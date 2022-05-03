import 'package:flutter/material.dart';

class SearchInputField extends StatelessWidget {
  TextEditingController searchInputController;
  Function onSearchButtonClicked;

  SearchInputField(
      {Key? key,
      required this.searchInputController,
      required this.onSearchButtonClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      validator: (value) => null,
      controller: searchInputController,
      decoration: InputDecoration(
        hintText: 'Search product',
        hintStyle: const TextStyle(color: Colors.black, fontFamily: 'Roboto'),
        fillColor: Colors.white,
        filled: true,
        suffixIcon: GestureDetector(
          onTap: () {
            onSearchButtonClicked();
          },
          child: const Icon(
            Icons.search,
          ),
        ),
        contentPadding: const EdgeInsets.all(10.0),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(
              width: 1.0, color: Colors.grey, style: BorderStyle.solid),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(
              width: 1.0, color: Colors.grey, style: BorderStyle.solid),
        ),
      ),
    );
  }
}
