import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/device_count_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/device_list_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ccms/replace_ccms_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ccms/replacement_ccms_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/replace_ilm_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/replacement_ilm_screen.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/ui/qr_scanner/qr_scanner.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localdb/db_helper.dart';
import '../../../localdb/model/region_model.dart';
import '../../splash_screen.dart';

class CCMSMaintenanceScreen extends StatefulWidget {
  const CCMSMaintenanceScreen({Key? key}) : super(key: key);

  @override
  _CCMSMaintenanceScreenState createState() => _CCMSMaintenanceScreenState();
}

class _CCMSMaintenanceScreenState extends State<CCMSMaintenanceScreen> {
  var selectedImage = "";
  bool _isOn = true;
  DateTime? date;
  int _selectedIndex = 0;
  bool clickedCentreFAB = false;
  var LampactiveStatus;
  String Lampwatts = "0";
  String DeviceName = "0";
  String DeviceStatus = "0";
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";
  String faultyStatus = "0";
  String timevalue = "0";
  String location = "0";

  // String version = "0";
  late ProgressDialog pr;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Lampwatts = prefs.getString('deviceWatts').toString();
    DeviceName = prefs.getString('deviceName').toString();
    DeviceStatus = prefs.getString('deviceStatus').toString();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();
    timevalue = prefs.getString("devicetimeStamp").toString();
    location = prefs.getString("location").toString();
    // version = prefs.getString("version").toString();
    faultyStatus = prefs.getString("faultyStatus").toString();
    prefs.setString('Maintenance', "Yes");

