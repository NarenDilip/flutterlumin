import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/app_bar_view.dart';
import 'package:flutterlumin/src/ui/chevron/chevron.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/map/location_map.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/point/edge.dart';
import 'package:flutterlumin/src/ui/point/point.dart';
import 'package:shared_preferences/shared_preferences.dart';

class map_view_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return map_view_screen_state();
  }
}

class map_view_screen_state extends State<map_view_screen> {
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();

    setState(() {
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;

      if (SelectedRegion == "null") {
        SelectedRegion = "Region";
        SelectedZone = "Zone";
        SelectedWard = "Ward";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    SelectedRegion = "";
    getSharedPrefs();
  }

  var dropDownValue = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          final result = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("Luminator"),
              content: Text("Are you sure you want to exit?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text("NO"),
                ),
                TextButton(
                  child: Text('YES', style: TextStyle(color: Colors.red)),
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
            resizeToAvoidBottomInset: false,
            extendBody: true,
            body: Container(
                color: thbDblue,
                child: Column(children: [
                  Expanded(
                      child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(35.0),
                                  topRight: Radius.circular(35.0),
                                  bottomLeft: Radius.circular(0.0),
                                  bottomRight: Radius.circular(0.0))),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const AppBarWidget(title: "Location",),
                                const SizedBox(height: 5),
                                Expanded(
                                    child: Container(
                                        color: Colors.grey,
                                        child: Stack(
                                          children: [
                                            LocationWidget(
                                              initialLabel: 0,
                                              onToggle: (index) {
                                                // print('switched to: $index');
                                              },
                                            ),
                                          ],
                                        )))
                              ])))
                ]))));
  }

  Future<void> callLogoutoption(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Luminator",
            style: const TextStyle(
                fontSize: 25.0,
                fontFamily: "Aqua",
                fontWeight: FontWeight.bold,
                color: darkgreen)),
        content: Text("Are you sure you want to Logout?",
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
                    fontSize: 18.0, fontFamily: "Aqua", color: darkgreen)),
          ),
          TextButton(
            child: Text('YES',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18.0,
                  fontFamily: "Aqua",
                )),
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          ),
        ],
      ),
    );
  }
}
