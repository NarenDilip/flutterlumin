import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/presentation/blocs/device_state.dart';
import 'package:flutterlumin/src/presentation/blocs/search_device_cubit.dart';
import 'package:flutterlumin/src/presentation/views/dashboard/app_bar_view.dart';
import 'package:flutterlumin/src/presentation/views/devices/device_list_view.dart';
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
    'gateway': 'GW',
  };
  String _selectedProduct = productMap.keys.first;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController searchInputController = TextEditingController();
  final controller = ValueNotifier('all');
  @override
  void initState() {
    super.initState();
   searchProduct();
   controller.addListener(() {

   });
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Flexible(
                                child: SearchInputField(
                                  searchInputController: searchInputController,
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        AdvancedSegment(
                          controller: controller, // AdvancedSegmentController
                          segments: { // Map<String, String>
                            'ilm': 'ILM',
                            'ccms': 'CCMS',
                            'pole': 'Pole',
                            'gateway': 'Gateway',
                          },
                        ),
                      ],
                    )
                ),
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
                    child: Text(deviceResponse.errorMessage, style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      color: Colors.red,
                    ),),
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
    searchProduct();
  }

  void searchProduct(){
    final productDeviceCubit = BlocProvider.of<ProductDeviceCubit>(context);
    productDeviceCubit.searchProduct(searchInputController.text, _selectedProduct);
  }

}
