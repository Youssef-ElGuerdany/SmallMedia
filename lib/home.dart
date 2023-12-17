import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAuth = false;
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

  @override
  void initState() {
    super.initState();
    // Detects when the user signs in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (errorInfos) {
      debugPrint('Error Sign in: $errorInfos');
    });

    // Reauthenticate user when the app is opened
    // googleSignIn
    //     .signInSilently(suppressErrors: false)
    //     .then((account) => handleSignIn(account))
    //     .catchError((errorInfo) {
    //   debugPrint('Error Sign in: $errorInfo');
    // });
  }

  void handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      debugPrint(account.toString());
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
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

  Widget buildAuthScreen() {
    return Scaffold(
      body: Center(
          child: InkWell(
        onTap: () {
          logOut(); // Call the logOut method when tapped
          setState(() {
            isAuth = false; // Update the authentication state
          });
        },
        child: const Text('Logout'),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
