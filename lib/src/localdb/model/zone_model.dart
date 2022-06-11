
// Model class for zone with data entry

class Zone {
  int? id;
  String? zoneid;
  String? zonename;
  String? regioninfo;

  Zone(this.id,
      this.zoneid,
      this.zonename,
      this.regioninfo);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'zoneid': zoneid,
      'zonename': zonename,
      'regioninfo': regioninfo
    };
    return map;
  }

  Zone.fromMap(Map<String, dynamic> map) {
    id = map['id'] as int;
    zoneid = map['zoneid'] as String;
    zonename = map['zonename'] as String;
    regioninfo = map['regioninfo'] as String;
  }
}
