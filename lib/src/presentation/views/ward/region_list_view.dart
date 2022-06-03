import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/data/model/zone_model.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/region_model.dart';
import 'package:flutterlumin/src/presentation/views/ward/zone_list_view.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegionListScreen extends StatefulWidget {
  const RegionListScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RegionListScreenState();
  }
}

class RegionListScreenState extends State<RegionListScreen> {
  // return Scaffold(body: regionListview());
  List<String>? _allUsers = [];
  List<String>? _foundUsers = [];
  List<String>? relatedzones = [];
  String selectedZone = "0";

  @override
  initState() {
    // at the beginning, all users are shown
    DBHelper dbHelper = DBHelper();
    Future<List<Region>> regions;
    regions = dbHelper.getDetails();

    regions.then((data) {
      for (int i = 0; i < data.length; i++) {
        String regionname = data[i].regionname.toString();
        _allUsers?.add(regionname);
      }
      setState(() {
        _foundUsers = _allUsers!;
      });
    }, onError: (e) {
      print(e);
    });

    //loadDetails();
  }

  void loadDetails() async {
    var sharedPreferences =
    await SharedPreferences.getInstance() as SharedPreferences;
    sharedPreferences.setString("SelectedRegion", selectedZone);
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          showExitPopup(context);
          return false;
        },
        child:  Scaffold(
          backgroundColor: lightGrey,
          body: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Select Region",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (value) => _runFilter(value),
                  style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'Roboto',
                      color: Colors.black),
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
                            loadDetails();
                          });

                          callZoneDetailsFinder(context, selectedZone);
                        },
                        title: Text(_foundUsers!.elementAt(index),
                            style: const TextStyle(
                                fontSize: 20.0,
                                fontFamily: 'Roboto',
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

  Future<bool> showExitPopup(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Luminator",
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Do you want to exit?"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            exit(0);
                          },
                          child: const Text("Yes"),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red.shade800),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("No",
                                style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                          ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    if (error.message == "Session expired!") {
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => RegionListScreen()));
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

  void callZoneDetailsFinder(BuildContext context, selectedZone) {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          var tbClient = await ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
          tbClient.smart_init();

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("SelectedRegion", selectedZone);

          DBHelper dbHelper = new DBHelper();
          dbHelper.zone_delete(selectedZone);
          List<ZoneResponse> details = await dbHelper
              .zone_regionbasedDetails(selectedZone);
          if (details.isEmpty) {
            // dbHelper.zone_delete();

            List<Region> regiondetails =
            await dbHelper.region_name_regionbasedDetails(selectedZone);
            if (regiondetails.length != 0) {
              Map<String, dynamic> fromId = {
                'entityType': 'ASSET',
                'id': regiondetails.first.regionid
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

                    var rng = new Random();
                    var code = rng.nextInt(999999) + 100000;

                    ZoneResponse zone =
                    ZoneResponse(j+code+0, asset.id!.id, asset.name, selectedZone);
                    dbHelper.zone_add(zone);
                  }
                }
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => ZoneListScreen()));
              } else {
                /*FlutterLogs.logInfo("regionlist_page", "region_list", "No Zone Details Found");*/
                Fluttertoast.showToast(
                    msg: app_reg_nozones,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);
              }
            } else {
              /*FlutterLogs.logInfo("regionlist_page", "region_list", "No Region Details Found");*/
              Fluttertoast.showToast(
                  msg: app_reg_notfound,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
            }
          } else {
            /*FlutterLogs.logInfo("regionlist_page", "region_list", "No Details Found");*/
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => ZoneListScreen()));
          }
        } catch (e) {
          /*FlutterLogs.logInfo("regionlist_page", "region_list", "Region List Fetching Exception");*/
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => RegionListScreen()));
            }
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => RegionListScreen()));
          }
        }
      } else {
        /*FlutterLogs.logInfo("regionlist_page", "region_list", "No Network");*/
        Fluttertoast.showToast(
            msg: app_no_network,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    });
  }
}
