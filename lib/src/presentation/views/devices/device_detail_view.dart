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
  bool mcbTripStatus = true;

  @override
  void initState() {
    final productDeviceCubit = BlocProvider.of<DeviceDetailCubit>(context);
    productDeviceCubit.getDeviceDetail(widget.productDevice.name, context);
    super.initState();
  }

  void updateDeviceStatus(bool deviceStatus) {
    final productDeviceCubit = BlocProvider.of<DeviceDetailCubit>(context);
    productDeviceCubit.updateDeviceStatus(context, deviceStatus);
  }

  void getLive() {
    final productDeviceCubit = BlocProvider.of<DeviceDetailCubit>(context);
    productDeviceCubit.requestLiveData(context);
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
                SingleChildScrollView(
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
                      Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: lightGrey, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 40, top: 14, bottom: 14, right: 40),
                          child: Column(
                            children: <Widget>[
                              IntrinsicHeight(
                                child: Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                            inactiveSwitchBorder: Border.all(
                                              color: Color(0xFF3C1E70),
                                              width: 6.0,
                                            ),
                                            activeSwitchBorder: Border.all(
                                              color: Color(0xFFD1D5DA),
                                              width: 6.0,
                                            ),
                                            inactiveColor: Color(0xFF271052),
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
                                              updateDeviceStatus(deviceStatus);
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
                                      Column(
                                        children: const [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          VerticalDivider(
                                            color: Colors.black26,
                                            thickness: .2,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                          visible: widget.productDevice.type ==
                                                  ccmsDeviceType
                                              ? true
                                              : false,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              FlutterSwitch(
                                                width: 60.0,
                                                height: 55.0,
                                                toggleSize: 45.0,
                                                value: mcbTripStatus,
                                                borderRadius: 30.0,
                                                padding: 2.0,
                                                inactiveToggleColor:
                                                    Colors.white,
                                                activeToggleColor:
                                                    Color(0xFF2F363D),
                                                inactiveSwitchBorder:
                                                    Border.all(
                                                  color: Colors.grey,
                                                  width: 6.0,
                                                ),
                                                activeSwitchBorder: Border.all(
                                                  color: Color(0xFFD1D5DA),
                                                  width: 6.0,
                                                ),
                                                inactiveColor: Colors.grey,
                                                activeColor: Colors.white,
                                                inactiveIcon: const Icon(
                                                  Icons.get_app_outlined,
                                                  color: Colors.black,
                                                ),
                                                activeIcon: const Icon(
                                                  Icons.publish_outlined,
                                                  color: Colors.red,
                                                ),
                                                onToggle: (val) {
                                                  setState(() {
                                                    mcbTripStatus = val;
                                                  });
                                                },
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "MCB",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontFamily: 'Roboto',
                                                  color: Colors.blueAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )),
                                      Column(
                                        children: const [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          VerticalDivider(
                                            color: Colors.black26,
                                            thickness: .2,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          getLive();
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            RawMaterialButton(
                                              onPressed: () {},
                                              elevation: 2.0,
                                              fillColor: Colors.lightBlue,
                                              child: const Icon(
                                                Icons.sync,
                                                color: Colors.white,
                                                size: 24.0,
                                              ),
                                              padding: EdgeInsets.all(15.0),
                                              shape: CircleBorder(),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              "LIVE",
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontFamily: 'Roboto',
                                                color: Colors.blueAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              /*const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "DEVICE REPLACEMENT",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Roboto',
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ActionButton(
                                          labelName: "SHOOTING CAP",
                                          itemPressed: () {},
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ActionButton(
                                          labelName: "ILM",
                                          itemPressed: () {},
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),*/
                            ],
                          ),
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
                              left: 20, top: 14, bottom: 14, right: 20),
                          child: Column(
                            children: <Widget>[
                              const Text(
                                "REPLACEMENT",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Roboto',
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              IntrinsicHeight(
                                child: Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            "SHORTING CAP",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          RawMaterialButton(
                                            onPressed: () {},
                                            elevation: 2.0,
                                            fillColor: Colors.deepOrange,
                                            child: const Icon(
                                              Icons.sync_lock_outlined,
                                              color: Colors.white,
                                              size: 24.0,
                                            ),
                                            padding: EdgeInsets.all(15.0),
                                            shape: CircleBorder(),
                                          ),
                                        ],
                                      ),
                                      const VerticalDivider(
                                        color: Colors.black26,
                                        thickness: .2,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            "ILM",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          RawMaterialButton(
                                            onPressed: () {},
                                            elevation: 2.0,
                                            fillColor: Colors.deepOrange,
                                            child: const Icon(
                                              Icons.cloud_sync_outlined,
                                              color: Colors.white,
                                              size: 24.0,
                                            ),
                                            padding: EdgeInsets.all(15.0),
                                            shape: CircleBorder(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              /*const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "DEVICE REPLACEMENT",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Roboto',
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ActionButton(
                                          labelName: "SHOOTING CAP",
                                          itemPressed: () {},
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ActionButton(
                                          labelName: "ILM",
                                          itemPressed: () {},
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),*/
                            ],
                          ),
                        ),
                      ),
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
