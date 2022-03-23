import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/models/devicelistrequester.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/ilm_maintenance_screen.dart';
import 'package:flutterlumin/src/ui/point/point.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../localdb/db_helper.dart';
import '../../localdb/model/region_model.dart';
import '../installation/ccms/ccms_install_cam_screen.dart';
import '../installation/gateway/gateway_install_cam_screen.dart';
import '../installation/ilm/ilm_install_cam_screen.dart';
import '../maintenance/ccms/ccms_maintenance_screen.dart';
import '../maintenance/gateway/gw_maintenance_screen.dart';
import '../splash_screen.dart';
import 'dashboard_screen.dart';

class device_list_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_list_screen_state();
  }
}

class device_list_screen_state extends State<device_list_screen> {
  List<String>? _foundUsers = [];
  List<String>? _gwfoundUsers = [];
  List<String>? _ccmsfoundUsers = [];

  List<String>? _relationdevices = [];
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";
  bool _visible = true;
  bool _ilmvisible = true;
  bool _gwvisible = true;
  bool _ccmsvisible = true;
  bool _obscureText = true;
  String searchNumber = "0";
  late ProgressDialog pr;
  String Maintenance = "true";

  LocationData? currentLocation;
  String? _error;
  double lattitude = 0;
  double longitude = 0;
  double accuracy = 0;
  String address = "";
  var accuvalue;
  var addvalue;
  List<double>? _latt = [];
  final Location locations = Location();
  LocationData? _location;
  StreamSubscription<LocationData>? _locationSubscription;

  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();

  // var _myLogFileName = "Luminator1.0_LogFile";
  // var logStatus = '';
  // static Completer _completer = new Completer<String>();

  final user = DeviceRequester(
    ilmnumber: "",
    ccmsnumber: "",
    polenumber: "",
    gatewaynumber: "",
  );

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();
    Maintenance = prefs.getString("Maintenance").toString();

