import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/models/devicelistrequester.dart';
import 'package:flutterlumin/src/presentation/widgets/app_bar_view.dart';
import 'package:flutterlumin/src/presentation/widgets/search_button.dart';
import 'package:flutterlumin/src/presentation/widgets/search_input_field.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/maintenance/ccms/ccms_maintenance_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:flutterlumin/src/ui/login/loginThingsboard.dart';
import 'package:progress_dialog/progress_dialog.dart';

class DeviceDetailView extends StatefulWidget {
  const DeviceDetailView({Key? key}) : super(key: key);

  @override
  _DeviceDetailState createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<DeviceDetailView> {
  List<String>? _foundProducts = [];
  final List<String>? _relationDevices = [];
  static final Map<String, String> productMap = {
    'ilm': 'ilm',
    'ccms': 'ccms',
    'pole': 'pole',
    'gateway': 'gateway',
  };
  final user = DeviceRequester(
    ilmnumber: "",
    ccmsnumber: "",
    polenumber: "",
  );
  final List<String>? _relationdevices = [];
  final List<String>? _foundUsers = [];
  String _selectedProduct = productMap.keys.first;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController searchInputController = TextEditingController();
  late ProgressDialog progressDialog;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    progressDialog.style(
      progress: 50.0,
      message: "Please wait...",
      progressWidget: Container(
          padding: const EdgeInsets.all(8.0),
          child: const CircularProgressIndicator()),
      maxProgress: 100.0,
      progressTextStyle: const TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: const TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    return Scaffold(
      backgroundColor: lightGrey,
      body: Column(
        children: <Widget>[
          const AppBarWidget(title: "Devices",),
          Container(
            padding:
            const EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 20),
            child: Column(
              children: <Widget>[
                CupertinoRadioChoice(
                    choices: productMap,
                    selectedColor: lightBlueViewColor,
                    onChange: onProductSelected,
                    initialKeyValue: _selectedProduct),
                const SizedBox(
                  height: 20,
                ),
                Form(
                    key: _formKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Flexible(
                            child: SearchInputField(
                              searchInputController: searchInputController,
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        SearchViewButton(
                          searchButtonClicked: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              FocusScope.of(context).requestFocus(FocusNode());
                              searchProduct(user);
                            }
                          },
                        ),
                      ],
                    ))
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Visibility(
                visible: _foundProducts!.isEmpty ? false : true,
                child: Container(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Text(
                    "${_foundProducts!.length} devices found",
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ),
          const SizedBox(
            height: 14,
          ),
          productListView()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.qr_code),
        onPressed: () {},
      ),
    );
  }

  void searchProduct(DeviceRequester user){
    switch(_selectedProduct){
      case "ilm" : {
        callILMDeviceListFinder(
            searchInputController.text,
            context,
            progressDialog);
      }
      break;
      case "ccms" : {
        callccmsbasedILMDeviceListFinder(
            user.ccmsnumber,
            _relationdevices,
            _foundUsers, context);
      }
      break;
      case "pole" : {
        callPoleBasedILMDeviceListFinder(
            user.polenumber,
            _relationdevices,
            _foundUsers,
            context);
      }
      break;
      case "gateway" : {
        /*   callILMDeviceListFinder(
            searchInputController.text,
            context,
            progressDialog);*/
      }
      break;
    }
  }

  productListView() => Expanded(
    child: Card(
      color: lightGrey,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.highlight,
                    color: kPrimaryColor,
                    size: 40.0,
                  ),
                  title: Text(
                    _foundProducts![index],
                    style: const TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_foundProducts![index]),
                  onTap: () {

                  },
                ),
              ],
            );
          },
          itemCount: _foundProducts!.length,
        ),
      ),
    ),
  );

  void onProductSelected(String productKey) {
    setState(() {
      _selectedProduct = productKey;
    });
  }

  Future<void> callILMDeviceListFinder(String selectedNumber,
      BuildContext context, ProgressDialog progressDialog) async {
    Utility.isConnected().then((value) async {
      if (value) {
        // progressDialog.show();
        try {
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();

          String searchNumber = selectedNumber.replaceAll(" ", "");

          PageLink pageLink = new PageLink(100);
          pageLink.page = 0;
          pageLink.pageSize = 100;
          pageLink.textSearch = searchNumber;

          PageData<Device> devicelist_response;
          devicelist_response =
          (await tbClient.getDeviceService().getTenantDevices(pageLink));

          if (devicelist_response != null) {
            if (devicelist_response.totalElements != 0) {
              for (int i = 0; i < devicelist_response.data.length; i++) {
                String name =
                devicelist_response.data.elementAt(i).name.toString();
                _foundProducts!.add(name);
              }
            }
            setState(() {
              _foundProducts = _foundProducts;
              progressDialog.hide();
            });
          } else {
            progressDialog.hide();
            calltoast(searchNumber);
          }
        } catch (e) {
          progressDialog.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callPoleBasedILMDeviceListFinder(
                  selectedNumber, _relationDevices, _foundProducts, context);
            }
          } else {
            //calltoast(searchNumber);
            // Navigator.pop(context);
          }
        }
      } else {
        calltoast(no_network);
      }
    });
  }

  void callPoleBasedILMDeviceListFinder(
      String searchnumber,
      List<String>? _relationdevices,
      List<String>? _foundUsers,
      BuildContext context) {
    Utility.isConnected().then((value) async {
      if (value) {
        progressDialog.show();
        try {
          _relationdevices!.clear();
          _foundUsers!.clear();

          String polenumber = searchnumber.replaceAll(" ", "");

          Asset response;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();
          response = await tbClient.getAssetService().getTenantAsset(polenumber)
          as Asset;

          if (response != null) {
            List<EntityRelation> relationresponse;
            relationresponse = await tbClient
                .getEntityRelationService()
                .findByFrom(response.id!);
            if (relationresponse != null) {
              for (int i = 0; i < relationresponse.length; i++) {
                _relationdevices
                    .add(relationresponse.elementAt(i).to.id.toString());
              }
              Device devrelationresponse;
              for (int i = 0; i < _relationdevices.length; i++) {
                devrelationresponse = await tbClient
                    .getDeviceService()
                    .getDevice(_relationdevices.elementAt(i).toString())
                as Device;
                if (devrelationresponse != null) {
                  if (devrelationresponse.type == "lumiNode") {
                    _foundUsers!.add(devrelationresponse.name);
                  } else {}
                } else {
                  calltoast(polenumber);
                  progressDialog.hide();
                }
              }
              setState(() {
                _foundUsers = _foundUsers;
              });
              progressDialog.hide();
            } else {
              progressDialog.hide();
              calltoast(polenumber);
            }
          } else {
            progressDialog.hide();
            calltoast(polenumber);
          }
        } catch (e) {
          progressDialog.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callPoleBasedILMDeviceListFinder(
                  searchnumber, _relationdevices, _foundUsers, context);
            }
          } else {
            progressDialog.hide();
            calltoast(searchnumber);
          }
        }
      } else {
        calltoast(no_network);
      }
    });
  }

  void callccmsbasedILMDeviceListFinder(
      String searchnumber,
      List<String>? _relationdevices,
      List<String>? _foundUsers,
      BuildContext context) {
    Utility.isConnected().then((value) async {
      if (value) {
        progressDialog.show();
        try {
          _relationdevices!.clear();
          _foundUsers!.clear();

          String ccmsnumber = searchnumber.replaceAll(" ", "");

          Device response;
          var tbClient = ThingsboardClient(serverUrl);
          tbClient.smart_init();
          response = await tbClient
              .getDeviceService()
              .getTenantDevice(ccmsnumber) as Device;

          if (response != null) {
            List<EntityRelation> relationresponse;
            relationresponse = await tbClient
                .getEntityRelationService()
                .findByFrom(response.id!);
            if (relationresponse != null) {
              for (int i = 0; i < relationresponse.length; i++) {
                _relationdevices
                    .add(relationresponse.elementAt(i).to.id.toString());
              }
              Device Devrelationresponse;
              for (int i = 0; i < _relationdevices.length; i++) {
                Devrelationresponse = await tbClient
                    .getDeviceService()
                    .getDevice(_relationdevices.elementAt(i).toString())
                as Device;
                if (Devrelationresponse != null) {
                  if (Devrelationresponse.type == "lumiNode") {
                    _foundUsers!.add(Devrelationresponse.name);
                  } else {}
                } else {
                  progressDialog.hide();
                  calltoast(ccmsnumber);
                }
              }
              setState(() {
                _foundUsers = _foundUsers;
              });
              progressDialog.hide();
            } else {
              progressDialog.hide();
              calltoast(ccmsnumber);
            }
          } else {
            progressDialog.hide();
            calltoast(ccmsnumber);
          }
        } catch (e) {
          progressDialog.hide();
          var message = toThingsboardError(e, context);
          if (message == session_expired) {
            var status = loginThingsboard.callThingsboardLogin(context);
            if (status == true) {
              callccmsbasedILMDeviceListFinder(
                  user.ccmsnumber, _relationdevices, _foundUsers, context);
            }
          } else {
            calltoast(searchnumber);
          }
        }
      } else {
        calltoast(no_network);
      }
    });
  }
}
