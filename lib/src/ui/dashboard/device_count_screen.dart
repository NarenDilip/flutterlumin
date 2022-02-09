import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/point/edge.dart';
import 'package:flutterlumin/src/ui/point/point.dart';
import 'package:flutterlumin/src/ui/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localdb/model/region_model.dart';
import '../../localdb/model/ward_model.dart';

class device_count_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_count_screen_state();
  }
}

class device_count_screen_state extends State<device_count_screen> {
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";
  String totalCount = "0";
  String activeCount = "0";
  String nonactiveCount = "0";
  String ncCount = "0";
  String Maintenance = "true";

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();

    totalCount = prefs.getString("totalCount").toString();
    activeCount = prefs.getString("activeCount").toString();
    nonactiveCount = prefs.getString("nonactiveCount").toString();
    ncCount = prefs.getString("ncCount").toString();
    Maintenance = prefs.getString("Maintenance").toString();

    setState(() {
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;

      totalCount = totalCount;
      activeCount = activeCount;
      nonactiveCount = nonactiveCount;
      ncCount = ncCount;
      Maintenance = Maintenance;

      if (SelectedRegion == "0" || SelectedRegion == "null") {
        SelectedRegion = "Region";
        SelectedZone = "Zone";
        SelectedWard = "Ward";
      }

      if (SelectedZone == "0" || SelectedZone == "null") {
        SelectedZone = "Zone";
      }

      if (SelectedWard == "0" || SelectedWard == "null") {
        SelectedWard = "Ward";
      }

      if (totalCount == "null") {
        totalCount = "0";
        activeCount = "0";
        nonactiveCount = "0";
        ncCount = "0";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    SelectedRegion = "";
    getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Container(
          color: thbDblue,
          child: Column(
            children: [
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
                      child: Text('Dashboard',
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
                        icon: const Icon(
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
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        SizedBox(height: 5),
                        Container(
                          height: 55,
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
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
                                    ]))),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            child: Card(
                          color: Colors.transparent,
                          elevation: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Card(
                                  elevation: 20,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SizedBox(height: 10),
                                        Container(
                                            child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    15.0, 0.0, 0.0, 0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0.0, 0.0, 0),
                                                child: Align(
                                                  child: Text(
                                                    "ILM",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: thbDblue),
                                                  ),
                                                  alignment: Alignment.center,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 15.0, 0),
                                                child: Align(
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.blue,
                                                    child: Center(
                                                      child: new Text(
                                                        '$totalCount',
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                "Montserrat",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerRight,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: const <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    40.0, 0.0, 0.0, 0),
                                                child: Align(
                                                  child: Text(
                                                    "ON",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: thbDblue),
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0.0, 0.0, 0),
                                                child: Align(
                                                  child: Text(
                                                    "OFF",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: thbDblue),
                                                  ),
                                                  alignment: Alignment.center,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 40.0, 0),
                                                child: Align(
                                                  child: Text(
                                                    "NC",
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: thbDblue),
                                                  ),
                                                  alignment:
                                                      Alignment.centerRight,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    30.0, 0.0, 0.0, 0),
                                                child: Align(
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.green,
                                                    child: Center(
                                                      child: Text(
                                                        '$activeCount',
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                "Montserrat",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0.0, 0.0, 0),
                                                child: Align(
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors.red,
                                                    child: Center(
                                                      child: Text(
                                                        '$nonactiveCount',
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                "Montserrat",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 30.0, 0),
                                                child: Align(
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.orange,
                                                    child: Center(
                                                      child: Text(
                                                        '$ncCount',
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                "Montserrat",
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerRight,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                      ])),
                            ],
                          ),
                        )),
                      ])))
            ],
          ),
        ));
  }
}

Future<void> callLogoutoption(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      backgroundColor: Colors.white,
      title: Text("Luminator",
          style: const TextStyle(
              fontSize: 25.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: liorange)),
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
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
        ),
        TextButton(
          child: Text('YES',
              style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          onPressed: () async {

            DBHelper dbhelper = new DBHelper();
            SharedPreferences prefs = await SharedPreferences.getInstance();

            var SelectedRegion = prefs.getString("SelectedRegion").toString();
            List<Region> details = await dbhelper.region_getDetails();

            for(int i=0;i<details.length;i++){
              dbhelper.delete(details.elementAt(i).id!.toInt());
            }
            dbhelper.zone_delete(SelectedRegion);
            dbhelper.ward_delete(SelectedRegion);

            // List<Region> detailss = await dbhelper.region_getDetails();
            // List<Zone> zdetails =
            //     (await dbhelper.zone_getDetails()).cast<Zone>();
            // List<Ward> wdetails = await dbhelper.ward_getDetails();

            // dbhelper.region_delete();
            // dbhelper.zone_delete();
            // dbhelper.ward_delete();

            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            await preferences.clear();
            // SystemChannels.platform.invokeMethod('SystemNavigator.pop');

            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => splash_screen()));
          },
        ),
      ],
    ),
  );
}