    setState(() {
      Lampwatts = Lampwatts;
      DeviceName = DeviceName;
      DeviceStatus = DeviceStatus;
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;
      timevalue = timevalue;
      location = location;
      // version = version;
      faultyStatus = faultyStatus;

      date = DateTime.fromMillisecondsSinceEpoch(int.parse(timevalue));

      if (SelectedRegion == "null") {
        SelectedRegion = "Region";
        SelectedZone = "Zone";
        SelectedWard = "Ward";
        faultyStatus = "0";
      }

      if (SelectedZone == "0" || SelectedZone == "null") {
        SelectedZone = "Zone";
      }

      if (SelectedWard == "0" || SelectedWard == "null") {
        SelectedWard = "Ward";
      }

      if (location == "0") {
        location = location;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Lampwatts = "";
    DeviceName = "";
    DeviceStatus = "";
    getSharedPrefs();
  }

  void toggle() {
    setState(() => _isOn = !_isOn);
  }

  BuildContext get context => super.context;

  final List<Widget> _widgetOptions = <Widget>[
    device_count_screen(),
    device_list_screen()
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;

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

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => dashboard_screen()));
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Stack(
          children: [
            _widgetOptions.elementAt(_selectedIndex),
            Align(
              alignment: FractionalOffset.bottomRight,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                //if clickedCentreFAB == true, the first parameter is used. If it's false, the second.
                height: clickedCentreFAB
                    ? MediaQuery.of(context).size.height
                    : 10.0,
                width: clickedCentreFAB
                    ? MediaQuery.of(context).size.height
                    : 10.0,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(clickedCentreFAB ? 0.0 : 300.0),
                    color: Colors.white),
              ),
            ),
            Container(
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
                          child: Text('CCMS Maintanance',
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
                            icon: Icon(
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
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: <
                                  Widget>[
                            Container(
                                child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                        child: Text('$SelectedRegion',
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                EdgeInsets>(EdgeInsets.all(20)),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    thbDblue),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.black),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ))),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      region_list_screen()));
                                        }),
                                    SizedBox(width: 5),
                                    TextButton(
                                        child: Text('$SelectedZone',
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                EdgeInsets>(EdgeInsets.all(20)),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    thbDblue),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ))),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          zone_li_screen()));
                                        }),
                                    SizedBox(width: 5),
                                    TextButton(
                                        child: Text('$SelectedWard',
                                            style: const TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        style: ButtonStyle(
                                            padding: MaterialStateProperty.all<
                                                EdgeInsets>(EdgeInsets.all(20)),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    thbDblue),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ))),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ward_li_screen()));
                                        })
                                  ]),
                            )),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(15, 10, 5, 0),
                              decoration: const BoxDecoration(
                                  color: thbDblue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35.0))),
                              child: Column(
                                children: [
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 0, 0, 0),
                                        width: width / 3,
                                        height: 45,
                                        alignment: Alignment.centerLeft,
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15.0))),
                                        child: Center(
                                          child: Text(
                                            '$DeviceName',
                                            style: TextStyle(
                                                color: Colors.deepOrange,
                                                fontSize: 26,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ), //Container
                                      SizedBox(
                                        width: 15,
                                      ), //SizedBox
                                      Container(
                                          width: width / 2.05,
                                          height: 25,
                                          child: Text(
                                            "$location",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily: "Montserrat",
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ) //BoxDecoration
                                          ) //Container
                                    ], //<Widget>[]
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                          width: width / 3,
                                          height: 25,
                                          child: Text(
                                            "Lamp watts",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: "Montserrat",
                                                color: Colors.white),
                                          )), //Container
                                      SizedBox(
                                        width: 5,
                                      ), //SizedBox
                                      Container(
                                          width: width / 2.05,
                                          height: 25,
                                          child: Text(
                                            "$Lampwatts",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold),
                                          ) //BoxDecoration
                                          ) //Container
                                    ], //<Widget>[]
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                          width: width / 3,
                                          height: 25,
                                          child: Text(
                                            "Last Comm @ ",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontFamily: "Montserrat"),
                                          )), //Container
                                      SizedBox(
                                        width: 5,
                                      ), //SizedBox
                                      Container(
                                          width: width / 2.05,
                                          height: 25,
                                          child: Text(
                                            "$date",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold),
                                          ) //BoxDecoration
                                          ) //Container
                                    ], //<Widget>[]
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  // Column(
                                  //   children: [
                                  //     Container(
                                  //       alignment: Alignment.topLeft,
                                  //       padding: const EdgeInsets.fromLTRB(8, 10, 0, 0),
                                  //       height: 40,
                                  //       child: Text(
                                  //         'Last Comm @',
                                  //         style: TextStyle(
                                  //             fontSize: 18, fontFamily: "Montserrat"),
                                  //       ),
                                  //     ),
                                  //     Container(
                                  //       padding: const EdgeInsets.all(8),
                                  //       height: 40,
                                  //       child: Text(
                                  //         '$date',
                                  //         style: TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.bold,
                                  //             fontFamily: "Montserrat"),
                                  //       ),
                                  //     ),
                                  //     // Expanded(
                                  //     //   child: Container(
                                  //     //     alignment: Alignment.centerRight,
                                  //     //     padding: EdgeInsets.all(6),
                                  //     //     child: IconButton(
                                  //     //       icon: const Icon(
                                  //     //         Icons.arrow_drop_down,
                                  //     //       ),
                                  //     //       iconSize: 50,
                                  //     //       color: Colors.black,
                                  //     //       splashColor: Colors.purple,
                                  //     //       onPressed: () {
                                  //     //         // showDialog(context, date);
                                  //     //       },
                                  //     //     ),
                                  //     //   ),
                                  //     // ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
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
                                        height: 90,
                                        decoration: const BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50.0))),
                                        child: const Center(
                                          child: Text('GET LIVE',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontFamily: "Montserrat")),
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
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      child: Container(
                                        height: 90,
                                        decoration: const BoxDecoration(
                                            color: Colors.lightBlue,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50.0))),
                                        child: const Center(
                                          child: Text('MCB TRIP',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontFamily: "Montserrat")),
                                        ),
                                      ),
                                      onTap: () {
                                        if ('$DeviceStatus' != "false") {
                                          callMCBTrip(context);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "Device in Offline Mode",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1);
                                        }
                                      },
                                    )),
                                const SizedBox(
                                  width: 15,
                                ),
                                // Expanded(
                                //     flex: 2,
                                //     child: InkWell(
                                //       child: Container(
                                //         height: 90,
                                //         decoration: const BoxDecoration(
                                //             color: Colors.lightGreen,
                                //             borderRadius: BorderRadius.all(
                                //                 Radius.circular(50.0))),
                                //         child: const Center(
                                //           child: Text('MCB CLEAR',
                                //               style: TextStyle(
                                //                   fontSize: 18,
                                //                   color: Colors.white,
                                //                   fontFamily: "Montserrat")),
                                //         ),
                                //       ),
                                //       onTap: () {},
                                //     )),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              decoration: const BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18.0))),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: InkWell(
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 90,
                                              decoration: const BoxDecoration(
                                                  color: Colors.deepOrange,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              50.0))),
                                              child: const Text('REMOVE',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          "Montserrat")),
                                            ),
                                            onTap: () {
                                              removeCCMS(context);
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
                                                height: 90,
                                                decoration: const BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                50.0))),
                                                child: const Text('REPLACE',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white,
                                                        fontFamily:
                                                            "Montserrat")),
                                              ),
                                              onTap: () {
                                                replaceCCMS(context);
                                              })),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToggleButton extends StatefulWidget {
  const ToggleButton({Key? key}) : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

const double width = 300.0;
const double height = 90.0;
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
              width: width * 0.28,
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
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
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
      pr.show();
      // Utility.progressDialog(context);
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceID = prefs.getString('deviceId').toString();

        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        // type: String
        final jsonData = {
          "method": "ctrl",
          "params": {"lamp": 1}
        };
        // final parsedJson = jsonDecode(jsonData);

        var response = await tbClient
            .getDeviceService()
            .handleTwoWayDeviceRPCRequest(deviceID, jsonData)
            .timeout(Duration(minutes: 2));

        if (response["lamp"].toString() == "1") {
          Fluttertoast.showToast(
              msg: "Device ON Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
          pr.hide();
          // Navigator.pop(context);
        } else {
          pr.hide();
          // Navigator.pop(context);
          calltoast("Unable to Process, Please try again");
        }
      } catch (e) {
        pr.hide();
        // Navigator.pop(context);
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            callONRPCCall(context);
          }
        } else {
          calltoast("Unable to Process");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> callOFFRPCCall(context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
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
      pr.show();
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceID = prefs.getString('deviceId').toString();

        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        // type: String
        final jsonData = {
          "method": "ctrl",
          "params": {"lamp": 0}
        };
        // final parsedJson = jsonDecode(jsonData);

        var response = await tbClient
            .getDeviceService()
            .handleTwoWayDeviceRPCRequest(deviceID, jsonData)
            .timeout(const Duration(minutes: 2));

        if (response["lamp"].toString() == "0") {
          pr.hide();
          Fluttertoast.showToast(
              msg: "Device Off Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
        } else {
          pr.hide();
          calltoast("Unable to Process, Please try again");
        }
      } catch (e) {
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            callOFFRPCCall(context);
          }
        } else {
          calltoast("Unable to Process");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> callMCBTrip(context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
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
      pr.show();
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceID = prefs.getString('deviceId').toString();
        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        // type: String
        final jsonData;

        jsonData = {"method": "clr", "params": "8"};

        // final parsedJson = jsonDecode(jsonData);
        var response = await tbClient
            .getDeviceService()
            .handleOneWayDeviceRPCRequest(deviceID, jsonData)
            .timeout(const Duration(minutes: 5));

        final jsonDatat;

        jsonDatat = {
          "method": "set",
          "params": {'rostat': 0, 'yostat': 0, 'bostat': 0}
        };

        var responsee = await tbClient
            .getDeviceService()
            .handleOneWayDeviceRPCRequest(deviceID, jsonDatat)
            .timeout(const Duration(minutes: 5));

        pr.hide();
        // if(response.) {
        //   calltoast("Device ON Sucessfully");
        //   Navigator.pop(context);
        // }else {
        //   calltoast("Unable to Process, Please try again");
        //   Navigator.pop(context);
        // }
      } catch (e) {
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            getLiveRPCCall(context);
          }
        } else {
          calltoast("Unable to Process");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> getLiveRPCCall(context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
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
      pr.show();
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String deviceID = prefs.getString('deviceId').toString();
        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        // type: String
        final jsonData;

        jsonData = {
          "method": "get",
          "params": {"value": 0}
        };

        // final parsedJson = jsonDecode(jsonData);
        var response = await tbClient
            .getDeviceService()
            .handleOneWayDeviceRPCRequest(deviceID, jsonData)
            .timeout(const Duration(minutes: 5));
        pr.hide();
        // if(response.) {
        //   calltoast("Device ON Sucessfully");
        //   Navigator.pop(context);
        // }else {
        //   calltoast("Unable to Process, Please try again");
        //   Navigator.pop(context);
        // }
      } catch (e) {
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            getLiveRPCCall(context);
          }
        } else {
          calltoast("Unable to Process");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> replaceCCMS(context) async {
  // Navigator.pop(context);
  // Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(builder: (BuildContext context) => replaceilm()));

  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
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
      pr.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String OlddeviceID = prefs.getString('deviceId').toString();
      String OlddeviceName = prefs.getString('deviceName').toString();

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => QRScreen()),
          (route) => true).then((value) async {
        if (value != null) {
          if (OlddeviceName.toString() != value.toString()) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('newDevicename', value);

            pr.hide();
            // showActionAlertDialog(context,OlddeviceName,value);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => replaceccms()));
          } else {
            pr.hide();
            calltoast("Duplicate QR Code");
          }
        } else {
          pr.hide();
          calltoast("Invalid QR Code");
        }
      });
    } else {
      calltoast(no_network);
    }
  });
}

