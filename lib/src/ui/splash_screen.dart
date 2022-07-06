import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/storage/storage.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login/login_screen.dart';

// Splash screen this screen will be the app first screen , implemented with
// timer values and navigate to the dashboard or login pages.

class splash_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return splash_screenState();
  }
}

class splash_screenState extends State<splash_screen> {
  late String token;
  late final TbStorage storage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initial();
    // checkForUpdate();
  }

  // Future<void> checkForUpdate()async {
  //
  // }

  void initial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      token = prefs.getString("smart_token").toString();
      Timer(
          const Duration(seconds: 4),
          () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) {
                if (token == "null") {
                  return login_screen();
                } else {
                  var selectedRegion = prefs.getString("SelectedRegion").toString();
                  var SelectedZone = prefs.getString("SelectedZone").toString();
                  var SelectedWard = prefs.getString("SelectedWard").toString();
                  if(selectedRegion == "null"){
                    return region_list_screen();
                  }else{
                    if(SelectedZone == "null"){
                      return zone_li_screen();
                    }else{
                      if(SelectedWard == "null") {
                        return ward_li_screen();
                      }else{
                        return dashboard_screen(selectedPage: 0);
                      }
                    }
                  }
                }
              })));
    } catch (e) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return true;
        },
        child: Container(
            height: size.height,
            width: double.infinity,
            color: Colors.white,
            // decoration: const BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage("assets/icons/background_img.jpeg"),
            //   fit: BoxFit.cover,
            // ),
            // ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Image(
                    image: AssetImage("assets/icons/logo.png"),
                    height: 150,
                    width: 150),
                SizedBox(
                  height: 40,
                ),
                DefaultTextStyle(
                    style: TextStyle(decoration: TextDecoration.none),
                    child :Text(splashscreen_text,
                    style: TextStyle(
                        color: thbDblue,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Montserrat"))),
                const SizedBox(height: 60),
                DefaultTextStyle(
                    style: TextStyle(decoration: TextDecoration.none),
                    child : Center(
                    child:Text(app_version,style: const TextStyle(
                        fontSize: 15.0,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        color: invListBackgroundColor))
                )),
              ],
            )));
  }
}
