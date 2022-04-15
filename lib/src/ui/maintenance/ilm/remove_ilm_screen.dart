import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/thingsboard/model/device_models.dart';
import 'package:flutterlumin/src/thingsboard/model/entity_group_models.dart';
import 'package:flutterlumin/src/thingsboard/model/id/entity_group_id.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/components/rounded_button.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../localdb/db_helper.dart';
import '../../../localdb/model/region_model.dart';
import '../../../thingsboard/model/model.dart';
import '../../dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';

import 'ilm_maintenance_screen.dart';

class replacementilm extends StatefulWidget {
  const replacementilm() : super();

  @override
  replacementilmState createState() => replacementilmState();
}

class replacementilmState extends State<replacementilm> {
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
        // Contains file name of zip
        // FlutterLogs.logInfo(
        //     _tag, "setUpLogs", "logsExported: ${call.arguments.toString()}");

        setLogsStatus(
            status: "logsExported: ${call.arguments.toString()}", append: true);

        // Notify Future with value
        _completer.complete(call.arguments.toString());
      } else if (call.method == 'logsPrinted') {
        // FlutterLogs.logInfo(
        //     _tag, "setUpLogs", "logsPrinted: ${call.arguments.toString()}");

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
      message: 'Please wait ..',
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
              builder: (BuildContext context) => dashboard_screen()));
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
                          child: const Text("Complete Replacement",
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
                              FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
                              pr.hide();
                              Fluttertoast.showToast(
                                  msg:
                                      "Image not captured successfully! Please try again!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  fontSize: 16.0);
                            }
                          }))
                  // rounded_button(
                  //   text: "Complete Replacement",
                  //   color: Colors.green,
                  //   press: () {
                  //     callReplacementComplete(context, imageFile, DeviceName);
                  //   },
                  //   key: null,
                  // ),
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
      imageFile = pickedFile;
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
        // Utility.progressDialog(context);
        pr.show();
        try {
          var tbClient = ThingsboardClient(serverUrl);
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
                  await dbHelper.region_name_regionbasedDetails(SelectedRegion)
                      as List<Region>;
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
              //           .getAttributeService()
              //           .getFirmAttributeKvEntries(regionid, myfirmList))
              //       as List<AttributeKvEntry>;
              //
              //   if (faultresponser.length != 0) {
              //     var firmwaredetails =
              //         faultresponser.first.getValue().toString();
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
              //   FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
              //   var message = toThingsboardError(e, context);
              // }

              if (versionCompatability == true) {
                // if (faultyStatus == "2") {
                //   Map data = {'faulty': "true"};
                //   var saveAttributes = await tbClient
                //       .getAttributeService()
                //       .saveDeviceAttributes(
                //           response.id!.id!, "SERVER_SCOPE", data);
                // }

                var relationDetails = await tbClient
                    .getEntityRelationService()
                    .findInfoByTo(response.id!);

                List<EntityGroupInfo> entitygroups;
                entitygroups = await tbClient
                    .getEntityGroupService()
                    .getEntityGroupsByFolderType();

                if (entitygroups != null) {
                  for (int i = 0; i < entitygroups.length; i++) {
                    if (entitygroups.elementAt(i).name ==
                        ILMserviceFolderName) {
                      DevicemoveFolderName =
                          entitygroups.elementAt(i).id!.id!.toString();
                    }
                  }

                  List<EntityGroupId> currentdeviceresponse;
                  currentdeviceresponse = await tbClient
                      .getEntityGroupService()
                      .getEntityGroupsForFolderEntity(response.id!.id!);

                  if (currentdeviceresponse != null) {
                    if (currentdeviceresponse.last.id.toString().isNotEmpty) {
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
                              relationDetails.elementAt(0).from.id!,
                              response.id!.id!);

                      // DevicecurrentFolderName =
                      //     currentdeviceresponse.last.id.toString();

                      List<String> myList = [];
                      myList.add(response.id!.id!);

                      try {
                        var remove_response = await tbClient
                            .getEntityGroupService()
                            .removeEntitiesFromEntityGroup(
                                DevicecurrentFolderName, myList);
                      } catch (e) {    FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");}
                      try {
                        var add_response = await tbClient
                            .getEntityGroupService()
                            .addEntitiesToEntityGroup(
                                DevicemoveFolderName, myList);
                      } catch (e) {    FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");}

                      final bytes = File(imageFile!.path).readAsBytesSync();
                      String img64 = base64Encode(bytes);

                      postRequest(context, img64, DeviceName);
                      pr.hide();
                    } else {
                      FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
                      pr.hide();
                      calltoast("Device is not Found");

                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              dashboard_screen()));
                    }
                  } else {
                    FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
                    pr.hide();
                    calltoast("Device EntityGroup Not Found");

                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => dashboard_screen()));
                  }
                } else {
                  FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
                  pr.hide();
                  calltoast(deviceName);

                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => dashboard_screen()));
                }
              } else {
                FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
                pr.hide();
                Fluttertoast.showToast(
                    msg:
                        "Device is not compatible with this Project"+ SelectedRegion + "Kindly try another one.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);

                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => dashboard_screen()));
              }
            } else {
              FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
              pr.hide();
              calltoast(deviceName);

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => dashboard_screen()));
            }
          } else {
            FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
            pr.hide();
            Fluttertoast.showToast(
                msg:
                    "Image not captured successfully! Please try again",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        } catch (e) {
          FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
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
                builder: (BuildContext context) => dashboard_screen()));
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
            builder: (BuildContext context) => dashboard_screen()));
      } else {}
      return response;
    } catch (e) {
      FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
      pr.hide();
      Fluttertoast.showToast(
          msg: "Device Replacement Image Upload Error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
      return response;
    }
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
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