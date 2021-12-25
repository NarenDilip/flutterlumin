import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_list_screen.dart';


class ward_list_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ward_list_screen_state();
  }
}

class ward_list_screen_state extends State<ward_list_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const ward_list_Page());
  }
}

class ward_list_Page extends StatefulWidget {
  const ward_list_Page({Key? key}) : super(key: key);

  @override
  _ward_list_State createState() => _ward_list_State();
}

class _ward_list_State extends State<ward_list_Page> {
  // This holds a list of fiction users
  // You can use data fetched from a database or a server as well
  final List<Map<String, dynamic>> _allUsers = [
    {"name": "VLR-1-1"},
    {"name": "VLR-1-2"},
    {"name": "VLR-1-3"},
    {"name": "VLR-1-4"},
    {"name": "VLR-1-5"},
    {
      "name": "VLR-1-6",
    },
    {"name": "VLR-1-7"},
    {"name": "VLR-1-8"},
  ];

  // This list holds the data for the list view
  List<Map<String, dynamic>> _foundUsers = [];

  @override
  initState() {
    // at the beginning, all users are shown
    _foundUsers = _allUsers;
    super.initState();
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
              user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
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
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      zone_list_screen()));
          return true;
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Select Wards",
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
                  child: _foundUsers.isNotEmpty
                      ? ListView.builder(
                          itemCount: _foundUsers.length,
                          itemBuilder: (context, index) => Card(
                            key: ValueKey(_foundUsers[index]["id"]),
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
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            dashboard_screen()));
                              },
                              title: Text(_foundUsers[index]['name'],
                                  style: const TextStyle(
                                      fontSize: 22.0,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              // subtitle: Text(
                              //   '${_foundUsers[index]["Devices"].toString()} Devices',
                              //   style: const TextStyle(
                              //       fontSize: 16.0,
                              //       fontFamily: "Montserrat",
                              //       fontWeight: FontWeight.normal,
                              //       color: Colors.black),
                              // ),
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
