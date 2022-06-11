import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutterlumin/src/thingsboard/model/login_models.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

// User login with credentials for thingsboard production and smart accounts,
// and check the user is valid person or invalid, if the user is valid we need
// to store server token and refresh token in local storage

class loginThingsboard {
  static Future<bool> callThingsboardLogin(BuildContext context) async {
    try {
      var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var username = prefs.getString('username');
      var password = prefs.getString('password');

      final smartToken =
      await tbClient.login(LoginRequest(username!, password!));
      if (smartToken.token != null) {
        prefs.setString('smart_token', smartToken.token);
        prefs.setString('smart_refreshtoken', smartToken.refreshToken);
      }
    } catch (e) {
      return false;
    }
    return true;
  }
}
