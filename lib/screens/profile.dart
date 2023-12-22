import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user_infos.dart';
import 'package:fluttershare/screens/edit_profile.dart';
import 'package:fluttershare/screens/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String? profileId;
  const Profile({super.key, required this.profileId});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String currentUserId = currentUser!.id;
  String postOrientation = 'grid';
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  void getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  editProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditProfile(currentUSerId: currentUserId); // Fixed variable name
    }));
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(text: 'Edit Profile', function: editProfile);
    }
  }

  buildButton({String? text, VoidCallback? function}) {
    return Container(
      padding: const EdgeInsets.only(top: 2.0),
      child: InkWell(
        onTap: function,
        child: Container(
          width: 210.0,
          height: 24.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text(
            text ?? '',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
                fontSize: 15.0),
          ),
        )
      ],
    );
  }

  buildProfileHeader() {
    return FutureBuilder(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          UserInfos user = UserInfos.fromDocument(snapshot.data!);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.orange,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                    ),
                    Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildCountColumn('posts', postCount),
                                buildCountColumn('followers', 0),
                                buildCountColumn('following', 0),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [buildProfileButton()],
                            )
                          ],
                        ))
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    user.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    user.bio,
                  ),
                )
              ],
            ),
          );
        });
  }

  buidldProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 50),
        child: Center(
          child: Text(
            'No content',
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    } else if (postOrientation == 'grid') {
      List<GridTile> gridTiles = [];
      for (var post in posts) {
        gridTiles.add(GridTile(child: PostTile(post: post)));
      }
      return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 1.5,
          crossAxisSpacing: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: gridTiles);
    } else if (postOrientation == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            onPressed: () => setPostOrientation('grid'),
            icon: Icon(
              Icons.grid_on,
              color: postOrientation == 'grid' ? Colors.yellow : Colors.grey,
            )),
        IconButton(
            onPressed: () => setPostOrientation('list'),
            icon: Icon(
              Icons.list,
              color: postOrientation == 'list' ? Colors.yellow : Colors.grey,
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(titleText: 'Profile'),
      body: ListView(
        children: [
          buildProfileHeader(),
          const Divider(),
          buildTogglePostOrientation(),
          const Divider(
            height: 0.0,
          ),
          buidldProfilePosts(),
        ],
      ),
    );
  }
}
