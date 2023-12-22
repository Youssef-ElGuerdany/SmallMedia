import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user_infos.dart';
import 'package:fluttershare/screens/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:google_sign_in/google_sign_in.dart';

class EditProfile extends StatefulWidget {
  final String currentUSerId;
  const EditProfile({super.key, required this.currentUSerId});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  final usersRef = FirebaseFirestore.instance.collection('users');
  late UserInfos user;
  bool _bioValid = true;
  bool _displayNameValid = true;
  final GoogleSignIn googleSignIn = GoogleSignIn();
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
          decoration: InputDecoration(
              errorText: _displayNameValid ? null : 'Display name too short',
              hintText: 'update Display name'),
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
          decoration: InputDecoration(
              errorText: _bioValid ? null : 'Bio is too long',
              hintText: 'update text bio'),
        )
      ],
    );
  }

  void updateProfileData() {
    setState(() {
      _displayNameValid = displayNameController.text.trim().length >= 3 &&
          displayNameController.text.isNotEmpty;

      _bioValid = bioController.text.trim().length <= 100;
    });

    if (_displayNameValid && _bioValid) {
      usersRef.doc(widget.currentUSerId).update({
        'displayName': displayNameController.text,
        'bio': bioController.text,
      });
      Widget snackBar = const Text('upadate profile');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: snackBar,
      ));
    }
  }

  logout() {
    googleSignIn.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                          onPressed: updateProfileData,
                          child: const Text('Update Profile')),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          label: const Text('log out'),
                          onPressed: logout,
                          icon: const Icon(
                            Icons.logout,
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
