import 'package:campus_compass/auth_service.dart';
import 'package:flutter/material.dart';

mixin DialogUtils {
  // Function to show error when user enters invalid info
  // Takes in a string to display the desired error message to the user
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

  // Shows a dialog with the confirmation message that an email was sent
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

  // Dialog box that allows the user to enter their email
  // sends email link to user to reset password
  void showResetPasswordDialog(BuildContext context, AuthService authService,
      bool Function(String) validateEmailFunction) {
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
                if (email.isEmpty || !validateEmailFunction(email)) {
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
}
