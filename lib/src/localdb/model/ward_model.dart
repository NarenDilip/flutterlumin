
// Model class for ward with data entry

class Ward {
  int? id;
  String? wardid;
  String? wardname;
  String? regionsinfo;
  String? zoneinfo;

  Ward(this.id,
      this.wardid,
      this.wardname,
      this.regionsinfo,
      this.zoneinfo);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'wardid': wardid,
      'wardname': wardname,
      'regionsinfo': regionsinfo,
      'zoneinfo': zoneinfo
    };
    return map;
  }

  Ward.fromMap(Map<String, dynamic> map) {
    id = map['id'] as int;
    wardid = map['wardid'] as String;
    wardname = map['wardname'] as String;
    regionsinfo = map['regionsinfo'] as String;
    zoneinfo = map['zoneinfo'] as String;
  }
}
