import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/widgets/app_bar_view.dart';
import 'package:flutterlumin/src/presentation/widgets/project_card_view.dart';
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
    getDeviceCount();
  }

  Future<void> getDeviceCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ilmTotalCount = prefs.getInt("ilm_total_count")!;
      ccmsTotalCount = prefs.getInt("ccms_total_count")!;
      gatewayTotalCount = prefs.getInt("gw_total_count")!;
      ilmOnCount = prefs.getInt("ilm_on_count")!;
      ccmsOnCount = prefs.getInt("ccms_on_count")!;
      gwOnCount = prefs.getInt("gw_on_count")!;
      ilmOffCount = prefs.getInt("ilm_off_count")!;
      ccmsOffCount = prefs.getInt("ccms_off_count")!;
      gwOffCount = prefs.getInt("gw_off_count")!;
      ilmNcCount = prefs.getInt("ilm_nc_count")!;
      ccmsNcCount = prefs.getInt("ccms_nc_count")!;
      gwNcCount = prefs.getInt("gw_nc_count")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        const AppBarWidget(),
        ProjectCard(
          projectName: "ILM",
          cardBottomColor: lightBlueCardColor,
          totalCount: ilmTotalCount,
          onCount: ilmOnCount,
          offCount: ilmOffCount,
          ncCount: ilmNcCount,
        ),
        ProjectCard(
          projectName: "CCMS",
          cardBottomColor: lightGreenCardColor,
          totalCount: ccmsTotalCount,
          onCount: ccmsOnCount,
          offCount: ccmsOffCount,
          ncCount: ccmsNcCount,
        ),
        ProjectCard(
          projectName: "GATEWAY",
          cardBottomColor: lightPinkCardColor,
          totalCount: gatewayTotalCount,
          onCount: gwOnCount,
          offCount: gwOffCount,
          ncCount: gwNcCount,
        ),
      ]),
    );
  }
}
