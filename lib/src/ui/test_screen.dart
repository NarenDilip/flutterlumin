
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterlumin/src/local/db.dart';
import 'package:flutterlumin/src/local/model/region.dart';
import 'package:flutterlumin/src/thingsboard/storage/storage.dart';

class DbDisplay extends StatefulWidget {
  late final Region region;

  DbDisplay({
    required this.region
  });

  @override
  State<StatefulWidget> createState() {
    return DbDisplayState();
  }
}

class DbDisplayState extends State<DbDisplay> {
  final DbManager dbManager = DbManager();
  late String token;
  late final TbStorage storage;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.region.regionName}'),
      ),
      body: FutureBuilder<List>(
        future: dbManager.getModelList(),
        initialData: [],
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (_, int position) {
              final item = snapshot.data![position];
              //get your item data here ...
              return  Center(
                child: Row(
                  children: <Widget>[Text('${widget.region.regionName}')],
                ),
              );
            },
          )
              : Center(
            child: Row(
              children: <Widget>[Text('${widget.region.regionName}')],
            ),
          );
        },
      ),
    );
  }
}
