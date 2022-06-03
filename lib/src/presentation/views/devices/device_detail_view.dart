import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/data/model/device.dart';
import 'package:flutterlumin/src/presentation/blocs/device_detail_cubit.dart';
import 'package:flutterlumin/src/presentation/blocs/device_info_state.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong/latlong.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../thingsboard/error/thingsboard_error.dart';
import '../../../thingsboard/thingsboard_client_base.dart';
import '../../../ui/maintenance/ccms/remove_ccms_screen.dart';
import '../../../ui/maintenance/ccms/replace_ccms_screen.dart';
import '../../../ui/maintenance/gateway/remove_gw_screen.dart';
import '../../../ui/maintenance/gateway/replace_gw_screen.dart';
import '../../../ui/maintenance/ilm/remove_ilm_screen.dart';
import '../../../ui/maintenance/ilm/replace_ilm_screen.dart';
import '../../../ui/qr_scanner/qr_scanner.dart';
import '../../../utils/utility.dart';
import '../dashboard/dashboard_view.dart';

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
    productDeviceCubit.getDeviceDetail(widget.productDevice, context);
    super.initState();
  }

  /* void updateDeviceStatus(bool deviceStatus, ProductDevice productDevice) {
    final productDeviceCubit = BlocProvider.of<DeviceDetailCubit>(context);
    productDeviceCubit.updateDeviceStatus(context, deviceStatus, productDevice);
  }*/

  void getLive() {
    final productDeviceCubit = BlocProvider.of<DeviceDetailCubit>(context);
    productDeviceCubit.requestLiveData(context);
  }

  void showWarningPopup(ProductDevice productDevice, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(productDevice.name),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      resizeToAvoidBottomInset: false,
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
          }
          if (state is LoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ErrorState) {
            return const Center(
             child: Text("Unable to fetch the data",  style: TextStyle(
                fontSize: 24,
                fontFamily: 'Roboto',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),),
            );
          } else if (state is LoadedState) {
            return Column(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
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
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                softWrap: true,
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
                      Visibility(
                          visible: widget.productDevice.type == ilmDeviceType ||
                              widget.productDevice.type == ccmsDeviceType,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side:
                                  const BorderSide(color: lightGrey, width: 2),
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
                                                value: state.deviceResponse.deviceStatus,
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
                                                  updateDeviceStatus(
                                                      context,
                                                      !state.deviceResponse.deviceStatus,
                                                      state.deviceResponse);
                                                },
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                state.deviceResponse.deviceStatus == false
                                                    ? "OFF"
                                                    : "ON",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontFamily: 'Roboto',
                                                  color: state.deviceResponse.deviceStatus == false
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
                                              visible:
                                                  widget.productDevice.type ==
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
                                                    activeSwitchBorder:
                                                        Border.all(
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
                                                      callMCBTrip(context, state.deviceResponse);
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                            onTap: () {
                                              getLive();
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                RawMaterialButton(
                                                  onPressed: () {
                                                    getLiveRPCCall(context,
                                                        state.deviceResponse);
                                                  },
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
                                ],
                              ),
                            ),
                          )),
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
                              Visibility(
                                  visible:
                                      widget.productDevice.type == ilmDeviceType
                                          ? true
                                          : false,
                                  child: const Text(
                                    "REPLACEMENT",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Roboto',
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                              const SizedBox(
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
                                      GestureDetector(
                                        onTap: () {
                                          removeDevice(
                                              context, widget.productDevice);
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              widget.productDevice.type ==
                                                      ilmDeviceType
                                                  ? "SHORTING CAP"
                                                  : "REPLACE",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Roboto',
                                                color: Colors.blueAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            RawMaterialButton(
                                              onPressed: () {
                                                removeDevice(context,
                                                    widget.productDevice);
                                              },
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
                                      ),
                                      const VerticalDivider(
                                        color: Colors.black26,
                                        thickness: .2,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          replaceDevice(
                                              context, widget.productDevice);
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              widget.productDevice.type ==
                                                      ilmDeviceType
                                                  ? "ILM"
                                                  : "REMOVE",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Roboto',
                                                color: Colors.blueAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            RawMaterialButton(
                                              onPressed: () {
                                                replaceDevice(context,
                                                    widget.productDevice);
                                              },
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
                                      )
                                    ],
                                  ),
                                ),
                              ),
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

Future<void> updateDeviceStatus(
    context, deviceStatus, ProductDevice productDevice) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(
        progress: 50.0,
        message: "Please wait...",
        progressWidget: Container(
            padding: const EdgeInsets.all(8.0),
            child: const CircularProgressIndicator()),
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
      pr.show();
      // Utility.progressDialog(context);
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
        tbClient.smart_init();

        if (productDevice.type == ilmDeviceType) {
          final jsonData = {
            "method": "ctrl",
            "params": {"lamp": deviceStatus == true ? 1 : 0, "mode": 2}
          };
          updateOnOffStatus(tbClient, jsonData, productDevice, pr);
        } else if (productDevice.type == ccmsDeviceType ||
            productDevice.type == gatewayDeviceType) {
          final jsonData = {
            "method": "ctrl",
            "params": {"lamp": deviceStatus == true ? 1 : 0}
          };
          updateOnOffStatus(tbClient, jsonData, productDevice, pr);
        }
      } catch (e) {
        FlutterLogs.logInfo("devicelist_page", "ilm_maintenance", "logMessage");
        pr.hide();
        // Navigator.pop(context);
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            updateDeviceStatus(context, deviceStatus, productDevice );
          }
        } else {
          calltoast("Unable to Process");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> updateOnOffStatus(ThingsboardClient tbClient, jsonData,
    ProductDevice productDevice, ProgressDialog pr) async {
  var response = await tbClient
      .getDeviceService()
      .handleTwoWayDeviceRPCRequest(productDevice.id, jsonData)
      .timeout(Duration(minutes: 2));

  if (response["lamp"].toString() == "1") {
    Fluttertoast.showToast(
        msg: "Device ON Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
    pr.hide();
    // Navigator.pop(context);
  } else if (response["lamp"].toString() == "0") {
    Fluttertoast.showToast(
        msg: "Device OFF Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
    pr.hide();
    // Navigator.pop(context);
  }else {
    pr.hide();
    // Navigator.pop(context);
    calltoast("Unable to Process, Please try again");
  }
}

Future<void> getLiveRPCCall(context, ProductDevice productDevice) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(
        progress: 50.0,
        message: "Please wait...",
        progressWidget: Container(
            padding: const EdgeInsets.all(8.0),
            child: const CircularProgressIndicator()),
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
      pr.show();
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
        tbClient.smart_init();
        // type: String
        final jsonData;
        if (productDevice.type == ilmDeviceType) {
          var version = prefs.getString("version").toString();
          if (version == "0") {
            jsonData = {"method": "get", "params": 0};
          } else {
            jsonData = {
              "method": "get",
              "params": {"rpcType": 2, "value": 0}
            };
          }
          updateLiveCall(tbClient, jsonData, productDevice.id, pr);
        } else if (productDevice.type == ccmsDeviceType) {
          jsonData = {
            "method": "get",
            "params": {"value": 0}
          };
          updateLiveCall(tbClient, jsonData, productDevice.id, pr);
        } else if (productDevice.type == gatewayDeviceType) {
          jsonData = {
            "method": "get",
            "params": {"value": 0}
          };
          updateLiveCall(tbClient, jsonData, productDevice.id, pr);
        }
      } catch (e) {
        FlutterLogs.logInfo("devicelist_page", "ilm_maintenance",
            "ILM Device Maintenance Exception");
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            getLiveRPCCall(context, productDevice);
          }
        } else {
          calltoast("Unable to Process");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> callMCBTrip(context, ProductDevice productDevice) async {
  Utility.isConnected().then((value) async {
    late ProgressDialog pr;
    if (value) {
      pr = ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(
        progress: 50.0,
        message: "Please wait...",
        progressWidget: Container(
            padding: const EdgeInsets.all(8.0),
            child: const CircularProgressIndicator()),
        maxProgress: 100.0,
        progressTextStyle: const TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: const TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
      pr.show();
      try {
        var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
        tbClient.smart_init();
        final jsonData;
        jsonData = {"method": "clr", "params": "8"};
        var response = await tbClient
            .getDeviceService()
            .handleOneWayDeviceRPCRequest(productDevice.id, jsonData)
            .timeout(const Duration(minutes: 5));
        final jsonDatat;
        jsonDatat = {
          "method": "set",
          "params": {'rostat': 0, 'yostat': 0, 'bostat': 0}
        };
        var responsee = await tbClient
            .getDeviceService()
            .handleOneWayDeviceRPCRequest(
            productDevice.id, jsonDatat)
            .timeout(const Duration(minutes: 5));
        pr.hide();
      } catch (e) {
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
          if (status == true) {
            callMCBTrip(context,productDevice);
          }
        } else {
          calltoast(app_unab_procs);
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<void> updateLiveCall(ThingsboardClient tbClient, jsonData,
    String deviceIdDetails, ProgressDialog pr) async {
  var response = await tbClient
      .getDeviceService()
      .handleOneWayDeviceRPCRequest(deviceIdDetails.toString(), jsonData)
      .timeout(const Duration(minutes: 5));
  pr.hide();
}

Future<void> removeDevice(context, ProductDevice productDevice) async {
  if (productDevice.type == ilmDeviceType) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => replacementilm()));
  } else if (productDevice.type == ccmsDeviceType) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => replacementccms()));
  } else if (productDevice.type == gatewayDeviceType) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => replacementgw()));
  }
}

Future<void> replaceDevice(context, ProductDevice productDevice) async {
  Utility.isConnected().then((value) async {
    if (value) {
      late ProgressDialog pr;
      try {
        pr = ProgressDialog(context,
            type: ProgressDialogType.Normal, isDismissible: false);
        pr.style(
          progress: 50.0,
          message: "Please wait...",
          progressWidget: Container(
              padding: const EdgeInsets.all(8.0),
              child: const CircularProgressIndicator()),
          maxProgress: 100.0,
          progressTextStyle: const TextStyle(
              color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
          messageTextStyle: const TextStyle(
              color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
        );
        pr.show();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String OlddeviceName = prefs.getString('deviceName').toString();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => QRScreen()),
            (route) => true).then((value) async {
          if (value != null) {
            if (OlddeviceName.toString() != value.toString()) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('newDevicename', value);
              pr.hide();
              if (productDevice.type == ilmDeviceType) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => replaceilm()));
              } else if (productDevice.type == ccmsDeviceType) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => replaceccms()));
              } else if (productDevice.type == gatewayDeviceType) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => replacegw()));
              }
            } else {
              FlutterLogs.logInfo(
                  "ilm_maintenance", "ilm_maintenance", "Duplicate QR Code");
              pr.hide();
              calltoast("Duplicate QR Code");
            }
          } else {
            FlutterLogs.logInfo(
                "ilm_maintenance_page", "ilm_maintenance", "Invalid QR Code");
            pr.hide();
            calltoast("Invalid QR Code");
          }
        });
      } catch (e) {
        FlutterLogs.logInfo("ilm_maintenance_page", "ilm_maintenance",
            "ILM  Device Maintenance Exception");
        pr.hide();
        var message = toThingsboardError(e, context);
        if (message == session_expired) {
          var status = loginThingsboard.callThingsboardLogin(context);
        } else {
          calltoast("Device Replacement Issue");
        }
      }
    } else {
      calltoast(no_network);
    }
  });
}

