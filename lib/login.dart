import 'package:campus_compass/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        leading: IconButton(
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to the FAQ page when the question mark icon is pressed
              Navigator.pushNamed(context, '/faq');
            },
            icon: const Icon(
              Icons.question_mark,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        reverse: true, // Scroll content upwards when the keyboard appears
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Column(
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Welcome back! Login with your credentials',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                  // Text Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        makeInput(label: 'Email', controller: emailController),
                        makeInput(
                            label: 'Password',
                            obscureText: true,
                            controller: newPWController),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(top: 3, left: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () async {
                          // set loading to true
                          setState(() {
                            isLoading = true;
                          });

                          String email = emailController.text;
                          String password = newPWController.text;

                          if (!isEmailValid(email)) {
                            showErrorDialog(context, 'Invalid email address.');
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                            return;
                          } else if (!sPValid(password)) {
                            showErrorDialog(context, 'Invalid password.');
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                            return;
                          }
                          try {
                            // Use the AuthService to sign in with email and password
                            await authService.signInWithEmailAndPassword(
                                email, password);
                            // if successful go to map
                            if (mounted) {
                              Navigator.pushNamed(context, '/map');
                            }
                          } on FirebaseAuthException catch (e) {
                            // Handle the firebase authentication error
                            if (mounted) {
                              showErrorDialog(
                                  context,
                                  e.message ??
                                      'An error occured during sign in');
                              setState(() {
                                isLoading = false;
                              });
                            }
                          } catch (e) {
                            if (mounted) {
                              // Handles other errors
                              showErrorDialog(context, e.toString());
                              setState(() {
                                isLoading = false;
                              });
                            }
                          } finally {
                            if (mounted) {
                              // Set loading to false
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                        color: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // reset password button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Forgot your password? "),
                      GestureDetector(
                        onTap: () {
                          showResetPasswordDialog(context, authService);
                        },
                        child: const Text(
                          "Reset Password",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),

                  // sign up link
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          //Navigate to the sign up page
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Assuming you have an instance of AuthService available in your widget
// If not, you can create one like this:
// AuthService authService = AuthService();

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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmPWController = TextEditingController();
  final TextEditingController newPWController = TextEditingController();

//Createria that email mus follow
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

// for input boxes
Widget makeInput(
    {label, obscureText = false, required TextEditingController controller}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      const SizedBox(
        height: 5,
      ),
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          border:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        ),
      ),
      const SizedBox(
        height: 30,
      )
    ],
  );
}

//P@ssw0rd
//user@example.com
