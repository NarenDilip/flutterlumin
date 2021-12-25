import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/ui/listview/zone_list_screen.dart';

class region_list_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return region_list_screen_state();
  }
}

class region_list_screen_state extends State<region_list_screen> {
  @override
  Widget build(BuildContext context) {
    // return Scaffold(body: regionListview());
    return Scaffold(body: const region_list_Page());
  }
}

class region_list_Page extends StatefulWidget {
  const region_list_Page({Key? key}) : super(key: key);

  @override
  _region_list_State createState() => _region_list_State();
}

class _region_list_State extends State<region_list_Page> {
  // This holds a list of fiction users
  // You can use data fetched from a database or a server as well
  final List<Map<String, dynamic>> _allUsers = [
    {"id": 1, "name": "VLR", "Devices": 29},
    {"id": 2, "name": "CJB", "Devices": 40},
    {"id": 3, "name": "MAA", "Devices": 5},
    {"id": 4, "name": "DEMO", "Devices": 35},
    {"id": 5, "name": "GOA", "Devices": 21},
    {"id": 6, "name": "MAD", "Devices": 55},
    {"id": 7, "name": "TUP", "Devices": 30},
    {"id": 8, "name": "TVL", "Devices": 14},
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
      final result = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Luminator"),
          content: Text("Are you sure you want to exit?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text("NO"),
            ),
            TextButton(
              child: Text('YES', style: TextStyle(color: Colors.red)),
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
          ],
        ),
      );
      return result;
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
                                        zone_list_screen()));
                          },
                          title: Text(_foundUsers[index]['name'],
                              style: const TextStyle(
                                  fontSize: 22.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          subtitle: Text(
                            '${_foundUsers[index]["Devices"].toString()} Devices',
                            style: const TextStyle(
                                fontSize: 16.0,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
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
