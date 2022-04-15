import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/device_count_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/device_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/remove_ilm_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/replace_ilm_screen.dart';
import 'package:flutterlumin/src/ui/point/point.dart';
import 'package:flutterlumin/src/ui/qr_scanner/qr_scanner.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poly_geofence_service/models/lat_lng.dart';
import 'package:poly_geofence_service/models/poly_geofence.dart';
import 'package:poly_geofence_service/poly_geofence_service.dart';

// import 'package:location/location.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localdb/db_helper.dart';
import '../../../localdb/model/region_model.dart';
import '../../../utils/ilmtoogle_button.dart';
import '../../splash_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen() : super();

  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with WidgetsBindingObserver {
  var selectedImage = "";
  bool _isOn = true;
  DateTime? date;
  int _selectedIndex = 0;
  bool clickedCentreFAB = false;
  var LampactiveStatus;
  String Lampwatts = "0";
  String DeviceName = "0";
  String DeviceIdDetails = "";
  String DeviceStatus = "0";
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";
  String faultyStatus = "0";
  String geoFence = "false";
  String timevalue = "0";
  String location = "0";
  String version = "0";
  String Lattitude = "0";
  String Longitude = "0";
  String FirmwareVersion = "0";
  late ProgressDialog pr;
  late ProgressDialog pr1;
  late bool visibility = false;
  late bool viewvisibility = true;

  // LocationData? currentLocation;
  String? _error;
  double lattitude = 0;
  double longitude = 0;
  double accuracy = 0;
  double difference = 0;
  String address = "";
  var accuvalue;
  var counter = 0;
  var addvalue;
  List<double>? _latt = [];
  final _streamController = StreamController<PolyGeofence>();
  var caclsss = 0;
  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();
  var serverUrl = FlavorConfig.instance.variables["baseUrl"];
  late Timer _timer;
  int _start = 5;

  // final Location locations = Location();
  // LocationData? _location;
  // StreamSubscription<LocationData>? _locationSubscription;

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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('deviceLatitude', location.latitude.toString());
    prefs.setString('deviceLongitude', location.longitude.toString());

    if (caclsss == 0) {
      startTimer();
    }
    caclsss++;

    if (geoFence == "true") {
      for (int i = 0; i < _polyGeofenceList[0].polygon.length; i++) {
        var insideArea = _checkIfValidMarker(
            LatLng(location.latitude, location.longitude),
            _polyGeofenceList[0].polygon);
        if (insideArea == true) {
          if (accuracy <= 10) {
            Geolocator geolocator = new Geolocator();
            difference = (await geolocator.distanceBetween(
                double.parse(Lattitude),
                double.parse(Longitude),
                location.latitude,
                location.longitude));
            difference = difference;
            if (difference <= 50.0) {
              setState(() {
                visibility = true;
                viewvisibility = false;
                difference = difference;
              });
              callPolygonStop();
            } else {
              callPolygonStop();
              // _controll_dialog_show(context, difference, true);
              // setState(() {
              //   visibility = false;
              //   viewvisibility = false;
              // });
            }
          } else {
            setState(() {
              visibility = false;
              viewvisibility = true;
            });

          }
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => dashboard_screen()));
          setState(() {
            visibility = false;
          });
          if (counter == 0 || counter == 3 || counter == 6 || counter == 9) {
            // Fluttertoast.showToast(
            //     msg:
            //         "GeoFence Location Alert Your are not in the selected Ward, Please reselect the Current Ward , Status: " +
            //             insideArea.toString(),
            //     toastLength: Toast.LENGTH_SHORT,
            //     gravity: ToastGravity.BOTTOM,
            //     timeInSecForIosWeb: 1,
            //     backgroundColor: Colors.white,
            //     textColor: Colors.black,
            //     fontSize: 16.0);
            counter++;
          }
          callPolygonStop();
        }
      }
    } else {
      if (accuracy <= 10) {
        Geolocator geolocator = new Geolocator();
        difference = (await geolocator.distanceBetween(double.parse(Lattitude),
            double.parse(Longitude), location.latitude, location.longitude));
        difference = difference;

        if (difference <= 50.0) {
          _timer.cancel();
          callPolygonStop();
          setState(() {
            visibility = true;
            viewvisibility = false;
          });
        } else {
          setState(() {
            visibility = true;
            viewvisibility = false;
          });

          // _controll_dialog_show(context, difference, true);

          // Fluttertoast.showToast(
          //     msg:
          //         "Your Distance with device Location is More, Your not in the adequate Range",
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Colors.white,
          //     textColor: Colors.black,
          //     fontSize: 16.0);
          //
          // setState(() {
          //   visibility = false;
          //   viewvisibility = false;
          // });
        }
      } else {
        // _timer.cancel();
        // callPolygonStop();
        // setState(() {
        //   visibility = false;
        //   viewvisibility = true;
        // });

        // Fluttertoast.showToast(
        //     msg: "Fetching Device Location Accuracy Please wait for Some time" +
        //         "Acccuracy Level-->" +
        //         accuracy.toString(),
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 1,
        //     backgroundColor: Colors.white,
        //     textColor: Colors.black,
        //     fontSize: 16.0);
      }
    }

    if (caclsss == 20) {
      _timer.cancel();
      callPolygonStop();
      Geolocator geolocator = new Geolocator();
      var difference = await geolocator.distanceBetween(double.parse(Lattitude),
          double.parse(Longitude), location.latitude, location.longitude);
      if (difference <= 50.0) {
        setState(() {
          visibility = true;
          viewvisibility = false;
        });
      } else {
        setState(() {
          visibility = false;
          viewvisibility = false;
        });
      }
    }
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          timer.cancel();
          callPolygonStop();
          if (accuracy <= 10) {
            if (difference <= 50) {
              setState(() {
                visibility = true;
                viewvisibility = false;
              });
            } else {
              setState(() {
                visibility = true;
                viewvisibility = false;
              });
              // _controll_dialog_show(context, difference, true);
            }
          } else {
            // timer.cancel();
            // callPolygonStop();
            setState(() {
              visibility = true;
              viewvisibility = false;
            });
            if (difference <= 50) {
              setState(() {
                visibility = true;
                viewvisibility = false;
              });
            } else {
              setState(() {
                visibility = true;
                viewvisibility = false;
              });
              // _controll_dialog_show(context, difference, true);
            }
          }
        }else{
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> callPolygonStop() async {
    _polyGeofenceService
        .removePolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
    _polyGeofenceService.removeLocationChangeListener(_onLocationChanged);
    _polyGeofenceService.removeLocationServicesStatusChangeListener(
        _onLocationServicesStatusChanged);
    _polyGeofenceService.removeStreamErrorListener(_onError);
    _polyGeofenceService.clearAllListeners();
    _polyGeofenceService.stop();
    pr1.hide();
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

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Lampwatts = prefs.getString('deviceWatts').toString();
    DeviceName = prefs.getString('deviceName').toString();
    DeviceIdDetails = prefs.getString('DeviceDetails').toString();
    DeviceStatus = prefs.getString('deviceStatus').toString();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();
    timevalue = prefs.getString("devicetimeStamp").toString();
    location = prefs.getString("location").toString();
    version = prefs.getString("version").toString();
    faultyStatus = prefs.getString("faultyStatus").toString();
    geoFence = prefs.getString('geoFence').toString();
    FirmwareVersion = prefs.getString('firmwareVersion').toString();

    Lattitude = prefs.getString('deviceLatitude').toString();
    Longitude = prefs.getString('deviceLongitude').toString();

    prefs.setString('Maintenance', "Yes");

    setState(() {
      Lampwatts = Lampwatts;
      DeviceName = DeviceName;
      DeviceStatus = DeviceStatus;
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;
      timevalue = timevalue;
      location = location;
      version = version;
      faultyStatus = faultyStatus;
      Lattitude = Lattitude;
      Longitude = Longitude;
      FirmwareVersion = FirmwareVersion;
      geoFence = geoFence;
      DeviceIdDetails = DeviceIdDetails;

      date = DateTime.fromMillisecondsSinceEpoch(int.parse(timevalue));

      if (SelectedRegion == "null") {
        SelectedRegion = "Region";
        SelectedZone = "Zone";
        SelectedWard = "Ward";
        faultyStatus = "0";
      }

      if (SelectedZone == "0" || SelectedZone == "null") {
        SelectedZone = "Zone";
      }

      if (SelectedWard == "0" || SelectedWard == "null") {
        SelectedWard = "Ward";
      }

      if (location == "0") {
        location = location;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Lampwatts = "";
    DeviceName = "";
    DeviceStatus = "";
    getSharedPrefs();
    CallGeoFenceListener(context);
    // calllocationFinder();


    // visibility = true;
    // _listenLocation();
  }

  void setUpLogs() async {
    await FlutterLogs.initLogs(
        logLevelsEnabled: [
          LogLevel.INFO,
          LogLevel.WARNING,
          LogLevel.ERROR,
          LogLevel.SEVERE
        ],
        timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
        directoryStructure: DirectoryStructure.FOR_DATE,
        logTypesEnabled: [_myLogFileName],
        logFileExtension: LogFileExtension.LOG,
        logsWriteDirectoryName: "MyLogs",
        logsExportDirectoryName: "MyLogs/Exported",
        debugFileOperations: true,
        isDebuggable: true);

    // [IMPORTANT] The first log line must never be called before 'FlutterLogs.initLogs'
    // FlutterLogs.logInfo(_tag, "setUpLogs", "setUpLogs: Setting up logs..");

    // Logs Exported Callback
    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == 'logsExported') {
        // Contains file name of zip
        // FlutterLogs.logInfo(
        //     _tag, "setUpLogs", "logsExported: ${call.arguments.toString()}");

        setLogsStatus(
            status: "logsExported: ${call.arguments.toString()}", append: true);

        // Notify Future with value
        _completer.complete(call.arguments.toString());
      } else if (call.method == 'logsPrinted') {
        // FlutterLogs.logInfo(
        //     _tag, "setUpLogs", "logsPrinted: ${call.arguments.toString()}");

        setLogsStatus(
            status: "logsPrinted: ${call.arguments.toString()}", append: true);
      }
    });
  }

  // void calllocationFinder() async {
  //   var status = await Permission.location.status;
  //   if (status.isGranted) {
  //     CallGeoFenceListener(context);
  //     setUpLogs();
  //   } else {
  //     Permission.locationAlways.request();
  //   }
  // }

  void setLogsStatus({String status = '', bool append = false}) {
    setState(() {
      logStatus = status;
    });
  }

  Future<void> CallGeoFenceListener(BuildContext context) async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      try {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        var geoFence = prefs.getString('geoFence').toString();
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _polyGeofenceService.start();
          _polyGeofenceService.addPolyGeofenceStatusChangeListener(
              _onPolyGeofenceStatusChanged);
          _polyGeofenceService.addLocationChangeListener(_onLocationChanged);
          _polyGeofenceService.addLocationServicesStatusChangeListener(
              _onLocationServicesStatusChanged);
          _polyGeofenceService.addStreamErrorListener(_onError);
          _polyGeofenceService.start(_polyGeofenceList).catchError(_onError);
          pr1.show();
        });
        if (geoFence == "true") {
          CallCoordinates(context);
          setState(() {
            visibility = true;
          });
        } else {

          visibility = true;
          viewvisibility = false;
          // Fluttertoast.showToast(
          //     msg: "GeoFence Availability is not found with this Ward",
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Colors.white,
          //     textColor: Colors.black,
          //     fontSize: 16.0);
        }
      } catch (e) {}
    } else {
      // Fluttertoast.showToast(
      //     msg: "Kindly Enable App Location Permission",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.white,
      //     textColor: Colors.black,
      //     fontSize: 16.0);
      Permission.locationAlways.request();
      // openAppSettings();
    }
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

  // Future<void> _listenLocation() async {
  //   // pr.show();
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
  //     setState(() async {
  //       _error = null;
  //       _location = currentLocation;
  //       _latt!.add(_location!.latitude!);
  //       lattitude = _location!.latitude!;
  //       longitude = _location!.longitude!;
  //       accuracy = _location!.accuracy!;
  //
  //       // if (accuracy <= 7) {
  //       //   _locationSubscription?.cancel();
  //         setState(() {
  //           viewvisibility = false;
  //           // _locationSubscription = null;
  //         });
  //         accuvalue = accuracy.toString().split(".");
  //         // distanceCalculation(context);
  //
  //         Geolocator geolocator = new Geolocator();
  //         var difference = await geolocator.distanceBetween(
  //             double.parse(Lattitude),
  //             double.parse(Longitude),
  //             _location!.latitude!,
  //             _location!.longitude!);
  //         if (difference <= 5.0) {
  //           visibility = true;
  //         } else {
  //           visibility = false;
  //         }
  //       // }
  //     });
  //   });
  // }

  void toggle() {
    setState(() => _isOn = !_isOn);
  }

  BuildContext get context => super.context;

  final List<Widget> _widgetOptions = <Widget>[
    device_count_screen(),
    device_list_screen()
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;

    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
      message: 'Please wait ..',
      borderRadius: 20.0,
      backgroundColor: Colors.lightBlueAccent,
      elevation: 10.0,
      messageTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: "Montserrat",
          fontSize: 19.0,
          fontWeight: FontWeight.w600),
      progressWidget: const CircularProgressIndicator(
          backgroundColor: Colors.lightBlueAccent,
          valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
          strokeWidth: 3.0),
    );

    pr1 = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr1.style(
      message: 'Fetching Location',
      borderRadius: 20.0,
      backgroundColor: Colors.lightBlueAccent,
      elevation: 10.0,
      messageTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: "Montserrat",
          fontSize: 19.0,
          fontWeight: FontWeight.w600),
      progressWidget: const CircularProgressIndicator(
          backgroundColor: Colors.lightBlueAccent,
          valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
          strokeWidth: 3.0),
    );

    return WillPopScope(
      onWillPop: () async {
        callPolygonStop();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => dashboard_screen()));
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Stack(
          children: [
            _widgetOptions.elementAt(_selectedIndex),
            Align(
              alignment: FractionalOffset.bottomRight,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                //if clickedCentreFAB == true, the first parameter is used. If it's false, the second.
                height: clickedCentreFAB
                    ? MediaQuery.of(context).size.height
                    : 10.0,
                width: clickedCentreFAB
                    ? MediaQuery.of(context).size.height
                    : 10.0,
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(clickedCentreFAB ? 0.0 : 300.0),
                    color: Colors.white),
              ),
            ),
            Container(
              color: thbDblue,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                        color: thbDblue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                            bottomLeft: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0))),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: Text('ILM Maintanance',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 20.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Positioned(
                          right: 10,
                          top: 20,
                          bottom: 0,
                          child: IconButton(
                            color: Colors.red,
                            icon: Icon(
                              Icons.logout_outlined,
                              size: 35,
                            ),
                            onPressed: () {
                              callLogoutoption(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(35.0),
                                topRight: Radius.circular(35.0),
                                bottomLeft: Radius.circular(0.0),
                                bottomRight: Radius.circular(0.0))),
                        child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: ListView(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                children: <Widget>[
                                  SizedBox(height: 5),
                                  Wrap(
                                      spacing: 8.0,
                                      // gap between adjacent chips
                                      runSpacing: 4.0,
                                      // gap between lines
                                      direction: Axis.horizontal,
                                      // main axis (rows or columns)
                                      children: <Widget>[
                                        Container(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                              child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Padding(
                                                        padding:
                                                        EdgeInsets.only(left: 5.0),
                                                        child: Point(
                                                          triangleHeight: 25.0,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(context).push(
                                                                  MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                      context) =>
                                                                          ward_li_screen()));
                                                              setState(() {});
                                                            },
                                                            child: Container(
                                                              color: thbDblue,
                                                              height: 40.0,
                                                              child: Center(
                                                                child: Text(
                                                                    ' $SelectedRegion  ',
                                                                    style: const TextStyle(
                                                                        fontSize: 16.0,
                                                                        fontFamily:
                                                                        "Montserrat",
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Padding(
                                                        padding:
                                                        EdgeInsets.only(left: 5.0),
                                                        child: Point(
                                                          triangleHeight: 25.0,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(context).push(
                                                                  MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                      context) =>
                                                                          zone_li_screen()));
                                                              setState(() {});
                                                            },
                                                            child: Container(
                                                              color: thbDblue,
                                                              height: 40.0,
                                                              child: Center(
                                                                child: Text(
                                                                    '  $SelectedZone  ',
                                                                    style: const TextStyle(
                                                                        fontSize: 16.0,
                                                                        fontFamily:
                                                                        "Montserrat",
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Padding(
                                                        padding:
                                                        EdgeInsets.only(left: 5.0),
                                                        child: Point(
                                                          triangleHeight: 25.0,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(context).push(
                                                                  MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                      context) =>
                                                                          ward_li_screen()));
                                                              setState(() {});
                                                            },
                                                            child: Container(
                                                              color: thbDblue,
                                                              height: 40.0,
                                                              child: Center(
                                                                child: Text(
                                                                    '  $SelectedWard  ',
                                                                    style: const TextStyle(
                                                                        fontSize: 16.0,
                                                                        fontFamily:
                                                                        "Montserrat",
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                            )),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Wrap(
                                            spacing: 8.0,
                                            // gap between adjacent chips
                                            runSpacing: 4.0,
                                            // gap between lines
                                            direction: Axis.horizontal,
                                            // main axis (rows or columns)
                                            children: <Widget>[
                                              Container(
                                                padding: const EdgeInsets.fromLTRB(
                                                    5, 10, 2, 0),
                                                decoration: const BoxDecoration(
                                                    color: thbDblue,
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(35.0))),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: <Widget>[
                                                        Container(
                                                          padding: const EdgeInsets
                                                              .fromLTRB(5, 0, 0, 0),
                                                          width: width / 3,
                                                          height: 45,
                                                          alignment:
                                                          Alignment.centerLeft,
                                                          decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      15.0))),
                                                          child: Center(
                                                            child: Text(
                                                              '$DeviceName',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .deepOrange,
                                                                  fontSize: 26,
                                                                  fontFamily:
                                                                  "Montserrat",
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ),
                                                          ),
                                                        ), //Container
                                                        SizedBox(
                                                          width: 15,
                                                        ), //SizedBox
                                                        Container(
                                                            width: width / 2.05,
                                                            height: 25,
                                                            child: Text(
                                                              "$location",
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                  "Montserrat",
                                                                  color:
                                                                  Colors.white,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ) //BoxDecoration
                                                        ) //Container
                                                      ], //<Widget>[]
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Container(
                                                            width: width / 3,
                                                            height: 25,
                                                            child: Text(
                                                              "Lamp watts",
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                  "Montserrat",
                                                                  color:
                                                                  Colors.white),
                                                            )), //Container
                                                        SizedBox(
                                                          width: 5,
                                                        ), //SizedBox
                                                        Container(
                                                            width: width / 2.05,
                                                            height: 25,
                                                            child: Text(
                                                              "$Lampwatts",
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  color:
                                                                  Colors.white,
                                                                  fontFamily:
                                                                  "Montserrat",
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ) //BoxDecoration
                                                        ) //Container
                                                      ], //<Widget>[]
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Container(
                                                            width: width / 3,
                                                            height: 25,
                                                            child: Text(
                                                              "Last Comm @ ",
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  color:
                                                                  Colors.white,
                                                                  fontFamily:
                                                                  "Montserrat"),
                                                            )), //Container
                                                        SizedBox(
                                                          width: 5,
                                                        ), //SizedBox
                                                        Container(
                                                            width: width / 2.05,
                                                            height: 25,
                                                            child: Text(
                                                              "$date",
                                                              style: const TextStyle(
                                                                  fontSize: 18,
                                                                  color:
                                                                  Colors.white,
                                                                  fontFamily:
                                                                  "Montserrat",
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                            ) //BoxDecoration
                                                        ) //Container
                                                      ], //<Widget>[]
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    // Column(
                                                    //   children: [
                                                    //     Container(
                                                    //       alignment: Alignment.topLeft,
                                                    //       padding: const EdgeInsets.fromLTRB(8, 10, 0, 0),
                                                    //       height: 40,
                                                    //       child: Text(
                                                    //         'Last Comm @',
                                                    //         style: TextStyle(
                                                    //             fontSize: 18, fontFamily: "Montserrat"),
                                                    //       ),
                                                    //     ),
                                                    //     Container(
                                                    //       padding: const EdgeInsets.all(8),
                                                    //       height: 40,
                                                    //       child: Text(
                                                    //         '$date',
                                                    //         style: TextStyle(
                                                    //             fontSize: 16,
                                                    //             fontWeight: FontWeight.bold,
                                                    //             fontFamily: "Montserrat"),
                                                    //       ),
                                                    //     ),
                                                    //     // Expanded(
                                                    //     //   child: Container(
                                                    //     //     alignment: Alignment.centerRight,
                                                    //     //     padding: EdgeInsets.all(6),
                                                    //     //     child: IconButton(
                                                    //     //       icon: const Icon(
                                                    //     //         Icons.arrow_drop_down,
                                                    //     //       ),
                                                    //     //       iconSize: 50,
                                                    //     //       color: Colors.black,
                                                    //     //       splashColor: Colors.purple,
                                                    //     //       onPressed: () {
                                                    //     //         // showDialog(context, date);
                                                    //     //       },
                                                    //     //     ),
                                                    //     //   ),
                                                    //     // ),
                                                    //   ],
                                                    // ),
                                                  ],
                                                ),
                                              )
                                            ]),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                          children: [
                                            const Expanded(
                                                flex: 2, child: ILMToggleButtonn()),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Expanded(
                                                flex: 2,
                                                child: InkWell(
                                                  child: Container(
                                                    height: 90,
                                                    decoration: const BoxDecoration(
                                                        color: Colors.orange,
                                                        borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                50.0))),
                                                    child: const Center(
                                                      child: Text('GET LIVE',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: Colors.white,
                                                              fontFamily:
                                                              "Montserrat")),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    if (visibility == true) {
                                                      if ('$DeviceStatus' !=
                                                          "false") {
                                                        getLiveRPCCall(
                                                            version, context);
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                            "Device in Offline Mode",
                                                            toastLength:
                                                            Toast.LENGTH_SHORT,
                                                            gravity:
                                                            ToastGravity.BOTTOM,
                                                            timeInSecForIosWeb: 1);
                                                      }
                                                    } else {
                                                      _show(context, true);
                                                    }
                                                  },
                                                )),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          padding:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                          decoration: const BoxDecoration(
                                              color: Colors.black12,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(18.0))),
                                          child: Column(
                                            children: [
                                              const Text(
                                                "Replace With",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: thbDblue,
                                                  fontSize: 35,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: InkWell(
                                                        child: Container(
                                                          alignment:
                                                          Alignment.center,
                                                          height: 90,
                                                          decoration: const BoxDecoration(
                                                              color:
                                                              Colors.deepOrange,
                                                              borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      50.0))),
                                                          child: const Text(
                                                              'Shorting CAP',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color:
                                                                  Colors.white,
                                                                  fontFamily:
                                                                  "Montserrat")),
                                                        ),
                                                        onTap: () {
                                                          if (visibility == true) {
                                                            replaceShortingCap(
                                                                context);
                                                          } else {
                                                            _show(context, true);
                                                          }
                                                        },
                                                      )),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                      flex: 2,
                                                      child: InkWell(
                                                          child: Container(
                                                            alignment:
                                                            Alignment.center,
                                                            height: 90,
                                                            decoration: const BoxDecoration(
                                                                color: Colors.green,
                                                                borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        50.0))),
                                                            child: const Text('ILM',
                                                                textAlign: TextAlign
                                                                    .center,
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                    "Montserrat")),
                                                          ),
                                                          onTap: () {
                                                            if (visibility ==
                                                                true) {
                                                              replaceILM(context);
                                                            } else {
                                                              _show(context, true);
                                                            }
                                                          })),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                ])),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _controll_dialog_show(context, distance, dvisibility) {
    showDialog(
        barrierDismissible: false,
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return Visibility(
            child: AlertDialog(
              elevation: 10,
              title: Text(
                  'You are far from the ILM to be replaced by a distance ' +
                      distance.toString() +
                      'm (recommended - < 50m )',
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontFamily: "Montserrat")),
              content: const Text(''),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              dashboard_screen()));
                    },
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontFamily: "Montserrat"))),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Proceed with Replacement',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                            fontFamily: "Montserrat")))
              ],
            ),
          );
        });
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
              content: const Text(
                  'Your are not in the Nearest Range to Controll or Access the Device'),
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

