import "package:flutter/material.dart";
import 'package:campus_compass/Components/text_field.dart';
import 'package:campus_compass/faq.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orangeBackground(
        SafeArea(
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FaqPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.question_mark,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 50),
                const Text(
                  "Campus \nCompass",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 47,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Welcome back to Campus Compass!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // email address text field

                const LoginTextField(
                  hintText: "Email",
                ),
                const SizedBox(height: 25),
                // password text field
                const LoginTextField(
                  hintText: "Password",
                ),

                const SizedBox(height: 20),

                // forgot password

                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.white60),
                    ),
                  ],
                ),

                //sign in button
                ElevatedButton(
                    style: null, onPressed: () {}, child: const Text("Login")),

                //not a member? register now

                Divider(
                  thickness: 0.5,
                  color: Colors.grey[400],
                ),

                const SizedBox(height: 50),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New user?"),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      "Register Now",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//Function for Background Change
Widget orangeBackground(Widget child) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.deepOrangeAccent, Colors.orangeAccent, Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: child,
  );
}

//


