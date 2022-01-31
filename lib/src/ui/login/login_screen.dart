
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/region_model.dart';
import 'package:flutterlumin/src/localdb/model/ward_model.dart';
import 'package:flutterlumin/src/localdb/model/zone_model.dart';
import 'package:flutterlumin/src/models/loginrequester.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/storage/storage.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/components/rounded_button.dart';
import 'package:flutterlumin/src/ui/components/rounded_input_field.dart';
import 'package:flutterlumin/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutterlumin/src/ui/login/login_thingsboard.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/ilm_maintenance_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class login_screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return login_screenState();
  }
}

class login_screenState extends State<login_screen> {
  late DBHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LoginForm());
  }
}

class LoginForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences logindata;
  final user = LoginRequester(
      username: "",
      password: "",
      token: "",
      refreshtoken: "",
      responseCode: 0,
      email: "");
  late final TbStorage storage;
  TextEditingController passwordController = TextEditingController(text: "");
  final TextEditingController _emailController =
      TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return true;
        },
    child: SingleChildScrollView(
      child: Container(
        color: Colors.white,
          height: size.height,
          width: double.infinity,

          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Image(
                      image: AssetImage("assets/icons/logo.png"),
                      height: 95,
                      width: 95),
                  const SizedBox(height: 35),
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Log-In with User email and Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  rounded_input_field(
                    hintText: user_email,
                    isObscure: false,
                    controller: _emailController,
                    validator: (email) {
                      if (email!.isEmpty) {
                        return "Please enter the email";
                      } else if (!EmailValidator.validate(email)) {
                        return "Please enter the validate email";
                      }
                    },
                    onSaved: (email) => user.username = email!,
                    onChanged: (String value) {},
                  ),
                  SizedBox(height: size.height * 0.02),
                  rounded_input_field(
                    hintText: user_password,
                    isObscure: true,
                    onSaved: (value) => user.password = value!,
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the password";
                      }
                    },
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 10),
                  rounded_button(
                    text: sign_in,
                    color: thbDblue,
                    press: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        FocusScope.of(context).requestFocus(FocusNode());
                        _loginAPI(context);
                      }
                    },
                    key: null,
                  ),
                ],
              )))),
    );
  }

  Future<void> _loginAPI(BuildContext context) async {
    // storage = TbSecureStorage();
    Utility.isConnected().then((value) async {
      if (value) {
        Utility.progressDialog(context);
        if ((user.username.isNotEmpty) && (user.password.isNotEmpty)) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var status = await login_thingsboard.callThingsboardLogin(
              context, user.username, user.password);
          if (status == true) {
            prefs.setString('username', user.username);
            prefs.setString('password', user.password);
            callRegionDetails(context);
            // Navigator.of(context).pushReplacement(MaterialPageRoute(
            //     builder: (BuildContext context) => dashboard_screen()));
          }else{
            Navigator.pop(context);
            Fluttertoast.showToast(
                msg: "Please check Username and Password, Invalid Credentials",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        } else {
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "Please check Username and Password, Invalid Credentials",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0);
        }
      }
    });
  }

  void callRegionDetails(BuildContext context) {
    Utility.isConnected().then((value) async {
      if (value) {
        Utility.progressDialog(context);

        var tbClient = ThingsboardClient(serverUrl);
        tbClient.smart_init();

        DBHelper dbHelper = new DBHelper();
        // dbHelper.region_delete();


        // final jsonData = '{"region"}';
        // final parsedJson = jsonDecode(jsonData);

        Map<String, dynamic> _portaInfoMap = {
          "type": ["region"],
        };

        PageLink pageLink = new PageLink(250);
        pageLink.page = 0;
        pageLink.pageSize = 250;

        PageData<Asset> region_response;
        region_response = (await tbClient
            .getAssetService()
            .getRegionTenantAssets(pageLink));

        if (region_response != null) {
          if (region_response.totalElements != 0) {
            for (int i = 0; i < region_response.data.length; i++) {
              String id = region_response.data
                  .elementAt(i)
                  .id!
                  .id
                  .toString();
              String name = region_response.data
                  .elementAt(i)
                  .name
                  .toString();
              Region region = new Region(i, id, name);
              dbHelper.add(region);
            }
          }

          PageData<Asset> zone_response;
          zone_response = (await tbClient
              .getAssetService()
              .getZoneTenantAssets(pageLink));

          // if (zone_response != null) {
          //   if (zone_response.totalElements != 0) {
          //     for (int i = 0; i < zone_response.data.length; i++) {
          //       String id = zone_response.data
          //           .elementAt(i)
          //           .id!
          //           .id
          //           .toString();
          //       String name = zone_response.data
          //           .elementAt(i)
          //           .name
          //           .toString();
          //       var regionname = name.split("-");
          //       Zone zone = new Zone(i, id, name, regionname[0].toString());
          //       dbHelper.zone_add(zone);
          //     }
          //   }
          //
          //   PageData<Asset> ward_response;
          //   ward_response = (await tbClient
          //       .getAssetService()
          //       .getWardTenantAssets(pageLink));

            // if (ward_response != null) {
            //   if (ward_response.totalElements != 0) {
            //     for (int i = 0; i < ward_response.data.length; i++) {
            //       String id = ward_response.data
            //           .elementAt(i)
            //           .id!
            //           .id
            //           .toString();
            //       String name = ward_response.data
            //           .elementAt(i)
            //           .name
            //           .toString();
            //       var regionname = name.split("-");
            //       Ward ward = new Ward(i, id, name, regionname[0].toString(),
            //           regionname[0].toString() + "-" +
            //               regionname[1].toString());
            //       dbHelper.ward_add(ward);
            //     }
            //   }
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (BuildContext context) => dashboard_screen()));
            // } else {
            //   Navigator.pop(context);
            //   calltoast("Ward Details found");
            // }
          // } else {
          //   Navigator.pop(context);
          //   calltoast("Zone Details found");
          // }
        } else {
          Navigator.pop(context);
          calltoast("Region Details found");
        }
      }
    });
  }
}
