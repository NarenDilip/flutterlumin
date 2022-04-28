import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/data/model/device_response.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

class DeviceRepository {

  Future<DeviceResponse> fetchILMDevices(String productSearchString) async {
    DeviceResponse deviceResponse = DeviceResponse();
    var tbClient = ThingsboardClient(serverUrl);
    tbClient.smart_init();
    String searchNumber = productSearchString.replaceAll(" ", "");
    PageLink pageLink = PageLink(100);
    pageLink.page = 0;
    pageLink.pageSize = 100;
    pageLink.textSearch = searchNumber;
    PageData<Device> deviceListResponse;
    deviceListResponse =
        (await tbClient.getDeviceService().getTenantDevices(pageLink));
    if (deviceListResponse.totalElements != 0) {
      List<String>? deviceList = [];
      for (int i = 0; i < deviceListResponse.data.length; i++) {
        String name = deviceListResponse.data.elementAt(i).name.toString();
        deviceList.add(name);
      }
      deviceResponse.deviceList = deviceList;
    }else{
      deviceResponse.errorMessage = "No devices found";
    }
    return deviceResponse;
  }

  Future<DeviceResponse> fetchCCMSDevices(
      String productSearchString) async {
    DeviceResponse deviceResponse = DeviceResponse();
    var tbClient = ThingsboardClient(serverUrl);
    tbClient.smart_init();
    String searchNumber = productSearchString.replaceAll(" ", "");
    PageLink pageLink = PageLink(100);
    pageLink.page = 0;
    pageLink.pageSize = 100;
    pageLink.textSearch = searchNumber;

    PageData<Device> deviceListResponse;
    deviceListResponse = (await tbClient
        .getDeviceService()
        .getccmsTenantDevices(pageLink));

    if (deviceListResponse != null) {
      if (deviceListResponse.totalElements != 0) {
        List<String>? deviceList = [];
        for (int i = 0; i < deviceListResponse.data.length; i++) {
          String name = deviceListResponse.data.elementAt(i).name.toString();
          deviceList.add(name);
        }
        deviceResponse.deviceList = deviceList;
      }
    }else{
      deviceResponse.errorMessage = "No devices found";
    }
    return deviceResponse;
  }

  Future<DeviceResponse> fetchPoleDevices(
      String productSearchString) async {
    final List<String>? relationDevices = [];
    DeviceResponse deviceResponse = DeviceResponse();
    String poleNumber = productSearchString.replaceAll(" ", "");
    Asset response;
    var tbClient = ThingsboardClient(serverUrl);
    tbClient.smart_init();
    response =
        await tbClient.getAssetService().getTenantAsset(poleNumber) as Asset;
    List<EntityRelation> relationResponse;
    relationResponse =
        await tbClient.getEntityRelationService().findByFrom(response.id!);
    for (int i = 0; i < relationResponse.length; i++) {
      relationDevices!.add(relationResponse.elementAt(i).to.id.toString());
    }
    Device devRelationResponse;
    for (int i = 0; i < relationDevices!.length; i++) {
      devRelationResponse = await tbClient
          .getDeviceService()
          .getDevice(relationDevices.elementAt(i).toString()) as Device;
      if (devRelationResponse.type == "lumiNode") {
        deviceResponse.deviceList.add(devRelationResponse.name);
      } else {}
    }
    return deviceResponse;
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
