import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/views/ward/region_list_view.dart';
import 'package:flutterlumin/src/presentation/views/ward/ward_list_view.dart';
import 'package:flutterlumin/src/presentation/views/ward/zone_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBarWidget extends StatefulWidget {
  final String title;
  const AppBarWidget({
    Key? key, required this.title
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
        child: Column(children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Image(
                  image: AssetImage("assets/icons/logo.png"),
                  height: 30,
                  width: 30),
              Text(widget.title,
                style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold),
              ),
              const CircleAvatar(
                radius: 16, // Image radius
                backgroundImage:
                    NetworkImage("https://i.imgur.com/BoN9kdC.png"),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CategoryWidget(
                categoryName: "Region",
                selectedItem:selectedRegion ,
                itemPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => RegionListScreen()));
                },
              ),
              CategoryWidget(
                categoryName: "Zone",
                selectedItem: selectedZone,
                itemPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => ZoneListScreen()));
                },
              ),
              CategoryWidget(
                categoryName: "Ward",
                selectedItem: selectedWard,
                itemPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => WardList()));
                },
              ),
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
          borderRadius: BorderRadius.circular(8),
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
