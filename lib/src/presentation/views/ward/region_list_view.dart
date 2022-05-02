import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/data/model/zone_model.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/region_model.dart';
import 'package:flutterlumin/src/presentation/views/ward/zone_list_view.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

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
    return Container(
        child: Scaffold(
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
        // Utility.progressDialog(context);
        try {
          var tbClient = await ThingsboardClient(serverUrl);
          tbClient.smart_init();

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("SelectedRegion", selectedZone);

          DBHelper dbHelper = DBHelper();
          List<ZoneResponse> details = await dbHelper
              .zone_regionbasedDetails(selectedZone);
          if (details.isEmpty) {
            // dbHelper.zone_delete();

            List<Region> regiondetails =
            await dbHelper.region_name_regionbasedDetails(selectedZone);
            if (regiondetails.isNotEmpty) {
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

                // DBHelper dbHelper = new DBHelper();
                // dbHelper.region_delete();

                for (int j = 0; j < relatedzones!.length; j++) {
                  Asset asset = await tbClient
                      .getAssetService()
                      .getAsset(relatedzones!.elementAt(j).toString()) as Asset;
                  if (asset.name != null) {
                    // var regionname = selectedZone.split("-");
                    ZoneResponse zone =
                    ZoneResponse(j, asset.id!.id, asset.name, selectedZone) ;
                    dbHelper.zone_add(zone);
                  }
                }
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => ZoneListScreen()));
              } else {
                Fluttertoast.showToast(
                    msg: "No Zones releated to this Region",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);
              }
            } else {
              Fluttertoast.showToast(
                  msg: "Unable to find Region Details",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
            }
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => ZoneListScreen()));
          }
        } catch (e) {
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
            // Navigator.pop(context);
          }
        }
      } else {
        Fluttertoast.showToast(
            msg: "No Network. Please try again later",
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
