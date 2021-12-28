import 'package:flutterlumin/src/local/model/region.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbManager {
  late Database _database;

  Future openDb() async {
    _database = await openDatabase(
        join(await getDatabasesPath(), "region_database.db"),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
        'CREATE TABLE region(id INTEGER PRIMARY KEY, regionId INTEGER, regionName TEXT)',
      );
    });
    return _database;
  }

  Future insertRegion(Region region) async {
    await openDb();
    return await _database.insert('region', region.toMap());
  }

  Future<List<Region>> getModelList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('region');

    return List.generate(maps.length, (i) {
      return Region(
        id: maps[i]['id'],
        regionId: maps[i]['regionId'],
        regionName: maps[i]['regionName'],
      );
    });
    // return maps
    //     .map((e) => Model(
    //         id: e["id"], fruitName: e["fruitName"], quantity: e["quantity"]))
    //     .toList();
  }
}
