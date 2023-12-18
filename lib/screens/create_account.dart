import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  late String username;
  final _formKey = GlobalKey<FormState>();
  submit() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $username"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      // timer
      Timer(const Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(titleText: 'set up your profil',removeBackButton: true),
        body: ListView(
          children: [
            Container(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text('Create user name'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Form(
                        autovalidateMode: AutovalidateMode.always,
                        key: _formKey,
                        child: TextFormField(
                          validator: (val) {
                            if (val!.trim().length < 3 || val.isEmpty) {
                              return 'user name to short';
                            } else if (val.trim().length > 12) {
                              return 'user name to long';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (val) => username = val!,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'user name ',
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: 'Must be at less 3 charachters'),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: submit,
                      child: const Text('Submit'),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
