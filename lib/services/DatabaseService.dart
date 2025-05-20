import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  final String _baseUrl = 'https://argo.td.ufpr.edu.br/maquinas/ws';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'maquinas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tipos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao TEXT,
            syncStatus TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE marcas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            syncStatus TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE maquinas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idMarca INTEGER,
            idTipo INTEGER,
            anoFabricacao INTEGER,
            contatoProprietario TEXT,
            dataInclusao TEXT,
            descricao TEXT,
            nomeProprietario TEXT,
            percentualComissao REAL,
            status TEXT,
            valor REAL,
            syncStatus TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            resource TEXT,
            action TEXT,
            data TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/tipo'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<int> saveResource(String resource, dynamic data, String action) async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();
    int localId;

    if (action == 'create') {
      localId = await db.insert(resource, data.toMap());
    } else {
      localId = data.id;
      await db.update(
        resource,
        data.toMap(),
        where: 'id = ?',
        whereArgs: [localId],
      );
    }

    await db.insert('sync_queue', {
      'resource': resource,
      'action': action,
      'data': jsonEncode({...data.toMap(), 'localId': localId}),
      'timestamp': timestamp,
    });

    if (await isOnline()) {
      await syncWithServer();
    }

    return localId;
  }

  Future<void> syncWithServer() async {
    if (!(await isOnline())) return;

    final db = await database;
    final queue = await db.query('sync_queue');
    if (queue.isEmpty) return;

    final syncFutures = queue.map((item) async {
      try {
        final resource = item['resource'] as String;
        final action = item['action'] as String;
        final data = jsonDecode(item['data'] as String);
        final localId = data['localId'];
        final payload =
            Map<String, dynamic>.from(data)
              ..remove('localId')
              ..remove('syncStatus');
        final url =
            action == 'update'
                ? '$_baseUrl/$resource/${data['id']}'
                : '$_baseUrl/$resource';

        http.Response response;
        if (action == 'create') {
          response = await http.post(
            Uri.parse(url),
            body: jsonEncode(payload),
            headers: {'Content-Type': 'application/json'},
          );
        } else {
          response = await http.put(
            Uri.parse(url),
            body: jsonEncode(payload),
            headers: {'Content-Type': 'application/json'},
          );
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          final serverData = jsonDecode(response.body);
          await db.transaction((txn) async {
            await txn.update(
              resource,
              {...serverData, 'syncStatus': 'synced'},
              where: 'id = ?',
              whereArgs: [localId],
            );
            await txn.delete(
              'sync_queue',
              where: 'id = ?',
              whereArgs: [item['id']],
            );
          });
          return true;
        }
        return false;
      } catch (e) {
        print('Erro ao sincronizar: $e');
        return false;
      }
    });

    await Future.wait(syncFutures);
  }

  Future<List<dynamic>> getAll(String resource) async {
    final db = await database;
    final result = await db.query(resource);
    if (resource == 'tipos')
      return result.map((e) => Tipo.fromJson(e)).toList();
    if (resource == 'marcas')
      return result.map((e) => Marca.fromJson(e)).toList();
    return result.map((e) => Maquina.fromJson(e)).toList();
  }

  Future<dynamic> getById(String resource, int id) async {
    final db = await database;
    final result = await db.query(resource, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    if (resource == 'tipos') return Tipo.fromJson(result.first);
    if (resource == 'marcas') return Marca.fromJson(result.first);
    return Maquina.fromJson(result.first);
  }

  Future<void> fetchFromServer(String resource) async {
    if (!(await isOnline())) return;

    try {
      final response = await http.get(Uri.parse('$_baseUrl/$resource'));
      if (response.statusCode == 200) {
        final db = await database;
        final data = jsonDecode(response.body) as List;
        await db.transaction((txn) async {
          await txn.delete(resource);
          for (var item in data) {
            await txn.insert(resource, {...item, 'syncStatus': 'synced'});
          }
        });
      }
    } catch (e) {
      print('Erro ao buscar $resource do servidor: $e');
    }
  }

  Future<void> syncAllResources() async {
    final resources = ['tipos', 'marcas', 'maquinas'];
    await Future.wait(resources.map((resource) => fetchFromServer(resource)));
    await syncWithServer();
  }
}
