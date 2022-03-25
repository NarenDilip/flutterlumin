import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final String _valueDropdownGrade = 'ILM';

  @override
  Widget build(BuildContext context) {
    return Wrap(children: <Widget>[
      Container(
        padding:
            const EdgeInsets.only(left: 40, top: 20, right: 40, bottom: 20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Align(
                alignment: Alignment.center,
                child: Text("Choose your ward",
                    style: TextStyle(fontSize: 20, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Region',
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              DropDownMenu(valueDropdownGrade: _valueDropdownGrade),
              const SizedBox(
                height: 24,
              ),
              const Text(
                'Zone',
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              DropDownMenu(valueDropdownGrade: _valueDropdownGrade),
              const SizedBox(
                height: 24,
              ),
              const Text(
                'Ward',
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              DropDownMenu(valueDropdownGrade: _valueDropdownGrade),
              const SizedBox(
                height: 24,
              ),
              const Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: SearchButton(),
                  ))
            ]),
      )
    ]);
  }
}

class DropDownMenu extends StatelessWidget {
  const DropDownMenu({
    Key? key,
    required String valueDropdownGrade,
  })  : _valueDropdownGrade = valueDropdownGrade,
        super(key: key);

  final String _valueDropdownGrade;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 1.0, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        contentPadding: EdgeInsets.all(0.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            icon: const Icon(Icons.arrow_drop_down),
            hint: const Text('Choose the Product'),
            onChanged: (newValue) {},
            value: _valueDropdownGrade,
            items: <String>[
              'ILM',
              'CCMS',
              'GATEWAY',
              'POLE',
            ].map((String value) {
              return DropdownMenuItem<String>(
                  value: value,
                  child: SizedBox(
                    width: 80.0, // for example
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
                    ),
                  ));
            }).toList()),
      ),
    );
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Text("APPLY".toUpperCase(),
            style: const TextStyle(fontSize: 16, fontFamily: 'Roboto')),
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
