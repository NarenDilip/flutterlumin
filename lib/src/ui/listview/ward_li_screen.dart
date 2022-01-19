import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/ward_model.dart';
import 'package:flutterlumin/src/thingsboard/model/asset_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/asset_id.dart';
import 'package:flutterlumin/src/thingsboard/model/id/device_id.dart';
import 'package:flutterlumin/src/thingsboard/model/relation_models.dart';
import 'package:flutterlumin/src/thingsboard/model/telemetry_models.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

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
  String selectedZone = "0";
  String selectedWard = "0";

  @override
  initState() {
    // at the beginning, all users are shown
    loadDetails();
  }

  void loadDetails() async {
    DBHelper dbHelper = DBHelper();
    Future<List<Ward>> wards;

    var sharedPreferences = await SharedPreferences.getInstance();
    selectedZone = sharedPreferences.getString("SelectedZone").toString();

    if (selectedZone != "0") {
      wards = dbHelper.ward_zonebasedDetails(selectedZone);
      wards.then((data) {
        for (int i = 0; i < data.length; i++) {
          String regionname = data[i].wardname.toString();
          _allUsers?.add(regionname);
        }
        setState(() {
          _foundUsers = _allUsers!;
        });
      }, onError: (e) {
        print(e);
      });
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
        Utility.progressDialog(context);
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
                }else{

                }
              }

              var assetrelatedwardid;

              for (int j = 0; j < AssetDevices!.length; j++) {
                  List<EntityRelationInfo> relationdevicelist = await tbClient
                          .getEntityRelationService()
                          .findInfoByAssetFrom(AssetDevices!.elementAt(j))
                      as List<EntityRelationInfo>;

                  if (relationdevicelist.length != 0) {
                    assetrelatedwardid = relationdevicelist.elementAt(0).to;
                    relatedDevices?.add(assetrelatedwardid);
                  }
              }

              if (relatedDevices != null) {
                for (int k = 0; k < relatedDevices!.length; k++) {
                  List<String> myList = [];
                  myList.add("active");

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
                    }
                  }
                }

                var totalval = activeDevice!.length + nonactiveDevices!.length;
                var ncdevices = relatedDevices!.length - totalval;
                var noncomdevice = "";
                if(ncdevices.toString().contains("-")){
                  noncomdevice = ncdevices.toString().replaceAll("-", "");
                }else{
                  noncomdevice = ncdevices.toString();
                }

                sharedPreferences.setString(
                    'totalCount', relatedDevices!.length.toString());
                sharedPreferences.setString(
                    'activeCount', activeDevice!.length.toString());
                sharedPreferences.setString(
                    'nonactiveCount', nonactiveDevices!.length.toString());
                sharedPreferences.setString('ncCount', noncomdevice);

                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => dashboard_screen()));
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

              sharedPreferences.setString(
                  'totalCount', "0");
              sharedPreferences.setString(
                  'activeCount', "0");
              sharedPreferences.setString(
                  'nonactiveCount', "0");
              sharedPreferences.setString('ncCount', "0");

              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => dashboard_screen()));
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
                builder: (BuildContext context) => dashboard_screen()));
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
      backgroundColor: liorange,
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
                  color: Colors.black),
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
                  color: Colors.black),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
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
                                  color: Colors.black)),
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
}

void callNavigator(context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    SystemNavigator.pop();
  }
}
