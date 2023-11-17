import 'package:campus_compass/dialog_utils.dart';
import 'package:campus_compass/form_validation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'database_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with formValidation, DialogUtils {
  final AuthService authService = AuthService();
  final DatabaseService dbService = DatabaseService();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPWController = TextEditingController();
  final TextEditingController confirmPWController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue[800],
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Column(
                children: [
                  const SizedBox(height: 30),
                  // ignore: prefer_const_constructors
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Create an Account, It's Free",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blueGrey,
                        ),
                      ),
                      SizedBox(height: 20)
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        makeInput(
                            label: "First Name",
                            controller: firstNameController),
                        makeInput(
                            label: "Last Name", controller: lastNameController),
                        makeInput(label: "Email", controller: emailController),
                        makeInput(
                          label: "Password",
                          obscureText: true,
                          controller: newPWController,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        passwordCriteriaWidget(newPWController.text),
                        const SizedBox(height: 10),
                        makeInput(
                            label: "Confirm Password",
                            obscureText: true,
                            controller: confirmPWController),
                      ],
                    ),
                  ),
                  // Sign up button with functionality to register a new user
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: const EdgeInsets.only(top: 3, left: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () async {
                          // controllers for input fields
                          String email = emailController.text;
                          String password = newPWController.text;
                          String confirmPassword = confirmPWController.text;
                          String firstName = firstNameController.text;
                          String lastName = lastNameController.text;
                          // verify email is valid (contains @)
                          if (!isEmailValid(email)) {
                            showErrorDialog(context, 'Invalid email address.');
                            return;
                            // verify both password and confirm password match
                          } else if (password != confirmPassword) {
                            showErrorDialog(context, 'Passwords do not match.');
                            return;
                            // verify the password follows password criteria
                          } else if (!sPValid(password)) {
                            showErrorDialog(context, 'Invalid password.');
                            return;
                          }
                          // If all validations pass, proceed with user registration
                          try {
                            // Use AuthService to create the user
                            UserCredential userCredential = await authService
                                .createUserWithEmailAndPassword(
                                    email, password);

                            // Get the user's unique ID
                            String uid = userCredential.user!.uid;

                            // Create user data
                            Map<String, dynamic> userData = {
                              'firstName': firstName,
                              'lastName': lastName,
                              'courses':
                                  [], // Initialize with an empty array of courses
                              'preferences': {},
                            };

                            // Use DatabaseService to store the additional information
                            await dbService.createUserProfile(uid, userData);
                            if (!mounted) {
                              return;
                            }
                            // If the user is successfully created, navigate to the login page
                            Navigator.pushNamed(context, '/login');
                          } catch (e) {
                            if (!mounted) {
                              return;
                            }
                            showErrorDialog(
                                context, 'Failed to sign up: ${e.toString()}');
                          }
                        },
                        // sign up button styling
                        color: Colors.lightBlue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Text("Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    // login link
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?  "),
                      GestureDetector(
                        onTap: () {
                          // Navigate to login page
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          "Login",
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

// Widget to make input fields
Widget makeInput(
    {label,
    obscureText = false,
    required TextEditingController controller,
    Function(String)? onChanged}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      const SizedBox(
        height: 3,
      ),
      TextField(
        onChanged: onChanged,
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
        height: 15,
      )
    ],
  );
}
