import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/widgets/app_bar_view.dart';
import 'package:flutterlumin/src/presentation/widgets/project_card_view.dart';

class ProjectDashboard extends StatelessWidget {
  const ProjectDashboard({Key? key, required}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: const <Widget>[
        AppBarWidget(),
        ProjectCard(projectName: "ILM", cardBottomColor: lightBlueColor),
        ProjectCard(
          projectName: "CCMS",
          cardBottomColor: lightRed,
        ),
        ProjectCard(
          projectName: "Gateway",
          cardBottomColor: lightBlueColor,
        ),
      ]),
    );
  }
}

