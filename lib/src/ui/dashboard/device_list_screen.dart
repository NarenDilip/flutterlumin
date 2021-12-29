import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/ui/components/dropdown_button_field.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';

class device_list_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_list_screen_state();
  }
}

class device_list_screen_state extends State<device_list_screen> {
  List<String> spinnerList = [
    'One',
    'Two',
    'Three',
  ];

  var dropDownValue = "";
  late bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
            padding: EdgeInsets.fromLTRB(15, 60, 15, 0),
            decoration: const BoxDecoration(
                color: btnLightbluColor,
                borderRadius: BorderRadius.all(Radius.circular(35.0))),
            alignment: Alignment.center,
            child: Container(
                child: Stack(children: [
              Container(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Expanded(
                        child: DropdownButtonField(
                            dropdownValue: dropDownValue,
                            onChanged: (value) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      region_list_screen()));
                              // setState(() {
                              //   dropDownValue = value;
                              // });
                            },
                            spinnerItems: spinnerList)),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                        child: DropdownButtonField(
                            dropdownValue: dropDownValue,
                            onChanged: (value) {
                              setState(() {
                                dropDownValue = value;
                              });
                            },
                            spinnerItems: spinnerList)),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                        child: DropdownButtonField(
                            dropdownValue: dropDownValue,
                            onChanged: (value) {
                              setState(() {
                                dropDownValue = value;
                              });
                            },
                            spinnerItems: spinnerList)),
                  ],
                ),
              )),
              ListView(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                children: <Widget>[
                  const SizedBox(
                    height: 80,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isVisible = true;
                      });
                    },
                    onDoubleTap: () {
                      setState(() {
                        _isVisible = false;
                      });
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: Text('Device Filters',
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Montserrat",
                                                color: Colors.black)))),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: _isVisible,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      height: 130,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30)),
                              child: const Center(
                                child: Text('ILM Number',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: "Montserrat",
                                        color: Colors.black)),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  borderRadius: BorderRadius.circular(30)),
                              child: const Center(
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: "Montserrat",
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 12),
                                      child: Text('ILM Device',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "Montserrat",
                                              color: Colors.black)))),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 12),
                                      child: Text('CCMS Device ',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "Montserrat",
                                              color: Colors.black)))),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 12),
                                      child: Text('Gateway Device',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "Montserrat",
                                              color: Colors.black)))),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                ],
              )
            ]))));
  }
}

class DeviceForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Container(
            padding: new EdgeInsets.all(10.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        TextField(
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          decoration: InputDecoration(
                              labelText: 'ILM Nodes',
                              suffixIcon: Icon(Icons.search)),
                        ),
                      ])),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        TextField(
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          decoration: InputDecoration(
                              labelText: 'Pole Numbers',
                              suffixIcon: Icon(Icons.search)),
                        ),
                      ])),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        TextField(
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          decoration: InputDecoration(
                              labelText: 'CCMS Numbers',
                              suffixIcon: Icon(Icons.search)),
                        ),
                      ])),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0),
                            child: TextField(
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: 'GATEWAY Numbers',
                                  suffixIcon: Icon(Icons.search)),
                            )),
                      ])),
            ])));
  }
}
