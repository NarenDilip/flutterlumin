import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'components/dropdown_button_field.dart';

class device_count_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_count_screen_state();
  }
}

class device_count_screen_state extends State<device_count_screen> {
  List<String> spinnerList = [
    'One',
    'Two',
    'Three',
  ];

  var dropDownValue = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Card(
                      elevation: 10,
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        const SizedBox(height: 10),
                        Container(
                            color: Colors.white,
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
                                    padding:
                                        EdgeInsets.fromLTRB(0, 0.0, 0.0, 0),
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
                                padding: EdgeInsets.fromLTRB(40.0, 0.0, 0.0, 0),
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
                                padding: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0),
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
                  Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10,
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        const SizedBox(height: 10),
                        Container(
                            color: Colors.white,
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
                                    padding:
                                        EdgeInsets.fromLTRB(0, 0.0, 0.0, 0),
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
                                padding: EdgeInsets.fromLTRB(40.0, 0.0, 0.0, 0),
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
                                padding: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0),
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
                  Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10,
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        const SizedBox(height: 10),
                        Container(
                            color: Colors.white,
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
                                    padding:
                                        EdgeInsets.fromLTRB(0, 0.0, 0.0, 0),
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
                                padding: EdgeInsets.fromLTRB(40.0, 0.0, 0.0, 0),
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
                                padding: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0),
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
            )));
  }
}
//     body: Container(
//   child: Column(
//     children: [
//       Padding(padding: EdgeInsets.all(4),child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(width: 50,height: 100),
//           Expanded(child:   DropdownButtonField(dropdownValue: dropDownValue,onChanged: (value){
//             setState(() {
//               dropDownValue = value;
//             });
//           },spinnerItems: spinnerList)),
//           SizedBox(width: 4,),
//           Expanded(child:   DropdownButtonField(dropdownValue: dropDownValue,onChanged: (value){
//             setState(() {
//               dropDownValue = value;
//             });
//           },spinnerItems: spinnerList)),
//           SizedBox(width: 4,),
//           Expanded(child:   DropdownButtonField(dropdownValue: dropDownValue,onChanged: (value){
//             setState(() {
//               dropDownValue = value;
//             });
//           },spinnerItems: spinnerList)),
//
//         ],
//       ),),
//       Expanded(child: SingleChildScrollView(
//         child: DeviceCountForm(),
//       ))
//     ],
//   ),
// )
// );
// }
// }

class DeviceCountForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
        child: Container(
            padding: new EdgeInsets.all(10.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    const SizedBox(height: 10),
                    Container(
                        color: Colors.white,
                        child: Row(
                          children: const <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0),
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
                            padding: EdgeInsets.fromLTRB(40.0, 0.0, 0.0, 0),
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
                            padding: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0),
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
              const SizedBox(height: 10),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    const SizedBox(height: 10),
                    Row(
                      children: const <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0),
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
                                "CCMS",
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
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(40.0, 0.0, 0.0, 0),
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
                            padding: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0),
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
              const SizedBox(height: 10),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    const SizedBox(height: 10),
                    Row(
                      children: const <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0),
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
                                "GATEWAY",
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
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(40.0, 0.0, 0.0, 0),
                            child: Align(
                              child: Text(
                                "ON",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18.0,
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
                                    fontSize: 18.0,
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
                                    fontSize: 18.0,
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
                            padding: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0),
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
            ])));
  }
}
