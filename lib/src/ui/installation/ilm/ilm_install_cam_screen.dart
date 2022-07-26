import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/model/device_models.dart';
import 'package:flutterlumin/src/thingsboard/model/entity_group_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/entity_group_id.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localdb/db_helper.dart';

import '../../../localdb/model/region_model.dart';
import '../../../localdb/model/ward_model.dart';
import '../../../thingsboard/error/thingsboard_error.dart';
import '../../../thingsboard/model/id/entity_id.dart';
import '../../../thingsboard/model/model.dart';
import '../../dashboard/dashboard_screen.dart';

import 'package:poly_geofence_service/models/lat_lng.dart';
import 'package:poly_geofence_service/models/poly_geofence.dart';
import 'package:poly_geofence_service/poly_geofence_service.dart';

// ILM Installation screen, Geo fence validation is implemeted, location accuracy
// is implemented, Based on the user selected device, we need to capture the user
// photo, and upload the image url to the cloud based on the device name,
// successfull message need to shown to user

class ilmcaminstall extends StatefulWidget {
  const ilmcaminstall() : super();

  @override
  ilmcaminstallState createState() => ilmcaminstallState();
}

class ilmcaminstallState extends State<ilmcaminstall> {
  String DeviceName = "0";
  var imageFile;
  var accuvalue;
  var Adressaccuvalue;

  String address = "";
  String SelectedWard = "0";
  double lattitude = 0;
  double longitude = 0;
  double accuracy = 0;

  String? _error;
  late ProgressDialog pr;
  List<double>? _latt = [];
  String Lattitude = "0";
  String Longitude = "0";
  String geoFence = "false";
  var counter = 0;
  var caclsss = 0;

  late bool visibility = false;
  late bool viewvisibility = true;

  final _streamController = StreamController<PolyGeofence>();

  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();

  late Timer _timer;
  int _start = 20;

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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print('location: ${location.toJson()}');
    accuracy = location.accuracy;
    Lattitude = location.latitude.toString();
    Longitude = location.longitude.toString();
    accuvalue = accuracy.toString().split(".");

    _getAddress(location.latitude, location.longitude).then((value) {
      setState(() {
        address = value;
        prefs.setString("location", value);
      });
    });

    var insideArea;

    if (caclsss == 0) {
      startTimer();
    }
    caclsss++;

    if (geoFence == "true") {
      for (int i = 0; i < _polyGeofenceList[0].polygon.length; i++) {
        insideArea = _checkIfValidMarker(
            LatLng(location.latitude, location.longitude),
            _polyGeofenceList[0].polygon);
        if (insideArea == true) {
          if (accuracy <= 10) {
            _getAddress(location.latitude, location.longitude).then((value) {
              setState(() {
                address = value;
              });
            });
          }
          else {
            setState(() {
              visibility = false;
            });
            Fluttertoast.showToast(
                msg: app_fetch_loc,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
          callPolygonStop();
        } else {
          setState(() {
            visibility = false;
          });
          if (counter == 0 || counter == 3 || counter == 6 || counter == 9) {
            Fluttertoast.showToast(
                msg: app_loc_ward,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
            counter++;
          }
          callPolygonStop();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
        }
      }
    } else {
      if (accuracy <= 10) {
        callPolygonStop();
        _timer.cancel();
        _getAddress(location.latitude, location.longitude).then((value) {
          setState(() {
            visibility = true;
            address = value;
          });
        });
      }
    }

    if (caclsss == 20) {
      _timer.cancel();
      callPolygonStop();
      setState(() {
        visibility = true;
        viewvisibility = false;
      });
    }
    Adressaccuvalue = address.toString().split(",");
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          if (accuracy <= 10) {
            timer.cancel();
            callPolygonStop();
            setState(() {
              visibility = true;
              viewvisibility = false;
            });
          } else {
            timer.cancel();
            callPolygonStop();
            setState(() {
              visibility = true;
              viewvisibility = false;
            });
          }
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
    Adressaccuvalue = address.toString().split(",");
  }

  Future<void> callPolygons() async {}

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
    SelectedWard = prefs.getString("SelectedWard").toString();
    geoFence = prefs.getString('geoFence').toString();
    // FirmwareVersion = prefs.getString("firmwareVersion").toString();
    setState(() {
      DeviceName = DeviceName;
      SelectedWard = SelectedWard;
      geoFence = geoFence;
      // FirmwareVersion = FirmwareVersion;
    });
  }

  @override
  void initState() {
    super.initState();
    // getLocation();
    DeviceName = "";
    SelectedWard = "";
    getSharedPrefs();
    checkGps(context);
    setUpLogs();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _polyGeofenceService.start();
      _polyGeofenceService
          .addPolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
      _polyGeofenceService.addLocationChangeListener(_onLocationChanged);
      _polyGeofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      _polyGeofenceService.addStreamErrorListener(_onError);
      _polyGeofenceService.start(_polyGeofenceList).catchError(_onError);
    });

