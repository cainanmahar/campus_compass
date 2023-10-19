import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.lightBlue[800],
      ),
      body: SafeArea(
          child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Account Settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  SizedBox(height: 20),
                ],
              ))),

      /* ListView(
        children: <Widget>[
          ElevatedButton(
            onPressed: () {}, //_changeEmailDialog,
            child: const Text('Change Email'),
          ),
          ElevatedButton(
            onPressed: () {}, //_changePasswordDialog,
            child: const Text('Change Password'),
          ),
          // Other settings options can be added here
        ],
      ),*/
    );
  }
}
