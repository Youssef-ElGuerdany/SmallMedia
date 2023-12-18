import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfos {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  UserInfos(
     this.id,
     this.username, 
     this.email,
     this.photoUrl,
     this.displayName,
    this.bio);
      
  factory UserInfos.fromDocument(DocumentSnapshot doc) {
    return UserInfos(
      doc['id'],
      doc['username'],
      doc['email'],
      doc['photoUrl'],
      doc['displayName'],
      doc['bio']);
  }
}
