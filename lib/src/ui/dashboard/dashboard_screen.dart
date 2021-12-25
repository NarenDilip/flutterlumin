import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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

  final List<Widget> _widgetOptions = <Widget>[
    Home(),
    device_count_screen(),
    device_count_screen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.qr_code,
              color: Colors.grey,
            ),
            title: Text('QR Scan'),
            activeIcon: Icon(
              Icons.qr_code,
              color: Colors.purple,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
              color: Colors.grey,
            ),
            title: Text('Search List'),
            activeIcon: Icon(
              Icons.list,
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
              Icons.analytics,
              color: Colors.grey,
              size: 36,
            ),
            title: Text('Dashboard'),
            activeIcon: Icon(
              Icons.analytics,
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
      // body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
