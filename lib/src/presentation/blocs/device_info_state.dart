import 'package:equatable/equatable.dart';
import 'package:flutterlumin/src/data/model/device.dart';
import 'package:flutterlumin/src/data/model/device_response.dart';

abstract class DeviceInfoState extends Equatable {}

class InitialState extends DeviceInfoState {
  @override
  List<Object> get props => [];
}

class LoadingState extends DeviceInfoState {
  @override
  List<Object> get props => [];
}

class ProgressState extends DeviceInfoState {
  @override
  List<Object> get props => [];
}

class LoadedState extends DeviceInfoState {
  LoadedState(this.deviceResponse);

  final ProductDevice deviceResponse;

  @override
  List<Object> get props => [deviceResponse];
}

class SuccessState extends DeviceInfoState {
  SuccessState(this.message);
  final String message;

  @override
  List<Object> get props => [];
}

class ErrorState extends DeviceInfoState {
  ErrorState(this.errorMessage);
  final String errorMessage;

  @override
  List<Object> get props => [];
}