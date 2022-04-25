import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/domain/repository/device_repository.dart';
import 'package:flutterlumin/src/presentation/blocs/product_device_list_cubit.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/projects_dashboard_view.dart';
import 'package:flutterlumin/src/presentation/views/devices/search_devices.dart';
import 'package:flutterlumin/src/presentation/views/profile/profile_view.dart';
import 'package:flutterlumin/src/presentation/widgets/modal_bottom_sheet.dart';
import 'package:flutterlumin/src/ui/map/map_view_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardAppState createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardView> {
  var _currentIndex = 0;
  late PageController _pageController;
  List<Widget> tabPages = [
    const ProjectDashboard(),
    map_view_screen(),
    BlocProvider<ProductDeviceCubit>(
      create: (context) => ProductDeviceCubit(DeviceRepository()),
      child: const SearchDevicesView(),
    ),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
   /* Future.delayed(Duration.zero, () {
      _modalBottomSheetMenu(context);
    });*/
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => onPageChanged(i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: kPrimaryColor,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.location_searching),
            title: const Text("Location"),
            selectedColor: kPrimaryColor,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.add_chart),
            title: const Text("Devices"),
            selectedColor: kPrimaryColor,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
            selectedColor: kPrimaryColor,
          ),
        ],
      ),
      body: PageView(
        children: tabPages,
        onPageChanged: onPageChanged,
        controller: _pageController,
      ),
    );
  }

  void onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
      _pageController.jumpToPage(page);
    });
  }

  void _modalBottomSheetMenu(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return const FilterBottomSheet();
        });
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child:
        Text("APPLY".toUpperCase(), style: const TextStyle(fontSize: 14, fontFamily: 'Roboto')),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: kPrimaryColor)))),
        onPressed: () => {
             Navigator.pop(context)
        });
  }
}



class CategoryInputField extends StatelessWidget {
  final String category;
  const CategoryInputField({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      validator: (value) => null,
      decoration: InputDecoration(
        hintText: category,
        contentPadding: const EdgeInsets.all(0.0),
        hintStyle:
        const TextStyle(color: Colors.grey, fontFamily: 'Roboto'),
        fillColor: lightGrey,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: lightGrey, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: lightGrey),
        ),
      ),
    );
  }
}

