import 'package:disp_moveis_suf/models/OperacaoSincronizacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'maquinas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

  Future<int> _getNextId(String table) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COALESCE(MAX(id), 0) + 1 as nextId FROM $table');
    return result.first['nextId'] as int;
  }

  // Tipos
  Future<List<Tipo>> obterTipos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tipos');
    return List.generate(maps.length, (i) => Tipo.fromMap(maps[i]));
  }

  Future<void> inserirTipo(Tipo tipo) async {
    final db = await database;
    final id = await _getNextId('tipos');
    final tipoComId = Tipo(id: id, descricao: tipo.descricao);
    await db.insert('tipos', tipoComId.toMap());
    await db.insert('fila_sincronizacao', {
      'recurso': 'tipo',
      'recursoId': id,
      'operacao': 'inserir',
      'dados': jsonEncode(tipoComId.toApiMap()),
    });
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
  }

  Future<void> excluirTipo(int id) async {
    final db = await database;
    await db.delete('tipos', where: 'id = ?', whereArgs: [id]);
    await db.insert('fila_sincronizacao', {
      'recurso': 'tipo',
      'recursoId': id,
      'operacao': 'excluir',
      'dados': '{}',
    });
  }

  // Marcas
  Future<List<Marca>> obterMarcas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('marcas');
    return List.generate(maps.length, (i) => Marca.fromMap(maps[i]));
  }

  Future<void> inserirMarca(Marca marca) async {
    final db = await database;
    final id = await _getNextId('marcas');
    final marcaComId = Marca(id: id, nome: marca.nome);
    await db.insert('marcas', marcaComId.toMap());
    await db.insert('fila_sincronizacao', {
      'recurso': 'marca',
      'recursoId': id,
      'operacao': 'inserir',
      'dados': jsonEncode(marcaComId.toApiMap()),
    });
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
  }

  Future<void> excluirMarca(int id) async {
    final db = await database;
    await db.delete('marcas', where: 'id = ?', whereArgs: [id]);
    await db.insert('fila_sincronizacao', {
      'recurso': 'marca',
      'recursoId': id,
      'operacao': 'excluir',
      'dados': '{}',
    });
  }

  // Máquinas
  Future<List<Maquina>> obterMaquinas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('maquinas');
    return List.generate(maps.length, (i) => Maquina.fromMap(maps[i]));
  }

  Future<void> inserirMaquina(Maquina maquina) async {
    final db = await database;
    final id = await _getNextId('maquinas');
    final maquinaComId = Maquina(
      id: id,
      idMarca: maquina.idMarca,
      idTipo: maquina.idTipo,
      anoFabricacao: maquina.anoFabricacao,
      contatoProprietario: maquina.contatoProprietario,
      dataInclusao: maquina.dataInclusao,
      descricao: maquina.descricao,
      nomeProprietario: maquina.nomeProprietario,
      percentualComissao: maquina.percentualComissao,
      status: maquina.status,
      valor: maquina.valor,
    );
    await db.insert('maquinas', maquinaComId.toMap());
    await db.insert('fila_sincronizacao', {
      'recurso': 'maquina',
      'recursoId': id,
      'operacao': 'inserir',
      'dados': jsonEncode(maquinaComId.toApiMap()),
    });
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
  }

  Future<void> marcarMaquinaComoSincronizada(int id) async {
    final db = await database;
    await db.update(
      'maquinas',
      {'isSincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fila de sincronização
  Future<List<OperacaoSincronizacao>> obterOperacoesPendentes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fila_sincronizacao');
    return List.generate(maps.length, (i) => OperacaoSincronizacao.fromMap(maps[i]));
  }

  Future<void> limparFilaSincronizacao(int id) async {
    final db = await database;
    await db.delete('fila_sincronizacao', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> debugFilaSincronizacao() async {
    final operacoes = await obterOperacoesPendentes();
    debugPrint('Conteúdo da fila_sincronizacao: $operacoes');
  }
}