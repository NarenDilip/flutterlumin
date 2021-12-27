import 'package:flutter/material.dart';

class ilm_maintenance_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ilm_maintenance_screenState();
  }
}

class ilm_maintenance_screenState extends State<ilm_maintenance_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ilm_maintenance_screenForm());
  }
}

class ilm_maintenance_screenForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/icons/background_img.jpeg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