// class ToggleButton extends StatefulWidget {
//   const ToggleButton({Key? key}) : super(key: key);
//
//   @override
//   _ToggleButtonState createState() => _ToggleButtonState();
// }

// const double width = 300.0;
// const double height = 90.0;
// const double loginAlign = -1;
// const double signInAlign = 1;
// const Color selectedColor = Colors.black54;
// const Color normalColor = Colors.black54;
//
// class _ToggleButtonState extends State<ToggleButton> {
//   late double xAlign;
//   late Color loginColor;
//   late Color signInColor;
//
//   @override
//   void initState() {
//     super.initState();
//     xAlign = loginAlign;
//     loginColor = selectedColor;
//     signInColor = normalColor;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         color: Colors.green,
//         borderRadius: const BorderRadius.all(
//           Radius.circular(50.0),
//         ),
//       ),
//       child: Stack(
//         children: [
//           AnimatedAlign(
//             alignment: Alignment(xAlign, 0),
//             duration: const Duration(milliseconds: 300),
//             child: Container(
//               width: width * 0.28,
//               height: height,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(50.0),
//                 ),
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () async {
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               String DeviceStatus = prefs.getString('deviceStatus').toString();
//               setState(() {
//                 if (DeviceStatus == "true") {
//                   xAlign = loginAlign;
//                   loginColor = Colors.black;
//                   signInColor = Colors.black;
//                   callONRPCCall(context);
//                 } else {
//                   Fluttertoast.showToast(
//                       msg: "Device in Offline Mode",
//                       toastLength: Toast.LENGTH_SHORT,
//                       gravity: ToastGravity.BOTTOM,
//                       timeInSecForIosWeb: 1);
//                 }
//               });
//             },
//             child: Align(
//               alignment: const Alignment(-1, 0),
//               child: Container(
//                 width: width * 0.35,
//                 color: Colors.transparent,
//                 alignment: Alignment.center,
//                 child: Center(
//                   child: Text(
//                     'ON',
//                     style: TextStyle(
//                       color: loginColor,
//                       fontSize: 18,
//                       fontFamily: "Montserrat",
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () async {
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               String DeviceStatus = prefs.getString('deviceStatus').toString();
//               setState(() {
//                 if (DeviceStatus == "true") {
//                   xAlign = signInAlign;
//                   signInColor = Colors.black;
//                   loginColor = Colors.black;
//                   callOFFRPCCall(context);
//                 } else {
//                   Fluttertoast.showToast(
//                       msg: "Device in Offline Mode",
//                       toastLength: Toast.LENGTH_SHORT,
//                       gravity: ToastGravity.BOTTOM,
//                       timeInSecForIosWeb: 1);
//                 }
//               });
//             },
//             child: Align(
//               alignment: const Alignment(1, 0),
//               child: Container(
//                 width: width * 0.35,
//                 color: Colors.transparent,
//                 alignment: Alignment.center,
//                 child: Center(
//                   child: Text(
//                     'OFF',
//                     style: TextStyle(
//                       color: signInColor,
//                       fontSize: 18,
//                       fontFamily: "Montserrat",
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
}

Future<void> callONRPCCall(context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(
        message: 'Please wait ..',
        borderRadius: 20.0,
        backgroundColor: Colors.lightBlueAccent,
        elevation: 10.0,
        messageTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: "Montserrat",
            fontSize: 19.0,
            fontWeight: FontWeight.w600),
        progressWidget: const CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
            valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
            strokeWidth: 3.0),
      );
      pr.show();
      // Utility.progressDialog(context);
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
        tbClient.smart_init();
        // type: String
        final jsonData = {
          "method": "ctrl",
          "params": {"lamp": 1, "mode": 2}
        };
        // final parsedJson = jsonDecode(jsonData);
        var DeviceIdDetails = prefs.getString('DeviceDetails').toString();
        var response = await tbClient
            .getDeviceService()
            .handleTwoWayDeviceRPCRequest(DeviceIdDetails!.toString(), jsonData)
            .timeout(Duration(minutes: 2));

        if (response["lamp"].toString() == "1") {
          Fluttertoast.showToast(
              msg: "Device ON Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
          pr.hide();
          // Navigator.pop(context);
        } else {
          pr.hide();
          // Navigator.pop(context);
          calltoast("Unable to Process, Please try again");
        }
      } catch (e) {
        FlutterLogs.logInfo("devicelist_page", "ilm_maintenance", "logMessage");
        pr.hide();
        // Navigator.pop(context);
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            callONRPCCall(context);
          }
        } else {
          calltoast("Unable to Process");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> callOFFRPCCall(context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(
        message: 'Please wait ..',
        borderRadius: 20.0,
        backgroundColor: Colors.lightBlueAccent,
        elevation: 10.0,
        messageTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: "Montserrat",
            fontSize: 19.0,
            fontWeight: FontWeight.w600),
        progressWidget: const CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
            valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
            strokeWidth: 3.0),
      );
      pr.show();
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
        tbClient.smart_init();
        // type: String
        final jsonData = {
          "method": "ctrl",
          "params": {"lamp": 0, "mode": 2}
        };
        // final parsedJson = jsonDecode(jsonData);
        var DeviceIdDetails = prefs.getString('DeviceDetails').toString();
        var response = await tbClient
            .getDeviceService()
            .handleTwoWayDeviceRPCRequest(DeviceIdDetails!.toString(), jsonData)
            .timeout(const Duration(minutes: 2));

        if (response["lamp"].toString() == "0") {
          pr.hide();
          Fluttertoast.showToast(
              msg: "Device Off Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
        } else {
          FlutterLogs.logInfo("devicelist_page", "ilm_maintenance",
              "Devie Connectivity Exception");
          pr.hide();
          calltoast("Unable to Process, Please try again");
        }
      } catch (e) {
        FlutterLogs.logInfo("devicelist_page", "ilm_maintenance",
            "ILM Device Maintenance Exception");
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            callOFFRPCCall(context);
          }
        } else {
          calltoast("Unable to Process");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> getLiveRPCCall(version, context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(
        message: 'Please wait ..',
        borderRadius: 20.0,
        backgroundColor: Colors.lightBlueAccent,
        elevation: 10.0,
        messageTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: "Montserrat",
            fontSize: 19.0,
            fontWeight: FontWeight.w600),
        progressWidget: const CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
            valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
            strokeWidth: 3.0),
      );
      pr.show();
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
        tbClient.smart_init();
        // type: String
        final jsonData;

        if (version == "0") {
          jsonData = {"method": "get", "params": 0};
        } else {
          jsonData = {
            "method": "get",
            "params": {"rpcType": 2, "value": 0}
          };
        }

        var DeviceIdDetails = prefs.getString('DeviceDetails').toString();
        // final parsedJson = jsonDecode(jsonData);
        var response = await tbClient
            .getDeviceService()
            .handleOneWayDeviceRPCRequest(DeviceIdDetails!.toString(), jsonData)
            .timeout(const Duration(minutes: 5));
        pr.hide();
        // if(response.) {
        //   calltoast("Device ON Sucessfully");
        //   Navigator.pop(context);
        // }else {
        //   calltoast("Unable to Process, Please try again");
        //   Navigator.pop(context);
        // }
      } catch (e) {
        FlutterLogs.logInfo("devicelist_page", "ilm_maintenance",
            "ILM Device Maintenance Exception");
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            getLiveRPCCall(version, context);
          }
        } else {
          calltoast("Unable to Process");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> replaceILM(context) async {
  // Navigator.pop(context);
  // Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(builder: (BuildContext context) => replaceilm()));

  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      try {
        pr = ProgressDialog(context,
            type: ProgressDialogType.Normal, isDismissible: false);
        pr.style(
          message: 'Please wait ..',
          borderRadius: 20.0,
          backgroundColor: Colors.lightBlueAccent,
          elevation: 10.0,
          messageTextStyle: const TextStyle(
              color: Colors.white,
              fontFamily: "Montserrat",
              fontSize: 19.0,
              fontWeight: FontWeight.w600),
          progressWidget: const CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
              valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
              strokeWidth: 3.0),
        );
        pr.show();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        // String OlddeviceID = prefs.getString('deviceId').toString();
        String OlddeviceName = prefs.getString('deviceName').toString();

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => QRScreen()),
                (route) => true).then((value) async {
          if (value != null) {
            if (OlddeviceName.toString() != value.toString()) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('newDevicename', value);

              pr.hide();
              // showActionAlertDialog(context,OlddeviceName,value);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => replaceilm()));
            } else {
              FlutterLogs.logInfo(
                  "ilm_maintenance", "ilm_maintenance", "Duplicate QR Code");
              pr.hide();
              calltoast("Duplicate QR Code");
            }
          } else {
            FlutterLogs.logInfo(
                "ilm_maintenance_page", "ilm_maintenance", "Invalid QR Code");
            pr.hide();
            calltoast("Invalid QR Code");
          }
        });
      } catch (e) {
        FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance",
            "ILM  Device Maintenance Exception");
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
        } else {
          calltoast("Device Replacement Issue");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

// @override
// Future<Device?> ilm_main_fetchDeviceDetails(
//     String OlddeviceName, String deviceName, BuildContext context) async {
//   Utility.isConnected().then((value) async {
//     if (value) {
//       late ProgressDialog pr;
//       pr = ProgressDialog(context,
//           type: ProgressDialogType.Normal, isDismissible: false);
//       pr.style(
//         message: 'Please wait ..',
//         borderRadius: 20.0,
//         backgroundColor: Colors.lightBlueAccent,
//         elevation: 10.0,
//         messageTextStyle: const TextStyle(
//             color: Colors.white,
//             fontFamily: "Montserrat",
//             fontSize: 19.0,
//             fontWeight: FontWeight.w600),
//         progressWidget: const CircularProgressIndicator(
//             backgroundColor: Colors.lightBlueAccent,
//             valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
//             strokeWidth: 3.0),
//       );
//       pr.show();
//       try {
//         Device response;
//         Future<List<EntityGroupInfo>> deviceResponse;
//         var tbClient = ThingsboardClient(serverUrl);
//         tbClient.smart_init();
//         response = await tbClient.getDeviceService().getTenantDevice(deviceName)
//             as Device;
//         if (response.name.isNotEmpty) {
//           if (response.type == ilm_deviceType) {
//             // ilm_main_fetchSmartDeviceDetails(
//             //     OlddeviceName, deviceName, response.id!.id.toString(), context);
//           } else if (response.type == ccms_deviceType) {
//           } else if (response.type == Gw_deviceType) {
//           } else {
//             FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//             pr.hide();
//             calltoast("Device Details Not Found");
//           }
//         } else {
//           FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//           pr.hide();
//           calltoast(deviceName);
//         }
//       } catch (e) {
//         FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//         pr.hide();
//         var message = toThingsboardError(e, context);
//         if (message == session_expired) {
//           var status = loginThingsboard.callThingsboardLogin(context);
//           if (status == true) {
//             ilm_main_fetchDeviceDetails(OlddeviceName, deviceName, context);
//           }
//         } else {
//           calltoast(deviceName);
//         }
//       }
//     } else {
//       FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//       calltoast(no_network);
//     }
//   });
// }

Future<void> replaceShortingCap(context) async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String deviceID = prefs.getString('deviceId').toString();
  // String deviceName = prefs.getString('deviceName').toString();
  //
  // var DevicecurrentFolderName = "";
  // var DevicemoveFolderName = "";
  //
  // Utility.isConnected().then((value) async {
  //   if (value) {
  //     Utility.progressDialog(context);
  //     try {
  //       var tbClient = ThingsboardClient(serverUrl);
  //       tbClient.smart_init();
  //
  //       Device response;
  //       response = (await tbClient
  //           .getDeviceService()
  //           .getTenantDevice(deviceName)) as Device;
  //
  //       if (response != null) {
  //         var relationDetails = await tbClient
  //             .getEntityRelationService()
  //             .findInfoByTo(response.id!);
  //
  //         List<EntityGroupInfo> entitygroups;
  //         entitygroups = await tbClient
  //             .getEntityGroupService()
  //             .getEntityGroupsByFolderType();
  //
  //         if (entitygroups != null) {
  //           for (int i = 0; i < entitygroups.length; i++) {
  //             if (entitygroups.elementAt(i).name == ILMserviceFolderName) {
  //               DevicemoveFolderName =
  //                   entitygroups.elementAt(i).id!.id!.toString();
  //             }
  //           }
  //
  //           List<EntityGroupId> currentdeviceresponse;
  //           currentdeviceresponse = await tbClient
  //               .getEntityGroupService()
  //               .getEntityGroupsForFolderEntity(response.id!.id!);
  //
  //           if (currentdeviceresponse != null) {
  //             if (currentdeviceresponse.last.id.toString().isNotEmpty) {
  //
  //               var firstdetails = await tbClient
  //                   .getEntityGroupService()
  //                   .getEntityGroup(currentdeviceresponse.first.id!);
  //               if (firstdetails!.name.toString() != "All") {
  //                 DevicecurrentFolderName = currentdeviceresponse.first.id!;
  //               }
  //               var seconddetails = await tbClient
  //                   .getEntityGroupService()
  //                   .getEntityGroup(currentdeviceresponse.last.id!);
  //               if (seconddetails!.name.toString() != "All") {
  //                 DevicecurrentFolderName = currentdeviceresponse.last.id!;
  //               }
  //
  //               var relation_response = await tbClient
  //                   .getEntityRelationService()
  //                   .deleteDeviceRelation(relationDetails.elementAt(0).from.id!,
  //                       response.id!.id!);
  //
  //               // DevicecurrentFolderName =
  //               //     currentdeviceresponse.last.id.toString();
  //
  //               List<String> myList = [];
  //               myList.add(response.id!.id!);
  //
  //               var remove_response = tbClient
  //                   .getEntityGroupService()
  //                   .removeEntitiesFromEntityGroup(
  //                       DevicecurrentFolderName, myList);
  //
  //               var add_response = tbClient
  //                   .getEntityGroupService()
  //                   .addEntitiesToEntityGroup(DevicemoveFolderName, myList);
  //
  // Navigator.pop(context);
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => replacementilm()));
  //             } else {
  //               calltoast("Device is not Found");
  //               Navigator.pop(context);
  //             }
  //           } else {
  //             calltoast("Device EntityGroup Not Found");
  //             Navigator.pop(context);
  //           }
  //         } else {
  //           calltoast(deviceName);
  //           Navigator.pop(context);
  //         }
  //       } else {
  //         calltoast(deviceName);
  //         Navigator.pop(context);
  //       }
  //     } catch (e) {
  //       var message = toThingsboardError(e, context);
  //       if (message == session_expired) {
  //         var status = loginThingsboard.callThingsboardLogin(context);
  //         if (status == true) {
  //           replaceILM(context);
  //         }
  //       } else {
  //         calltoast(deviceName);
  //         Navigator.pop(context);
  //       }
  //     }
  //   }
  // });
}

