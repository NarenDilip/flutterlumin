import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/model/device_models.dart';
import 'package:flutterlumin/src/thingsboard/model/entity_group_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/entity_group_id.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/components/rounded_button.dart';
import 'package:flutterlumin/src/ui/qr_scanner/qr_scanner.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dashboard_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

class replaceilm extends StatefulWidget {
  const replaceilm({Key? key}) : super(key: key);

  @override
  replaceilmState createState() => replaceilmState();
}

class replaceilmState extends State<replaceilm> {
  String DeviceName = "0";
  String newDeviceName = "0";
  var imageFile;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DeviceName = prefs.getString('deviceName').toString();
    newDeviceName = prefs.getString('newDevicename').toString();

    setState(() {
      DeviceName = DeviceName;
      newDeviceName = newDeviceName;
    });
  }

  @override
  void initState() {
    super.initState();
    DeviceName = "";
    newDeviceName = "";
    _openCamera(context);
    getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return
      WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => dashboard_screen()));
          return true;
        },
    child : Scaffold(
        body: Container(
            padding: EdgeInsets.fromLTRB(15, 60, 15, 0),
            decoration: const BoxDecoration(
                color: liblue,
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
              rounded_button(
                text: "Complete Replacement",
                color: purpleColor,
                press: () {
                  late Future<Device?> entityFuture;
                  entityFuture =
                      ilm_main_fetchDeviceDetails(
                          DeviceName,newDeviceName,context,imageFile);
                  showActionAlertDialog(context, DeviceName, newDeviceName);
                },
                key: null,
              ),
            ]))));
    // );
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
}
//
// Future<void> replaceILM(context,imageFile) async {
//   Utility.isConnected().then((value) async {
//     if (value) {
//       try {
//         Utility.progressDialog(context);
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         String OlddeviceID = prefs.getString('deviceId').toString();
//         String OlddeviceName = prefs.getString('deviceName').toString();
//
//         Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (BuildContext context) => QRScreen()),
//                 (route) => true).then((value) async {
//           if (value != null) {
//             if (OlddeviceName.toString() != value.toString()) {
//               Navigator.pop(context);
//               late Future<Device?> entityFuture;
//               // Utility.progressDialog(context);
//
//             } else {
//               calltoast("Duplicate QR Code");
//               Navigator.pop(context);
//             }
//           } else {
//             calltoast("Invalid QR Code");
//             Navigator.pop(context);
//           }
//         });
//       }catch(e){
//         var message = toThingsboardError(e, context);
//         if (message == session_expired) {
//           var status = loginThingsboard.callThingsboardLogin(context);
//           if (status == true) {
//           }
//         } else {
//           Navigator.pop(context);
//         }
//       }
//     } else {
//       calltoast(no_network);
//     }
//   });
// }

showActionAlertDialog(context,OldDevice,NewDevice) {
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
      // // Utility.progressDialog(context);
      // entityFuture =
      //     ilm_main_fetchDeviceDetails(context, OldDevice, NewDevice, imageFile);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Luminator",
        style: const TextStyle(
            fontSize: 25.0,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: thbblue)),

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
    // actions: [
    //   cancelButton,
    //   continueButton,
    // ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

