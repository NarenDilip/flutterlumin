
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
        hintText: 'Search product',
        hintStyle: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.all(10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(width: 1.0, color: Colors.grey,style: BorderStyle.solid),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(width: 1.0, color: Colors.grey, style: BorderStyle.solid),
        ),
      ),
    );
  }
}