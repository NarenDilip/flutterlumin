import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/device_list_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/map_view_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/device_count_screen.dart';
import 'package:flutterlumin/src/ui/installation/ilm/ilm_installation_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/ilm_maintenance_screen.dart';
import 'package:flutterlumin/src/ui/qr_scanner/qr_scanner.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterlumin/src/ui/login/login_thingsboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class dashboard_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return dashboard_screenState();
  }
}

class dashboard_screenState extends State<dashboard_screen> {
  int _selectedIndex = 0;
  bool clickedCentreFAB = false;
  @override
  // TODO: implement context
  BuildContext get context => super.context;

  final List<Widget> _widgetOptions = <Widget>[
    device_count_screen(),
    // map_view_screen(),
    device_list_screen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              height:
                  clickedCentreFAB ? MediaQuery.of(context).size.height : 10.0,
              width:
                  clickedCentreFAB ? MediaQuery.of(context).size.height : 10.0,
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
        onPressed: () {
          deviceFetcher(context);
        },
        tooltip: "Centre FAB",
        child: Container(
          margin: EdgeInsets.all(15.0),
          child: Icon(Icons.qr_code),
        ),
        elevation: 3.0,
      ),
      backgroundColor: Colors.black12,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: liorange,
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
            label:'Dashboard',
            activeIcon: Icon(
              Icons.analytics,
              color: Colors.white,
              size: 45,
            ),
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.map,
          //     color: Colors.black,
          //     size: 45,
          //   ),
          //   title: Text('Map View'),
          //   activeIcon: Icon(
          //     Icons.map,
          //     color: Colors.white,
          //     size: 45,
          //   ),
          // ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
              color: Colors.black,
              size: 45,
            ),
            label:'Device List',
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
    );
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
          late Future<Device?> entityFuture;
          Utility.progressDialog(context);
          entityFuture = fetchDeviceDetails(value, context);
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
        Device response;
        Future<List<EntityGroupInfo>> deviceResponse;
        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();
        response = await tbClient.getDeviceService().getTenantDevice(deviceName)
            as Device;
        if (response.name.isNotEmpty) {
          if (response.type == ilm_deviceType) {
            fetchSmartDeviceDetails(
                deviceName, response.id!.id.toString(), context);
          } else if (response.type == ccms_deviceType) {
          } else if (response.type == Gw_deviceType) {
          } else {
            Fluttertoast.showToast(
                msg: "Device Details Not Found",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
            Navigator.pop(context);
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
          Navigator.pop(context);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => dashboard_screen()));
        }
      } catch (e) {
        var message = toThingsboardError(e,context);
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
          Navigator.pop(context);
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
Future<Device?> fetchSmartDeviceDetails(
    String deviceName, String deviceid, BuildContext context) async {
  Utility.isConnected().then((value) async {
    if (value) {
      try {
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

        List<String> myList = [];
        myList.add("lampWatts");
        myList.add("active");

        List<BaseAttributeKvEntry> responser;

        responser = (await tbClient.getAttributeService().getAttributeKvEntries(
            response.id!, myList)) as List<BaseAttributeKvEntry>;

        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString('deviceStatus', responser.first.kv.getValue().toString());
        prefs.setString('deviceWatts', responser.last.kv.getValue().toString());
        prefs.setString('devicetimeStamp', responser.first.lastUpdateTs.toString());

        List<String> myLister = [];
        myLister.add("location");

        List<AttributeKvEntry> responserse;

        responserse = (await tbClient.getAttributeService().getAttributeKvEntries(
            response.id!, myLister)) as List<AttributeKvEntry>;

        if(responserse.length != "0") {
          prefs.setString('location', responserse.first.getValue().toString());
          prefs.setString('deviceId', deviceid);
          prefs.setString('deviceName', deviceName);

          List<String> versionlist = [];
          versionlist.add("ver");

          List<AttributeKvEntry> version_responserse;

          version_responserse =
          (await tbClient.getAttributeService().getAttributeKvEntries(
              response.id!, versionlist)) as List<AttributeKvEntry>;

          if (version_responserse.length == 0) {
            prefs.setString('version', "0");
          } else {
            prefs.setString('version', version_responserse.first.getValue());
          }

          if (relationDetails.length.toString() == "0") {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => ilm_installation_screen()));


          } else {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => MaintenanceScreen()));
          }
        }else{
          calltoast("Device Details Not Found");
          Navigator.pop(context);
        }
      } catch (e) {
        var message = toThingsboardError(e,context);
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
          Navigator.pop(context);
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

Future<ThingsboardError> toThingsboardError(error, context,[StackTrace? stackTrace]) async {
  ThingsboardError? tbError;
  if(error.message == "Session expired!"){
    var status = loginThingsboard.callThingsboardLogin(context);
    if (status == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => dashboard_screen()));
    }
  }else {
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