// @override
// Future<Device?> ilm_main_fetchSmartDeviceDetails(String Olddevicename,
//     String deviceName, String deviceid, BuildContext context) async {
//   var DevicecurrentFolderName = "";
//   var DevicemoveFolderName = "";
//
//   Utility.isConnected().then((value) async {
//     if (value) {
//       late ProgressDialog pr;
//       pr = ProgressDialog(context,
//           type: ProgressDialogType.Normal, isDismissible: false);
//       pr.style(
//         message: 'Please wait ..',
//         borderRadius: 20.0,
//         backgroundColor: Colors.lightBlueAccent,
//         elevation: 10.0,
//         messageTextStyle: const TextStyle(
//             color: Colors.white,
//             fontFamily: "Montserrat",
//             fontSize: 19.0,
//             fontWeight: FontWeight.w600),
//         progressWidget: const CircularProgressIndicator(
//             backgroundColor: Colors.lightBlueAccent,
//             valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
//             strokeWidth: 3.0),
//       );
//       pr.show();
//       try {
//         Device response;
//         Future<List<EntityGroupInfo>> deviceResponse;
//         var tbClient = ThingsboardClient(serverUrl);
//         tbClient.smart_init();
//
//         response = (await tbClient
//             .getDeviceService()
//             .getTenantDevice(deviceName)) as Device;
//
//         if (response != null) {
//           var new_Device_Name = response.name;
//
//           List<EntityGroupInfo> entitygroups;
//           entitygroups = await tbClient
//               .getEntityGroupService()
//               .getEntityGroupsByFolderType();
//
//           if (entitygroups != null) {
//             for (int i = 0; i < entitygroups.length; i++) {
//               if (entitygroups.elementAt(i).name == ILMserviceFolderName) {
//                 DevicemoveFolderName =
//                     entitygroups.elementAt(i).id!.id!.toString();
//               }
//             }
//
//             List<EntityGroupId> currentdeviceresponse;
//             currentdeviceresponse = await tbClient
//                 .getEntityGroupService()
//                 .getEntityGroupsForFolderEntity(response.id!.id!);
//
//             if (currentdeviceresponse != null) {
//               var firstdetails = await tbClient
//                   .getEntityGroupService()
//                   .getEntityGroup(currentdeviceresponse.first.id!);
//               if (firstdetails!.name.toString() != "All") {
//                 DevicecurrentFolderName = currentdeviceresponse.first.id!;
//               }
//               var seconddetails = await tbClient
//                   .getEntityGroupService()
//                   .getEntityGroup(currentdeviceresponse.last.id!);
//               if (seconddetails!.name.toString() != "All") {
//                 DevicecurrentFolderName = currentdeviceresponse.last.id!;
//               }
//
//               var relationDetails = await tbClient
//                   .getEntityRelationService()
//                   .findInfoByTo(response.id!);
//
//               if (relationDetails != null) {
//                 List<String> myList = [];
//                 myList.add("lampWatts");
//                 myList.add("active");
//
//                 List<BaseAttributeKvEntry> responser;
//
//                 responser = (await tbClient
//                         .getAttributeService()
//                         .getAttributeKvEntries(response.id!, myList))
//                     as List<BaseAttributeKvEntry>;
//
//                 if (responser != null) {
//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   prefs.setString(
//                       'deviceStatus', responser.first.kv.getValue().toString());
//                   prefs.setString(
//                       'deviceWatts', responser.last.kv.getValue().toString());
//
//                   prefs.setString('deviceId', deviceid);
//                   prefs.setString('deviceName', deviceName);
//
//                   DeviceCredentials? newdeviceCredentials;
//                   DeviceCredentials? olddeviceCredentials;
//
//                   if (relationDetails.length.toString() == "0") {
//                     newdeviceCredentials = await tbClient
//                         .getDeviceService()
//                         .getDeviceCredentialsByDeviceId(
//                             response.id!.id.toString()) as DeviceCredentials;
//
//                     if (newdeviceCredentials != null) {
//                       var newQRID =
//                           newdeviceCredentials.credentialsId.toString();
//
//                       newdeviceCredentials.credentialsId = newQRID + "L";
//                       var credresponse = await tbClient
//                           .getDeviceService()
//                           .saveDeviceCredentials(newdeviceCredentials);
//
//                       response.name = deviceName + "99";
//                       var devresponse = await tbClient
//                           .getDeviceService()
//                           .saveDevice(response);
//
//                       // Old Device Updations
//                       Device Olddevicedetails = null as Device;
//                       Olddevicedetails = await tbClient
//                           .getDeviceService()
//                           .getTenantDevice(Olddevicename) as Device;
//
//                       if (Olddevicedetails != null) {
//                         var Old_Device_Name = Olddevicedetails.name;
//
//                         olddeviceCredentials = await tbClient
//                                 .getDeviceService()
//                                 .getDeviceCredentialsByDeviceId(
//                                     Olddevicedetails.id!.id.toString())
//                             as DeviceCredentials;
//
//                         if (olddeviceCredentials != null) {
//                           var oldQRID =
//                               olddeviceCredentials.credentialsId.toString();
//
//                           olddeviceCredentials.credentialsId = oldQRID + "L";
//                           var old_cred_response = await tbClient
//                               .getDeviceService()
//                               .saveDeviceCredentials(olddeviceCredentials);
//
//                           Olddevicedetails.name = Olddevicename + "99";
//                           var old_dev_response = await tbClient
//                               .getDeviceService()
//                               .saveDevice(Olddevicedetails);
//
//                           olddeviceCredentials.credentialsId = newQRID;
//                           var oldcredresponse = await tbClient
//                               .getDeviceService()
//                               .saveDeviceCredentials(olddeviceCredentials);
//
//                           response.name = Old_Device_Name;
//                           response.label = Old_Device_Name;
//                           var olddevresponse = await tbClient
//                               .getDeviceService()
//                               .saveDevice(response);
//
//                           final old_body_req = {
//                             'boardNumber': Old_Device_Name,
//                             'ieeeAddress': oldQRID,
//                           };
//
//                           var up_attribute = (await tbClient
//                               .getAttributeService()
//                               .saveDeviceAttributes(response.id!.id!,
//                                   "SERVER_SCOPE", old_body_req));
//
//                           // New Device Updations
//
//                           Olddevicedetails.name = new_Device_Name;
//                           Olddevicedetails.label = new_Device_Name;
//                           var up_devresponse = await tbClient
//                               .getDeviceService()
//                               .saveDevice(Olddevicedetails);
//
//                           newdeviceCredentials.credentialsId = oldQRID;
//                           var up_credresponse = await tbClient
//                               .getDeviceService()
//                               .saveDeviceCredentials(newdeviceCredentials);
//
//                           final new_body_req = {
//                             'boardNumber': new_Device_Name,
//                             'ieeeAddress': newQRID,
//                           };
//
//                           var up_newdevice_attribute = (await tbClient
//                               .getAttributeService()
//                               .saveDeviceAttributes(Olddevicedetails.id!.id!,
//                                   "SERVER_SCOPE", new_body_req));
//
//                           List<String> myList = [];
//                           myList.add(response.id!.id!);
//
//                           var remove_response = tbClient
//                               .getEntityGroupService()
//                               .removeEntitiesFromEntityGroup(
//                                   DevicecurrentFolderName, myList);
//
//                           var add_response = tbClient
//                               .getEntityGroupService()
//                               .addEntitiesToEntityGroup(
//                                   DevicemoveFolderName, myList);
//
//                           pr.hide();
//                           callDashboard(context);
//                         }
//                       } else {
//                         FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//                         pr.hide();
//                         calltoast(deviceName);
//                       }
//                     }
//                   } else {
//                     // New Device Updations
//                     newdeviceCredentials = await tbClient
//                         .getDeviceService()
//                         .getDeviceCredentialsByDeviceId(
//                             response.id!.id.toString()) as DeviceCredentials;
//
//                     var relation_response = await tbClient
//                         .getEntityRelationService()
//                         .deleteDeviceRelation(
//                             relationDetails.elementAt(0).from.id!,
//                             response.id!.id!);
//
//                     if (newdeviceCredentials != null) {
//                       var newQRID =
//                           newdeviceCredentials.credentialsId.toString();
//
//                       newdeviceCredentials.credentialsId = newQRID + "L";
//                       var credresponse = await tbClient
//                           .getDeviceService()
//                           .saveDeviceCredentials(newdeviceCredentials);
//
//                       response.name = deviceName + "99";
//                       var devresponse = await tbClient
//                           .getDeviceService()
//                           .saveDevice(response);
//
//                       // Old Device Updations
//
//                       Device Olddevicedetails = null as Device;
//                       Olddevicedetails = await tbClient
//                           .getDeviceService()
//                           .getTenantDevice(Olddevicename) as Device;
//
//                       if (Olddevicedetails != null) {
//                         var Old_Device_Name = Olddevicedetails.name;
//
//                         olddeviceCredentials = await tbClient
//                                 .getDeviceService()
//                                 .getDeviceCredentialsByDeviceId(
//                                     Olddevicedetails.id!.id.toString())
//                             as DeviceCredentials;
//
//                         if (olddeviceCredentials != null) {
//                           var oldQRID =
//                               olddeviceCredentials.credentialsId.toString();
//
//                           olddeviceCredentials.credentialsId = oldQRID + "L";
//                           var old_cred_response = await tbClient
//                               .getDeviceService()
//                               .saveDeviceCredentials(olddeviceCredentials);
//
//                           Olddevicedetails.name = Olddevicename + "99";
//                           var old_dev_response = await tbClient
//                               .getDeviceService()
//                               .saveDevice(Olddevicedetails);
//
//                           olddeviceCredentials.credentialsId = newQRID;
//                           var oldcredresponse = await tbClient
//                               .getDeviceService()
//                               .saveDeviceCredentials(olddeviceCredentials);
//
//                           response.name = Old_Device_Name;
//                           response.label = Old_Device_Name;
//                           var olddevresponse = await tbClient
//                               .getDeviceService()
//                               .saveDevice(response);
//
//                           final old_body_req = {
//                             'boardNumber': Old_Device_Name,
//                             'ieeeAddress': oldQRID,
//                           };
//
//                           var up_attribute = (await tbClient
//                               .getAttributeService()
//                               .saveDeviceAttributes(response.id!.id!,
//                                   "SERVER_SCOPE", old_body_req));
//
//                           // New Device Updations
//
//                           Olddevicedetails.name = new_Device_Name;
//                           Olddevicedetails.label = new_Device_Name;
//                           var up_devresponse = await tbClient
//                               .getDeviceService()
//                               .saveDevice(Olddevicedetails);
//
//                           newdeviceCredentials.credentialsId = oldQRID;
//                           var up_credresponse = await tbClient
//                               .getDeviceService()
//                               .saveDeviceCredentials(newdeviceCredentials);
//
//                           final new_body_req = {
//                             'boardNumber': new_Device_Name,
//                             'ieeeAddress': newQRID,
//                           };
//
//                           var up_newdevice_attribute = (await tbClient
//                               .getAttributeService()
//                               .saveDeviceAttributes(Olddevicedetails.id!.id!,
//                                   "SERVER_SCOPE", new_body_req));
//
//                           List<String> myList = [];
//                           myList.add(response.id!.id!);
//
//                           var remove_response = tbClient
//                               .getEntityGroupService()
//                               .removeEntitiesFromEntityGroup(
//                                   DevicecurrentFolderName, myList);
//
//                           var add_response = tbClient
//                               .getEntityGroupService()
//                               .addEntitiesToEntityGroup(
//                                   DevicemoveFolderName, myList);
//
//                           pr.hide();
//                           callDashboard(context);
//                         }
//                       } else {
//                         FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//                         pr.hide();
//                         calltoast(deviceName);
//                       }
//                     } else {
//                       FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//                       pr.hide();
//                       calltoast(deviceName);
//                     }
//                   }
//                 } else {
//                   FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//                   pr.hide();
//                   calltoast(deviceName);
//                 }
//               } else {
//                 FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//                 pr.hide();
//                 calltoast(deviceName);
//               }
//             } else {
//               FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//               pr.hide();
//               calltoast(deviceName);
//             }
//           } else {
//             FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//             pr.hide();
//             calltoast(deviceName);
//           }
//         } else {
//           FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//           pr.hide();
//           calltoast(deviceName);
//         }
//       } catch (e) {
//         FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance", "logMessage");
//         pr.hide();
//         var message = toThingsboardError(e, context);
//         if (message == session_expired) {
//           var status = loginThingsboard.callThingsboardLogin(context);
//           if (status == true) {
//             ilm_main_fetchDeviceDetails(Olddevicename, deviceName, context);
//           }
//         } else {
//           calltoast(deviceName);
//         }
//       }
//     } else {
//       calltoast(no_network);
//     }
//   });
// }

