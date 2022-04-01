import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/model/login_models.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';

import 'package:shared_preferences/shared_preferences.dart';

class login_thingsboard {
  static Future<bool> callThingsboardLogin(BuildContext context, String username,String password) async {
    try {
      var tbClient = ThingsboardClient(serverUrl);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final smartToken =
      await tbClient.login(LoginRequest(username, password));
      if (smartToken.token != null) {
        prefs.setString('smart_token', smartToken.token);
        prefs.setString('smart_refreshtoken', smartToken.refreshToken);
      }
    } catch (e) {
      // Navigator.pop(context);
      return false;
    }
    return true;
  }
}