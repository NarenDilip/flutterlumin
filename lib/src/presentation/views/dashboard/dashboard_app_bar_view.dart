import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/views/ward/ward_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardAppBarWidget extends StatefulWidget {
  final String title;
  const DashboardAppBarWidget({
    Key? key, required this.title
  }) : super(key: key);

  @override
  State<DashboardAppBarWidget> createState() => _DashboardAppBarWidgetState();
}

class _DashboardAppBarWidgetState extends State<DashboardAppBarWidget> {

  String selectedRegion ='';
  String selectedZone ='';
  String selectedWard ='';

  @override
  initState()  {
    super.initState();
    getSelectedDetails();
  }

  Future<void> getSelectedDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRegion = prefs.getString("SelectedRegion").toString();
      selectedZone = prefs.getString("SelectedZone").toString();
      selectedWard = prefs.getString("SelectedWard").toString();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.only(left: 10, top: 30, right: 10,bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => const WardList()));
                },
                child: Icon(Icons.filter_list, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(6),
                  primary: Colors.blue, // <-- Button color
                  onPrimary: Colors.blue, // <-- Splash color
                ),
              ),
              Text(selectedWard,
                style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold),
              ),
              const Image(
                  image: AssetImage("assets/icons/logo.png"),
                  height: 30,
                  width: 30),
            ],
          ),

          
        ]));
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    Key? key,
    required this.categoryName,
    required this.itemPressed,
    required this.selectedItem,
  }) : super(key: key);
  final String categoryName;
  final Function() itemPressed;
  final String selectedItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: itemPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 40,
            width: 100,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12),
            color: selectedItem != 'null'  && selectedItem != '' ? kPrimaryColor : lightGrey,
            child: Text(selectedItem != 'null'  && selectedItem != '' ? selectedItem :categoryName  ,
                style:
                     TextStyle(color: selectedItem != 'null'  && selectedItem != '' ? Colors.white : Colors.black, fontFamily: "Roboto")),
          ),
        ));
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: Text("APPLY".toUpperCase(),
            style: const TextStyle(fontSize: 20, fontFamily: 'Roboto')),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    side: BorderSide(color: kPrimaryColor)))),
        onPressed: () => {Navigator.pop(context)});
  }
}
