import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfileView> {


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
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            padding:
            const EdgeInsets.only(left: 30, top: 20, right: 30, bottom: 20),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 14, top: 20, right: 20),
                  child: const Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 40, // Image radius
                      backgroundImage: NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                const Text("Developer", style: TextStyle(fontSize: 24, fontFamily: "Roboto"),)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      validator: (value) => null,
      decoration: const InputDecoration(
        hintText: 'Enter product number',
        hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Roboto'),
        fillColor: Colors.grey,
        contentPadding: EdgeInsets.all(10.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
