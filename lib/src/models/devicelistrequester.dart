class DeviceRequester {
  String ilmnumber;

  DeviceRequester(
      {required this.ilmnumber});

  static DeviceRequester fromJson(dynamic json) {
    return DeviceRequester(
        ilmnumber: json["ilmnumber"]);
  }
}
