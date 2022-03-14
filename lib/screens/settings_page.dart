import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final collectionReference = Firestore.instance.collection("Language");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              'Select Languages To Appear on App',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: collectionReference.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      //child: Text('No Snapshot FOUND'),
                      );
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                      child: Row(
                        children: [
                          InkWell(
                            onLongPress: () {
                              collectionReference
                                  .document('present_languages')
                                  .setData({'english': false}, merge: true);
                            },
                            onTap: () {
                              collectionReference
                                  .document('present_languages')
                                  .setData({'english': true}, merge: true);
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black45, width: 2),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child:
                                  snapshot.data.documents[0]['english'] == true
                                      ? Icon(
                                          Icons.check,
                                          color: Theme.of(context).primaryColor,
                                          size: 30,
                                        )
                                      : Container(),
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'English',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                      child: Row(
                        children: [
                          InkWell(
                            onLongPress: () {
                              collectionReference
                                  .document('present_languages')
                                  .setData({'spanish': false}, merge: true);
                            },
                            onTap: () {
                              collectionReference
                                  .document('present_languages')
                                  .setData({'spanish': true}, merge: true);
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black45, width: 2),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child:
                                  snapshot.data.documents[0]['spanish'] == true
                                      ? Icon(
                                          Icons.check,
                                          color: Theme.of(context).primaryColor,
                                          size: 30,
                                        )
                                      : Container(),
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Spanish',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Note: Long press the box to uncheck the option and press the box once to check the option',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
