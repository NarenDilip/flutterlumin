import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/const.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    required this.labelName,
    required this.itemPressed,
  }) : super(key: key);
  final String labelName;
  final Function() itemPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: itemPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            width: 140,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12),
            color: kPrimaryColor ,
            child: Text(labelName  ,
                style:
                TextStyle(color: Colors.white, fontFamily: "Roboto")),
          ),
        ));
  }
}