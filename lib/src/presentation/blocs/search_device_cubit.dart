import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/domain/repository/device_repository.dart';
import 'package:flutterlumin/src/presentation/blocs/device_state.dart';

class ProductDeviceCubit extends Cubit<DevicesState> {
  final DeviceRepository repository;

  ProductDeviceCubit(this.repository) : super(InitialState());

  Future<void> searchProduct(String productSearchString, String productType) async {
    if(productType != "pole"){
      getDevices(productSearchString, productType);
    }else{
      getPoleDevices(productSearchString);
    }
  }

  Future<void> getDevices(String productSearchString, String productType) async {
    try {
      emit(LoadingState());
      final deviceResponse =
          await repository.fetchDevices(productSearchString, productType);
      emit(LoadedState(deviceResponse));
    } catch (e) {
      emit(ErrorState());
    }
  }

  Future<void> getPoleDevices(
      String productSearchString) async {
    try {
      emit(LoadingState());
      final deviceResponse = await repository.fetchPoleDevices(
          productSearchString);
      emit(LoadedState(deviceResponse));
    } catch (e) {
      emit(ErrorState());
    }
  }
}
