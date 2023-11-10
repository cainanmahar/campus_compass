import 'package:flutter/material.dart';
import 'package:campus_compass/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final AuthService authService = AuthService();

  AppDrawer({super.key});

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
              // Store a reference to the ScaffoldMessenger before the async gap
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              // Attempt to sign out
              authService.signOut().then((_) {
                // Sign-out was successful
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('You have been signed out.'),
                  ),
                );
                // Redirect to the login or home page, or wherever you want to go
                Navigator.pushReplacementNamed(context, '/login');
              }).catchError((error) {
                // Sign-out failed
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Sign-out failed. Please try again.'),
                  ),
                );
              });
            },
          ),

          const Divider(
            color: Colors.grey,
          ),
          const ListTile(
            title: Text('Filters'),
          ),
          const ListTile(leading: Filters(), title: Text("Filter 1")),
          const ListTile(
            leading: Filters(),
            title: Text("Filter 2"),
          ),
          const ListTile(
            leading: Filters(),
            title: Text("Filter 3"),
          ),
          //ElevatedButton(onPressed: (){Filters.resetFilter();}, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),child: Text("Reset")),
        ],
      ),
    );
  }
}

class Filters extends StatefulWidget {
  const Filters({super.key});
  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.selected
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.white;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }

  void resetFilter() {
    setState(() {
      isChecked = false; //resets it back to false.
    });
  }
}
