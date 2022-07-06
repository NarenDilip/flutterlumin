import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/mapdata_model.dart';
import 'package:flutterlumin/src/localdb/model/ward_model.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/ilm_maintenance_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../thingsboard/error/thingsboard_error.dart';
import '../installation/ccms/ccms_install_cam_screen.dart';
import '../installation/gateway/gateway_install_cam_screen.dart';
import '../installation/ilm/ilm_install_cam_screen.dart';
import '../maintenance/ccms/ccms_maintenance_screen.dart';
import '../maintenance/gateway/gw_maintenance_screen.dart';

// Location map screen it will be used for map view, based on the ward selection
// list of device details are avaliavle in local database, we need to plot
// the device details in the map view, we need to plot the current location in
// the mapview and need to create a radius circle, if users need to click on the
// device it will show a popup details , user need to click on the popup it will
// check the device details and device current state and move to the respective page

class LocationWidget extends StatefulWidget {
  final int initialLabel;
  final OnToggle onToggle;

  LocationWidget({
    this.initialLabel = 0,
    required this.onToggle,
  });

  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

typedef OnToggle = void Function(int index);

class _LocationWidgetState extends State<LocationWidget> {
  final PopupController _popupController = PopupController();
  final Location locations = Location();
  LocationData? _location;
  StreamSubscription<LocationData>? _locationSubscription;
  double lattitude = 0;
  String Lattitude = "";
  double longitude = 0;
  double accuracy = 0;
  var accuvalue;
  var addvalue;
  String? _error;
  MapController _mapController = MapController();
  double _zoom = 10;
  late int current;
  late double marker;
  LocationData? currentLocation;
  String address = "";
  String ssname = "";
  List<double>? _latt = [];
  List<Marker> markersss = [];
  List<LatLng> _latLngListAll = [];
  var listAnswers = [];
  List<LatLng> _latLngListILM = [];
  List<LatLng> _latLngListCCMS = [];
  List<LatLng> _latLngListGW = [];
  List<Marker> _markers = [];
  List<CircleMarker> circleMarkers = [];
  late ProgressDialog pr;

  get loginThingsboard => null;

  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();
  var serverUrl = FlavorConfig.instance.variables["baseUrl"];

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _listenLocation();
    current = widget.initialLabel;
    callWatcher(context);
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

