import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/region_model.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localdb/model/zone_model.dart';
import '../../thingsboard/model/model.dart';
import '../../thingsboard/thingsboard_client_base.dart';
import '../../utils/utility.dart';

class region_list_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return region_list_screen_state();
  }
}

class region_list_screen_state extends State<region_list_screen> {
  // return Scaffold(body: regionListview());
  List<String>? _allUsers = [];
  List<String>? _foundUsers = [];
  List<String>? relatedzones = [];
  String selectedZone = "0";
  late ProgressDialog pr;

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

    pr = ProgressDialog(
        context, type: ProgressDialogType.Normal, isDismissible: false);
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
              "Select Region",
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
                suffixIcon: Icon(Icons.search,color: Colors.white,),
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
                              selectedZone =
                                  _foundUsers!.elementAt(index).toString();
                              loadDetails();
                            });

                            callZoneDetailsFinder(context, selectedZone);
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

  void callZoneDetailsFinder(BuildContext context, selectedZone) {
    Utility.isConnected().then((value) async {
      if (value) {
        // Utility.progressDialog(context);
        pr.show();
        var tbClient = await ThingsboardClient(serverUrl);
        tbClient.smart_init();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("SelectedRegion", selectedZone);

        DBHelper dbHelper = new DBHelper();
        List<Zone> details =
            await dbHelper.zone_regionbasedDetails(selectedZone) as List<Zone>;
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

              // DBHelper dbHelper = new DBHelper();
              // dbHelper.region_delete();

              for (int j = 0; j < relatedzones!.length; j++) {
                Asset asset = await tbClient
                    .getAssetService()
                    .getAsset(relatedzones!.elementAt(j).toString()) as Asset;
                if (asset.name != null) {
                  // var regionname = selectedZone.split("-");
                  Zone zone =
                      new Zone(j, asset.id!.id, asset.name, selectedZone);
                  dbHelper.zone_add(zone);
                }
              }
              pr.hide();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => zone_li_screen()));
            } else {
              pr.hide();
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
            pr.hide();
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
          pr.hide();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => zone_li_screen()));
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
