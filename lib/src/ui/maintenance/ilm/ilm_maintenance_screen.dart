import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/device_list_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/map_view_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/device_count_screen.dart';
import 'package:flutterlumin/src/ui/login/login_screen.dart';
import 'package:flutterlumin/src/ui/qr_scanner/qr_scanner.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/colors.dart';
import '../../components/dropdown_button_field.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _isOn = true;
  int _selectedIndex = 0;
  var LampactiveStatus;
  String Lampwatts = "0";
  String DeviceName = "0";
  String DeviceStatus = "0";

  void initState() {
    // TODO: implement initState
    super.initState();
    loadDetails();
  }

  void loadDetails() async {
    setState(() async {
      var sharedPreferences = await SharedPreferences.getInstance();
      Lampwatts = sharedPreferences.getString('deviceWatts').toString();
      DeviceName = sharedPreferences.getString('deviceName').toString();
      DeviceStatus = sharedPreferences.getString('deviceStatus').toString();
    });
  }

  void toggle() {
    setState(() => _isOn = !_isOn);
  }

  final List<Widget> _widgetOptions = <Widget>[
    device_count_screen(),
    map_view_screen(),
    device_list_screen()
  ];

  List<String> spinnerList = [
    'One',
    'Two',
    'Three',
  ];
  var dropDownValue = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(15, 80, 15, 0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(15, 50, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Expanded(
                        child: DropdownButtonField(
                            dropdownValue: dropDownValue,
                            onChanged: (value) {
                              setState(() {
                                dropDownValue = value;
                              });
                            },
                            spinnerItems: spinnerList)),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                        child: DropdownButtonField(
                            dropdownValue: dropDownValue,
                            onChanged: (value) {
                              setState(() {
                                dropDownValue = value;
                              });
                            },
                            spinnerItems: spinnerList)),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                        child: DropdownButtonField(
                            dropdownValue: dropDownValue,
                            onChanged: (value) {
                              setState(() {
                                dropDownValue = value;
                              });
                            },
                            spinnerItems: spinnerList)),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(15, 00, 15, 0),
                decoration: const BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(35.0))),
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.all(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              height: 50,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0))),
                              child: Text(
                                '$DeviceName',
                                style: TextStyle(
                                    fontSize: 18, fontFamily: "Montserrat"),
                              ),
                            )),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            child: Container(
                          alignment: Alignment.centerRight,
                          child: const Text(
                            '2nd Street , Gandhipuram',
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 14, fontFamily: "Montserrat"),
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                "Lamp Watts : " '$Lampwatts',
                                style: const TextStyle(
                                    fontSize: 18, fontFamily: "Montserrat"),
                              ),
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          height: 40,
                          child: const Text(
                            'Last Communication Date and Time',
                            style: TextStyle(
                                fontSize: 16, fontFamily: "Montserrat"),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.all(6),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_drop_down,
                              ),
                              iconSize: 50,
                              color: Colors.black,
                              splashColor: Colors.purple,
                              onPressed: () {
                                showDialog(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Expanded(flex: 2, child: ToggleButton()),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                      flex: 2,
                      child: InkWell(
                        child: Container(
                          height: 100,
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(34, 255, 59, 59),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0))),
                          child: const Center(
                            child: Text('GET LIVE',
                                style: TextStyle(
                                    fontSize: 18, fontFamily: "Montserrat")),
                          ),
                        ),
                        onTap: () {
                          if ('$DeviceStatus' != "false") {
                            getLiveRPCCall(context);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Device in Offline Mode",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1);
                          }
                        },
                      )),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Replace With",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontFamily: "Montserrat"),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      flex: 2,
                      child: InkWell(
                        child: Container(
                          alignment: Alignment.center,
                          height: 100,
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(34, 255, 59, 59),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0))),
                          child: Text('Shorting CAP',
                              style: TextStyle(
                                  fontSize: 18, fontFamily: "Montserrat")),
                        ),
                        onTap: () {
                          replaceShortingCap(context);
                        },
                      )),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                      flex: 2,
                      child: InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            height: 100,
                            decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0))),
                            child: const Text('ILM',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, fontFamily: "Montserrat")),
                          ),
                          onTap: () {
                            replaceILM(context);
                          })),
                ],
              ),
            ],
          )),
    );
  }
}