  void setLogsStatus({String status = '', bool append = false}) {
    setState(() {
      logStatus = status;
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
            setState(() {
              address = value;
              if (_latt!.length <= 5) {
                _latt!.add(_location!.latitude!);
                lattitude = _location!.latitude!;
                longitude = _location!.longitude!;
                accuracy = _location!.accuracy!;
                // addresss = addresss;
              } else {
                _locationSubscription?.cancel();
                accuvalue = accuracy.toString().split(".");
                addvalue = value.toString().split(",");
                distance();
              }
            });
          });
        });
    });
  }

  Future<void> distance() async {
    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }

    List<dynamic> data = [
      {LatLng(_location?.latitude, _location?.longitude)},
      {_latLngListILM}
    ];
    double totalDistance = 0;
    List combinedData = [];
    if (data.isNotEmpty) {
      for (var i = 0; i < data.length - 1; i++) {
        if (data[i].toString().isNotEmpty) {
          totalDistance += calculateDistance(data[i]["lat"], data[i]["lng"],
              data[i + 1]["lat"], data[i + 1]["lng"]);
          if (totalDistance <= 5) {
            var distance = data[i + 1];
            combinedData.add(distance);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
   // callNetworkToast(_markers.length.toString());

    var circleMarkers;
    if (_location != null)
      circleMarkers = <CircleMarker>[
        CircleMarker(
            point: LatLng(_location!.latitude, _location!.longitude),
            color: Colors.blue.withOpacity(0.3),
            borderStrokeWidth: 1,
            borderColor: Colors.blue,
            useRadiusInMeter: true,
            radius: 6000 // 2000 meters | 2 km
            ),
      ];

    return Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(children: <Widget>[
        if (_location != null)
          FlutterMap(
            options: MapOptions(
              zoom: _zoom,
              center: LatLng(_location!.latitude, _location!.longitude),
              interactiveFlags: InteractiveFlag.pinchZoom |
                  InteractiveFlag.doubleTapZoom |
                  InteractiveFlag.drag,
              plugins: [
                MarkerClusterPlugin(),
              ],
              onTap: (_) => _popupController.hidePopup(),
            ),
            mapController: _mapController,
            layers: [
              TileLayerOptions(
                minZoom: 2,
                maxZoom: 18,
                backgroundColor: Colors.black,
                // errorImage: ,
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              CircleLayerOptions(circles: circleMarkers),
              MarkerClusterLayerOptions(
                maxClusterRadius: 190,
                disableClusteringAtZoom: 16,
                size: const Size(50, 50),
                fitBoundsOptions: const FitBoundsOptions(
                  padding: EdgeInsets.all(50),
                ),
                markers: _markers,
                polygonOptions: const PolygonOptions(
                    borderColor: Colors.blueAccent,
                    color: Colors.black12,
                    borderStrokeWidth: 3),
                popupOptions: PopupOptions(
                    popupSnap: PopupSnap.top,
                    popupController: _popupController,
                    popupBuilder: (_, marker) => Container(
                        padding: const EdgeInsets.all(5),
                        color: Colors.white,
                        child: GestureDetector(
                            onTap: () {
                              popupOnClick(
                                  listAnswers[listAnswers.indexWhere((pair) =>
                                              pair['Key'] ==
                                              marker.point.latitude.toString())]
                                          ['value']
                                      .toString(),
                                  context);
                            },
                            child: Container(
                                alignment: Alignment.center,
                                height: 65,
                                width: 150,
                                child: Column(children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Lattitude : "),
                                        Text(
                                          marker.point.latitude.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Longitude : "),
                                        Text(
                                          marker.point.longitude.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Name : "),
                                        Text(
                                            listAnswers[listAnswers.indexWhere(
                                                        (pair) =>
                                                            pair['Key'] ==
                                                            marker
                                                                .point.latitude
                                                                .toString())]
                                                    ['value']
                                                .toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ]),
                                ]))))),
                builder: (context, markers) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                    child: Text('${markers.length}'),
                  );
                },
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.only(right: 13, bottom: 40),
          child: Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                getCurrentLocation();
              },
              child: Container(
                height: 55,
                width: 55,
                //margin: EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  color: darkgreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 15.0),
          child: Align(
            alignment: Alignment.topRight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 30,
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                      ['All', 'ILM', 'CCMS', 'GW'].length * 2 - 1, (index) {
                    final active = index ~/ 2 == current;
                    final textColor = active ? Colors.white : Colors.black;
                    final bgColor = active ? thbDblue : Colors.transparent;
                    if (index % 2 == 1) {
                      final activeDivider = active || index ~/ 2 == current - 1;
                      return Container(
                        width: 1,
                        color: activeDivider ? lightorange : Colors.white30,
                        margin: EdgeInsets.symmetric(
                            vertical: activeDivider ? 0 : 8),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            current = index ~/ 2;
                            if (widget.onToggle != null) {
                              widget.onToggle(index);
                            }
                            if (current == 0) {
                              var _markers_1 = _latLngListILM
                                  .map((point) => Marker(
                                        point: point,
                                        width: 60,
                                        height: 60,
                                        builder: (context) => const Icon(
                                          Icons.location_pin,
                                          size: 60,
                                          color: Colors.red,
                                        ),
                                      ))
                                  .toList();
                              var _markers_2 = _latLngListCCMS
                                  .map((point) => Marker(
                                        point: point,
                                        width: 60,
                                        height: 60,
                                        builder: (context) => const Icon(
                                          Icons.location_pin,
                                          size: 60,
                                          color: Colors.green,
                                        ),
                                      ))
                                  .toList();
                              var _markers_3 = _latLngListGW
                                  .map((point) => Marker(
                                        point: point,
                                        width: 60,
                                        height: 60,
                                        builder: (context) => const Icon(
                                          Icons.location_pin,
                                          size: 60,
                                          color: Colors.purple,
                                        ),
                                      ))
                                  .toList();
                              var _markers_4 = _latLngListGW
                                  .map((point) => Marker(
                                        point: point,
                                        width: 60,
                                        height: 60,
                                        builder: (context) => const Icon(
                                          Icons.location_pin,
                                          size: 60,
                                          color: Colors.purple,
                                        ),
                                      ))
                                  .toList();
                              setState(() {
                                _markers = _markers_1 + _markers_2 + _markers_3;
                              });
                            }
                            if (current == 1) {
                              _markers = _latLngListILM
                                  .map((point) => Marker(
                                        point: point,
                                        width: 60,
                                        height: 60,
                                        builder: (context) => const Icon(
                                          Icons.location_pin,
                                          size: 60,
                                          color: Colors.red,
                                        ),
                                      ))
                                  .toList();
                            }
                            if (current == 2) {
                              _markers = _latLngListCCMS
                                  .map((point) => Marker(
                                        point: point,
                                        width: 60,
                                        height: 60,
                                        builder: (context) => const Icon(
                                          Icons.location_pin,
                                          size: 60,
                                          color: Colors.green,
                                        ),
                                      ))
                                  .toList();
                            }
                            if (current == 3) {
                              _markers = _latLngListGW
                                  .map((point) => Marker(
                                        point: point,
                                        width: 60,
                                        height: 60,
                                        builder: (context) => const Icon(
                                          Icons.location_pin,
                                          size: 60,
                                          color: Colors.purple,
                                        ),
                                      ))
                                  .toList();
                            }
                          });
                        },
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 40),
                          alignment: Alignment.center,
                          color: bgColor,
                          child: Text(['All', 'ILM', 'CCMS', 'GW'][index ~/ 2],
                              style: TextStyle(
                                  color: textColor, fontFamily: "Aqua")),
                        ),
                      );
                    }
                  }),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 13, bottom: 40),
          child: Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                getCurrentLocation();
              },
              child: Container(
                height: 55,
                width: 55,
                //margin: EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  color: thbDblue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location,
                  semanticLabel: "test",
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }

  getCurrentLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      //_center = LatLng(_locationData.latitude, _locationData.longitude);
      _mapController.move(
          LatLng(_locationData.latitude!, _locationData.longitude!), 10.0);

      // _markers = [LatLng(_locationData.latitude, _locationData.longitude)]
      //     .map((point) => Marker(
      //           point: point,
      //           width: 15,
      //           height: 15,
      //           builder: (context) => Icon(
      //             Icons.circle,
      //             size: 15,
      //             color: Colors.blue,
      //           ),
      //         ))
      //     .toList();
    });
  }

  Future<void> popupOnClick(String string, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('deviceName', string);
    fetchGWDeviceDetails(string, context);
  }

  @override
  Future<Device?> fetchGWDeviceDetails(
      String deviceName, BuildContext context) async {
    Utility.isConnected().then((value) async {
      var gofenceValidation = false;
      if (value) {
        try {
          pr.show();
          Device response;
          String? SelectedRegion;
          var tbClient =
              ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
          tbClient.smart_init();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          SelectedRegion = prefs.getString("SelectedRegion").toString();
          if (SelectedRegion.toString() != "Region") {
            if (SelectedRegion.toString() != "null") {
              response = (await tbClient
                  .getDeviceService()
                  .getTenantDevice(deviceName)) as Device;

              if (response.toString().isNotEmpty) {
                prefs.setString('deviceId', response.id!.id!.toString());
                prefs.setString('DeviceDetails', response.id!.id!.toString());

                // try {
                //   List<TsKvEntry> faultresponser;
                //   faultresponser = await tbClient
                //       .getAttributeService()
                //       .getselectedLatestTimeseries(response.id!.id!, "version");
                //   if (faultresponser.isNotEmpty) {
                //     prefs.setString('firmwareVersion',
                //         faultresponser.first.getValue().toString());
                //   }
                // } catch (e) {
                //   var message = toThingsboardError(e, context);
                //   FlutterLogs.logInfo(
                //       "Luminator 2.0", "dashboard_page", "");
                // }

                // List<String> myLists = [];
                // myLists.add("version");
                //
                // List<AttributeKvEntry> deviceresponser;
                //
                // deviceresponser = (await tbClient
                //     .getAttributeService()
                //     .getAttributeKvEntries(response.id!, myLists));

                // if (deviceresponser.isNotEmpty) {
                //   prefs.setString('firmwareVersion',
                //       deviceresponser.first.getValue().toString());
                prefs.setString('deviceName', deviceName);

                var relationDetails = await tbClient
                    .getEntityRelationService()
                    .findInfoByTo(response.id!);

                List<AttributeKvEntry> responserse;

                // var SelectedWard = prefs.getString("SelectedWard").toString();
                // DBHelper dbHelper = new DBHelper();
                // var wardDetails =
                //     await dbHelper.ward_basedDetails(SelectedWard);
                // if (wardDetails.isNotEmpty) {
                //   wardDetails.first.wardid;
                //
                //   List<String> wardist = [];
                //   wardist.add("geofence");
                //
                //   var wardresponser = await tbClient
                //       .getAttributeService()
                //       .getFirmAttributeKvEntries(
                //           wardDetails.first.wardid!, wardist);
                //
                //   if (wardresponser.isNotEmpty) {
                //     if (wardresponser.first.getValue() == "true") {
                //       gofenceValidation = true;
                //       prefs.setString('geoFence', "true");
                //     } else {
                //       gofenceValidation = false;
                //       prefs.setString('geoFence', "false");
                //     }
                //   }
                // }

                gofenceValidation = false;
                prefs.setString('geoFence', "false");

                if (relationDetails.length.toString() == "0") {
                  pr.hide();
                  if (response.type == ilm_deviceType) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ilmcaminstall()),
                    );
                  } else if (response.type == ccms_deviceType) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ccmscaminstall()),
                    );
                  } else if (response.type == Gw_deviceType) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const gwcaminstall()),
                    );
                  }
                  // } else {
                  //   // Navigator.pop(context);
                  //   pr.hide();
                  //   // refreshPage(context);
                  // }
                } else {
                  List<String> firstmyList = [];
                  firstmyList.add("lmp");

                  try {
                    List<TsKvEntry> faultresponser;
                    faultresponser = await tbClient
                        .getAttributeService()
                        .getselectedLatestTimeseries(response.id!.id!, "lmp");
                    if (faultresponser.isNotEmpty) {
                      prefs.setString('faultyStatus',
                          faultresponser.first.getValue().toString());
                    }
                  } catch (e) {
                    var message = toThingsboardError(e, context);
                    FlutterLogs.logInfo("Luminator 2.0", "dashboard_page", "");
                  }

                  List<String> myList = [];
                  myList.add("active");

                  List<AttributeKvEntry> atresponser;

                  atresponser = (await tbClient
                      .getAttributeService()
                      .getAttributeKvEntries(response.id!, myList));

                  if (atresponser.isNotEmpty) {
                    prefs.setString('deviceStatus',
                        atresponser.first.getValue().toString());
                    prefs.setString('devicetimeStamp',
                        atresponser.elementAt(0).getLastUpdateTs().toString());

                    List<String> myLister = [];
                    myLister.add("landmark");

                    responserse = (await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(response.id!, myLister));

                    if (responserse.isNotEmpty) {
                      prefs.setString(
                          'location', responserse.first.getValue().toString());
                      prefs.setString('deviceName', deviceName);
                    }
                    // myLister.add("location");

                    List<String> LampmyList = [];
                    LampmyList.add("lampWatts");

                    List<AttributeKvEntry> lampatresponser;

                    lampatresponser = (await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(response.id!, LampmyList));

                    if (lampatresponser.isNotEmpty) {
                      prefs.setString('deviceWatts',
                          lampatresponser.first.getValue().toString());
                    }

                    List<String> myList = [];
                    myList.add("lattitude");
                    myList.add("longitude");

                    List<BaseAttributeKvEntry> responser;

                    responser = (await tbClient
                            .getAttributeService()
                            .getAttributeKvEntries(response.id!, myList))
                        as List<BaseAttributeKvEntry>;

                    prefs.setString('deviceLatitude',
                        responser.first.kv.getValue().toString());
                    prefs.setString('deviceLongitude',
                        responser.last.kv.getValue().toString());

                    pr.hide();
                    if (response.type == ilm_deviceType) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MaintenanceScreen()),
                      );
                    } else if (response.type == ccms_deviceType) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CCMSMaintenanceScreen()),
                      );
                    } else if (response.type == Gw_deviceType) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GWMaintenanceScreen()),
                      );
                    }
                  } else {
                    FlutterLogs.logInfo("Dashboard_Page", "Dashboard",
                        "No attributes key found");
                    pr.hide();
                    refreshPage(context);
                    //"" No Active attribute found
                  }
                }
                // } else {
                //   FlutterLogs.logInfo(
                //       "Dashboard_Page", "Dashboard", "No version attributes key found");
                //   pr.hide();
                //   refreshPage(context);
                //   //"" No Firmware Device Found
                // }
              } else {
                FlutterLogs.logInfo(
                    "Dashboard_Page", "Dashboard", "No Device Details Found");
                pr.hide();
                refreshPage(context);
                //"" No Device Found
              }
            } else {
              Fluttertoast.showToast(
                  msg: "Please select Region to start Installation.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);

              pr.hide();
              refreshPage(context);
              //"" No Device Found
            }
          } else {
            Fluttertoast.showToast(
                msg: "Please select Region to start Installation.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);

            pr.hide();
            refreshPage(context);
            //"" No Device Found
          }
        } catch (e) {
          FlutterLogs.logInfo(
              "Dashboard_Page", "Dashboard", "Device Details Fetch Exception");
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              fetchGWDeviceDetails(deviceName, context);
            }
          } else {
            refreshPage(context);
            Fluttertoast.showToast(
                msg: device_toast_msg + deviceName + device_toast_notfound,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        }
      }
    });
  }

  // @override
  // Future<Device?> fetchDeviceDetails(
  //     String deviceName, BuildContext context) async {
  //   Utility.isConnected().then((value) async {
  //     if (value) {
  //       try {
  //         // Utility.progressDialog(context);
  //         pr.show();
  //         Device response;
  //         Future<List<EntityGroupInfo>> deviceResponse;
  //         var tbClient = ThingsboardClient(serverUrl);
  //         tbClient.smart_init();
  //         response = await tbClient
  //             .getDeviceService()
  //             .getTenantDevice(deviceName) as Device;
  //         if (response != null) {
  //           DeviceCredentials deviceCredentials = (await tbClient
  //                   .getDeviceService()
  //                   .getDeviceCredentialsByDeviceId(response.id!.id!))
  //               as DeviceCredentials;
  //
  //           if (response.type == ilm_deviceType) {
  //             if (deviceCredentials.credentialsId.length == 16) {
  //               fetchSmartDeviceDetails(
  //                   deviceName, response.id!.id.toString(), context);
  //             } else {
  //               pr.hide();
  //               Fluttertoast.showToast(
  //                   msg:
  //                       "Device Credentials are invalid, Device not despatched properly",
  //                   toastLength: Toast.LENGTH_SHORT,
  //                   gravity: ToastGravity.BOTTOM,
  //                   timeInSecForIosWeb: 1,
  //                   backgroundColor: Colors.white,
  //                   textColor: Colors.black,
  //                   fontSize: 16.0);
  //             }
  //           } else if (response.type == ccms_deviceType) {
  //             if (deviceCredentials.credentialsId.length == 15) {
  //               fetchCCMSDeviceDetails(
  //                   deviceName, response.id!.id.toString(), context);
  //             } else {
  //               pr.hide();
  //               Fluttertoast.showToast(
  //                   msg:
  //                       "Device Credentials are invalid, Device not despatched properly",
  //                   toastLength: Toast.LENGTH_SHORT,
  //                   gravity: ToastGravity.BOTTOM,
  //                   timeInSecForIosWeb: 1,
  //                   backgroundColor: Colors.white,
  //                   textColor: Colors.black,
  //                   fontSize: 16.0);
  //             }
  //           } else if (response.type == Gw_deviceType) {
  //             if (deviceCredentials.credentialsId.length == 15) {
  //               fetchGWDeviceDetails(
  //                   deviceName, response.id!.id.toString(), context);
  //             } else {
  //               pr.hide();
  //               Fluttertoast.showToast(
  //                   msg:
  //                       "Device Credentials are invalid, Device not despatched properly",
  //                   toastLength: Toast.LENGTH_SHORT,
  //                   gravity: ToastGravity.BOTTOM,
  //                   timeInSecForIosWeb: 1,
  //                   backgroundColor: Colors.white,
  //                   textColor: Colors.black,
  //                   fontSize: 16.0);
  //             }
  //           } else {
  //             pr.hide();
  //             // Navigator.pop(context);
  //             Fluttertoast.showToast(
  //                 msg: "Device Details Not Found",
  //                 toastLength: Toast.LENGTH_SHORT,
  //                 gravity: ToastGravity.BOTTOM,
  //                 timeInSecForIosWeb: 1,
  //                 backgroundColor: Colors.white,
  //                 textColor: Colors.black,
  //                 fontSize: 16.0);
  //           }
  //         } else {
  //           // Navigator.pop(context);
  //           pr.hide();
  //           Fluttertoast.showToast(
  //               msg: device_toast_msg + deviceName + device_toast_notfound,
  //               toastLength: Toast.LENGTH_SHORT,
  //               gravity: ToastGravity.BOTTOM,
  //               timeInSecForIosWeb: 1,
  //               backgroundColor: Colors.white,
  //               textColor: Colors.black,
  //               fontSize: 16.0);
  //           Navigator.of(context).pushReplacement(MaterialPageRoute(
  //               builder: (BuildContext context) => dashboard_screen()));
  //         }
  //       } catch (e) {
  //         // Navigator.pop(context);
  //         pr.hide();
  //         var message = toThingsboardError(e, context);
  //         if (message == session_expired) {
  //           var status = loginThingsboard.callThingsboardLogin(context);
  //           if (status == true) {
  //             fetchDeviceDetails(deviceName, context);
  //           }
  //         } else {
  //           Fluttertoast.showToast(
  //               msg: device_toast_msg + deviceName + device_toast_notfound,
  //               toastLength: Toast.LENGTH_SHORT,
  //               gravity: ToastGravity.BOTTOM,
  //               timeInSecForIosWeb: 1,
  //               backgroundColor: Colors.white,
  //               textColor: Colors.black,
  //               fontSize: 16.0);
  //         }
  //       }
  //     } else {
  //       Fluttertoast.showToast(
  //           msg: no_network,
  //           toastLength: Toast.LENGTH_SHORT,
  //           gravity: ToastGravity.BOTTOM,
  //           timeInSecForIosWeb: 1,
  //           backgroundColor: Colors.white,
  //           textColor: Colors.black,
  //           fontSize: 16.0);
  //     }
  //   });
  // }

  // @override
  // Future<Device?> fetchGWDeviceDetails(
  //     String deviceName, String string, BuildContext context) async {
  //   Utility.isConnected().then((value) async {
  //     if (value) {
  //       try {
  //         pr.show();
  //         Device response;
  //         String? SelectedRegion;
  //         Future<List<EntityGroupInfo>> deviceResponse;
  //         var tbClient = ThingsboardClient(serverUrl);
  //         tbClient.smart_init();
  //
  //         response = (await tbClient
  //             .getDeviceService()
  //             .getTenantDevice(deviceName)) as Device;
  //
  //         var relationDetails = await tbClient
  //             .getEntityRelationService()
  //             .findInfoByTo(response.id!);
  //
  //         List<String> myLists = [];
  //         myLists.add("firmwareVersion");
  //
  //         List<AttributeKvEntry> deviceresponser;
  //
  //         deviceresponser = (await tbClient
  //                 .getAttributeService()
  //                 .getAttributeKvEntries(response.id!, myLists))
  //             as List<AttributeKvEntry>;
  //
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //         prefs.setString(
  //             'firmwareVersion', deviceresponser.first.getValue().toString());
  //         prefs.setString('deviceName', deviceName);
  //         SelectedRegion = prefs.getString("SelectedRegion").toString();
  //
  //         List<String> firstmyList = [];
  //         firstmyList.add("lmp");
  //
  //         try {
  //           List<TsKvEntry> faultresponser;
  //           faultresponser = await tbClient
  //                   .getAttributeService()
  //                   .getselectedLatestTimeseries(response.id!.id!, "lmp")
  //               as List<TsKvEntry>;
  //           if (faultresponser.length != 0) {
  //             prefs.setString(
  //                 'faultyStatus', faultresponser.first.getValue().toString());
  //           }
  //         } catch (e) {
  //           var message = toThingsboardError(e, context);
  //         }
  //
  //         List<String> myList = [];
  //         myList.add("active");
  //
  //         List<AttributeKvEntry> responser;
  //
  //         responser = (await tbClient
  //                 .getAttributeService()
  //                 .getAttributeKvEntries(response.id!, myList))
  //             as List<AttributeKvEntry>;
  //
  //         prefs.setString(
  //             'deviceStatus', responser.first.getValue().toString());
  //         prefs.setString('devicetimeStamp',
  //             responser.elementAt(0).getLastUpdateTs().toString());
  //
  //         List<String> myLister = [];
  //         myLister.add("landmark");
  //         // myLister.add("location");
  //
  //         List<AttributeKvEntry> responserse;
  //
  //         responserse = (await tbClient
  //                 .getAttributeService()
  //                 .getAttributeKvEntries(response.id!, myLister))
  //             as List<AttributeKvEntry>;
  //
  //         if (responserse.length != "0") {
  //           prefs.setString(
  //               'location', responserse.first.getValue().toString());
  //           prefs.setString('deviceId', response.id!.toString());
  //           prefs.setString('deviceName', deviceName);
  //         }
  //
  //         if (relationDetails.length.toString() == "0") {
  //           if (SelectedRegion.length.toString() != "0") {
  //             // pr.hide();
  //             // if (context != null) {
  //             //   Navigator.push(
  //             //     context,
  //             //     MaterialPageRoute(builder: (context) => const gwcaminstall()),
  //             //   );
  //             Navigator.of(context).pushReplacement(MaterialPageRoute(
  //                 builder: (BuildContext context) => gwcaminstall()));
  //             // }
  //           } else {
  //             // Navigator.pop(context);
  //             pr.hide();
  //             Fluttertoast.showToast(
  //                 msg: "Kindly Choose your Region, Zone and Ward to Install",
  //                 toastLength: Toast.LENGTH_SHORT,
  //                 gravity: ToastGravity.BOTTOM,
  //                 timeInSecForIosWeb: 1,
  //                 backgroundColor: Colors.white,
  //                 textColor: Colors.black,
  //                 fontSize: 16.0);
  //             // refreshPage(context);
  //           }
  //         } else {
  //           // pr.hide();
  //           // Navigator.pop(context);
  //           // if (context != null) {
  //           //   Navigator.push(
  //           //     context,
  //           //     MaterialPageRoute(
  //           //         builder: (context) => const GWMaintenanceScreen()),
  //           //   );
  //           Navigator.of(context).pushReplacement(MaterialPageRoute(
  //               builder: (BuildContext context) => GWMaintenanceScreen()));
  //           // }
  //         }
  //         // pr.hide();
  //       } catch (e) {
  //         pr.hide();
  //         var message = toThingsboardError(e, context);
  //         if (message == session_expired) {
  //           var status = loginThingsboard.callThingsboardLogin(context);
  //           if (status == true) {
  //             fetchDeviceDetails(deviceName, context);
  //           }
  //         } else {
  //           refreshPage(context);
  //           Fluttertoast.showToast(
  //               msg: device_toast_msg + deviceName + device_toast_notfound,
  //               toastLength: Toast.LENGTH_SHORT,
  //               gravity: ToastGravity.BOTTOM,
  //               timeInSecForIosWeb: 1,
  //               backgroundColor: Colors.white,
  //               textColor: Colors.black,
  //               fontSize: 16.0);
  //         }
  //       }
  //     }
  //   });
  // }

  @override
  Future<Device?> fetchCCMSDeviceDetails(
      String deviceName, String string, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          pr.show();
          Device response;
          String? SelectedRegion;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          response = (await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName)) as Device;

          var relationDetails = await tbClient
              .getEntityRelationService()
              .findInfoByTo(response.id!);

          List<String> myLists = [];
          myLists.add("firmwareVersion");

          List<BaseAttributeKvEntry> deviceresponser;

          deviceresponser = (await tbClient
                  .getAttributeService()
                  .getAttributeKvEntries(response.id!, myLists))
              as List<BaseAttributeKvEntry>;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('firmwareVersion',
              deviceresponser.first.kv.getValue().toString());
          prefs.setString('deviceName', deviceName);
          SelectedRegion = prefs.getString("SelectedRegion").toString();

          List<String> firstmyList = [];
          firstmyList.add("lmp");

          try {
            List<TsKvEntry> faultresponser;
            faultresponser = await tbClient
                    .getAttributeService()
                    .getselectedLatestTimeseries(response.id!.id!, "lmp")
                as List<TsKvEntry>;
            if (faultresponser.length != 0) {
              prefs.setString(
                  'faultyStatus', faultresponser.first.getValue().toString());
            }
          } catch (e) {
            var message = toThingsboardError(e, context);
          }

          List<String> myList = [];
          myList.add("active");

          List<BaseAttributeKvEntry> responser;

          responser = (await tbClient
                  .getAttributeService()
                  .getAttributeKvEntries(response.id!, myList))
              as List<BaseAttributeKvEntry>;

          prefs.setString(
              'deviceStatus', responser.first.kv.getValue().toString());
          prefs.setString(
              'devicetimeStamp', responser.first.lastUpdateTs.toString());

          List<String> myLister = [];
          myLister.add("landmark");
          // myLister.add("location");

          List<AttributeKvEntry> responserse;

          responserse = (await tbClient
                  .getAttributeService()
                  .getAttributeKvEntries(response.id!, myLister))
              as List<AttributeKvEntry>;

          if (responserse.length != "0") {
            prefs.setString(
                'location', responserse.first.getValue().toString());
            prefs.setString('deviceId', response.id!.toString());
            prefs.setString('deviceName', deviceName);
          }

          if (relationDetails.length.toString() == "0") {
            if (SelectedRegion.length.toString() != "0") {
              // pr.hide();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ccmscaminstall()),
              );
            } else {
              // Navigator.pop(context);
              pr.hide();
              Fluttertoast.showToast(
                  msg: "Please select Region to start Installation",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
              // refreshPage(context);
            }
          } else {
            // pr.hide();
            // Navigator.pop(context);
            if (context != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CCMSMaintenanceScreen()),
              );
              // Navigator.of(context).pushReplacement(MaterialPageRoute(
              //     builder: (BuildContext context) => CCMSMaintenanceScreen()));
            }
          }
          // pr.hide();
        } catch (e) {
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              fetchGWDeviceDetails(deviceName, context);
            }
          } else {
            Fluttertoast.showToast(
                msg: device_toast_msg + deviceName + device_toast_notfound,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
            refreshPage(context);
          }
        }
      }
    });
  }

  // @override
  // Future<Device?> fetchSmartDeviceDetails(
  //     String deviceName, String deviceid, BuildContext context) async {
  //   Utility.isConnected().then((value) async {
  //     if (value) {
  //       try {
  //         // Utility.progressDialog(context);
  //         pr.show();
  //         Device response;
  //         Future<List<EntityGroupInfo>> deviceResponse;
  //         var tbClient = ThingsboardClient(serverUrl);
  //         tbClient.smart_init();
  //
  //         response = (await tbClient
  //             .getDeviceService()
  //             .getTenantDevice(deviceName)) as Device;
  //
  //         var relationDetails = await tbClient
  //             .getEntityRelationService()
  //             .findInfoByTo(response.id!);
  //
  //         List<String> firstmyList = [];
  //         firstmyList.add("lmp");
  //
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //         try {
  //           List<TsKvEntry> faultresponser;
  //           faultresponser = await tbClient
  //                   .getAttributeService()
  //                   .getselectedLatestTimeseries(response.id!.id!, "lmp")
  //               as List<TsKvEntry>;
  //           if (faultresponser.length != 0) {
  //             prefs.setString(
  //                 'faultyStatus', faultresponser.first.getValue().toString());
  //           }
  //         } catch (e) {
  //           var message = toThingsboardError(e, context);
  //         }
  //
  //         List<String> myList = [];
  //         myList.add("lampWatts");
  //         myList.add("active");
  //
  //         List<BaseAttributeKvEntry> responser;
  //
  //         responser = (await tbClient
  //                 .getAttributeService()
  //                 .getAttributeKvEntries(response.id!, myList))
  //             as List<BaseAttributeKvEntry>;
  //
  //         prefs.setString(
  //             'deviceStatus', responser.first.kv.getValue().toString());
  //         prefs.setString(
  //             'deviceWatts', responser.last.kv.getValue().toString());
  //         prefs.setString(
  //             'devicetimeStamp', responser.first.lastUpdateTs.toString());
  //
  //         List<String> myLister = [];
  //         // myLister.add("landmark");
  //         myLister.add("location");
  //
  //         List<AttributeKvEntry> responserse;
  //
  //         responserse = (await tbClient
  //             .getAttributeService()
  //             .getAttributeKvEntries(response.id!, myLister));
  //
  //         if (responserse.length != "0") {
  //           prefs.setString(
  //               'location', responserse.first.getValue().toString());
  //           prefs.setString('deviceId', deviceid);
  //           prefs.setString('deviceName', deviceName);
  //
  //           List<String> versionlist = [];
  //           versionlist.add("version");
  //
  //           List<AttributeKvEntry> version_responserse;
  //
  //           version_responserse = (await tbClient
  //               .getAttributeService()
  //               .getAttributeKvEntries(response.id!, versionlist));
  //
  //           if (version_responserse.length == 0) {
  //             prefs.setString('version', "0");
  //           } else {
  //             prefs.setString('version', version_responserse.first.getValue());
  //           }
  //
  //           if (relationDetails.length.toString() == "0") {
  //             SharedPreferences prefs = await SharedPreferences.getInstance();
  //             var SelectedRegion = prefs.getString("SelectedRegion").toString();
  //             if (SelectedRegion != "null") {
  //               List<String> myList = [];
  //               myList.add("faulty");
  //               List<AttributeKvEntry> responser;
  //
  //               responser = (await tbClient
  //                   .getAttributeService()
  //                   .getAttributeKvEntries(response.id!, myList));
  //
  //               var faultyDetails = false;
  //               if (responser.length == 0) {
  //                 faultyDetails = false;
  //               } else {
  //                 faultyDetails = responser.first.getValue();
  //               }
  //
  //               if (faultyDetails == false) {
  //                 Navigator.of(context).pushReplacement(MaterialPageRoute(
  //                     builder: (BuildContext context) => ilmcaminstall()));
  //               } else {
  //                 // Navigator.pop(context);
  //                 pr.hide();
  //                 Fluttertoast.showToast(
  //                     msg:
  //                         "Device Currently in Faulty State Unable to Install.",
  //                     toastLength: Toast.LENGTH_SHORT,
  //                     gravity: ToastGravity.BOTTOM,
  //                     timeInSecForIosWeb: 1,
  //                     backgroundColor: Colors.white,
  //                     textColor: Colors.black,
  //                     fontSize: 16.0);
  //
  //                 // refreshPage(context);
  //               }
  //             } else {
  //               // Navigator.pop(context);
  //               pr.hide();
  //               Fluttertoast.showToast(
  //                   msg: "Kindly Choose your Region, Zone and Ward to Install",
  //                   toastLength: Toast.LENGTH_SHORT,
  //                   gravity: ToastGravity.BOTTOM,
  //                   timeInSecForIosWeb: 1,
  //                   backgroundColor: Colors.white,
  //                   textColor: Colors.black,
  //                   fontSize: 16.0);
  //
  //               // refreshPage(context);
  //             }
  //           } else {
  //             // Navigator.pop(context);
  //             pr.hide();
  //             Navigator.of(context).pushReplacement(MaterialPageRoute(
  //                 builder: (BuildContext context) => MaintenanceScreen()));
  //           }
  //         } else {
  //           // Navigator.pop(context);
  //           pr.hide();
  //           Fluttertoast.showToast(
  //               msg: device_toast_msg + deviceName + device_toast_notfound,
  //               toastLength: Toast.LENGTH_SHORT,
  //               gravity: ToastGravity.BOTTOM,
  //               timeInSecForIosWeb: 1,
  //               backgroundColor: Colors.white,
  //               textColor: Colors.black,
  //               fontSize: 16.0);
  //           // refreshPage(context);
  //         }
  //       } catch (e) {
  //         // Navigator.pop(context);
  //         var message = toThingsboardError(e, context);
  //         if (message == session_expired) {
  //           var status = loginThingsboard.callThingsboardLogin(context);
  //           if (status == true) {
  //             fetchGWDeviceDetails(deviceName, context);
  //           }
  //         } else {
  //           Fluttertoast.showToast(
  //               msg: device_toast_msg + deviceName + device_toast_notfound,
  //               toastLength: Toast.LENGTH_SHORT,
  //               gravity: ToastGravity.BOTTOM,
  //               timeInSecForIosWeb: 1,
  //               backgroundColor: Colors.white,
  //               textColor: Colors.black,
  //               fontSize: 16.0);
  //         }
  //       }
  //     } else {
  //       Fluttertoast.showToast(
  //           msg: no_network,
  //           toastLength: Toast.LENGTH_SHORT,
  //           gravity: ToastGravity.BOTTOM,
  //           timeInSecForIosWeb: 1,
  //           backgroundColor: Colors.white,
  //           textColor: Colors.black,
  //           fontSize: 16.0);
  //     }
  //   });
  // }

  void circle() {
    circleMarkers = CircleMarker(
        point: LatLng(lattitude, longitude),
        color: Colors.blue.withOpacity(0.3),
        borderStrokeWidth: 3,
        borderColor: Colors.blue,
        useRadiusInMeter: true,
        radius: 5000 // 2000 meters | 2 km
        ) as List<CircleMarker>;
  }

  void callWatcher(context) {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          var tbClient = await ThingsboardClient(serverUrl);
          tbClient.smart_init();

          SharedPreferences prefs = await SharedPreferences.getInstance();
          var SelectedWard = prefs.getString("SelectedWard").toString();

          if (SelectedWard != "Ward") {
            DBHelper dbHelper = DBHelper();
            // List<Mapdata> locationdetails =
            //     await dbHelper.get_details_LocalNetMapdata(SelectedWard);
            // if (locationdetails.isEmpty) {
              // pr.show();
              List<Ward> warddetails =
                  await dbHelper.ward_basedDetails(SelectedWard);
              if (warddetails.length != null) {
                // pr.show();
                for (int i = 0; i < warddetails.length; i++) {
                  List<EntityRelation> wardslist = await tbClient
                      .getEntityRelationService()
                      .findByWardFrom(
                          warddetails.elementAt(i).wardid.toString());
                  if (wardslist.isNotEmpty) {
                    for (int j = 0; j < wardslist.length; j++) {
                      if (wardslist.elementAt(j).to.entityType.index == 5) {
                        List<EntityRelation> assetslist = await tbClient
                            .getEntityRelationService()
                            .findByWardFrom(
                                warddetails.elementAt(j).wardid.toString());

                        if (assetslist.isNotEmpty) {
                          for (int k = 0; k < assetslist.length; k++) {
                            List<EntityRelation> wardsdetailslist =
                                await tbClient
                                    .getEntityRelationService()
                                    .findByWardFrom(
                                        assetslist.elementAt(k).to.id!);

                            if (wardsdetailslist.isNotEmpty) {
                              for (int l = 0;
                                  l < wardsdetailslist.length;
                                  l++) {
                                Device relatedDevice = await tbClient
                                    .getDeviceService()
                                    .getDevice(wardsdetailslist
                                        .elementAt(l)
                                        .to
                                        .id
                                        .toString()) as Device;

                                List<String> myList = [];
                                myList.add("latitude");
                                myList.add("longitude");

                                List<AttributeKvEntry> responser;
                                responser = (await tbClient
                                    .getAttributeService()
                                    .getAttributeKvEntries(
                                        relatedDevice.id!, myList));

                                var rng = new Random();
                                var code = rng.nextInt(900000) + 100000;

                                if (responser.isNotEmpty) {
                                  // distance();
                                  DBHelper dbHelper = DBHelper();
                                  Mapdata mapdata = Mapdata(
                                      l + code + 1,
                                      relatedDevice.id!.id,
                                      relatedDevice.name,
                                      responser.first.getValue().toString(),
                                      responser.last.getValue().toString(),
                                      relatedDevice.type,
                                      SelectedWard);

                                  dbHelper.mapdata_add(mapdata);
                                  var sslat = double.parse(
                                      responser.first.getValue().toString());
                                  Lattitude = double.parse(
                                          responser.first.getValue().toString())
                                      .toString();
                                  var sslong = double.parse(
                                      responser.last.getValue().toString());

                                  var keyPair = {
                                    'Key': sslat.toString(),
                                    'value': relatedDevice.name.toString(),
                                  };
                                  listAnswers.add(keyPair);
                                  // someMap= {sslat.toString(),relatedDevice.name.toString()};

                                  setState(() {
                                    if (relatedDevice.type == "lumiNode") {
                                      _latLngListILM.add(LatLng(sslat, sslong));
                                    } else if (relatedDevice.type == "CCMS") {
                                      _latLngListCCMS
                                          .add(LatLng(sslat, sslong));
                                    } else if (relatedDevice.type ==
                                        "Gateway") {
                                      _latLngListGW.add(LatLng(sslat, sslong));
                                    }

                                    ssname = relatedDevice.name;
                                  });

                                  var _markers_1 = _latLngListILM
                                      .map((point) => Marker(
                                    point: point,
                                    width: 60,
                                    height: 60,
                                    builder: (context) => const Icon(
                                      Icons.location_pin,
                                      size: 60,
                                      color: Colors.red,
                                    ),
                                  ))
                                      .toList();
                                  var _markers_2 = _latLngListCCMS
                                      .map((point) => Marker(
                                    point: point,
                                    width: 60,
                                    height: 60,
                                    builder: (context) => const Icon(
                                      Icons.location_pin,
                                      size: 60,
                                      color: Colors.green,
                                    ),
                                  ))
                                      .toList();
                                  var _markers_3 = _latLngListGW
                                      .map((point) => Marker(
                                    point: point,
                                    width: 60,
                                    height: 60,
                                    builder: (context) => const Icon(
                                      Icons.location_pin,
                                      size: 60,
                                      color: Colors.purple,
                                    ),
                                  ))
                                      .toList();
                                  setState(() {
                                    _markers = _markers_1 + _markers_2 + _markers_3;
                                  });
                                  // pr.hide();
                                  _listenLocation();
                                }
                              }
                            }
                          }
                        }
                      }
                      else {
                        Device relatedDevice = await tbClient
                                .getDeviceService()
                                .getDevice(
                                    wardslist.elementAt(j).to.id.toString())
                            as Device;

                        List<String> myList = [];
                        myList.add("lattitude");
                        myList.add("longitude");

                        List<AttributeKvEntry> responser;
                        responser = (await tbClient
                            .getAttributeService()
                            .getAttributeKvEntries(relatedDevice.id!, myList));

                        var rng = new Random();
                        var code = rng.nextInt(900000) + 100000;

                        if (responser.isNotEmpty) {
                          // distance();
                          DBHelper dbHelper = DBHelper();
                          Mapdata mapdata = Mapdata(
                              j + code + 1,
                              relatedDevice.id!.id,
                              relatedDevice.name,
                              responser.first.getValue(),
                              responser.last.getValue(),
                              relatedDevice.type,
                              SelectedWard);

                          dbHelper.mapdata_add(mapdata);
                          var sslat = double.parse(responser.first.getValue());
                          Lattitude = double.parse(responser.first.getValue())
                              .toString();
                          var sslong = double.parse(responser.last.getValue());

                          var keyPair = {
                            'Key': sslat.toString(),
                            'value': relatedDevice.name.toString(),
                          };
                          listAnswers.add(keyPair);
                          // someMap= {sslat.toString(),relatedDevice.name.toString()};

                          setState(() {
                            if (relatedDevice.type == "lumiNode") {
                              _latLngListILM.add(LatLng(sslat, sslong));
                            } else if (relatedDevice.type == "CCMS") {
                              _latLngListCCMS.add(LatLng(sslat, sslong));
                            } else if (relatedDevice.type == "Gateway") {
                              _latLngListGW.add(LatLng(sslat, sslong));
                            }

                            ssname = relatedDevice.name;
                          });

                          var _markers_1 = _latLngListILM
                              .map((point) => Marker(
                                    point: point,
                                    width: 60,
                                    height: 60,
                                    builder: (context) => const Icon(
                                      Icons.location_pin,
                                      size: 60,
                                      color: Colors.red,
                                    ),
                                  ))
                              .toList();
                          var _markers_2 = _latLngListCCMS
                              .map((point) => Marker(
                                    point: point,
                                    width: 60,
                                    height: 60,
                                    builder: (context) => const Icon(
                                      Icons.location_pin,
                                      size: 60,
                                      color: Colors.green,
                                    ),
                                  ))
                              .toList();
                          var _markers_3 = _latLngListGW
                              .map((point) => Marker(
                                    point: point,
                                    width: 60,
                                    height: 60,
                                    builder: (context) => const Icon(
                                      Icons.location_pin,
                                      size: 60,
                                      color: Colors.purple,
                                    ),
                                  ))
                              .toList();
                          setState(() {
                            _markers = _markers_1 + _markers_2 + _markers_3;
                          });
                          // pr.hide();
                          _listenLocation();
                        }
                      }
                    }
                    // distance();
                  }
                }
                // pr.hide();
              } else {
                _markers.length = 0;
              }
              // pr.hide();
            // } else {
            //   // pr.show();
            //   for (int l = 0; l < locationdetails.length; l++) {
            //     var sslat = double.parse(
            //         locationdetails.elementAt(l).lattitude.toString());
            //     var sslong = double.parse(
            //         locationdetails.elementAt(l).longitude.toString());
            //
            //     var keyPair = {
            //       'Key': sslat.toString(),
            //       'value': locationdetails.elementAt(l).devicename,
            //     };
            //     listAnswers.add(keyPair);
            //     // someMap= {sslat.toString(),relatedDevice.name.toString()};
            //
            //     setState(() {
            //       if (locationdetails.elementAt(l).devicetype == "lumiNode") {
            //         _latLngListILM.add(LatLng(sslat, sslong));
            //       } else if (locationdetails.elementAt(l).devicetype ==
            //           "CCMS") {
            //         _latLngListCCMS.add(LatLng(sslat, sslong));
            //       } else if (locationdetails.elementAt(l).devicetype ==
            //           "Gateway") {
            //         _latLngListGW.add(LatLng(sslat, sslong));
            //       }
            //       ssname = locationdetails.elementAt(l).devicename.toString();
            //     });
            //
            //     var _markers_1 = _latLngListILM
            //         .map((point) => Marker(
            //               point: point,
            //               width: 60,
            //               height: 60,
            //               builder: (context) => const Icon(
            //                 Icons.location_pin,
            //                 size: 60,
            //                 color: Colors.red,
            //               ),
            //             ))
            //         .toList();
            //     var _markers_2 = _latLngListCCMS
            //         .map((point) => Marker(
            //               point: point,
            //               width: 60,
            //               height: 60,
            //               builder: (context) => const Icon(
            //                 Icons.location_pin,
            //                 size: 60,
            //                 color: Colors.green,
            //               ),
            //             ))
            //         .toList();
            //     var _markers_3 = _latLngListGW
            //         .map((point) => Marker(
            //               point: point,
            //               width: 60,
            //               height: 60,
            //               builder: (context) => const Icon(
            //                 Icons.location_pin,
            //                 size: 60,
            //                 color: Colors.purple,
            //               ),
            //             ))
            //         .toList();
            //     setState(() {
            //       _markers = _markers_1 + _markers_2 + _markers_3;
            //     });
            //     // pr.hide();
            //     _listenLocation();
            //   }
            // }
          }
          // pr.hide();
        } catch (e) {
          var message;
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callWatcher(context);
            }
          }
        }
      }
      else {
        callNetworkToast(no_network);
      }
    });
  }
  void callNetworkToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}

void refreshPage(context) {
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
}

Future<ThingsboardError> toThingsboardError(error, context,
    [StackTrace? stackTrace]) async {
  ThingsboardError? tbError;
  if (error.message == "Session expired!") {
    var status = loginThingsboard.callThingsboardLogin(context);
    if (status == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
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

Future<String> _getAddress(double? lat, double? lang) async {
  if (lat == null || lang == null) return "";
  final coordinates = Coordinates(lat, lang);
  List<Address> addresss = (await Geocoder.local
      .findAddressesFromCoordinates(coordinates)) as List<Address>;
  return "${addresss.elementAt(1).addressLine}";
}
