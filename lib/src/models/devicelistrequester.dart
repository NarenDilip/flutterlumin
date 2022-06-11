// model class for requesting server with key values
class DeviceRequester {
  String ilmnumber;
  String ccmsnumber;
  String polenumber;
  String gatewaynumber;

  DeviceRequester(
      {required this.ilmnumber,
       required this.ccmsnumber,
       required this.polenumber,
        required this.gatewaynumber});

  static DeviceRequester fromJson(dynamic json) {
    return DeviceRequester(
        ilmnumber: json["ilmnumber"],
        ccmsnumber: json["ccmsnumber"],
        polenumber: json["polenumber"],
        gatewaynumber: json["gatewaynumber"]
    );
  }
}
