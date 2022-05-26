import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/domain/repository/device_repository.dart';
import 'package:flutterlumin/src/domain/repository/projects_repository.dart';
import 'package:flutterlumin/src/presentation/blocs/projects_detail_cubit.dart';
import 'package:flutterlumin/src/presentation/blocs/search_device_cubit.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/projects_dashboard_view.dart';
import 'package:flutterlumin/src/presentation/views/devices/search_devices.dart';
import 'package:flutterlumin/src/presentation/views/settings/settings_view.dart';
import 'package:flutterlumin/src/ui/map/map_view_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/model/device.dart';
import '../../../thingsboard/error/thingsboard_error.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import '../../../thingsboard/model/model.dart';
import '../../../thingsboard/thingsboard_client_base.dart';
import '../../../ui/installation/ccms/ccms_install_cam_screen.dart';
import '../../../ui/installation/gateway/gateway_install_cam_screen.dart';
import '../../../ui/installation/ilm/ilm_install_cam_screen.dart';
import '../../../ui/qr_scanner/qr_scanner.dart';
import '../../../utils/utility.dart';
import '../devices/device_detail_view.dart';
import '../location/location_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardAppState createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardView> {
  var _currentIndex = 0;
  late PageController _pageController;
  List<Widget> tabPages = [
    BlocProvider<ProjectDetailCubit>(
      create: (context) => ProjectDetailCubit(ProjectsRepository()),
      child: const ProjectDashboard(),
    ),
    BlocProvider<SearchDeviceCubit>(
      create: (context) => SearchDeviceCubit(DeviceRepository()),
      child: const SearchDevicesView(),
    ),
    DeviceLocationView(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          showExitPopup(context);
          return false;
        },
        child: Scaffold(
          backgroundColor: lightGrey,
          bottomNavigationBar: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) => onPageChanged(i),
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home),
                title: const Text("Home"),
                selectedColor: kPrimaryColor,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.add_chart),
                title: const Text("Search"),
                selectedColor: kPrimaryColor,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.location_searching),
                title: const Text("Locate"),
                selectedColor: kPrimaryColor,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.settings),
                title: const Text("Settings"),
                selectedColor: kPrimaryColor,
              ),
            ],
          ),
          body: PageView(
            children: tabPages,
            onPageChanged: onPageChanged,
            controller: _pageController,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: kPrimaryColor,
            child: const Icon(Icons.qr_code),
            onPressed: () {
              deviceFetcher(context);
            },
          ),
        ));
  }

  void onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
      _pageController.jumpToPage(page);
    });
  }

  Future<bool> showExitPopup(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Luminator",
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Do you want to exit?"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            exit(0);
                          },
                          child: const Text("Yes"),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red.shade800),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("No",
                                style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                          ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> deviceFetcher(BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => QRScreen()),
                (route) => true).then((value) async {
          if (value != null) {
            // if (value.toString().length == 6) {
            fetchGWDeviceDetails(value, context);
          } else {
            Fluttertoast.showToast(
                msg: device_qr_nt_found,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        });
      } else {
        // FlutterLogs.logInfo("Dashboard_Page", "Dashboard", "No Network");
        Fluttertoast.showToast(
            msg: no_network,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    });
  }


  @override
  Future<Device?> fetchGWDeviceDetails(
      String deviceName, BuildContext context) async {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          Device response;
          String? SelectedRegion;
          var tbClient =
          ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
          tbClient.smart_init();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          SelectedRegion = prefs.getString("SelectedRegion").toString();
          if (SelectedRegion.toString() != "Region") {
            if (SelectedRegion.toString() != "null") {
              response = (await tbClient
                  .getDeviceService()
                  .getTenantDevice(deviceName)) as Device;
              if (response.toString().isNotEmpty) {
                prefs.setString('deviceId', response.id!.id!.toString());
                prefs.setString('DeviceDetails', response.id!.id!.toString());
                prefs.setString('deviceName', deviceName);
                var relationDetails = await tbClient
                    .getEntityRelationService()
                    .findInfoByTo(response.id!);
                List<AttributeKvEntry> responserse;
                prefs.setString('geoFence', "false");
                if (relationDetails.length.toString() == "0") {
                  if (response.type == ilmDeviceType) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ilmcaminstall()),
                    );
                  } else if (response.type == ccmsDeviceType) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ccmscaminstall()),
                    );
                  } else if (response.type == gatewayDeviceType) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const gwcaminstall()),
                    );
                  }
                } else {
                  List<String> firstmyList = [];
                  firstmyList.add("lmp");
                  try {
                    List<TsKvEntry> faultresponser;
                    faultresponser = await tbClient
                        .getAttributeService()
                        .getselectedLatestTimeseries(response.id!.id!, "lmp");
                    if (faultresponser.isNotEmpty) {
                      prefs.setString('faultyStatus',
                          faultresponser.first.getValue().toString());
                    }
                  } catch (e) {
                    var message = toThingsboardError(e, context);
                    // FlutterLogs.logInfo("Luminator 2.0", "dashboard_page", "");
                  }
                  List<String> myList = [];
                  myList.add("active");
                  List<AttributeKvEntry> atresponser;
                  atresponser = (await tbClient
                      .getAttributeService()
                      .getAttributeKvEntries(response.id!, myList));
                  if (atresponser.isNotEmpty) {
                    prefs.setString('deviceStatus',
                        atresponser.first.getValue().toString());
                    prefs.setString('devicetimeStamp',
                        atresponser.elementAt(0).getLastUpdateTs().toString());
                    try {
                      List<String> myLister = [];
                      myLister.add("landmark");
                      responserse = (await tbClient
                          .getAttributeService()
                          .getAttributeKvEntries(response.id!, myLister));
                      if (responserse.isNotEmpty) {
                        prefs.setString('location',
                            responserse.first.getValue().toString());
                        prefs.setString('deviceName', deviceName);
                      }
                      // myLister.add("location");
                      List<String> LampmyList = [];
                      LampmyList.add("lampWatts");
                      List<AttributeKvEntry> lampatresponser;
                      lampatresponser = (await tbClient
                          .getAttributeService()
                          .getAttributeKvEntries(response.id!, LampmyList));
                      if (lampatresponser.isNotEmpty) {
                        prefs.setString('deviceWatts',
                            lampatresponser.first.getValue().toString());
                      }
                      List<String> myList = [];
                      myList.add("lattitude");
                      myList.add("longitude");
                      List<BaseAttributeKvEntry> responser;
                      responser = (await tbClient
                          .getAttributeService()
                          .getAttributeKvEntries(response.id!, myList))
                      as List<BaseAttributeKvEntry>;
                      prefs.setString('deviceLatitude',
                          responser.first.kv.getValue().toString());
                      prefs.setString('deviceLongitude',
                          responser.last.kv.getValue().toString());
                    } catch (e) {
                      var message = toThingsboardError(e, context);
                    }
                    if (response.type == ilmDeviceType ||
                        response.type == ccmsDeviceType ||
                        response.type == gatewayDeviceType) {
                      ProductDevice productDevice = ProductDevice();
                      productDevice.name = deviceName;
                      productDevice.type = response.type;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DeviceDetailView(productDevice: productDevice,
                                  )));
                    }
                  } else {
                    // FlutterLogs.logInfo("Dashboard_Page", "Dashboard",
                    //     "No attributes key found");
                    refreshPage(context);
                    //"" No Active attribute found
                  }
                }
                /*} else {
                  FlutterLogs.logInfo(
                      "Dashboard_Page", "Dashboard", "No version attributes key found");
                  pr.hide();
                  refreshPage(context);
                  //"" No Firmware Device Found
                }*/
              } else {
                // FlutterLogs.logInfo(
                //     "Dashboard_Page", "Dashboard", "No Device Details Found");
                refreshPage(context);
                //"" No Device Found
              }
            } else {
              Fluttertoast.showToast(
                  msg: device_selec_regions,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
              refreshPage(context);
              //"" No Device Found
            }
          } else {
            Fluttertoast.showToast(
                msg: device_selec_regions,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
            refreshPage(context);
            //"" No Device Found
          }
        } catch (e) {
          // FirebaseCrashlytics.instance.crash();
          // FlutterLogs.logInfo(
          //     "Dashboard_Page", "Dashboard", "Device Details Fetch Exception");
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              fetchGWDeviceDetails(deviceName, context);
            }
          } else {
            refreshPage(context);
            Fluttertoast.showToast(
                msg: device_toast_msg + deviceName + device_toast_notfound,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        }
      }
    });
  }

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void refreshPage(context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => DashboardView()));
  }

  Future<ThingsboardError> toThingsboardError(error, context,
      [StackTrace? stackTrace]) async {
    ThingsboardError? tbError;
    // FlutterLogs.logInfo("Dashboard_Page", "Dashboard",
    //     "Global Error " + error.message.toString());
    if (error.message == "Session expired!") {
      var status = loginThingsboard.callThingsboardLogin(context);
      if (status == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => DashboardView()));
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