@override
Future<Device?> ilm_main_fetchDeviceDetails(String OlddeviceName,
    String deviceName, BuildContext context, imageFile) async {
  Utility.isConnected().then((value) async {
    if (value) {
      Utility.progressDialog(context);
      try {
        Device response;
        Future<List<EntityGroupInfo>> deviceResponse;
        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        response = await tbClient.getDeviceService().getTenantDevice(deviceName)
            as Device;
        if (response.name.isNotEmpty) {
          if (response.type == ilm_deviceType) {
            ilm_main_fetchSmartDeviceDetails(OlddeviceName, deviceName,
                response.id!.id.toString(), context, imageFile);
          } else if (response.type == ccms_deviceType) {
          } else if (response.type == Gw_deviceType) {
          } else {
            Navigator.pop(context);
            calltoast("Device Details Not Found");
          }
        } else {
          Navigator.pop(context);
          calltoast(deviceName);

        }
      } catch (e) {
        Navigator.pop(context);
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            ilm_main_fetchDeviceDetails(
                OlddeviceName, deviceName, context, imageFile);
          }
        } else {
          calltoast(deviceName);
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

@override
Future<Device?> ilm_main_fetchSmartDeviceDetails(String Olddevicename,
    String deviceName, String deviceid, BuildContext context, imageFile) async {
  var DevicecurrentFolderName = "";
  var DevicemoveFolderName = "";

  Utility.isConnected().then((value) async {
    if (value) {
      Utility.progressDialog(context);
      try {
        Device response;
        Future<List<EntityGroupInfo>> deviceResponse;
        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();

        response = (await tbClient
            .getDeviceService()
            .getTenantDevice(deviceName)) as Device;

        if (response != null) {
          var new_Device_Name = response.name;

          List<EntityGroupInfo> entitygroups;
          entitygroups = await tbClient
              .getEntityGroupService()
              .getEntityGroupsByFolderType();

          if (entitygroups != null) {
            for (int i = 0; i < entitygroups.length; i++) {
              if (entitygroups.elementAt(i).name == ILMserviceFolderName) {
                DevicemoveFolderName =
                    entitygroups.elementAt(i).id!.id!.toString();
              }
            }

            List<EntityGroupId> currentdeviceresponse;
            currentdeviceresponse = await tbClient
                .getEntityGroupService()
                .getEntityGroupsForFolderEntity(response.id!.id!);

            if (currentdeviceresponse != null) {
              var firstdetails = await tbClient
                  .getEntityGroupService()
                  .getEntityGroup(currentdeviceresponse.first.id!);
              if (firstdetails!.name.toString() != "All") {
                DevicecurrentFolderName = currentdeviceresponse.first.id!;
              }
              var seconddetails = await tbClient
                  .getEntityGroupService()
                  .getEntityGroup(currentdeviceresponse.last.id!);
              if (seconddetails!.name.toString() != "All") {
                DevicecurrentFolderName = currentdeviceresponse.last.id!;
              }

              var relationDetails = await tbClient
                  .getEntityRelationService()
                  .findInfoByTo(response.id!);

              if (relationDetails != null) {
                List<String> myList = [];
                myList.add("lampWatts");
                myList.add("active");

                List<BaseAttributeKvEntry> responser;

                responser = (await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(response.id!, myList))
                    as List<BaseAttributeKvEntry>;

                if (responser != null) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString(
                      'deviceStatus', responser.first.kv.getValue().toString());
                  prefs.setString(
                      'deviceWatts', responser.last.kv.getValue().toString());

                  prefs.setString('deviceId', deviceid);
                  prefs.setString('deviceName', deviceName);

                  DeviceCredentials? newdeviceCredentials;
                  DeviceCredentials? olddeviceCredentials;

                  if (relationDetails.length.toString() == "0") {
                    newdeviceCredentials = await tbClient
                        .getDeviceService()
                        .getDeviceCredentialsByDeviceId(
                            response.id!.id.toString()) as DeviceCredentials;

                    if (newdeviceCredentials != null) {
                      var newQRID =
                          newdeviceCredentials.credentialsId.toString();

                      newdeviceCredentials.credentialsId = newQRID + "L";
                      var credresponse = await tbClient
                          .getDeviceService()
                          .saveDeviceCredentials(newdeviceCredentials);

                      response.name = deviceName + "99";
                      var devresponse = await tbClient
                          .getDeviceService()
                          .saveDevice(response);

                      // Old Device Updations
                      Device Olddevicedetails = null as Device;
                      Olddevicedetails = await tbClient
                          .getDeviceService()
                          .getTenantDevice(Olddevicename) as Device;

                      if (Olddevicedetails != null) {
                        var Old_Device_Name = Olddevicedetails.name;

                        olddeviceCredentials = await tbClient
                                .getDeviceService()
                                .getDeviceCredentialsByDeviceId(
                                    Olddevicedetails.id!.id.toString())
                            as DeviceCredentials;

                        if (olddeviceCredentials != null) {
                          var oldQRID =
                              olddeviceCredentials.credentialsId.toString();

                          olddeviceCredentials.credentialsId = oldQRID + "L";
                          var old_cred_response = await tbClient
                              .getDeviceService()
                              .saveDeviceCredentials(olddeviceCredentials);

                          Olddevicedetails.name = Olddevicename + "99";
                          var old_dev_response = await tbClient
                              .getDeviceService()
                              .saveDevice(Olddevicedetails);

                          olddeviceCredentials.credentialsId = newQRID;
                          var oldcredresponse = await tbClient
                              .getDeviceService()
                              .saveDeviceCredentials(olddeviceCredentials);

                          response.name = Old_Device_Name;
                          response.label = Old_Device_Name;
                          var olddevresponse = await tbClient
                              .getDeviceService()
                              .saveDevice(response);

                          final old_body_req = {
                            'boardNumber': Old_Device_Name,
                            'ieeeAddress': oldQRID,
                          };

                          var up_attribute = (await tbClient
                              .getAttributeService()
                              .saveDeviceAttributes(response.id!.id!,
                                  "SERVER_SCOPE", old_body_req));

                          // New Device Updations

                          Olddevicedetails.name = new_Device_Name;
                          Olddevicedetails.label = new_Device_Name;
                          var up_devresponse = await tbClient
                              .getDeviceService()
                              .saveDevice(Olddevicedetails);

                          newdeviceCredentials.credentialsId = oldQRID;
                          var up_credresponse = await tbClient
                              .getDeviceService()
                              .saveDeviceCredentials(newdeviceCredentials);

                          final new_body_req = {
                            'boardNumber': new_Device_Name,
                            'ieeeAddress': newQRID,
                          };

                          var up_newdevice_attribute = (await tbClient
                              .getAttributeService()
                              .saveDeviceAttributes(Olddevicedetails.id!.id!,
                                  "SERVER_SCOPE", new_body_req));

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

                          Navigator.pop(context);
                          callReplacementComplete(
                              context, imageFile,deviceName);
                        }
                      } else {
                        Navigator.pop(context);
                        calltoast(deviceName);
                      }
                    }
                  } else {
                    // New Device Updations
                    newdeviceCredentials = await tbClient
                        .getDeviceService()
                        .getDeviceCredentialsByDeviceId(
                            response.id!.id.toString()) as DeviceCredentials;

                    var relation_response = await tbClient
                        .getEntityRelationService()
                        .deleteDeviceRelation(
                            relationDetails.elementAt(0).from.id!,
                            response.id!.id!);

                    if (newdeviceCredentials != null) {
                      var newQRID =
                          newdeviceCredentials.credentialsId.toString();

                      newdeviceCredentials.credentialsId = newQRID + "L";
                      var credresponse = await tbClient
                          .getDeviceService()
                          .saveDeviceCredentials(newdeviceCredentials);

                      response.name = deviceName + "99";
                      var devresponse = await tbClient
                          .getDeviceService()
                          .saveDevice(response);

                      // Old Device Updations

                      Device Olddevicedetails = null as Device;
                      Olddevicedetails = await tbClient
                          .getDeviceService()
                          .getTenantDevice(Olddevicename) as Device;

                      if (Olddevicedetails != null) {
                        var Old_Device_Name = Olddevicedetails.name;

                        olddeviceCredentials = await tbClient
                                .getDeviceService()
                                .getDeviceCredentialsByDeviceId(
                                    Olddevicedetails.id!.id.toString())
                            as DeviceCredentials;

                        if (olddeviceCredentials != null) {
                          var oldQRID =
                              olddeviceCredentials.credentialsId.toString();

                          olddeviceCredentials.credentialsId = oldQRID + "L";
                          var old_cred_response = await tbClient
                              .getDeviceService()
                              .saveDeviceCredentials(olddeviceCredentials);

                          Olddevicedetails.name = Olddevicename + "99";
                          var old_dev_response = await tbClient
                              .getDeviceService()
                              .saveDevice(Olddevicedetails);

                          olddeviceCredentials.credentialsId = newQRID;
                          var oldcredresponse = await tbClient
                              .getDeviceService()
                              .saveDeviceCredentials(olddeviceCredentials);

                          response.name = Old_Device_Name;
                          response.label = Old_Device_Name;
                          var olddevresponse = await tbClient
                              .getDeviceService()
                              .saveDevice(response);

                          final old_body_req = {
                            'boardNumber': Old_Device_Name,
                            'ieeeAddress': oldQRID,
                          };

                          var up_attribute = (await tbClient
                              .getAttributeService()
                              .saveDeviceAttributes(response.id!.id!,
                                  "SERVER_SCOPE", old_body_req));

                          // New Device Updations

                          Olddevicedetails.name = new_Device_Name;
                          Olddevicedetails.label = new_Device_Name;
                          var up_devresponse = await tbClient
                              .getDeviceService()
                              .saveDevice(Olddevicedetails);

                          newdeviceCredentials.credentialsId = oldQRID;
                          var up_credresponse = await tbClient
                              .getDeviceService()
                              .saveDeviceCredentials(newdeviceCredentials);

                          final new_body_req = {
                            'boardNumber': new_Device_Name,
                            'ieeeAddress': newQRID,
                          };

                          var up_newdevice_attribute = (await tbClient
                              .getAttributeService()
                              .saveDeviceAttributes(Olddevicedetails.id!.id!,
                                  "SERVER_SCOPE", new_body_req));

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

                          Navigator.pop(context);
                          Navigator.of(context, rootNavigator: true).pop('dialog');
                          callReplacementComplete(context,imageFile,deviceName);
                        }
                      } else {
                        Navigator.pop(context);
                        calltoast(deviceName);
                      }
                    } else {
                      Navigator.pop(context);
                      calltoast(deviceName);
                    }
                  }
                } else {
                  Navigator.pop(context);
                  calltoast(deviceName);
                }
              } else {
                Navigator.pop(context);
                calltoast(deviceName);
              }
            } else {
              Navigator.pop(context);
              calltoast(deviceName);
            }
          } else {
            Navigator.pop(context);
            calltoast(deviceName);
          }
        } else {
          Navigator.pop(context);
          calltoast(deviceName);
        }
      } catch (e) {
        Navigator.pop(context);
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            ilm_main_fetchDeviceDetails(Olddevicename, deviceName, context,imageFile);
          }
        } else {
          calltoast(deviceName);
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> callReplacementComplete(context, imageFile, DeviceName) async {
  final bytes = File(imageFile!.path).readAsBytesSync();
  String img64 = base64Encode(bytes);
  postRequest(context, img64, DeviceName);
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
          msg: "Device Replacement Completed",
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
        msg: "Device Replacement Image Upload Error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
    return response;
  }
}