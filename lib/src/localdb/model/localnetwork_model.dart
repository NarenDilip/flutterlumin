
// Model class for device with internet connectivity local sync

class LocalNetData {
  int? id;
  String? devname;
  String? prodname;
  String? prodcred;
  String? smartname;
  String? smartcred;
  String? prodstatus;
  String? smartstatus;

  LocalNetData(this.id,
      this.devname,
      this.prodname,
      this.prodcred,
      this.smartname,
      this.smartcred,
      this.prodstatus,
      this.smartstatus);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'devname': devname,
      'prodname': prodname,
      'prodcred': prodcred,
      'smartname': smartname,
      'smartcred': smartcred,
      'prodstatus': prodstatus,
      'smartstatus': smartstatus
    };
    return map;
  }

  LocalNetData.fromMap(Map<String, dynamic> map) {
    id = map['id'] as int;
    devname = map['devname'] as String;
    prodname = map['prodname'] as String;
    prodcred = map['prodcred'] as String;
    smartname = map['smartname'] as String;
    smartcred = map['smartcred'] as String;
    prodstatus = map['prodstatus'] as String;
    smartstatus = map['smartstatus'] as String;
  }
}
