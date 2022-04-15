import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/device_count_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/device_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/ui/maintenance/ccms/remove_ccms_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ccms/replace_ccms_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/remove_ilm_screen.dart';
import 'package:flutterlumin/src/ui/point/point.dart';
import 'package:flutterlumin/src/ui/qr_scanner/qr_scanner.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poly_geofence_service/models/lat_lng.dart';
import 'package:poly_geofence_service/models/poly_geofence.dart';
import 'package:poly_geofence_service/poly_geofence_service.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localdb/db_helper.dart';
import '../../../localdb/model/region_model.dart';
import '../../../utils/ccmstoogle_button.dart';
import '../../splash_screen.dart';

class CCMSMaintenanceScreen extends StatefulWidget {
  const CCMSMaintenanceScreen() : super();

  @override
  _CCMSMaintenanceScreenState createState() => _CCMSMaintenanceScreenState();
}

class _CCMSMaintenanceScreenState extends State<CCMSMaintenanceScreen> {
  var selectedImage = "";
  bool _isOn = true;
  DateTime? date;
  int _selectedIndex = 0;
  bool clickedCentreFAB = false;
  var LampactiveStatus;

  String DeviceName = "0";
  String DeviceStatus = "0";
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";
  String faultyStatus = "0";
  String FirmwareVersion = "0";
  String timevalue = "0";
  String location = "0";

  double difference = 0;
  late Timer _timer;
  int _start = 20;

  late ProgressDialog pr;

  String Lattitude = "0";
  String Longitude = "0";
  late bool visibility = false;
  late bool viewvisibility = true;

  String? _error;
  double lattitude = 0;
  double longitude = 0;
  double accuracy = 0;
  var counter = 0;
  String address = "";
  var accuvalue;
  var addvalue;
  List<double>? _latt = [];
  String geoFence = "false";
  var caclsss = 0;
  final _streamController = StreamController<PolyGeofence>();
  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();

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
            difference = difference;
          });
        }
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
          if (accuracy <= 20) {
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
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
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
    DeviceName = prefs.getString('deviceName').toString();
    DeviceStatus = prefs.getString('deviceStatus').toString();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();
    timevalue = prefs.getString("devicetimeStamp").toString();
    location = prefs.getString("location").toString();
    geoFence = prefs.getString('geoFence').toString();
    faultyStatus = prefs.getString("faultyStatus").toString();
    prefs.setString('Maintenance', "Yes");
    FirmwareVersion = prefs.getString("firmwareVersion").toString();
    Lattitude = prefs.getString('deviceLatitude').toString();
    Longitude = prefs.getString('deviceLongitude').toString();

    setState(() {
      DeviceName = DeviceName;
      DeviceStatus = DeviceStatus;
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;
      timevalue = timevalue;
      location = location;
      // version = version;
      faultyStatus = faultyStatus;
      Lattitude = Lattitude;
      Longitude = Longitude;
      FirmwareVersion = FirmwareVersion;
      geoFence = geoFence;

      if (timevalue != null) {
        date = DateTime.fromMillisecondsSinceEpoch(int.parse(timevalue));
      }

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
    DeviceName = "";
    DeviceStatus = "";
    getSharedPrefs();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _polyGeofenceService.start();
      _polyGeofenceService
          .addPolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
      _polyGeofenceService.addLocationChangeListener(_onLocationChanged);
      _polyGeofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      _polyGeofenceService.addStreamErrorListener(_onError);
      _polyGeofenceService.start(_polyGeofenceList).catchError(_onError);
    });

    CallGeoFenceListener(context);
    setUpLogs();
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
        setLogsStatus(
            status: "logsExported: ${call.arguments.toString()}", append: true);

        // Notify Future with value
        _completer.complete(call.arguments.toString());
      } else if (call.method == 'logsPrinted') {
        setLogsStatus(
            status: "logsPrinted: ${call.arguments.toString()}", append: true);
      }
    });
  }

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
        });
        if (geoFence == "true") {
          CallCoordinates(context);
          setState(() {
            visibility = true;
          });
        } else {
          visibility = true;
          viewvisibility = false;
          Fluttertoast.showToast(
              msg: app_geofence_nfound,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
        }
      } catch (e) {}
    } else {
      Permission.locationAlways.request();
    }
  }

  Future<void> CallCoordinates(context) async {
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
      _polyGeofenceList[0].polygon.add(LatLng(latter, rlonger));
    }
  }

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
      message: app_pls_wait,
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
                          child: Text('CCMS Maintanance',
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
                                                            '  $SelectedRegion  ',
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
                                              ],
                                            ),
                                          ),
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
                                                  flex: 2,
                                                  child: CCMSToggleButtonn()),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: InkWell(
                                                      child: Container(
                                                        height: 90,
                                                        decoration: const BoxDecoration(
                                                            color:
                                                                Colors.orange,
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        50.0))),
                                                        child: const Center(
                                                          child: Text(
                                                              'GET LIVE',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      "Montserrat")),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        if (visibility ==
                                                            true) {
                                                          if ('$DeviceStatus' !=
                                                              "false") {
                                                            getLiveRPCCall(
                                                                context);
                                                          } else {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                app_dev_offline_mode,
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                timeInSecForIosWeb:
                                                                    1);
                                                          }
                                                        } else {
                                                          _show(context, true);
                                                        }
                                                      })),
                                            ],
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
                                                      height: 90,
                                                      decoration: const BoxDecoration(
                                                          color:
                                                              Colors.lightBlue,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      50.0))),
                                                      child: const Center(
                                                        child: Text('MCB TRIP',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    "Montserrat")),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      if (visibility == true) {
                                                        if ('$DeviceStatus' !=
                                                            "false") {
                                                          callMCBTrip(context);
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                              app_dev_offline_mode,
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM,
                                                              timeInSecForIosWeb:
                                                                  1);
                                                        }
                                                      } else {
                                                        _show(context, true);
                                                      }
                                                    },
                                                  )),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 5, 5, 5),
                                            decoration: const BoxDecoration(
                                                color: Colors.black12,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(18.0))),
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: InkWell(
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height: 90,
                                                            decoration: const BoxDecoration(
                                                                color: Colors
                                                                    .deepOrange,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            50.0))),
                                                            child: const Text(
                                                                'REMOVE',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        "Montserrat")),
                                                          ),
                                                          onTap: () {
                                                            if (visibility ==
                                                                true) {
                                                              removeCCMS(
                                                                  context);
                                                            } else {
                                                              _show(context,
                                                                  true);
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
                                                                  Alignment
                                                                      .center,
                                                              height: 90,
                                                              decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .green,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              50.0))),
                                                              child: const Text(
                                                                  'REPLACE',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white,
                                                                      fontFamily:
                                                                          "Montserrat")),
                                                            ),
                                                            onTap: () {
                                                              if (visibility ==
                                                                  true) {
                                                                replaceCCMS(
                                                                    context);
                                                              } else {
                                                                _show(context,
                                                                    true);
                                                              }
                                                            })),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ])
                                  ]),
                            ])),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
              title: const Text(app_dev_loc_alert),
              content: const Text(
                  app_dev_range_alert),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(app_close_btn))
              ],
            ),
          );
        });
  }
}

