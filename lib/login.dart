import 'package:campus_compass/auth_service.dart';
import 'package:campus_compass/dialog_utils.dart';
import 'package:campus_compass/form_validation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with formValidation, DialogUtils {
  bool isLoading = false;
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmPWController = TextEditingController();
  final TextEditingController newPWController = TextEditingController();
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
                      // login screen title
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
                  // Text Fields for user to enter email and password
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
                  // login button with login functionality
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

                          // checks if email is valid (contains @)
                          if (!isEmailValid(email)) {
                            showErrorDialog(context, 'Invalid email address.');
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                            return;
                            // checks if password follows criteria
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
                        // login button
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
                          showResetPasswordDialog(
                              context, authService, isEmailValid);
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
}

// Widget to create input boxes
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
