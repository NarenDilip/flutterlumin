import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/ward_model.dart';
import 'package:flutterlumin/src/thingsboard/model/asset_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/asset_id.dart';
import 'package:flutterlumin/src/thingsboard/model/id/device_id.dart';
import 'package:flutterlumin/src/thingsboard/model/relation_models.dart';
import 'package:flutterlumin/src/thingsboard/model/telemetry_models.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

import '../../thingsboard/error/thingsboard_error.dart';
import '../../thingsboard/model/model.dart';
import '../maintenance/ilm/ilm_maintenance_screen.dart';

// Ward list screen in this we need to show the ward details already
// inserted in local database, based on the ward selection we need to fetch the
// total number of ILM,CCMS and Gateway devices are present and store in local
// storages, ui we need to create a list view with ward details.

class ward_li_screen extends StatefulWidget {
  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();

  @override
  State<StatefulWidget> createState() {
    return ward_li_screen_state();
  }
}

class ward_li_screen_state extends State<ward_li_screen> {
  // return Scaffold(body: regionListview());
  List<String>? _allUsers = [];
  List<String>? _foundUsers = [];
  List<DeviceId>? relatedDevices = [];
  List<AssetId>? AssetDevices = [];

  List<DeviceId>? ILMactiveDevice = [];

  List<DeviceId>? activeDevice = [];
  List<DeviceId>? nonactiveDevices = [];
  List<DeviceId>? ncDevices = [];

  List<DeviceId>? ccms_activeDevice = [];
  List<DeviceId>? ccms_nonactiveDevices = [];
  List<DeviceId>? ccms_ncDevices = [];

  List<DeviceId>? gw_activeDevice = [];
  List<DeviceId>? gw_nonactiveDevices = [];
  List<DeviceId>? gw_ncDevices = [];

  String selectedZone = "0";
  String selectedWard = "0";
  late ProgressDialog pr;

  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();
  int index = 0;

  @override
  initState() {
    // at the beginning, all users are shown
    loadDetails();
    setUpLogs();
    getIndex();
  }

  void getIndex() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
      index = prefs.getInt("Selected_index")!;
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