Future<void> callONRPCCall(context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(
        message: app_pls_wait,
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
        var DeviceIdDetails = prefs.getString('DeviceDetails').toString();

        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        // type: String
        final jsonData = {
          "method": "ctrl",
          "params": {"lamp": 1}
        };

        var response = await tbClient
            .getDeviceService()
            .handleTwoWayDeviceRPCRequest(DeviceIdDetails!.toString(), jsonData)
            .timeout(Duration(minutes: 2));

        if (response["lamp"].toString() == "1") {
          Fluttertoast.showToast(
              msg: app_dev_on,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
          pr.hide();
        } else {
          /*FlutterLogs.logInfo("ccms_maintenance_page", "ccms_maintenance",
              "Device Connectivity Issue");*/
          pr.hide();
          calltoast(app_unab_procs);
        }
      } catch (e) {
        /*FlutterLogs.logInfo("ccms_maintenance_page", "ccms_maintenance",
            "ON/RPC Device Connectivity Issue Exception");*/
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            callONRPCCall(context);
          }
        } else {
          calltoast(app_unab_procs);
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
        message: app_pls_wait,
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
        var DeviceIdDetails = prefs.getString('DeviceDetails').toString();

        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        final jsonData = {
          "method": "ctrl",
          "params": {"lamp": 0}
        };
        var response = await tbClient
            .getDeviceService()
            .handleTwoWayDeviceRPCRequest(DeviceIdDetails!.toString(), jsonData)
            .timeout(const Duration(minutes: 2));

        if (response["lamp"].toString() == "0") {
          pr.hide();
          Fluttertoast.showToast(
              msg: app_dev_off,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
        } else {
         /* FlutterLogs.logInfo("ccms_maintenance_page", "ccms_maintenance",
              "Device Connectivity Issue");*/
          pr.hide();
          calltoast(app_unab_procs);
        }
      } catch (e) {
        /*FlutterLogs.logInfo("ccms_maintenance_page", "ccms_maintenance",
            "OFF/RPC Device Connectivity Issue Exception");*/
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            callOFFRPCCall(context);
          }
        } else {
          calltoast(app_unab_procs);
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> callMCBTrip(context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(
        message: app_pls_wait,
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
        var DeviceIdDetails = prefs.getString('DeviceDetails').toString();
        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        final jsonData;

        jsonData = {"method": "clr", "params": "8"};

        var response = await tbClient
            .getDeviceService()
            .handleOneWayDeviceRPCRequest(DeviceIdDetails!.toString(), jsonData)
            .timeout(const Duration(minutes: 5));

        final jsonDatat;

        jsonDatat = {
          "method": "set",
          "params": {'rostat': 0, 'yostat': 0, 'bostat': 0}
        };

        var responsee = await tbClient
            .getDeviceService()
            .handleOneWayDeviceRPCRequest(
                DeviceIdDetails!.toString(), jsonDatat)
            .timeout(const Duration(minutes: 5));

        pr.hide();
      } catch (e) {
        /*FlutterLogs.logInfo("ccms_maintenance_page", "ccms_maintenance",
            "MCB/Device Connectivity Issue Exception");*/
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            getLiveRPCCall(context);
          }
        } else {
          calltoast(app_unab_procs);
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> getLiveRPCCall(context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(
        message: app_pls_wait,
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
        var DeviceIdDetails = prefs.getString('DeviceDetails').toString();
        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        final jsonData;

        jsonData = {
          "method": "get",
          "params": {"value": 0}
        };

        var response = await tbClient
            .getDeviceService()
            .handleOneWayDeviceRPCRequest(DeviceIdDetails!.toString(), jsonData)
            .timeout(const Duration(minutes: 5));
        pr.hide();

      } catch (e) {
        /*FlutterLogs.logInfo("ccms_maintenance_page", "ccms_maintenance",
            "Device Connectivity Issue Exception");*/
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            getLiveRPCCall(context);
          }
        } else {
          calltoast(app_unab_procs);
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> replaceCCMS(context) async {

  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(
        message: app_pls_wait,
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
      String OlddeviceID = prefs.getString('deviceId').toString();
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
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => replaceccms()));
          } else {
            /*FlutterLogs.logInfo("ccms_maintenance_page", "ccms_maintenance",
                "Duplicate QR Found for Execution");*/
            pr.hide();
            calltoast(app_qr_duplicate);
          }
        } else {
          /*FlutterLogs.logInfo("ccms_maintenance_page", "ccms_maintenance",
              "Invalid QR Found for Execution");*/
          pr.hide();
          calltoast(app_qr_invalid);
        }
      });
    } else {
      calltoast(no_network);
    }
  });
}
Future<void> removeCCMS(context) async {
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => replacementccms()));
}

