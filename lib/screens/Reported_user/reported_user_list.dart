import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hookup4u_admin/model/user.dart';
import 'package:hookup4u_admin/screens/Reported_user/reported_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hookup4u_admin/screens/login.dart';
import 'package:hookup4u_admin/screens/user_info.dart';

class ReportedUserList extends StatefulWidget {
  @override
  _ReportedUserListState createState() => _ReportedUserListState();
}

class _ReportedUserListState extends State<ReportedUserList> {
  List reportedUserProfileList;
  var user = [];
  DocumentSnapshot lastVisible;
  bool sort = true;
  int totalDoc;
  int documentLimit = 25;

  CollectionReference collectionReference =
      Firestore.instance.collection("Users");

  @override
  void initState() {
    super.initState();
    fetchReportedUserList();
    getuserList();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchctrlr = TextEditingController();

  fetchReportedUserList() async {
    dynamic resultant = await ReportedUser().getReportedUser();

    if (resultant == null) {
      print('unable to retrieve');
    } else {
      setState(() {
        reportedUserProfileList = resultant;
      });
    }
    totalDoc = reportedUserProfileList.length;
  }

  Future getuserList() async {
    await collectionReference.document().get().then((value) {
      collectionReference.document().get().then((report) {
        // totalDoc = report.documentID.length;
      });
    });

    for (int i = 0; i < reportedUserProfileList.length; i++) {
      var reportedid = reportedUserProfileList[i]['victim_id'];
      var reportedby = reportedUserProfileList[i]['reported_by'];

      await collectionReference.document(reportedid).get().then((valueUser) {
        collectionReference.document(reportedby).get().then((report) {
          user.add({
            'Reportedby': report['UserName'],
            'UserData': User.fromDocument(valueUser)
          });
          setState(() {});
        });
      });
    }
    return user;
  }

  Widget userlists(user) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: sort,
                sortColumnIndex: 2,
                columnSpacing: MediaQuery.of(context).size.width * .085,
                columns: [
                  DataColumn(
                    label: Text("Images"),
                  ),
                  DataColumn(
                    label: Text("Name"),
                  ),
                  DataColumn(
                    label: Text("Gender"),
                  ),
                  DataColumn(label: Text("Phone Number")),
                  DataColumn(label: Text("User_id")),
                  DataColumn(label: Text("view")),
                  DataColumn(label: Text("Reported By")),
                ],
                rows: [
                  for (var i in user)
                    DataRow(cells: [
                      DataCell(
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: CircleAvatar(
                            child: i['UserData'].imageUrl[0] != null
                                ? Image.network(
                                    "${i['UserData'].imageUrl[0]}",
                                    fit: BoxFit.fill,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Text('');
                                    },
                                  )
                                : Container(),
                            backgroundColor: Colors.grey,
                            radius: 18,
                          ),
                        ),
                      ),
                      DataCell(
                        Text("${i['UserData'].name}"),
                      ),
                      DataCell(
                        Text("${i['UserData'].gender}"),
                      ),
                      DataCell(
                        Text("${i['UserData'].phoneNumber}"),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 150,
                              child: Text(
                                "${i['UserData'].id}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.content_copy,
                                  size: 20,
                                ),
                                tooltip: "copy",
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                    text: "${i['UserData'].id}",
                                  ));
                                })
                          ],
                        ),
                      ),
                      DataCell(
                        IconButton(
                            icon: Icon(Icons.fullscreen),
                            tooltip: "open profile",
                            onPressed: () async {
                              var _isdelete = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Info(i['UserData'])));
                              if (_isdelete != null && _isdelete) {
                                snackbar('Deleted', _scaffoldKey);

                                setState(() {
                                  searchctrlr.clear();
                                  searchReasultfuture = null;
                                  user.removeWhere((element) =>
                                      element.id == i['UserData'].id);
                                });
                              }
                            }),
                      ),
                      DataCell(
                        Text("${i['Reportedby']}"),
                      ),
                    ]),
                ],
              ),
            ),
          ),
          searchReasultfuture != null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: 12,
                          ),
                          onPressed: () {}),
                      Text(
                          "${user.length >= documentLimit ? user.length - documentLimit : 0}-${user.length - 1} of $totalDoc  "),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                        ),
                        onPressed: () {},
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  var results = [];
  var r = [];
  Future<QuerySnapshot> searchReasultfuture;
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  searchuser(String query) {
    if (query.trim().length > 0) {
      Future<QuerySnapshot> users = collectionReference
          .where(
            isNumeric(query) ? 'phoneNumber' : 'UserName',
            isEqualTo: query,
          )
          .getDocuments();

      setState(() {
        searchReasultfuture = users;
      });
    }
  }

  Widget buildSearchresults() {
    return FutureBuilder(
      future: searchReasultfuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                )),
              ),
              Text("Searching......"),
            ],
          );
        }

        if (snapshot.data.documents.length > 0) {
          results.clear();
          snapshot.data.documents.forEach((DocumentSnapshot doc) {
            if (doc.data.length > 0) {
              var t = user.map((e) {
                if (doc.data['userId'] == e['UserData'].id) {
                  var reportername = e['Reportedby'];
                  var usert22 = User.fromDocument(doc);
                  results
                      .add({'UserData': usert22, 'Reportedby': reportername});
                }
              });
              print(t);
            }
          });

          return userlists(results);
        }
        return Center(child: Text("no data found"));
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Reported Users List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              height: 4,
              width: MediaQuery.of(context).size.width * .3,
              child: Card(
                child: TextFormField(
                  cursorColor: Theme.of(context).primaryColor,
                  controller: searchctrlr,
                  decoration: InputDecoration(
                      hintText: "Search by name or phone number",
                      filled: true,
                      prefixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () => searchuser(searchctrlr.text)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchctrlr.clear();
                          setState(() {
                            searchReasultfuture = null;
                          });
                        },
                      )),
                  onFieldSubmitted: searchuser,
                ),
              ),
            ),
          ),
        ],
      ),
      body: searchReasultfuture == null
          ? user.length > 0
              ? userlists(user)
              : Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                )))
          : buildSearchresults(),
    );
  }
}
