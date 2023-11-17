import 'package:campus_compass/dialog_utils.dart';
import 'package:campus_compass/form_validation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with formValidation, DialogUtils {
  final DatabaseService dbService = DatabaseService();
  final AuthService authService = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPWController = TextEditingController();
  final TextEditingController newPWController = TextEditingController();
  final TextEditingController confirmPWController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.lightBlue[800],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center horizontally
                children: [
                  const Text(
                    'Account Settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  const SizedBox(height: 100),

                  // Change Name Button
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      _showChangeNameDialog();
                    },
                    color: Colors.lightBlue[800],
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Text(
                      'Change Name',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Change Password Button
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      showResetPasswordDialog(
                          context, authService, isEmailValid);
                    },
                    color: Colors.lightBlue[800],
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Text(
                      'Change Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to show the "Change Name" dialog
  void _showChangeNameDialog() {
    firstNameController.clear();
    lastNameController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                ),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Handle cancel button press
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Get the first and last name from the text controllers
                String newFirstName = firstNameController.text.trim();
                String newLastName = lastNameController.text.trim();

                // Perform some basic validation
                if (newFirstName.isEmpty || newLastName.isEmpty) {
                  showErrorDialog(
                      context, 'Please enter both first and last names.');
                  return;
                }

                User? user = authService.getCurrentUser();
                if (user != null) {
                  dbService
                      .updateUserName(user.uid, newFirstName, newLastName)
                      .then((_) {
                    // Handle successful update, like showing a success message
                    // Show success message using SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Name updated successfully!'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                    Navigator.of(context).pop(); // Close the dialog
                    // You might want to refresh the UI or state at this point
                  }).catchError((error) {
                    // Handle errors
                    showErrorDialog(context, 'Failed to update name: $error');
                  });
                } else {
                  showErrorDialog(context, 'No user is signed in.');
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
