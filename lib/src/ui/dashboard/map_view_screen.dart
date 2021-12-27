import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/ui/components/dropdown_button_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class map_view_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return map_view_screen_state();
  }
}

class map_view_screen_state extends State<map_view_screen> {
  List<String> spinnerList = [
    'One',
    'Two',
    'Three',
  ];

  var dropDownValue = "";
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.00
  );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Scaffold(
            appBar: AppBar(
              title: Text("Luminator",  style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Montserrat",
              )),
            ),
            body: Container(
                height: size.height,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/icons/background_img.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                    child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                              child: DropdownButtonField(
                                  dropdownValue: dropDownValue,
                                  onChanged: (value) {
                                    setState(() {
                                      dropDownValue = value;
                                    });
                                  },
                                  spinnerItems: spinnerList)),
                          SizedBox(
                            width: 4,
                          ),
                          Expanded(
                              child: DropdownButtonField(
                                  dropdownValue: dropDownValue,
                                  onChanged: (value) {
                                    setState(() {
                                      dropDownValue = value;
                                    });
                                  },
                                  spinnerItems: spinnerList)),
                          SizedBox(
                            width: 4,
                          ),
                          Expanded(
                              child: DropdownButtonField(
                                  dropdownValue: dropDownValue,
                                  onChanged: (value) {
                                    setState(() {
                                      dropDownValue = value;
                                    });
                                  },
                                  spinnerItems: spinnerList)),
                        ],
                      ),
                    ),
                    // Expanded(
                    //     child: GoogleMap(
                    //   mapType: MapType.hybrid,
                    //   initialCameraPosition: _kGooglePlex,
                    //   onMapCreated: (GoogleMapController controller) {
                    //     _controller.complete(controller);
                    //   },
                    // )
                    // ),
                  ],
                )))));
  }

}
