import 'package:flutterlumin/src/localdb/model/mapdata_model.dart';
import 'package:flutterlumin/src/localdb/model/ward_model.dart';
import 'package:flutterlumin/src/localdb/model/zone_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'model/localnetwork_model.dart';
import 'model/region_model.dart';

//Database helper class with table creation, insertion, updation and deletion

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

// table on creation
  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE region (id INTEGER PRIMARY KEY, regionid TEXT, regionname TEXT)');
    await db.execute(
        'CREATE TABLE zone (id INTEGER PRIMARY KEY, zoneid TEXT, zonename TEXT, regioninfo TEXT)');
    await db.execute(
        'CREATE TABLE ward (id INTEGER PRIMARY KEY, wardid TEXT, wardname TEXT, regionsinfo TEXT, zoneinfo TEXT)');
    await db.execute(
        'CREATE TABLE mapdata (id INTEGER PRIMARY KEY, deviceid TEXT, devicename TEXT, lattitude TEXT, longitude TEXT, devicetype TEXT, wardname TEXT)');
    await db.execute(
        'CREATE TABLE localdata (id INTEGER PRIMARY KEY, devname TEXT, prodname TEXT, prodcred TEXT, smartname TEXT, smartcred TEXT, prodstatus TEXT, smartstatus TEXT)');
  }

  // local network sync details addition
  Future<LocalNetData> localnetwork_add(LocalNetData localdata) async {
    var dbClient = await db;
    localdata.id = await dbClient.insert('localdata', localdata.toMap());
    return localdata;
  }

  // map details insertion for viewing map details
  Future<Mapdata> mapdata_add(Mapdata mapdata) async {
    var dbClient = await db;
    mapdata.id = await dbClient.insert('mapdata', mapdata.toMap());
    return mapdata;
  }

  // local network sync deletion updation based on the device name
  Future<int> Mapdata_delete(String? wardname) async {
    var dbClient = await db;
    return await dbClient.delete(
      'mapdata',
      where: 'wardname = ?',
      whereArgs: [wardname],
    );
  }


  // map details fetching for viewing map details
  Future<List<Mapdata>> mapdata_getDetails() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query('mapdata', columns: [
      'id',
      'deviceid',
      'devicename',
      'lattitude',
      'longitude',
      'devicetype',
      'wardname'
    ]);
    List<Mapdata> mapdata = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        mapdata.add(Mapdata.fromMap(maps[i] as dynamic));
      }
    }
    return mapdata;
  }

  // local network sync details fetching based on the device name
  Future<List<Mapdata>> get_details_LocalNetMapdata(
      String? wardname) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      'mapdata',
      where: 'wardname = ?',
      whereArgs: [wardname],
    );
    List<Mapdata> devicedetails = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        devicedetails.add(Mapdata.fromMap(maps[i] as dynamic));
      }
    }
    return devicedetails;
  }


  // local network sync details fetching based on the device name
  Future<List<LocalNetData>> get_namebased_LocalNetData(
      String? selecteddevicename) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      'localdata',
      where: 'devname = ?',
      whereArgs: [selecteddevicename],
    );
    List<LocalNetData> devicename = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        devicename.add(LocalNetData.fromMap(maps[i] as dynamic));
      }
    }
    return devicename;
  }


  // local network sync details fetching
  Future<List<LocalNetData>> localdata_getDetails() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query('localdata', columns: [
      'id',
      'devname',
      'prodname',
      'prodcred',
      'smartname',
      'smartcred',
      'prodstatus',
      'smartstatus'
    ]);
    List<LocalNetData> mapdata = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        mapdata.add(LocalNetData.fromMap(maps[i] as dynamic));
      }
    }
    return mapdata;
  }


  // local network sync details updation based on the device name
  Future<int> localdata_update(LocalNetData localNetData) async {
    var dbClient = await db;
    return await dbClient.update(
      'localdata',
      localNetData.toMap(),
      where: 'devname = ?',
      whereArgs: [localNetData.devname],
    );
  }

  // local network sync deletion updation based on the device name
  Future<int> localdata_delete(String? devicename) async {
    var dbClient = await db;
    return await dbClient.delete(
      'localdata',
      where: 'devname = ?',
      whereArgs: [devicename],
    );
  }


  // region details addition
  Future<Region> add(Region region) async {
    var dbClient = await db;
    region.id = await dbClient.insert('region', region.toMap());
    return region;
  }

  // region details fetching
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

  // region details fetching based on region name
  Future<List<Region>> region_name_regionbasedDetails(
      String? selectedRegion) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      'region',
      where: 'regionname = ?',
      whereArgs: [selectedRegion],
    );
    List<Region> region = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        region.add(Region.fromMap(maps[i] as dynamic));
      }
    }
    return region;
  }

  // region details deletion
  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      'region',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // zone details deletion
  Future<int> zone_delete(String? regioninfo) async {
    var dbClient = await db;
    return await dbClient.delete(
      'zone',
      where: 'regioninfo = ?',
      whereArgs: [regioninfo],
    );
  }

  // ward details deletion
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

  // zone details addition
  Future<Zone> zone_add(Zone zone) async {
    var dbClient = await db;
    zone.id = await dbClient.insert('zone', zone.toMap());
    return zone;
  }

  // ward details addition
  Future<Ward> ward_add(Ward ward) async {
    var dbClient = await db;
    ward.id = await dbClient.insert('ward', ward.toMap());
    return ward;
  }

  // ward details fetching
  Future<List<Ward>> ward_getDetails() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query('ward',
        columns: ['id', 'wardid', 'wardname', 'regionsinfo', 'zoneinfo']);
    List<Ward> ward = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        ward.add(Ward.fromMap(maps[i] as dynamic));
      }
    }
    return ward;
  }

  // ward details fetching based on ward name
  Future<List<Ward>> ward_basedDetails(String? selectedWard) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      'ward',
      where: 'wardname = ?',
      whereArgs: [selectedWard],
    );
    List<Ward> ward = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        ward.add(Ward.fromMap(maps[i] as dynamic));
      }
    }
    return ward;
  }

  // zone details fetching based on zone name
  Future<List<Zone>> zone_getDetails() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query('zone', columns: ['id', 'zoneid', 'zonename', 'regioninfo']);
    List<Zone> zone = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        zone.add(Zone.fromMap(maps[i] as dynamic));
      }
    }
    return zone;
  }

  // zone details fetching based on zone name
  Future<List<Zone>> zone_zonebasedDetails(String? selectedZone) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      'zone',
      where: 'zonename = ?',
      whereArgs: [selectedZone],
    );
    List<Zone> zone = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        zone.add(Zone.fromMap(maps[i] as dynamic));
      }
    }
    return zone;
  }

  // zone details fetching based on region info
  Future<List<Zone>> zone_regionbasedDetails(String? selectedZone) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      'zone',
      where: 'regioninfo = ?',
      whereArgs: [selectedZone],
    );
    List<Zone> zone = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        zone.add(Zone.fromMap(maps[i] as dynamic));
      }
    }
    return zone;
  }

  // ward details fetching based on zone info
  Future<List<Ward>> ward_zonebasedDetails(String? selectedZone) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      'ward',
      where: 'zoneinfo = ?',
      whereArgs: [selectedZone],
    );
    List<Ward> ward = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        ward.add(Ward.fromMap(maps[i] as dynamic));
      }
    }
    return ward;
  }

  // ward details fetching based on regions info
  Future<List<Ward>> ward_regionbasedDetails(String? selectedZone) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(
      'ward',
      where: 'regionsinfo = ?',
      whereArgs: [selectedZone],
    );
    List<Ward> ward = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        ward.add(Ward.fromMap(maps[i] as dynamic));
      }
    }
    return ward;
  }

  // region details fetching based on regions info
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

  // region details updation
  Future<int> update(Region region) async {
    var dbClient = await db;
    return await dbClient.update(
      'region',
      region.toMap(),
      where: 'id = ?',
      whereArgs: [region.id],
    );
  }

  // closing the database
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
