import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:sqflite/sqflite.dart';

class TipoDAO {
  final Database db;

  TipoDAO(this.db);

  Future<int> insert(Tipo tipo) async {
    return await db.insert('tipo', tipo.toMap());
  }

  Future<List<Tipo>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query('tipo');
    return List.generate(maps.length, (i) {
      return Tipo.fromMap(maps[i]);
    });
  }

  Future<Tipo?> getById(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'tipo',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Tipo.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Tipo tipo) async {
    return await db.update(
      'tipo',
      tipo.toMap(),
      where: 'id = ?',
      whereArgs: [tipo.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete('tipo', where: 'id = ?', whereArgs: [id]);
  }
}
