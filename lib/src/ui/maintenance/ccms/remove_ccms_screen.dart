import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/device_models.dart';
import 'package:flutterlumin/src/thingsboard/model/entity_group_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/entity_group_id.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../localdb/db_helper.dart';
import '../../../localdb/model/region_model.dart';
import '../../../thingsboard/model/model.dart';
import '../../dashboard/dashboard_screen.dart';
import '../ilm/ilm_maintenance_screen.dart';
import 'ccms_maintenance_screen.dart';

// CCMS Maintenance remove device screen, it will check the selected device
// is present in server, it will collect the details of the device, user need
// to remove the selected device.on the removal process will move the device to
// forrepair folder and revert back to maintenance page

class replacementccms extends StatefulWidget {
  const replacementccms() : super();

  @override
  replacementccmsState createState() => replacementccmsState();
}

class replacementccmsState extends State<replacementccms> {
  String DeviceName = "0";
  var imageFile;
  String faultyStatus = "0";
  late ProgressDialog pr;

  var _myLogFileName = "Luminator2.0_LogFile";
  var logStatus = '';
  static Completer _completer = new Completer<String>();

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DeviceName = prefs.getString('deviceName').toString();
    faultyStatus = prefs.getString("faultyStatus").toString();

    setState(() {
      DeviceName = DeviceName;
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
    Size size = MediaQuery
        .of(context)
        .size;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;

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
              builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
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
                          child: const Text(app_com_replace,
                              style: TextStyle(
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
                          onPressed: () {
                            if (imageFile != null) {
                              pr.show();
                              callReplacementComplete(
                                  context, imageFile, DeviceName);
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
                          }))
                ]))));
  }

  void _openCamera(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 480,
        maxWidth: 640,
        imageQuality: 25,
        preferredCameraDevice: CameraDevice.rear);
    setState(() {
      if(pickedFile != null) {
        imageFile = pickedFile;
      }else{
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CCMSMaintenanceScreen()),
        );
      }
    });
  }

  Future<void> callReplacementComplete(context, imageFile, DeviceName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String deviceID = prefs.getString('deviceId').toString();
    String deviceName = prefs.getString('deviceName').toString();
    faultyStatus = prefs.getString("faultyStatus").toString();
    String SelectedRegion = prefs.getString('SelectedRegion').toString();
    String FirmwareVersion = prefs.getString("firmwareVersion").toString();

    var versionCompatability = false;

    var DevicecurrentFolderName = "";
    var DevicemoveFolderName = "";

    Utility.isConnected().then((value) async {
      if (value) {
        pr.show();
        try {
          var tbClient = ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
          tbClient.smart_init();

          Device response;
          response = (await tbClient
              .getDeviceService()
              .getTenantDevice(deviceName)) as Device;

          if (imageFile != null) {
            if (response != null) {
              DBHelper dbHelper = DBHelper();
              var regionid;
              List<Region> regiondetails =
              await dbHelper.region_name_regionbasedDetails(SelectedRegion);
              if (regiondetails.length != "0") {
                regionid = regiondetails.first.regionid;
              }

              // try {
              //   List<String> myfirmList = [];
              //   myfirmList.add("firmware_versions");
              //
              //   List<AttributeKvEntry> faultresponser;
              //
              //   faultresponser = (await tbClient
              //       .getAttributeService()
              //       .getFirmAttributeKvEntries(regionid, myfirmList));
              //
              //   if (faultresponser.length != 0) {
              //     var firmwaredetails =
              //     faultresponser.first.getValue().toString();
              //     final decoded = jsonDecode(firmwaredetails) as Map;
              //     var firmware_versions = decoded['firmware_version'];
              //
              //     if (firmware_versions.toString().contains(FirmwareVersion)) {
                    versionCompatability = true;
              //     } else {
              //       versionCompatability = false;
              //     }
              //   }
              // } catch (e) {
              //   var message = toThingsboardError(e, context);
              // }

              if (versionCompatability == true) {
                if (faultyStatus == "2") {
                  Map data = {'faulty': "true"};
                  var saveAttributes = await tbClient
                      .getAttributeService()
                      .saveDeviceAttributes(
                      response.id!.id!, "SERVER_SCOPE", data);
                }

                var relationDetails = await tbClient
                    .getEntityRelationService()
                    .findInfoByTo(response.id!);

                List<EntityGroupInfo> entitygroups;
                entitygroups = await tbClient
                    .getEntityGroupService()
                    .getEntityGroupsByFolderType();

                if (entitygroups != null) {
                  for (int i = 0; i < entitygroups.length; i++) {
                    if (entitygroups
                        .elementAt(i)
                        .name ==
                        FlavorConfig.instance.variables["CCMSserviceFolderName"]) {
                      DevicemoveFolderName =
                          entitygroups
                              .elementAt(i)
                              .id!
                              .id!
                              .toString();
                    }
                  }

                  List<EntityGroupId> currentdeviceresponse;
                  currentdeviceresponse = await tbClient
                      .getEntityGroupService()
                      .getEntityGroupsForFolderEntity(response.id!.id!);

                  if (currentdeviceresponse != null) {
                    if (currentdeviceresponse.last.id
                        .toString()
                        .isNotEmpty) {
                      var firstdetails = await tbClient
                          .getEntityGroupService()
                          .getEntityGroup(currentdeviceresponse.first.id!);
                      if (firstdetails!.name.toString() != "All") {
                        DevicecurrentFolderName =
                        currentdeviceresponse.first.id!;
                      }
                      var seconddetails = await tbClient
                          .getEntityGroupService()
                          .getEntityGroup(currentdeviceresponse.last.id!);
                      if (seconddetails!.name.toString() != "All") {
                        DevicecurrentFolderName =
                        currentdeviceresponse.last.id!;
                      }

                      var relation_response = await tbClient
                          .getEntityRelationService()
                          .deleteDeviceRelation(
                          relationDetails
                              .elementAt(0)
                              .from
                              .id!,
                          response.id!.id!);

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

                      final bytes = File(imageFile!.path).readAsBytesSync();
                      String img64 = base64Encode(bytes);

                      postRequest(context, img64, DeviceName);
                      pr.hide();
                    } else {
                      /*FlutterLogs.logInfo("CCMS_replacement_page", "CCMS_remove", "Device Not Found Exception");*/
                      pr.hide();
                      calltoast(
                          app_dev_nfound_one + DeviceName + app_dev_nfound_two);

                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              dashboard_screen(selectedPage: 0)));
                    }
                  } else {
                    /*FlutterLogs.logInfo("CCMS_replacement_page", "CCMS_remove",
                        "No Device Groups Found");*/
                    pr.hide();
                    calltoast(app_dev_group_nfud);

                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
                  }
                } else {
                  pr.hide();
                  calltoast(deviceName);

                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
                }
              } else {
                /*FlutterLogs.logInfo("CCMS_replacement_page", "CCMS_remove",
                    "Not authorized to Install");*/
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
                    builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
              }
            } else {
              pr.hide();
              calltoast(deviceName);

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
            }
          } else {
            /*FlutterLogs.logInfo("CCMS_replacement_page", "CCMS_remove",
                "Image Base64 Exception");*/
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
          /*FlutterLogs.logInfo("ccms_replacement_page", "ccms_remove",
              "CCMS Replacement Device Exception Occurs");*/
          pr.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callReplacementComplete(context, imageFile, DeviceName);
            }
          } else {
            calltoast(deviceName);
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
          }
        }
      }
    });
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

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
    if (error.message == "Session expired!") {
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
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


  Future<http.Response> postRequest(context, imageFile, DeviceName) async {
    var response;
    try {
      pr.show();
      // Uri myUri = Uri.parse(serverUrl);
      Uri myUri = Uri.parse(localAPICall);

      Map data = {'img': imageFile, 'name': DeviceName};
      //encode Map to JSON
      var body = json.encode(data);

      response = await http.post(myUri,
          headers: {"Content-Type": "application/json"}, body: body);
      print("${response.statusCode}");
      pr.hide();
      if (response.statusCode.toString() == "200") {
        Fluttertoast.showToast(
            msg: "Device Replacement Completed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => dashboard_screen(selectedPage: 0)));
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
}
