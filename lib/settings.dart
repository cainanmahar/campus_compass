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
      body: ListView(
        children: const <Widget>[
          ListTile(
            title: Text('Change Email'),
            subtitle: Text("Email"),
            //onTap: _changeEmailDialog,
          ),
          ListTile(
            title: Text('Change Password'),
            subtitle: Text('********'),
            //onTap: _changePasswordDialog,
          ),
          // Other settings options can be added here
        ],
      ),
    );
  }
}
