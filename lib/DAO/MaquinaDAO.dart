import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:sqflite/sqflite.dart';

class MaquinaDAO {
  final Database db;

  MaquinaDAO(this.db);

  Future<int> insert(Maquina maquina) async {
    return await db.insert(
      'maquinas',
      maquina.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Maquina>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query('maquinas');
    return List.generate(maps.length, (i) {
      return Maquina.fromMap(maps[i]);
    });
  }

  Future<int> update(Maquina maquina, int id) async {
    return await db.update(
      'maquinas',
      maquina.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete('maquinas', where: 'id = ?', whereArgs: [id]);
  }
}
