import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/ui/dashboard/device_list_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/map_view_screen.dart';
import 'package:flutterlumin/src/ui/device_count_screen.dart';
import 'package:flutterlumin/src/ui/login/login_screen.dart';

import '../../../utils/colors.dart';
import '../../components/dropdown_button_field.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  _MaintenanceScreenState createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _isOn = true;

  void toggle() {
    setState(() => _isOn = !_isOn);
  }

  List<String> spinnerList = [
    'One',
    'Two',
    'Three',
  ];
  var dropDownValue = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
           color: btngreytbluColor,
            padding: const EdgeInsets.fromLTRB(15, 00, 15, 0),
            child: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15, 50, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 10),
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
        ),
        const SizedBox(
          height: 25,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(15, 00, 15, 0),
          decoration: const BoxDecoration(
              color: btnLightbluColor,
              borderRadius: BorderRadius.all(Radius.circular(35.0))),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0))),
                        child: const Text(
                          'ZAA001',
                          style: TextStyle(fontSize: 18,fontFamily: "Montserrat"),
                        ),
                      )),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child:  const Text(
                        '2nd Street , Gandhipuram',maxLines: 1,
                        style: TextStyle(fontSize: 14,fontFamily: "Montserrat"),
                      ),
                      )),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        height: 40,
                        child: const Text(
                          'Lamp Voltage',
                          style: TextStyle(fontSize: 18,fontFamily: "Montserrat"),
                        ),
                      )),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        height: 40,
                        child: const Text(
                          'Last Communication Date and Time',
                          style: TextStyle(fontSize: 16,fontFamily: "Montserrat"),
                        ),
                      )),
                  Expanded(
                      child: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.all(6),
                    height: 40,
                    child: DropdownButton<String>(
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.arrow_drop_down,color: Colors.black,),
                      ),
                      iconSize: 24,
                      elevation: 16,
                      underline: Container(
                        color: Colors.transparent,
                      ),
                      items: [],
                      onChanged: (Object? value) {},
                    ),
                  )),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Expanded(flex: 2, child: ToggleButton()),
            const SizedBox(
              width: 15,
            ),
            Expanded(
                flex: 2,
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(34, 255, 59, 59),
                      borderRadius: BorderRadius.all(Radius.circular(50.0))),
                  child: const Center(
                    child: Text('GET LIVE', style: TextStyle(fontSize: 18,fontFamily: "Montserrat")),
                  ),
                )),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
        const Text(
          "Replace With",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontFamily: "Montserrat"),
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                flex: 2,
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(34, 255, 59, 59),
                      borderRadius: BorderRadius.all(Radius.circular(50.0))),
                  child: const Center(
                    child: Text('Shorting CAP',style: TextStyle(fontSize: 18,fontFamily: "Montserrat")),
                  ),
                )),
            const SizedBox(
              width: 15,
            ),
            Expanded(
                flex: 2,
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(50.0))),
                  child: const Center(
                    child: Text('ILM', style: TextStyle(fontSize: 18,fontFamily: "Montserrat")),
                  ),
                )),
          ],
        ),
      ],
    )));
  }
}

class ToggleButton extends StatefulWidget {
  const ToggleButton({Key? key}) : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

const double width = 300.0;
const double height = 100.0;
const double loginAlign = -1;
const double signInAlign = 1;
const Color selectedColor = Colors.white;
const Color normalColor = Colors.black54;

class _ToggleButtonState extends State<ToggleButton> {
  late double xAlign;
  late Color loginColor;
  late Color signInColor;

  @override
  void initState() {
    super.initState();
    xAlign = loginAlign;
    loginColor = selectedColor;
    signInColor = normalColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.green,
        borderRadius: const BorderRadius.all(
          Radius.circular(50.0),
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(xAlign, 0),
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: width * 0.35,
              height: height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(50.0),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                xAlign = loginAlign;
                loginColor = Colors.black;
                signInColor = normalColor;
              });
            },
            child: Align(
              alignment: const Alignment(-1, 0),
              child: Container(
                width: width * 0.35,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    'ON',
                    style: TextStyle(
                      color: loginColor,
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                xAlign = signInAlign;
                signInColor = Colors.black;

                loginColor = normalColor;
              });
            },
            child: Align(
              alignment: const Alignment(1, 0),
              child: Container(
                width: width * 0.35,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    'OFF',
                    style: TextStyle(
                      color: signInColor,
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
