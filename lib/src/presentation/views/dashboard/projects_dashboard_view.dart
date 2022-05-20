import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/blocs/projects_detail_cubit.dart';
import 'package:flutterlumin/src/presentation/blocs/projects_state.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/app_bar_view.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/dashboard_app_bar_view.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/project_card_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectDashboard extends StatefulWidget {
  const ProjectDashboard({Key? key, required}) : super(key: key);

  @override
  State<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  int ilmTotalCount = 0;
  int ccmsTotalCount = 0;
  int gatewayTotalCount = 0;
  int ilmOnCount = 0;
  int ccmsOnCount = 0;
  int gwOnCount = 0;
  int ilmOffCount = 0;
  int ccmsOffCount = 0;
  int gwOffCount = 0;
  int ilmNcCount = 0;
  int ccmsNcCount = 0;
  int gwNcCount = 0;

  @override
  void initState() {
    super.initState();
    final projectsCubit = BlocProvider.of<ProjectDetailCubit>(context);
    projectsCubit.getProjectDetail(context);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDetailCubit, ProjectsState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ErrorState) {
          return Text(
            state.errorMessage,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Roboto',
              color: Colors.red,
            ),
          );
        }
        else if (state is LoadedState) {
          var projectData = state.response;
            return SingleChildScrollView(
              child: Column(children: <Widget>[
                const DashboardAppBarWidget(title: "",),
                ProjectCard(
                  projectName: "ILM",
                  cardBottomColor: lightBlueCardColor,
                  totalCount: projectData.ilmTotalCount,
                  onCount: projectData.ilmOnCount,
                  offCount: projectData.ilmOffCount,
                  ncCount: projectData.ilmNcCount,
                ),
                ProjectCard(
                  projectName: "CCMS",
                  cardBottomColor: lightGreenCardColor,
                  totalCount: projectData.ccmsTotalCount,
                  onCount: projectData.ccmsOnCount,
                  offCount: projectData.ccmsOffCount,
                  ncCount: projectData.ccmsNcCount,
                ),
                ProjectCard(
                  projectName: "GATEWAY",
                  cardBottomColor: lightPinkCardColor,
                  totalCount: projectData.gatewayTotalCount,
                  onCount: projectData.gatewayOnCount,
                  offCount: projectData.gatewayOffCount,
                  ncCount: projectData.gatewayNcCount,
                ),
              ]),
            );
        } else {
          return Container();
        }
      },
    );

  }
}
