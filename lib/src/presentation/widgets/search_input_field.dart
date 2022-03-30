
import 'package:flutter/material.dart';

class SearchInputField extends StatelessWidget {
 TextEditingController searchInputController;

  SearchInputField({Key? key, required this.searchInputController}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      validator: (value) => null,
      controller: searchInputController,
      decoration: const InputDecoration(
        hintText: 'Enter product number',
        hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Roboto'),
        fillColor: Colors.grey,
        contentPadding: EdgeInsets.all(10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(width: 1.0, style: BorderStyle.solid),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(width: 1.0, style: BorderStyle.solid),
        ),
      ),
    );
  }
}