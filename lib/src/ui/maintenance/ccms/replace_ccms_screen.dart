import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/device_models.dart';
import 'package:flutterlumin/src/thingsboard/model/entity_group_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/entity_group_id.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/ui/maintenance/ccms/ccms_maintenance_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localdb/db_helper.dart';
import '../../../localdb/model/region_model.dart';
import '../../../localdb/model/ward_model.dart';
import '../../dashboard/dashboard_screen.dart';
import '../ilm/ilm_maintenance_screen.dart';

// CCMS Maintenance remove device screen, it will check the selected device
// is present in server, it will collect the details of the device, user need
// to scan the new qr code for replacing with new device.on the replacement
// process it will interchange both devices and move the non working device to
// forrepair folder and revert back to maintenance page

class replaceccms extends StatefulWidget {
  const replaceccms() : super();

  @override
  replaceccmsState createState() => replaceccmsState();
}

class replaceccmsState extends State<replaceccms> {
  String DeviceName = "0";
  String newDeviceName = "0";
  var imageFile;
  String faultyStatus = "0";
  late ProgressDialog pr;
  String address = "";
  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DeviceName = prefs.getString('deviceName').toString();
    newDeviceName = prefs.getString('newDevicename').toString();
    faultyStatus = prefs.getString("faultyStatus").toString();

