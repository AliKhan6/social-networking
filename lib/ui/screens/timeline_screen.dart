import 'package:flutter/material.dart';
import 'package:fluttershare/ui/custom_widgets/header.dart';
import 'package:fluttershare/ui/custom_widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final userRef = Firestore.instance.collection('users');

class TimelineScreen extends StatefulWidget {
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
//
//  List<dynamic> user = [];
//
//  @override
//  void initState() {
//    getUsers();
////    getDocumentById();
//    super.initState();
//  }
//
////  getDocumentById() async{
////    String id = '8hjElQSiabbTgatsDBts';
////    final DocumentSnapshot doc = await userRef.document(id).get();
////    print(doc.data);
////  }
//  getUsers() async{
//    final QuerySnapshot snapshot = await userRef.
////    where("postsCount", isGreaterThan: "2").
////    where('userName', isEqualTo: 'Khan').
////    orderBy('postsCount', descending: true).
////    limit(2).
//    getDocuments();
//    setState(() {
//      user = snapshot.documents;
//    });
////      snapshot.documents.forEach((DocumentSnapshot doc) {
////        print(doc.data);
////        print(doc.documentID);
////        print(doc.exists);
////      });
//  }
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
          stream: userRef.snapshots(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return circularProgress();
            }
            List<Text> children = [];
            snapshot.data.documents.map((doc) {
              final username = doc['username'];
              Text text = Text(username);
              children.add(text);
            });
            print(children.length);
            return Container(
              child: ListView(
                children: children
              ),
            );
          }
      )
    );
  }
}

