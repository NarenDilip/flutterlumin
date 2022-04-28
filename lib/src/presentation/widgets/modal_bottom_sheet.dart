
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/region_model.dart';
import 'package:flutterlumin/src/data/model/zone_model.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/maintenance/ccms/ccms_maintenance_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final String _valueDropdownGrade = 'ILM';
  List<String>? regions = [];
  List<String>? zones = [];
  List<String>? wards = [];
  @override
  initState() {
    super.initState();
    getRegions();
  }

  getRegions() {
    DBHelper dbHelper = DBHelper();
    dbHelper.getDetails().then((data) {
      for (int i = 0; i < data.length; i++) {
        String regionName = data[i].regionname.toString();
        setState(() {
          regions?.add(regionName);
        });
      }
    }, onError: (e) {});
  }

  void callZoneDetailsFinder(BuildContext context, selectedZone) {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("selected_region", selectedZone);
          DBHelper dbHelper = DBHelper();
          List<ZoneResponse> details = await dbHelper
              .zone_regionbasedDetails(selectedZone);
          if (details.isEmpty) {
            List<Region> regionDetails =
            await dbHelper.region_name_regionbasedDetails(selectedZone);
            if (regionDetails.isNotEmpty) {
              Map<String, dynamic> fromId = {
                'entityType': 'ASSET',
                'id': regionDetails.first.regionid
              };
              List<EntityRelationInfo> wardlist = await tbClient
                  .getEntityRelationService()
                  .findInfoByAssetFrom(EntityId.fromJson(fromId));
              if (wardlist.isNotEmpty) {
                for (int i = 0; i < wardlist.length; i++) {
                  zones?.add(wardlist.elementAt(i).to.id.toString());
                }
                for (int j = 0; j < zones!.length; j++) {
                  Asset asset = await tbClient
                      .getAssetService()
                      .getAsset(zones!.elementAt(j).toString()) as Asset;
                  if (asset.name != null) {
                    ZoneResponse zone =
                    ZoneResponse(j, asset.id!.id, asset.name, selectedZone);
                    dbHelper.zone_add(zone);
                  }
                }

              } else {
                Fluttertoast.showToast(
                    msg: "No Zones releated to this Region",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    fontSize: 16.0);
              }
            } else {
              Fluttertoast.showToast(
                  msg: "Unable to find Region Details",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  fontSize: 16.0);
            }
          } else {

          }
        } catch (e) {
          var message = toThingsboardError(e, context);
          if (message == session_expired) {

          } else {

          }
        }
      } else {
        Fluttertoast.showToast(
            msg: "No Network. Please try again later",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(children: <Widget>[
      Container(
        padding:
            const EdgeInsets.only(left: 40, top: 20, right: 40, bottom: 20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0))),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Align(
                alignment: Alignment.center,
                child: Text("Choose your ward",
                    style: TextStyle(fontSize: 20, fontFamily: 'Roboto')),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Region',
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              DropDownMenu(valueDropdownGrade: _valueDropdownGrade),
              const SizedBox(
                height: 24,
              ),
              const Text(
                'Zone',
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              DropDownMenu(valueDropdownGrade: _valueDropdownGrade),
              const SizedBox(
                height: 24,
              ),
              const Text(
                'Ward',
                style: TextStyle(fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              DropDownMenu(valueDropdownGrade: _valueDropdownGrade),
              const SizedBox(
                height: 24,
              ),
              const Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: SearchButton(),
                  ))
            ]),
      )
    ]);
  }
}

class DropDownMenu extends StatelessWidget {
  const DropDownMenu({
    Key? key,
    required String valueDropdownGrade,
  })  : _valueDropdownGrade = valueDropdownGrade,
        super(key: key);

  final String _valueDropdownGrade;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 1.0, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        contentPadding: EdgeInsets.all(0.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            icon: const Icon(Icons.arrow_drop_down),
            hint: const Text('Choose the Product'),
            onChanged: (newValue) {},
            value: _valueDropdownGrade,
            items: <String>[
              'ILM',
              'CCMS',
              'GATEWAY',
              'POLE',
            ].map((String value) {
              return DropdownMenuItem<String>(
                  value: value,
                  child: SizedBox(
                    width: 80.0, // for example
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 14, fontFamily: 'Roboto'),
                    ),
                  ));
            }).toList()),
      ),
    );
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
            style: const TextStyle(fontSize: 16, fontFamily: 'Roboto')),
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
