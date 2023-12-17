import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  const Timeline({super.key});

  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    getUsers();
    super.initState();
  }

  getUsers() async {
    // Get users by query selector Where() , and we can also take multupl Where().where.where()...
    final QuerySnapshot snapshot = await usersRef
        // limit(1) Query => return one user
        // .where('postCount', isGreaterThan: 10)
        // .where('userName', isEqualTo: 'youssef')
        .orderBy("postCount", descending: true)
        .get();

    for (var doc in snapshot.docs) {
      debugPrint(doc.data().toString());
      debugPrint(doc.id);
      debugPrint(doc.exists.toString());
    }
  }

  // getUsersById() async {
  //   const String userID = 'BwoqR0NN2du7U4VAEI1c';
  //   final DocumentSnapshot doc = await usersRef.doc(userID).get();
  //   print(doc.id);
  //   //  then((DocumentSnapshot doc) {
  //   //   print(doc.data());
  //   //   print(doc.id);
  //   //   print(doc.exists);
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: header(isAppTitle: true), body: linearProgress());
  }
}
