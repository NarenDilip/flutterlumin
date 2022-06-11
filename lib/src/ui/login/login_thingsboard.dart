import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutterlumin/src/thingsboard/model/login_models.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';

import 'package:shared_preferences/shared_preferences.dart';

// User login with credentials for thingsboard production and smart accounts,
// and check the user is valid person or invalid, if the user is valid we need
// to store server token and refresh token in local storage

class login_thingsboard {
  static Future<bool> callThingsboardLogin(BuildContext context, String username,String password) async {
    try {
      var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
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