class Region {
  late int id;
  late String regionid;
  late String regionname;

  Region(
  this.id,
  this.regionid,
  this.regionname);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'regionid': regionid,
      'regionname': regionname,
    };
    return map;
  }

  Region.fromMap(Map<String, dynamic> map) {
    id = map['id'] as int;
    regionid = map['regionid'] as String;
    regionname = map['regionname'] as String;
  }
}
