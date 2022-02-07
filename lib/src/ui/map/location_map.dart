import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/mapdata_model.dart';
import 'package:flutterlumin/src/localdb/model/ward_model.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/ilm_maintenance_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/replace_ilm_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

import '../installation/ccms/ccms_install_cam_screen.dart';
import '../installation/ilm/ilm_install_cam_screen.dart';

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
  double longitude = 0;
  double accuracy = 0;
  var accuvalue;
  var addvalue;
  String? _error;
  MapController _mapController = MapController();
  double _zoom = 12;
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
  List<LatLng> _latLngList2 = [];
  List<LatLng> _latLngList3 = [];
  List<Marker> _markers = [];
  List<CircleMarker> circleMarkers = [];
  late ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    current = widget.initialLabel;
    _listenLocation();
    callWatcher(context);
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

  distance() {
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
        totalDistance += calculateDistance(data[i]["lat"], data[i]["lng"],
            data[i + 1]["lat"], data[i + 1]["lng"]);
        if (totalDistance <= 5) {
          var distance = data[i + 1];
          combinedData.add(distance);
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
              mapController: _mapController,
              options: MapOptions(
                // swPanBoundary: LatLng(13, 77.5),
                // nePanBoundary: LatLng(13.07001, 77.58),
                // center: _latLngList[0],
                // bounds: LatLngBounds.fromPoints(_latLngList),
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
                                            marker.point.latitude
                                                .toString())]['value']
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
                                          Text("name : "),
                                          Text(
                                              listAnswers[listAnswers
                                                          .indexWhere((pair) =>
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
                      final textColor = active ? Colors.black : Colors.black;
                      final bgColor = active ? thbDblue : Colors.transparent;
                      if (index % 2 == 1) {
                        final activeDivider =
                            active || index ~/ 2 == current - 1;
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
                                _markers = _latLngListAll
                                    .map((point) => Marker(
                                          point: point,
                                          width: 60,
                                          height: 60,
                                          builder: (context) => const Icon(
                                            Icons.location_pin,
                                            size: 60,
                                            color: Colors.blueAccent,
                                          ),
                                        ))
                                    .toList();
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
                                _markers = _latLngList2
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
                                _markers = _latLngList3
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
                            child: Text(
                                ['All', 'ILM', 'CCMS', 'GW'][index ~/ 2],
                                style: TextStyle(color: textColor)),
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
                  setState(() {
                    _markers = [LatLng(lattitude, longitude)]
                        .map((point) => Marker(
                              point: point,
                              width: 60,
                              height: 60,
                              builder: (context) => Icon(
                                Icons.location_pin,
                                size: 60,
                                color: Colors.cyan,
                              ),
                            ))
                        .toList();
                  });
                },
                child: Container(
                  height: 55,
                  width: 55,
                  //margin: EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                    color: thbDblue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.my_location),
                ),
              ),
            ),
          )
        ]));
  }

  Future<void> popupOnClick(String string, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('deviceName', string);
    fetchDeviceDetails(string, context);
  }

  @override
  Future<Device?> fetchDeviceDetails(
      String deviceName, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          // Utility.progressDialog(context);
          pr.show();
          Device response;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();
          response = await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName) as Device;
          if (response != null) {
            DeviceCredentials deviceCredentials = (await tbClient
                    .getDeviceService()
                    .getDeviceCredentialsByDeviceId(response.id!.id!))
                as DeviceCredentials;
            if (deviceCredentials.credentialsId.length == 16) {
              if (response.type == ilm_deviceType) {
                fetchSmartDeviceDetails(
                    deviceName, response.id!.id.toString(), context);
              } else if (response.type == ccms_deviceType) {
                fetchCCMSDeviceDetails(
                    deviceName, response.id!.id.toString(), context);
              } else if (response.type == Gw_deviceType) {
              } else {
                pr.hide();
                // Navigator.pop(context);
                Fluttertoast.showToast(
                    msg: "Device Details Not Found",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);
              }
            } else {
              // Navigator.pop(context);
              pr.hide();
              Fluttertoast.showToast(
                  msg:
                      "Device Credentials are invalid, Device not despatched properly",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
            }
          } else {
            // Navigator.pop(context);
            pr.hide();
            Fluttertoast.showToast(
                msg: device_toast_msg + deviceName + device_toast_notfound,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => dashboard_screen()));
          }
        } catch (e) {
          // Navigator.pop(context);
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              fetchDeviceDetails(deviceName, context);
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
          }
        }
      } else {
        Fluttertoast.showToast(
            msg: no_network,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    });
  }

  @override
  Future<Device?> fetchCCMSDeviceDetails(
      String deviceName, String string, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          pr.show();
          Device response;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          response = (await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName)) as Device;

          var relationDetails = await tbClient
              .getEntityRelationService()
              .findInfoByTo(response.id!);

          if (relationDetails.length.toString() == "0") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var SelectedRegion = prefs.getString("SelectedRegion").toString();
            if (SelectedRegion != "null") {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => ccmscaminstall()));
            } else {
              // Navigator.pop(context);
              pr.hide();
              Fluttertoast.showToast(
                  msg: "Kindly Choose your Region, Zone and Ward to Install",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
              // refreshPage(context);
            }
          } else {}
          pr.hide();
        } catch (e) {
          pr.hide();
        }
      }
    });
  }

  @override
  Future<Device?> fetchSmartDeviceDetails(
      String deviceName, String deviceid, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          // Utility.progressDialog(context);
          pr.show();
          Device response;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          response = (await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName)) as Device;

          var relationDetails = await tbClient
              .getEntityRelationService()
              .findInfoByTo(response.id!);

          List<String> firstmyList = [];
          firstmyList.add("lmp");

          SharedPreferences prefs = await SharedPreferences.getInstance();

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
          myList.add("lampWatts");
          myList.add("active");

          List<BaseAttributeKvEntry> responser;

          responser = (await tbClient
                  .getAttributeService()
                  .getAttributeKvEntries(response.id!, myList))
              as List<BaseAttributeKvEntry>;

          prefs.setString(
              'deviceStatus', responser.first.kv.getValue().toString());
          prefs.setString(
              'deviceWatts', responser.last.kv.getValue().toString());
          prefs.setString(
              'devicetimeStamp', responser.first.lastUpdateTs.toString());

          List<String> myLister = [];
          // myLister.add("landmark");
          myLister.add("location");

          List<AttributeKvEntry> responserse;

          responserse = (await tbClient
                  .getAttributeService()
                  .getAttributeKvEntries(response.id!, myLister))
              as List<AttributeKvEntry>;

          if (responserse.length != "0") {
            prefs.setString(
                'location', responserse.first.getValue().toString());
            prefs.setString('deviceId', deviceid);
            prefs.setString('deviceName', deviceName);

            List<String> versionlist = [];
            versionlist.add("version");

            List<AttributeKvEntry> version_responserse;

            version_responserse = (await tbClient
                    .getAttributeService()
                    .getAttributeKvEntries(response.id!, versionlist))
                as List<AttributeKvEntry>;

            if (version_responserse.length == 0) {
              prefs.setString('version', "0");
            } else {
              prefs.setString('version', version_responserse.first.getValue());
            }

            if (relationDetails.length.toString() == "0") {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var SelectedRegion = prefs.getString("SelectedRegion").toString();
              if (SelectedRegion != "null") {
                List<String> myList = [];
                myList.add("faulty");
                List<AttributeKvEntry> responser;

                responser = (await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(response.id!, myList))
                    as List<AttributeKvEntry>;

                var faultyDetails = false;
                if (responser.length == 0) {
                  faultyDetails = false;
                } else {
                  faultyDetails = responser.first.getValue();
                }

                if (faultyDetails == false) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => ilmcaminstall()));
                } else {
                  // Navigator.pop(context);
                  pr.hide();
                  Fluttertoast.showToast(
                      msg:
                          "Device Currently in Faulty State Unable to Install.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 16.0);

                  // refreshPage(context);
                }
              } else {
                // Navigator.pop(context);
                pr.hide();
                Fluttertoast.showToast(
                    msg: "Kindly Choose your Region, Zone and Ward to Install",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);

                // refreshPage(context);
              }
            } else {
              // Navigator.pop(context);
              pr.hide();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => MaintenanceScreen()));
            }
          } else {
            // Navigator.pop(context);
            pr.hide();
            calltoast("Device Details Not Found");

            // refreshPage(context);
          }
        } catch (e) {
          // Navigator.pop(context);
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              fetchDeviceDetails(deviceName, context);
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
          }
        }
      } else {
        Fluttertoast.showToast(
            msg: no_network,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    });
  }

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
            List<Ward> warddetails =
                await dbHelper.ward_basedDetails(SelectedWard);
            if (warddetails.length != null) {
              for (int i = 0; i < warddetails.length; i++) {
                List<EntityRelation> wardslist = await tbClient
                    .getEntityRelationService()
                    .findByWardFrom(warddetails.elementAt(i).wardid.toString());
                if (wardslist.isNotEmpty) {
                  for (int j = 0; j < wardslist.length; j++) {
                    Device relatedDevice = await tbClient
                            .getDeviceService()
                            .getDevice(wardslist.elementAt(j).to.id.toString())
                        as Device;

                    List<String> myList = [];
                    myList.add("lattitude");
                    myList.add("longitude");

                    List<BaseAttributeKvEntry> responser;
                    responser = (await tbClient
                            .getAttributeService()
                            .getAttributeKvEntries(relatedDevice.id!, myList))
                        as List<BaseAttributeKvEntry>;

                    if (responser.isNotEmpty) {
                      // distance();
                      DBHelper dbHelper = DBHelper();
                      Mapdata mapdata = Mapdata(
                          j,
                          relatedDevice.id!.id,
                          relatedDevice.name,
                          responser.first.kv.getValue(),
                          responser.last.kv.getValue(),
                          relatedDevice.type,
                          SelectedWard);

                      dbHelper.mapdata_add(mapdata);
                      var sslat = double.parse(responser.first.kv.getValue());
                      var sslong = double.parse(responser.last.kv.getValue());

                      var keyPair = {
                        'Key': sslat.toString(),
                        'value': relatedDevice.name.toString(),
                      };
                      listAnswers.add(keyPair);
                      // someMap= {sslat.toString(),relatedDevice.name.toString()};

                      setState(() {
                        _latLngListILM.add(LatLng(sslat, sslong));
                        _latLngListAll.add(LatLng(sslat, sslong));
                        ssname = relatedDevice.name;
                      });
                    }
                  }
                  _markers = _latLngListAll
                      .map((point) => Marker(
                            point: point,
                            width: 45,
                            height: 45,
                            anchorPos: AnchorPos.align(AnchorAlign.top),
                            builder: (context) => const Icon(
                              Icons.place,
                              size: 45,
                              color: Colors.green,
                            ),
                          ))
                      .toList();

                  distance();
                } else {}
              }
            }
          } else {
            //show toast
          }
        } catch (e) {
          var message;
          if (message == session_expired) {}
        }
      }
    });
  }
}

Future<String> _getAddress(double? lat, double? lang) async {
  if (lat == null || lang == null) return "";
  final coordinates = Coordinates(lat, lang);
  List<Address> addresss = (await Geocoder.local
      .findAddressesFromCoordinates(coordinates)) as List<Address>;
  return "${addresss.elementAt(1).addressLine}";
}
