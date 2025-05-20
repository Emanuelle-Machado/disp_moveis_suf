import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:sqflite/sqflite.dart';

class MarcaDAO {
  final Database db;

  MarcaDAO(this.db);

  Future<int> insert(Marca marca) async {
    return await db.insert('marca', marca.toMap());
  }

  Future<List<Marca>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query('marca');
    return List.generate(maps.length, (i) => Marca.fromMap(maps[i]));
  }

  Future<Marca?> getById(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'marca',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Marca.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(Marca marca) async {
    return await db.update(
      'marca',
      marca.toMap(),
      where: 'id = ?',
      whereArgs: [marca.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete('marca', where: 'id = ?', whereArgs: [id]);
  }
}
