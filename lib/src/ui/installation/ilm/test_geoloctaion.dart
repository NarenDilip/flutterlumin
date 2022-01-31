import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ilm_installation_screen1 extends StatefulWidget {
  @override
  ilm_installation_screenState createState() => ilm_installation_screenState();
}

class ilm_installation_screenState extends State<ilm_installation_screen1> {
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
  LocationData? currentLocation;
  String address = "";

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

      // date = DateTime.fromMillisecondsSinceEpoch(int.parse(timevalue));

      if (SelectedRegion == "null") {
        SelectedRegion = "Region";
        SelectedZone = "Zone";
        SelectedWard = "Ward";
      }
    });
  }

  void getLocation() {
    setState(() {
      _getLocation().then((value) {
        LocationData? location = value;
        _getAddress(location?.latitude, location?.longitude).then((value) {
          setState(() {
            currentLocation = location;
            address = value;
          });
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Lampwatts = "";
    DeviceName = "";
    DeviceStatus = "";
    getSharedPrefs();
    getLocation();
  }

  void toggle() {
    setState(() => _isOn = !_isOn);
  }

  BuildContext get context => super.context;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          SystemNavigator.pop();
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Stack(
          children: [
            Container(
              color: lightorange,
              child: Column(
                children: [
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
                          top: 15,
                          bottom: 0,
                          child: IconButton(
                            color: Colors.red,
                            icon: Icon(
                              Icons.logout_outlined,
                              size: 35,
                            ),
                            onPressed: () {},
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
                                                MaterialStateProperty.all<
                                                    Color>(Colors.black),
                                                shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(18.0),
                                                    ))),
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                      context) =>
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
                                      ]),
                                )),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(15, 15, 5, 0),
                              decoration: const BoxDecoration(
                                  color: lightorange,
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(35.0))),
                              child: Column(
                                children: [
                                  Row(
                                    children: <Widget>[
                                    ], //<Widget>[]
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (currentLocation != null)
                              Text(
                                  "Location: ${currentLocation?.latitude}, ${currentLocation?.longitude}"),
                            const SizedBox(
                              height: 10,
                            ),
                            if (currentLocation != null)
                              Text("Accuracy: ${currentLocation?.accuracy}"),
                            const SizedBox(
                              height: 10,
                            ),
                            if (currentLocation != null)
                              Text(
                                "Address: $address",
                                textAlign: TextAlign.center,
                              ),
                          ]),
                        )),
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
    Location location = new Location();
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
    // GeoCode geoCode = GeoCode();
    // Address address =
    // await geoCode.reverseGeocoding(latitude: lat, longitude: lang);
    // return "${address.streetAddress}, ${address.city}, ${address.countryName}, ${address.postal}";
    return "";
  }
}
