import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/domain/repository/projects_repository.dart';
import 'package:flutterlumin/src/presentation/blocs/projects_state.dart';


class ProjectDetailCubit extends Cubit<ProjectsState> {
  final ProjectsRepository repository;

  ProjectDetailCubit(this.repository) : super(InitialState());

  Future<void> getProjectDetail(BuildContext context) async {
    try {
      emit(LoadingState());
      final deviceResponse =
          await repository.fetchProjectsInformation(context);
      emit(LoadedState(deviceResponse));
    } catch (e) {
      emit(ErrorState(""));
    }
  }

}
