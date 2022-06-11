
// Model class for region with data entry

class Region {
  int? id;
  String? regionid;
  String? regionname;

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
