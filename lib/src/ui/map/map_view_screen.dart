import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
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
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                        color: thbDblue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                            bottomLeft: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0))),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: Text('Map view',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 25.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Positioned(
                          right: 10,
                          top: 20,
                          bottom: 0,
                          child: IconButton(
                            color: Colors.red,
                            icon: Icon(
                              Icons.logout_outlined,
                              size: 35,
                            ),
                            onPressed: () {
                              callLogoutoption(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
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
                              Column(mainAxisSize: MainAxisSize.min, children: <
                                  Widget>[
                            SizedBox(height: 5),
                            Container(
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 5.0),
                                              child: Point(
                                                triangleHeight: 25.0,
                                                edge: Edge.RIGHT,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                ward_li_screen()));
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    color: thbDblue,
                                                    width: 120.0,
                                                    height: 50.0,
                                                    child: Center(
                                                      child: Text(
                                                          '$SelectedRegion',
                                                          style: const TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 5.0),
                                              child: Point(
                                                triangleHeight: 25.0,
                                                edge: Edge.RIGHT,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                zone_li_screen()));
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    color: thbDblue,
                                                    width: 120.0,
                                                    height: 50.0,
                                                    child: Center(
                                                      child: Text(
                                                          '$SelectedZone',
                                                          style: const TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 5.0),
                                              child: Point(
                                                triangleHeight: 25.0,
                                                edge: Edge.RIGHT,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                ward_li_screen()));
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    color: thbDblue,
                                                    width: 120.0,
                                                    height: 50.0,
                                                    child: Center(
                                                      child: Text(
                                                          '$SelectedWard',
                                                          style: const TextStyle(
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  "Montserrat",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // TextButton(
                                          //     child: Text('$SelectedWard',
                                          //         style: const TextStyle(
                                          //             fontSize: 18.0,
                                          //             fontFamily: "Montserrat",
                                          //             fontWeight: FontWeight
                                          //                 .bold,
                                          //             color: Colors.white)),
                                          //     style: ButtonStyle(
                                          //         padding: MaterialStateProperty
                                          //             .all<EdgeInsets>(
                                          //             EdgeInsets.all(20)),
                                          //         backgroundColor:
                                          //         MaterialStateProperty.all(
                                          //             thbDblue),
                                          //         shape: MaterialStateProperty
                                          //             .all<
                                          //             RoundedRectangleBorder>(
                                          //             RoundedRectangleBorder(
                                          //               borderRadius:
                                          //               BorderRadius
                                          //                   .circular(18.0),
                                          //             ))),
                                          //     onPressed: () {
                                          //       // Navigator.of(context).push(
                                          //       //     MaterialPageRoute(
                                          //       //         builder: (
                                          //       //             BuildContext
                                          //       //             context) =>
                                          //       //             ward_li_screen()));
                                          //       setState(() {});
                                          //     })
                                        ]))),
                            SizedBox(
                              height: 5,
                            ),
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
        title: Text("Luminator"),
        content: Text("Are you sure you want to Logout?"),
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
  }
}
