import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            response = (await tbClient
                .getDeviceService()
                .getTenantDevice(deviceName)) as Device;

            if (response.toString().isNotEmpty) {
              List<String> myLists = [];
              myLists.add("firmware_versions");

              List<AttributeKvEntry> deviceresponser;

              deviceresponser = (await tbClient
                  .getAttributeService()
                  .getAttributeKvEntries(response.id!, myLists));

              if (deviceresponser.isNotEmpty) {
                prefs.setString('firmwareVersion',
                    deviceresponser.first.getValue().toString());
                prefs.setString('deviceName', deviceName);

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
                }

                List<String> myList = [];
                myList.add("active");

                List<AttributeKvEntry> responser;

                responser = (await tbClient
                    .getAttributeService()
                    .getAttributeKvEntries(response.id!, myList));

                if (responser.isNotEmpty) {
                  prefs.setString(
                      'deviceStatus', responser.first.getValue().toString());
                  prefs.setString('devicetimeStamp',
                      responser.elementAt(0).getLastUpdateTs().toString());

                  List<String> myLister = [];
                  myLister.add("landmark");
                  // myLister.add("location");

                  List<AttributeKvEntry> responserse;

                  responserse = (await tbClient
                      .getAttributeService()
                      .getAttributeKvEntries(response.id!, myLister));

                  if (responserse.isNotEmpty) {
                    prefs.setString(
                        'location', responserse.first.getValue().toString());
                    prefs.setString('deviceId', response.id!.toString());
                    prefs.setString('deviceName', deviceName);

                    var SelectedWard =
                        prefs.getString("SelectedWard").toString();
                    DBHelper dbHelper = new DBHelper();
                    var wardDetails =
                        await dbHelper.ward_basedDetails(SelectedWard);
                    if (wardDetails.isNotEmpty) {
                      wardDetails.first.wardid;

                      List<String> wardist = [];
                      myList.add("geofence");

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
                    }

                    var relationDetails = await tbClient
                        .getEntityRelationService()
                        .findInfoByTo(response.id!);

                    if (relationDetails.length.toString() == "0") {
                      if (SelectedRegion.length.toString() != "0") {
                        pr.hide();
                        if (response.type == ilm_deviceType) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ilmcaminstall()),
                          );

                          // Navigator.of(context).pushReplacement(MaterialPageRoute(
                          //     builder: (BuildContext context) =>
                          //         const ilmcaminstall()));
                        } else if (response.type == ccms_deviceType) {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ccmscaminstall()),
                          );

                          // Navigator.of(context).pushReplacement(
                          //     MaterialPageRoute(
                          //         builder: (BuildContext context) =>
                          //             const ccmscaminstall()));
                        } else if (response.type == Gw_deviceType) {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const gwcaminstall()),
                          );

                          // Navigator.of(context).pushReplacement(
                          //     MaterialPageRoute(
                          //         builder: (BuildContext context) =>
                          //             const gwcaminstall()));
                        }
                      } else {
                        // Navigator.pop(context);
                        pr.hide();
                        Fluttertoast.showToast(
                            msg:
                                "Kindly Choose your Region, Zone and Ward to Install",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0);
                        // refreshPage(context);
                      }
                    } else {
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

                        // Navigator.of(context).pushReplacement(MaterialPageRoute(
                        //     builder: (BuildContext context) =>
                        //         const MaintenanceScreen()));
                      } else if (response.type == ccms_deviceType) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CCMSMaintenanceScreen()),
                        );

                        // Navigator.of(context).pushReplacement(MaterialPageRoute(
                        //     builder: (BuildContext context) =>
                        //         const CCMSMaintenanceScreen()));
                      } else if (response.type == Gw_deviceType) {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GWMaintenanceScreen()),
                        );

                        // Navigator.of(context).pushReplacement(MaterialPageRoute(
                        //     builder: (BuildContext context) =>
                        //         const GWMaintenanceScreen()));

                      }
                    }
                  } else {
                    pr.hide();
                    refreshPage(context);
                    //"" No landmark attribute found
                  }
                } else {
                  pr.hide();
                  refreshPage(context);
                  //"" No Active attribute found
                }
              } else {
                pr.hide();
                refreshPage(context);
                //"" No Firmware Device Found
              }
            } else {
              pr.hide();
              refreshPage(context);
              //"" No Device Found
            }
          } else {
            pr.hide();
            refreshPage(context);
          }
        } catch (e) {
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
