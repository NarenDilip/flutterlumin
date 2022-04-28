import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/blocs/device_state.dart';
import 'package:flutterlumin/src/presentation/blocs/product_device_list_cubit.dart';
import 'package:flutterlumin/src/presentation/widgets/app_bar_view.dart';
import 'package:flutterlumin/src/presentation/widgets/device_search_list_view.dart';
import 'package:flutterlumin/src/presentation/widgets/search_button.dart';
import 'package:flutterlumin/src/presentation/widgets/search_input_field.dart';

class SearchDevicesView extends StatefulWidget {
  const SearchDevicesView({Key? key}) : super(key: key);

  @override
  _SearchDevicesState createState() => _SearchDevicesState();
}

class _SearchDevicesState extends State<SearchDevicesView> {
  static final Map<String, String> productMap = {
    'ilm': 'ILM',
    'ccms': 'CCMS',
    'pole': 'Pole',
    'gateway': 'Gateway',
  };
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
            const EdgeInsets.only(left: 16, top: 20, right: 16, bottom: 20),
            child: Column(
              children: <Widget>[
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
                              searchProduct();
                            }
                          },
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                CupertinoRadioChoice(
                    choices: productMap,
                    selectedColor: lightBlueViewColor,
                    onChange: onProductSelected,
                    initialKeyValue: _selectedProduct),
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
                if(deviceResponse.errorMessage != ""){
                  return Container(
                    child: Text(deviceResponse.errorMessage),
                  );
                }else{
                  return DeviceListView(devices: deviceResponse.deviceList);
                }
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  void onProductSelected(String productKey) {
    setState(() {
      _selectedProduct = productKey;
    });
  }

  void searchProduct(){
    switch(_selectedProduct){
      case "ilm" : {
        final productDeviceCubit = BlocProvider.of<ProductDeviceCubit>(context);
        productDeviceCubit.getILMDevices(searchInputController.text);
      }
      break;
      case "ccms" : {
        final productDeviceCubit = BlocProvider.of<ProductDeviceCubit>(context);
        productDeviceCubit.getCCMSDevices(searchInputController.text);
      }
      break;
      case "pole" : {
        final productDeviceCubit = BlocProvider.of<ProductDeviceCubit>(context);
        productDeviceCubit.getPoleDevices(searchInputController.text);
      }
      break;
    }
  }
}
