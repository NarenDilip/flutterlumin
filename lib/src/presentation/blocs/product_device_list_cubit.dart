import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/domain/repository/device_repository.dart';
import 'package:flutterlumin/src/presentation/blocs/device_state.dart';

class ProductDeviceCubit extends Cubit<DevicesState> {
  final DeviceRepository repository;

  ProductDeviceCubit(this.repository) : super(InitialState());

  void getILMDevices(String productSearchString) async {
    try {
      emit(LoadingState());
      final deviceResponse =
          await repository.fetchILMDevices(productSearchString);
      emit(LoadedState(deviceResponse));
    } catch (e) {
      emit(ErrorState());
    }
  }

  Future<void> getCCMSDevices(
      String productSearchString, List<String> relationDevices) async {
    try {
      emit(LoadingState());
      final deviceResponse = await repository.fetchCCMSDevices(
          productSearchString, relationDevices);
      emit(LoadedState(deviceResponse));
    } catch (e) {
      emit(ErrorState());
    }
  }

  Future<void> getPoleDevices(
      String productSearchString, List<String> relationDevices) async {
    try {
      emit(LoadingState());
      final deviceResponse = await repository.fetchPoleDevices(
          productSearchString, relationDevices);
      emit(LoadedState(deviceResponse));
    } catch (e) {
      emit(ErrorState());
    }
  }
}
