import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/data/model/device.dart';
import 'package:flutterlumin/src/domain/repository/device_detail_repository.dart';
import 'package:flutterlumin/src/presentation/blocs/device_info_state.dart';
import 'package:intl/intl.dart';
import 'package:flutterlumin/src/constants/const.dart';
import '../../constants/const.dart';
import '../../utils/utility.dart';

class DeviceDetailCubit extends Cubit<DeviceInfoState> {
  final DeviceDetailRepository repository;

  DeviceDetailCubit(this.repository) : super(InitialState());

  Future<void> getDeviceDetail(ProductDevice device, BuildContext context) async {
    try {
      emit(LoadingState());
      final deviceResponse =
          await repository.fetchDeviceInformation(device, context);
      if (deviceResponse.deviceTimeStamp != null) {
        var dt = DateTime.fromMillisecondsSinceEpoch(
            int.parse(deviceResponse.deviceTimeStamp));
        deviceResponse.deviceTimeStamp =
            DateFormat('MMM dd, yyyy hh:mm a').format(dt).toString();
      }
      emit(LoadedState(deviceResponse));
    } catch (e) {
      emit(ErrorState(""));
    }
  }

  Future<void> requestLiveData(BuildContext context) async {
    emit(LoadingState());
    Utility.isConnected().then((value) async {
      if (value) {
        final response = await repository.getLiveRPCCall(context);
      } else {
        emit(ErrorState(no_network));
      }
    });
  }

  Future<void> updateDeviceStatus(
      BuildContext context, bool status, ProductDevice productDevice) async {
    Utility.isConnected().then((value) async {
      if (value) {
        final response = await repository.changeDeviceStatus(context, status, productDevice);
        if (response["lamp"].toString() == "1") {
          emit(SuccessState(onMessage));
        } else if (response["lamp"].toString() == "0") {
          emit(SuccessState(offMessage));
        }
      } else {
        emit(ErrorState(no_network));
      }
    });
  }

  Future<void> initiateMCBTrip(BuildContext context, int status) async {
    emit(LoadingState());
    Utility.isConnected().then((value) async {
      if (value) {
        final response = await repository.initiateMCBTrip(context, status);
      } else {
        emit(ErrorState(no_network));
      }
    });
  }
}
