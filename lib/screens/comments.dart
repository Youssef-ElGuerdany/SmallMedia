import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/screens/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  const Comments({
    Key? key,
    required this.postId,
    required this.postOwnerId,
    required this.postMediaUrl,
  }) : super(key: key);

  @override
  State<Comments> createState() => _CommentsState(
        postId: postId,
        postOwnerId: postOwnerId,
        postMediaUrl: postMediaUrl,
      );
}

class _CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  _CommentsState({
    required this.postId,
    required this.postOwnerId,
    required this.postMediaUrl,
  });

  buildComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: commentsRef
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<Comment> comments = [];
        for (var doc in snapshot.data!.docs) {
          comments.add(Comment.fromDocument(doc));
        }

        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment() {
    commentsRef.doc(postId).collection('comments').add({
      'username': currentUser?.username ?? 'Unknown User',
      'comment': commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'avatarUrl': currentUser?.photoUrl ?? '',
      'userId': currentUser?.id ?? '',
    });
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(titleText: 'Comments'),
      body: Column(
        children: [
          Expanded(
            child: buildComments(),
          ),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: const InputDecoration(labelText: 'Write a comment ...'),
            ),
            trailing: OutlinedButton(
              onPressed: addComment,
              child: const Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  const Comment({
    Key? key,
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  }) : super(key: key);

 factory Comment.fromDocument(DocumentSnapshot doc) {
  return Comment(
    avatarUrl: doc['avatarUrl'],
    comment: doc['comment'],
    timestamp: doc['timestamp'] as Timestamp? ?? Timestamp.now(), // Handle null
    userId: doc['userId'],
    username: doc['username'],
  );
}


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(timeago.format(timestamp.toDate())),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(comment),
        ),
        const Divider(),
      ],
    );
  }
}
