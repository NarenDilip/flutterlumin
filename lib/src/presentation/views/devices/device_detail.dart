import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/data/model/device.dart';
import 'package:flutterlumin/src/domain/repository/device_detail_repository.dart';
import 'package:flutterlumin/src/presentation/blocs/device_detail_cubit.dart';
import 'package:flutterlumin/src/presentation/blocs/device_info_state.dart';
import 'package:flutterlumin/src/presentation/views/devices/device_detail_view.dart';
import 'package:latlong/latlong.dart';

class DeviceDetailDataView extends StatefulWidget {
  const DeviceDetailDataView({Key? key, required this.productDevice}) : super(key: key);
  final ProductDevice productDevice;
  @override
  _DeviceDetailState createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<DeviceDetailDataView> {
  late TextEditingController searchInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body:  BlocProvider<DeviceDetailCubit>(
        create: (context) => DeviceDetailCubit(DeviceDetailRepository()),
        child: DeviceDetailView(productDevice: widget.productDevice,))
    );
  }


}
