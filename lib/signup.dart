import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
                        onPressed: () {
                          String email = emailController.text;
                          String password = newPWController.text;
                          String confirmPassword = confirmPWController.text;
                          if (!isEmailValid(email)) {
                            showErrorDialog(context, 'Invalid email address.');
                            return;
                          } else if (password != confirmPassword) {
                            showErrorDialog(context, 'Passwords do not match.');
                            return;
                          } else if (!sPValid(password)) {
                            showErrorDialog(context, 'Invalid password.');
                            return;
                          } else {
                            Navigator.pushNamed(context, '/login');
                          }
                        },
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

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPWController = TextEditingController();
  final TextEditingController confirmPWController = TextEditingController();

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

  // Function to show error when user enters invalid info
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
