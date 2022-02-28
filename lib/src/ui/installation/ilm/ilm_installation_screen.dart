import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:flutterlumin/src/ui/point/point.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localdb/db_helper.dart';
import '../../../localdb/model/region_model.dart';
import '../../../thingsboard/model/model.dart';
import '../../../thingsboard/thingsboard_client_base.dart';
import '../../../utils/utility.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../splash_screen.dart';
import 'ilm_install_cam_screen.dart';

class ilm_installation_screen extends StatefulWidget {
  @override
  ilm_installation_screenState createState() => ilm_installation_screenState();
}

class ilm_installation_screenState extends State<ilm_installation_screen> {
  var selectedImage = "";
  bool _isOn = true;
  DateTime? date;
  int _selectedIndex = 0;
  bool clickedCentreFAB = false;
  var LampactiveStatus;
  String Lampwatts = "0";
  String DeviceName = "0";
  String DeviceStatus = "0";
  String SelectedRegion = "0";
  String SelectedZone = "0";
  String SelectedWard = "0";
  String timevalue = "0";
  String location = "0";
  String version = "0";
  late ProgressDialog pr;
  bool _obscureText = true;

  // LocationData? currentLocation;
  String address = "";

  // Address? address;
  double? latttitude;
  double? longtitude;
  double? accuracy;
  final Location locations = Location();
  LocationData? _location;
  StreamSubscription<LocationData>? _locationSubscription;
  String? _error;

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Lampwatts = prefs.getString('deviceWatts').toString();
    DeviceName = prefs.getString('deviceName').toString();
    DeviceStatus = prefs.getString('deviceStatus').toString();
    SelectedRegion = prefs.getString("SelectedRegion").toString();
    SelectedZone = prefs.getString("SelectedZone").toString();
    SelectedWard = prefs.getString("SelectedWard").toString();
    timevalue = prefs.getString("devicetimeStamp").toString();
    location = prefs.getString("location").toString();
    version = prefs.getString("version").toString();

    prefs.setString('Maintenance', "Yes");

