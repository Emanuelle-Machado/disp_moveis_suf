import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/OperacaoSincronizacao.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const int _version = 2;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('maquinas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: _version,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tipos (
      id INTEGER PRIMARY KEY,
      descricao TEXT NOT NULL
    )
    ''');
    await db.execute('''
    CREATE TABLE marcas (
      id INTEGER PRIMARY KEY,
      nome TEXT NOT NULL
    )
    ''');
    await db.execute('''
    CREATE TABLE maquinas (
      id INTEGER PRIMARY KEY,
      idMarca INTEGER NOT NULL,
      idTipo INTEGER NOT NULL,
      anoFabricacao INTEGER NOT NULL,
      contatoProprietario TEXT NOT NULL,
      dataInclusao TEXT NOT NULL,
      descricao TEXT NOT NULL,
      nomeProprietario TEXT NOT NULL,
      percentualComissao REAL NOT NULL,
      status TEXT NOT NULL,
      valor REAL NOT NULL,
      isSincronizado INTEGER NOT NULL DEFAULT 0
    )
    ''');
    await db.execute('''
    CREATE TABLE fila_sincronizacao (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      recurso TEXT NOT NULL,
      recursoId INTEGER NOT NULL,
      operacao TEXT NOT NULL,
      dados TEXT NOT NULL
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE maquinas ADD COLUMN isSincronizado INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<bool> podeExcluirTipo(int id) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM maquinas WHERE idTipo = ?', [id]));
    return count == 0;
  }

  Future<bool> podeExcluirMarca(int id) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM maquinas WHERE idMarca = ?', [id]));
    return count == 0;
  }

  Future<void> debugFilaSincronizacao() async {
    final db = await database;
    final maps = await db.query('fila_sincronizacao');
    debugPrint('Conteúdo da fila_sincronizacao: $maps');
  }

  Future<void> limparFilaSincronizacaoCompleta() async {
    final db = await database;
    await db.delete('fila_sincronizacao');
    debugPrint('Fila de sincronização limpa');
  }

  Future<void> limparRegistrosNaoSincronizados() async {
    final db = await database;
    await db.delete('tipos');
    await db.delete('marcas');
    await db.delete('maquinas', where: 'isSincronizado = ?', whereArgs: [0]);
    debugPrint('Registros não sincronizados limpos');
  }

  Future<void> marcarMaquinaComoSincronizada(int id) async {
    final db = await database;
    await db.update(
      'maquinas',
      {'isSincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('Máquina ID: $id marcada como sincronizada');
  }

  // Tipos
  Future<void> inserirTipo(Tipo tipo) async {
    final db = await database;
    await db.insert('tipos', tipo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('fila_sincronizacao', {
      'recurso': 'tipo',
      'recursoId': tipo.id,
      'operacao': 'inserir',
      'dados': jsonEncode(tipo.toApiMap()),
    });
    await debugFilaSincronizacao();
  }

  Future<void> atualizarTipo(Tipo tipo) async {
    final db = await database;
    await db.update('tipos', tipo.toMap(), where: 'id = ?', whereArgs: [tipo.id]);
    await db.insert('fila_sincronizacao', {
      'recurso': 'tipo',
      'recursoId': tipo.id,
      'operacao': 'atualizar',
      'dados': jsonEncode(tipo.toApiMap()),
    });
    await debugFilaSincronizacao();
  }

  Future<void> excluirTipo(int id) async {
    if (!await podeExcluirTipo(id)) {
      throw Exception('Não é possível excluir tipo com máquinas vinculadas');
    }
    final db = await database;
    await db.delete('tipos', where: 'id = ?', whereArgs: [id]);
    await db.insert('fila_sincronizacao', {
      'recurso': 'tipo',
      'recursoId': id,
      'operacao': 'excluir',
      'dados': '{}',
    });
    await debugFilaSincronizacao();
  }

  Future<List<Tipo>> obterTipos() async {
    final db = await database;
    final maps = await db.query('tipos');
    return List.generate(maps.length, (i) => Tipo.fromMap(maps[i]));
  }

  // Marcas
  Future<void> inserirMarca(Marca marca) async {
    final db = await database;
    await db.insert('marcas', marca.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('fila_sincronizacao', {
      'recurso': 'marca',
      'recursoId': marca.id,
      'operacao': 'inserir',
      'dados': jsonEncode(marca.toApiMap()),
    });
    await debugFilaSincronizacao();
  }

  Future<void> atualizarMarca(Marca marca) async {
    final db = await database;
    await db.update('marcas', marca.toMap(), where: 'id = ?', whereArgs: [marca.id]);
    await db.insert('fila_sincronizacao', {
      'recurso': 'marca',
      'recursoId': marca.id,
      'operacao': 'atualizar',
      'dados': jsonEncode(marca.toApiMap()),
    });
    await debugFilaSincronizacao();
  }

  Future<void> excluirMarca(int id) async {
    if (!await podeExcluirMarca(id)) {
      throw Exception('Não é possível excluir marca com máquinas vinculadas');
    }
    final db = await database;
    await db.delete('marcas', where: 'id = ?', whereArgs: [id]);
    await db.insert('fila_sincronizacao', {
      'recurso': 'marca',
      'recursoId': id,
      'operacao': 'excluir',
      'dados': '{}',
    });
    await debugFilaSincronizacao();
  }

  Future<List<Marca>> obterMarcas() async {
    final db = await database;
    final maps = await db.query('marcas');
    return List.generate(maps.length, (i) => Marca.fromMap(maps[i]));
  }

  // Máquinas
  Future<void> inserirMaquina(Maquina maquina) async {
    final db = await database;
    await db.insert('maquinas', maquina.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('fila_sincronizacao', {
      'recurso': 'maquina',
      'recursoId': maquina.id,
      'operacao': 'inserir',
      'dados': jsonEncode(maquina.toApiMap()),
    });
    await debugFilaSincronizacao();
  }

  Future<void> atualizarMaquina(Maquina maquina) async {
    final db = await database;
    await db.update('maquinas', maquina.toMap(), where: 'id = ?', whereArgs: [maquina.id]);
    await db.insert('fila_sincronizacao', {
      'recurso': 'maquina',
      'recursoId': maquina.id,
      'operacao': 'atualizar',
      'dados': jsonEncode(maquina.toApiMap()),
    });
    await debugFilaSincronizacao();
  }

  Future<void> excluirMaquina(int id) async {
    final db = await database;
    await db.delete('maquinas', where: 'id = ?', whereArgs: [id]);
    await db.insert('fila_sincronizacao', {
      'recurso': 'maquina',
      'recursoId': id,
      'operacao': 'excluir',
      'dados': '{}',
    });
    await debugFilaSincronizacao();
  }

  Future<List<Maquina>> obterMaquinas() async {
    final db = await database;
    final maps = await db.query('maquinas');
    return List.generate(maps.length, (i) => Maquina.fromMap(maps[i]));
  }

  Future<List<OperacaoSincronizacao>> obterOperacoesPendentes() async {
    final db = await database;
    final maps = await db.query('fila_sincronizacao');
    return List.generate(maps.length, (i) => OperacaoSincronizacao.fromMap(maps[i]));
  }

  Future<void> limparFilaSincronizacao(int id) async {
    final db = await database;
    await db.delete('fila_sincronizacao', where: 'id = ?', whereArgs: [id]);
  }
}