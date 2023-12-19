import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user_infos.dart';
import 'package:fluttershare/screens/activity_feed.dart';
import 'package:fluttershare/screens/create_account.dart';
import 'package:fluttershare/screens/profile.dart';
import 'package:fluttershare/screens/search.dart';
import 'package:fluttershare/screens/upload.dart'; 
import 'package:google_sign_in/google_sign_in.dart';

Reference storageRef = FirebaseStorage.instance.ref();
  final postsRef = FirebaseFirestore.instance.collection('posts');
   UserInfos? currentUser;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //  VARIABLES

  int pageIndex = 0;
  PageController pageController = PageController();
  bool isAuth = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final usersRef = FirebaseFirestore.instance.collection('users');
  final timestamp = DateTime.now();

  void login() async {
    try {
      await googleSignIn.signIn();
    } catch (error) {
      debugPrint('Error signing in: $error');
    }
  }

  void logOut() async {
    await googleSignIn.signOut();
    debugPrint('Log out successfully !');
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        curve: Curves.bounceInOut, duration: const Duration(milliseconds: 300));
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when the user signs in
    if (googleSignIn.currentUser == null) {
      googleSignIn.onCurrentUserChanged.listen((account) {
        handleSignIn(account);
      }, onError: (errorInfos) {
        debugPrint('Error Sign in: $errorInfos');
      });
    } else {
      // Reauthenticate user when the app is opened
      googleSignIn
          .signInSilently(suppressErrors: false)
          .then((account) => handleSignIn(account))
          .catchError((errorInfo) {
        debugPrint('Error Sign in: $errorInfo');
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1 -check if the user exist in suers collection in data base (according to their id )
    final GoogleSignInAccount user = googleSignIn.currentUser!;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();
    // 2 -  if the user doesn't exist => take them to create  account page
    if (!doc.exists) {
      final username =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const CreateAccount();
      }));

      // 3 - get username from create account , use it to make new user document in user collection
      usersRef.doc(user.id).set({
        'id': user.id,
        'username': username,
        'photoUrl': user.photoUrl,
        'email': user.email,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timestamp
      });
      doc = await usersRef.doc(user.id).get();
    }
    currentUser = UserInfos.fromDocument(doc);
  }

  // Auth Screen
  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              Color(0xFF001F3F), // Deep Blue
              Color(0xFFFFD700), // Gold
            ])),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Share App',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Signatra', fontSize: 80),
            ),
            InkWell(
              onTap: login,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.white,
                  width: 200,
                  height: 60,
                  child: const Center(
                    child: Text(
                      'Sign in with Google ',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // UnAuth Screen
  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Timeline(),
          InkWell(
            onTap: logOut,
            child: const Icon(Icons.logout),
          ),
          const ActivityFeed(),
          Upload(currentUser: currentUser),
          const Search(),
           Profile(profileId: currentUser?.id)
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
            size: 35.0,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
        activeColor: const Color(0xFFFFD700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
