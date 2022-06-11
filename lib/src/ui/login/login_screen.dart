import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/region_model.dart';
import 'package:flutterlumin/src/models/loginrequester.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/storage/storage.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/components/rounded_button.dart';
import 'package:flutterlumin/src/ui/components/rounded_input_field.dart';
import 'package:flutterlumin/src/ui/listview/region_list_screen.dart';
import 'package:flutterlumin/src/ui/login/login_thingsboard.dart';
import 'package:flutterlumin/src/ui/maintenance/ilm/ilm_maintenance_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// User login with credentials for thingsboard production and smart accounts,
// and check the user is valid person or invalid, if the user is valid we need
// fetch user related region details and store in local database, based on
// the user login we need to store server token and refresh token in
// local storage

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

    //intialize the Local Database
    dbHelper = DBHelper();
  }

  @override
  Widget build(BuildContext context) {
    //loading the login form widget
    return Scaffold(body: LoginForm());
  }
}

class LoginForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences logindata;
  late ProgressDialog pr;
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
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
      message: app_pls_wait,
      borderRadius: 20.0,
      backgroundColor: Colors.lightBlueAccent,
      elevation: 10.0,
      messageTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: "Montserrat",
          fontSize: 19.0,
          fontWeight: FontWeight.w600),
      progressWidget: const CircularProgressIndicator(
          backgroundColor: Colors.lightBlueAccent,
          valueColor: AlwaysStoppedAnimation<Color>(thbDblue),
          strokeWidth: 3.0),
    );
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
                          app_log_email,
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
                            return app_no_email;
                            //validating the user email address
                          } else if (!EmailValidator.validate(email)) {
                            return app_validate_email;
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
                            return app_validate_pass;
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
                            //Calling the api user validation with thingsboard library access
                            _loginAPI(context);
                          }
                        },
                        key: null,
                      ),
                      const SizedBox(height: 60),
                      Center(
                          child: Text(app_version,
                              style: const TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.bold,
                                  color: invListBackgroundColor))),
                    ],
                  )))),
    );
  }

  Future<void> _loginAPI(BuildContext context) async {
    // storage = TbSecureStorage();
    Utility.isConnected().then((value) async {
      if (value) {
        pr.show();
        if ((user.username.isNotEmpty) && (user.password.isNotEmpty)) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var status = await login_thingsboard.callThingsboardLogin(
              context, user.username, user.password);
          if (status == true) {
            prefs.setString('username', user.username);
            prefs.setString('password', user.password);
            callRegionDetails(context);
          } else {
            pr.hide();
            Fluttertoast.showToast(
                msg: app_usr_invalid_cred,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0);
          }
        } else {
          // Navigator.pop(context);
          pr.hide();
          Fluttertoast.showToast(
              msg: app_usr_invalid_cred,
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

  // Fetching the user related region details and store it in local database

  void callRegionDetails(BuildContext context) {
    Utility.isConnected().then((value) async {
      if (value) {
        try {
          pr.show();
          var tbClient =
              ThingsboardClient(FlavorConfig.instance.variables["baseUrl"]);
          tbClient.smart_init();

          DBHelper dbHelper = new DBHelper();

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
                String id = region_response.data.elementAt(i).id!.id.toString();
                String name = region_response.data.elementAt(i).name.toString();
                Region region = new Region(i, id, name);
                dbHelper.add(region);
              }
            }

            PageData<Asset> zone_response;
            zone_response = (await tbClient
                .getAssetService()
                .getZoneTenantAssets(pageLink));

            // passing the application from login screen to region selection screen
            pr.hide();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => region_list_screen()));
          } else {
            // FlutterLogs.logInfo("devicelist_page", "device_list", "logMessage");
            pr.hide();
            calltoast(app_no_regions);
          }
        } catch (e) {
          pr.hide();
        }
      }
    });
  }
}
