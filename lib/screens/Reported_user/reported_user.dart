import 'package:cloud_firestore/cloud_firestore.dart';

class ReportedUser {
  final CollectionReference reportsList =
      Firestore.instance.collection('Reports');
  Future getReportedUser() async {
    List itemList = [];
    try {
      // ignore: non_constant_identifier_names
      await reportsList.getDocuments().then((QuerySnapshot) {
        QuerySnapshot.documents.forEach((element) {
          itemList.add(element.data);
        });
      });
      return itemList;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
