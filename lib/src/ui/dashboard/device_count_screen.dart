import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();

    setState(() {
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;

      if(SelectedRegion == "0" || SelectedRegion == "null"){
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      final result = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 0),
          backgroundColor: Colors.white,
          title: Text("Luminator", style: const TextStyle(
              fontSize: 25.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: liorange)),
          content: Text("Are you sure you want to exit?", style: const TextStyle(
              fontSize: 18.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: Colors.black)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text("NO", style: const TextStyle(
                  fontSize: 25.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
            ),
            TextButton(
              child: Text('YES',  style: const TextStyle(
          fontSize: 25.0,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
          color: Colors.red)),
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
          color: lightorange,
          child: Column(
            children: [
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
                        'Dashboard',
                        textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 25.0,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                              color: Colors.white)
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 15,
                      bottom: 0,
                      child: IconButton(
                        color: Colors.red,
                        icon: Icon(
                          IconData(0xe3b3, fontFamily: 'MaterialIcons'),
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
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        SizedBox(height: 5),
                        Container(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                          child: Text('$SelectedRegion',
                                              style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          style: ButtonStyle(
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsets>(
                                                      EdgeInsets.all(20)),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      lightorange),
                                              foregroundColor:
                                                  MaterialStateProperty.all<Color>(
                                                      Colors.black),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                              ))),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        region_list_screen()));
                                          }),
                                      SizedBox(width: 5),
                                      TextButton(
                                          child: Text('$SelectedZone',
                                              style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          style: ButtonStyle(
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsets>(
                                                      EdgeInsets.all(20)),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      lightorange),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                              ))),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        zone_li_screen()));
                                          }),
                                      SizedBox(width: 5),
                                      TextButton(
                                          child: Text('$SelectedWard',
                                              style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontFamily: "Montserrat",
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          style: ButtonStyle(
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsets>(
                                                      EdgeInsets.all(20)),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      lightorange),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                              ))),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        ward_li_screen()));
                                          })
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
                                        const SizedBox(height: 10),
                                        Container(
                                            child: Row(
                                          children: const <Widget>[
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
                                                        color: Colors.black),
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
                                                      child: Text(
                                                        "110",
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
                                                        color: Colors.grey),
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
                                                        color: Colors.grey),
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
                                                        color: Colors.grey),
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
                                          children: const <Widget>[
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
                                                        "30",
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
                                                        "40",
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
                                                        "40",
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
        )));
  }
}

Future<void> callLogoutoption(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      backgroundColor: Colors.white,
      title: Text("Luminator",style: const TextStyle(
          fontSize: 25.0,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
          color: liorange)),
      content: Text("Are you sure you want to Logout?",style: const TextStyle(
          fontSize: 18.0,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
          color: Colors.black)),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Text("NO",style: const TextStyle(
              fontSize: 18.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: Colors.green)),
        ),
        TextButton(
          child: Text('YES',style: const TextStyle(
              fontSize: 18.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: Colors.red)),
          onPressed: () async {
            SharedPreferences preferences = await SharedPreferences.getInstance();
            await preferences.clear();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => splash_screen()));
          },
        ),
      ],
    ),
  );
}