    setState(() {
      Lampwatts = Lampwatts;
      DeviceName = DeviceName;
      DeviceStatus = DeviceStatus;
      SelectedRegion = SelectedRegion;
      SelectedZone = SelectedZone;
      SelectedWard = SelectedWard;
      timevalue = timevalue;
      location = location;
      version = version;
      latttitude = latttitude;
      longtitude = longtitude;
      accuracy = accuracy;

      // date = DateTime.fromMillisecondsSinceEpoch(int.parse(timevalue));

      if (SelectedRegion == "null") {
        SelectedRegion = "Region";
        SelectedZone = "Zone";
        SelectedWard = "Ward";
      }

      if (SelectedZone == "0" || SelectedZone == "null") {
        SelectedZone = "Zone";
      }

      if (SelectedWard == "0" || SelectedWard == "null") {
        SelectedWard = "Ward";
      }

    });
  }

  Future<void> _listenLocation() async {
    _locationSubscription =
        locations.onLocationChanged.handleError((dynamic err) {
      if (err is PlatformException) {
        setState(() {
          _error = err.code;
        });
      }
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((LocationData currentLocation) {
      setState(() {
        _error = null;
        _location = currentLocation;
        _getAddress(_location!.latitude, _location!.longitude).then((value) {
          setState(() {
            address = value;
          });
        });
      });
    });
  }

  // void getLocation() {
  //   setState(() {
  //     _getLocation().then((value) {
  //       LocationData? location = value;
  //       _getAddress(location?.latitude, location?.longitude).then((value) {
  //         setState(() {
  //           currentLocation = location;
  //           address = value;
  //         });
  //       });
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    Lampwatts = "";
    DeviceName = "";
    DeviceStatus = "";
    getSharedPrefs();
    _listenLocation();
    // getLocation();
  }

  void toggle() {
    setState(() => _isOn = !_isOn);
  }

  BuildContext get context => super.context;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;

    pr = ProgressDialog(
        context, type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
      message: 'Please wait ..',
      borderRadius: 20.0,
      backgroundColor: Colors.lightBlueAccent,
      elevation: 10.0,
      messageTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: "Montserrat",
          fontSize: 19.0,
          fontWeight: FontWeight.w600),
      progressWidget: const CircularProgressIndicator(
          backgroundColor: Colors.lightBlueAccent,
          valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
          strokeWidth: 3.0),
    );


    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => dashboard_screen()));
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Stack(
          children: [
            Container(
              color: thbDblue,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                        color: thbDblue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                            bottomLeft: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0))),
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: Text('ILM Installation',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 25.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Positioned(
                          right: 10,
                          top: 20,
                          bottom: 0,
                          child: IconButton(
                            color: Colors.red,
                            icon: Icon(
                              Icons.logout_outlined,
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
                    child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                        children: <Widget>[
                          Container(
                              width: double.infinity,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(35.0),
                                topRight: Radius.circular(35.0),
                                bottomLeft: Radius.circular(0.0),
                                bottomRight: Radius.circular(0.0))),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: <
                                  Widget>[
                            Container(
                                child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding:
                                        EdgeInsets.only(left: 5.0),
                                        child: Point(
                                          triangleHeight: 25.0,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                      context) =>
                                                          ward_li_screen()));
                                              setState(() {});
                                            },
                                            child: Container(
                                              color: thbDblue,
                                              width: 120.0,
                                              height: 50.0,
                                              child: Center(
                                                child: Text(
                                                    '$SelectedRegion',
                                                    style: const TextStyle(
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                        "Montserrat",
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        color: Colors
                                                            .white)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding:
                                        EdgeInsets.only(left: 5.0),
                                        child: Point(
                                          triangleHeight: 25.0,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                      context) =>
                                                          zone_li_screen()));
                                              setState(() {});
                                            },
                                            child: Container(
                                              color: thbDblue,
                                              width: 120.0,
                                              height: 50.0,
                                              child: Center(
                                                child: Text(
                                                    '$SelectedZone',
                                                    style: const TextStyle(
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                        "Montserrat",
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        color: Colors
                                                            .white)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding:
                                        EdgeInsets.only(left: 5.0),
                                        child: Point(
                                          triangleHeight: 25.0,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                      context) =>
                                                          ward_li_screen()));
                                              setState(() {});
                                            },
                                            child: Container(
                                              color: thbDblue,
                                              width: 120.0,
                                              height: 50.0,
                                              child: Center(
                                                child: Text(
                                                    '$SelectedWard',
                                                    style: const TextStyle(
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                        "Montserrat",
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        color: Colors
                                                            .white)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            )),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35.0))),
                              child: Column(
                                children: [
                                  Row(children: [
                                    Flexible(
                                        child: TextFormField(
                                      autofocus: false,
                                      readOnly: true,
                                      keyboardType: TextInputType.text,
                                      style: const TextStyle(
                                          fontSize: 25.0,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          color: thbDblue),
                                      decoration: InputDecoration(
                                        filled: true,
                                        hintText: '$DeviceName',
                                        hintStyle: TextStyle(
                                            fontSize: 25.0,
                                            fontFamily: "Montserrat",
                                            color: thbDblue),
                                        fillColor: Colors.white,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        enabledBorder: const OutlineInputBorder(
                                          // width: 0.0 produces a thin "hairline" border
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20.0)),
                                          borderSide:
                                              BorderSide(color: thbDblue),
                                          //borderSide: const BorderSide(),
                                        ),
                                        // suffixIcon: GestureDetector(
                                        //   onTap: () {
                                        //     Navigator.pushAndRemoveUntil(
                                        //             context,
                                        //             MaterialPageRoute(
                                        //                 builder: (BuildContext
                                        //                         context) =>
                                        //                     QRScreen()),
                                        //             (route) => true)
                                        //         .then((value) async {
                                        //       if (value != null) {
                                        //         SharedPreferences prefs =
                                        //             await SharedPreferences
                                        //                 .getInstance();
                                        //         prefs.setString(
                                        //             'deviceName', value);
                                        //         setState(() {
                                        //           DeviceName = value;
                                        //         });
                                        //       }
                                        //     });
                                        //   },
                                        //   child: Icon(
                                        //     _obscureText
                                        //         ? Icons.qr_code_scanner_sharp
                                        //         : Icons.qr_code_scanner_sharp,
                                        //   ),
                                        // ),
                                      ),
                                    ))
                                  ]),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // Text(
                            //   'Listen location: ' + (_error ?? '${locations ?? "unknown"}'),
                            //   style: Theme.of(context).textTheme.bodyText1,
                            // ),
                            Text('Lattitude and Longitude',
                                style: const TextStyle(
                                    fontSize: 22.0,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold,
                                    color: thbDblue)),
                            const SizedBox(
                              height: 5,
                            ),
                            if (_location != null)
                              Container(
                                  width: double.infinity,
                                  child: TextButton(
                                      child: Text(
                                          _location!.latitude.toString() +
                                              " // " +
                                              _location!.longitude.toString(),
                                          style: const TextStyle(
                                              fontSize: 24.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(EdgeInsets.all(20)),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  thbDblue),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                          ))),
                                      onPressed: () {})),
                            const SizedBox(
                              height: 20,
                            ),
                            Text('Accuracy',
                                style: const TextStyle(
                                    fontSize: 22.0,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold,
                                    color: thbDblue)),
                            const SizedBox(
                              height: 5,
                            ),
                            if (_location != null)
                              Container(
                                  width: double.infinity,
                                  child: TextButton(
                                      child: Text(
                                          _location!.accuracy.toString(),
                                          style: const TextStyle(
                                              fontSize: 24.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(EdgeInsets.all(20)),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  thbDblue),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                          ))),
                                      onPressed: () {})),
                            const SizedBox(
                              height: 20,
                            ),
                            Text('Landmark Details',
                                style: const TextStyle(
                                    fontSize: 22.0,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold,
                                    color: thbDblue)),
                            const SizedBox(
                              height: 10,
                            ),
                            if (address != null)
                              Container(
                                  width: double.infinity,
                                  child: TextButton(
                                      child: Text(address,
                                          style: const TextStyle(
                                              fontSize: 22.0,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all<
                                              EdgeInsets>(EdgeInsets.all(20)),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  thbDblue),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                          ))),
                                      onPressed: () {})),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                                width: double.infinity,
                                child: TextButton(
                                    child: Text('Start Install ILM',
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
                                                Colors.green),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                        ))),
                                    onPressed: () {
                                      ilmInstallationStart(context);
                                    })),
                                const SizedBox(
                                  height: 15,
                                ),
                          ]),
                        )),
                        ])
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<LocationData?> _getLocation() async {
    Location location = Location();
    LocationData _locationData;
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();

    return _locationData;
  }

  Future<String> _getAddress(double? lat, double? lang) async {
    if (lat == null || lang == null) return "";
    final coordinates = new Coordinates(lat, lang);
    List<Address> addresss = (await Geocoder.local
        .findAddressesFromCoordinates(coordinates)) as List<Address>;
    return "${addresss.elementAt(1).addressLine}";
  }

  // Future<String> _getAddress(double? lat, double? lang) async {
  //   if (lat == null || lang == null) return "";
  //   Geolocator geolocator = Geolocator();
  //   List<Placemark> placemarks =
  //       await geolocator.placemarkFromCoordinates(lat, lang);
  //   Placemark place = placemarks[0];
  //   setState(() {
  //     "${place.locality}, ${place.postalCode}, ${place.country}";
  //   });

  // GeoCode geoCode = GeoCode();
  // Address address =
  //     await geoCode.reverseGeocoding(latitude: lat, longitude: lang);
  // return "${place.name}, ${place.locality}, ${place.country}";
  // }