    setState(() {
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;
      Maintenance = Maintenance;

      if (SelectedRegion == "0" || SelectedRegion == "null") {
        SelectedRegion = "Region";
        SelectedZone = "Zone";
        SelectedWard = "Ward";
      }

      if (SelectedZone == "0" || SelectedZone == "null") {
        SelectedZone = "Zone";
      }

      if (SelectedWard == "0" || SelectedWard == "null") {
        SelectedWard = "Ward";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    SelectedRegion = "";
    getSharedPrefs();
    // setUpLogs();
    // _listenLocation();
    setUpLogs();
    FlutterLogs.logInfo("devicelist_page", "device_list", "Page Entry");
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

  // void setUpLogs() async {
  //   await FlutterLogs.initLogs(
  //       logLevelsEnabled: [
  //         LogLevel.INFO,
  //         LogLevel.WARNING,
  //         LogLevel.ERROR,
  //         LogLevel.SEVERE
  //       ],
  //       timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
  //       directoryStructure: DirectoryStructure.FOR_DATE,
  //       logTypesEnabled: [_myLogFileName],
  //       logFileExtension: LogFileExtension.LOG,
  //       logsWriteDirectoryName: "MyLogs",
  //       logsExportDirectoryName: "MyLogs/Exported",
  //       debugFileOperations: true,
  //       isDebuggable: true);
  //
  //   // [IMPORTANT] The first log line must never be called before 'FlutterLogs.initLogs'
  //   // FlutterLogs.logInfo(_tag, "setUpLogs", "setUpLogs: Setting up logs..");
  //
  //   // Logs Exported Callback
  //   FlutterLogs.channel.setMethodCallHandler((call) async {
  //     if (call.method == 'logsExported') {
  //       // Contains file name of zip
  //       // FlutterLogs.logInfo(
  //       //     _tag, "setUpLogs", "logsExported: ${call.arguments.toString()}");
  //
  //       setLogsStatus(
  //           status: "logsExported: ${call.arguments.toString()}", append: true);
  //
  //       // Notify Future with value
  //       _completer.complete(call.arguments.toString());
  //     } else if (call.method == 'logsPrinted') {
  //       // FlutterLogs.logInfo(
  //       //     _tag, "setUpLogs", "logsPrinted: ${call.arguments.toString()}");
  //
  //       setLogsStatus(
  //           status: "logsPrinted: ${call.arguments.toString()}", append: true);
  //     }
  //   });
  // }
  //
  // void setLogsStatus({String status = '', bool append = false}) {
  //   setState(() {
  //     logStatus = status;
  //   });
  // }

  void _toggle() {
    setState(() {
      _visible = !_visible;
    });
  }

  void _vtoggle() {
    setState(() {
      _ilmvisible = !_ilmvisible;
    });
  }

  void _gwtoggle() {
    setState(() {
      _gwvisible = !_gwvisible;
    });
  }

  void _ccmstoggle() {
    setState(() {
      _ccmsvisible = !_ccmsvisible;
    });
  }

  var dropDownValue = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

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

    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Container(
            color: thbDblue,
            child: Column(children: [
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
                      child: Text('Device List view',
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
                        icon: const Icon(
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
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                        children: <Widget>[
                          SizedBox(height: 5),
                          Wrap(
                              spacing: 8.0,
                              // gap between adjacent chips
                              runSpacing: 4.0,
                              // gap between lines
                              direction: Axis.horizontal,
                              // main axis (rows or columns)
                              children: <Widget>[
                                Container(
                                  height: 55,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Point(
                                            triangleHeight: 25.0,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            region_list_screen()));
                                                setState(() {});
                                              },
                                              child: Container(
                                                color: thbDblue,
                                                height: 40.0,
                                                child: Center(
                                                  child: Text(
                                                      "  " +
                                                          '$SelectedRegion' +
                                                          "      ",
                                                      style: const TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Point(
                                            triangleHeight: 25.0,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            zone_li_screen()));
                                                setState(() {});
                                              },
                                              child: Container(
                                                color: thbDblue,
                                                height: 40.0,
                                                child: Center(
                                                  child: Text(
                                                      "  " +
                                                          '$SelectedZone' +
                                                          "      ",
                                                      style: const TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Point(
                                            triangleHeight: 25.0,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            ward_li_screen()));
                                                setState(() {});
                                              },
                                              child: Container(
                                                color: thbDblue,
                                                height: 40.0,
                                                child: Center(
                                                  child: Text(
                                                      "  " +
                                                          '$SelectedWard' +
                                                          "      ",
                                                      style: const TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _toggle();
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: thbDblue,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 12),
                                                child: Text(
                                                  'Device Filters',
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      fontFamily: "Montserrat",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ))),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Visibility(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                              decoration: BoxDecoration(
                                  color: thbDblue,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(children: [
                                    Flexible(
                                        child: TextFormField(
                                            autofocus: false,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              filled: true,
                                              hintText: 'ILM Number',
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 0, 0, 0),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          70.0),
                                                  borderSide: BorderSide(
                                                      color: thbDblue)),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                // width: 0.0 produces a thin "hairline" border
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0)),
                                                borderSide:
                                                    BorderSide(color: thbDblue),
                                                //borderSide: const BorderSide(),
                                              ),
                                              suffixIcon: GestureDetector(
                                                onTap: () {
                                                  if (user
                                                      .ilmnumber.isNotEmpty) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());
                                                    callILMDeviceListFinder(
                                                        user.ilmnumber,
                                                        context);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Please Enter Device",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1);
                                                  }
                                                },
                                                child: Icon(
                                                  _obscureText
                                                      ? Icons.search
                                                      : Icons.search,
                                                  semanticLabel: _obscureText
                                                      ? 'show password'
                                                      : 'hide password',
                                                ),
                                              ),
                                            ),
                                            onSaved: (value) => user.ilmnumber =
                                                value!.toUpperCase(),
                                            onChanged: (String value) {
                                              user.ilmnumber =
                                                  value.toUpperCase();
                                              setState(() {
                                                _foundUsers!.clear();
                                              });
                                            }))
                                  ]),
                                  const SizedBox(height: 5),
                                  Row(children: [
                                    Flexible(
                                        child: TextFormField(
                                            autofocus: false,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              filled: true,
                                              hintText: 'CCMS Number',
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 0, 0, 0),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  borderSide: BorderSide(
                                                      color: Colors.white)),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                // width: 0.0 produces a thin "hairline" border
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0)),
                                                borderSide:
                                                    BorderSide(color: thbDblue),
                                                //borderSide: const BorderSide(),
                                              ),
                                              suffixIcon: GestureDetector(
                                                onTap: () {
                                                  if (user
                                                      .ccmsnumber.isNotEmpty) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());
                                                    callCcmsDeviceListFinder(
                                                        user.ccmsnumber,
                                                        context);
                                                    // callccmsbasedILMDeviceListFinder(
                                                    //     user.ccmsnumber,
                                                    //     _relationdevices,
                                                    //     _foundUsers,
                                                    //     context);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Please Enter Device",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1);
                                                  }
                                                },
                                                child: Icon(
                                                  _obscureText
                                                      ? Icons.search
                                                      : Icons.search,
                                                  semanticLabel: _obscureText
                                                      ? 'show password'
                                                      : 'hide password',
                                                ),
                                              ),
                                            ),
                                            onSaved: (value) =>
                                                user.ccmsnumber =
                                                    value!.toUpperCase(),
                                            onChanged: (String value) {
                                              user.ccmsnumber =
                                                  value.toUpperCase();
                                              setState(() {
                                                _ccmsfoundUsers!.clear();
                                              });
                                            }))
                                  ]),
                                  const SizedBox(height: 5),
                                  Row(children: [
                                    Flexible(
                                        child: TextFormField(
                                            autofocus: false,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              filled: true,
                                              hintText: 'Pole Number',
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 0, 0, 0),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  borderSide: BorderSide(
                                                      color: Colors.white)),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                // width: 0.0 produces a thin "hairline" border
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0)),
                                                borderSide:
                                                    BorderSide(color: thbDblue),
                                                //borderSide: const BorderSide(),
                                              ),
                                              suffixIcon: GestureDetector(
                                                onTap: () {
                                                  if (user
                                                      .polenumber.isNotEmpty) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());
                                                    callpolebasedILMDeviceListFinder(
                                                        user.polenumber,
                                                        _relationdevices,
                                                        _foundUsers,
                                                        context);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Please Enter Device",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1);
                                                  }
                                                },
                                                child: Icon(
                                                  _obscureText
                                                      ? Icons.search
                                                      : Icons.search,
                                                  semanticLabel: _obscureText
                                                      ? 'show password'
                                                      : 'hide password',
                                                ),
                                              ),
                                            ),
                                            onSaved: (value) =>
                                                user.polenumber =
                                                    value!.toUpperCase(),
                                            onChanged: (String value) {
                                              user.polenumber =
                                                  value.toUpperCase();
                                              setState(() {
                                                _foundUsers!.clear();
                                              });
                                            }))
                                  ]),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(children: [
                                    Flexible(
                                        child: TextFormField(
                                            autofocus: false,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Montserrat",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              filled: true,
                                              hintText: 'Gateway Number',
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 0, 0, 0),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  borderSide: BorderSide(
                                                      color: Colors.white)),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                // width: 0.0 produces a thin "hairline" border
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20.0)),
                                                borderSide:
                                                    BorderSide(color: thbDblue),
                                                //borderSide: const BorderSide(),
                                              ),
                                              suffixIcon: GestureDetector(
                                                onTap: () {
                                                  if (user.gatewaynumber
                                                      .isNotEmpty) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());
                                                    callgwDeviceListFinder(
                                                        user.gatewaynumber,
                                                        context);
                                                    // callpolebasedILMDeviceListFinder(
                                                    //     user.gatewaynumber,
                                                    //     _relationdevices,
                                                    //     _gwfoundUsers,
                                                    //     context);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Please Enter Device",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1);
                                                  }
                                                },
                                                child: Icon(
                                                  _obscureText
                                                      ? Icons.search
                                                      : Icons.search,
                                                  semanticLabel: _obscureText
                                                      ? 'show password'
                                                      : 'hide password',
                                                ),
                                              ),
                                            ),
                                            onSaved: (value) =>
                                                user.gatewaynumber =
                                                    value!.toUpperCase(),
                                            onChanged: (String value) {
                                              user.gatewaynumber =
                                                  value.toUpperCase();
                                              setState(() {
                                                _gwfoundUsers!.clear();
                                              });
                                            }))
                                  ])
                                ],
                              ),
                            ),
                            visible: _visible,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Row(
                              children: [],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  color: thbDblue,
                                  borderRadius: BorderRadius.circular(0)),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _vtoggle();
                                      });
                                    },
                                    child: Container(
                                        child: Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 12),
                                                child: Text('ILM Devices',
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)))),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                                  ),
                                ],
                              )),
                          Visibility(
                            child: Container(
                              color: thbDblue,
                              child: _foundUsers!.isNotEmpty
                                  ? ListView.builder(
                                      primary: false,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: _foundUsers!.length,
                                      itemBuilder: (context, index) => Card(
                                        key: ValueKey(_foundUsers),
                                        color: Colors.white,
                                        margin: const EdgeInsets.fromLTRB(
                                            15, 1, 10, 0),
                                        child: ListTile(
                                          onTap: () {
                                            fetchGWDeviceDetails(
                                                _foundUsers!
                                                    .elementAt(index)
                                                    .toString(),
                                                context);
                                          },
                                          title: Text(
                                              _foundUsers!.elementAt(index),
                                              style: const TextStyle(
                                                  fontSize: 22.0,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.white,
                                      child: Column(children: [
                                        // SizedBox(
                                        //   height: 10,
                                        // ),
                                        // Text(
                                        //   'No results found',
                                        //   textAlign: TextAlign.center,
                                        //   style: const TextStyle(
                                        //       fontSize: 18.0,
                                        //       fontFamily: "Montserrat",
                                        //       fontWeight: FontWeight.normal,
                                        //       color: Colors.black),
                                        // )
                                      ])),
                            ),
                            visible: _ilmvisible,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  color: thbDblue,
                                  borderRadius: BorderRadius.circular(0)),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _ccmstoggle();
                                      });
                                    },
                                    child: Container(
                                        child: Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 12),
                                                child: Text('CCMS Devices',
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)))),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                                  ),
                                ],
                              )),
                          Visibility(
                            child: Container(
                              color: thbDblue,
                              child: _ccmsfoundUsers!.isNotEmpty
                                  ? ListView.builder(
                                      primary: false,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: _ccmsfoundUsers!.length,
                                      itemBuilder: (context, index) => Card(
                                        key: ValueKey(_ccmsfoundUsers),
                                        color: Colors.white,
                                        margin: const EdgeInsets.fromLTRB(
                                            15, 1, 10, 0),
                                        child: ListTile(
                                          onTap: () {
                                            fetchGWDeviceDetails(
                                                _ccmsfoundUsers!
                                                    .elementAt(index)
                                                    .toString(),
                                                context);
                                          },
                                          title: Text(
                                              _ccmsfoundUsers!.elementAt(index),
                                              style: const TextStyle(
                                                  fontSize: 22.0,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.white,
                                      child: Column(children: [
                                        // SizedBox(
                                        //   height: 10,
                                        // ),
                                        // Text(
                                        //   'No results found',
                                        //   textAlign: TextAlign.center,
                                        //   style: const TextStyle(
                                        //       fontSize: 18.0,
                                        //       fontFamily: "Montserrat",
                                        //       fontWeight: FontWeight.normal,
                                        //       color: Colors.black),
                                        // )
                                      ])),
                            ),
                            visible: _ccmsvisible,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              decoration: BoxDecoration(
                                  color: thbDblue,
                                  borderRadius: BorderRadius.circular(0)),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _gwtoggle();
                                      });
                                    },
                                    child: Container(
                                        child: Row(
                                      children: [
                                        Expanded(
                                            child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 12),
                                                child: Text('Gateway Devices',
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)))),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                                  ),
                                ],
                              )),
                          Visibility(
                            child: Container(
                              color: thbDblue,
                              child: _gwfoundUsers!.isNotEmpty
                                  ? ListView.builder(
                                      primary: false,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: _gwfoundUsers!.length,
                                      itemBuilder: (context, index) => Card(
                                        key: ValueKey(_gwfoundUsers),
                                        color: Colors.white,
                                        margin: const EdgeInsets.fromLTRB(
                                            15, 1, 10, 0),
                                        child: ListTile(
                                          onTap: () {
                                            fetchGWDeviceDetails(
                                                _gwfoundUsers!
                                                    .elementAt(index)
                                                    .toString(),
                                                context);
                                          },
                                          title: Text(
                                              _gwfoundUsers!.elementAt(index),
                                              style: const TextStyle(
                                                  fontSize: 22.0,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.white,
                                      child: Column(children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'No results found',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black),
                                        )
                                      ])),
                            ),
                            visible: _gwvisible,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      )))
            ])));
  }

  // Future<void> callCCMSDeviceListFinder(
  //     String selectedNumber, BuildContext context) async {
  //   Utility.isConnected().then((value) async {
  //     if (value) {
  //       pr.show();
  //       try {
  //         var tbClient = ThingsboardClient(serverUrl);
  //         tbClient.smart_init();
  //
  //         String searchnumber = user.ilmnumber.replaceAll(" ", "");
  //
  //         PageLink pageLink = new PageLink(100);
  //         pageLink.page = 0;
  //         pageLink.pageSize = 100;
  //         pageLink.textSearch = searchnumber;
  //
  //         PageData<Device> devicelist_response;
  //         devicelist_response = (await tbClient
  //             .getDeviceService()
  //             .getTenantDevices(pageLink));
  //
  //         if (devicelist_response != null) {
  //           if (devicelist_response.totalElements != 0) {
  //             for (int i = 0; i < devicelist_response.data.length; i++) {
  //               String name =
  //                   devicelist_response.data.elementAt(i).name.toString();
  //               _foundUsers!.add(name);
  //             }
  //           }
  //
  //           setState(() {
  //             _foundUsers = _foundUsers;
  //           });
  //           pr.hide();
  //         } else {
  //           pr.hide();
  //           calltoast(searchNumber);
  //         }
  //       } catch (e) {
  //         pr.hide();
  //         var message = toThingsboardError(e, context);
  //         if (message == session_expired) {
  //           var status = loginThingsboard.callThingsboardLogin(context);
  //           if (status == true) {
  //             callpolebasedILMDeviceListFinder(
  //                 user.ilmnumber, _relationdevices, _foundUsers, context);
  //           }
  //         } else {
  //           calltoast(searchNumber);
  //           // Navigator.pop(context);
  //         }
  //       }
  //     } else {
  //       calltoast(no_network);
  //     }
  //   });
  // }

  Future<void> callILMDeviceListFinder(
      String selectedNumber, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        pr.show();
        try {
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          String searchnumber = user.ilmnumber.replaceAll(" ", "");

          PageLink pageLink = new PageLink(100);
          pageLink.page = 0;
          pageLink.pageSize = 100;
          pageLink.textSearch = searchnumber;

          PageData<Device> devicelist_response;
          devicelist_response =
              (await tbClient.getDeviceService().getTenantDevices(pageLink));

          if (devicelist_response != null) {
            if (devicelist_response.totalElements != 0) {
              for (int i = 0; i < devicelist_response.data.length; i++) {
                String name =
                    devicelist_response.data.elementAt(i).name.toString();
                _foundUsers!.add(name);
              }
            }

            setState(() {
              _foundUsers = _foundUsers;
            });
            pr.hide();
          } else {
            pr.hide();
            calltoast(searchNumber);
          }
        } catch (e) {
          FlutterLogs.logInfo(
              "devicelist_page", "device_list", "ILM Device Finder Issue");
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callpolebasedILMDeviceListFinder(
                  user.ilmnumber, _relationdevices, _foundUsers, context);
            }
          } else {
            calltoast(searchNumber);
            // Navigator.pop(context);
          }
        }
      } else {
        calltoast(no_network);
      }
    });
  }

  Future<void> callCcmsDeviceListFinder(
      String selectedNumber, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        pr.show();
        try {
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          String searchnumber = user.ccmsnumber.replaceAll(" ", "");

          PageLink pageLink = new PageLink(100);
          pageLink.page = 0;
          pageLink.pageSize = 100;
          pageLink.textSearch = searchnumber;

          PageData<Device> devicelist_response;
          devicelist_response = (await tbClient
              .getDeviceService()
              .getccmsTenantDevices(pageLink));

          if (devicelist_response != null) {
            if (devicelist_response.totalElements != 0) {
              for (int i = 0; i < devicelist_response.data.length; i++) {
                String name =
                    devicelist_response.data.elementAt(i).name.toString();
                _ccmsfoundUsers!.add(name);
              }
            }

            setState(() {
              _ccmsfoundUsers = _ccmsfoundUsers;
            });
            pr.hide();
          } else {
            pr.hide();
            calltoast(searchNumber);
          }
        } catch (e) {
          FlutterLogs.logInfo(
              "devicelist_page", "device_list", "CCMS Device Finder Issue");
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {}
          } else {
            calltoast(searchNumber);
          }
        }
      } else {
        calltoast(no_network);
      }
    });
  }

  Future<void> callgwDeviceListFinder(
      String selectedNumber, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        pr.show();
        try {
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          String searchnumber = user.gatewaynumber.replaceAll(" ", "");

          PageLink pageLink = new PageLink(100);
          pageLink.page = 0;
          pageLink.pageSize = 100;
          pageLink.textSearch = searchnumber;

          PageData<Device> devicelist_response;
          devicelist_response = (await tbClient
              .getDeviceService()
              .getgwTenantDevices(pageLink)) as PageData<Device>;

          if (devicelist_response != null) {
            if (devicelist_response.totalElements != 0) {
              for (int i = 0; i < devicelist_response.data.length; i++) {
                String name =
                    devicelist_response.data.elementAt(i).name.toString();
                _gwfoundUsers!.add(name);
              }
            }

            setState(() {
              _gwfoundUsers = _gwfoundUsers;
            });
            pr.hide();
          } else {
            pr.hide();
            calltoast(searchNumber);
          }
        } catch (e) {
          FlutterLogs.logInfo(
              "devicelist_page", "device_list", "GW Device Finder Exception");
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callgwDeviceListFinder(selectedNumber, context);
            }
          } else {
            calltoast(searchNumber);
            // Navigator.pop(context);
          }
        }
      } else {
        calltoast(no_network);
      }
    });
  }

  void callpolebasedILMDeviceListFinder(
      String searchnumber,
      List<String>? _relationdevices,
      List<String>? _foundUsers,
      BuildContext context) {
    Utility.isConnected().then((value) async {
      if (value) {
        pr.show();
        try {
          _relationdevices!.clear();
          _foundUsers!.clear();

          String polenumber = searchnumber.replaceAll(" ", "");

          Asset response;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();
          response = await tbClient.getAssetService().getTenantAsset(polenumber)
              as Asset;

          if (response != null) {
            List<EntityRelation> relationresponse;
            relationresponse = await tbClient
                .getEntityRelationService()
                .findByFrom(response.id!);
            if (relationresponse != null) {
              for (int i = 0; i < relationresponse.length; i++) {
                _relationdevices
                    .add(relationresponse.elementAt(i).to.id.toString());
              }
              Device devrelationresponse;
              for (int i = 0; i < _relationdevices.length; i++) {
                devrelationresponse = await tbClient
                        .getDeviceService()
                        .getDevice(_relationdevices.elementAt(i).toString())
                    as Device;
                if (devrelationresponse != null) {
                  if (devrelationresponse.type == "lumiNode") {
                    _foundUsers!.add(devrelationresponse.name);
                  } else {}
                } else {
                  calltoast(polenumber);
                  pr.hide();
                }
              }
              setState(() {
                _foundUsers = _foundUsers;
              });
              pr.hide();
            } else {
              FlutterLogs.logInfo("devicelist_page", "device_list",
                  "No Relation Occurs and cause Exception");
              pr.hide();
              calltoast(polenumber);
            }
          } else {
            FlutterLogs.logInfo("devicelist_page", "device_list",
                "No Device Found for execution");
            pr.hide();
            calltoast(polenumber);
          }
        } catch (e) {
          FlutterLogs.logInfo("devicelist_page", "device_list",
              "Pole Based Device Installation Exception");
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callpolebasedILMDeviceListFinder(
                  user.polenumber, _relationdevices, _foundUsers, context);
            }
          } else {
            pr.hide();
            calltoast(searchnumber);
          }
        }
      } else {
        calltoast(no_network);
      }
    });
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
          var tbClient = ThingsboardClient(serverUrl);
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
                    FlutterLogs.logInfo(
                        "Luminator 2.0", "dashboard_page", "");
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
                    prefs.setString(
                        'devicetimeStamp',
                        atresponser
                            .elementAt(0)
                            .getLastUpdateTs()
                            .toString());

                    List<String> myLister = [];
                    myLister.add("landmark");

                    responserse = (await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(response.id!, myLister));

                    if (responserse.isNotEmpty) {
                      prefs.setString('location',
                          responserse.first.getValue().toString());
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
                            builder: (context) =>
                            const GWMaintenanceScreen()),
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
                  msg: "Kindly Choose your Region, Zone and Ward to Install",
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
                msg: "Kindly Choose your Region, Zone and Ward to Install",
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
  // Future<Device?> fetchGWDeviceDetails(
  //     String deviceName, BuildContext context) async {
  //   Utility.isConnected().then((value) async {
  //     var gofenceValidation = false;
  //     if (value) {
  //       try {
  //         pr.show();
  //         Device response;
  //         String? SelectedRegion;
  //         var tbClient = ThingsboardClient(serverUrl);
  //         tbClient.smart_init();
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //         SelectedRegion = prefs.getString("SelectedRegion").toString();
  //         if (SelectedRegion.toString() != "Region") {
  //           response = (await tbClient
  //               .getDeviceService()
  //               .getTenantDevice(deviceName)) as Device;
  //
  //           if (response.toString().isNotEmpty) {
  //             List<String> myLists = [];
  //             myLists.add("firmware_versions");
  //
  //             List<AttributeKvEntry> deviceresponser;
  //
  //             deviceresponser = (await tbClient
  //                 .getAttributeService()
  //                 .getAttributeKvEntries(response.id!, myLists));
  //
  //             if (deviceresponser.isNotEmpty) {
  //               prefs.setString('firmwareVersion',
  //                   deviceresponser.first.getValue().toString());
  //               prefs.setString('deviceName', deviceName);
  //
  //               var relationDetails = await tbClient
  //                   .getEntityRelationService()
  //                   .findInfoByTo(response.id!);
  //
  //               if (relationDetails.length.toString() == "0") {
  //                 pr.hide();
  //                 if (response.type == ilm_deviceType) {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => const ilmcaminstall()),
  //                   );
  //                 } else if (response.type == ccms_deviceType) {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => const ccmscaminstall()),
  //                   );
  //                 } else if (response.type == Gw_deviceType) {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => const gwcaminstall()),
  //                   );
  //                 }
  //               } else {
  //                 List<String> firstmyList = [];
  //                 firstmyList.add("lmp");
  //
  //                 try {
  //                   List<TsKvEntry> faultresponser;
  //                   faultresponser = await tbClient
  //                       .getAttributeService()
  //                       .getselectedLatestTimeseries(response.id!.id!, "lmp");
  //                   if (faultresponser.isNotEmpty) {
  //                     prefs.setString('faultyStatus',
  //                         faultresponser.first.getValue().toString());
  //                   }
  //                 } catch (e) {
  //                   FlutterLogs.logInfo("devicelist_page", "device_list",
  //                       "Faulty Status Exception");
  //                   var message = toThingsboardError(e, context);
  //                 }
  //
  //                 List<String> myList = [];
  //                 myList.add("active");
  //
  //                 List<AttributeKvEntry> atresponser;
  //
  //                 atresponser = (await tbClient
  //                     .getAttributeService()
  //                     .getAttributeKvEntries(response.id!, myList));
  //
  //                 if (atresponser.isNotEmpty) {
  //                   prefs.setString('deviceStatus',
  //                       atresponser.first.getValue().toString());
  //                   prefs.setString('devicetimeStamp',
  //                       atresponser.elementAt(0).getLastUpdateTs().toString());
  //
  //                   List<String> myLister = [];
  //                   myLister.add("landmark");
  //                   // myLister.add("location");
  //
  //                   List<AttributeKvEntry> responserse;
  //
  //                   responserse = (await tbClient
  //                       .getAttributeService()
  //                       .getAttributeKvEntries(response.id!, myLister));
  //
  //                   if (responserse.isNotEmpty) {
  //                     prefs.setString(
  //                         'location', responserse.first.getValue().toString());
  //                     prefs.setString('deviceId', response.id!.toString());
  //                     prefs.setString('deviceName', deviceName);
  //
  //                     var SelectedWard =
  //                         prefs.getString("SelectedWard").toString();
  //                     DBHelper dbHelper = new DBHelper();
  //                     var wardDetails =
  //                         await dbHelper.ward_basedDetails(SelectedWard);
  //                     if (wardDetails.isNotEmpty) {
  //                       wardDetails.first.wardid;
  //
  //                       List<String> wardist = [];
  //                       wardist.add("geofence");
  //
  //                       var wardresponser = await tbClient
  //                           .getAttributeService()
  //                           .getFirmAttributeKvEntries(
  //                               wardDetails.first.wardid!, wardist);
  //
  //                       if (wardresponser.isNotEmpty) {
  //                         if (wardresponser.first.getValue() == "true") {
  //                           gofenceValidation = true;
  //                           prefs.setString('geoFence', "true");
  //                         } else {
  //                           gofenceValidation = false;
  //                           prefs.setString('geoFence', "false");
  //                         }
  //                       }
  //                     }
  //                   }
  //
  //                   List<String> myList = [];
  //                   myList.add("lattitude");
  //                   myList.add("longitude");
  //
  //                   List<BaseAttributeKvEntry> responser;
  //
  //                   responser = (await tbClient
  //                           .getAttributeService()
  //                           .getAttributeKvEntries(response.id!, myList))
  //                       as List<BaseAttributeKvEntry>;
  //
  //                   prefs.setString('deviceLatitude',
  //                       responser.first.kv.getValue().toString());
  //                   prefs.setString('deviceLongitude',
  //                       responser.last.kv.getValue().toString());
  //
  //                   pr.hide();
  //                   if (response.type == ilm_deviceType) {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                           builder: (context) => const MaintenanceScreen()),
  //                     );
  //                   } else if (response.type == ccms_deviceType) {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                           builder: (context) =>
  //                               const CCMSMaintenanceScreen()),
  //                     );
  //                   } else if (response.type == Gw_deviceType) {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                           builder: (context) => const GWMaintenanceScreen()),
  //                     );
  //                   }
  //                 } else {
  //                   FlutterLogs.logInfo("devicelist_page", "device_list",
  //                       "No Attribute Found Exception");
  //                   pr.hide();
  //                   refreshPage(context);
  //                   //"" No Active attribute found
  //                 }
  //               }
  //             } else {
  //               FlutterLogs.logInfo("devicelist_page", "device_list",
  //                   "No Frimware Attribute Found Exception");
  //               pr.hide();
  //               refreshPage(context);
  //               //"" No Firmware Device Found
  //             }
  //           } else {
  //             FlutterLogs.logInfo("devicelist_page", "device_list",
  //                 "No Device Found Exception");
  //             pr.hide();
  //             refreshPage(context);
  //             //"" No Device Found
  //           }
  //         } else {
  //           Fluttertoast.showToast(
  //               msg: "Kindly Choose your Region, Zone and Ward to Install",
  //               toastLength: Toast.LENGTH_SHORT,
  //               gravity: ToastGravity.BOTTOM,
  //               timeInSecForIosWeb: 1,
  //               backgroundColor: Colors.white,
  //               textColor: Colors.black,
  //               fontSize: 16.0);
  //
  //           pr.hide();
  //           refreshPage(context);
  //           //"" No Device Found
  //         }
  //       } catch (e) {
  //         FlutterLogs.logInfo(
  //             "devicelist_page", "device_list", "No Device Found Exception");
  //         pr.hide();
  //         var message = toThingsboardError(e, context);
  //         if (message == session_expired) {
  //           var status = loginThingsboard.callThingsboardLogin(context);
  //           if (status == true) {
  //             fetchGWDeviceDetails(deviceName, context);
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

  void refreshPage(context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => dashboard_screen()));
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

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    FlutterLogs.logInfo(
        "devicelist_page",
        "device_list",
        "Device List Exception with server Exception " +
            error.message.toString());
    if (error.message == "Session expired!") {
      // Navigator.pop(context);
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
            //
            // DBHelper dbhelper = new DBHelper();
            // dbhelper.region_delete();
            // dbhelper.zone_delete();
            // dbhelper.ward_delete();
            try {
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
              // SystemChannels.platform.invokeMethod('SystemNavigator.pop');

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => splash_screen()));
            } catch (e) {
              FlutterLogs.logInfo("devicelist_page", "device_list", "DB Exception");
            }
          },
        ),
      ],
    ),
  );
}
