import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/listview/ward_li_screen.dart';
import 'package:flutterlumin/src/ui/listview/zone_li_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {

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
        color: lightGrey,
        padding: const EdgeInsets.only(left: 10, top: 40, right: 10),
        child: Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Image(
                  image: AssetImage("assets/icons/logo.png"),
                  height: 30,
                  width: 30),
              const Text(
                "VLR-1-1",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold),
              ),
              Container(
                child: const CircleAvatar(
                  radius: 16, // Image radius
                  backgroundImage:
                      NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CategoryWidget(
                categoryName: "Region",
                selectedItem:selectedRegion ,
                itemPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => region_list_screen()));
                },
              ),
              CategoryWidget(
                categoryName: "Zone",
                selectedItem: selectedZone,
                itemPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => zone_li_screen()));
                },
              ),
              CategoryWidget(
                categoryName: "Ward",
                selectedItem: selectedWard,
                itemPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ward_li_screen()));
                },
              ),
            ],
          ),
          const SizedBox(
            height: 10,
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
            color: selectedItem != 'null'  && selectedItem != '' ? Colors.white : Colors.grey,
            child: Text(selectedItem != 'null'  && selectedItem != '' ? selectedItem :categoryName  ,
                style:
                    const TextStyle(color: Colors.black, fontFamily: "Roboto")),
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
