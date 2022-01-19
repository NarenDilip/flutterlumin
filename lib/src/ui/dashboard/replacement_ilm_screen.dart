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
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dashboard_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

class replacementilm extends StatefulWidget {
  const replacementilm({Key? key}) : super(key: key);

  @override
  replacementilmState createState() => replacementilmState();
}

class replacementilmState extends State<replacementilm> {
  String DeviceName = "0";
  var imageFile;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DeviceName = prefs.getString('deviceName').toString();

    setState(() {
      DeviceName = DeviceName;
    });
  }

  @override
  void initState() {
    super.initState();
    DeviceName = "";
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
    child :Scaffold(
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
                  callReplacementComplete(context, imageFile, DeviceName);
                },
                key: null,
              ),
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
}

Future<void> callReplacementComplete(context, imageFile, DeviceName) async {

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

        if (response != null) {
          var relationDetails = await tbClient
              .getEntityRelationService()
              .findInfoByTo(response.id!);

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
              if (currentdeviceresponse.last.id.toString().isNotEmpty) {

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

                var relation_response = await tbClient
                    .getEntityRelationService()
                    .deleteDeviceRelation(relationDetails.elementAt(0).from.id!,
                    response.id!.id!);

                // DevicecurrentFolderName =
                //     currentdeviceresponse.last.id.toString();

                List<String> myList = [];
                myList.add(response.id!.id!);

                var remove_response = tbClient
                    .getEntityGroupService()
                    .removeEntitiesFromEntityGroup(
                    DevicecurrentFolderName, myList);

                var add_response = tbClient
                    .getEntityGroupService()
                    .addEntitiesToEntityGroup(DevicemoveFolderName, myList);

                final bytes = File(imageFile!.path).readAsBytesSync();
                String img64 = base64Encode(bytes);

                postRequest(context, img64, DeviceName);
                Navigator.pop(context);

              } else {
                Navigator.pop(context);
                calltoast("Device is not Found");
              }
            } else {
              Navigator.pop(context);
              calltoast("Device EntityGroup Not Found");

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
            callReplacementComplete(context,imageFile, DeviceName);
          }
        } else {
          calltoast(deviceName);
          Navigator.pop(context);
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
