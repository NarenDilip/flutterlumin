import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutterlumin/src/ui/dashboard/device_list_screen.dart';
import 'package:flutterlumin/src/ui/dashboard/map_view_screen.dart';
import 'package:flutterlumin/src/ui/device_count_screen.dart';
import 'package:flutterlumin/src/ui/login/login_screen.dart';

import '../home_screen.dart';

class dashboard_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return dashboard_screenState();
  }
}

class dashboard_screenState extends State<dashboard_screen> {
  int _selectedIndex = 0;
  bool clickedCentreFAB = false;

  final List<Widget> _widgetOptions = <Widget>[
    device_count_screen(),
    map_view_screen(),
    device_list_screen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _widgetOptions.elementAt(_selectedIndex),
          // Align(
          //   alignment: FractionalOffset.center,
          //   //in this demo, only the button text is updated based on the bottom app bar clicks
          //   child: RaisedButton(
          //     // child: Text(""),
          //     onPressed: () {},
          //   ),
          // ),
          //this is the code for the widget container that comes from behind the floating action button (FAB)
          Align(
            alignment: FractionalOffset.bottomRight,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              //if clickedCentreFAB == true, the first parameter is used. If it's false, the second.
              height:
              clickedCentreFAB ? MediaQuery.of(context).size.height : 10.0,
              width: clickedCentreFAB ? MediaQuery.of(context).size.height : 10.0,
              decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(clickedCentreFAB ? 0.0 : 300.0),
                  color: Colors.white),
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked, //specify the location of the FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            clickedCentreFAB = !clickedCentreFAB; //to update the animated container
          });
        },
        tooltip: "Centre FAB",
        child: Container(
          margin: EdgeInsets.all(15.0),
          child: Icon(Icons.qr_code),
        ),
        elevation: 3.0,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.qr_code,
          //     color: Colors.grey,
          //   ),
          //   title: Text('QR Scan'),
          //   activeIcon: Icon(
          //     Icons.qr_code,
          //     color: Colors.purple,
          //   ),
          // ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.analytics,
              color: Colors.grey,
            ),
            title: Text('Dashboard'),
            activeIcon: Icon(
              Icons.analytics,
              color: Colors.purple,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
              color: Colors.grey,
              size: 36,
            ),
            title: Text('Map View'),
            activeIcon: Icon(
              Icons.map,
              color: Colors.purple,
              size: 36,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
              color: Colors.grey,
              size: 36,
            ),
            title: Text('Device List'),
            activeIcon: Icon(
              Icons.list,
              color: Colors.purple,
              size: 36,
            ),
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

    );
  }
}
