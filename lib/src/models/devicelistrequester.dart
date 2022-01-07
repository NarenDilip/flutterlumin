class DeviceRequester {
  String ilmnumber;
  String ccmsnumber;
  String polenumber;

  DeviceRequester(
      {required this.ilmnumber,
       required this.ccmsnumber,
       required this.polenumber});

  static DeviceRequester fromJson(dynamic json) {
    return DeviceRequester(
        ilmnumber: json["ilmnumber"],
        ccmsnumber: json["ccmsnumber"],
        polenumber: json["polenumber"]
    );
  }
}