// }

  void ilmInstallationStart(context) {
    Utility.isConnected().then((value) async {
      if (value) {
        // Utility.progressDialog(context);
        pr.show();
        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('lattitude', _location!.latitude.toString());
          prefs.setString('longitude', _location!.longitude.toString());
          prefs.setString('accuracy', _location!.accuracy.toString());
          prefs.setString('address', address);
          if (SelectedWard != "Ward") {
            if (_location!.latitude != null) {
              var tbClient = ThingsboardClient(serverUrl);
              tbClient.smart_init();

              DeviceName = prefs.getString('deviceName').toString();

              Device response;
              response = (await tbClient
                  .getDeviceService()
                  .getTenantDevice(DeviceName)) as Device;

              if (response != null) {
                List<String> myList = [];
                myList.add("faulty");
                List<AttributeKvEntry> responser;

                responser = (await tbClient
                        .getAttributeService()
                        .getAttributeKvEntries(response.id!, myList))
                    as List<AttributeKvEntry>;

                var faultyDetails = false;
                if (responser.length == 0) {
                  faultyDetails = false;
                } else {
                  faultyDetails = responser.first.getValue();
                }

                if (faultyDetails == false) {
                  pr.hide();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => ilmcaminstall()));
                } else {
                  // Navigator.pop(context);
                  pr.hide();
                  Fluttertoast.showToast(
                      msg: "Device Currently in Faulty State Unable to Install.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 16.0);
                }
              } else {}
            } else {
              // Navigator.pop(context);
              pr.hide();
              Fluttertoast.showToast(
                  msg:
                      "Please wait to load lattitude, longitude Details to Install.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
            }
          } else {
            // Navigator.pop(context);
            pr.hide();
            Fluttertoast.showToast(
                msg:
                    "Kindly Select the Region, Zone and Ward Details to Install.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        } catch (e) {
          pr.hide();
          // Navigator.pop(context);
        }
      } else {}
    });
  }

  Future<void> callLogoutoption(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: Colors.white,
        title: Text("Luminator",
            style: const TextStyle(
                fontSize: 25.0,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.bold,
                color: liorange)),
        content: Text("Are you sure you want to Logout?",
            style: const TextStyle(
                fontSize: 18.0,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("NO",
                style: const TextStyle(
                    fontSize: 18.0,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
          ),
          TextButton(
            child: Text('YES',
                style: const TextStyle(
                    fontSize: 18.0,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            onPressed: () async {
              // DBHelper dbhelper = new DBHelper();
              // dbhelper.region_delete();
              // dbhelper.zone_delete();
              // dbhelper.ward_delete();

              DBHelper dbhelper = new DBHelper();
              SharedPreferences prefs = await SharedPreferences.getInstance();

              var SelectedRegion = prefs.getString("SelectedRegion").toString();
              List<Region> details = await dbhelper.region_getDetails();

              for(int i=0;i<details.length;i++){
                dbhelper.delete(details.elementAt(i).id!.toInt());
              }
              dbhelper.zone_delete(SelectedRegion);
              dbhelper.ward_delete(SelectedRegion);

              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              await preferences.clear();
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => splash_screen()));
            },
          ),
        ],
      ),
    );
  }
}
