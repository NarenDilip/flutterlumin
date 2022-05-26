import 'package:flutter/material.dart';
import 'package:flutterlumin/src/constants/const.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard(
      {Key? key,
      required this.projectName,
      required this.cardBottomColor,
      required this.totalCount,
      required this.onCount,
      required this.offCount,
      required this.ncCount})
      : super(key: key);
  final String projectName;
  final Color cardBottomColor;
  final int totalCount;
  final int onCount;
  final int offCount;
  final int ncCount;

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(projectName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                      totalCount == 0
                          ? " - 0"
                          : " - " + totalCount.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Roboto',
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: <Widget>[
                    const Text("On",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            color: Colors.grey)),
                    const SizedBox(height: 6),
                    Text(onCount == 0 ? "-" : "$onCount units",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: darkgreen))
                  ],
                ),
                Column(
                  children: <Widget>[
                    const Text(
                      "Off",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Roboto'),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      offCount == 0 ? "-" : "$offCount units",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: lightRedColor,
                          fontFamily: 'Roboto'),
                    )
                  ],
                ),
                Column(
                  children: <Widget>[
                    const Text(
                      "Nc",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      ncCount == 0 ? "-" : "$ncCount units",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: thbDblue),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 34,
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
