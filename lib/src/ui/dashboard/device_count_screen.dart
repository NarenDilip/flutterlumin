import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/point/edge.dart';
import 'package:flutterlumin/src/ui/point/point.dart';
import 'package:flutterlumin/src/ui/splash_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poly_geofence_service/models/lat_lng.dart';
import 'package:poly_geofence_service/models/poly_geofence.dart';
import 'package:poly_geofence_service/poly_geofence_service.dart';

import '../../localdb/model/region_model.dart';
import 'package:flutter/services.dart' as rootBundle;
import '../../localdb/model/ward_model.dart';

class device_count_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_count_screen_state();
  }
}

class device_count_screen_state extends State<device_count_screen> {
  final _streamController = StreamController<PolyGeofence>();
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";

  String totalCount = "0";
  String activeCount = "0";
  String nonactiveCount = "0";
  String ncCount = "0";

  String ccms_totalCount = "0";
  String ccms_activeCount = "0";
  String ccms_nonactiveCount = "0";
  String ccms_ncCount = "0";

  String gw_totalCount = "0";
  String gw_activeCount = "0";
  String gw_nonactiveCount = "0";
  String gw_ncCount = "0";

  String Maintenance = "true";

  // LocationData? currentLocation;
  String? _error;
  double lattitude = 0;
  double longitude = 0;
  double accuracy = 0;
  String address = "";
  var accuvalue;
  var addvalue;
  var polygonad;
  List<double>? _latt = [];

  // final Location locations = Location();
  // LocationData? _location;
  // StreamSubscription<LocationData>? _locationSubscription;

  // Create a [PolyGeofenceService] instance and set options.
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

    // final jsondata = await rootBundle.load('assets/geofence.json');
    // final list = json.decode(jsondata) as List<dynamic>;

    // var my_data = json.decode(await getJson());
    // my_data.toString();

