import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localdb/db_helper.dart';
import '../../../localdb/model/region_model.dart';
import '../../../ui/splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            padding:
                const EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 20),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                const Text(
                  "Settings",
                  style: TextStyle(fontSize: 30, fontFamily: "Roboto", color: Colors.black54,
                    fontWeight: FontWeight.bold,),
                ),
                SizedBox(
                  height: 30,
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: lightGrey, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 14, top: 20, bottom: 20, right: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            showLogoutPopup(context);
                          },
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 34.0,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Roboto',
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(color: Colors.black26),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(
                              Icons.verified_user,
                              color: Colors.blue,
                              size: 34.0,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Profile",
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Roboto',
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


Future<bool> showLogoutPopup(context) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Luminator",
                    style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(app_logout),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            DBHelper dbhelper = new DBHelper();
                            SharedPreferences prefs = await SharedPreferences.getInstance();

                            var SelectedRegion = prefs.getString("SelectedRegion").toString();
                            List<Region> details = await dbhelper.region_getDetails();

                            for (int i = 0; i < details.length; i++) {
                              dbhelper.delete(details.elementAt(i).id!.toInt());
                            }
                            dbhelper.zone_delete(SelectedRegion);
                            dbhelper.ward_delete(SelectedRegion);

                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            await preferences.clear();

                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (BuildContext context) => splash_screen()));
                          } catch (e) {
                            // FlutterLogs.logInfo("devicecount_page", "device_count", "Db Exception");
                          }
                        },
                        child: const Text("Yes"),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red.shade800),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("No",
                              style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                          ),
                        ))
                  ],
                )
              ],
            ),
          ),
        );
      });
}
