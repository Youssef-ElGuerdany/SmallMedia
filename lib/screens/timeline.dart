import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = []; // the list of users
  @override
  void initState() {
    super.initState();
    createNewUser();
    // // updateUser();
    // deleteUser();
  }

  createNewUser() async {
    // await usersRef.doc('ihweui25').update({
    //   'userName': 'Mimi',
    //   'isAdmin': true,
    //   'postCount': 99,
    // });
  }

  updateUser() async {
    // usersRef.doc('ihweui25').set({
    //   'userName': 'new mimi',
    //   'isAdmin': true,
    //   'postCount': 99,
    // });
  }

  deleteUser() async {
    // final DocumentSnapshot doc = await usersRef.doc('ihweui23').get();
    // if (doc.exists) {
    //   doc.reference.delete();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
    // return Scaffold(
    //     appBar: header(isAppTitle: true),
    //     body: StreamBuilder<QuerySnapshot>(
    //         // here we can use Stream or Future Builder
    //         stream: usersRef.snapshots(),
    //         builder: (context, snapshot) {
    //           if (snapshot.hasData) {
    //             // put the data in this list view and use it
    //             final List<Text> children = snapshot.data!.docs
    //                 .map((doc) => Text(doc['userName']))
    //                 .toList();
    //             return SizedBox(
    //               child: ListView(
    //                 children: children,
    //               ),
    //             );
    //           } else {
    //             return circularProgress();
    //           }
    //         })
    //     );
  }
}