class ToggleButton extends StatefulWidget {
  const ToggleButton({Key? key}) : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

const double width = 300.0;
const double height = 100.0;
const double loginAlign = -1;
const double signInAlign = 1;
const Color selectedColor = Colors.black54;
const Color normalColor = Colors.black54;

class _ToggleButtonState extends State<ToggleButton> {
  late double xAlign;
  late Color loginColor;
  late Color signInColor;

  @override
  void initState() {
    super.initState();
    xAlign = loginAlign;
    loginColor = selectedColor;
    signInColor = normalColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.green,
        borderRadius: const BorderRadius.all(
          Radius.circular(50.0),
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(xAlign, 0),
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: width * 0.35,
              height: height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(50.0),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String DeviceStatus = prefs.getString('deviceStatus').toString();
              setState(() {
                if (DeviceStatus == "true") {
                  xAlign = loginAlign;
                  loginColor = Colors.black;
                  signInColor = Colors.black;
                  callONRPCCall(context);
                } else {
                  Fluttertoast.showToast(
                      msg: "Device in Offline Mode",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1);
                }
              });
            },
            child: Align(
              alignment: const Alignment(-1, 0),
              child: Container(
                width: width * 0.35,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    'ON',
                    style: TextStyle(
                      color: loginColor,
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String DeviceStatus = prefs.getString('deviceStatus').toString();
              setState(() {
                if (DeviceStatus == "true") {
                  xAlign = signInAlign;
                  signInColor = Colors.black;
                  loginColor = Colors.black;
                  callOFFRPCCall(context);
                } else {
                  Fluttertoast.showToast(
                      msg: "Device in Offline Mode",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1);
                }
              });
            },
            child: Align(
              alignment: const Alignment(1, 0),
              child: Container(
                width: width * 0.35,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    'OFF',
                    style: TextStyle(
                      color: signInColor,
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> callONRPCCall(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String deviceID = prefs.getString('deviceId').toString();

  var tbClient = ThingsboardClient(serverUrl);
  tbClient.smart_init();
  // type: String
  final jsonData = '{"lamp":"1","mode":"2"}';
  final parsedJson = jsonDecode(jsonData);

  var response = tbClient
      .getDeviceService()
      .handleTwoWayDeviceRPCRequest(deviceID, parsedJson);
  if (response == null) {}
}

Future<void> callOFFRPCCall(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String deviceID = prefs.getString('deviceId').toString();

  var tbClient = ThingsboardClient(serverUrl);
  tbClient.smart_init();
  // type: String
  final jsonData = '{"lamp":"0","mode":"2"}';
  final parsedJson = jsonDecode(jsonData);

  var response = tbClient
      .getDeviceService()
      .handleTwoWayDeviceRPCRequest(deviceID, parsedJson);
  if (response == null) {}
}

Future<void> getLiveRPCCall(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String deviceID = prefs.getString('deviceId').toString();
  var tbClient = ThingsboardClient(serverUrl);
  tbClient.smart_init();
  // type: String
  final jsonData = '{"params":"0","method":"get"}';
  final parsedJson = jsonDecode(jsonData);

  var response = tbClient
      .getDeviceService()
      .handleTwoWayDeviceRPCRequest(deviceID, parsedJson);
  if (response == null) {}
}

Future<void> replaceILM(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String OlddeviceID = prefs.getString('deviceId').toString();
  String OlddeviceName = prefs.getString('deviceName').toString();

  Utility.isConnected().then((value) async {
    if (value) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => QRScreen()),
          (route) => true).then((value) async {
        if (value != null) {}
      });
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

Future<void> replaceShortingCap(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String deviceID = prefs.getString('deviceId').toString();
  String deviceName = prefs.getString('deviceName').toString();
}

Future<void> callDeviceCurrentStatus(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String deviceID = prefs.getString('deviceId').toString();
  String deviceName = prefs.getString('deviceName').toString();
}

void showDialog(context) {
  showGeneralDialog(
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 700),
    context: context,
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
            height: 300,
            padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
            child: Column(children: const <Widget>[
              Text(
                "Last Communication Date and Time",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ])),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}
