import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';

import 'modal_bottom_sheet.dart';

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  final String _valueDropdownGrade = 'ILM';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 40, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Image(
              image: AssetImage("assets/icons/logo.png"),
              height: 30,
              width: 30),
          const Text(
            "VLR-1-1",
            style: TextStyle(
                fontSize: 26,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_alt_outlined,
            ),
            iconSize: 30,
            color: kPrimaryColor,
            splashColor: kPrimaryColor,
            onPressed: () {
              _modalBottomSheetMenu(context, _valueDropdownGrade);
            },
          ),
        ],
      ),
    );
  }
}

void _modalBottomSheetMenu(BuildContext context, String valueDropdownGrade) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (builder) {
        return const FilterBottomSheet();
      });
}

class SearchButton extends StatelessWidget {
  const SearchButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Text("APPLY".toUpperCase(),
            style: const TextStyle(fontSize: 20, fontFamily: 'Roboto')),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    side: BorderSide(color: kPrimaryColor)))),
        onPressed: () => {Navigator.pop(context)});
  }
}
