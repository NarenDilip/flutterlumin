import 'dart:convert';
import 'package:flutterlumin/src/models/loginrequester.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  static LoginRequester? user;

  static Future<void> save(String key, String data) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(key, data);
  }

  static Future<String?> read(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  static Future<void> remove(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(key);
  }

  static Future<void> clear() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  static Future<LoginRequester?> getUser(String key) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString(key) != null) {
      var res = json.decode(pref.getString(key)!);
      return LoginRequester?.fromJson(res);
    } else {
      return null;
    }
  }

  static Future<LoginRequester?> getUserDetails() async {
    await getUser("user").then((value) {
      user = value;
    });
    return user;
  }
}
