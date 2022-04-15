import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/device_count_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/device_list_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/ui/maintenance/gateway/gw_maintenance_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/ilm_maintenance_screen.dart';
import 'package:flutterlumin/src/ui/qr_scanner/qr_scanner.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../installation/ccms/ccms_install_cam_screen.dart';
import '../installation/gateway/gateway_install_cam_screen.dart';
import '../installation/ilm/ilm_install_cam_screen.dart';
import '../maintenance/ccms/ccms_maintenance_screen.dart';
import '../map/map_view_screen.dart';

class dashboard_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return dashboard_screenState();
  }
}

class dashboard_screenState extends State<dashboard_screen> {
  int _selectedIndex = 0;
  bool clickedCentreFAB = false;
  var _tag = "DashboardPage";
  var isPressed = false;
  late ProgressDialog pr;
  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();

  @override
  // TODO: implement context
  BuildContext get context => super.context;

  @override
  void initState() {
    super.initState();
    setUpLogs();
  }

  final List<Widget> _widgetOptions = <Widget>[
    device_count_screen(),
    map_view_screen(),
    device_list_screen()
  ];

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

  @override
  Widget build(BuildContext context) {
    Color? _foreground = Colors.green[900];
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
          final result = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 0),
              backgroundColor: Colors.white,
              title: Text(app_display_name,
                  style: const TextStyle(
                      fontSize: 25.0,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                      color: liorange)),
              content: Text(app_logout_msg,
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
                  child: Text(app_logout_no,
                      style: const TextStyle(
                          fontSize: 25.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                ),
                TextButton(
                  child: Text(app_logout_yes,
                      style: const TextStyle(
                          fontSize: 25.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                ),
              ],
            ),
          );
          return result;
        },
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              _widgetOptions.elementAt(_selectedIndex),
              //this is the code for the widget container that comes from behind the floating action button (FAB)
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
              )
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          //specify the location of the FAB
          floatingActionButton: FloatingActionButton(
            backgroundColor: _foreground,
            onPressed: () {
              var currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              deviceFetcher(context);
            },
            tooltip: app_scan_qr,
            child: Container(
              margin: EdgeInsets.all(15.0),
              child: Icon(Icons.qr_code),
            ),
            elevation: 3.0,
          ),
          backgroundColor: thbDblue,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.analytics,
                  color: Colors.grey,
                  size: 45,
                ),
                label: 'Dashboard',
                activeIcon: Icon(
                  Icons.analytics,
                  color: darkgreen,
                  size: 45,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.map,
                  color: Colors.grey,
                  size: 45,
                ),
                label: 'Map View',
                activeIcon: Icon(
                  Icons.map,
                  color: darkgreen,
                  size: 45,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.list,
                  color: Colors.grey,
                  size: 45,
                ),
                label: 'Device List',
                activeIcon: Icon(
                  Icons.list,
                  color: darkgreen,
                  size: 45,
                ),
              ),
            ],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ));
  }

  Future<void> deviceFetcher(BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => QRScreen()),
                (route) => true).then((value) async {
          if (value != null) {
            // if (value.toString().length == 6) {
            fetchGWDeviceDetails(value, context);
          } else {
            Fluttertoast.showToast(
                msg: device_qr_nt_found,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        });
      } else {
        // FlutterLogs.logInfo("Dashboard_Page", "Dashboard", "No Network");
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
  Future<Device?> fetchGWDeviceDetails(
      String deviceName, BuildContext context) async {
    Utility.isConnected().then((value) async {
      var gofenceValidation = false;
      if (value) {
        try {
          pr.show();
          Device response;
          String? SelectedRegion;
          var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
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

                /*try {
                  List<TsKvEntry> faultresponser;
                  faultresponser = await tbClient
                      .getAttributeService()
                      .getselectedLatestTimeseries(response.id!.id!, "version");
                  if (faultresponser.isNotEmpty) {
                    prefs.setString('firmwareVersion',
                        faultresponser.first.getValue().toString());
                  }
                } catch (e) {
                  var message = toThingsboardError(e, context);
                  FlutterLogs.logInfo(
                      "Luminator 2.0", "dashboard_page", "");
                }

                List<String> myLists = [];
                myLists.add("version");

                List<AttributeKvEntry> deviceresponser;

                deviceresponser = (await tbClient
                    .getAttributeService()
                    .getAttributeKvEntries(response.id!, myLists));

                if (deviceresponser.isNotEmpty) {
                  prefs.setString('firmwareVersion',
                      deviceresponser.first.getValue().toString());*/

                prefs.setString('deviceName', deviceName);

                var relationDetails = await tbClient
                    .getEntityRelationService()
                    .findInfoByTo(response.id!);

                List<AttributeKvEntry> responserse;

                /* var SelectedWard = prefs.getString("SelectedWard").toString();
                  DBHelper dbHelper = new DBHelper();
                  var wardDetails =
                      await dbHelper.ward_basedDetails(SelectedWard);
                  if (wardDetails.isNotEmpty) {
                    wardDetails.first.wardid;

                    List<String> wardist = [];
                    wardist.add("geofence");

                    var wardresponser = await tbClient
                        .getAttributeService()
                        .getFirmAttributeKvEntries(
                            wardDetails.first.wardid!, wardist);

                    if (wardresponser.isNotEmpty) {
                      if (wardresponser.first.getValue() == "true") {
                        gofenceValidation = true;
                        prefs.setString('geoFence', "true");
                      } else {
                        gofenceValidation = false;
                        prefs.setString('geoFence', "false");
                      }
                    }
                  }*/

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
                    // FlutterLogs.logInfo("Luminator 2.0", "dashboard_page", "");
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
                    prefs.setString('devicetimeStamp',
                        atresponser.elementAt(0).getLastUpdateTs().toString());

                    try {

                      List<String> myLister = [];
                      myLister.add("landmark");

                      responserse = (await tbClient
                          .getAttributeService()
                          .getAttributeKvEntries(response.id!, myLister));

                      if (responserse.isNotEmpty) {
                        prefs.setString(
                            'location',
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

                    }catch(e){
                      var message = toThingsboardError(e, context);
                    }

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
                            builder: (context) => const GWMaintenanceScreen()),
                      );
                    }
                  } else {
                    // FlutterLogs.logInfo("Dashboard_Page", "Dashboard",
                    //     "No attributes key found");
                    pr.hide();
                    refreshPage(context);
                    //"" No Active attribute found
                  }
                }
                /*} else {
                  FlutterLogs.logInfo(
                      "Dashboard_Page", "Dashboard", "No version attributes key found");
                  pr.hide();
                  refreshPage(context);
                  //"" No Firmware Device Found
                }*/
              } else {
                // FlutterLogs.logInfo(
                //     "Dashboard_Page", "Dashboard", "No Device Details Found");
                pr.hide();
                refreshPage(context);
                //"" No Device Found
              }
            } else {
              Fluttertoast.showToast(
                  msg: device_selec_regions,
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
                msg: device_selec_regions,
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
          FirebaseCrashlytics.instance.crash();
          // FlutterLogs.logInfo(
          //     "Dashboard_Page", "Dashboard", "Device Details Fetch Exception");
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

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void refreshPage(context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => dashboard_screen()));
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    // FlutterLogs.logInfo("Dashboard_Page", "Dashboard",
    //     "Global Error " + error.message.toString());
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
}
