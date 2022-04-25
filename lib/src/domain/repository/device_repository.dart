import 'dart:async';

import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/data/model/device_response.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';

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
    }
    return deviceResponse;
  }

  Future<DeviceResponse> fetchCCMSDevices(
      String productSearchString, List<String> relationDevices) async {
    DeviceResponse deviceResponse = DeviceResponse();
    String ccmsNumber = productSearchString.replaceAll(" ", "");
    Device response;
    var tbClient = ThingsboardClient(serverUrl);
    tbClient.smart_init();
    response =
        await tbClient.getDeviceService().getTenantDevice(ccmsNumber) as Device;
    if(response != null){
      List<EntityRelation> relationResponse;
      relationResponse =
      await tbClient.getEntityRelationService().findByFrom(response.id!);
      for (int i = 0; i < relationResponse.length; i++) {
        relationDevices.add(relationResponse.elementAt(i).to.id.toString());
      }
      Device devRelationResponse;
      for (int i = 0; i < relationDevices.length; i++) {
        devRelationResponse = await tbClient
            .getDeviceService()
            .getDevice(relationDevices.elementAt(i).toString()) as Device;
        if (devRelationResponse.type == "lumiNode") {
          deviceResponse.deviceList.add(devRelationResponse.name);
        } else {}
      }
    }

    return deviceResponse;
  }

  Future<DeviceResponse> fetchPoleDevices(
      String productSearchString, List<String> relationDevices) async {
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
      relationDevices.add(relationResponse.elementAt(i).to.id.toString());
    }
    Device devRelationResponse;
    for (int i = 0; i < relationDevices.length; i++) {
      devRelationResponse = await tbClient
          .getDeviceService()
          .getDevice(relationDevices.elementAt(i).toString()) as Device;
      if (devRelationResponse.type == "lumiNode") {
        deviceResponse.deviceList.add(devRelationResponse.name);
      } else {}
    }
    return deviceResponse;
  }
}