showActionAlertDialog(context, OldDevice, NewDevice) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel",
        style: const TextStyle(
            fontSize: 25.0,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: Colors.red)),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    },
  );
  Widget continueButton = TextButton(
    child: Text("Replace",
        style: const TextStyle(
            fontSize: 25.0,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: Colors.green)),
    onPressed: () {
      // late Future<Device?> entityFuture;
      replaceILM(context);
      // Utility.progressDialog(context);
      // entityFuture = ilm_main_fetchDeviceDetails(context, OldDevice, NewDevice);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Luminator",
        style: const TextStyle(
            fontSize: 25.0,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: thbDblue)),

    content: RichText(
      text: new TextSpan(
        text: 'Would you like to replace ',
        style: const TextStyle(
            fontSize: 16.0,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: liorange),
        children: <TextSpan>[
          new TextSpan(
              text: OldDevice,
              style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          new TextSpan(
              text: ' With ',
              style: const TextStyle(
                  fontSize: 16.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: liorange)),
          new TextSpan(
              text: NewDevice,
              style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          new TextSpan(
              text: ' ? ',
              style: const TextStyle(
                  fontSize: 16.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: liorange)),
        ],
      ),
    ),

    // content: Text("Would you like to replace "+OldDevice+" with "+NewDevice +"?",style: const TextStyle(
    //     fontSize: 18.0,
    //     fontFamily: "Montserrat",
    //     fontWeight: FontWeight.normal,
    //     color: liorange)),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void calltoast(String polenumber) {
  Fluttertoast.showToast(
      msg: device_toast_msg + polenumber + device_toast_notfound,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0);
}

void callDashboard(context) {
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => replacementilm()));
}

