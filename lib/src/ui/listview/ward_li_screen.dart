import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/ward_model.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ward_li_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ward_li_screen_state();
  }
}

class ward_li_screen_state extends State<ward_li_screen> {

  // return Scaffold(body: regionListview());
  List<String>? _allUsers = [];
  List<String>? _foundUsers = [];
  String selectedZone = "0";
  String selectedWard = "0";

  @override
  initState() {
    // at the beginning, all users are shown
    loadDetails();
  }

  void loadDetails() async {
    DBHelper dbHelper = DBHelper();
    Future<List<Ward>> wards;

    var sharedPreferences = await SharedPreferences.getInstance();
    selectedZone = sharedPreferences.getString("SelectedZone").toString();

    if(selectedZone  != "0") {
      wards = dbHelper.ward_zonebasedDetails(selectedZone);
      wards.then((data) {
        for (int i = 0; i < data.length; i++) {
          String regionname = data[i].wardname.toString();
          _allUsers?.add(regionname);
        }
        setState(() {
          _foundUsers = _allUsers! ;
        });
      }, onError: (e) {
        print(e);
      });
    }

    // setState(() {
    //   _foundUsers = _allUsers! ;
    // });
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

  loadLocalData() async {
    var sharedPreferences = await SharedPreferences.getInstance() as SharedPreferences;
    sharedPreferences.setString("SelectedWard",selectedWard);
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
                  "Select Ward",
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
                                selectedWard = _foundUsers!.elementAt(index).toString();
                                loadLocalData();
                              });
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          dashboard_screen()));
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