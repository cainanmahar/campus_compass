import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

                  /* Change Email button
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      _showChangeEmailDialog();
                    },
                    color: Colors.lightBlue[800],
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Text(
                      'Change Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),*/

                  // Change Password Button
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      showResetPasswordDialog(context, authService);
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

                User? user = FirebaseAuth.instance.currentUser;
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

  void showResetPasswordDialog(BuildContext context, AuthService authService) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                    'Enter your email address and we will send you a link to reset your password.'),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String email = emailController.text.trim();
                if (email.isEmpty || !isEmailValid(email)) {
                  showErrorDialog(
                      dialogContext, 'Please enter a valid email address.');
                  return;
                }

                // Disable the send button while processing
                Navigator.of(dialogContext).pop();
                await authService.sendPasswordResetEmail(email).then((_) {
                  // The then callback ensures we're still in a valid context
                  showConfirmationDialog(
                      context, 'Check your email to reset your password.');
                }).catchError((error) {
                  showErrorDialog(context,
                      'Failed to send password reset email: ${error.toString()}');
                });
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }

  // Shows a dialog with the confirmation message
  void showConfirmationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Sent'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Createria that email must follow
  bool isEmailValid(String email) {
    String emailPattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.[a-z]{2,})$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  //Method to check if password contains an uppercase letter
  bool containsLowercase(String password) {
    return RegExp(r'[a-z]').hasMatch(password);
  }

  //Method to check if password contains an uppercase letter
  bool containsUppercase(String password) {
    return RegExp(r'[A-Z]').hasMatch(password);
  }

  // Method to check if password contains a number
  bool containsNumber(String password) {
    return RegExp(r'[0-9]').hasMatch(password);
  }

  //Method to check if password contains a symbol
  bool containsSymbol(String password) {
    return RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  bool sPValid(String password) {
    // Check password length (at least 8 characters)
    if (password.length < 8) {
      return false;
    }
    if (!containsLowercase(password) ||
        !containsUppercase(password) ||
        !containsNumber(password) ||
        !containsSymbol(password)) {
      return false;
    }
    return true;
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Widget to display password criteria
  Widget passwordCriteriaWidget(String password) {
    return Column(
      children: [
        criteriaRow('At least 8 characters', password.length >= 8),
        criteriaRow('At least 1 uppercase', containsUppercase(password)),
        criteriaRow('At least 1 number', containsNumber(password)),
        criteriaRow('At least 1 symbol', containsSymbol(password)),
      ],
    );
  }

  // Widget for individual criteria row
  Widget criteriaRow(String criteria, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check : Icons.close,
          color: isMet ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 10),
        Text(criteria,
            style: TextStyle(color: isMet ? Colors.green : Colors.red)),
        const SizedBox(height: 10),
      ],
    );
  }
}

/* // Function to show the "Change Email" dialog box
  void _showChangeEmailDialog() {
    // clear out any previous input
    emailController.clear();
    confirmEmailController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: confirmEmailController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Email',
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
                String email = emailController.text;
                String confirmEmail = confirmEmailController.text;
                if (email != confirmEmail) {
                  showErrorDialog(context, 'Emails do not match.');
                  return;
                }
                //String confirmEmail = _confirmEmailController.text;
                else if (!isEmailValid(email)) {
                  showErrorDialog(context, 'Please enter a valid email.');
                  return;
                } else {
                  // Handle confirm button press and update the email
                  // TODO: Update the email in database
                  // Close the dialog
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }*/
