import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poly_geofence_service/models/poly_geofence.dart';
import 'package:poly_geofence_service/poly_geofence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ILMToggleButtonn extends StatefulWidget {
  const ILMToggleButtonn({Key? key}) : super(key: key);

  @override
  _ILMToggleButtonnState createState() => _ILMToggleButtonnState();
}

const double width = 300.0;
const double height = 90.0;
const double loginAlign = -1;
const double signInAlign = 1;
const Color selectedColor = Colors.black54;
const Color normalColor = Colors.black54;
bool visibility = true;

class _ILMToggleButtonnState extends State<ILMToggleButtonn> {
  late double xAlign;
  late Color loginColor;
  late Color signInColor;
  // final Location locations = Location();
  // LocationData? _location;
  // StreamSubscription<LocationData>? _locationSubscription;
  String? _error;
  String address = "";
  List<double>? _latt = [];
  double lattitude = 0;
  double longitude = 0;
  String Lattitude = "0";
  String Longitude = "0";
  // LocationData? currentLocation;
  double accuracy = 0;
  late bool visibility = false;
  String geoFence = "false";

  final _streamController = StreamController<PolyGeofence>();

  final _polyGeofenceService = PolyGeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      allowMockLocations: false,
      printDevLog: false);

  // Create a [PolyGeofence] list.
  final _polyGeofenceList = <PolyGeofence>[
    PolyGeofence(
      id: 'Office_Address',
      data: {
        'address': 'Coimbatore',
        'about': 'Schnell Energy Equipments,Coimbatore.',
      },
      polygon: <LatLng>[
        const LatLng(11.140339923116493, 76.94095999002457),
      ],
    ),
  ];

  // This function is to be called when the geofence status is changed.
  Future<void> _onPolyGeofenceStatusChanged(PolyGeofence polyGeofence,
      PolyGeofenceStatus polyGeofenceStatus, Location location) async {
    print('polyGeofence: ${polyGeofence.toJson()}');
    print('polyGeofenceStatus: ${polyGeofenceStatus.toString()}');
    _streamController.sink.add(polyGeofence);
  }

  // Future<String> getJson() {
  //   return rootBundle.loadString('geofence.json');
  // }

  // This function is to be called when the location has changed.
  Future<void> _onLocationChanged(Location location) async {
    print('location: ${location.toJson()}');
    accuracy = location.accuracy;

    if (accuracy <= 7) {
      if (geoFence == "true") {
        for (int i = 0; i < _polyGeofenceList[0].polygon.length; i++) {
          var insideArea = _checkIfValidMarker(
              LatLng(location.latitude, location.longitude),
              _polyGeofenceList[0].polygon);
          print('location check: ${insideArea}');
          if (insideArea == true) {
            Geolocator geolocator = new Geolocator();
            var difference = await geolocator.distanceBetween(
                double.parse(Lattitude),
                double.parse(Longitude),
                location.latitude,
                location.longitude);

            if (difference <= 5.0) {
              setState(() {
                visibility = true;
              });
              callPolygonStop();
            } else {
              setState(() {
                visibility = false;
              });
            }
          } else {
            setState(() {
              visibility = false;
            });
            // if (i == 0) {
            //   Fluttertoast.showToast(
            //       msg:
            //           "GeoFence Location Alert Your are not in the selected Ward, Please reselect the Current Ward , Status: " +
            //               insideArea.toString(),
            //       toastLength: Toast.LENGTH_SHORT,
            //       gravity: ToastGravity.BOTTOM,
            //       timeInSecForIosWeb: 1,
            //       backgroundColor: Colors.white,
            //       textColor: Colors.black,
            //       fontSize: 16.0);
            // }
          }
        }
      } else {
        setState(() {
          visibility = true;
        });
        callPolygonStop();
      }
    } else {
      setState(() {
        visibility = false;
      });

      Fluttertoast.showToast(
          msg: "Fetching Device Location Accuracy Please wait for Some time" +
              "Acccuracy Level-->" +
              accuracy.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  void callPolygonStop() {
    _polyGeofenceService
        .removePolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
    _polyGeofenceService.removeLocationChangeListener(_onLocationChanged);
    _polyGeofenceService.removeLocationServicesStatusChangeListener(
        _onLocationServicesStatusChanged);
    _polyGeofenceService.removeStreamErrorListener(_onError);
    _polyGeofenceService.clearAllListeners();
    _polyGeofenceService.stop();
  }

  Future<void> CallCoordinates(context) async {
    try {
      _polyGeofenceList[0].polygon.clear();
      String data = await DefaultAssetBundle.of(context)
          .loadString("assets/json/geofence.json");
      final jsonResult = jsonDecode(data); //latest Dart
      var coordinateCount =
          jsonResult['features'][0]['geometry']['coordinates'][0].length;
      var details;
      for (int i = 0; i < coordinateCount; i++) {
        var latter =
        jsonResult['features'][0]['geometry']['coordinates'][0][i][1];
        var rlonger =
        jsonResult['features'][0]['geometry']['coordinates'][0][i][0];
        // polygonad(LatLng(latter,rlonger));
        _polyGeofenceList[0].polygon.add(LatLng(latter, rlonger));
        // details[new LatLng(latter,rlonger)];
      }
    } catch (e) {}
  }

  Future<void> CallGeoFenceListener(BuildContext context) async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var geoFence = prefs.getString('geoFence').toString();
        if (geoFence == "true") {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _polyGeofenceService.start();
            _polyGeofenceService.addPolyGeofenceStatusChangeListener(
                _onPolyGeofenceStatusChanged);
            _polyGeofenceService.addLocationChangeListener(_onLocationChanged);
            _polyGeofenceService.addLocationServicesStatusChangeListener(
                _onLocationServicesStatusChanged);
            _polyGeofenceService.addStreamErrorListener(_onError);
            _polyGeofenceService.start(_polyGeofenceList).catchError(_onError);
          });
          CallCoordinates(context);
          setState(() {
            visibility = true;
          });
        } else {
          visibility = true;
          Fluttertoast.showToast(
              msg: "GeoFence Availability is not found with this Ward",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
        }
      } catch (e) {}
    } else {
      Fluttertoast.showToast(
          msg: "Kindly Enable App Location Permission",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
      // openAppSettings();
    }
  }

  Future<void> callPolygons() async {}

  // This function is to be called when a location services status change occurs
  // since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }
    print('ErrorCode: $errorCode');
  }

  bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }
    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }
    return true;
  }


  @override
  void initState() {
    super.initState();
    xAlign = loginAlign;
    loginColor = selectedColor;
    signInColor = normalColor;
    CallGeoFenceListener(context);
    getPrefs();
    // _listenLocation();
  }

  Future<void> getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Lattitude = prefs.getString('deviceLatitude').toString();
    Longitude = prefs.getString('deviceLongitude').toString();
    geoFence = prefs.getString('geoFence').toString();
    setState(() {
      Lattitude = Lattitude;
      Longitude = Longitude;
      geoFence = geoFence;
    });
  }

  // Future<void> _listenLocation() async {
  //   _locationSubscription =
  //       locations.onLocationChanged.handleError((dynamic err) {
  //     if (err is PlatformException) {
  //       setState(() {
  //         _error = err.code;
  //       });
  //     }
  //     _locationSubscription?.cancel();
  //     setState(() {
  //       _locationSubscription = null;
  //     });
  //   }).listen((LocationData currentLocation) {
  //     setState(() {
  //       _error = null;
  //       _location = currentLocation;
  //       _getAddress(_location!.latitude, _location!.longitude).then((value) {
  //         setState(() async {
  //           address = value;
  //           if (_latt!.length <= 5) {
  //             _latt!.add(_location!.latitude!);
  //             lattitude = _location!.latitude!;
  //             longitude = _location!.longitude!;
  //             accuracy = _location!.accuracy!;
  //             // addresss = addresss;
  //           } else {
  //             _locationSubscription?.cancel();
  //             var accuvalue = accuracy.toString().split(".");
  //             var addvalue = value.toString().split(",");
  //
  //             // if (accuracy <= 7) {
  //             //   _locationSubscription?.cancel();
  //             //   setState(() {
  //             // _locationSubscription = null;
  //             // });
  //             accuvalue = accuracy.toString().split(".");
  //             // distanceCalculation(context);
  //
  //             Geolocator geolocator = new Geolocator();
  //             var difference = await geolocator.distanceBetween(
  //                 double.parse(Lattitude),
  //                 double.parse(Longitude),
  //                 _location!.latitude!,
  //                 _location!.longitude!);
  //             if (difference <= 5.0) {
  //               visibility = true;
  //             } else {
  //               visibility = false;
  //             }
  //             // }
  //           }
  //         });
  //       });
  //     });
  //   });
  // }

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
                    //callONRPCCall(context);
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
                    //callOFFRPCCall(context);
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
