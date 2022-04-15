import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/zone_model.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localdb/model/ward_model.dart';
import '../../thingsboard/error/thingsboard_error.dart';
import '../../thingsboard/model/model.dart';
import '../../thingsboard/thingsboard_client_base.dart';
import '../../utils/utility.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

import '../dashboard/dashboard_screen.dart';

class zone_li_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return zone_li_screen_state();
  }
}

class zone_li_screen_state extends State<zone_li_screen> {
  List<String>? _allUsers = [];
  List<String>? _foundUsers = [];
  String selectedRegion = "0";
  String selectedZone = "0";
  List<String>? relatedzones = [];
  late ProgressDialog pr;

  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();

  @override
  initState() {
    loadDetails();
    setUpLogs();
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

    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == 'logsExported') {
        setLogsStatus(
            status: "logsExported: ${call.arguments.toString()}", append: true);
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

  void loadDetails() async {
    DBHelper dbHelper = DBHelper();
    Future<List<Zone>> zones;

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

    var sharedPreferences = await SharedPreferences.getInstance();
    selectedRegion = sharedPreferences.getString("SelectedRegion").toString();

    if (selectedRegion != "0") {
      zones = dbHelper.zone_regionbasedDetails(selectedRegion);
      zones.then((data) {
        for (int i = 0; i < data.length; i++) {
          String regionname = data[i].zonename.toString();
          _allUsers?.add(regionname);
        }
        setState(() {
          _foundUsers = _allUsers!;
        });
      }, onError: (e) {
        print(e);
      });
    }
  }

  loadLocalData() async {
    var sharedPreferences =
    await SharedPreferences.getInstance() as SharedPreferences;
    sharedPreferences.setString("SelectedZone", selectedZone);
  }

  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allUsers!;
    } else {
      results = _allUsers!
          .where((user) =>
          user.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
          backgroundColor: thbDblue,
          body: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Select Zone",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25.0,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (value) => _runFilter(value),
                  style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(fontSize: 20.0, color: Colors.white),
                    labelText: 'Search',
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: _foundUsers!.isNotEmpty
                      ? ListView.builder(
                    itemCount: _foundUsers!.length,
                    itemBuilder: (context, index) => Card(
                      key: ValueKey(_foundUsers),
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            selectedZone =
                                _foundUsers!.elementAt(index).toString();
                            loadLocalData();
                          });
                          callWardDetailsFinder(context, selectedZone);
                        },
                        title: Text(_foundUsers!.elementAt(index),
                            style: const TextStyle(
                                fontSize: 22.0,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.bold,
                                color: thbDblue)),
                      ),
                    ),
                  )
                      : const Text(
                    app_no_results,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void callWardDetailsFinder(BuildContext context, selectedZone) {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          pr.show();
          var tbClient = await ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
          tbClient.smart_init();

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("SelectedZone", selectedZone);

          var regionname = selectedZone.split("-");

          DBHelper dbHelper = new DBHelper();
          dbHelper.ward_delete(regionname[0].toString());
          List<Ward> ward =
          await dbHelper.ward_zonebasedDetails(selectedZone);
          if (ward.isEmpty) {

            List<Zone> regiondetails =
            await dbHelper.zone_zonebasedDetails(selectedZone);
            if (regiondetails.length != 0) {
              Map<String, dynamic> fromId = {
                'entityType': 'ASSET',
                'id': regiondetails.first.zoneid
              };

              List<EntityRelationInfo> wardlist = await tbClient
                  .getEntityRelationService()
                  .findInfoByAssetFrom(EntityId.fromJson(fromId));

              if (wardlist.isNotEmpty) {
                for (int i = 0; i < wardlist.length; i++) {
                  relatedzones?.add(wardlist.elementAt(i).to.id.toString());
                }

                for (int j = 0; j < relatedzones!.length; j++) {
                  Asset asset = await tbClient
                      .getAssetService()
                      .getAsset(relatedzones!.elementAt(j).toString()) as Asset;
                  if (asset.name != null) {
                    var regionname = selectedZone.split("-");

                    var rng = new Random();
                    var code = rng.nextInt(900000) + 100000;

                    Ward ward = Ward(j+code+0, asset.id!.id, asset.name, selectedZone,
                        regionname[0].toString());

                    dbHelper.ward_add(ward);
                  }
                }
                pr.hide();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => ward_li_screen()));
              } else {
                FlutterLogs.logInfo("zonelist_page", "zone_list", "Ward Details Relation Nof Found Exception");
                pr.hide();
                Fluttertoast.showToast(
                    msg: "No Wards releated to this zone",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);
              }
            } else {
              FlutterLogs.logInfo("zonelist_page", "zone_list", "Region Details Not found Exception");
              pr.hide();
              Fluttertoast.showToast(
                  msg: "Unable to find Region Details",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
            }
          } else {
            pr.hide();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => ward_li_screen()));
          }
        } catch (e) {
          FlutterLogs.logInfo("zonelist_page", "zone_list", "Zone Details not found Exception");
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => zone_li_screen()));
            }
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => dashboard_screen()));
          }
        }
      } else {
        FlutterLogs.logInfo("zonelist_page", "zone_list", "No Network");
        Fluttertoast.showToast(
            msg: "No Network. Please try again later",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    });
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    FlutterLogs.logInfo("zonelist_page", "zone_list", "Zone Details Exception with server");
    if (error.message == "Session expired!") {
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => zone_li_screen()));
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
