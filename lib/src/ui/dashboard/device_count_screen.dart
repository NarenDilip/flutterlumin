import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/thingsboard/model/dashboard_models.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/point/edge.dart';
import 'package:flutterlumin/src/ui/point/point.dart';
import 'package:flutterlumin/src/ui/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localdb/model/region_model.dart';

class device_count_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_count_screen_state();
  }
}

class device_count_screen_state extends State<device_count_screen> {
  String selectedRegion = "0";
  String selectedZone = "0";
  String selectedWard = "0";

  String totalCount = "0";
  String activeCount = "0";
  String nonactiveCount = "0";
  String ncCount = "0";

  String ccmsTotalCount = "0";
  String ccmsActiveCount = "0";
  String ccmsNonactiveCount = "0";
  String ccmsNcCount = "0";

  String gw_totalCount = "0";
  String gw_activeCount = "0";
  String gw_nonactiveCount = "0";
  String gw_ncCount = "0";

  String Maintenance = "true";

  double lattitude = 0;
  double longitude = 0;
  double accuracy = 0;
  String address = "";
  var accuvalue;
  var addvalue;
  var polygonad;

  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedRegion = prefs.getString("SelectedRegion").toString();
    selectedZone = prefs.getString("SelectedZone").toString();
    selectedWard = prefs.getString("SelectedWard").toString();

    totalCount = prefs.getString("totalCount").toString();
    activeCount = prefs.getString("activeCount").toString();
    nonactiveCount = prefs.getString("nonactiveCount").toString();
    ncCount = prefs.getString("ncCount").toString();

    ccmsTotalCount = prefs.getString("ccms_totalCount").toString();
    ccmsActiveCount = prefs.getString("ccms_activeCount").toString();
    ccmsNonactiveCount = prefs.getString("ccms_nonactiveCount").toString();
    ccmsNcCount = prefs.getString("ccms_ncCount").toString();

    gw_totalCount = prefs.getString("gw_totalCount").toString();
    gw_activeCount = prefs.getString("gw_activeCount").toString();
    gw_nonactiveCount = prefs.getString("gw_nonactiveCount").toString();
    gw_ncCount = prefs.getString("gw_ncCount").toString();

    Maintenance = prefs.getString("Maintenance").toString();

