import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
   late String username ;
  final _formKey = GlobalKey<FormState>();
  submit() {
    _formKey.currentState!.save();
    Navigator.pop(context, username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(titleText: 'set up your profil'),
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
                        key: _formKey,
                        child: TextFormField(
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