    setState(() {
      DeviceName = DeviceName;
      newDeviceName = newDeviceName;
      faultyStatus = faultyStatus;

      if (DeviceName == null) {
        faultyStatus = "0";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    DeviceName = "";
    newDeviceName = "";
    _openCamera(context);
    getSharedPrefs();
    setUpLogs();
  }

  void setUpLogs() async {
    await FlutterLogs.initLogs(
        logLevelsEnabled: [
          LogLevel.INFO,
          LogLevel.WARNING,
          LogLevel.ERROR,
          LogLevel.SEVERE
        ],
        timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
        directoryStructure: DirectoryStructure.FOR_DATE,
        logTypesEnabled: [_myLogFileName],
        logFileExtension: LogFileExtension.LOG,
        logsWriteDirectoryName: "MyLogs",
        logsExportDirectoryName: "MyLogs/Exported",
        debugFileOperations: true,
        isDebuggable: true);

    // [IMPORTANT] The first log line must never be called before 'FlutterLogs.initLogs'
    // FlutterLogs.logInfo(_tag, "setUpLogs", "setUpLogs: Setting up logs..");

    // Logs Exported Callback
    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == 'logsExported') {
        setLogsStatus(
            status: "logsExported: ${call.arguments.toString()}", append: true);

        // Notify Future with value
        _completer.complete(call.arguments.toString());
      } else if (call.method == 'logsPrinted') {
        setLogsStatus(
            status: "logsPrinted: ${call.arguments.toString()}", append: true);
      }
    });
  }

  void setLogsStatus({String status = '', bool append = false}) {
    setState(() {
      logStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
      message: app_pls_wait,
      borderRadius: 20.0,
      backgroundColor: Colors.lightBlueAccent,
      elevation: 10.0,
      messageTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: "Montserrat",
          fontSize: 19.0,
          fontWeight: FontWeight.w600),
      progressWidget: const CircularProgressIndicator(
          backgroundColor: Colors.lightBlueAccent,
          valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
          strokeWidth: 3.0),
    );

    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) =>
                  dashboard_screen(selectedPage: 0)));
          return true;
        },
        child: Scaffold(
            body: Container(
                padding: EdgeInsets.fromLTRB(15, 60, 15, 0),
                decoration: const BoxDecoration(
                    color: thbDblue,
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                alignment: Alignment.center,
                child: Column(children: [
                  Container(
                    width: width / 1.25,
                    height: height / 1.25,
                    child: imageFile != null
                        ? Image.file(File(imageFile.path))
                        : Container(
                            decoration: BoxDecoration(color: Colors.white),
                            width: 200,
                            height: 200,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            )),
                  ),
                  SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      child: TextButton(
                          child: Text(app_com_replace,
                              style: const TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(20)),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ))),
                          onPressed: () async {
                            if (imageFile != null) {
                              // pr.show();
                              // late Future<Device?> entityFuture;
                              // entityFuture = ilm_main_fetchDeviceDetails(
                              //     DeviceName,
                              //     newDeviceName,
                              //     context,
                              //     imageFile);
                              if (!(await Geolocator()
                                  .isLocationServiceEnabled())) {
                                onGpsAlert();
                              } else {
                                showActionAlertDialog(
                                    context, DeviceName, newDeviceName);
                              }
                            } else {
                              pr.hide();
                              Fluttertoast.showToast(
                                  msg: app_device_image_cap,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  fontSize: 16.0);
                            }
                          })),
                ]))));
  }

  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 480,
        maxWidth: 640,
        imageQuality: 10,
        preferredCameraDevice: CameraDevice.rear);
    setState(() {
      if (pickedFile != null) {
        imageFile = pickedFile;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CCMSMaintenanceScreen()),
        );
      }
    });
  }

  showActionAlertDialog(context, OldDevice, NewDevice) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(app_dialog_cancel,
          style: const TextStyle(
              fontSize: 25.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: Colors.red)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: Text(app_dialog_replace,
          style: const TextStyle(
              fontSize: 25.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: Colors.green)),
      onPressed: () {
        late Future<Device?> entityFuture;
        // Utility.progressDialog(context);
        entityFuture = ilm_main_fetchDeviceDetails(
            OldDevice, NewDevice, context, imageFile);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text(app_display_name,
          style: TextStyle(
              fontSize: 25.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: thbDblue)),
      content: RichText(
        text: TextSpan(
          text: app_dial_replace,
          style: const TextStyle(
              fontSize: 16.0,
              fontFamily: "Montserrat",
              fontWeight: FontWeight.bold,
              color: liorange),
          children: <TextSpan>[
             TextSpan(
                text: OldDevice,
                style: const TextStyle(
                    fontSize: 18.0,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
             const TextSpan(
                text: app_dial_replace_with,
                style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    color: liorange)),
             TextSpan(
                text: NewDevice,
                style: const TextStyle(
                    fontSize: 18.0,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
             const TextSpan(
                text: ' ? ',
                style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold,
                    color: liorange)),
          ],
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Future<Device?> ilm_main_fetchDeviceDetails(String OlddeviceName,
      String deviceName, BuildContext context, imageFile) async {
    Utility.isConnected().then((value) async {
      if (value) {
        pr.show();
        try {
          Device response;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient =
              ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
          tbClient.smart_init();
          response = await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName) as Device;
          if (response.name.isNotEmpty) {
            if (response.type == ilm_deviceType) {
            } else if (response.type == ccms_deviceType) {
              ilm_main_fetchSmartDeviceDetails(OlddeviceName, deviceName,
                  response.id!.id.toString(), context, imageFile);
            } else if (response.type == Gw_deviceType) {
            } else {
              pr.hide();
              calltoast(app_dev_sel_details_one +
                  deviceName +
                  app_dev_sel_details_two);
            }
          } else {
            pr.hide();
            calltoast(deviceName);
          }
        } catch (e) {
          /*FlutterLogs.logInfo("CCMS_replacement_page", "CCMS_remove",
              "Unable to find Device Details");*/
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              ilm_main_fetchDeviceDetails(
                  OlddeviceName, deviceName, context, imageFile);
            }
          } else {
            calltoast(deviceName);
          }
        }
      } else {
        noInternetToast(no_network);
      }
    });
  }

  Future<String> _getAddress(double? lat, double? lang) async {
    if (lat == null || lang == null) return "";
    final coordinates = new Coordinates(lat, lang);
    List<Address> addresss =
        (await Geocoder.local.findAddressesFromCoordinates(coordinates));
    setState(() {
      address = addresss.elementAt(1).addressLine.toString();
    });
    return "${addresss.elementAt(1).addressLine}";
  }

  @override
  Future<Device?> ilm_main_fetchSmartDeviceDetails(
      String Olddevicename,
      String deviceName,
      String deviceid,
      BuildContext context,
      imageFile) async {
    var DevicecurrentFolderName = "";
    var DevicemoveFolderName = "";

    Utility.isConnected().then((value) async {
      if (value) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String SelectedRegion = prefs.getString('SelectedRegion').toString();
        String SelectedWard = prefs.getString('SelectedWard').toString();
        String FirmwareVersion = prefs.getString("firmwareVersion").toString();
        String Lattitude = prefs.getString("deviceLatitude").toString();
        String Longitude = prefs.getString("deviceLongitude").toString();
        String SelectedZone = prefs.getString('SelectedZone').toString();
        //newly added by dev
        String Createdby = prefs.getString("username").toString();
        var versionCompatability = false;

        var latter = double.parse(Lattitude);
        var longer = double.parse(Longitude);

        _getAddress(latter, longer).then((value) {
          setState(() {
            address = value;
            prefs.setString("location", address);
          });
        });

        // Utility.progressDialog(context);
        pr.show();
        try {
          Device response;
          Future<List<EntityGroupInfo>> deviceResponse;
          var tbClient =
              ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
          tbClient.smart_init();

          response = (await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName)) as Device;

          if (imageFile != null) {
            if (response != null) {
              var new_Device_Name = response.name;
              var new_Device_label = response.label;

              if (faultyStatus == "2") {
                Map data = {'faulty': "true"};
                var saveAttributes = await tbClient
                    .getAttributeService()
                    .saveDeviceAttributes(
                        response.id!.id!, "SERVER_SCOPE", data);
              }

              List<EntityGroupInfo> entitygroups;
              entitygroups = await tbClient
                  .getEntityGroupService()
                  .getEntityGroupsByFolderType();

              if (entitygroups != null) {
                for (int i = 0; i < entitygroups.length; i++) {
                  if (entitygroups.elementAt(i).name ==
                      FlavorConfig
                          .instance.variables["CCMSserviceFolderName"]) {
                    DevicemoveFolderName =
                        entitygroups.elementAt(i).id!.id!.toString();
                  }
                }

                List<EntityGroupId> currentdeviceresponse;
                currentdeviceresponse = await tbClient
                    .getEntityGroupService()
                    .getEntityGroupsForFolderEntity(response.id!.id!);

                if (currentdeviceresponse != null) {
                  var firstdetails = await tbClient
                      .getEntityGroupService()
                      .getEntityGroup(currentdeviceresponse.first.id!);
                  if (firstdetails!.name.toString() != "All") {
                    DevicecurrentFolderName = currentdeviceresponse.first.id!;
                  }
                  var seconddetails = await tbClient
                      .getEntityGroupService()
                      .getEntityGroup(currentdeviceresponse.last.id!);
                  if (seconddetails!.name.toString() != "All") {
                    DevicecurrentFolderName = currentdeviceresponse.last.id!;
                  }

                  var relationDetails = await tbClient
                      .getEntityRelationService()
                      .findInfoByTo(response.id!);

                  if (relationDetails != null) {
                    List<String> myList = [];
                    myList.add("lampWatts");
                    myList.add("active");

                    List<BaseAttributeKvEntry> responser;

                    responser = (await tbClient
                            .getAttributeService()
                            .getAttributeKvEntries(response.id!, myList))
                        as List<BaseAttributeKvEntry>;

                    if (responser != null) {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('deviceStatus',
                          responser.first.kv.getValue().toString());
                      prefs.setString('deviceWatts',
                          responser.last.kv.getValue().toString());

                      prefs.setString('deviceId', deviceid);
                      prefs.setString('deviceName', deviceName);

                      DeviceCredentials? newdeviceCredentials;
                      DeviceCredentials? olddeviceCredentials;

                      DBHelper dbHelper = DBHelper();
                      var regionid;
                      List<Region> regiondetails = await dbHelper
                          .region_name_regionbasedDetails(SelectedRegion);
                      if (regiondetails.length != "0") {
                        regionid = regiondetails.first.regionid;
                      }

                      // List<String> myfirmList = [];
                      // myfirmList.add("firmware_versions");
                      //
                      // List<AttributeKvEntry> faultresponser;
                      //
                      // faultresponser = (await tbClient
                      //     .getAttributeService()
                      //     .getFirmAttributeKvEntries(regionid, myfirmList));
                      //
                      // List<String> myreplacefirmList = [];
                      // myreplacefirmList.add("firmware_versions");
                      //
                      // List<AttributeKvEntry> relacefaultresponser;
                      //
                      // relacefaultresponser = (await tbClient
                      //     .getAttributeService()
                      //     .getAttributeallKvEntries(
                      //     response.id!.id!, myreplacefirmList));

                      // if (faultresponser.length != 0) {
                      //   var firmwaredetails =
                      //   faultresponser.first.getValue().toString();

                      // final decoded = jsonDecode(firmwaredetails) as Map;
                      // var firmware_versions = decoded['firmware_version'];
                      // var compatable_versions = decoded[FirmwareVersion];
                      //
                      // if (compatable_versions
                      //     .toString()
                      //     .contains(relacefaultresponser.first.getValue())) {
                      versionCompatability = true;
                      // } else {
                      //   versionCompatability = false;
                      // }

                      if (versionCompatability == true) {
                        if (relationDetails.length.toString() == "0") {
                          newdeviceCredentials = await tbClient
                                  .getDeviceService()
                                  .getDeviceCredentialsByDeviceId(
                                      response.id!.id.toString())
                              as DeviceCredentials;

                          if (newdeviceCredentials != null) {
                            var newQRID =
                                newdeviceCredentials.credentialsId.toString();

                            newdeviceCredentials.credentialsId = newQRID + "L";
                            var credresponse = await tbClient
                                .getDeviceService()
                                .saveDeviceCredentials(newdeviceCredentials);

                            response.name = deviceName + "99";
                            var devresponse = await tbClient
                                .getDeviceService()
                                .saveDevice(response);

                            // Old Device Updations
                            Device Olddevicedetails = null as Device;
                            Olddevicedetails = await tbClient
                                .getDeviceService()
                                .getTenantDevice(Olddevicename) as Device;

                            if (Olddevicedetails != null) {
                              var Old_Device_Name = Olddevicedetails.name;
                              var Old_Device_label = Olddevicedetails.label;


                              olddeviceCredentials = await tbClient
                                      .getDeviceService()
                                      .getDeviceCredentialsByDeviceId(
                                          Olddevicedetails.id!.id.toString())
                                  as DeviceCredentials;

                              if (olddeviceCredentials != null) {
                                var oldQRID = olddeviceCredentials.credentialsId
                                    .toString();

                                olddeviceCredentials.credentialsId =
                                    oldQRID + "L";
                                var old_cred_response = await tbClient
                                    .getDeviceService()
                                    .saveDeviceCredentials(
                                        olddeviceCredentials);

                                Olddevicedetails.name = Olddevicename + "99";
                                var old_dev_response = await tbClient
                                    .getDeviceService()
                                    .saveDevice(Olddevicedetails);

                                olddeviceCredentials.credentialsId = newQRID;
                                var oldcredresponse = await tbClient
                                    .getDeviceService()
                                    .saveDeviceCredentials(
                                        olddeviceCredentials);

                                response.name = Old_Device_Name;
                                response.label = Old_Device_label;
                                var olddevresponse = await tbClient
                                    .getDeviceService()
                                    .saveDevice(response);

                                final old_body_req = {
                                  'boardNumber': Old_Device_Name,
                                  'ieeeAddress': oldQRID,
                                  'slatitude': Lattitude.toString(),
                                  'slongitude': Longitude.toString(),
                                  'landmark': address,
                                  'zoneName': SelectedZone,
                                  'wardName': SelectedWard,
                                  'InstallBy': Createdby,
                                  'InstalledOn':DateTime.now().millisecondsSinceEpoch,
                                };

                                DBHelper dbHelper = DBHelper();
                                List<Ward> warddetails = await dbHelper
                                    .ward_basedDetails(SelectedWard);
                                if (warddetails.length != "0") {
                                  warddetails.first.wardid;

                                  Map<String, dynamic> fromId = {
                                    'entityType': 'ASSET',
                                    'id': warddetails.first.wardid
                                  };

                                  Map<String, dynamic> toId = {
                                    'entityType': 'DEVICE',
                                    'id': response.id!.id
                                  };

                                  EntityRelation entityRelation =
                                      EntityRelation(
                                          from: EntityId.fromJson(fromId),
                                          to: EntityId.fromJson(toId),
                                          type: "Contains",
                                          typeGroup: RelationTypeGroup.COMMON);

                                  Future<EntityRelation> entityRelations =
                                      tbClient
                                          .getEntityRelationService()
                                          .saveRelation(entityRelation);
                                }

                                var up_attribute = (await tbClient
                                    .getAttributeService()
                                    .saveDeviceAttributes(response.id!.id!,
                                        "SERVER_SCOPE", old_body_req));

                                // New Device Updations

                                Olddevicedetails.name = new_Device_Name;
                                Olddevicedetails.label = new_Device_label;
                                var up_devresponse = await tbClient
                                    .getDeviceService()
                                    .saveDevice(Olddevicedetails);

                                newdeviceCredentials.credentialsId = oldQRID;
                                var up_credresponse = await tbClient
                                    .getDeviceService()
                                    .saveDeviceCredentials(
                                        newdeviceCredentials);

                                final new_body_req = {
                                  'boardNumber': new_Device_Name,
                                  'ieeeAddress': newQRID,
                                  'landmark': address,
                                  'slatitude': Lattitude.toString(),
                                  'slongitude': Longitude.toString(),
                                  'zoneName': SelectedZone,
                                  'wardName': SelectedWard,
                                  'InstallBy': Createdby,
                                  'InstalledOn':DateTime.now().millisecondsSinceEpoch,
                                };

                                try {
                                  var up_newdevice_attribute = (await tbClient
                                      .getAttributeService()
                                      .saveDeviceAttributes(
                                          Olddevicedetails.id!.id!,
                                          "SERVER_SCOPE",
                                          new_body_req));
                                } catch (e) {}

                                List<String> myList = [];
                                myList.add(response.id!.id!);

                                try {
                                  var remove_response = await tbClient
                                      .getEntityGroupService()
                                      .removeEntitiesFromEntityGroup(
                                          DevicecurrentFolderName, myList);
                                } catch (e) {}
                                try {
                                  var add_response = await tbClient
                                      .getEntityGroupService()
                                      .addEntitiesToEntityGroup(
                                          DevicemoveFolderName, myList);
                                } catch (e) {}
                                pr.hide();
                                callReplacementComplete(
                                    context, imageFile, deviceName);
                              }
                            } else {
                              pr.hide();
                              calltoast(deviceName);

                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          dashboard_screen(selectedPage: 0)));
                            }
                          }
                        } else {
                          // New Device Updations
                          newdeviceCredentials = await tbClient
                                  .getDeviceService()
                                  .getDeviceCredentialsByDeviceId(
                                      response.id!.id.toString())
                              as DeviceCredentials;

                          var relation_response = await tbClient
                              .getEntityRelationService()
                              .deleteDeviceRelation(
                                  relationDetails.elementAt(0).from.id!,
                                  response.id!.id!);

                          if (newdeviceCredentials != null) {
                            var newQRID =
                                newdeviceCredentials.credentialsId.toString();

                            newdeviceCredentials.credentialsId = newQRID + "L";
                            var credresponse = await tbClient
                                .getDeviceService()
                                .saveDeviceCredentials(newdeviceCredentials);

                            response.name = deviceName + "99";
                            var devresponse = await tbClient
                                .getDeviceService()
                                .saveDevice(response);

                            // Old Device Updations

                            Device Olddevicedetails = null as Device;
                            Olddevicedetails = await tbClient
                                .getDeviceService()
                                .getTenantDevice(Olddevicename) as Device;

                            if (Olddevicedetails != null) {
                              var Old_Device_Name = Olddevicedetails.name;
                              var Old_Device_label = Olddevicedetails.label;

                              olddeviceCredentials = await tbClient
                                      .getDeviceService()
                                      .getDeviceCredentialsByDeviceId(
                                          Olddevicedetails.id!.id.toString())
                                  as DeviceCredentials;

                              if (olddeviceCredentials != null) {
                                var oldQRID = olddeviceCredentials.credentialsId
                                    .toString();

                                olddeviceCredentials.credentialsId =
                                    oldQRID + "L";
                                var old_cred_response = await tbClient
                                    .getDeviceService()
                                    .saveDeviceCredentials(
                                        olddeviceCredentials);

                                Olddevicedetails.name = Olddevicename + "99";
                                var old_dev_response = await tbClient
                                    .getDeviceService()
                                    .saveDevice(Olddevicedetails);

                                olddeviceCredentials.credentialsId = newQRID;
                                var oldcredresponse = await tbClient
                                    .getDeviceService()
                                    .saveDeviceCredentials(
                                        olddeviceCredentials);

                                response.name = Old_Device_Name;
                                response.label = Old_Device_label;
                                var olddevresponse = await tbClient
                                    .getDeviceService()
                                    .saveDevice(response);
                                /*  List<String> myfirmList = [];
                                myfirmList.add("lattitude");

                                List<AttributeKvEntry> latt_faultresponser;

                                latt_faultresponser = (await tbClient
                                    .getAttributeService()
                                    .getFirmAttributeKvEntries(
                                    regionid, myfirmList));

                                if (latt_faultresponser.first
                                    .getValue()
                                    .toString()
                                    .isNotEmpty) {
                                } else {
                                  final old_bodyW_req = {
                                    'lattitude': Lattitude.toString(),
                                    'longitude': Longitude.toString(),
                                    'landmark': address,
                                  };

                                  var up_attribute = (await tbClient
                                      .getAttributeService()
                                      .saveDeviceAttributes(response.id!.id!,
                                      "SERVER_SCOPE", old_bodyW_req));
                                }*/

                                final old_body_req = {
                                  'boardNumber': Old_Device_Name,
                                  'ieeeAddress': oldQRID,
                                };

                                var up_attribute = (await tbClient
                                    .getAttributeService()
                                    .saveDeviceAttributes(response.id!.id!,
                                        "SERVER_SCOPE", old_body_req));

                                // New Device Updations

                                Olddevicedetails.name = new_Device_Name;
                                Olddevicedetails.label = new_Device_label;
                                var up_devresponse = await tbClient
                                    .getDeviceService()
                                    .saveDevice(Olddevicedetails);

                                newdeviceCredentials.credentialsId = oldQRID;
                                var up_credresponse = await tbClient
                                    .getDeviceService()
                                    .saveDeviceCredentials(
                                        newdeviceCredentials);

                                final new_body_req = {
                                  'boardNumber': new_Device_Name,
                                  'ieeeAddress': newQRID,
                                };
                                try {
                                  var up_newdevice_attribute = (await tbClient
                                      .getAttributeService()
                                      .saveDeviceAttributes(
                                          Olddevicedetails.id!.id!,
                                          "SERVER_SCOPE",
                                          new_body_req));
                                } catch (e) {}

                                List<String> myList = [];
                                myList.add(response.id!.id!);

                                try {
                                  var remove_response = tbClient
                                      .getEntityGroupService()
                                      .removeEntitiesFromEntityGroup(
                                          DevicecurrentFolderName, myList);
                                } catch (e) {}
                                try {
                                  var add_response = tbClient
                                      .getEntityGroupService()
                                      .addEntitiesToEntityGroup(
                                          DevicemoveFolderName, myList);
                                } catch (e) {}

                                pr.hide();
                                Navigator.of(context, rootNavigator: true)
                                    .pop('dialog');
                                callReplacementComplete(
                                    context, imageFile, deviceName);
                              }
                            } else {
                              pr.hide();
                              calltoast(deviceName);
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          dashboard_screen(selectedPage: 0)));
                            }
                          } else {
                            pr.hide();
                            callstoast(app_dev_find_dev_cred);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        dashboard_screen(selectedPage: 0)));
                          }
                        }
                      } else {
                        pr.hide();
                        Fluttertoast.showToast(
                            msg: app_dev_not_compat_one +
                                SelectedRegion +
                                app_dev_not_compat_two,
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0);

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                dashboard_screen(selectedPage: 0)));
                      }
                      // } else {
                      //   pr.hide();
                      // }
                    } else {
                      pr.hide();
                      callstoast(app_dev_find_dev_attr);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              dashboard_screen(selectedPage: 0)));
                    }
                  } else {
                    pr.hide();
                    callstoast(app_dev_find_relation_details);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            dashboard_screen(selectedPage: 0)));
                  }
                } else {
                  pr.hide();
                  callstoast(app_dev_current_unable_folder_details);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          dashboard_screen(selectedPage: 0)));
                }
              } else {
                pr.hide();
                callstoast(app_dev_unable_folder_details);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        dashboard_screen(selectedPage: 0)));
              }
            } else {
              pr.hide();
              callstoast(app_dev_sel_details_one +
                  DeviceName +
                  app_dev_sel_details_two);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      dashboard_screen(selectedPage: 0)));
            }
          } else {
            pr.hide();
            Fluttertoast.showToast(
                msg: app_device_image_cap,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        } catch (e) {
          /*FlutterLogs.logInfo("CCMS_replacement_page", "CCMS_remove",
              "CCMS Replacement Device Replacement Exception");*/
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              ilm_main_fetchDeviceDetails(
                  Olddevicename, deviceName, context, imageFile);
            }
          } else {
            calltoast(deviceName);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) =>
                    dashboard_screen(selectedPage: 0)));
          }
        }
      } else {
        noInternetToast(no_network);
      }
    });
  }

  Future<void> callReplacementComplete(context, imageFile, DeviceName) async {
    final bytes = File(imageFile!.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    postRequest(context, img64, DeviceName);
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
    if (error.message == "Session expired!") {
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) =>
                dashboard_screen(selectedPage: 0)));
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

  void callstoast(String polenumber) {
    Fluttertoast.showToast(
        msg: polenumber,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
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

  void noInternetToast(String msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  Future<http.Response> postRequest(context, imageFile, DeviceName) async {
    var response;
    try {
      pr.show();
      Uri myUri = Uri.parse(localAPICall);
      // Uri myUri = Uri.parse(serverUrl);

      Map data = {'img': imageFile, 'name': DeviceName};
      //encode Map to JSON
      var body = json.encode(data);

      response = await http.post(myUri,
          headers: {"Content-Type": "application/json"}, body: body);
      print("${response.statusCode}");
      pr.hide();
      if (response.statusCode.toString() == "200") {
        Fluttertoast.showToast(
            msg: app_dev_repl_comp,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) =>
                dashboard_screen(selectedPage: 0)));
      } else {}
      return response;
    } catch (e) {
      /*FlutterLogs.logInfo("CCMS_replacement_page", "CCMS_remove",
          "Passing Image Base64 to Local Basket");*/
      pr.hide();
      Fluttertoast.showToast(
          msg: app_dev_img_upload_error,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
      return response;
    }
  }

  void onGpsAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: const Text("Location not available"),
              content: const Text(
                  'Please make sure you enable location and try again'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text("Ok"),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                )
              ],
            )
    );
  }

}
