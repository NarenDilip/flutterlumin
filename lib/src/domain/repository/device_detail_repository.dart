import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/data/model/device.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DeviceDetailRepository {
  Future<ProductDevice> fetchDeviceInformation(String deviceName, BuildContext context) async {
    ProductDevice productDevice = ProductDevice();
    var tbClient = ThingsboardClient(serverUrl);
    tbClient.smart_init();
    var response = (await tbClient
        .getDeviceService()
        .getTenantDevice(deviceName)) as Device;
    List<String> myList = [];
    myList.add("active");
    var deviceResponse = (await tbClient
        .getAttributeService()
        .getAttributeKvEntries(response.id!, myList));
    if (deviceResponse.isNotEmpty) {
      productDevice.deviceStatus = deviceResponse.first.getValue().toString();
      productDevice.deviceTimeStamp =
          deviceResponse.elementAt(0).getLastUpdateTs().toString();
    }
    try {
      List<String> myLister = [];
      myLister.add("landmark");
      var locationResponse = (await tbClient
          .getAttributeService()
          .getAttributeKvEntries(response.id!, myLister));
      if (locationResponse.isNotEmpty) {
        productDevice.location = locationResponse.first.getValue().toString();
      }
      List<String> lampWatts = [];
      lampWatts.add("lampWatts");
      List<AttributeKvEntry> lampDataResponse;
      lampDataResponse = (await tbClient
          .getAttributeService()
          .getAttributeKvEntries(response.id!, lampWatts));
      if (lampDataResponse.isNotEmpty) {
        productDevice.watts = lampDataResponse.first.getValue().toString();
      }
      List<String> locationMap = [];
      locationMap.add("latitude");
      locationMap.add("longitude");
      List<BaseAttributeKvEntry> latLongLocationDataResponse;
      latLongLocationDataResponse = (await tbClient.getAttributeService().getAttributeKvEntries(
          response.id!, locationMap)) as List<BaseAttributeKvEntry>;
      if (latLongLocationDataResponse.isNotEmpty) {
        productDevice.latitude = latLongLocationDataResponse.first.kv.getValue().toString();
        productDevice.longitude = latLongLocationDataResponse.last.kv.getValue().toString();
      }
    } catch (e) {
      var message = toThingsboardError(e, context);
    }
    return productDevice;
  }

  Future<void> getLiveRPCCall(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceID = prefs.getString('deviceId').toString();
    var tbClient = ThingsboardClient(serverUrl);
    tbClient.smart_init();
    final Map<String, Object> jsonData;
    String version="0";
    if (version == "0") {
      jsonData = {"method": "get", "params": 0};
    } else {
      jsonData = {
        "method": "get",
        "params": {"rpcType": 2, "value": 0}
      };
    }
    var response = await tbClient
        .getDeviceService()
        .handleOneWayDeviceRPCRequest(deviceID, jsonData)
        .timeout(const Duration(minutes: 5));
    return response;
  }

  Future<void> changeDeviceStatus(BuildContext context, bool deviceStatus) async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String deviceID = prefs.getString('deviceId').toString();
      var tbClient = ThingsboardClient(serverUrl);
      tbClient.smart_init();
      final jsonData = {
        "method": "ctrl",
        "params": {"lamp": deviceStatus == true ? 1 : 0}
      };
      var response = await tbClient
          .getDeviceService()
          .handleTwoWayDeviceRPCRequest(deviceID, jsonData)
          .timeout(const Duration(minutes: 2));
      return response;
    } catch (e) {
      var message = toThingsboardError(e, context);
      if (message == session_expired) {
        var status = loginThingsboard.callThingsboardLogin(context);
        if (status == true) {
          //changeDeviceStatus(context, status);
        }
      } else {
        //calltoast("Unable to Process");
      }
    }
  }

  Future<void> initiateMCBTrip(BuildContext context, int status) async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String deviceID = prefs.getString('deviceId').toString();
      var tbClient = ThingsboardClient(serverUrl);
      tbClient.smart_init();
      final Map<String, String> jsonData;
      jsonData = {"method": "clr", "params": "8"};
      var response = await tbClient
          .getDeviceService()
          .handleOneWayDeviceRPCRequest(deviceID, jsonData)
          .timeout(const Duration(minutes: 5));
      final Map<String, Object> jsonNewData;
      jsonNewData = {
        "method": "set",
        "params": {'rostat': 0, 'yostat': 0, 'bostat': 0}
      };
      var newResponse = await tbClient
          .getDeviceService()
          .handleOneWayDeviceRPCRequest(deviceID, jsonNewData)
          .timeout(const Duration(minutes: 5));
      return newResponse;
    } catch (e) {
      var message = toThingsboardError(e, context);
      if (message == session_expired) {
        var status = loginThingsboard.callThingsboardLogin(context);
        if (status == true) {
          //changeDeviceStatus(context, status);
        }
      } else {
        //calltoast("Unable to Process");
      }
    }
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    if (error.message == "Session expired!") {
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => dashboard_screen()));
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
}
