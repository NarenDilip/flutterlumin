import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:flutterlumin/src/utils/responsive.dart';

class Utility {

  var logStatus = '';
  static final Completer _completer = Completer<String>();
  var _tag = "DashboardPage";
  var _myLogFileName = "Luminator2.0_LogFile";

  static Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
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
  }

  // static void progressDialog(BuildContext context) {
  //   showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (BuildContext context) {
  //         return const Center(
  //           child: CircularProgressIndicator(),
  //         );
  //       });
  // }

  static double getResponsiveWidth(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return 0.2;
    } else if (Responsive.isTablet(context)) {
      return 0.5;
    } else {
      return 0.9;
    }
  }
}
