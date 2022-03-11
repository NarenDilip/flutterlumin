import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';


class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);


  @override
  _LoginAppState createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
              Widget>[
            ClipPath(
              clipper: CurveClipper(),
              child: Container(
                padding: const EdgeInsets.only(left: 40, top: 50, right: 20),
                height: 350,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF80D8FF),
                      Color(0xFF0091EA),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const <Widget>[
                    SizedBox(height: 10),
                    Image(
                        image: AssetImage("assets/icons/schnell-logo-white.png"),
                        height: 100,
                        width: 100),
                    SizedBox(height: 40),
                    Text(
                      "Lumiantor",
                      style: TextStyle(
                          color: Colors.white, fontSize: 30, fontFamily: 'Roboto'),
                    )
                  ],
                ),
              ),
            ),
            Container(
                padding:
                const EdgeInsets.only(left: 40, top: 40, right: 40, bottom: 40),
                child: Column(
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        hintStyle:
                        TextStyle(color: Colors.grey, fontFamily: 'Roboto'),
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
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        hintStyle:
                        TextStyle(color: Colors.grey, fontFamily: 'Roboto'),
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
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        child: const Text(
                          " Forgot Password",
                          style:
                          TextStyle(color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    SizedBox(
                      height: 50.0,
                      child: GestureDetector(
                        onTap: () {


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
                    ),
                  ],
                ))
          ]),
        ));
  }


}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
