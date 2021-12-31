import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class device_count_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_count_screen_state();
  }
}

class device_count_screen_state extends State<device_count_screen> {
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";


  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();
    setState(() {
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;
    });
  }

  @override
  void initState() {
    super.initState();
    SelectedRegion = "";
    getSharedPrefs();
  }


  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   setState(() {
  //     loaddevice();
  //   });
  // }

  // loaddevice() async {
  //   var sharedPreferences = await SharedPreferences.getInstance();
  //   SelectedRegion = sharedPreferences.getString('SelectedRegion').toString();
  //   SelectedZone = sharedPreferences.getString('SelectedZone').toString();
  //   SelectedWard = sharedPreferences.getString('selectedWard').toString();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
                color: btnLightbluColor,
                borderRadius: BorderRadius.all(Radius.circular(35.0))),
            alignment: Alignment.center,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                child: Text('$SelectedRegion',
                                    style: const TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(20)),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ))),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          region_list_screen()));
                                }),
                            SizedBox(width: 5),
                            TextButton(
                                child: Text('$SelectedZone',
                                    style: const TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(20)),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ))),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          zone_li_screen()));
                                }),
                            SizedBox(width: 5),
                            TextButton(
                                child: Text('$SelectedWard',
                                    style: const TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(20)),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ))),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ward_li_screen()));
                                })
                          ])
                      // child: Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     SizedBox(height: 10),
                      //     Expanded(
                      //         child: DropdownButtonField(
                      //             dropdownValue: dropDownValue,
                      //             onChanged: (value) {
                      //               Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => region_list_screen()));
                      //               // setState(() {
                      //               //   dropDownValue = value;
                      //               // });
                      //             },
                      //             spinnerItems: spinnerList)),
                      //     SizedBox(
                      //       width: 4,
                      //     ),
                      //     Expanded(
                      //         child: DropdownButtonField(
                      //             dropdownValue: dropDownValue,
                      //             onChanged: (value) {
                      //               setState(() {
                      //                 dropDownValue = value;
                      //               });
                      //             },
                      //             spinnerItems: spinnerList)),
                      //     SizedBox(
                      //       width: 4,
                      //     ),
                      //     Expanded(
                      //         child: DropdownButtonField(
                      //             dropdownValue: dropDownValue,
                      //             onChanged: (value) {
                      //               setState(() {
                      //                 dropDownValue = value;
                      //               });
                      //             },
                      //             spinnerItems: spinnerList)),
                      //   ],
                      // ),
                      )),
              SizedBox(
                height: 20,
              ),
              Container(
                  child: Card(
                color: Colors.transparent,
                elevation: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Card(
                        elevation: 20,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: <
                                Widget>[
                          const SizedBox(height: 10),
                          Container(
                              child: Row(
                            children: const <Widget>[
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0.0, 0.0, 0),
                                  child: Align(
                                    child: Text(
                                      "ILM",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 15.0, 0),
                                  child: Align(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Center(
                                        child: Text(
                                          "110",
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ],
                          )),
                          const SizedBox(height: 10),
                          Row(
                            children: const <Widget>[
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(40.0, 0.0, 0.0, 0),
                                  child: Align(
                                    child: Text(
                                      "ON",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0.0, 0.0, 0),
                                  child: Align(
                                    child: Text(
                                      "OFF",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 40.0, 0),
                                  child: Align(
                                    child: Text(
                                      "NC",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                    alignment: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: const <Widget>[
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0),
                                  child: Align(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: Center(
                                        child: Text(
                                          "30",
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0.0, 0.0, 0),
                                  child: Align(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      child: Center(
                                        child: Text(
                                          "40",
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 30.0, 0),
                                  child: Align(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      child: Center(
                                        child: Text(
                                          "40",
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.centerRight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ])),
                  ],
                ),
              )),
            ])));
  }
}
