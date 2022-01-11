import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/region_model.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class region_list_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return region_list_screen_state();
  }
}

class region_list_screen_state extends State<region_list_screen> {

  // return Scaffold(body: regionListview());
  List<String>? _allUsers = [];
  List<String>? _foundUsers = [];
  String selectedZone = "0";

  @override
  initState() {
    // at the beginning, all users are shown
    DBHelper dbHelper = DBHelper();
    Future<List<Region>> regions;
    regions = dbHelper.getDetails();

    regions.then((data) {
      for (int i = 0; i < data.length; i++) {
        String regionname = data[i].regionname.toString();
        _allUsers?.add(regionname);
      }
      setState(() {
        _foundUsers = _allUsers! ;
      });
    }, onError: (e) {
      print(e);
    });

    //loadDetails();
  }

  void loadDetails() async {
    var sharedPreferences = await SharedPreferences.getInstance() as SharedPreferences;
    sharedPreferences.setString("SelectedRegion",selectedZone);
  }

  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers!;
    } else {
      results = _allUsers!
          .where((user) =>
          user.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundUsers = results;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        // onWillPop: () async {
        //   final result = await showDialog(
        //     context: context,
        //     builder: (ctx) =>
        //         AlertDialog(
        //           title: Text("Luminator"),
        //           content: Text("Are you sure you want to exit?"),
        //           actions: <Widget>[
        //             TextButton(
        //               onPressed: () {
        //                 Navigator.of(ctx).pop();
        //               },
        //               child: Text("NO"),
        //             ),
        //             TextButton(
        //               child: Text('YES', style: TextStyle(color: Colors.red)),
        //               onPressed: () {
        //                 // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        //               },
        //             ),
        //           ],
        //         ),
        //   );
        //   return result;
        // },
        child: Scaffold(
          backgroundColor: liorange,
          body: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Select Regions",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25.0,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  onChanged: (value) => _runFilter(value),
                  style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  decoration: const InputDecoration(
                      labelText: 'Search', suffixIcon: Icon(Icons.search)),
                ),
                Expanded(
                  child: _foundUsers!.isNotEmpty
                      ?ListView.builder(
                    itemCount: _foundUsers!.length,
                    itemBuilder: (context, index) =>
                        Card(
                          key: ValueKey(_foundUsers),
                          color: Colors.white,
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            // leading: Text(
                            //   _foundUsers[index]["id"].toString(),
                            //   style: const TextStyle(
                            //       fontSize: 24.0,
                            //       fontFamily: "Montserrat",
                            //       fontWeight: FontWeight.normal,
                            //       color: Colors.black),
                            // ),
                            onTap: () {
                              setState(() {
                                selectedZone = _foundUsers!.elementAt(index).toString();
                                loadDetails();
                              });

                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          zone_li_screen()));
                            },
                            title: Text(_foundUsers!.elementAt(index),
                                style: const TextStyle(
                                    fontSize: 22.0,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ),
                        ),
                  )
                      : const Text(
                    'No results found',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}