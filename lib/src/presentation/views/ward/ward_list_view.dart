import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/ward_model.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/dashboard_view.dart';
import 'package:flutterlumin/src/presentation/views/ward/region_list_view.dart';
import 'package:flutterlumin/src/presentation/views/ward/zone_list_view.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/app_bar_view.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/asset_models.dart';
import 'package:flutterlumin/src/thingsboard/model/device_models.dart';
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

class WardList extends StatefulWidget {
  const WardList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WardListState();
  }
}

class WardListState extends State<WardList> {
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
  String selectedRegion = "0";

  @override
  initState() {
    // at the beginning, all users are shown
    loadDetails();
  }

  void loadDetails() async {
    DBHelper dbHelper = DBHelper();
    var sharedPreferences = await SharedPreferences.getInstance();
    selectedZone = sharedPreferences.getString("SelectedZone").toString();
    selectedRegion = sharedPreferences.getString("SelectedRegion").toString();
    if (selectedZone != "0") {
      List<Ward> wards = await dbHelper.ward_getDetails();
      for (int i = 0; i < wards.length; i++) {
        String regionname = wards[i].wardname.toString();
        _allUsers?.add(regionname);
      }
      setState(() {
        _foundUsers = _allUsers!;
      });
    }
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
                .findInfoByAssetFrom(response.id!);
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
                        .findInfoByAssetFrom(AssetDevices!.elementAt(j));
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

                    sharedPreferences.setInt('ilm_total_count', totalval);
                    sharedPreferences.setInt(
                        'ilm_on_count', activeDevice!.length);
                    sharedPreferences.setInt(
                        'ilm_off_count', nonactiveDevices!.length);
                    sharedPreferences.setInt(
                        'ilm_nc_count', int.parse(noncomdevice));
                  }
                  else if (data_response.type == "CCMS") {
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

                    sharedPreferences.setInt('ccms_total_count', ccms_totalval);
                    sharedPreferences.setInt(
                        'ccms_on_count', ccms_activeDevice!.length);
                    sharedPreferences.setInt(
                        'ccms_off_count', ccms_nonactiveDevices!.length);
                    sharedPreferences.setInt(
                        'ccms_nc_count', int.parse(ccms_noncomdevice));
                  }
                  else if (data_response.type == "Gateway") {
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

                    sharedPreferences.setInt('gw_total_count', gw_totalval);
                    sharedPreferences.setInt(
                        'gw_on_count', gw_activeDevice!.length);
                    sharedPreferences.setInt(
                        'gw_off_count', gw_nonactiveDevices!.length);
                    sharedPreferences.setInt(
                        'gw_nc_count', int.parse(gw_noncomdevice));
                  }
                }
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => DashboardView()));
              }
            } else {
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
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => DashboardView()));
            }
          }
        } catch (e) {
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
        child: Scaffold(
      backgroundColor: lightGrey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text("Select Ward"),
          ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: [
                    Text("Region"),
                    const SizedBox(
                      height: 10,
                    ),
                    CategoryWidget(
                      categoryName: "Region",
                      selectedItem: selectedRegion,
                      itemPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                RegionListScreen()));
                      },
                    ),
                  ],
                ),
                SizedBox(width: 30,),
                Column(
                  children: [
                    Text("Zone"),
                    SizedBox(
                      height: 10,
                    ),
                    CategoryWidget(
                      categoryName: "Zone",
                      selectedItem: selectedZone,
                      itemPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ZoneListScreen()));
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              onChanged: (value) => _runFilter(value),
              style: const TextStyle(
                  fontSize: 18.0, fontFamily: 'Roboto', color: Colors.black),
              decoration: const InputDecoration(
                labelStyle: TextStyle(fontSize: 20.0, color: Colors.black),
                labelText: 'Search',
                suffixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
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
                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const DashboardView()));
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

  Future<void> updateWard() async{
    var sharedPreferences =
        await SharedPreferences.getInstance() as SharedPreferences;
    sharedPreferences.setString("SelectedWard", selectedWard);
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    if (error.message == "Session expired!") {
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => WardList()));
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