Future<ThingsboardError> toThingsboardError(error, context,
    [StackTrace? stackTrace]) async {
  ThingsboardError? tbError;
  FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
  if (error.message == "Session expired!") {
    var status = loginThingsboard.callThingsboardLogin(context);
    if (status == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => DashboardView()));
    }
  } else {
    if (error is DioError) {
      if (error.response != null && error.response!.data != null) {
        var data = error.response!.data;
        if (data is ThingsboardError) {
          tbError = data;
        } else if (data is Map<String, dynamic>) {
          tbError = ThingsboardError.fromJson(data);
        } else if (data is String) {
          try {
            tbError = ThingsboardError.fromJson(jsonDecode(data));
          } catch (_) {}
        }
      } else if (error.error != null) {
        if (error.error is ThingsboardError) {
          tbError = error.error;
        } else if (error.error is SocketException) {
          tbError = ThingsboardError(
              error: error,
              message: 'Unable to connect',
              errorCode: ThingsBoardErrorCode.general);
        } else {
          tbError = ThingsboardError(
              error: error,
              message: error.error.toString(),
              errorCode: ThingsBoardErrorCode.general);
        }
      }
      if (tbError == null &&
          error.response != null &&
          error.response!.statusCode != null) {
        var httpStatus = error.response!.statusCode!;
        var message = (httpStatus.toString() +
            ': ' +
            (error.response!.statusMessage != null
                ? error.response!.statusMessage!
                : 'Unknown'));
        tbError = ThingsboardError(
            error: error,
            message: message,
            errorCode: httpStatusToThingsboardErrorCode(httpStatus),
            status: httpStatus);
      }
    } else if (error is ThingsboardError) {
      tbError = error;
    }
  }
  tbError ??= ThingsboardError(
      error: error,
      message: error.toString(),
      errorCode: ThingsBoardErrorCode.general);

  var errorStackTrace;
  if (tbError.error is Error) {
    errorStackTrace = tbError.error.stackTrace;
  }

  tbError.stackTrace = stackTrace ??
      tbError.getStackTrace() ??
      errorStackTrace ??
      StackTrace.current;

  return tbError;
}

void calltoast(String polenumber) {
  Fluttertoast.showToast(
      msg: device_toast_msg + polenumber + device_toast_notfound,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0);
}
