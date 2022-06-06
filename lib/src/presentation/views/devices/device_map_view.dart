import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutterlumin/src/data/model/device.dart';
import 'package:latlong/latlong.dart';

class DeviceMapView extends StatelessWidget {
  final ProductDevice deviceResponse;
  const DeviceMapView(this.deviceResponse, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(
              deviceResponse.latitude != ""
                  ? double.parse(
                  deviceResponse.latitude)
                  : 0.0,
              deviceResponse.longitude != ""
                  ? double.parse(
                  deviceResponse.longitude)
                  : 0.0),
          zoom: 17.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate:
            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(
                    deviceResponse.latitude != ""
                        ? double.parse(
                        deviceResponse.latitude)
                        : 0.0,
                    deviceResponse.longitude != ""
                        ? double.parse(
                        deviceResponse.longitude)
                        : 0.0),
                builder: (_) => const Icon(
                  Icons.location_pin,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}