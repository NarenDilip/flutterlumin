import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterlumin/src/constants/const.dart';

class SearchDevicesView extends StatefulWidget {
  const SearchDevicesView({Key? key}) : super(key: key);

  @override
  _SearchDevicesState createState() => _SearchDevicesState();
}

class _SearchDevicesState extends State<SearchDevicesView> {
  final List<String>? _foundUsers = [];
  String _valueDropdownGrade = 'ILM';

  @override
  void initState() {
    super.initState();
    _foundUsers!.add("FBX201");
    _foundUsers!.add("DEX2021");
    _foundUsers!.add("#EX2021");
    _foundUsers!.add("#TX2221");
    _foundUsers!.add("#TX2221");
    _foundUsers!.add("#TX2221");
    _foundUsers!.add("#TX2221");
    _foundUsers!.add("#TX2221");
    _foundUsers!.add("#TX2221");
    _foundUsers!.add("#TX2221");
    _foundUsers!.add("#TX2221");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 30, top: 40, right: 20),
                child: const Text(
                  "Devices",
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 14, top: 40, right: 20),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 20, // Image radius
                    backgroundImage:
                        NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 20),
            child: Column(
              children: <Widget>[
                _SearchInputField(),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1.0, style: BorderStyle.solid),
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          ),
                          contentPadding: EdgeInsets.all(0.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              hint: const Text('Choose the Product'),
                              onChanged: (newValue) {
                                setState(() => _valueDropdownGrade = newValue!);
                              },
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
                                      width: 100.0, // for example
                                      child: Text(value,
                                          textAlign: TextAlign.center),
                                    ));
                              }).toList()),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const SearchButton()
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          _list()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.qr_code),
        onPressed: () {},
      ),
    );
  }

  _list() => Expanded(
        child: Card(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Scrollbar(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(
                        Icons.highlight,
                        color: kPrimaryColor,
                        size: 40.0,
                      ),
                      title: Text(
                        _foundUsers![index],
                        style: const TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(_foundUsers![index]),
                      onTap: () {},
                    ),
                  ],
                );
              },
              itemCount: _foundUsers!.length,
            ),
          ),
        ),
      );
}

class SearchButton extends StatelessWidget {
  const SearchButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child:
            Text("Search".toUpperCase(), style: const TextStyle(fontSize: 14)),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: kPrimaryColor)))),
        onPressed: () => null);
  }
}

class _SearchInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      validator: (value) => null,
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
          borderSide: BorderSide(
              width: 1.0, style: BorderStyle.solid),
        ),
      ),
    );
  }
}
