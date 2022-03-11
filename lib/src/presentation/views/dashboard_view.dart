import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardAppState createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardView> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: lightGrey,
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            /// Home
            SalomonBottomBarItem(
              icon: Icon(Icons.home),
              title: Text("Home"),
              selectedColor: kPrimaryColor,
            ),

            /// Likes
            SalomonBottomBarItem(
              icon: Icon(Icons.location_searching),
              title: Text("Location"),
              selectedColor: kPrimaryColor,
            ),

            /// Search
            SalomonBottomBarItem(
              icon: Icon(Icons.add_chart),
              title: Text("Devices"),
              selectedColor: kPrimaryColor,
            ),

            /// Profile
            SalomonBottomBarItem(
              icon: Icon(Icons.person),
              title: Text("Profile"),
              selectedColor: kPrimaryColor,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 14, top: 40, right: 20),
              child: const Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 20, // Image radius
                  backgroundImage:
                      NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 14, top: 40, right: 14),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.white70, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const <Widget>[
                          Icon(
                            Icons.lightbulb,
                            color: Colors.orange,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text("ILM",
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'Roboto', fontWeight: FontWeight.bold,)),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: const <Widget>[
                            Text("ON",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: Colors.grey)),
                            SizedBox(height: 6),
                            Text("110 units",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: darkgreen))
                          ],
                        ),
                        Column(
                          children: const <Widget>[
                            Text(
                              "OFF",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontFamily: 'Roboto'),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "10 units",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: lightRedColor,
                                  fontFamily: 'Roboto'),
                            )
                          ],
                        ),
                        Column(
                          children: const <Widget>[
                            Text(
                              "NC",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "16 units",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: thbDblue),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 60,
                      color: lightRed,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 14, top: 10, right: 14),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.white70, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const <Widget>[
                          Icon(
                            Icons.lightbulb,
                            color: Colors.orange,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text("CCMS",
                              style: TextStyle(
                                  fontSize: 20, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: const <Widget>[
                            Text("ON",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: Colors.grey)),
                            SizedBox(height: 6),
                            Text("110 units",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                    color: darkgreen))
                          ],
                        ),
                        Column(
                          children: const <Widget>[
                            Text(
                              "OFF",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontFamily: 'Roboto'),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "10 units",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: lightRedColor,
                                  fontFamily: 'Roboto'),
                            )
                          ],
                        ),
                        Column(
                          children: const <Widget>[
                            Text(
                              "NC",
                              style:
                              TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "16 units",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: thbDblue),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 60,
                      color: lightBlueColor,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 14, top: 10, right: 14),
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.white70, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const <Widget>[
                          Icon(
                            Icons.lightbulb,
                            color: Colors.orange,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text("GATEWAY",
                              style: TextStyle(
                                  fontSize: 18, fontFamily: 'Roboto')),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: const <Widget>[
                            Text("ON", style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontFamily: 'Roboto')),
                            SizedBox(height: 6),
                            Text("110 devices",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    color: darkgreen))
                          ],
                        ),
                        Column(
                          children: const <Widget>[
                            Text(
                              "OFF",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontFamily: 'Roboto'),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "10 devices",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: lightRedColor,
                                  fontFamily: 'Roboto'),
                            )
                          ],
                        ),
                        Column(
                          children: const <Widget>[
                            Text(
                              "NC",
                              style: TextStyle(fontSize: 14, color: Colors.grey,),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              "16 devices",
                              style: TextStyle(fontSize: 14, color: thbDblue),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 60,
                      color: lightRed,
                    ),
                  ],
                ),
              ),
            )
          ]),
        ));
  }
}
