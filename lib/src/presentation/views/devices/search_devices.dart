import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/models/devicelistrequester.dart';
import 'package:flutterlumin/src/presentation/blocs/device_state.dart';
import 'package:flutterlumin/src/presentation/blocs/product_device_list_cubit.dart';
import 'package:flutterlumin/src/presentation/widgets/app_bar_view.dart';
import 'package:flutterlumin/src/presentation/widgets/search_button.dart';
import 'package:flutterlumin/src/presentation/widgets/search_input_field.dart';

class SearchDevicesView extends StatefulWidget {
  const SearchDevicesView({Key? key}) : super(key: key);

  @override
  _SearchDevicesState createState() => _SearchDevicesState();
}

class _SearchDevicesState extends State<SearchDevicesView> {
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
  String _selectedProduct = productMap.keys.first;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController searchInputController = TextEditingController();
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
          BlocBuilder<ProductDeviceCubit, DevicesState>(
            builder: (context, state) {
              if (state is LoadingState) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ErrorState) {
                return const Center(
                  child: Icon(Icons.close),
                );
              } else if (state is LoadedState) {
                final deviceResponse = state.deviceResponse;
                return   productListView(deviceResponse.deviceList);
              } else {
                return Container();
              }
            },
          ),
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
        final productDeviceCubit = BlocProvider.of<ProductDeviceCubit>(context);
        productDeviceCubit.getILMDevices(searchInputController.text);
      }
      break;
      case "ccms" : {
        final productDeviceCubit = BlocProvider.of<ProductDeviceCubit>(context);
        productDeviceCubit.getCCMSDevices(searchInputController.text, _relationdevices!);
      }
      break;
      case "pole" : {
        final productDeviceCubit = BlocProvider.of<ProductDeviceCubit>(context);
        productDeviceCubit.getPoleDevices(searchInputController.text, _relationdevices!);
      }
      break;
    }
  }

  productListView(List<String> devices) => Expanded(
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
                    devices[index],
                    style: const TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(devices[index]),
                  onTap: () {

                  },
                ),
              ],
            );
          },
          itemCount: devices.length,
        ),
      ),
    ),
  );

  void onProductSelected(String productKey) {
    setState(() {
      _selectedProduct = productKey;
    });
  }
}
