import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';

class ilm_installation_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ilm_installation_screenState();
  }
}

class ilm_installation_screenState extends State<ilm_installation_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ilm_installation_screenForm());
  }
}

class ilm_installation_screenForm extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                dashboard_screen()));
        return true;
      },
      child: Container(
        color: liorange,
        height: size.height,
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: Text('ILM Installation in Progress',
            style: const TextStyle(
                fontSize: 18.0,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.bold,
                color: Colors.white)),
    ));
  }
}
