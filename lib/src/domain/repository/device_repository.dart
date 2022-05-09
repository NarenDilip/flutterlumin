import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/data/model/device.dart';
import 'package:flutterlumin/src/data/model/device_response.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

class DeviceRepository {
  Future<DeviceResponse> fetchDevices(String productSearchString,
      String productType, BuildContext context) async {
    DeviceResponse deviceResponse = DeviceResponse();
    try {
      var tbClient = ThingsboardClient(serverUrl);
      tbClient.smart_init();
      String searchNumber = productSearchString.replaceAll(" ", "");
      PageLink pageLink = PageLink(100);
      pageLink.page = 0;
      pageLink.pageSize = 100;
      pageLink.textSearch = searchNumber;
      PageData<Device> deviceListResponse;
      if (productType != "all") {
        deviceListResponse = (await tbClient
            .getDeviceService()
            .getTenantProductDevices(pageLink, productType));
      } else {
        deviceListResponse =
            (await tbClient.getDeviceService().getTenantDevices(pageLink));
      }
      if (deviceListResponse.totalElements != 0) {
        List<ProductDevice>? deviceList = [];
        for (int i = 0; i < deviceListResponse.data.length; i++) {
          ProductDevice productDevice = ProductDevice();
          productDevice.name = deviceListResponse.data.elementAt(i).name;
          productDevice.type = deviceListResponse.data.elementAt(i).type;
          if (productDevice.type == gatewayDeviceType) {
            productDevice.icon = Icons.hub_outlined;
          } else if (productDevice.type == ccmsDeviceType) {
            productDevice.icon = Icons.offline_bolt_outlined;
          } else if (productDevice.type == ilmDeviceType) {
            productDevice.icon = Icons.light_outlined;
          } else {
            productDevice.icon = Icons.tungsten_outlined;
          }
          if (productDevice.icon != Icons.tungsten_outlined) {
            deviceList.add(productDevice);
          }
        }
        deviceResponse.deviceList = deviceList;
      } else {
        deviceResponse.errorMessage = "No devices found";
      }
    } catch (e) {
      var message = toThingsboardError(e, context);
      if (message == session_expired) {
        var status = loginThingsboard.callThingsboardLogin(context);
        if (status == true) {
          fetchDevices(productSearchString, productType, context);
        }
      }
    }

    return deviceResponse;
  }

  Future<DeviceResponse> fetchPoleDevices(String productSearchString) async {
    final List<String>? relationDevices = [];
    DeviceResponse deviceResponse = DeviceResponse();
    String poleNumber = productSearchString.replaceAll(" ", "");
    Asset response;
    var tbClient = ThingsboardClient(serverUrl);
    tbClient.smart_init();
    response =
        await tbClient.getAssetService().getTenantAsset(poleNumber) as Asset;
    if (response != null) {
      List<EntityRelation> relationResponse;
      relationResponse =
          await tbClient.getEntityRelationService().findByFrom(response.id!);
      if (relationResponse != null) {
        for (int i = 0; i < relationResponse.length; i++) {
          relationDevices!.add(relationResponse.elementAt(i).to.id.toString());
        }
        Device devRelationResponse;
        List<ProductDevice>? deviceList = [];
        for (int i = 0; i < relationDevices!.length; i++) {
          devRelationResponse = await tbClient
              .getDeviceService()
              .getDevice(relationDevices.elementAt(i).toString()) as Device;
          if (devRelationResponse != null) {
            if (devRelationResponse.type == "lumiNode") {
              ProductDevice productDevice = ProductDevice();
              productDevice.name = devRelationResponse.name;
              productDevice.type = "pole";
              deviceList.add(productDevice);
            } else {}
          }
        }
        deviceResponse.deviceList = deviceList;
      }
    } else {
      deviceResponse.errorMessage = "No devices found";
    }
    return deviceResponse;
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    if (error.message == "Session expired!") {
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {

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
