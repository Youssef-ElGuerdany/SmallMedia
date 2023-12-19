import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user_infos.dart';
import 'package:fluttershare/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUSerId;
  const EditProfile({super.key, required this.currentUSerId});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool isLoading = false;
  final usersRef = FirebaseFirestore.instance.collection('users');
  late UserInfos user;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUSerId).get();
    user = UserInfos.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  buildDisplayNameField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text('user name'),
        ),
        TextFormField(
          controller: displayNameController,
          decoration: const InputDecoration(hintText: 'update Display name'),
        )
      ],
    );
  }

  buildBioField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text('bio'),
        ),
        TextFormField(
          controller: bioController,
          decoration: const InputDecoration(hintText: 'update text bio'),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Edite Profile',
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.done,
                color: Colors.green,
              ))
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: [
                SizedBox(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.orange,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            buildDisplayNameField(),
                            buildBioField(),
                          ],
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {},
                          child: const Text('Update Profile')),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          label: const Text('Cancel'),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
