import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutterlumin/src/data/model/projects.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/asset_models.dart';
import 'package:flutterlumin/src/thingsboard/model/device_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/asset_id.dart';
import 'package:flutterlumin/src/thingsboard/model/id/device_id.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/const.dart';
import '../../thingsboard/model/id/asset_id.dart';
import '../../thingsboard/model/id/device_id.dart';
import '../../thingsboard/model/model.dart';
import '../../thingsboard/thingsboard_client_base.dart';

class ProjectsRepository {
  List<DeviceId>? activeDevice = [];
  List<DeviceId>? nonactiveDevices = [];
  List<DeviceId>? ncDevices = [];

  List<DeviceId>? ccms_activeDevice = [];
  List<DeviceId>? ccms_nonactiveDevices = [];
  List<DeviceId>? ccms_ncDevices = [];

  List<DeviceId>? gw_activeDevice = [];
  List<DeviceId>? gw_nonactiveDevices = [];
  List<DeviceId>? gw_ncDevices = [];

  List<DeviceId>? relatedDevices = [];
  List<AssetId>? AssetDevices = [];

  Future<Projects> fetchProjectsInformation(BuildContext context) async {
    Projects projectInfo = Projects();
    try {
      var sharedPreferences = await SharedPreferences.getInstance();
      var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
      tbClient.smart_init();
      relatedDevices!.clear();
      AssetDevices!.clear();
      activeDevice!.clear();
      nonactiveDevices!.clear();
      ccms_activeDevice!.clear();
      ccms_nonactiveDevices!.clear();
      Asset response;
      response = await tbClient
              .getAssetService()
              .getTenantAsset(sharedPreferences.getString("SelectedWard")!)
          as Asset;
      var relatedDeviceId;
      if (response != null) {
        List<EntityRelationInfo> wardlist = await tbClient
            .getEntityRelationService()
            .findInfoByAssetFrom(response.id!) as List<EntityRelationInfo>;
        if (wardlist.length != 0) {
          for (int i = 0; i < wardlist.length; i++) {
            if (wardlist.elementAt(i).to.entityType.name != "DEVICE") {
              relatedDeviceId = wardlist.elementAt(i).to;
              AssetDevices?.add(relatedDeviceId);
            } else {
              relatedDeviceId = wardlist.elementAt(i).from;
              AssetDevices?.add(relatedDeviceId);
              break;
            }
          }
          var assetrelatedwardid;
          for (int j = 0; j < AssetDevices!.length; j++) {
            List<EntityRelationInfo> relationdevicelist = await tbClient
                .getEntityRelationService()
                .findInfoByAssetFrom(AssetDevices!.elementAt(j))
            as List<EntityRelationInfo>;
            for (int k = 0; k < relationdevicelist.length; k++) {
              if (relationdevicelist.length != 0) {
                if(relationdevicelist.elementAt(k).to.entityType.index == 6){
                  assetrelatedwardid = relationdevicelist.elementAt(k).to;
                  relatedDevices?.add(assetrelatedwardid);
                }else{
                  assetrelatedwardid = relationdevicelist.elementAt(k).to;
                  AssetDevices?.add(assetrelatedwardid);
                }
              }
            }
          }
          if (relatedDevices != null) {
            for (int k = 0; k < relatedDevices!.length; k++) {
              List<String> myList = [];
              myList.add("active");

              Device data_response;
              data_response = (await tbClient
                      .getDeviceService()
                      .getDevice(relatedDevices!.elementAt(k).id.toString()))
                  as Device;
              if (data_response.type == "lumiNode") {
                List<AttributeKvEntry> responser;
                responser = await tbClient
                    .getAttributeService()
                    .getAttributeKvEntries(
                        relatedDevices!.elementAt(k), myList);
                if (responser != null) {
                  if (responser.first.getValue().toString() == "true") {
                    activeDevice!.add(relatedDevices!.elementAt(k));
                  } else if (responser.first.getValue().toString() == "false") {
                    nonactiveDevices!.add(relatedDevices!.elementAt(k));
                  } else {
                    ncDevices!.add(relatedDevices!.elementAt(k));
                  }
                }
                var totalval = activeDevice!.length +
                    nonactiveDevices!.length +
                    ncDevices!.length;
                var parttotalval =
                    activeDevice!.length + nonactiveDevices!.length;
                var ncdevices = parttotalval - totalval;
                var noncomdevice = "";
                if (ncdevices.toString().contains("-")) {
                  noncomdevice = ncdevices.toString().replaceAll("-", "");
                } else {
                  noncomdevice = ncdevices.toString();
                }
                projectInfo.ilmTotalCount = totalval;
                projectInfo.ilmOnCount = activeDevice!.length;
                projectInfo.ilmOffCount = nonactiveDevices!.length;
                if (noncomdevice != "") {
                  projectInfo.ilmNcCount = int.parse(noncomdevice);
                }
                sharedPreferences.setInt('ilm_total_count', totalval);
                sharedPreferences.setInt('ilm_on_count', activeDevice!.length);
                sharedPreferences.setInt(
                    'ilm_off_count', nonactiveDevices!.length);
                sharedPreferences.setInt(
                    'ilm_nc_count', int.parse(noncomdevice));
              } else if (data_response.type == "CCMS") {
                List<AttributeKvEntry> responser;
                responser = await tbClient
                    .getAttributeService()
                    .getAttributeKvEntries(
                        relatedDevices!.elementAt(k), myList);
                if (responser != null) {
                  if (responser.first.getValue().toString() == "true") {
                    ccms_activeDevice!.add(relatedDevices!.elementAt(k));
                  } else if (responser.first.getValue().toString() == "false") {
                    ccms_nonactiveDevices!.add(relatedDevices!.elementAt(k));
                  } else {
                    ccms_ncDevices!.add(relatedDevices!.elementAt(k));
                  }
                }
                var ccms_totalval = ccms_activeDevice!.length +
                    ccms_nonactiveDevices!.length +
                    ccms_ncDevices!.length;
                var ccms_parttotalval =
                    ccms_activeDevice!.length + ccms_nonactiveDevices!.length;
                var ccms_ncdevices = ccms_parttotalval - ccms_totalval;
                var ccms_noncomdevice = "";
                if (ccms_ncdevices.toString().contains("-")) {
                  ccms_noncomdevice =
                      ccms_ncdevices.toString().replaceAll("-", "");
                } else {
                  ccms_noncomdevice = ccms_ncdevices.toString();
                }
                projectInfo.ccmsTotalCount = ccms_totalval;
                projectInfo.ccmsOnCount = ccms_activeDevice!.length;
                projectInfo.ccmsOffCount = ccms_nonactiveDevices!.length;
                if (ccms_noncomdevice != "") {
                  projectInfo.ccmsNcCount = int.parse(ccms_noncomdevice);
                }
                sharedPreferences.setInt('ccms_total_count', ccms_totalval);
                sharedPreferences.setInt(
                    'ccms_on_count', ccms_activeDevice!.length);
                sharedPreferences.setInt(
                    'ccms_off_count', ccms_nonactiveDevices!.length);
                sharedPreferences.setInt(
                    'ccms_nc_count', int.parse(ccms_noncomdevice));
              } else if (data_response.type == "Gateway") {
                List<AttributeKvEntry> responser;
                responser = await tbClient
                    .getAttributeService()
                    .getAttributeKvEntries(
                        relatedDevices!.elementAt(k), myList);
                if (responser != null) {
                  if (responser.first.getValue().toString() == "true") {
                    gw_activeDevice!.add(relatedDevices!.elementAt(k));
                  } else if (responser.first.getValue().toString() == "false") {
                    gw_nonactiveDevices!.add(relatedDevices!.elementAt(k));
                  } else {
                    gw_ncDevices!.add(relatedDevices!.elementAt(k));
                  }
                }
                var gw_totalval = gw_activeDevice!.length +
                    gw_nonactiveDevices!.length +
                    gw_ncDevices!.length;
                var gw_parttotalval =
                    gw_activeDevice!.length + gw_nonactiveDevices!.length;
                var gw_ncdevices = gw_parttotalval - gw_totalval;
                var gw_noncomdevice = "";
                if (gw_ncdevices.toString().contains("-")) {
                  gw_noncomdevice = gw_ncdevices.toString().replaceAll("-", "");
                } else {
                  gw_noncomdevice = gw_ncdevices.toString();
                }
                projectInfo.gatewayTotalCount = gw_totalval;
                projectInfo.gatewayOnCount = gw_activeDevice!.length;
                projectInfo.gatewayOffCount = gw_nonactiveDevices!.length;
                if (gw_noncomdevice != "") {
                  projectInfo.ccmsNcCount = int.parse(gw_noncomdevice);
                }
                sharedPreferences.setInt('gw_total_count', gw_totalval);
                sharedPreferences.setInt(
                    'gw_on_count', gw_activeDevice!.length);
                sharedPreferences.setInt(
                    'gw_off_count', gw_nonactiveDevices!.length);
                sharedPreferences.setInt(
                    'gw_nc_count', int.parse(gw_noncomdevice));
              }
            }
          }
        } else {
          Fluttertoast.showToast(
              msg: "No Devices Directly Related to Ward",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);

          sharedPreferences.setString('totalCount', "0");
          sharedPreferences.setString('activeCount', "0");
          sharedPreferences.setString('nonactiveCount', "0");
          sharedPreferences.setString('ncCount', "0");

        }
      }
    } catch (e) {
      var message = toThingsboardError(e, context);
      if (message == session_expired) {
        var status = loginThingsboard.callThingsboardLogin(context);
        if (status == true) {
          fetchProjectsInformation(context);
        }
      } else {
        /*Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => DashboardView()));*/
        // Navigator.pop(context);
      }
    }
    return projectInfo;
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    if (error.message == "Session expired!") {
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {
       /* Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => DashboardView()));*/
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
