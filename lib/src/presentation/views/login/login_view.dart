import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:flutterlumin/src/localdb/db_helper.dart';
import 'package:flutterlumin/src/localdb/model/region_model.dart';
import 'package:flutterlumin/src/models/loginrequester.dart';
import 'package:flutterlumin/src/presentation/views/ward/region_list_view.dart';
import 'package:flutterlumin/src/thingsboard/model/model.dart';
import 'package:flutterlumin/src/thingsboard/thingsboard_client_base.dart';
import 'package:flutterlumin/src/ui/maintenance/ccms/ccms_maintenance_screen.dart';
import 'package:flutterlumin/src/utils/utility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterlumin/src/ui/login/login_thingsboard.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginAppState createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginView> {
  late ProgressDialog pr;
  TextEditingController passwordController = TextEditingController(text: "");
  final TextEditingController _emailController =
      TextEditingController(text: "");
  final user = LoginRequester(
      username: "",
      password: "",
      token: "",
      refreshtoken: "",
      responseCode: 0,
      email: "");
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
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
    return Form(
        key: _formKey,
        child: Scaffold(
            body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(
                      left: 20, top: 40, right: 20, bottom: 20),
                  child: const Image(
                    image: AssetImage("assets/icons/background_luminator.png"),
                    height: 340,
                    width: double.infinity,
                  ),
                ),
                Container(
                    padding: const EdgeInsets.only(
                        left: 40, top: 20, right: 40, bottom: 40),
                    child: Column(
                      children: [
                        _EmailInputField(_emailController, user),
                        const SizedBox(height: 10),
                        const SizedBox(
                          height: 10,
                        ),
                        _PasswordInputField(passwordController, user),
                        const SizedBox(
                          height: 6,
                        ),
                        _ForgotPassword(),
                        const SizedBox(
                          height: 30,
                        ),
                        LoginButton(
                          _formKey,
                          key: UniqueKey(),
                          user: user,
                          progressDialog: pr,
                        )
                      ],
                    ))
              ]),
        )));
  }
}

class _EmailInputField extends StatelessWidget {
  const _EmailInputField(this._emailController, this.user);

  final TextEditingController _emailController;
  final LoginRequester user;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
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
      decoration: const InputDecoration(
        hintText: 'Email',
        hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Roboto'),
        fillColor: lightGrey,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: lightGrey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: lightGrey),
        ),
      ),
    );
  }
}

class _PasswordInputField extends StatelessWidget {
  const _PasswordInputField(this._passwordController, this.user);

  final TextEditingController _passwordController;
  final LoginRequester user;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Roboto'),
        filled: true,
        fillColor: lightGrey,
        suffixIcon: Icon(
          Icons.visibility_off,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: lightGrey),
        ),
      ),
      onSaved: (value) => user.password = value!,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter the password";
        }
      },
      onChanged: (value) {},
    );
  }
}

class _ForgotPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        child: const Text(
          " Forgot Password",
          style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto'),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton(this._formKey,
      {Key? key, required this.user, required this.progressDialog})
      : super(key: key);
  final GlobalKey<FormState> _formKey;
  final LoginRequester user;
  final ProgressDialog progressDialog;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: GestureDetector(
        onTap: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            FocusScope.of(context).requestFocus(FocusNode());
            _loginAPI(context, user, progressDialog);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: const LinearGradient(
              colors: [Color(0xFF80D8FF), Color(0xFF0091EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Center(
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _loginAPI(BuildContext context, LoginRequester user,
    ProgressDialog progressDialog) async {
  // storage = TbSecureStorage();
  Utility.isConnected().then((value) async {
    if (value) {
      progressDialog.show();
      if ((user.username.isNotEmpty) && (user.password.isNotEmpty)) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var status = await login_thingsboard.callThingsboardLogin(
            context, user.username, user.password);
        if (status == true) {
          prefs.setString('username', user.username);
          prefs.setString('password', user.password);
          callRegionDetails(context, progressDialog);
        } else {
          // Navigator.pop(context);
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
        // Navigator.pop(context);
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

void callRegionDetails(BuildContext context, ProgressDialog progressDialog) {
  Utility.isConnected().then((value) async {
    if (value) {
      var tbClient = ThingsboardClient(serverUrl);
      tbClient.smart_init();
      DBHelper dbHelper = DBHelper();
      PageLink pageLink = PageLink(250);
      pageLink.page = 0;
      pageLink.pageSize = 250;
      PageData<Asset> regionResponse;
      regionResponse =
          (await tbClient.getAssetService().getRegionTenantAssets(pageLink));
      if (regionResponse != null) {
        if (regionResponse.totalElements != 0) {
          for (int i = 0; i < regionResponse.data.length; i++) {
            String id = regionResponse.data.elementAt(i).id!.id.toString();
            String name = regionResponse.data.elementAt(i).name.toString();
            Region region = new Region(i, id, name);
            dbHelper.add(region);
          }
        }
        await tbClient.getAssetService().getZoneTenantAssets(pageLink);
        progressDialog.hide();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const RegionListScreen()));
      } else {
        progressDialog.hide();
        calltoast("Region Details found");
      }
    }
  });
}
