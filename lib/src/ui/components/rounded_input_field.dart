import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/utils/utility.dart';

// widget for rounded input button design for all stateful classes.

class rounded_input_field extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final Function(String?) onSaved;
  final bool isObscure;
  final TextEditingController controller;

  const rounded_input_field({
    Key? key,
    required this.hintText,
    required this.onChanged,
    required this.validator,
    required this.onSaved,
    required this.isObscure,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        width: size.width * Utility.getResponsiveWidth(context),
        child: TextFormField(
          style: const TextStyle(
              fontSize: 16.0,
              fontFamily: "Montserrat",
              height: 1.25,
              color: Colors.black),
          validator: validator,
          onSaved: onSaved,
          onChanged: onChanged,
          obscureText: isObscure,
          controller: controller,
          cursorColor: kPrimaryColor,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Colors.white,
            errorStyle: const TextStyle(fontSize: 18),
            filled: true,
            focusedBorder: const OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderRadius: BorderRadius.all(Radius.circular(70.0)),
              borderSide: BorderSide(color: thbDblue),
              //borderSide: const BorderSide(),
            ),
            enabledBorder: const OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderRadius: BorderRadius.all(Radius.circular(70.0)),
              borderSide: BorderSide(color: thbDblue),
              //borderSide: const BorderSide(),
            ),
          ),
        ));
  }
}
