import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/ui/components/dropdown_button_field.dart';

class device_list_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_list_screen_state();
  }
}

class device_list_screen_state extends State<device_list_screen> {
  List <String> spinnerList = [
    'One',
    'Two',
    'Three',
  ] ;
  var dropDownValue = "";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(body: Scaffold(
        appBar:AppBar(title: const Text("Luminator", style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: "Montserrat",
        )),),body: Container(
        height: size.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/icons/background_img.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child:   DropdownButtonField(dropdownValue: dropDownValue,onChanged: (value){
                          setState(() {
                            dropDownValue = value;
                          });
                        },spinnerItems: spinnerList)),
                        SizedBox(width: 4,),
                        Expanded(child:   DropdownButtonField(dropdownValue: dropDownValue,onChanged: (value){
                          setState(() {
                            dropDownValue = value;
                          });
                        },spinnerItems: spinnerList)),
                        SizedBox(width: 4,),
                        Expanded(child:   DropdownButtonField(dropdownValue: dropDownValue,onChanged: (value){
                          setState(() {
                            dropDownValue = value;
                          });
                        },spinnerItems: spinnerList)),

                      ],
                    ),
                  ),
                ),
                Align(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                          image: AssetImage("assets/icons/logo.png"),
                          height: 75,
                          width: 75),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Device List",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30.0,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )))));
  }
}

class DeviceForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
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
                    mainAxisSize: MainAxisSize.min, children: const <Widget>[

                  TextField(
                    style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    decoration: InputDecoration(
                        labelText: 'ILM Nodes', suffixIcon: Icon(Icons.search)),
                  ),
                ])),

            Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 10,

                child: Column(
                    mainAxisSize: MainAxisSize.min, children: const <Widget>[

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
                    mainAxisSize: MainAxisSize.min, children: const <Widget>[

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
                    mainAxisSize: MainAxisSize.min, children: const < Widget>[
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
