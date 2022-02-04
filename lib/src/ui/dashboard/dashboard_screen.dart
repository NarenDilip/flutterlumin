import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/device_count_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/device_list_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/ilm_maintenance_screen.dart';
import 'package:flutterlumin/src/ui/qr_scanner/qr_scanner.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../installation/ccms/ccms_install_cam_screen.dart';
import '../installation/ilm/ilm_install_cam_screen.dart';
import 'map_view_screen.dart';

class dashboard_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return dashboard_screenState();
  }
}

class dashboard_screenState extends State<dashboard_screen> {
  int _selectedIndex = 0;
  bool clickedCentreFAB = false;
  var isPressed = false;
  late ProgressDialog pr;

  @override
  // TODO: implement context
  BuildContext get context => super.context;

  final List<Widget> _widgetOptions = <Widget>[
    device_count_screen(),
    map_view_screen(),
    device_list_screen()
  ];

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
              title: Text("Luminator",
                  style: const TextStyle(
                      fontSize: 25.0,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                      color: liorange)),
              content: Text("Are you sure you want to exit Luminator?",
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
                          fontSize: 25.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                ),
                TextButton(
                  child: Text('YES',
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
              // Align(
              //   alignment: FractionalOffset.center,
              //   //in this demo, only the button text is updated based on the bottom app bar clicks
              //   child: RaisedButton(
              //     // child: Text(""),
              //     onPressed: () {},
              //   ),
              // ),
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
              deviceFetcher(context);
            },
            tooltip: "SCAN QR",
            child: Container(
              margin: EdgeInsets.all(15.0),
              child: Icon(Icons.qr_code),
            ),
            elevation: 3.0,
          ),
          backgroundColor: thbDblue,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: thbDblue,
            currentIndex: _selectedIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.analytics,
                  color: Colors.black,
                  size: 45,
                ),
                label: 'Dashboard',
                activeIcon: Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 45,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.map,
                  color: Colors.black,
                  size: 45,
                ),
                  label : 'Map View',
                activeIcon: Icon(
                  Icons.map,
                  color: Colors.white,
                  size: 45,
                ),
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.list,
                  color: Colors.black,
                  size: 45,
                ),
                label: 'Device List',
                activeIcon: Icon(
                  Icons.list,
                  color: Colors.white,
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
            late Future<Device?> entityFuture;
            // Utility.progressDialog(context);
            entityFuture = fetchDeviceDetails(value, context);
          } else {
            Fluttertoast.showToast(
                msg: "No QRs Found",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
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

// Fetching the device details from smart server
  @override
  Future<Device?> fetchDeviceDetails(
      String deviceName, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          // Utility.progressDialog(context);
          pr.show();
          Device response;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();
          response = await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName) as Device;
          if (response != null) {
            DeviceCredentials deviceCredentials = (await tbClient
                    .getDeviceService()
                    .getDeviceCredentialsByDeviceId(response.id!.id!))
                as DeviceCredentials;
            if (deviceCredentials.credentialsId.length == 16) {
              if (response.type == ilm_deviceType) {
                fetchSmartDeviceDetails(
                    deviceName, response.id!.id.toString(), context);
              } else if (response.type == ccms_deviceType) {
                fetchCCMSDeviceDetails(
                    deviceName, response.id!.id.toString(), context);
              } else if (response.type == Gw_deviceType) {
              } else {
                pr.hide();
                // Navigator.pop(context);
                Fluttertoast.showToast(
                    msg: "Device Details Not Found",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);
              }
            } else {
              // Navigator.pop(context);
              pr.hide();
              Fluttertoast.showToast(
                  msg:
                      "Device Credentials are invalid, Device not despatched properly",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
            }
          } else {
            // Navigator.pop(context);
            pr.hide();
            Fluttertoast.showToast(
                msg: device_toast_msg + deviceName + device_toast_notfound,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => dashboard_screen()));
          }
        } catch (e) {
          // Navigator.pop(context);
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              fetchDeviceDetails(deviceName, context);
            }
          } else {
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

  @override
  Future<Device?> fetchCCMSDeviceDetails(
      String deviceName, String string, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          pr.show();
          Device response;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          response = (await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName)) as Device;

          var relationDetails = await tbClient
              .getEntityRelationService()
              .findInfoByTo(response.id!);

          if (relationDetails.length.toString() == "0") {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            var SelectedRegion = prefs.getString("SelectedRegion").toString();
            if (SelectedRegion != "null") {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => ccmscaminstall()));
            } else {
              // Navigator.pop(context);
              pr.hide();
              Fluttertoast.showToast(
                  msg: "Kindly Choose your Region, Zone and Ward to Install",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
              // refreshPage(context);
            }
          } else {}
          pr.hide();
        } catch (e) {
          pr.hide();
        }
      }
    });
  }

  @override
  Future<Device?> fetchSmartDeviceDetails(
      String deviceName, String deviceid, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          // Utility.progressDialog(context);
          pr.show();
          Device response;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          response = (await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName)) as Device;

          var relationDetails = await tbClient
              .getEntityRelationService()
              .findInfoByTo(response.id!);

          List<String> firstmyList = [];
          firstmyList.add("lmp");

          SharedPreferences prefs = await SharedPreferences.getInstance();

          try {
            List<TsKvEntry> faultresponser;
            faultresponser = await tbClient
                    .getAttributeService()
                    .getselectedLatestTimeseries(response.id!.id!, "lmp")
                as List<TsKvEntry>;
            if (faultresponser.length != 0) {
              prefs.setString(
                  'faultyStatus', faultresponser.first.getValue().toString());
            }
          } catch (e) {
            var message = toThingsboardError(e, context);
          }

          List<String> myList = [];
          myList.add("lampWatts");
          myList.add("active");

          List<BaseAttributeKvEntry> responser;

          responser = (await tbClient
                  .getAttributeService()
                  .getAttributeKvEntries(response.id!, myList))
              as List<BaseAttributeKvEntry>;

          prefs.setString(
              'deviceStatus', responser.first.kv.getValue().toString());
          prefs.setString(
              'deviceWatts', responser.last.kv.getValue().toString());
          prefs.setString(
              'devicetimeStamp', responser.first.lastUpdateTs.toString());

          List<String> myLister = [];
          // myLister.add("landmark");
          myLister.add("location");

          List<AttributeKvEntry> responserse;

          responserse = (await tbClient
                  .getAttributeService()
                  .getAttributeKvEntries(response.id!, myLister))
              as List<AttributeKvEntry>;

          if (responserse.length != "0") {
            prefs.setString(
                'location', responserse.first.getValue().toString());
            prefs.setString('deviceId', deviceid);
            prefs.setString('deviceName', deviceName);

            List<String> versionlist = [];
            versionlist.add("version");

            List<AttributeKvEntry> version_responserse;

            version_responserse = (await tbClient
                    .getAttributeService()
                    .getAttributeKvEntries(response.id!, versionlist))
                as List<AttributeKvEntry>;

            if (version_responserse.length == 0) {
              prefs.setString('version', "0");
            } else {
              prefs.setString('version', version_responserse.first.getValue());
            }

            if (relationDetails.length.toString() == "0") {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              var SelectedRegion = prefs.getString("SelectedRegion").toString();
              if (SelectedRegion != "null") {
                List<String> myList = [];
                myList.add("faulty");
                List<AttributeKvEntry> responser;

                responser = (await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(response.id!, myList))
                    as List<AttributeKvEntry>;

                var faultyDetails = false;
                if (responser.length == 0) {
                  faultyDetails = false;
                } else {
                  faultyDetails = responser.first.getValue();
                }

                if (faultyDetails == false) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => ilmcaminstall()));
                } else {
                  // Navigator.pop(context);
                  pr.hide();
                  Fluttertoast.showToast(
                      msg:
                          "Device Currently in Faulty State Unable to Install.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 16.0);

                  // refreshPage(context);
                }
              } else {
                // Navigator.pop(context);
                pr.hide();
                Fluttertoast.showToast(
                    msg: "Kindly Choose your Region, Zone and Ward to Install",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);

                // refreshPage(context);
              }
            } else {
              // Navigator.pop(context);
              pr.hide();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => MaintenanceScreen()));
            }
          } else {
            // Navigator.pop(context);
            pr.hide();
            calltoast("Device Details Not Found");

            // refreshPage(context);
          }
        } catch (e) {
          // Navigator.pop(context);
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              fetchDeviceDetails(deviceName, context);
            }
          } else {
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

  void refreshPage(context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => dashboard_screen()));
  }

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
}
