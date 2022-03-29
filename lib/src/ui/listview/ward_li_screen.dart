import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/ward_model.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/dashboard_view.dart';
import 'package:flutterlumin/src/thingsboard/model/asset_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/asset_id.dart';
import 'package:flutterlumin/src/thingsboard/model/id/device_id.dart';
import 'package:flutterlumin/src/thingsboard/model/relation_models.dart';
import 'package:flutterlumin/src/thingsboard/model/telemetry_models.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

import '../../thingsboard/error/thingsboard_error.dart';
import '../../thingsboard/model/model.dart';
import '../maintenance/ilm/ilm_maintenance_screen.dart';

class ward_li_screen extends StatefulWidget {
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

  @override
  initState() {
    // at the beginning, all users are shown
    loadDetails();
  }

  void loadDetails() async {
    DBHelper dbHelper = DBHelper();

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

    var sharedPreferences = await SharedPreferences.getInstance();
    selectedZone = sharedPreferences.getString("SelectedZone").toString();

    if (selectedZone != "0") {
      List<Ward> wards = await dbHelper.ward_getDetails() as List<Ward>;
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

          var tbClient = await ThingsboardClient(serverUrl);
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
                .findInfoByAssetFrom(response.id!) as List<EntityRelationInfo>;

            if (wardlist.length != 0) {
              for (int i = 0; i < wardlist.length; i++) {
                if (wardlist.elementAt(i).to.entityType.name != "DEVICE") {
                  relatedDeviceId = wardlist.elementAt(i).to;
                  AssetDevices?.add(relatedDeviceId);
                } else {
                  relatedDeviceId = wardlist.elementAt(i).from;
                  AssetDevices?.add(relatedDeviceId);
                  break;
                }
              }

              var assetrelatedwardid;
              for (int j = 0; j < AssetDevices!.length; j++) {
                List<EntityRelationInfo> relationdevicelist = await tbClient
                        .getEntityRelationService()
                        .findInfoByAssetFrom(AssetDevices!.elementAt(j))
                    as List<EntityRelationInfo>;

                for (int k = 0; k < relationdevicelist.length; k++) {
                  if (relationdevicelist.length != 0) {
                    assetrelatedwardid = relationdevicelist.elementAt(k).to;
                    relatedDevices?.add(assetrelatedwardid);
                  }
                }
              }

              if (relatedDevices != null) {
                for (int k = 0; k < relatedDevices!.length; k++) {
                  List<String> myList = [];
                  myList.add("active");

                  Device data_response;
                  data_response = (await tbClient.getDeviceService().getDevice(
                      relatedDevices!.elementAt(k).id.toString())) as Device;

                  if (data_response.type == "lumiNode") {
                    List<AttributeKvEntry> responser;
                    responser = await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(
                            relatedDevices!.elementAt(k), myList);

                    if (responser != null) {
                      if (responser.first.getValue().toString() == "true") {
                        activeDevice!.add(relatedDevices!.elementAt(k));
                      } else if (responser.first.getValue().toString() ==
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

                    sharedPreferences.setInt(
                        'ilm_total_count', totalval);
                    sharedPreferences.setInt(
                        'ilm_on_count', activeDevice!.length);
                    sharedPreferences.setInt(
                        'ilm_off_count', nonactiveDevices!.length);
                    sharedPreferences.setInt('ilm_nc_count', int.parse(noncomdevice));
                  } else if (data_response.type == "CCMS") {
                    List<AttributeKvEntry> responser;
                    responser = await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(
                            relatedDevices!.elementAt(k), myList);

                    if (responser != null) {
                      if (responser.first.getValue().toString() == "true") {
                        ccms_activeDevice!.add(relatedDevices!.elementAt(k));
                      } else if (responser.first.getValue().toString() ==
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

                    sharedPreferences.setInt(
                        'ccms_total_count', ccms_totalval);
                    sharedPreferences.setInt('ccms_on_count',
                        ccms_activeDevice!.length);
                    sharedPreferences.setInt('ccms_off_count',
                        ccms_nonactiveDevices!.length);
                    sharedPreferences.setInt(
                        'ccms_nc_count', int.parse(ccms_noncomdevice));

                  } else if (data_response.type == "Gateway") {
                    List<AttributeKvEntry> responser;
                    responser = await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(
                        relatedDevices!.elementAt(k), myList);

                    if (responser != null) {
                      if (responser.first.getValue().toString() == "true") {
                        gw_activeDevice!.add(relatedDevices!.elementAt(k));
                      } else if (responser.first.getValue().toString() ==
                          "false") {
                        gw_nonactiveDevices!
                            .add(relatedDevices!.elementAt(k));
                      } else {
                        gw_ncDevices!.add(relatedDevices!.elementAt(k));
                      }
                    }

                    var gw_totalval = gw_activeDevice!.length +
                        gw_nonactiveDevices!.length +
                        gw_ncDevices!.length;
                    var gw_parttotalval = gw_activeDevice!.length +
                        gw_nonactiveDevices!.length;
                    var gw_ncdevices = gw_parttotalval - gw_totalval;
                    var gw_noncomdevice = "";
                    if (gw_ncdevices.toString().contains("-")) {
                      gw_noncomdevice =
                          gw_ncdevices.toString().replaceAll("-", "");
                    } else {
                      gw_noncomdevice = gw_ncdevices.toString();
                    }

                    sharedPreferences.setInt(
                        'gw_total_count', gw_totalval);
                    sharedPreferences.setInt('gw_on_count',
                        gw_activeDevice!.length);
                    sharedPreferences.setInt('gw_off_count',
                        gw_nonactiveDevices!.length);
                    sharedPreferences.setInt(
                        'gw_nc_count', int.parse(gw_noncomdevice));

                  }
                }

                // Navigator.pop(context);
                pr.hide();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => DashboardView()));
              }
            } else {
              pr.hide();
              Fluttertoast.showToast(
                  msg: "No Devices Directly Related to Ward",
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
                  builder: (BuildContext context) => DashboardView()));
            }
          }
        } catch (e) {
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              loadLocalData(context);
            }
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => DashboardView()));
            // Navigator.pop(context);
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
  Widget build(BuildContext context) {
    return Container(
        // onWillPop: () async {
        //   final result = await showDialog(
        //     context: context,
        //     builder: (ctx) =>
        //         AlertDialog(
        //           title: Text("Luminator"),
        //           content: Text("Are you sure you want to exit?"),
        //           actions: <Widget>[
        //             TextButton(
        //               onPressed: () {
        //                 Navigator.of(ctx).pop();
        //               },
        //               child: Text("NO"),
        //             ),
        //             TextButton(
        //               child: Text('YES', style: TextStyle(color: Colors.red)),
        //               onPressed: () {
        //                 // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        //               },
        //             ),
        //           ],
        //         ),
        //   );
        //   return result;
        // },
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
                          // leading: Text(
                          //   _foundUsers[index]["id"].toString(),
                          //   style: const TextStyle(
                          //       fontSize: 24.0,
                          //       fontFamily: "Montserrat",
                          //       fontWeight: FontWeight.normal,
                          //       color: Colors.black),
                          // ),
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
                      'No results found',
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
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
//
// void callNavigator(context) {
//   if (Navigator.canPop(context)) {
//     Navigator.pop(context);
//   } else {
//     SystemNavigator.pop();
//   }
// }