    for (int i = 0; i < _polyGeofenceList[0].polygon.length; i++) {

      var insideArea = _checkIfValidMarker(
          LatLng(location.latitude, location.longitude),
          _polyGeofenceList[0].polygon);
      print('location check: ${insideArea}');

      Fluttertoast.showToast(
          msg: "GeoFence Location Alert Your are not in the selected Ward, Please reselect the Current Ward , Status: " + insideArea!.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);

      _polyGeofenceService.stop();
    }
  }

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
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();

    totalCount = prefs.getString("totalCount").toString();
    activeCount = prefs.getString("activeCount").toString();
    nonactiveCount = prefs.getString("nonactiveCount").toString();
    ncCount = prefs.getString("ncCount").toString();

    ccms_totalCount = prefs.getString("ccms_totalCount").toString();
    ccms_activeCount = prefs.getString("ccms_activeCount").toString();
    ccms_nonactiveCount = prefs.getString("ccms_nonactiveCount").toString();
    ccms_ncCount = prefs.getString("ccms_ncCount").toString();

    gw_totalCount = prefs.getString("gw_totalCount").toString();
    gw_activeCount = prefs.getString("gw_activeCount").toString();
    gw_nonactiveCount = prefs.getString("gw_nonactiveCount").toString();
    gw_ncCount = prefs.getString("gw_ncCount").toString();

    Maintenance = prefs.getString("Maintenance").toString();

    setState(() {
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;

      totalCount = totalCount;
      activeCount = activeCount;
      nonactiveCount = nonactiveCount;
      ncCount = ncCount;

      ccms_totalCount = ccms_totalCount;
      ccms_activeCount = ccms_activeCount;
      ccms_nonactiveCount = ccms_nonactiveCount;
      ccms_ncCount = ccms_ncCount;

      gw_totalCount = gw_totalCount;
      gw_activeCount = gw_activeCount;
      gw_nonactiveCount = gw_nonactiveCount;
      gw_ncCount = gw_ncCount;

      Maintenance = Maintenance;

      if (SelectedRegion == "0" || SelectedRegion == "null") {
        SelectedRegion = "Region";
        SelectedZone = "Zone";
        SelectedWard = "Ward";
      }

      if (SelectedZone == "0" || SelectedZone == "null") {
        SelectedZone = "Zone";
      }

      if (SelectedWard == "0" || SelectedWard == "null") {
        SelectedWard = "Ward";
      }

      if (totalCount == "null") {
        totalCount = "0";
        activeCount = "0";
        nonactiveCount = "0";
        ncCount = "0";

        ccms_totalCount = "0";
        ccms_activeCount = "0";
        ccms_nonactiveCount = "0";
        ccms_ncCount = "0";

        gw_totalCount = "0";
        gw_activeCount = "0";
        gw_nonactiveCount = "0";
        gw_ncCount = "0";
      }
    });

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
  }

  @override
  void initState() {
    super.initState();
    SelectedRegion = "";
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
    // _listenLocation();
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
  //       accuvalue = accuracy.toString().split(".");
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Container(
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
                      child: Text('Dashboard',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 25.0,
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
                        icon: const Icon(
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
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        SizedBox(height: 5),
                        Container(
                            height: 55,
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Point(
                                            triangleHeight: 25.0,
                                            edge: Edge.RIGHT,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            region_list_screen()));
                                                setState(() {});
                                              },
                                              child: Container(
                                                color: thbDblue,
                                                width: 120.0,
                                                height: 50.0,
                                                child: Center(
                                                  child: Text('$SelectedRegion',
                                                      style: const TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Point(
                                            triangleHeight: 25.0,
                                            edge: Edge.RIGHT,
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
                                                width: 120.0,
                                                height: 50.0,
                                                child: Center(
                                                  child: Text('$SelectedZone',
                                                      style: const TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Point(
                                            triangleHeight: 25.0,
                                            edge: Edge.RIGHT,
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
                                                width: 120.0,
                                                height: 50.0,
                                                child: Center(
                                                  child: Text('$SelectedWard',
                                                      style: const TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]))),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            child: Card(
                          color: Colors.transparent,
                          elevation: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Card(
                                elevation: 20,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(height: 10),
                                      Container(
                                          child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15.0, 0.0, 0.0, 0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "ILM",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 15.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.blue,
                                                  child: Center(
                                                    child: new Text(
                                                      '$totalCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: const <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  40.0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "ON",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "OFF",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 40.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "NC",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  30.0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.green,
                                                  child: Center(
                                                    child: Text(
                                                      '$activeCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.red,
                                                  child: Center(
                                                    child: Text(
                                                      '$nonactiveCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 30.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.orange,
                                                  child: Center(
                                                    child: Text(
                                                      '$ncCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                    ]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Card(
                                elevation: 20,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(height: 10),
                                      Container(
                                          child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15.0, 0.0, 0.0, 0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "CCMS",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 15.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.blue,
                                                  child: Center(
                                                    child: new Text(
                                                      '$ccms_totalCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: const <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  40.0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "ON",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "OFF",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 40.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "NC",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  30.0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.green,
                                                  child: Center(
                                                    child: Text(
                                                      '$ccms_activeCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.red,
                                                  child: Center(
                                                    child: Text(
                                                      '$ccms_nonactiveCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 30.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.orange,
                                                  child: Center(
                                                    child: Text(
                                                      '$ccms_ncCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                    ]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Card(
                                elevation: 20,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(height: 10),
                                      Container(
                                          child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15.0, 0.0, 0.0, 0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "Gateway",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 15.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.blue,
                                                  child: Center(
                                                    child: new Text(
                                                      '$gw_totalCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: const <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  40.0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "ON",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "OFF",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 40.0, 0),
                                              child: Align(
                                                child: Text(
                                                  "NC",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: thbDblue),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  30.0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.green,
                                                  child: Center(
                                                    child: Text(
                                                      '$gw_activeCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment: Alignment.centerLeft,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0.0, 0.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.red,
                                                  child: Center(
                                                    child: Text(
                                                      '$gw_nonactiveCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 30.0, 0),
                                              child: Align(
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.orange,
                                                  child: Center(
                                                    child: Text(
                                                      '$gw_ncCount',
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                    ]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        )),
                      ])))
            ],
          ),
        ));
  }
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
            DBHelper dbhelper = new DBHelper();
            SharedPreferences prefs = await SharedPreferences.getInstance();

            var SelectedRegion = prefs.getString("SelectedRegion").toString();
            List<Region> details = await dbhelper.region_getDetails();

            for (int i = 0; i < details.length; i++) {
              dbhelper.delete(details.elementAt(i).id!.toInt());
            }
            dbhelper.zone_delete(SelectedRegion);
            dbhelper.ward_delete(SelectedRegion);

            // List<Region> detailss = await dbhelper.region_getDetails();
            // List<Zone> zdetails =
            //     (await dbhelper.zone_getDetails()).cast<Zone>();
            // List<Ward> wdetails = await dbhelper.ward_getDetails();

            // dbhelper.region_delete();
            // dbhelper.zone_delete();
            // dbhelper.ward_delete();

            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            await preferences.clear();
            // SystemChannels.platform.invokeMethod('SystemNavigator.pop');

            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => splash_screen()));
          },
        ),
      ],
    ),
  );
}
