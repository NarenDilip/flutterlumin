// @dart=2.9

// Main app class is used for development and production release

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/ui/splash_screen.dart';

Future<void> main() async {
  FlavorConfig(
    name: "PROD",
    color: Colors.red,
    location: BannerLocation.topStart,
    variables: {
      "ILMDeviceInstallationFolder": ILMDeviceInstallationFolder,
      "ILMserviceFolderName": ILMserviceFolderName,
      "CCMSserviceFolderName": CCMSserviceFolderName,
      "GWserviceFolderName": GWserviceFolderName,
      "baseUrl": prodBaseUrl,
    },
  );

  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // FirebaseCrashlytics.instance.crash();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Luminator',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: splash_screen(),
        ));
  }
}