  void loadDetails() async {
    DBHelper dbHelper = DBHelper();

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
    selectedZone = sharedPreferences.getString("SelectedZone").toString();

    if (selectedZone != "0") {
      List<Ward> wardser = await dbHelper.ward_getDetails();
      List<Ward> wards = await dbHelper.ward_regionbasedDetails(selectedZone);
      // wards = (await dbHelper.ward_zonebasedDetails(selectedZone)) as List<Ward>;
      // wards.then((data) {
      for (int i = 0; i < wards.length; i++) {
        String regionname = wards[i].wardname.toString();
        _allUsers?.add(regionname);
      }
      setState(() {
        _foundUsers = _allUsers!;
      });
      // }, onError: (e) {
      //   print(e);
      // });
    }
    // setState(() {
    //   _foundUsers = _allUsers! ;
    // });
  }

  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers!;
    } else {
      results = _allUsers!
          .where((user) =>
              user.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }

  loadLocalData(context) {
    Utility.isConnected().then((value) async {
      if (value) {
        // Utility.progressDialog(context);
        pr.show();
        try {
          var sharedPreferences =
              await SharedPreferences.getInstance() as SharedPreferences;
          sharedPreferences.setString("SelectedWard", selectedWard);

          var tbClient = await ThingsboardClient(
              FlavorConfig.instance.variables["baseUrl"]);
          tbClient.smart_init();

          relatedDevices!.clear();
          AssetDevices!.clear();

          activeDevice!.clear();
          nonactiveDevices!.clear();

          ccms_activeDevice!.clear();
          ccms_nonactiveDevices!.clear();

          Asset response;
          response = await tbClient
              .getAssetService()
              .getTenantAsset(selectedWard) as Asset;

          var relatedDeviceId;
          if (response != null) {
            List<EntityRelationInfo> wardlist = await tbClient
                .getEntityRelationService()
                .findInfoByAssetFrom(response.id!);

            if (wardlist.length != 0) {
              for (int i = 0; i < wardlist.length; i++) {
                if (wardlist.elementAt(i).to.entityType.index == 6) {
                  relatedDeviceId = wardlist.elementAt(i).to;
                  ILMactiveDevice?.add(relatedDeviceId);
                } else {
                  relatedDeviceId = wardlist.elementAt(i).to;
                  AssetDevices?.add(relatedDeviceId);
                }
              }

              if (ILMactiveDevice != null) {
                for (int p = 0; p < ILMactiveDevice!.length; p++) {
                  Device ilm_device = (await tbClient.getDeviceService().getDevice(
                        ILMactiveDevice!.elementAt(p).id.toString())) as Device;
                  if (ilm_device.type == "lumiNode") {
                    List<String> myList = [];
                    myList.add("active");

                    Device data_response;
                    data_response = (await tbClient
                            .getDeviceService()
                            .getDevice(
                                relatedDevices!.elementAt(p).id.toString()))
                        as Device;
                    List<AttributeKvEntry> vresponser;
                    vresponser = await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(
                            relatedDevices!.elementAt(p), myList);

                    if (vresponser != null) {
                      if (vresponser.first.getValue().toString() == "true") {

                      }
                    }
                  }else{

                  }
                }
              }

              try {
                var assetrelatedwardid;
                for (int j = 0; j < AssetDevices!.length; j++) {
                  List<EntityRelationInfo> relationdevicelist = await tbClient
                      .getEntityRelationService()
                      .findInfoByAssetFrom(AssetDevices!.elementAt(j));

                  for (int k = 0; k < relationdevicelist.length; k++) {
                    if (relationdevicelist.length != 0) {
                      assetrelatedwardid = relationdevicelist.elementAt(k).to;
                      relatedDevices?.add(assetrelatedwardid);
                    }
                  }
                }
              } catch (e) {}

              if (relatedDevices != null) {
                for (int k = 0; k < relatedDevices!.length; k++) {
                  List<String> myList = [];
                  myList.add("active");

                  Device data_response;
                  data_response = (await tbClient.getDeviceService().getDevice(
                      relatedDevices!.elementAt(k).id.toString())) as Device;

                  if (data_response.type == "lumiNode") {
                    List<AttributeKvEntry> vresponser;
                    vresponser = await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(
                            relatedDevices!.elementAt(k), myList);

                    if (vresponser != null) {
                      if (vresponser.first.getValue().toString() == "true") {
                        activeDevice!.add(relatedDevices!.elementAt(k));
                      } else if (vresponser.first.getValue().toString() ==
                          "false") {
                        nonactiveDevices!.add(relatedDevices!.elementAt(k));
                      } else {
                        ncDevices!.add(relatedDevices!.elementAt(k));
                      }
                    }

                    var totalval = activeDevice!.length +
                        nonactiveDevices!.length +
                        ncDevices!.length;
                    var parttotalval =
                        activeDevice!.length + nonactiveDevices!.length;
                    var ncdevices = parttotalval - totalval;
                    var noncomdevice = "";
                    if (ncdevices.toString().contains("-")) {
                      noncomdevice = ncdevices.toString().replaceAll("-", "");
                    } else {
                      noncomdevice = ncdevices.toString();
                    }

                    sharedPreferences.setString(
                        'totalCount', totalval.toString());
                    sharedPreferences.setString(
                        'activeCount', activeDevice!.length.toString());
                    sharedPreferences.setString(
                        'nonactiveCount', nonactiveDevices!.length.toString());
                    sharedPreferences.setString('ncCount', noncomdevice);
                  } else if (data_response.type == "CCMS") {
                    List<AttributeKvEntry> sresponser;
                    sresponser = await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(
                            relatedDevices!.elementAt(k), myList);

                    if (sresponser != null) {
                      if (sresponser.first.getValue().toString() == "true") {
                        ccms_activeDevice!.add(relatedDevices!.elementAt(k));
                      } else if (sresponser.first.getValue().toString() ==
                          "false") {
                        ccms_nonactiveDevices!
                            .add(relatedDevices!.elementAt(k));
                      } else {
                        ccms_ncDevices!.add(relatedDevices!.elementAt(k));
                      }
                    }

                    var ccms_totalval = ccms_activeDevice!.length +
                        ccms_nonactiveDevices!.length +
                        ccms_ncDevices!.length;
                    var ccms_parttotalval = ccms_activeDevice!.length +
                        ccms_nonactiveDevices!.length;
                    var ccms_ncdevices = ccms_parttotalval - ccms_totalval;
                    var ccms_noncomdevice = "";
                    if (ccms_ncdevices.toString().contains("-")) {
                      ccms_noncomdevice =
                          ccms_ncdevices.toString().replaceAll("-", "");
                    } else {
                      ccms_noncomdevice = ccms_ncdevices.toString();
                    }

                    sharedPreferences.setString(
                        'ccms_totalCount', ccms_totalval.toString());
                    sharedPreferences.setString('ccms_activeCount',
                        ccms_activeDevice!.length.toString());
                    sharedPreferences.setString('ccms_nonactiveCount',
                        ccms_nonactiveDevices!.length.toString());
                    sharedPreferences.setString(
                        'ccms_ncCount', ccms_noncomdevice);
                  } else if (data_response.type == "Gateway") {
                    List<AttributeKvEntry> kresponser;
                    kresponser = await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(
                            relatedDevices!.elementAt(k), myList);

                    if (kresponser != null) {
                      if (kresponser.first.getValue().toString() == "true") {
                        gw_activeDevice!.add(relatedDevices!.elementAt(k));
                      } else if (kresponser.first.getValue().toString() ==
                          "false") {
                        gw_nonactiveDevices!.add(relatedDevices!.elementAt(k));
                      } else {
                        gw_ncDevices!.add(relatedDevices!.elementAt(k));
                      }
                    }

                    var gw_totalval = gw_activeDevice!.length +
                        gw_nonactiveDevices!.length +
                        gw_ncDevices!.length;
                    var gw_parttotalval =
                        gw_activeDevice!.length + gw_nonactiveDevices!.length;
                    var gw_ncdevices = gw_parttotalval - gw_totalval;
                    var gw_noncomdevice = "";
                    if (gw_ncdevices.toString().contains("-")) {
                      gw_noncomdevice =
                          gw_ncdevices.toString().replaceAll("-", "");
                    } else {
                      gw_noncomdevice = gw_ncdevices.toString();
                    }

                    sharedPreferences.setString(
                        'gw_totalCount', gw_totalval.toString());
                    sharedPreferences.setString(
                        'gw_activeCount', gw_activeDevice!.length.toString());
                    sharedPreferences.setString('gw_nonactiveCount',
                        gw_nonactiveDevices!.length.toString());
                    sharedPreferences.setString('gw_ncCount', gw_noncomdevice);
                  }
                }

                pr.hide();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => dashboard_screen(selectedPage: index,)));
              }
            } else {
              /*FlutterLogs.logInfo("wardlist_page", "ward_list",
                  "No Ward Details Relations found");*/
              pr.hide();
              Fluttertoast.showToast(
                  msg: app_no_ward_relation,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);

              sharedPreferences.setString('totalCount', "0");
              sharedPreferences.setString('activeCount', "0");
              sharedPreferences.setString('nonactiveCount', "0");
              sharedPreferences.setString('ncCount', "0");

              pr.hide();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => dashboard_screen(selectedPage: index,)));
            }
          }
        } catch (e) {
          /*FlutterLogs.logInfo(
              "wardlist_page", "ward_list", "No Ward Details found Exception");*/
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              loadLocalData(context);
            }
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => dashboard_screen(selectedPage: index,)));
          }
        }
      } else {
        /*FlutterLogs.logInfo("wardlist_page", "ward_list", "No Network");*/
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => zone_li_screen()));
          return true;
        },
        child: Container(
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
                  "Select Ward",
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
                                  selectedWard =
                                      _foundUsers!.elementAt(index).toString();
                                  loadLocalData(context);
                                });
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
        )));
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    /*FlutterLogs.logInfo(
        "wardlist_page", "ward_list", "Ward Details Exception with server");*/
    if (error.message == "Session expired!") {
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => ward_li_screen()));
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
