import 'package:flutter/material.dart';
import 'package:flutterlumin/src/utils/colors.dart';

// widget for Dropdown button design for all stateful classes.

class DropdownButtonField extends StatelessWidget {
  final String dropdownValue;
  final ValueChanged<dynamic>? onChanged;
  final List<String> spinnerItems;

  const DropdownButtonField(
      { Key? key,
      required this.dropdownValue,
        required this.onChanged,
      required this.spinnerItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      child: DropdownButton<String>(
        isExpanded: true,
        value: dropdownValue.isNotEmpty?dropdownValue:null,
        icon: Padding(padding: EdgeInsets.only(right: 10),child: Icon(Icons.arrow_drop_down),),
        iconSize: 24,
        elevation: 16,
        underline: Container(
          color: Colors.transparent,
        ),
        style: TextStyle(color: Colors.black, fontSize: 16),
       onChanged: onChanged,
        items: spinnerItems.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(padding: EdgeInsets.only(left: 5),child: Text(value),),
          );
        }).toList(),
      ),
    );
  }
}
