import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

                  // Forgot password feature from the login page....commented this out.. Will be using audrey's
                  // const SizedBox(height: 10),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.pushNamed(context, '/settings');
                  //   },
                  //   child: const Text(
                  //     "Forgot password?",
                  //     style: TextStyle(
                  //         color: Colors.grey,
                  //         decoration: TextDecoration.underline),
                  //   ),
                  // ),
                  //

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
                        onPressed: () {
                          String email = emailController.text;
                          String password = newPWController.text;

                          //checkingif input is being taken or not,
                          //print("Email: $email");
                          //print('Password: $password');

                          //if statment that will only go to map if both email
                          //and password meet the criteria

                          if (!isEmailValid(email)) {
                            showErrorDialog(context, 'Invalid email address.');
                            return;
                          } else if (!sPValid(password)) {
                            showErrorDialog(context, 'Invalid password.');
                            return;
                          } else {
                            Navigator.pushNamed(context, '/map');
                          }
                        },
                        color: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        child: const Text(
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
                          showResetPasswordDialog();
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

  void showResetPasswordDialog() {
    // clear any previous input
    newPWController.clear();
    confirmPWController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      obscureText: true,
                      controller: newPWController,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    passwordCriteriaWidget(newPWController.text),
                    TextField(
                      obscureText: true,
                      controller: confirmPWController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                      ),
                    ),
                  ],
                ),
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
                    String newPasssword = newPWController.text;
                    String confirmPassword = confirmPWController.text;
                    if (newPasssword != confirmPassword) {
                      showErrorDialog(context, 'Passwords do not match');
                    }
                    if (!sPValid(newPasssword)) {
                      showErrorDialog(context, 'Please enter a valid password');
                      return;
                    } else {
                      // Handle confirm button press and reset password
                      // TODO: Update the password in database
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