    if (geoFence == "true") {
      CallCoordinates(context);
    } else {
      Fluttertoast.showToast(
          msg: app_geofence_nfound,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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
              builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
          return true;
        },
        child: Scaffold(
            body: Container(
                padding: EdgeInsets.fromLTRB(15, 60, 15, 0),
                decoration: const BoxDecoration(
                    color: thbDblue,
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                alignment: Alignment.center,
                child: Column(children: [
                  Container(
                    width: width / 1.25,
                    height: height / 1.25,
                    child: imageFile != null
                        ? Image.file(File(imageFile.path))
                        : Container(
                            decoration: BoxDecoration(color: Colors.white),
                            width: 200,
                            height: 200,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            )),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                      visible: visibility,
                      child: Container(
                          width: double.infinity,
                          child: TextButton(
                              child: const Text(app_com_install,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.all(20)),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ))),
                              onPressed: () {
                                // Utility.progressDialog(context);
                                Utility.isConnected().then((value) async {
                                  if (value) {
                                    if (imageFile != null) {
                                        pr.show();
                                        if (geoFence == false) {
                                          callILMInstallation(context, imageFile,
                                              DeviceName, SelectedWard);
                                        } else {
                                          CallGeoFenceListener(context);
                                        }
                                    } else {
                                      pr.hide();
                                      Fluttertoast.showToast(
                                          msg: app_device_image_cap,
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          fontSize: 16.0);
                                    }
                                  } else {
                                    call_no_network_toast(no_network);
                                    pr.hide();
                                  }
                                });
                              })))
                ]))));
  }

  void checkGps(BuildContext context) async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      pr.hide();
      onGpsAlert();
    } else {
      _openCamera(context);
    }
  }

  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 480,
        maxWidth: 640,
        imageQuality: 10,
        preferredCameraDevice: CameraDevice.rear);
    setState(() {
      if (pickedFile != null) {
        imageFile = pickedFile;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => dashboard_screen(selectedPage: 0)),
        );
      }
    });

  }

  Future<void> CallGeoFenceListener(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var geoFence = prefs.getString('geoFence').toString();
    if (geoFence == "true") {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _polyGeofenceService.start();
        _polyGeofenceService.addPolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
        _polyGeofenceService.addLocationChangeListener(_onLocationChanged);
        _polyGeofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
        _polyGeofenceService.addStreamErrorListener(_onError);
        _polyGeofenceService.start(_polyGeofenceList).catchError(_onError);
      });
    } else {
      visibility = false;
      Fluttertoast.showToast(
          msg: app_geofence_nfound,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
      callILMInstallation(context, imageFile, DeviceName, SelectedWard);
    }
  }

  Future<void> callILMInstallation(
      context, imageFile, DeviceName, SelectedWard) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceID = prefs.getString('deviceId').toString();
    String deviceName = prefs.getString('deviceName').toString();
    String SelectedRegion = prefs.getString('SelectedRegion').toString();
    String SelectedZone = prefs.getString('SelectedZone').toString();
    //newly added by dev
    String Createdby = prefs.getString("username").toString();
    // String FirmwareVersion = prefs.getString("firmwareVersion").toString();

    var DevicecurrentFolderName = "";
    var DevicemoveFolderName = "";

    var status = await Permission.location.status;
    if (status.isGranted) {
      var versionCompatability = false;

      //newlly added by dev for landmark purpose
      var latter = double.parse(Lattitude);
      var longer = double.parse(Longitude);


      _getAddress(latter, longer).then((value) {
        setState(() {
          address = value;
          prefs.setString("location", value);
        });
      });


      Utility.isConnected().then((value) async {
        if (value) {
          pr.show();
          try {
            var tbClient =
                ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
            tbClient.smart_init();

            Device response;
            response = (await tbClient
                .getDeviceService()
                .getTenantDevice(deviceName)) as Device;
            if (imageFile != null) {
              if (response != null) {
                DeviceCredentials deviceCredentials = await tbClient
                    .getDeviceService()
                    .getDeviceCredentialsByDeviceId(
                        response.id!.id.toString()) as DeviceCredentials;

                if (deviceCredentials.credentialsId.length == 16) {
                  /* List<String> myList = [];
                   myList.add("faulty");
                   List<AttributeKvEntry> responser;

                   responser = (await tbClient
                       .getAttributeService()
                       .getAttributeKvEntries(response.id!, myList));
                  */
                  var faultyDetails = false;
                  /* if (responser.isEmpty) {
                     faultyDetails = false;
                   } else {
                     var datas = responser.first.getValue();
                     faultyDetails = datas;
                   }*/

                  DBHelper dbHelper = DBHelper();
                  var regionid;
                  List<Region> regiondetails = await dbHelper
                      .region_name_regionbasedDetails(SelectedRegion);
                  if (regiondetails.length != "0") {
                    regionid = regiondetails.first.regionid;
                  }

                  /* try {
                    List<String> myfirmList = [];
                    myfirmList.add("firmware_versions");

                    List<AttributeKvEntry> faultresponser;

                    faultresponser = (await tbClient
                        .getAttributeService()
                        .getFirmAttributeKvEntries(regionid, myfirmList));

                    if (faultresponser.length != 0) {
                      var firmwaredetails =
                          faultresponser.first.getValue().toString();
                      final decoded = jsonDecode(firmwaredetails) as Map;
                      var firmware_versions = decoded['firmware_version'];

                      if (firmware_versions
                          .toString()
                          .contains(FirmwareVersion)) { */

                  versionCompatability = true;

                  /*     } else {
                         versionCompatability = false;
                       }
                     }
                   } catch (e) {
                     var message = toThingsboardError(e, context);
                   } */

                  if (faultyDetails == false) {
                    if (SelectedWard != "Ward") {
                      if (lattitude.toString() != null) {
                        if (versionCompatability == true) {
                          DBHelper dbHelper = DBHelper();
                          List<Ward> warddetails =
                              await dbHelper.ward_basedDetails(SelectedWard);
                          if (warddetails.length != "0") {
                            warddetails.first.wardid;

                            var oldasset;

                            PageLink pageLink = new PageLink(250);
                            pageLink.page = 0;
                            pageLink.pageSize = 250;

                            PageData<Asset> assetPagedetails = await tbClient
                                .getAssetService()
                                .getUsertypeAssets(pageLink);

                            if (assetPagedetails.data.length != 0) {
                              for (int i = 0;
                                  i < assetPagedetails.data.length;
                                  i++) {
                                if (assetPagedetails.data
                                        .elementAt(i)
                                        .name
                                        .toString() ==
                                    SelectedWard + "-" + "ILM") {
                                  oldasset =
                                      assetPagedetails.data.elementAt(i).id!.id;
                                  break;
                                }
                              }
                              if (oldasset == null) {
                                Asset newasset = Asset(
                                    SelectedWard + "-" + "ILM", "node-cluster");
                                Asset savedasset = await tbClient
                                    .getAssetService()
                                    .saveAsset(newasset);
                                oldasset = savedasset.id!.id;
                              }
                            } else {
                              Asset newasset = Asset(
                                  SelectedWard + "-" + "ILM", "node-cluster");
                              Asset savedasset = await tbClient
                                  .getAssetService()
                                  .saveAsset(newasset);
                              oldasset = savedasset.id!.id;
                            }

                            Map<String, dynamic> lfromId = {
                              'entityType': 'ASSET',
                              'id': warddetails.first.wardid
                            };

                            Map<String, dynamic> ltoId = {
                              'entityType': 'ASSET',
                              'id': oldasset
                            };

                            EntityRelation fentityRelation = EntityRelation(
                                from: EntityId.fromJson(lfromId),
                                to: EntityId.fromJson(ltoId),
                                type: "Contains",
                                typeGroup: RelationTypeGroup.COMMON);

                            Future<EntityRelation> entityRelations = tbClient
                                .getEntityRelationService()
                                .saveRelation(fentityRelation);

                            Map<String, dynamic> fromId = {
                              'entityType': 'ASSET',
                              'id': oldasset
                            };
                            Map<String, dynamic> toId = {
                              'entityType': 'DEVICE',
                              'id': response.id!.id
                            };

                            EntityRelation entityRelation = EntityRelation(
                                from: EntityId.fromJson(fromId),
                                to: EntityId.fromJson(toId),
                                type: "Contains",
                                typeGroup: RelationTypeGroup.COMMON);

                            Future<EntityRelation> entityRelationss = tbClient
                                .getEntityRelationService()
                                .saveRelation(entityRelation);

                            Map data = {
                              'landmark': address,
                              'latitude': Lattitude.toString(),
                              'longitude': Longitude.toString(),
                              'accuracy': accuracy.toString(),
                              'lampWatts': "",
                              'zoneName': SelectedZone,
                              'wardName': SelectedWard,
                              'boardNumber':DeviceName,
                              'InstallBy':Createdby,
                              'InstalledOn':DateTime.now().millisecondsSinceEpoch,
                            };

                            var saveAttributes = await tbClient
                                .getAttributeService()
                                .saveDeviceAttributes(
                                    response.id!.id!, "SERVER_SCOPE", data);

                            List<EntityGroupId> currentdeviceresponse;
                            currentdeviceresponse = await tbClient
                                .getEntityGroupService()
                                .getEntityGroupsForFolderEntity(
                                    response.id!.id!);

                            if (currentdeviceresponse != null) {
                              var firstdetails = await tbClient
                                  .getEntityGroupService()
                                  .getEntityGroup(
                                      currentdeviceresponse.first.id!);

                              if (firstdetails!.name.toString() != "All") {
                                DevicecurrentFolderName =
                                    currentdeviceresponse.first.id!;
                              }
                              var seconddetails = await tbClient
                                  .getEntityGroupService()
                                  .getEntityGroup(
                                      currentdeviceresponse.last.id!);
                              if (seconddetails!.name.toString() != "All") {
                                DevicecurrentFolderName =
                                    currentdeviceresponse.last.id!;
                              }

                              List<EntityGroupInfo> entitygroups;
                              entitygroups = await tbClient
                                  .getEntityGroupService()
                                  .getEntityGroupsByFolderType();

                              if (entitygroups != null) {
                                for (int i = 0; i < entitygroups.length; i++) {
                                  if (entitygroups.elementAt(i).name ==
                                      FlavorConfig.instance.variables[
                                          "ILMDeviceInstallationFolder"]) {
                                    DevicemoveFolderName = entitygroups
                                        .elementAt(i)
                                        .id!
                                        .id!
                                        .toString();
                                  }
                                }

                                List<String> myList = [];
                                myList.add(response.id!.id!);

                                var remove_response = tbClient
                                    .getEntityGroupService()
                                    .removeEntitiesFromEntityGroup(
                                        DevicecurrentFolderName, myList);

                                var add_response = tbClient
                                    .getEntityGroupService()
                                    .addEntitiesToEntityGroup(
                                        DevicemoveFolderName, myList);

                                final bytes =
                                    File(imageFile!.path).readAsBytesSync();
                                String img64 = base64Encode(bytes);

                                postRequest(context, img64, DeviceName);
                                pr.hide();
                              } else {
                                pr.hide();
                                Fluttertoast.showToast(
                                    msg: app_unable_folder,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                    fontSize: 16.0);
                                callPolygonStop();
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            dashboard_screen(selectedPage: 0)));
                              }
                            } else {
                              pr.hide();
                              calltoast(deviceName);
                              callPolygonStop();
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          dashboard_screen(selectedPage: 0)));
                            }
                          } else {
                            pr.hide();
                            calltoast(deviceName);
                            callPolygonStop();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        dashboard_screen(selectedPage: 0)));
                          }
                        } else {
                          /* FlutterLogs.logInfo(
                              "ilm_installation_page",
                              "ilm_installation",
                              "ILM Device Not authorized to Install");*/
                          pr.hide();
                          callPolygonStop();
                          Fluttertoast.showToast(
                              msg: app_compat_one +
                                  SelectedRegion +
                                  app_compat_two,
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 16.0);

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      dashboard_screen(selectedPage: 0)));
                        }
                      } else {
                        pr.hide();
                        Fluttertoast.showToast(
                            msg: app_fetch_loc,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0);
                      }
                    } else {
                      pr.hide();
                      Fluttertoast.showToast(
                          msg: app_reg_selec,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0);
                    }
                  } else {
                    pr.hide();
                    callPolygonStop();
                    Fluttertoast.showToast(
                        msg: app_device_faulty,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 16.0);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
                  }
                } else {
                  pr.hide();
                  /*FlutterLogs.logInfo(
                      "ilm_installation_page",
                      "ilm_installation",
                      "ILM Device Invalid Credentials Server Exception");*/
                  callPolygonStop();
                  calltoast(app_dev_cred_improper);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
                }
              } else {
                /*FlutterLogs.logInfo("ilm_installation_page", "ilm_installation",
                    "ILM Device details not found Exception");*/
                pr.hide();
                calltoast(device_toast_msg + DeviceName + app_dev_nfound_two);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
              }
            } else {
              /*FlutterLogs.logInfo("ilm_installation_page", "ilm_installation",
                  "ILM Device Invalid Image to Server Exception");*/
              pr.hide();
              Fluttertoast.showToast(
                  msg: app_device_image_cap,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
            }
          } catch (e) {
            callPolygonStop();
            /*FlutterLogs.logInfo("ilm_installation_page", "ilm_installation",
                "ILM Device Installation Exception");*/
            pr.hide();
            var message = toThingsboardError(e, context);
            if (message == session_expired) {
              var status = loginThingsboard.callThingsboardLogin(context);
              if (status == true) {
                callILMInstallation(
                    context, imageFile, DeviceName, SelectedWard);
              }
            } else {
              calltoast(deviceName);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
            }
          }
        } else {
          pr.hide();
          noInternetToast(no_network);
        }
      });
    } else {
      pr.hide();
      openAppSettings();
      // openAppSettings();
    }
  }

  void noInternetToast(String msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  void showMyDialog(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Container(
                  height: height / 1.25,
                  child: Column(children: [
                    Text(
                      "LumiNode " + ' $DeviceName ',
                      style: const TextStyle(
                          fontSize: 20.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: thbDblue),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 250,
                      height: 350,
                      child: imageFile != null
                          ? Image.file(File(imageFile.path))
                          : Container(
                              decoration: BoxDecoration(color: Colors.white),
                              width: 200,
                              height: 200,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[800],
                              )),
                    ),
                    SizedBox(height: 10),
                    Text(
                      Adressaccuvalue[0].toString(),
                      style: const TextStyle(
                          fontSize: 16.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'With ' + accuvalue[0].toString() + "m Accuracy",
                      style: const TextStyle(
                          fontSize: 16.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10),
                    Text(
                      app_dev_inst_success,
                      style: const TextStyle(
                          fontSize: 22.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 10),
                  ])));
        });
  }

  void call_no_network_toast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
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

  Future<String> _getAddress(double? lat, double? lang) async {
    if (lat == null || lang == null) return "";
    final coordinates = new Coordinates(lat, lang);
    List<Address> addresss =
        (await Geocoder.local.findAddressesFromCoordinates(coordinates));
    setState(() {
      address = addresss.elementAt(1).addressLine.toString();
    });
    return "${addresss.elementAt(1).addressLine}";
  }

  Future<http.Response> postRequest(context, imageFile, DeviceName) async {
    var response;
    try {
      Uri myUri = Uri.parse(localAPICall);

      Map data = {'img': imageFile, 'name': DeviceName};
      var body = json.encode(data);

      response = await http.post(myUri,
          headers: {"Content-Type": "application/json"}, body: body);
      print("${response.statusCode}");

      if (response.statusCode.toString() == "200") {
        callPolygonStop();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
        showMyDialog(context);
      } else {}
      return response;
    } catch (e) {
      callPolygonStop();
      /*FlutterLogs.logInfo("ilm_installation_page", "ilm_installation",
          "Captured Image Upload Error");*/
      await pr.hide();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
      Fluttertoast.showToast(
          msg: app_dev_img_uperror,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
      return response;
    }
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    /*FlutterLogs.logInfo("ilm_installation_page", "ilm_installation",
        "ILM Device Installation Server Error");*/
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

  void onGpsAlert(){
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title:  const Text("Location not available"),
          content: const Text('Please make sure you enable location and try again'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("Ok"),
              onPressed: (){
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => dashboard_screen(selectedPage: 0)),
                );
              },
            )
          ],
        )
    );
  }

}
