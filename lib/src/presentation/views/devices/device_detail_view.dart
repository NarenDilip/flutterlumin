import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/data/model/device.dart';
import 'package:flutterlumin/src/presentation/blocs/device_detail_cubit.dart';
import 'package:flutterlumin/src/presentation/blocs/device_info_state.dart';
import 'package:latlong/latlong.dart';

class DeviceDetailView extends StatefulWidget {
  const DeviceDetailView({
    Key? key,
    required this.productDevice,
  }) : super(key: key);
  final ProductDevice productDevice;

  @override
  State<DeviceDetailView> createState() => _DeviceDetailViewState();
}

class _DeviceDetailViewState extends State<DeviceDetailView> {
  bool deviceStatus = false;
  bool mcbTripStatus = false;

  @override
  void initState() {
    final productDeviceCubit = BlocProvider.of<DeviceDetailCubit>(context);
    productDeviceCubit.getDeviceDetail(widget.productDevice.name, context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: Text(
          widget.productDevice.name,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Roboto',
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black54, // add custom icons also
          ),
        ),
      ),
      body: BlocBuilder<DeviceDetailCubit, DeviceInfoState>(
        builder: (context, state) {
          if (state is LoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ErrorState) {
            return const Center(
              child: Icon(Icons.close),
            );
          } else if (state is LoadedState) {
            return Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 160,
                        child: FlutterMap(
                          options: MapOptions(
                            center: LatLng(
                                state.deviceResponse.latitude != ""
                                    ? double.parse(
                                        state.deviceResponse.latitude)
                                    : 0.0,
                                state.deviceResponse.longitude != ""
                                    ? double.parse(
                                        state.deviceResponse.longitude)
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
                                      state.deviceResponse.latitude != ""
                                          ? double.parse(
                                              state.deviceResponse.latitude)
                                          : 0.0,
                                      state.deviceResponse.longitude != ""
                                          ? double.parse(
                                              state.deviceResponse.longitude)
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
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: lightGrey, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 14, top: 20, bottom: 20, right: 14),
                          child: Column(
                            children: <Widget>[
                              const Text(
                                "Address",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Roboto',
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                state.deviceResponse.location != ""
                                    ? state.deviceResponse.location
                                    : "-",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Divider(color: Colors.black26),
                              const SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        "Device watts",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Roboto',
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        state.deviceResponse.watts != ""
                                            ? state.deviceResponse.watts
                                            : "-",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        "Last communication",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Roboto',
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        state.deviceResponse.deviceTimeStamp !=
                                                ""
                                            ? state
                                                .deviceResponse.deviceTimeStamp
                                            : "-",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: lightGrey, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 24, top: 24, bottom: 24, right: 24),
                                child: Column(
                                  children: <Widget>[
                                    IntrinsicHeight(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              FlutterSwitch(
                                                width: 100.0,
                                                height: 55.0,
                                                toggleSize: 45.0,
                                                value: deviceStatus,
                                                borderRadius: 30.0,
                                                padding: 2.0,
                                                inactiveToggleColor:
                                                    Color(0xFF6E40C9),
                                                activeToggleColor:
                                                    Color(0xFF2F363D),
                                                inactiveSwitchBorder:
                                                    Border.all(
                                                  color: Color(0xFF3C1E70),
                                                  width: 6.0,
                                                ),
                                                activeSwitchBorder: Border.all(
                                                  color: Color(0xFFD1D5DA),
                                                  width: 6.0,
                                                ),
                                                inactiveColor:
                                                    Color(0xFF271052),
                                                activeColor: Colors.white,
                                                inactiveIcon: const Icon(
                                                  Icons.nightlight_round,
                                                  color: Color(0xFFF8E3A1),
                                                ),
                                                activeIcon: const Icon(
                                                  Icons.wb_sunny,
                                                  color: Color(0xFFFFDF5D),
                                                ),
                                                onToggle: (val) {
                                                  setState(() {
                                                    deviceStatus = val;
                                                  });
                                                },
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                deviceStatus == false
                                                    ? "OFF"
                                                    : "ON",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontFamily: 'Roboto',
                                                  color: deviceStatus == false
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          const VerticalDivider(
                                            color: Colors.black26,
                                            thickness: 1,
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "GET LIVE",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.blueAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          const VerticalDivider(
                                            color: Colors.black26,
                                            thickness: 1,
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "MCB",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.blueAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              RotatedBox(
                                                quarterTurns: 3,
                                                child: FlutterSwitch(
                                                  width: 100.0,
                                                  height: 55.0,
                                                  toggleSize: 45.0,
                                                  value: mcbTripStatus,
                                                  borderRadius: 30.0,
                                                  padding: 2.0,
                                                  inactiveToggleColor:
                                                      Color(0xFF6E40C9),
                                                  activeToggleColor:
                                                      Color(0xFF2F363D),
                                                  inactiveSwitchBorder:
                                                      Border.all(
                                                    color: Color(0xFF3C1E70),
                                                    width: 6.0,
                                                  ),
                                                  activeSwitchBorder:
                                                      Border.all(
                                                    color: Color(0xFFD1D5DA),
                                                    width: 6.0,
                                                  ),
                                                  inactiveColor:
                                                      Color(0xFF271052),
                                                  activeColor: Colors.white,
                                                  inactiveIcon: const Icon(
                                                    Icons.nightlight_round,
                                                    color: Color(0xFFF8E3A1),
                                                  ),
                                                  activeIcon: const Icon(
                                                    Icons.wb_sunny,
                                                    color: Color(0xFFFFDF5D),
                                                  ),
                                                  onToggle: (val) {
                                                    setState(() {
                                                      deviceStatus = val;
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    const Divider(color: Colors.black26),
                                    IntrinsicHeight(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                deviceStatus == false
                                                    ? "OFF"
                                                    : "ON",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontFamily: 'Roboto',
                                                  color: deviceStatus == false
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          const VerticalDivider(
                                            color: Colors.black26,
                                            thickness: 1,
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                deviceStatus == false
                                                    ? "OFF"
                                                    : "ON",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontFamily: 'Roboto',
                                                  color: deviceStatus == false
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
