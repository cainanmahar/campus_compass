import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer header
          DrawerHeader(
            decoration: const BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Campus Compass'),
                const SizedBox(height: 10),
                // Add Classes Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/addclass');
                  },
                  icon: const Icon(Icons.add_box),
                  label: const Text('Add Classes'),
                ),
              ],
            ),
          ),

          //Settings icon
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),

          // FAQs icon
          ListTile(
            leading: const Icon(Icons.question_mark),
            title: const Text('FAQs'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/faq');
            },
          ),

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Close drawer first
              Navigator.pop(context);
              // Navigate back to home screen
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
    );
  }
}
