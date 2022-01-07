import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/storage/storage.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login/login_screen.dart';

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
  }

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
                  return dashboard_screen();
                }
              })));
    } catch (e) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
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
              height: 20,
            ),
            Text(splashscreen_text,
                style: TextStyle(
                    color: liorange,
                    fontSize: 35,
                    fontFamily: "Montserrat")),
          ],
        ));
  }
}
