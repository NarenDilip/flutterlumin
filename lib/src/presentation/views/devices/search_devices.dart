import 'package:flutter/material.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/blocs/device_state.dart';
import 'package:flutterlumin/src/presentation/blocs/search_device_cubit.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/app_bar_view.dart';
import 'package:flutterlumin/src/presentation/views/devices/device_list_view.dart';
import 'package:flutterlumin/src/presentation/widgets/search_input_field.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchDevicesView extends StatefulWidget {
  const SearchDevicesView({Key? key}) : super(key: key);

  @override
  _SearchDevicesState createState() => _SearchDevicesState();
}

class _SearchDevicesState extends State<SearchDevicesView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController searchInputController = TextEditingController();
  final deviceTypeController = ValueNotifier('ilm');

  @override
  void initState() {
    super.initState();
    searchProduct("");
    deviceTypeController.addListener(() {
      searchProduct(deviceTypeController.value);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: Column(
        children: <Widget>[
          const AppBarWidget(
            title: "Devices",
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 20),
            child: Column(
              children: <Widget>[
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Flexible(
                                child: SearchInputField(
                              searchInputController: searchInputController,
                              onSearchButtonClicked: () {
                                deviceTypeController.value = "all";
                                searchProduct("");
                              },
                            )),
                          ],
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        AdvancedSegment(
                          controller: deviceTypeController,
                          // AdvancedSegmentController
                          segments: const {
                            // Map<String, String>
                            'all': 'All',
                            ilmDeviceType: 'ILM',
                            ccmsDeviceType: 'CCMS',
                            gatewayDeviceType: 'Gateway',
                          },
                        ),
                      ],
                    )),
              ],
            ),
          ),
          BlocBuilder<SearchDeviceCubit, DevicesState>(
            builder: (context, state) {
              if (state is LoadingState) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ErrorState) {
                return Text(
                  state.errorMessage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    color: Colors.red,
                  ),
                );
              } else if (state is LoadedState) {
                final deviceResponse = state.deviceResponse;
                if (deviceResponse.errorMessage != "") {
                  return Text(
                    deviceResponse.errorMessage,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      color: Colors.red,
                    ),
                  );
                } else {
                  return DeviceListView(devices: deviceResponse.deviceList);
                }
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  void searchProduct(String deviceType) {
    final productDeviceCubit = BlocProvider.of<SearchDeviceCubit>(context);
    productDeviceCubit.getDevices(
        searchInputController.text, deviceType, context);
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
