import 'package:equatable/equatable.dart';
import 'package:flutterlumin/src/data/model/device_response.dart';

abstract class DevicesState extends Equatable {}

class InitialState extends DevicesState {
  @override
  List<Object> get props => [];
}

class LoadingState extends DevicesState {
  @override
  List<Object> get props => [];
}

class LoadedState extends DevicesState {
  LoadedState(this.deviceResponse);

  final DeviceResponse deviceResponse;

  @override
  List<Object> get props => [deviceResponse];
}

class ErrorState extends DevicesState {
  @override
  List<Object> get props => [];
}