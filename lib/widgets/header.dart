import 'package:flutter/material.dart';

AppBar header({bool isAppTitle = false, String titleText = ''}) {
  return AppBar(
    centerTitle: true,
    backgroundColor: const Color(0xFFFFD700),
    title: Text(
      isAppTitle ?'Share App' : titleText,
      style: TextStyle(
          color: Colors.black,
          fontFamily: isAppTitle ? 'Signatra' : '',
          fontSize: isAppTitle ? 40.0 : 20.0),
    ),
  );
}
