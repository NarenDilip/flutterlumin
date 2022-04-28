import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/views/devices/device_detail.dart';

class DeviceListView extends StatelessWidget {
  const DeviceListView({
    Key? key,
    required this.devices,
  }) : super(key: key);
  final List<String> devices;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Card(
      color: Colors.white,
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
                    devices[index],
                    style: const TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(devices[index]),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            DeviceDetailView(productDeviceName: devices[index],)));
                  },
                ),
              ],
            );
          },
          itemCount: devices.length,
        ),
      ),
    ));
  }
}
