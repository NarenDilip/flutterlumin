import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/model/device_models.dart';
import 'package:flutterlumin/src/thingsboard/model/entity_group_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/entity_group_id.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/components/rounded_button.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localdb/db_helper.dart';
import '../../../localdb/model/ward_model.dart';
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
  LocationData? currentLocation;
  String address = "";
  String SelectedWard = "0";
  String lattitude = "0";
  String longitude = "0";
  String accuracy = "0";
  String addresss = "0";

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DeviceName = prefs.getString('deviceName').toString();
    SelectedWard = prefs.getString("SelectedWard").toString();

    lattitude = prefs.getString('lattitude').toString();
    longitude = prefs.getString('longitude').toString();
    accuracy = prefs.getString('accuracy').toString();
    addresss = prefs.getString('address').toString();

    setState(() {
      DeviceName = DeviceName;
      SelectedWard = SelectedWard;
    });
  }

  @override
  void initState() {
    super.initState();
    getLocation();
    DeviceName = "";
    SelectedWard = "";
    _openCamera(context);
    getSharedPrefs();
  }

  void getLocation() {
    setState(() {
      _getLocation().then((value) {
        LocationData? location = value;
        _getAddress(location?.latitude, location?.longitude).then((value) {
          setState(() {
            currentLocation = location;
            address = value;
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
                            callReplacementComplete(
                                context, imageFile, DeviceName, SelectedWard);
                          }))
                  // rounded_button(
                  //   text: "Complete Replacement",
                  //   color: Colors.green,
                  //   press: () {
                  //     callReplacementComplete(context, imageFile, DeviceName,
                  //         address, SelectedWard);
                  //   },
                  //   key: null,
                  // ),
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
        Utility.progressDialog(context);
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
                    if (lattitude != null) {
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
                          'lattitude': lattitude,
                          'longitude': longitude,
                          'accuracy': accuracy
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
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context);
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
                          Navigator.pop(context);
                          calltoast(deviceName);
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      dashboard_screen()));
                        }
                      } else {
                        Navigator.pop(context);
                        calltoast(deviceName);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                dashboard_screen()));
                      }
                    } else {
                      Navigator.pop(context);
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
                    Navigator.pop(context);
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
                  Navigator.pop(context);
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
                Navigator.pop(context);
                calltoast(deviceName);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => dashboard_screen()));
              }
            } else {
              Navigator.pop(context);
              calltoast(deviceName);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => dashboard_screen()));
            }
          } else {
            Navigator.pop(context);
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
          Navigator.pop(context);
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callReplacementComplete(
                  context, imageFile, DeviceName, SelectedWard);
            }
          } else {
            calltoast(deviceName);
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => dashboard_screen()));
          }
        }
      }
    });
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
    Geolocator geolocator = Geolocator();
    List<Placemark> placemarks =
        await geolocator.placemarkFromCoordinates(lat, lang);
    Placemark place = placemarks[0];
    // GeoCode geoCode = GeoCode();
    // Address address =
    //     await geoCode.reverseGeocoding(latitude: lat, longitude: lang);
    return "${place.name}, ${place.locality}, ${place.country}";
  }

  Future<http.Response> postRequest(context, imageFile, DeviceName) async {
    var response;
    try {
      Uri myUri = Uri.parse(localAPICall);

      Map data = {'img': imageFile, 'name': DeviceName};
      //encode Map to JSON
      var body = json.encode(data);

      response = await http.post(myUri,
          headers: {"Content-Type": "application/json"}, body: body);
      print("${response.statusCode}");

      if (response.statusCode.toString() == "200") {
        Fluttertoast.showToast(
            msg: "Device Installation Completed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => dashboard_screen()));
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
}
