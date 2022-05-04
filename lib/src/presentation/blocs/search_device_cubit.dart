import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/domain/repository/device_repository.dart';
import 'package:flutterlumin/src/presentation/blocs/device_state.dart';

import '../../utils/utility.dart';

class ProductDeviceCubit extends Cubit<DevicesState> {
  final DeviceRepository repository;

  ProductDeviceCubit(this.repository) : super(InitialState());

  Future<void> getDevices(String productSearchString, String productType,
      BuildContext context) async {
    try {
      emit(LoadingState());
      Utility.isConnected().then((value) async {
        if (value) {
          final deviceResponse = await repository.fetchDevices(
              productSearchString, productType, context);
          emit(LoadedState(deviceResponse));
        } else {
          emit(ErrorState(no_network));
        }
      });
    } catch (e) {
      emit(ErrorState(""));
    }
  }

  Future<void> getPoleDevices(String productSearchString) async {
    try {
      emit(LoadingState());
      final deviceResponse =
          await repository.fetchPoleDevices(productSearchString);
      emit(LoadedState(deviceResponse));
    } catch (e) {
      emit(ErrorState(""));
    }
  }
}
