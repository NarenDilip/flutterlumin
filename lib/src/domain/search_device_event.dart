import 'package:flutter/cupertino.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/maintenance/ccms/ccms_maintenance_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';

class SearchDeviceEvent{
  static Future<List<String>> callILMDeviceListFinder(
      String selectedNumber, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          List<String>? _foundProducts = [];
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          String searchNumber = selectedNumber.replaceAll(" ", "");

          PageLink pageLink = new PageLink(100);
          pageLink.page = 0;
          pageLink.pageSize = 100;
          pageLink.textSearch = searchNumber;

          PageData<Device> devicelist_response;
          devicelist_response = (await tbClient
              .getDeviceService()
              .getTenantDevices(pageLink));

          if (devicelist_response != null) {
            if (devicelist_response.totalElements != 0) {
              for (int i = 0; i < devicelist_response.data.length; i++) {
                String name =
                devicelist_response.data.elementAt(i).name.toString();
                _foundProducts.add(name);
              }
            }
            return _foundProducts;
          } else {
            //progressDialog.hide();
            calltoast(searchNumber);
            return null;
          }
        } catch (e) {
          //progressDialog.hide();
         /* var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callPoleBasedILMDeviceListFinder(
                  selectedNumber, _relationdevices, _foundProducts, context);
            }
          } else {
            //calltoast(searchNumber);
            // Navigator.pop(context);
          }*/
          return null;
        }
      } else {
        calltoast(no_network);
      }
    });

  }
}