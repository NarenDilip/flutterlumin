import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/ui/maintenance/ccms/ccms_maintenance_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToggleButtonn extends StatefulWidget {
  const ToggleButtonn({Key? key}) : super(key: key);

  @override
  _ToggleButtonnState createState() => _ToggleButtonnState();
}

const double width = 300.0;
const double height = 90.0;
const double loginAlign = -1;
const double signInAlign = 1;
const Color selectedColor = Colors.black54;
const Color normalColor = Colors.black54;
bool visibility = true;

class _ToggleButtonnState extends State<ToggleButtonn> {
  late double xAlign;
  late Color loginColor;
  late Color signInColor;
  final Location locations = Location();
  LocationData? _location;
  StreamSubscription<LocationData>? _locationSubscription;
  String? _error;
  String address = "";
  List<double>? _latt = [];
  double lattitude = 0;
  double longitude = 0;
  String Lattitude = "0";
  String Longitude = "0";
  LocationData? currentLocation;
  double accuracy = 0;
  late bool visibility = false;

  @override
  void initState() {
    super.initState();
    xAlign = loginAlign;
    loginColor = selectedColor;
    signInColor = normalColor;
    getPrefs();
    _listenLocation();
  }

  Future<void> getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Lattitude = prefs.getString('deviceLatitude').toString();
    Longitude = prefs.getString('deviceLongitude').toString();
    setState(() {
      Lattitude = Lattitude;
      Longitude = Longitude;
    });
  }

  Future<void> _listenLocation() async {
    _locationSubscription =
        locations.onLocationChanged.handleError((dynamic err) {
      if (err is PlatformException) {
        setState(() {
          _error = err.code;
        });
      }
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((LocationData currentLocation) {
      setState(() {
        _error = null;
        _location = currentLocation;
        _getAddress(_location!.latitude, _location!.longitude).then((value) {
          setState(() async {
            address = value;
            if (_latt!.length <= 5) {
              _latt!.add(_location!.latitude!);
              lattitude = _location!.latitude!;
              longitude = _location!.longitude!;
              accuracy = _location!.accuracy!;
              // addresss = addresss;
            } else {
              _locationSubscription?.cancel();
              var accuvalue = accuracy.toString().split(".");
              var addvalue = value.toString().split(",");

              // if (accuracy <= 7) {
              //   _locationSubscription?.cancel();
              //   setState(() {
              // _locationSubscription = null;
              // });
              accuvalue = accuracy.toString().split(".");
              // distanceCalculation(context);

              Geolocator geolocator = new Geolocator();
              var difference = await geolocator.distanceBetween(
                  double.parse(Lattitude),
                  double.parse(Longitude),
                  _location!.latitude!,
                  _location!.longitude!);
              if (difference <= 5.0) {
                visibility = true;
              } else {
                visibility = false;
              }
              // }
            }
          });
        });
      });
    });
  }

  // Future<void> distanceCalculation(context) async {
  //   double calculateDistance(lat1, lon1, lat2, lon2) {
  //     var p = 0.017453292519943295;
  //     var c = cos;
  //     var a = 0.5 -
  //         c((lat2 - lat1) * p) / 2 +
  //         c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  //     return 12742 * asin(sqrt(a));
  //   }
  //
  //   var lat1 = 11.140537;
  //   var long1 = 76.941116;
  //   var lat2 = _location?.latitude;
  //   var long2 = _location?.longitude;
  //   double totalDistance = 0;
  //   totalDistance += calculateDistance(lat1, long1, lat2, long2);
  //   print(totalDistance);
  //   if (totalDistance <= 5) {
  //     visibility = false;
  //   } else {
  //     visibility = true;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.green,
        borderRadius: const BorderRadius.all(
          Radius.circular(50.0),
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(xAlign, 0),
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: width * 0.28,
              height: height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(50.0),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (visibility == true) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String DeviceStatus =
                    prefs.getString('deviceStatus').toString();
                setState(() {
                  if (DeviceStatus == "true") {
                    xAlign = loginAlign;
                    loginColor = Colors.black;
                    signInColor = Colors.black;
                    callONRPCCall(context);
                  } else {
                    Fluttertoast.showToast(
                        msg: "Device in Offline Mode",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1);
                  }
                });
              } else {
                _show(context, true);
              }
            },
            child: Align(
              alignment: const Alignment(-1, 0),
              child: Container(
                width: width * 0.35,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    'ON',
                    style: TextStyle(
                      color: loginColor,
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (visibility == true) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String DeviceStatus =
                    prefs.getString('deviceStatus').toString();
                setState(() {
                  if (DeviceStatus == "true") {
                    xAlign = signInAlign;
                    signInColor = Colors.black;
                    loginColor = Colors.black;
                    callOFFRPCCall(context);
                  } else {
                    Fluttertoast.showToast(
                        msg: "Device in Offline Mode",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1);
                  }
                });
              } else {
                _show(context, true);
              }
            },
            child: Align(
              alignment: const Alignment(1, 0),
              child: Container(
                width: width * 0.35,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    'OFF',
                    style: TextStyle(
                      color: signInColor,
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> _getAddress(double? lat, double? lang) async {
  if (lat == null || lang == null) return "";
  final coordinates = Coordinates(lat, lang);
  List<Address> addresss = (await Geocoder.local
      .findAddressesFromCoordinates(coordinates)) as List<Address>;
  return "${addresss.elementAt(1).addressLine}";
}

void _show(context, visibility) {
  showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Visibility(
          visible: visibility,
          child: AlertDialog(
            elevation: 10,
            title: const Text('Luminator Location Alert'),
            content: const Text('Your are not in the Nearest Range to Controll or Access the Device'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'))
            ],
          ),
        );
      });
}
