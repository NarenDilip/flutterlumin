import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/model/device_models.dart';
import 'package:flutterlumin/src/thingsboard/model/entity_group_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/entity_group_id.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localdb/db_helper.dart';
import '../../../localdb/model/ward_model.dart';
import '../../../thingsboard/error/thingsboard_error.dart';
import '../../../thingsboard/model/id/entity_id.dart';
import '../../../thingsboard/model/model.dart';
import '../../dashboard/dashboard_screen.dart';

class ilmcaminstall extends StatefulWidget {
  const ilmcaminstall({Key? key}) : super(key: key);

  @override
  ilmcaminstallState createState() => ilmcaminstallState();
}

class ilmcaminstallState extends State<ilmcaminstall> {
  String DeviceName = "0";
  var imageFile;
  var accuvalue;
  var addvalue;
  LocationData? currentLocation;
  String address = "";
  String SelectedWard = "0";
  double lattitude = 0;
  double longitude = 0;
  double accuracy = 0;
  String addresss = "0";
  String? _error;
  late ProgressDialog pr;
  List<double>? _latt = [];

  final Location locations = Location();
  LocationData? _location;
  StreamSubscription<LocationData>? _locationSubscription;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DeviceName = prefs.getString('deviceName').toString();
    SelectedWard = prefs.getString("SelectedWard").toString();

    setState(() {
      DeviceName = DeviceName;
      SelectedWard = SelectedWard;
    });
  }

  @override
  void initState() {
    super.initState();
    // getLocation();
    DeviceName = "";
    SelectedWard = "";
    _openCamera(context);
    getSharedPrefs();
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
              longitude = _location!.latitude!;
              accuracy = _location!.accuracy!;
              // addresss = addresss;
            } else {
              _locationSubscription?.cancel();

              accuvalue = accuracy.toString().split(".");
              addvalue = value.toString().split(",");

              callReplacementComplete(
                  context, imageFile, DeviceName, SelectedWard);
            }
          });
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    pr = ProgressDialog(
        context, type: ProgressDialogType.Normal, isDismissible: false);
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

    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => dashboard_screen()));
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
                  SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      child: TextButton(
                          child: Text("Complete Installation",
                              style: const TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
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
                            if(imageFile != null) {
                              pr.show();
                              _listenLocation();
                            }else{
                              pr.hide();
                              Fluttertoast.showToast(
                                  msg:
                                  "Invalid Image Capture, Please recapture and try installation",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  fontSize: 16.0);
                            }
                          }))
                ]))));
  }

  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 480,
        maxWidth: 640,
        imageQuality: 25,
        preferredCameraDevice: CameraDevice.rear);
    setState(() {
      imageFile = pickedFile;
    });
  }

  Future<void> callReplacementComplete(
      context, imageFile, DeviceName, SelectedWard) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceID = prefs.getString('deviceId').toString();
    String deviceName = prefs.getString('deviceName').toString();

    var DevicecurrentFolderName = "";
    var DevicemoveFolderName = "";

    Utility.isConnected().then((value) async {
      if (value) {
        // Utility.progressDialog(context);
        pr.show();
        try {
          var tbClient = ThingsboardClient(serverUrl);
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
                  if (SelectedWard != "Ward") {
                    if (lattitude.toString() != null) {
                      DBHelper dbHelper = DBHelper();
                      List<Ward> warddetails = await dbHelper
                          .ward_basedDetails(SelectedWard) as List<Ward>;
                      if (warddetails.length != "0") {
                        warddetails.first.wardid;

                        Map<String, dynamic> fromId = {
                          'entityType': 'ASSET',
                          'id': warddetails.first.wardid
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

                        Future<EntityRelation> entityRelations = tbClient
                            .getEntityRelationService()
                            .saveRelation(entityRelation);

                        Map data = {
                          'landmark': addresss,
                          'lattitude': lattitude.toString(),
                          'longitude': longitude.toString(),
                          'accuracy': accuracy.toString()
                        };

                        var saveAttributes = await tbClient
                            .getAttributeService()
                            .saveDeviceAttributes(
                                response.id!.id!, "SERVER_SCOPE", data);

                        List<EntityGroupId> currentdeviceresponse;
                        currentdeviceresponse = await tbClient
                            .getEntityGroupService()
                            .getEntityGroupsForFolderEntity(response.id!.id!);

                        if (currentdeviceresponse != null) {
                          var firstdetails = await tbClient
                              .getEntityGroupService()
                              .getEntityGroup(currentdeviceresponse.first.id!);

                          if (firstdetails!.name.toString() != "All") {
                            DevicecurrentFolderName =
                                currentdeviceresponse.first.id!;
                          }
                          var seconddetails = await tbClient
                              .getEntityGroupService()
                              .getEntityGroup(currentdeviceresponse.last.id!);
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
                                  ILMDeviceInstallationFolder) {
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
                            // Navigator.pop(context);
                            pr.hide();
                            Fluttertoast.showToast(
                                msg: "Unable to Find Folder Details",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                fontSize: 16.0);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        dashboard_screen()));
                          }
                        } else {
                          // Navigator.pop(context);
                          pr.hide();
                          calltoast(deviceName);
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      dashboard_screen()));
                        }
                      } else {
                        // Navigator.pop(context);
                        pr.hide();
                        calltoast(deviceName);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                dashboard_screen()));
                      }
                    } else {
                      // Navigator.pop(context);
                      pr.hide();
                      Fluttertoast.showToast(
                          msg:
                              "Please wait to load lattitude, longitude Details to Install.",
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
                            "Kindly Select the Region, Zone and Ward Details to Install.",
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
                          "Device Currently in Faulty State Unable to Install.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 16.0);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => dashboard_screen()));
                }
              } else {
                // Navigator.pop(context);
                pr.hide();
                calltoast(deviceName);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => dashboard_screen()));
              }
            } else {
              // Navigator.pop(context);
              pr.hide();
              calltoast(deviceName);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => dashboard_screen()));
            }
          } else {
            // Navigator.pop(context);
            pr.hide();
            Fluttertoast.showToast(
                msg:
                    "Invalid Image Capture, Please recapture and try installation",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        } catch (e) {
          // Navigator.pop(context);
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callReplacementComplete(
                  context, imageFile, DeviceName, SelectedWard);
            }
          } else {
            calltoast(deviceName);
            // Navigator.pop(context);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => dashboard_screen()));
          }
        }
      }
    });
  }

  void showMyDialog(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: Container(
              height: height/1.25,
                child: Column(
                    children: [
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
                         addvalue[0].toString() +","+ addvalue[1].toString(),
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
                        "Installed Successfully",
                        style: const TextStyle(
                            fontSize: 22.0,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10),
                    ])));
      }
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

  Future<LocationData?> _getLocation() async {
    Location location = Location();
    LocationData _locationData;
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();

    return _locationData;
  }

  Future<String> _getAddress(double? lat, double? lang) async {
    if (lat == null || lang == null) return "";
    final coordinates = new Coordinates(lat, lang);
    List<Address> addresss = (await Geocoder.local
        .findAddressesFromCoordinates(coordinates)) as List<Address>;
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
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => dashboard_screen()));
        showMyDialog(context);
      } else {}
      return response;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Device Installation Image Upload Error",
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
}