@override
Future<Device?> ilm_main_fetchDeviceDetails(
    String OlddeviceName, String deviceName, BuildContext context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
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
      pr.show();
      try {
        Device response;
        Future<List<EntityGroupInfo>> deviceResponse;
        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        response = await tbClient.getDeviceService().getTenantDevice(deviceName)
            as Device;
        if (response.name.isNotEmpty) {
          if (response.type == ilm_deviceType) {
            ilm_main_fetchSmartDeviceDetails(
                OlddeviceName, deviceName, response.id!.id.toString(), context);
          } else if (response.type == ccms_deviceType) {
          } else if (response.type == Gw_deviceType) {
          } else {
            pr.hide();
            calltoast("Device Details Not Found");
          }
        } else {
          pr.hide();
          calltoast(deviceName);
        }
      } catch (e) {
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            ilm_main_fetchDeviceDetails(OlddeviceName, deviceName, context);
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

Future<void> removeCCMS(context) async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String deviceID = prefs.getString('deviceId').toString();
  // String deviceName = prefs.getString('deviceName').toString();
  //
  // var DevicecurrentFolderName = "";
  // var DevicemoveFolderName = "";
  //
  // Utility.isConnected().then((value) async {
  //   if (value) {
  //     Utility.progressDialog(context);
  //     try {
  //       var tbClient = ThingsboardClient(serverUrl);
  //       tbClient.smart_init();
  //
  //       Device response;
  //       response = (await tbClient
  //           .getDeviceService()
  //           .getTenantDevice(deviceName)) as Device;
  //
  //       if (response != null) {
  //         var relationDetails = await tbClient
  //             .getEntityRelationService()
  //             .findInfoByTo(response.id!);
  //
  //         List<EntityGroupInfo> entitygroups;
  //         entitygroups = await tbClient
  //             .getEntityGroupService()
  //             .getEntityGroupsByFolderType();
  //
  //         if (entitygroups != null) {
  //           for (int i = 0; i < entitygroups.length; i++) {
  //             if (entitygroups.elementAt(i).name == ILMserviceFolderName) {
  //               DevicemoveFolderName =
  //                   entitygroups.elementAt(i).id!.id!.toString();
  //             }
  //           }
  //
  //           List<EntityGroupId> currentdeviceresponse;
  //           currentdeviceresponse = await tbClient
  //               .getEntityGroupService()
  //               .getEntityGroupsForFolderEntity(response.id!.id!);
  //
  //           if (currentdeviceresponse != null) {
  //             if (currentdeviceresponse.last.id.toString().isNotEmpty) {
  //
  //               var firstdetails = await tbClient
  //                   .getEntityGroupService()
  //                   .getEntityGroup(currentdeviceresponse.first.id!);
  //               if (firstdetails!.name.toString() != "All") {
  //                 DevicecurrentFolderName = currentdeviceresponse.first.id!;
  //               }
  //               var seconddetails = await tbClient
  //                   .getEntityGroupService()
  //                   .getEntityGroup(currentdeviceresponse.last.id!);
  //               if (seconddetails!.name.toString() != "All") {
  //                 DevicecurrentFolderName = currentdeviceresponse.last.id!;
  //               }
  //
  //               var relation_response = await tbClient
  //                   .getEntityRelationService()
  //                   .deleteDeviceRelation(relationDetails.elementAt(0).from.id!,
  //                       response.id!.id!);
  //
  //               // DevicecurrentFolderName =
  //               //     currentdeviceresponse.last.id.toString();
  //
  //               List<String> myList = [];
  //               myList.add(response.id!.id!);
  //
  //               var remove_response = tbClient
  //                   .getEntityGroupService()
  //                   .removeEntitiesFromEntityGroup(
  //                       DevicecurrentFolderName, myList);
  //
  //               var add_response = tbClient
  //                   .getEntityGroupService()
  //                   .addEntitiesToEntityGroup(DevicemoveFolderName, myList);
  //
  // Navigator.pop(context);
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => replacementccms()));
  //             } else {
  //               calltoast("Device is not Found");
  //               Navigator.pop(context);
  //             }
  //           } else {
  //             calltoast("Device EntityGroup Not Found");
  //             Navigator.pop(context);
  //           }
  //         } else {
  //           calltoast(deviceName);
  //           Navigator.pop(context);
  //         }
  //       } else {
  //         calltoast(deviceName);
  //         Navigator.pop(context);
  //       }
  //     } catch (e) {
  //       var message = toThingsboardError(e, context);
  //       if (message == session_expired) {
  //         var status = loginThingsboard.callThingsboardLogin(context);
  //         if (status == true) {
  //           replaceILM(context);
  //         }
  //       } else {
  //         calltoast(deviceName);
  //         Navigator.pop(context);
  //       }
  //     }
  //   }
  // });
}

