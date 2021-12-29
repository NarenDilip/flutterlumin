import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'model/region_model.dart';

class DBHelper {
  Database _db = null as Database;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'luminator.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE region (id INTEGER PRIMARY KEY, regionid TEXT, regionname TEXT)');
  }

  Future<Region> add(Region region) async {
    var dbClient = await db;
    region.id = await dbClient.insert('region', region.toMap());
    return region;
  }

  Future<List<Region>> getStudents() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('region', columns: ['id', 'regionid', 'regionname']);
    List<Region> region = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        region.add(Region.fromMap(maps[i] as dynamic));
      }
    }
    return region;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      'region',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Region region) async {
    var dbClient = await db;
    return await dbClient.update(
      'region',
      region.toMap(),
      where: 'id = ?',
      whereArgs: [region.id],
    );
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
