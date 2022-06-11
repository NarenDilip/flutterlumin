import 'package:flutter/material.dart';
import 'package:flutterlumin/src/utils/utility.dart';

// widget for roundede button design for all stateful classes.

class rounded_button extends StatelessWidget {
  final String text;
  final Function()? press;
  final Color color, textColor;

  const rounded_button({
    required Key? key,
    required this.text,
    required this.press,
    this.color = Colors.cyan,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      width: size.width * Utility.getResponsiveWidth(context),
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        elevation: 1.0,
        color: color,
        onPressed: press,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(29))),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 20.0,
              fontFamily: "Montserrat",
              height: 0.5,
              color: Colors.white),
        ),
      ),
    );
  }
}
