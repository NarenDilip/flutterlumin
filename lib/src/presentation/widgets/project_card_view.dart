import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard(
      {Key? key, required this.projectName, required this.cardBottomColor})
      : super(key: key);
  final String projectName;
  final Color cardBottomColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, top: 10, right: 14),
      child: Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: lightGrey, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const Icon(
                    Icons.lightbulb,
                    color: Colors.orange,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(projectName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(
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
                    Text("On",
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
                      "Off",
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
                      "Nc",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
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
              height: 50,
              color: cardBottomColor,
              child: Row(
                children: const <Widget>[],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
