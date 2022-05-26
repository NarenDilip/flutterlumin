import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/app_bar_view.dart';

import '../../../ui/map/location_map.dart';
import '../dashboard/dashboard_app_bar_view.dart';

class DeviceLocationView extends StatefulWidget {
  const DeviceLocationView({Key? key}) : super(key: key);

  @override
  _DeviceLocationState createState() => _DeviceLocationState();
}

class _DeviceLocationState extends State<DeviceLocationView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: Column(children: <Widget>[
          const DashboardAppBarWidget(title: "",),
          Expanded(
              child: Container(
                  color: Colors.grey,
                  child: Stack(
                    children: [
                      LocationWidget(
                        initialLabel: 0,
                        onToggle: (index) {
                          // print('switched to: $index');
                        },
                      ),
                    ],
                  )))
        ],
      )
    );
  }
}
