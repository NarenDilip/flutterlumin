import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../installation/ccms/ccms_install_cam_screen.dart';
import '../installation/gateway/gateway_install_cam_screen.dart';
import '../installation/ilm/ilm_install_cam_screen.dart';
import '../maintenance/ccms/ccms_maintenance_screen.dart';
import '../map/map_view_screen.dart';

// Dashboard Screen , consist of three classes in botton tab bar, defaultly
// it will open with device count screen, In Dashboard we implemented the remote
// config operations while user opens the dashboard page it will check with
// remote config for latest app updation, In Dashboard we have floating action button
// is for scanning the QR Codes,In Dashbaord the scanned qr will be validated using
// the server connectivity. fetching device details and default server error
// listener is implemented

class dashboard_screen extends StatefulWidget {

  int selectedPage;
  dashboard_screen({required this.selectedPage});

  @override
  State<StatefulWidget> createState() {
    return dashboard_screenState();
  }
}

class dashboard_screenState extends State<dashboard_screen> {
  bool clickedCentreFAB = false;
  var _tag = "DashboardPage";
  var isPressed = false;
  late ProgressDialog pr;
  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();

  late final PackageInfo _packageInfo;
  late final String enforcedBuildNumber;
  late final bool forceUpdate;
  final RemoteConfig remoteConfig = RemoteConfig.instance;
  late bool visibility = false;

  bool iscamerapermission = false;
  bool islocationpermission = false;

  @override
  // TODO: implement context
  BuildContext get context => super.context;

  @override
  void initState() {
    super.initState();
    // setUpLogs();
    _initPackageInfo();
    _enforcedVersion();
  }

  Future<void> launchAppStore() async {
    /// Depending on where you are putting this method you might need
    /// to pass a reference from your _packageInfo.
    final appPackageName = _packageInfo.packageName;

    if (Platform.isAndroid) {
      await launch(
          "https://play.google.com/store/apps/details?id=$appPackageName");
    } else if (Platform.isIOS) {
      await launch("market://details?id=$appPackageName");
    }
  }

  Future<void> _initPackageInfo() async {
    // PackageInfo _packageInfo = await PackageInfo.fromPlatform();
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _enforcedVersion() async {
    final RemoteConfig remoteConfig = RemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await remoteConfig.fetchAndActivate();
    setState(() {
      enforcedBuildNumber = remoteConfig.getString('version_code');
      visibility = remoteConfig.getBool('force_update');
    });
    if (int.parse(_packageInfo.buildNumber) < int.parse(enforcedBuildNumber)) {
      //How to force update?
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text('New version available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          content: Text('Please update app to new version',
              textAlign: TextAlign.left,
              style: const TextStyle(
              fontSize: 20.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.normal,
              color: Colors.black)),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Visibility(visible: visibility, child: Container(
                  child: Text('Not Now',
                      style: const TextStyle(
                          fontSize: 18.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                ))),
            TextButton(
                child: Text('Update',
                    style: const TextStyle(
                        fontSize: 18.0,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                onPressed: () async {
                  launchAppStore();
                })
          ],
          // actions: [
          //   TextButton(
          //     onPressed: launchAppStore,
          //     child: Text('Update',style: const TextStyle(
          //         fontSize: 18.0,
          //         fontFamily: "Montserrat",
          //         fontWeight: FontWeight.normal,
          //         color: Colors.green)),
          //   ),
          // ],
        ),
      );
    }
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
              _widgetOptions.elementAt(widget.selectedPage),
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
              requestCameraPermission();
              var currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if(iscamerapermission == false) {
                Fluttertoast.showToast(
                    msg:"Permission denied",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);
              } else {
                deviceFetcher(context);
              }
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
            currentIndex: widget.selectedPage,
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
            onTap: (index) async{
              requestLocationPermission();
              if(islocationpermission == false){
                Fluttertoast.showToast(
                    msg:"Permission denied",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);
              } else {
                setState(() {
                  widget.selectedPage = index;
                });
              }

            },
          ),
        ));
  }

  Future<void> requestCameraPermission() async {

    final status = await Permission.camera.request();

    if (status == PermissionStatus.granted) {
      iscamerapermission = true;
    } else if (status == PermissionStatus.denied) {
      iscamerapermission = false;
      await openAppSettings();
    } else if (status == PermissionStatus.permanentlyDenied) {
      iscamerapermission = false;
      await openAppSettings();
    }
  }
  Future<void> requestLocationPermission() async {

    final status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      islocationpermission = true;
    } else if (status == PermissionStatus.denied) {
      islocationpermission = false;
      await openAppSettings();
    } else if (status == PermissionStatus.permanentlyDenied) {
      islocationpermission = false;
      await openAppSettings();
    }
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
          var tbClient =
              ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
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
                    } catch (e) {
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
          // FirebaseCrashlytics.instance.crash();
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
        builder: (BuildContext context) => dashboard_screen(selectedPage: 0,)));
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
            builder: (BuildContext context) => dashboard_screen(selectedPage: 0,)));
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
