import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/domain/repository/device_detail_repository.dart';
import 'package:flutterlumin/src/presentation/blocs/device_info_state.dart';
import 'package:intl/intl.dart';

class DeviceDetailCubit extends Cubit<DeviceInfoState> {
  final DeviceDetailRepository repository;

  DeviceDetailCubit(this.repository) : super(InitialState());

  Future<void> getDeviceDetail(String device, BuildContext context) async {
    try {
      emit(LoadingState());
      final deviceResponse =
          await repository.fetchDeviceInformation(device, context);
      if(deviceResponse.deviceTimeStamp != null){
       var dt= DateTime.fromMillisecondsSinceEpoch(
            int.parse(deviceResponse.deviceTimeStamp));
        deviceResponse.deviceTimeStamp =
            DateFormat('MMM dd, yyyy hh:mm a').format(dt).toString();
      }
      emit(LoadedState(deviceResponse));
    } catch (e) {
      emit(ErrorState());
    }
  }
}
