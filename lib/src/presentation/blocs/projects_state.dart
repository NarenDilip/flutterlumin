import 'package:equatable/equatable.dart';
import 'package:flutterlumin/src/data/model/device.dart';
import 'package:flutterlumin/src/data/model/device_response.dart';
import 'package:flutterlumin/src/data/model/projects.dart';

abstract class ProjectsState extends Equatable {}

class InitialState extends ProjectsState {
  @override
  List<Object> get props => [];
}

class LoadingState extends ProjectsState {
  @override
  List<Object> get props => [];
}

class LoadedState extends ProjectsState {
  LoadedState(this.response);

  final Projects response;

  @override
  List<Object> get props => [response];
}

class ErrorState extends ProjectsState {
  ErrorState(this.errorMessage);
  final String errorMessage;

  @override
  List<Object> get props => [];
}