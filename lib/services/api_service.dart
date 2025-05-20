import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:disp_moveis_suf/services/LocalDatabaseService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:sqflite/sqflite.dart';

// Serviço API
class ApiService {
  static const String baseUrl = 'https://argo.td.ufpr.edu.br/maquinas/ws';
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await LocalDatabaseService.instance.database;
    return _database!;
  }

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/tipo'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
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
                ? '$baseUrl/$resource/${data['id']}'
                : '$baseUrl/$resource';

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
      final response = await http.get(Uri.parse('$baseUrl/$resource'));
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

  Future<void> syncData() async {
    // Exemplo genérico: adapte para seu banco local e lógica de sincronização

    // 1. Sincronizar dados locais pendentes com a API remota
    // (Exemplo: enviar novos registros ou atualizações locais)
    // Supondo que você tenha um LocalDatabaseService com métodos apropriados

    // Sincronizar Tipos
    final localTipos = await LocalDatabaseService.instance.getTiposPendentes();
    for (var tipo in localTipos) {
      await updateTipo(tipo, tipo.id);
      await LocalDatabaseService.instance.marcarTipoSincronizado(tipo);
    }

    // Sincronizar Marcas
    final localMarcas =
        await LocalDatabaseService.instance.getMarcasPendentes();
    for (var marca in localMarcas) {
      await updateMarca(marca, marca.id);
      await LocalDatabaseService.instance.marcarMarcaSincronizada(marca);
    }

    // Sincronizar Máquinas
    final localMaquinas =
        await LocalDatabaseService.instance.getMaquinasPendentes();
    for (var maquina in localMaquinas) {
      await updateMaquina(maquina, maquina.id);
      await LocalDatabaseService.instance.marcarMaquinaSincronizada(maquina);
    }

    // 2. Buscar dados atualizados da API remota e atualizar o banco local
    final tiposRemotos = await getTipos();
    await LocalDatabaseService.instance.atualizarTipos(tiposRemotos);

    final marcasRemotas = await getMarcas();
    await LocalDatabaseService.instance.atualizarMarcas(marcasRemotas);

    final maquinasRemotas = await getMaquinas();
    await LocalDatabaseService.instance.atualizarMaquinas(maquinasRemotas);
  }

  Future<List<T>> _getList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => fromJson(json)).toList();
    } else {
      throw Exception('Erro ao listar $endpoint');
    }
  }

  Future<T> _getSingle<T>(
    String endpoint,
    int id,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id'));
    if (response.statusCode == 200) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao consultar $endpoint/$id');
    }
  }

  Future<void> _post<T>(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar $endpoint');
    }
  }

  Future<void> _put<T>(
    String endpoint,
    int id,
    Map<String, dynamic> data,
  ) async {
    data['id'] = id;
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar $endpoint/$id');
    }
  }

  Future<void> _delete(String endpoint, int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar $endpoint/$id');
    }
  }

  // Métodos para Tipo
  Future<List<Tipo>> getTipos() => _getList('tipo', Tipo.fromJson);
  Future<Tipo> getTipo(int id) => _getSingle('tipo', id, Tipo.fromJson);
  Future<void> createTipo(Tipo tipo) => _post('tipo', tipo.toJson());
  Future<void> updateTipo(Tipo tipo, int id) => _put('tipo', id, tipo.toJson());
  Future<void> deleteTipo(int id) => _delete('tipo', id);

  // Métodos para Marca
  Future<List<Marca>> getMarcas() => _getList('marca', Marca.fromJson);
  Future<Marca> getMarca(int id) => _getSingle('marca', id, Marca.fromJson);
  Future<void> createMarca(Marca marca) => _post('marca', marca.toJson());
  Future<void> updateMarca(Marca marca, int id) =>
      _put('marca', id, marca.toJson());
  Future<void> deleteMarca(int id) => _delete('marca', id);

  // Métodos para Máquina
  Future<List<Maquina>> getMaquinas({
    double? valorDe,
    double? valorAte,
    String? status,
    int? idTipo,
    int? idMarca,
  }) async {
    final queryParams = <String, String>{};
    if (valorDe != null) queryParams['valorDe'] = valorDe.toString();
    if (valorAte != null) queryParams['valorAte'] = valorAte.toString();
    if (status != null) queryParams['status'] = status;
    if (idTipo != null) queryParams['idTipo'] = idTipo.toString();
    if (idMarca != null) queryParams['idMarca'] = idMarca.toString();

    final uri = Uri.parse(
      '$baseUrl/maquina',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Maquina.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao listar máquinas');
    }
  }

  Future<Maquina> getMaquina(int id) =>
      _getSingle('maquina', id, Maquina.fromJson);
  Future<void> createMaquina(Maquina maquina) =>
      _post('maquina', maquina.toJson());
  Future<void> updateMaquina(Maquina maquina, int id) =>
      _put('maquina', id, maquina.toJson());
  Future<void> deleteMaquina(int id) => _delete('maquina', id);

  Future<void> syncAllResources() async {
    final resources = ['tipos', 'marcas', 'maquinas'];
    await Future.wait(resources.map((resource) => fetchFromServer(resource)));
    await syncWithServer();
  }
}