@override
Future<Device?> ilm_main_fetchSmartDeviceDetails(String Olddevicename,
    String deviceName, String deviceid, BuildContext context) async {
  var DevicecurrentFolderName = "";
  var DevicemoveFolderName = "";

  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
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
      pr.show();
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

                          pr.hide();
                          callDashboard(context);
                        }
                      } else {
                        pr.hide();
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

                          pr.hide();
                          callDashboard(context);
                        }
                      } else {
                        pr.hide();
                        calltoast(deviceName);
                      }
                    } else {
                      pr.hide();
                      calltoast(deviceName);
                    }
                  }
                } else {
                  pr.hide();
                  calltoast(deviceName);
                }
              } else {
                pr.hide();
                calltoast(deviceName);
              }
            } else {
              pr.hide();
              calltoast(deviceName);
            }
          } else {
            pr.hide();
            calltoast(deviceName);
          }
        } else {
          pr.hide();
          calltoast(deviceName);
        }
      } catch (e) {
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            ilm_main_fetchDeviceDetails(Olddevicename, deviceName, context);
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

showActionAlertDialog(context, OldDevice, NewDevice) {
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
      late Future<Device?> entityFuture;
      // Utility.progressDialog(context);
      entityFuture = ilm_main_fetchDeviceDetails(context, OldDevice, NewDevice);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Luminator",
        style: const TextStyle(
            fontSize: 25.0,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: thbDblue)),

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
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
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

void callDashboard(context) {
  Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => replacementilm()));
}

