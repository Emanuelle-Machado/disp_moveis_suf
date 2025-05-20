import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._internal();
  Database? _db;

  LocalDatabaseService._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    // Inicialize seu banco de dados aqui
    _db = await openDatabase(
      'app.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tipos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao TEXT,
            sincronizado INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE marcas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT,
            sincronizado INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE maquinas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao TEXT,
            idTipo INTEGER,
            idMarca INTEGER,
            sincronizado INTEGER DEFAULT 0
          )
        ''');
      },
    );
    return _db!;
  }

  // TIPOS
  Future<List<Tipo>> getTiposPendentes() async {
    final db = await database;
    final maps = await db.query('tipos', where: 'sincronizado = 0');
    return maps.map((e) => Tipo.fromMap(e)).toList();
  }

  Future<void> marcarTipoSincronizado(Tipo tipo) async {
    final db = await database;
    await db.update(
      'tipos',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [tipo.id],
    );
  }

  Future<void> atualizarTipos(List<Tipo> tipos) async {
    final db = await database;
    await db.delete('tipos');
    for (var tipo in tipos) {
      await db.insert('tipos', tipo.toMap()..['sincronizado'] = 1);
    }
  }

  // MARCAS
  Future<List<Marca>> getMarcasPendentes() async {
    final db = await database;
    final maps = await db.query('marcas', where: 'sincronizado = 0');
    return maps.map((e) => Marca.fromMap(e)).toList();
  }

  Future<void> marcarMarcaSincronizada(Marca marca) async {
    final db = await database;
    await db.update(
      'marcas',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [marca.id],
    );
  }

  Future<void> atualizarMarcas(List<Marca> marcas) async {
    final db = await database;
    await db.delete('marcas');
    for (var marca in marcas) {
      await db.insert('marcas', marca.toMap()..['sincronizado'] = 1);
    }
  }

  // MAQUINAS
  Future<List<Maquina>> getMaquinasPendentes() async {
    final db = await database;
    final maps = await db.query('maquinas', where: 'sincronizado = 0');
    return maps.map((e) => Maquina.fromMap(e)).toList();
  }

  Future<void> marcarMaquinaSincronizada(Maquina maquina) async {
    final db = await database;
    await db.update(
      'maquinas',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [maquina.id],
    );
  }

  Future<void> atualizarMaquinas(List<Maquina> maquinas) async {
    final db = await database;
    await db.delete('maquinas');
    for (var maquina in maquinas) {
      await db.insert('maquinas', maquina.toMap()..['sincronizado'] = 1);
    }
  }
}
