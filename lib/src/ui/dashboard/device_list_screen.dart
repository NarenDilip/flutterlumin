import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/models/devicelistrequester.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/components/dropdown_button_field.dart';
import 'package:flutterlumin/src/ui/components/rounded_button.dart';
import 'package:flutterlumin/src/ui/components/rounded_input_field.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

import 'dashboard_screen.dart';

class device_list_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_list_screen_state();
  }
}

class device_list_screen_state extends State<device_list_screen> {
  List<String>? _foundUsers = [];
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";
  bool _visible = true;
  String searchNumber = "0";
  final TextEditingController _emailController =
      TextEditingController(text: "");

  final user = DeviceRequester(
    ilmnumber: "",
  );

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();

    setState(() {
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;
    });
  }

  @override
  void initState() {
    super.initState();
    SelectedRegion = "";
    getSharedPrefs();
  }

  void _toggle() {
    setState(() {
      _visible = !_visible;
    });
  }

  var dropDownValue = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Container(
            color: lightorange,
            child: Column(children: [
              Container(
                height: 100,
                decoration: const BoxDecoration(
                    color: lightorange,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0.0),
                        topRight: Radius.circular(0.0),
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(0.0))),
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: Text(
                          'Device List view',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 25.0,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      bottom: 0,
                      child: IconButton(
                        color: Colors.red,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 35,
                        ),
                        onPressed: () {
                          callLogoutoption(context);
                        },
                      ),
                    ),
                  ],
                ),),
              Expanded(
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35.0),
                              topRight: Radius.circular(35.0),
                              bottomLeft: Radius.circular(0.0),
                              bottomRight: Radius.circular(0.0))),
                      child:

                        ListView(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          children: <Widget>[
                            const SizedBox(
                              height: 30,
                            ),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              child: Text('$SelectedRegion',
                                  style: const TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsets>(
                                      EdgeInsets.all(20)),
                                  backgroundColor:
                                  MaterialStateProperty.all(Colors.lightBlue),
                                  foregroundColor: MaterialStateProperty.all<Color>(
                                      Colors.black),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ))),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        region_list_screen()));
                              }),
                          SizedBox(width: 5),
                          TextButton(
                              child: Text('$SelectedZone',
                                  style: const TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsets>(
                                      EdgeInsets.all(20)),
                                  backgroundColor:
                                  MaterialStateProperty.all(Colors.lightBlue),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ))),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        zone_li_screen()));
                              }),
                          SizedBox(width: 5),
                          TextButton(
                              child: Text('$SelectedWard',
                                  style: const TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsets>(
                                      EdgeInsets.all(20)),
                                  backgroundColor:
                                  MaterialStateProperty.all(Colors.lightBlue),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ))),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ward_li_screen()));
                              })
                        ],),

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
                                      color: liorange,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.only(left: 12),
                                                  child: Text('Device Filters',
                                                      style: TextStyle(
                                                          fontSize: 18.0,
                                                          fontFamily: "Montserrat",
                                                          color: Colors.black)))),
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
                            Visibility(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                decoration: BoxDecoration(
                                    color: liorange,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    rounded_input_field(
                                      hintText: "ILM Number",
                                      isObscure: false,
                                      controller: _emailController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return "Please enter the ILM Number";
                                        } else if (!EmailValidator.validate(value)) {
                                          return "Please enter the validate ILM Number";
                                        }
                                      },
                                      onSaved: (value) => user.ilmnumber = value!,
                                      onChanged: (String value) {
                                        user.ilmnumber = value;
                                        setState(() {
                                          _foundUsers!.clear();
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 5),
                                    rounded_button(
                                      text: "Search",
                                      color: Colors.green,
                                      press: () {
                                        if(user.ilmnumber.isNotEmpty) {
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          callILMDeviceListFinder(
                                              user.ilmnumber, context);
                                        }else{
                                          Fluttertoast.showToast(
                                              msg: "Please Select Device",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1);
                                        }
                                      },
                                      key: null,
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              visible: _visible,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                                decoration: BoxDecoration(
                                    color: liorange,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Column(
                                  children: [
                                    Row(
                                      children: const [
                                        Expanded(
                                            child: Padding(
                                                padding: EdgeInsets.only(left: 12),
                                                child: Text('ILM Device',
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontFamily: "Montserrat",
                                                        color: Colors.black)))),
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
                            Expanded(
                              child: _foundUsers!.isNotEmpty
                                  ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: _foundUsers!.length,
                                itemBuilder: (context, index) => Card(
                                  key: ValueKey(_foundUsers),
                                  color: Colors.white,
                                  margin: const EdgeInsets.fromLTRB(15,0,10,0),
                                  child: ListTile(
                                    // leading: Text(
                                    //   _foundUsers[index]["id"].toString(),
                                    //   style: const TextStyle(
                                    //       fontSize: 24.0,
                                    //       fontFamily: "Montserrat",
                                    //       fontWeight: FontWeight.normal,
                                    //       color: Colors.black),
                                    // ),
                                    onTap: () {

                                      fetchDeviceDetails(_foundUsers!.elementAt(index).toString(),context);
                                      _foundUsers = null;
                                    },
                                    title: Text(_foundUsers!.elementAt(index),
                                        style: const TextStyle(
                                            fontSize: 22.0,
                                            fontFamily: "Montserrat",
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                  ),
                                ),
                              )
                                  : const Text(
                                'No results found',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        )
              )
              )])));
  }

  Future<void> callILMDeviceListFinder(
      String searchNumber, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        Utility.progressDialog(context);
        try {
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          PageLink pageLink = new PageLink(100);
          pageLink.page = 0;
          pageLink.pageSize = 100;
          pageLink.textSearch = user.ilmnumber.toString();

          PageData<Device> devicelist_response;
          devicelist_response = (await tbClient
              .getDeviceService()
              .getTenantDevices(pageLink)) as PageData<Device>;

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
          Navigator.pop(context);
        } catch (e) {
          var message = toThingsboardError(e, context);
          Navigator.pop(context);
        }
      }
    });
  }
}

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
        }
      } catch (e) {
        Navigator.pop(context);
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

Future<ThingsboardError> toThingsboardError(error, context,
    [StackTrace? stackTrace]) async {
  ThingsboardError? tbError;
  if (error.message == "Session expired!") {
    Navigator.pop(context);
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


void callLogoutoption(BuildContext context) {

}