Future<void> callDeviceCurrentStatus(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String deviceID = prefs.getString('deviceId').toString();
  String deviceName = prefs.getString('deviceName').toString();
}

// void showDialog(context, timevalue) {
//   showGeneralDialog(
//     barrierLabel: "Barrier",
//     barrierDismissible: true,
//     barrierColor: Colors.black.withOpacity(0.5),
//     transitionDuration: Duration(milliseconds: 700),
//     context: context,
//     pageBuilder: (_, __, ___) {
//       return Align(
//         alignment: Alignment.bottomCenter,
//         child: Container(
//             margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(40),
//             ),
//             height: 300,
//             padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
//             child: Column(children: [
//               Text(
//                 "Last Communication Date and Time",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 20.0,
//                     fontFamily: "Montserrat",
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//               ),
//
//               const SizedBox(
//                 height: 15,
//               ),
//               Text(
//                 '$timevalue',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 20.0,
//                     fontFamily: "Montserrat",
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//               ),
//             ])),
//       );
//     },
//     transitionBuilder: (_, anim, __, child) {
//       return SlideTransition(
//         position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
//         child: child,
//       );
//     },
//   );
// }

Future<ThingsboardError> toThingsboardError(error, context,
    [StackTrace? stackTrace]) async {
  ThingsboardError? tbError;
  FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance",
      "Server Exception with selected Dev");
  if (error.message == "Session expired!") {
    var status = loginThingsboard.callThingsboardLogin(context);
    if (status == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => dashboard_screen()));
    }
  } else {
    if (error is DioError) {
      if (error.response != null && error.response!.data != null) {
        var data = error.response!.data;
        if (data is ThingsboardError) {
          tbError = data;
        } else if (data is Map<String, dynamic>) {
          tbError = ThingsboardError.fromJson(data);
        } else if (data is String) {
          try {
            tbError = ThingsboardError.fromJson(jsonDecode(data));
          } catch (_) {}
        }
      } else if (error.error != null) {
        if (error.error is ThingsboardError) {
          tbError = error.error;
        } else if (error.error is SocketException) {
          tbError = ThingsboardError(
              error: error,
              message: 'Unable to connect',
              errorCode: ThingsBoardErrorCode.general);
        } else {
          tbError = ThingsboardError(
              error: error,
              message: error.error.toString(),
              errorCode: ThingsBoardErrorCode.general);
        }
      }
      if (tbError == null &&
          error.response != null &&
          error.response!.statusCode != null) {
        var httpStatus = error.response!.statusCode!;
        var message = (httpStatus.toString() +
            ': ' +
            (error.response!.statusMessage != null
                ? error.response!.statusMessage!
                : 'Unknown'));
        tbError = ThingsboardError(
            error: error,
            message: message,
            errorCode: httpStatusToThingsboardErrorCode(httpStatus),
            status: httpStatus);
      }
    } else if (error is ThingsboardError) {
      tbError = error;
    }
  }
  tbError ??= ThingsboardError(
      error: error,
      message: error.toString(),
      errorCode: ThingsBoardErrorCode.general);

  var errorStackTrace;
  if (tbError.error is Error) {
    errorStackTrace = tbError.error.stackTrace;
  }

  tbError.stackTrace = stackTrace ??
      tbError.getStackTrace() ??
      errorStackTrace ??
      StackTrace.current;

  return tbError;
}

Future<void> callLogoutoption(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      backgroundColor: Colors.white,
      title: Text("Luminator",
          style: const TextStyle(
              fontSize: 25.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: liorange)),
      content: Text("Are you sure you want to Logout?",
          style: const TextStyle(
              fontSize: 18.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: Colors.black)),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Text("NO",
              style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
        ),
        TextButton(
          child: Text('YES',
              style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          onPressed: () async {
            // DBHelper dbhelper = new DBHelper();
            // dbhelper.region_delete();
            // dbhelper.zone_delete();
            // dbhelper.ward_delete();

            DBHelper dbhelper = new DBHelper();
            SharedPreferences prefs = await SharedPreferences.getInstance();

            var SelectedRegion = prefs.getString("SelectedRegion").toString();
            List<Region> details = await dbhelper.region_getDetails();

            for (int i = 0; i < details.length; i++) {
              dbhelper.delete(details.elementAt(i).id!.toInt());
            }
            dbhelper.zone_delete(SelectedRegion);
            dbhelper.ward_delete(SelectedRegion);

            SharedPreferences preferences =
            await SharedPreferences.getInstance();
            await preferences.clear();
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');

            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => splash_screen()));
          },
        ),
      ],
    ),
  );
}