showActionAlertDialog(context, OldDevice, NewDevice) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(app_dialog_cancel,
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
    child: Text(app_dialog_replace,
        style: const TextStyle(
            fontSize: 25.0,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: Colors.green)),
    onPressed: () {
      late Future<Device?> entityFuture;
      // Utility.progressDialog(context);
      replaceCCMS(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(app_display_name,
        style: const TextStyle(
            fontSize: 25.0,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: thbDblue)),

    content: RichText(
      text: new TextSpan(
        text: app_dial_replace,
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
              text: app_dial_replace_with,
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

Future<ThingsboardError> toThingsboardError(error, context,
    [StackTrace? stackTrace]) async {
  ThingsboardError? tbError;
  /*FlutterLogs.logInfo(
      "ccms_maintenance_page", "ccms_maintenance", "Server Error");*/
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
      title: Text(app_display_name,
          style: const TextStyle(
              fontSize: 25.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: liorange)),
      content: Text(app_logout,
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
          child: Text(app_logout_no,
              style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
        ),
        TextButton(
          child: Text(app_logout_yes,
              style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          onPressed: () async {
            try {
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
            } catch (e) {
              /*FlutterLogs.logInfo(
                  "ccms_maintenance_page", "ccms_maintenance", "DB Error");*/
            }
          },
        ),
      ],
    ),
  );
}
