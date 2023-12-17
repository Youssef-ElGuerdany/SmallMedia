import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    padding: const EdgeInsets.only(top: 10.0),
    alignment: Alignment.center,
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Color(0xFFFFD700),
      ),
    ),
  );
}

Container linearProgress() {
  return Container(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Color.fromARGB(193, 253, 217, 11),
      ),
    ),
  );
}
