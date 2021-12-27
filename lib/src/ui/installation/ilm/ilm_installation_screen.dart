import 'package:flutter/material.dart';

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
