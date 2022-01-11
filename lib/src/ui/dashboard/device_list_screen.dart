import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/models/devicelistrequester.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/installation/ilm/ilm_installation_screen.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/ilm_maintenance_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import '../splash_screen.dart';
import 'dashboard_screen.dart';


class device_list_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return device_list_screen_state();
  }
}

class device_list_screen_state extends State<device_list_screen> {
  List<String>? _foundUsers = [];
  List<String>? _relationdevices = [];
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";
  bool _visible = true;
  bool _ilmvisible = true;
  bool _obscureText = true;
  String searchNumber = "0";
  final TextEditingController _emailController =
  TextEditingController(text: "");

  final user = DeviceRequester(
    ilmnumber: "",
    ccmsnumber: "",
    polenumber: "",
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

      if (SelectedRegion == "0" || SelectedRegion == "null") {
        SelectedRegion = "Region";
        SelectedZone = "Zone";
        SelectedWard = "Ward";
      }
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

  void _vtoggle() {
    setState(() {
      _ilmvisible = !_ilmvisible;
    });
  }

  var dropDownValue = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return WillPopScope(
        onWillPop: () async {
          final result = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 0),
              backgroundColor: Colors.white,
              title: Text("Luminator", style: const TextStyle(
                  fontSize: 25.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: liorange)),
              content: Text("Are you sure you want to exit?", style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text("NO", style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
                ),
                TextButton(
                  child: Text('YES',  style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                ),
              ],
            ),
          );
          return result;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            extendBody: true,
            body: Container(
                color: lightorange,
                child: Column(children: [
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                        color: lightorange,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                            bottomLeft: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0))),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: Text('Device List view',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 25.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Positioned(
                          right: 10,
                          top: 15,
                          bottom: 0,
                          child: IconButton(
                            color: Colors.red,
                            icon: Icon(
                              IconData(0xe3b3, fontFamily: 'MaterialIcons'),
                              size: 35,
                            ),
                            onPressed: () {
                              callLogoutoption(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(35.0),
                                  topRight: Radius.circular(35.0),
                                  bottomLeft: Radius.circular(0.0),
                                  bottomRight: Radius.circular(0.0))),
                          child: ListView(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                            children: <Widget>[
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                      child: Text('$SelectedRegion',
                                          style: const TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(EdgeInsets.all(20)),
                                          backgroundColor:
                                          MaterialStateProperty.all(
                                              lightorange),
                                          foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.black),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(18.0),
                                              ))),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                    region_list_screen()));
                                      }),
                                  SizedBox(width: 5),
                                  TextButton(
                                      child: Text('$SelectedZone',
                                          style: const TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(EdgeInsets.all(20)),
                                          backgroundColor:
                                          MaterialStateProperty.all(
                                              lightorange),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(18.0),
                                              ))),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                    zone_li_screen()));
                                      }),
                                  SizedBox(width: 5),
                                  TextButton(
                                      child: Text('$SelectedWard',
                                          style: const TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(EdgeInsets.all(20)),
                                          backgroundColor:
                                          MaterialStateProperty.all(
                                              lightorange),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(18.0),
                                              ))),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                    ward_li_screen()));
                                      })
                                ],
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
                                        color: liorange,
                                        borderRadius:
                                        BorderRadius.circular(30)),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12),
                                                    child: Text(
                                                        'Device Filters',
                                                        style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontFamily:
                                                            "Montserrat",
                                                            color: Colors
                                                                .black)))),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                Alignment.centerRight,
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
                              const SizedBox(
                                height: 5,
                              ),
                              Visibility(
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                  decoration: BoxDecoration(
                                      color: liorange,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                                autofocus: false,
                                                keyboardType:
                                                TextInputType.text,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  hintText: 'ILM Number',
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 0, 0, 0),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                      borderSide: BorderSide(
                                                          color: Colors.white)),
                                                  suffixIcon: GestureDetector(
                                                    onTap: () {
                                                      if (user.ilmnumber
                                                          .isNotEmpty) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                            FocusNode());
                                                        callILMDeviceListFinder(
                                                            user.ilmnumber,
                                                            context);
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                            "Please Enter Device",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                            ToastGravity
                                                                .BOTTOM,
                                                            timeInSecForIosWeb:
                                                            1);
                                                      }
                                                    },
                                                    child: Icon(
                                                      _obscureText
                                                          ? Icons.search
                                                          : Icons.search,
                                                      semanticLabel:
                                                      _obscureText
                                                          ? 'show password'
                                                          : 'hide password',
                                                    ),
                                                  ),
                                                ),
                                                onSaved: (value) =>
                                                user.ilmnumber =
                                                    value!.toUpperCase(),
                                                onChanged: (String value) {
                                                  user.ilmnumber =
                                                      value.toUpperCase();
                                                  setState(() {
                                                    _foundUsers!.clear();
                                                  });
                                                }))
                                      ]),
                                      const SizedBox(height: 5),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                                autofocus: false,
                                                keyboardType:
                                                TextInputType.text,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  hintText: 'CCMS Number',
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 0, 0, 0),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                      borderSide: BorderSide(
                                                          color: Colors.white)),
                                                  suffixIcon: GestureDetector(
                                                    onTap: () {
                                                      if (user.ccmsnumber
                                                          .isNotEmpty) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                            FocusNode());
                                                        callccmsbasedILMDeviceListFinder(
                                                            user.ccmsnumber,
                                                            _relationdevices,
                                                            _foundUsers,
                                                            context);
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                            "Please Enter Device",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                            ToastGravity
                                                                .BOTTOM,
                                                            timeInSecForIosWeb:
                                                            1);
                                                      }
                                                    },
                                                    child: Icon(
                                                      _obscureText
                                                          ? Icons.search
                                                          : Icons.search,
                                                      semanticLabel:
                                                      _obscureText
                                                          ? 'show password'
                                                          : 'hide password',
                                                    ),
                                                  ),
                                                ),
                                                onSaved: (value) =>
                                                user.ccmsnumber =
                                                    value!.toUpperCase(),
                                                onChanged: (String value) {
                                                  user.ccmsnumber =
                                                      value.toUpperCase();
                                                  setState(() {
                                                    _foundUsers!.clear();
                                                  });
                                                }))
                                      ]),
                                      const SizedBox(height: 5),
                                      Row(children: [
                                        Flexible(
                                            child: TextFormField(
                                                autofocus: false,
                                                keyboardType:
                                                TextInputType.text,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  hintText: 'Pole Number',
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 0, 0, 0),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                      borderSide: BorderSide(
                                                          color: Colors.white)),
                                                  suffixIcon: GestureDetector(
                                                    onTap: () {
                                                      if (user.polenumber
                                                          .isNotEmpty) {
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                            FocusNode());
                                                        callpolebasedILMDeviceListFinder(
                                                            user.polenumber,
                                                            _relationdevices,
                                                            _foundUsers,
                                                            context);
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                            "Please Enter Device",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                            ToastGravity
                                                                .BOTTOM,
                                                            timeInSecForIosWeb:
                                                            1);
                                                      }
                                                    },
                                                    child: Icon(
                                                      _obscureText
                                                          ? Icons.search
                                                          : Icons.search,
                                                      semanticLabel:
                                                      _obscureText
                                                          ? 'show password'
                                                          : 'hide password',
                                                    ),
                                                  ),
                                                ),
                                                onSaved: (value) =>
                                                user.polenumber =
                                                    value!.toUpperCase(),
                                                onChanged: (String value) {
                                                  user.polenumber =
                                                      value.toUpperCase();
                                                  setState(() {
                                                    _foundUsers!.clear();
                                                  });
                                                }))
                                      ]),
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
                              Container(
                                child: Row(
                                  children: [],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                      color: liorange,
                                      borderRadius: BorderRadius.circular(0)),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _vtoggle();
                                          });
                                        },
                                        child: Container(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Padding(
                                                        padding: EdgeInsets
                                                            .only(
                                                            left: 12),
                                                        child: Text(
                                                            'ILM Devices',
                                                            style: TextStyle(
                                                                fontSize: 18.0,
                                                                fontFamily:
                                                                "Montserrat",
                                                                color: Colors
                                                                    .black)))),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                    Alignment.centerRight,
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                          12),
                                                      child: Icon(
                                                        Icons.arrow_drop_down,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                    ],
                                  )),
                              Visibility(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Container(
                                          color: liorange,
                                          child: Expanded(
                                            child: _foundUsers!.isNotEmpty
                                                ? ListView.builder(
                                              primary: false,
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemCount: _foundUsers!.length,
                                              itemBuilder: (context, index) =>
                                                  Card(
                                                    key: ValueKey(_foundUsers),
                                                    color: Colors.white,
                                                    margin:
                                                    const EdgeInsets.fromLTRB(
                                                        15, 1, 10, 0),
                                                    child: ListTile(
                                                      onTap: () {
                                                        fetchDeviceDetails(
                                                            _foundUsers!
                                                                .elementAt(index)
                                                                .toString(),
                                                            context);
                                                      },
                                                      title: Text(
                                                          _foundUsers!
                                                              .elementAt(index),
                                                          style: const TextStyle(
                                                              fontSize: 22.0,
                                                              fontFamily:
                                                              "Montserrat",
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: Colors.black)),
                                                    ),
                                                  ),
                                            )
                                                : Container(
                                                color: Colors.white,
                                                child: Column(children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    'No results found',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 18.0,
                                                        fontFamily: "Montserrat",
                                                        fontWeight:
                                                        FontWeight.normal,
                                                        color: Colors.black),
                                                  )
                                                ])),
                                          )),
                                    ],
                                  ),
                                ),
                                visible: _ilmvisible,
                              ),
                            ],
                          )))
                ]))));
  }

  Future<void> callILMDeviceListFinder(String searchNumber,
      BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        Utility.progressDialog(context);
        try {
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          PageLink pageLink = new PageLink(100);
          pageLink.page = 0;
          pageLink.pageSize = 100;
          pageLink.textSearch = user.ilmnumber.toString();

          PageData<Device> devicelist_response;
          devicelist_response = (await tbClient
              .getDeviceService()
              .getTenantDevices(pageLink)) as PageData<Device>;

          if(devicelist_response != null) {
            if (devicelist_response.totalElements != 0) {
              for (int i = 0; i < devicelist_response.data.length; i++) {
                String name =
                devicelist_response.data
                    .elementAt(i)
                    .name
                    .toString();
                _foundUsers!.add(name);
              }
            }

            setState(() {
              _foundUsers = _foundUsers;
            });
            Navigator.pop(context);
          }else{
            calltoast(searchNumber);
          }
        } catch (e) {
          Navigator.pop(context);
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callpolebasedILMDeviceListFinder(
                  user.ilmnumber,
                  _relationdevices,
                  _foundUsers,
                  context);
            }
          } else {
            calltoast(searchNumber);
            // Navigator.pop(context);
          }
        }
      }else{
        calltoast(no_network);
      }
    });
  }

  void callpolebasedILMDeviceListFinder(String polenumber,
      List<String>? _relationdevices, List<String>? _foundUsers,
      BuildContext context) {
    Utility.isConnected().then((value) async {
      if (value) {
        Utility.progressDialog(context);
        try {
          _relationdevices!.clear();
          _foundUsers!.clear();
          Asset response;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();
          response =
          await tbClient.getAssetService().getTenantAsset(polenumber)
          as Asset;

          if (response != null) {
            List<EntityRelation> relationresponse;
            relationresponse =
            await tbClient.getEntityRelationService().findByFrom(
                response.id!);
            if (relationresponse != null) {
              for (int i = 0; i < relationresponse.length; i++) {
                _relationdevices.add(relationresponse
                    .elementAt(i)
                    .to
                    .id
                    .toString());
              }
              Device devrelationresponse;
              for (int i = 0; i < _relationdevices.length; i++) {
                devrelationresponse =
                await tbClient.getDeviceService().getDevice(
                    _relationdevices.elementAt(i).toString()) as Device;
                if (devrelationresponse != null) {
                  if (devrelationresponse.type == "lumiNode") {
                    _foundUsers!.add(devrelationresponse.name);
                  } else {}
                } else {
                  calltoast(polenumber);
                  Navigator.pop(context);
                }
              }
              setState(() {
                _foundUsers = _foundUsers;
              });
              Navigator.pop(context);
            } else {
              calltoast(polenumber);
              Navigator.pop(context);
            }
          } else {
            calltoast(polenumber);
            Navigator.pop(context);
          }
        } catch (e) {
          Navigator.pop(context);
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callpolebasedILMDeviceListFinder(
                  user.polenumber,
                  _relationdevices,
                  _foundUsers,
                  context);
            }
          } else {
            calltoast(polenumber);
            Navigator.pop(context);
          }
        }
      }else{
        calltoast(no_network);
      }
    });
  }

  void callccmsbasedILMDeviceListFinder(String ccmsnumber,
      List<String>? _relationdevices, List<String>? _foundUsers,
      BuildContext context) {
    Utility.isConnected().then((value) async {
      if (value) {
        Utility.progressDialog(context);
        try {
          _relationdevices!.clear();
          _foundUsers!.clear();
          Device response;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();
          response =
          await tbClient.getDeviceService().getTenantDevice(ccmsnumber)
          as Device;

          if (response != null) {
            List<EntityRelation> relationresponse;
            relationresponse =
            await tbClient.getEntityRelationService().findByFrom(
                response.id!);
            if (relationresponse != null) {
              for (int i = 0; i < relationresponse.length; i++) {
                _relationdevices.add(relationresponse
                    .elementAt(i)
                    .to
                    .id
                    .toString());
              }
              Device Devrelationresponse;
              for (int i = 0; i < _relationdevices.length; i++) {
                Devrelationresponse =
                await tbClient.getDeviceService().getDevice(
                    _relationdevices.elementAt(i).toString()) as Device;
                if (Devrelationresponse != null) {
                  if (Devrelationresponse.type == "lumiNode") {
                    _foundUsers!.add(Devrelationresponse.name);
                  } else {}
                } else {
                  calltoast(ccmsnumber);
                  Navigator.pop(context);
                }
              }
              setState(() {
                _foundUsers = _foundUsers;
              });
              Navigator.pop(context);
            } else {
              calltoast(ccmsnumber);
              Navigator.pop(context);
            }
          } else {
            calltoast(ccmsnumber);
            Navigator.pop(context);
          }
        } catch (e) {
          Navigator.pop(context);
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callccmsbasedILMDeviceListFinder(
                  user.ccmsnumber,
                  _relationdevices,
                  _foundUsers,
                  context);
            }
          } else {
            calltoast(ccmsnumber);
          }
        }
      }else{
        calltoast(no_network);
      }
    });
  }

  @override
  Future<Device?> fetchDeviceDetails(String deviceName,
      BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        Utility.progressDialog(context);
        try {
          Device response;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();
          response =
          await tbClient.getDeviceService().getTenantDevice(deviceName)
          as Device;
          if (response.name.isNotEmpty) {
            if (response.type == ilm_deviceType) {
              fetchSmartDeviceDetails(
                  deviceName, response.id!.id.toString(), context);
            } else if (response.type == ccms_deviceType) {} else
            if (response.type == Gw_deviceType) {} else {
              calltoast("Device Details Not Found");
              Navigator.pop(context);
            }
          } else {
            calltoast(deviceName);
            Navigator.pop(context);
          }
        } catch (e) {
          Navigator.pop(context);
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              fetchDeviceDetails(deviceName, context);
            }
          } else {
            calltoast(deviceName);
            Navigator.pop(context);
          }
        }
      } else {
        calltoast(no_network);
      }
    });
  }

  @override
  Future<Device?> fetchSmartDeviceDetails(String deviceName, String deviceid,
      BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        Utility.progressDialog(context);
        try {
          Device response;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          response = (await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName)) as Device;
          if(response != null) {
            var relationDetails = await tbClient
                .getEntityRelationService()
                .findInfoByTo(response.id!);

            if(relationDetails != null) {
              List<String> myList = [];
              myList.add("lampWatts");
              myList.add("active");
              List<BaseAttributeKvEntry> responser;

              responser =
              (await tbClient.getAttributeService().getAttributeKvEntries(
                  response.id!, myList)) as List<BaseAttributeKvEntry>;

              if(responser!=null) {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                prefs.setString(
                    'deviceStatus', responser.first.kv.getValue().toString());
                prefs.setString(
                    'deviceWatts', responser.last.kv.getValue().toString());
                prefs.setString(
                    'devicetimeStamp', responser.first.lastUpdateTs.toString());

                prefs.setString('deviceId', deviceid);
                prefs.setString('deviceName', deviceName);

                if (relationDetails.length.toString() == "0") {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          ilm_installation_screen()));
                } else {

                  List<String> myList = [];
                  myList.add("location");

                  List<BaseAttributeKvEntry> responser;

                  responser = (await tbClient.getAttributeService().getAttributeKvEntries(
                      response.id!, myList)) as List<BaseAttributeKvEntry>;

                  if(responser != null) {
                    SharedPreferences prefs = await SharedPreferences
                        .getInstance();
                    prefs.setString(
                        'location', responser.first.kv.getValue().toString());
                  }else{
                    SharedPreferences prefs = await SharedPreferences
                        .getInstance();
                    prefs.setString(
                        'location', "-");
                  }

                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => MaintenanceScreen()));
                }
              }else{
                calltoast(deviceName);
                Navigator.pop(context);
              }
            }else{
              calltoast(deviceName);
              Navigator.pop(context);
            }
          }else{
            calltoast(deviceName);
            Navigator.pop(context);
          }
        } catch (e) {
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              fetchDeviceDetails(deviceName, context);
            }
          } else {
            calltoast(deviceName);
            Navigator.pop(context);
          }
        }
      } else {
        calltoast(no_network);
      }
    });
  }

  void calltoast(String polenumber) {
    Fluttertoast.showToast(
        msg: device_toast_msg + polenumber + device_toast_notfound,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    if (error.message == "Session expired!") {
      Navigator.pop(context);
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => dashboard_screen()));
      }
    } else {
      if (error is DioError) {
        if (error.response != null && error.response!.data != null) {
          var data = error.response!.data;
          if (data is ThingsboardError) {
            tbError = data;
          } else if (data is Map<String, dynamic>) {
            tbError = ThingsboardError.fromJson(data);
          } else if (data is String) {
            try {
              tbError = ThingsboardError.fromJson(jsonDecode(data));
            } catch (_) {}
          }
        } else if (error.error != null) {
          if (error.error is ThingsboardError) {
            tbError = error.error;
          } else if (error.error is SocketException) {
            tbError = ThingsboardError(
                error: error,
                message: 'Unable to connect',
                errorCode: ThingsBoardErrorCode.general);
          } else {
            tbError = ThingsboardError(
                error: error,
                message: error.error.toString(),
                errorCode: ThingsBoardErrorCode.general);
          }
        }
        if (tbError == null &&
            error.response != null &&
            error.response!.statusCode != null) {
          var httpStatus = error.response!.statusCode!;
          var message = (httpStatus.toString() +
              ': ' +
              (error.response!.statusMessage != null
                  ? error.response!.statusMessage!
                  : 'Unknown'));
          tbError = ThingsboardError(
              error: error,
              message: message,
              errorCode: httpStatusToThingsboardErrorCode(httpStatus),
              status: httpStatus);
        }
      } else if (error is ThingsboardError) {
        tbError = error;
      }
    }
    tbError ??= ThingsboardError(
        error: error,
        message: error.toString(),
        errorCode: ThingsBoardErrorCode.general);

    var errorStackTrace;
    if (tbError.error is Error) {
      errorStackTrace = tbError.error.stackTrace;
    }

    tbError.stackTrace = stackTrace ??
        tbError.getStackTrace() ??
        errorStackTrace ??
        StackTrace.current;

    return tbError;
  }
}

Future<void> callLogoutoption(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      backgroundColor: Colors.white,
      title: Text("Luminator",style: const TextStyle(
          fontSize: 25.0,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
          color: liorange)),
      content: Text("Are you sure you want to Logout?",style: const TextStyle(
          fontSize: 18.0,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
          color: Colors.black)),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Text("NO",style: const TextStyle(
              fontSize: 18.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: Colors.green)),
        ),
        TextButton(
          child: Text('YES',style: const TextStyle(
              fontSize: 18.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: Colors.red)),
          onPressed: () async {
            SharedPreferences preferences = await SharedPreferences.getInstance();
            await preferences.clear();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => splash_screen()));
          },
        ),
      ],
    ),
  );
}