    setState(() {
      selectedRegion = selectedRegion;
      selectedZone = selectedZone;
      selectedWard = selectedWard;

      totalCount = totalCount;
      activeCount = activeCount;
      nonactiveCount = nonactiveCount;
      ncCount = ncCount;

      ccmsTotalCount = ccmsTotalCount;
      ccmsActiveCount = ccmsActiveCount;
      ccmsNonactiveCount = ccmsNonactiveCount;
      ccmsNcCount = ccmsNcCount;

      gw_totalCount = gw_totalCount;
      gw_activeCount = gw_activeCount;
      gw_nonactiveCount = gw_nonactiveCount;
      gw_ncCount = gw_ncCount;

      Maintenance = Maintenance;

      if (selectedRegion == "0" || selectedRegion == "null") {
        selectedRegion = "Region";
        selectedZone = "Zone";
        selectedWard = "Ward";
      }

      if (selectedZone == "0" || selectedZone == "null") {
        selectedZone = "Zone";
      }

      if (selectedWard == "0" || selectedWard == "null") {
        selectedWard = "Ward";
      }

      if (totalCount == "null") {
        totalCount = "0";
        activeCount = "0";
        nonactiveCount = "0";
        ncCount = "0";
      }

      if (ccmsTotalCount == "null") {
        ccmsTotalCount = "0";
        ccmsActiveCount = "0";
        ccmsNonactiveCount = "0";
        ccmsNcCount = "0";
      }

      if (gw_totalCount == "null") {
        gw_totalCount = "0";
        gw_activeCount = "0";
        gw_nonactiveCount = "0";
        gw_ncCount = "0";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    selectedRegion = "";
    getSharedPrefs();
    setUpLogs();
    FlutterLogs.logInfo("devicecount_page", "device_count", "pageEntry");
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
        // Contains file name of zip
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Container(
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
                      child: Text('Dashboard',
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
                            new Wrap(
                                spacing: 8.0,
                                // gap between adjacent chips
                                runSpacing: 4.0,
                                // gap between lines
                                direction: Axis.horizontal,
                                // main axis (rows or columns)
                                children: <Widget>[
                                  Container(
                                      height: 55,
                                      child: Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(5, 5, 5, 0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5.0),
                                                    child: Point(
                                                      triangleHeight: 25.0,
                                                      edge: Edge.RIGHT,
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
                                                                    '$selectedRegion' +
                                                                    "      ",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        14.0,
                                                                    fontFamily:
                                                                        "Montserrat",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5.0),
                                                    child: Point(
                                                      triangleHeight: 25.0,
                                                      edge: Edge.RIGHT,
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
                                                                    '$selectedZone' +
                                                                    "      ",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        14.0,
                                                                    fontFamily:
                                                                        "Montserrat",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5.0),
                                                    child: Point(
                                                      triangleHeight: 25.0,
                                                      edge: Edge.RIGHT,
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
                                                                    '$selectedWard' +
                                                                    "      ",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        14.0,
                                                                    fontFamily:
                                                                        "Montserrat",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]))),
                                ]),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                                child: Card(
                              color: Colors.transparent,
                              elevation: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Card(
                                    elevation: 20,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          Container(
                                              child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      15.0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "ILM",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 15.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      child: Center(
                                                        child: new Text(
                                                          '$totalCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: const <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      40.0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "ON",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "OFF",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 40.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "NC",
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      30.0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.green,
                                                      child: Center(
                                                        child: Text(
                                                          '$activeCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      child: Center(
                                                        child: Text(
                                                          '$nonactiveCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 30.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.orange,
                                                      child: Center(
                                                        child: Text(
                                                          '$ncCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                        ]),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Card(
                                    elevation: 20,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const SizedBox(height: 10),
                                          Row(
                                            children: <Widget>[
                                              const Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      15.0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                ),
                                              ),
                                              const Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "CCMS",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 15.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      child: Center(
                                                        child: Text(
                                                          '$ccmsTotalCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: const <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      40.0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "ON",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "OFF",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 40.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "NC",
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      30.0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.green,
                                                      child: Center(
                                                        child: Text(
                                                          '$ccmsActiveCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      child: Center(
                                                        child: Text(
                                                          '$ccmsNonactiveCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 30.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.orange,
                                                      child: Center(
                                                        child: Text(
                                                          '$ccmsNcCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                        ]),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Card(
                                    elevation: 20,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          Container(
                                              child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      15.0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "Gateway",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 15.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      child: Center(
                                                        child: new Text(
                                                          '$gw_totalCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: const <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      40.0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "ON",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "OFF",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 40.0, 0),
                                                  child: Align(
                                                    child: Text(
                                                      "NC",
                                                      style: TextStyle(
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              "Montserrat",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: thbDblue),
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      30.0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.green,
                                                      child: Center(
                                                        child: Text(
                                                          '$gw_activeCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0.0, 0.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      child: Center(
                                                        child: Text(
                                                          '$gw_nonactiveCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 0, 30.0, 0),
                                                  child: Align(
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.orange,
                                                      child: Center(
                                                        child: Text(
                                                          '$gw_ncCount',
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    alignment:
                                                        Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                        ]),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            )),
                          ])))
            ],
          ),
        ));
  }
}

Future<void> callLogoutoption(BuildContext context) async {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      backgroundColor: Colors.white,
      title: const Text("Luminator",
          style: TextStyle(
              fontSize: 25.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: liorange)),
      content: const Text(app_logout,
          style: TextStyle(
              fontSize: 18.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: Colors.black)),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: const Text("NO",
              style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
        ),
        TextButton(
          child: const Text('YES',
              style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          onPressed: () async {
            try {
              DBHelper dbhelper = new DBHelper();
              SharedPreferences prefs = await SharedPreferences.getInstance();

              var SelectedRegion = prefs.getString("SelectedRegion").toString();
              List<Region> details = await dbhelper.region_getDetails();

              for (int i = 0; i < details.length; i++) {
                dbhelper.delete(details
                    .elementAt(i)
                    .id!
                    .toInt());
              }
              dbhelper.zone_delete(SelectedRegion);
              dbhelper.ward_delete(SelectedRegion);

              SharedPreferences preferences =
              await SharedPreferences.getInstance();
              await preferences.clear();

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => splash_screen()));
            }catch(e){
              FlutterLogs.logInfo("devicecount_page", "device_count", "Db Exception");
            }
          },
        ),
      ],
    ),
  );
}