Future<void> callDeviceCurrentStatus(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String deviceID = prefs.getString('deviceId').toString();
  String deviceName = prefs.getString('deviceName').toString();
}

// void showDialog(context, timevalue) {
//   showGeneralDialog(
//     barrierLabel: "Barrier",
//     barrierDismissible: true,
//     barrierColor: Colors.black.withOpacity(0.5),
//     transitionDuration: Duration(milliseconds: 700),
//     context: context,
//     pageBuilder: (_, __, ___) {
//       return Align(
//         alignment: Alignment.bottomCenter,
//         child: Container(
//             margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(40),
//             ),
//             height: 300,
//             padding: EdgeInsets.fromLTRB(20, 25, 20, 0),
//             child: Column(children: [
//               Text(
//                 "Last Communication Date and Time",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 20.0,
//                     fontFamily: "Montserrat",
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//               ),
//
//               const SizedBox(
//                 height: 15,
//               ),
//               Text(
//                 '$timevalue',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     fontSize: 20.0,
//                     fontFamily: "Montserrat",
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black),
//               ),
//             ])),
//       );
//     },
//     transitionBuilder: (_, anim, __, child) {
//       return SlideTransition(
//         position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
//         child: child,
//       );
//     },
//   );
// }

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
            // DBHelper dbhelper = new DBHelper();
            // dbhelper.region_delete();
            // dbhelper.zone_delete();
            // dbhelper.ward_delete();

            DBHelper dbhelper = new DBHelper();
            SharedPreferences prefs = await SharedPreferences.getInstance();

            var SelectedRegion = prefs.getString("SelectedRegion").toString();
            List<Region> details = await dbhelper.region_getDetails();

            for (int i = 0; i < details.length; i++) {
              dbhelper.delete(details.elementAt(i).id!.toInt());
            }
            dbhelper.zone_delete(SelectedRegion);
            dbhelper.ward_delete(SelectedRegion);

            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            await preferences.clear();
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');

            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => splash_screen()));
          },
        ),
      ],
    ),
  );
}
