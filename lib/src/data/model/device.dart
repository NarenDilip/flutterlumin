import 'package:flutter/cupertino.dart';

class ProductDevice {
  late String name;
  late String id;
  late String type;
  IconData? icon;
  late bool isInstalled;
  late bool deviceActiveStatus = false;
  late bool deviceStatus = false;
  String deviceTimeStamp = "";
  String location = "";
  String watts = "";
  String latitude = "";
  String longitude = "";
}
