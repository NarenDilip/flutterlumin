import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/ui/components/rounded_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dashboard_screen.dart';

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
    // return
    //   WillPopScope(
    //     onWillPop: () async {
    //       // Navigator.of(context).push(MaterialPageRoute(
    //       //     builder: (BuildContext context) => dashboard_screen()));
    //       return true;
    //     },
    // child :
    return Scaffold(
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
              SizedBox(height: 20),
              rounded_button(
                text: "Complete Replacement",
                color: purpleColor,
                press: () {
                  callReplacementComplete(context, imageFile, DeviceName);
                },
                key: null,
              ),
            ])));
    // );
  }

  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.rear);
    setState(() {
      imageFile = pickedFile;
    });
  }
}

void callReplacementComplete(context, imageFile, DeviceName) {
  final bytes = File(imageFile!.path).readAsBytesSync();
  String img64 = base64Encode(bytes);

  postRequest(context, img64, DeviceName);
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
