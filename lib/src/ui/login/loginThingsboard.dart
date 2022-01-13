import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/model/login_models.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginThingsboard {
  static Future<bool> callThingsboardLogin(BuildContext context) async {
    try {
      Utility.progressDialog(context);
      var tbClient = ThingsboardClient(serverUrl);
      SharedPreferences prefs = await SharedPreferences.getInstance();

     var username =  prefs.getString('username');
     var password = prefs.getString('password');

      final smartToken =
          await tbClient.login(LoginRequest(username!, password!));
      if (smartToken.token != null) {
        prefs.setString('smart_token', smartToken.token);
        prefs.setString('smart_refreshtoken', smartToken.refreshToken);

        // final prodToken =
        //     await tbClient.login(LoginRequest(prod_Username, prod_Password));
        // if (prodToken.token != null) {
        //   prefs.setString('prod_token', prodToken.token);
        //   prefs.setString('prod_refreshtoken', prodToken.refreshToken);
        //   Navigator.pop(context);
        //   return true;
        // }
      }
    } catch (e) {
      return false;
    }
    return true;
  }
}
