
// Model class for device with mapping records in marker

class Mapdata {
  int? id;
  String? deviceid;
  String? devicename;
  String? lattitude;
  String? longitude;
  String? devicetype;
  String? wardname;

  Mapdata(this.id,
      this.deviceid,
      this.devicename,
      this.lattitude,
      this.longitude,
      this.devicetype,
      this.wardname);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'deviceid': deviceid,
      'devicename': devicename,
      'lattitude': lattitude,
      'longitude': longitude,
      'devicetype': devicetype,
      'wardname': wardname
    };
    return map;
  }

  Mapdata.fromMap(Map<String, dynamic> map) {
    id = map['id'] as int;
    deviceid = map['deviceid'] as String;
    devicename = map['devicename'] as String;
    lattitude = map['lattitude'] as String;
    longitude = map['longitude'] as String;
    devicetype = map['devicetype'] as String;
    wardname = map['wardname'] as String;
  }
}
