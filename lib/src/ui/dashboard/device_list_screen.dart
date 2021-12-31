import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/models/devicelistrequester.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/components/dropdown_button_field.dart';
import 'package:flutterlumin/src/ui/components/rounded_input_field.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class device_list_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_list_screen_state();
  }
}

class device_list_screen_state extends State<device_list_screen> {
  List<String>? _foundUsers = [];
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";
  bool _visible = false;
  String searchNumber = "0";
  final TextEditingController _emailController =
  TextEditingController(text: "");

  final user = DeviceRequester(
      ilmnumber: "",
      );


  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();

    setState(() {
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;
    });
  }

  @override
  void initState() {
    super.initState();
    SelectedRegion = "";
    getSharedPrefs();
  }

  void _toggle() {
    setState(() {
      _visible = !_visible;
    });
  }

  var dropDownValue = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
            padding: EdgeInsets.fromLTRB(15, 60, 15, 0),
            decoration: const BoxDecoration(
                color: btnLightbluColor,
                borderRadius: BorderRadius.all(Radius.circular(35.0))),
            alignment: Alignment.center,
            child: Container(
                child: Stack(children: [
              Container(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          child: Text('$SelectedRegion',
                              style: const TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(20)),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ))),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    region_list_screen()));
                          }),
                      SizedBox(width: 5),
                      TextButton(
                          child: Text('$SelectedZone',
                              style: const TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(20)),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ))),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    zone_li_screen()));
                          }),
                      SizedBox(width: 5),
                      TextButton(
                          child: Text('$SelectedWard',
                              style: const TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(20)),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ))),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ward_li_screen()));
                          })
                    ]),
              )),
              ListView(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                children: <Widget>[
                  const SizedBox(
                    height: 80,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _toggle();
                      });
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: Text('Device Filters',
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontFamily: "Montserrat",
                                                color: Colors.black)))),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          rounded_input_field(
                            hintText: "ILM Number",
                            isObscure: false,
                            controller: _emailController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter the ILM Number";
                              } else if (!EmailValidator.validate(value)) {
                                return "Please enter the validate ILM Number";
                              }
                            },
                            onSaved: (value) => user.ilmnumber = value!,
                            onChanged: (String value) {
                              user.ilmnumber = value;
                            },
                          ),
                          // TextFormField(
                          //   style: const TextStyle(
                          //       fontSize: 18.0,
                          //       fontFamily: "Montserrat",
                          //       color: Colors.black),
                          //   decoration: const InputDecoration(
                          //     labelText: 'ILM Number',
                          //   ),
                          //   onSaved: (String? value) {
                          //       searchNumber = value!;
                          //   },
                          //   validator: (String? value) {
                          //     return (value != null && value.contains('@'))
                          //         ? 'Do not use the @ char.'
                          //         : null;
                          //   },
                          // ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              callILMDeviceListFinder(user.ilmnumber, context);
                            },
                            child: const Text('Search',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: "Montserrat",
                                    color: Colors.black)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    visible: _visible,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Expanded(
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 12),
                                      child: Text('ILM Device',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "Montserrat",
                                              color: Colors.black)))),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: _foundUsers!.isNotEmpty
                        ? ListView.builder(
                            itemCount: _foundUsers!.length,
                            itemBuilder: (context, index) => Card(
                              key: ValueKey(_foundUsers),
                              color: Colors.white,
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                // leading: Text(
                                //   _foundUsers[index]["id"].toString(),
                                //   style: const TextStyle(
                                //       fontSize: 24.0,
                                //       fontFamily: "Montserrat",
                                //       fontWeight: FontWeight.normal,
                                //       color: Colors.black),
                                // ),
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              zone_li_screen()));
                                },
                                title: Text(_foundUsers!.elementAt(index),
                                    style: const TextStyle(
                                        fontSize: 22.0,
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ),
                            ),
                          )
                        : const Text(
                            'No results found',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 22.0,
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.normal,
                                color: Colors.black),
                          ),
                  ),
                ],
              )
            ]))));
  }

  Future<void> callILMDeviceListFinder(
      String searchNumber, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          PageLink pageLink = new PageLink(100);
          pageLink.page = 0;
          pageLink.pageSize = 100;
          pageLink.textSearch = user.ilmnumber.toString();

          PageData<Device> devicelist_response;
          devicelist_response =
              (await tbClient.getDeviceService().getTenantDevices(pageLink)) as PageData<Device> ;

          if (devicelist_response.totalElements != 0) {
            for (int i = 0; i < devicelist_response.data.length; i++) {
              String name =
                  devicelist_response.data.elementAt(i).name.toString();
              _foundUsers!.add(name);
            }
          }

          setState(() {
            _foundUsers = _foundUsers;
          });
        } catch (e) {}
      }
    });
  }
}

class DeviceForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Container(
            padding: new EdgeInsets.all(10.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        TextField(
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          decoration: InputDecoration(
                              labelText: 'ILM Nodes',
                              suffixIcon: Icon(Icons.search)),
                        ),
                      ])),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        TextField(
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          decoration: InputDecoration(
                              labelText: 'Pole Numbers',
                              suffixIcon: Icon(Icons.search)),
                        ),
                      ])),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        TextField(
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Montserrat",
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          decoration: InputDecoration(
                              labelText: 'CCMS Numbers',
                              suffixIcon: Icon(Icons.search)),
                        ),
                      ])),
              Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0),
                            child: TextField(
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              decoration: InputDecoration(
                                  labelText: 'GATEWAY Numbers',
                                  suffixIcon: Icon(Icons.search)),
                            )),
                      ])),
            ])));
  }
}
