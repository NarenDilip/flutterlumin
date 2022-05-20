import 'package:flutterlumin/src/localdb/model/mapdata_model.dart';
import 'package:flutterlumin/src/localdb/model/ward_model.dart';
import 'package:flutterlumin/src/data/model/zone_model.dart';
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
    await db.execute('CREATE TABLE zone (id INTEGER PRIMARY KEY, zoneid TEXT, zonename TEXT, regioninfo TEXT)');
    await db.execute('CREATE TABLE ward (id INTEGER PRIMARY KEY, wardid TEXT, wardname TEXT, regionsinfo TEXT, zoneinfo TEXT)');
    await db.execute('CREATE TABLE mapdata (id INTEGER PRIMARY KEY, deviceid TEXT, devicename TEXT, lattitude TEXT, longitude TEXT, devicetype TEXT, wardname TEXT)');
  }

  Future<Mapdata> mapdata_add(Mapdata mapdata) async {
    var dbClient = await db;
    mapdata.id = await dbClient.insert('mapdata', mapdata.toMap());
    return mapdata;
  }

  Future<List<Mapdata>> mapdata_getDetails() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('mapdata', columns: ['id', 'deviceid', 'devicename', 'lattitude', 'longitude', 'devicetype', 'wardname']);
    List<Mapdata> mapdata = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        mapdata.add(Mapdata.fromMap(maps[i] as dynamic));
      }
    }
    return mapdata;
  }

  Future<Region> add(Region region) async {
    var dbClient = await db;
    region.id = await dbClient.insert('region', region.toMap());
    return region;
  }

  Future<List<Region>> region_getDetails() async {
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

  Future<List<Region>> region_name_regionbasedDetails(String? selectedRegion) async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('region',
      where: 'regionname = ?',
      whereArgs: [selectedRegion],);
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


  Future<int> zone_delete(String? regioninfo) async {
    var dbClient = await db;
    return await dbClient.delete(
      'zone',
      where: 'regioninfo = ?',
      whereArgs: [regioninfo],
    );
  }

  Future<int> ward_delete(String? zoneinfo) async {
    var dbClient = await db;
    return await dbClient.delete(
      'ward',
      where: 'zoneinfo = ?',
      whereArgs: [zoneinfo],
    );
  }

  // Future<int> region_delete() async {
  //   var dbClient = await db;
  //   return await dbClient.rawDelete("DROP TABLE IF EXISTS region");
  // }
  //
  // Future<int> zone_delete() async {
  //   var dbClient = await db;
  //   return await dbClient.rawDelete("DROP TABLE IF EXISTS zone");
  // }
  //
  // Future<int> ward_delete() async {
  //   var dbClient = await db;
  //   return await dbClient.rawDelete("DROP TABLE IF EXISTS ward");
  // }

  Future<ZoneResponse> zone_add(ZoneResponse zone) async {
    var dbClient = await db;
    zone.id = await dbClient.insert('zone', zone.toMap());
    return zone;
  }

  Future<Ward> ward_add(Ward ward) async {
    var dbClient = await db;
    ward.id = await dbClient.insert('ward', ward.toMap());
    return ward;
  }

  Future<List<Ward>> ward_getDetails() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('ward', columns: ['id', 'wardid', 'wardname', 'regionsinfo', 'zoneinfo']);
    List<Ward> ward = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        ward.add(Ward.fromMap(maps[i] as dynamic));
      }
    }
    return ward;
  }



  Future<List<Ward>> ward_basedDetails(String? selectedWard) async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('ward',
      where: 'wardname = ?',
      whereArgs: [selectedWard],);
    List<Ward> ward = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        ward.add(Ward.fromMap(maps[i] as dynamic));
      }
    }
    return ward;
  }

  Future<List<ZoneResponse>> zone_getDetails() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('zone', columns: ['id', 'zoneid', 'zonename', 'regioninfo']);
    List<ZoneResponse> zone = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        zone.add(ZoneResponse.fromMap(maps[i] as dynamic));
      }
    }
    return zone;
  }

  Future<List<ZoneResponse>> zone_zonebasedDetails(String? selectedZone) async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('zone',
      where: 'zonename = ?',
      whereArgs: [selectedZone],);
    List<ZoneResponse> zone = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        zone.add(ZoneResponse.fromMap(maps[i] as dynamic));
      }
    }
    return zone;
  }

  Future<List<ZoneResponse>> zone_regionbasedDetails(String? selectedZone) async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('zone',
        where: 'regioninfo = ?',
        whereArgs: [selectedZone],);
    List<ZoneResponse> zone = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        zone.add(ZoneResponse.fromMap(maps[i] as dynamic));
      }
    }
    return zone;
  }

  Future<List<Ward>> ward_zonebasedDetails(String? selectedZone) async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('ward',
      where: 'zoneinfo = ?',
      whereArgs: [selectedZone],);
    List<Ward> ward = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        ward.add(Ward.fromMap(maps[i] as dynamic));
      }
    }
    return ward;
  }

  Future<List<Ward>> ward_regionbasedDetails(String? selectedZone) async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('ward',
      where: 'regionsinfo = ?',
      whereArgs: [selectedZone],);
    List<Ward> ward = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        ward.add(Ward.fromMap(maps[i] as dynamic));
      }
    }
    return ward;
  }

  Future<List<Region>> getDetails() async {
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

  // Future<int> delete(int id) async {
  //   var dbClient = await db;
  //   return await dbClient.delete(
  //     'region',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }


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
