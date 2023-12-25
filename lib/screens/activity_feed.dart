import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/screens/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({super.key});

  @override
  State<ActivityFeed> createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    try {
      QuerySnapshot snapshot = await activityFeedRef
          .doc(currentUser!.id)
          .collection('feedItems')
          .orderBy('timestamp', descending: true)
          .get();

      List<ActivityFeedItem> feedItems = [];
      for (var element in snapshot.docs) {
        feedItems.add(ActivityFeedItem.fromDocument(element));
      }
      return feedItems;
    } catch (e) {
      print('Error fetching activity feed: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: header(titleText: 'Activity feed'),
      body: SizedBox(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error fetching data');
            }
            if (snapshot.hasData) {
              // Return the actual data here
              return ListView(
                children: (snapshot.data as List<ActivityFeedItem>)
                    .map((item) => item.build(context))
                    .toList(),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

late Widget mediaPreview;
late String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String postId;
  final String type; // LIKE OR FOLLOW  OR COMMENT
  final String mediaUrl;
  final String userProfileImg;
  final String commentData;
  final String timetsamp;

  const ActivityFeedItem(
      {super.key,
      required this.username,
      required this.userId,
      required this.type,
      required this.postId,
      required this.mediaUrl,
      required this.userProfileImg,
      required this.commentData,
      required this.timetsamp});

  factory ActivityFeedItem.fromDocument(doc) {
    return ActivityFeedItem(
        username: doc['username'],
        userId: doc['userId'],
        type: doc['type'],
        postId: doc['postId'],
        mediaUrl: doc['mediaUrl'],
        userProfileImg: doc['userProfileImg'],
        commentData: doc['commentData'],
        timetsamp: doc['timetsamp']);
  }
  configureMediaPreview() {
    if (type == 'like' || type == 'comment') {
      mediaPreview = GestureDetector(
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(mediaUrl)))),
          ),
        ),
      );
    } else {
      mediaPreview = const Text('');
    }

    if (type == 'like') {
      activityItemText = 'liked your post';
    } else if (type == 'follow') {
      activityItemText = 'is following yoy';
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else {
      activityItemText = 'Error: Unknown type $type';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: const TextStyle(fontSize: 14.0, color: Colors.black),
                  children: [
                    TextSpan(
                        text: username,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' $activityItemText'),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
