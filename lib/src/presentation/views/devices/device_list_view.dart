import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/data/model/device.dart';
import 'package:flutterlumin/src/presentation/views/devices/device_detail.dart';
import 'package:flutterlumin/src/thingsboard/model/device_models.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../thingsboard/model/model.dart';
import '../../../ui/installation/ccms/ccms_install_cam_screen.dart';
import '../../../ui/installation/gateway/gateway_install_cam_screen.dart';
import '../../../ui/installation/ilm/ilm_install_cam_screen.dart';

class DeviceListView extends StatefulWidget {
  const DeviceListView({
    Key? key,
    required this.devices,
  }) : super(key: key);
  final List<ProductDevice> devices;

  @override
  State<DeviceListView> createState() => _DeviceListViewState();
}

class _DeviceListViewState extends State<DeviceListView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Card(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                ListTile(
                    leading: Icon(
                      widget.devices[index].icon,
                      color: kPrimaryColor,
                      size: 40.0,
                    ),
                    title: Text(
                      widget.devices[index].name,
                      style: const TextStyle(
                          color: kPrimaryColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(widget.devices[index].name),
                    onTap: () {
                      isDeviceInstalled(widget.devices![index]);
                    }),
              ],
            );
          },
          itemCount: widget.devices.length,
        ),
      ),
    ));
  }

  Future<void> isDeviceInstalled(ProductDevice device) async {
    var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
    tbClient.smart_init();
    var response = (await tbClient
        .getDeviceService()
        .getTenantDevice(device.name)) as Device;
    var relationDetails =
        await tbClient.getEntityRelationService().findInfoByTo(response.id!);
    if (relationDetails.isEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> versionlist = [];
      versionlist.add("version");
      List<AttributeKvEntry> versionResponserse;
      versionResponserse = (await tbClient
              .getAttributeService()
              .getAttributeKvEntries(response.id!, versionlist))
          as List<AttributeKvEntry>;
      if (versionResponserse.length == 0) {
        prefs.setString('version', "0");
      } else {
        prefs.setString('version', versionResponserse.first.getValue());
      }
      if (relationDetails.length.toString() == "0") {
        if (device.type == ilmDeviceType) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ilmcaminstall()),
          );
        } else if (device.type == ccmsDeviceType) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ccmscaminstall()),
          );
        } else if (device.type == gatewayDeviceType) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const gwcaminstall()),
          );
        }
      }

    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => DeviceDetailDataView(
                productDevice: device,
              )));
    }
  }
}
