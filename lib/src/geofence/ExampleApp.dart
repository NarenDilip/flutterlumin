import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poly_geofence_service/models/lat_lng.dart';
import 'package:poly_geofence_service/models/poly_geofence.dart';
import 'package:poly_geofence_service/poly_geofence_service.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _streamController = StreamController<PolyGeofence>();

  // final List<LatLng> _areaGreen = [
  //   const LatLng(11.140737304684361,76.94101095199585),
  //   const LatLng(11.140737304684361,76.94142937660217),
  //   const LatLng(11.140889941168785,76.94142937660217),
  //   const LatLng(11.140889941168785,76.94101095199585),
  //   const LatLng(11.140737304684361,76.94101095199585)
  // ];

  // Create a [PolyGeofenceService] instance and set options.
  final _polyGeofenceService = PolyGeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      allowMockLocations: false,
      printDevLog: false);

  // Create a [PolyGeofence] list.
  final _polyGeofenceList = <PolyGeofence>[
    PolyGeofence(
      id: 'Office_Address',
      data: {
        'address': 'Coimbatore',
        'about': 'Schnell Energy Equipments,Coimbatore.',
      },
      polygon: <LatLng>[
        const LatLng(11.140339923116493, 76.94095999002457),
        const LatLng(11.140339923116493, 76.94147363305092),
        const LatLng(11.140964943549918, 76.94147363305092),
        const LatLng(11.140964943549918, 76.94095999002457),
        const LatLng(11.140339923116493, 76.94095999002457)
      ],
    ),
  ];

  // This function is to be called when the geofence status is changed.
  Future<void> _onPolyGeofenceStatusChanged(PolyGeofence polyGeofence,
      PolyGeofenceStatus polyGeofenceStatus, Location location) async {
    print('polyGeofence: ${polyGeofence.toJson()}');
    print('polyGeofenceStatus: ${polyGeofenceStatus.toString()}');
    _streamController.sink.add(polyGeofence);
  }

  // This function is to be called when the location has changed.
  void _onLocationChanged(Location location) {
    print('location: ${location.toJson()}');

    for(int i=0;i<_polyGeofenceList[0].polygon.length;i++) {
      var insideArea = _checkIfValidMarker(
          LatLng(location.latitude, location.longitude),
          _polyGeofenceList[i].polygon);
      print('location check: ${insideArea}');
    }
  }

  // This function is to be called when a location services status change occurs
  // since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }
    print('ErrorCode: $errorCode');
  }

  bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }
    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _polyGeofenceService.start();
      _polyGeofenceService
          .addPolyGeofenceStatusChangeListener(_onPolyGeofenceStatusChanged);
      _polyGeofenceService.addLocationChangeListener(_onLocationChanged);
      _polyGeofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      _polyGeofenceService.addStreamErrorListener(_onError);
      _polyGeofenceService.start(_polyGeofenceList).catchError(_onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // A widget used when you want to start a foreground task when trying to minimize or close the app.
      // Declare on top of the [Scaffold] widget.
      home: WillStartForegroundTask(
        onWillStart: () async {
          // You can add a foreground task start condition.
          return _polyGeofenceService.isRunningService;
        },
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription:
              'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          isSticky: false,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Poly Geofence Service'),
            centerTitle: true,
          ),
          body: _buildContentView(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Widget _buildContentView() {
    return StreamBuilder<PolyGeofence>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        final content = snapshot.data?.toJson().toString() ?? '';

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          children: [
            Text('•\t\tPolyGeofence (updated: $updatedDateTime)'),
            const SizedBox(height: 10.0),
            Text(content),
          ],
        );
      },
    );
  }
}
