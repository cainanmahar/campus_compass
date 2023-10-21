import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Campus Compass",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome to the Campus Compass Navigation App for SHSU',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              /*
              Removed home screen image to add more buttons for testing
              Leaving code here in case we want to use home screen
              in final application.
              const SizedBox(height: 30),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/sh_bearkat.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),*/

              // Login Button
              const SizedBox(height: 20),
              MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: () {
                  // Navigate to the LoginPage when the login button is pressed
                  Navigator.pushNamed(context, '/login');
                },
                color: Colors.orange[300],
                shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(40)),
                child: const Text(
                  'Login',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black),
                ),
              ),

              // Sign Up Button
              const SizedBox(height: 20),
              MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: () {
                  // handle sign up button
                  // Navigate to sign up page when the button is pressed
                  Navigator.pushNamed(context, '/signup');
                },
                color: Colors.lightBlue[800],
                shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(40)),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              // Map Button
              const SizedBox(height: 20),
              MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: () {
                  // handle sign up button
                  // Navigate to sign up page when the button is pressed
                  Navigator.pushNamed(context, '/map');
                },
                shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(40)),
                child: const Text(
                  'Map',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),

              // Add Classes Button
              const SizedBox(height: 20),
              MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: () {
                  // handle sign up button
                  // Navigate to sign up page when the button is pressed
                  Navigator.pushNamed(context, '/addclass');
                },
                color: Colors.lightBlue[800],
                shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(40)),
                child: const Text(
                  'Add Classes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              // FAQ Button
              const SizedBox(height: 20),
              MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: () {
                  // handle sign up button
                  // Navigate to sign up page when the button is pressed
                  Navigator.pushNamed(context, '/faq');
                },
                color: Colors.orange[300],
                shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(40)),
                child: const Text(
                  'FAQ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),

              // Settings Button
              const SizedBox(height: 20),
              MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: () {
                  // handle sign up button
                  // Navigate to sign up page when the button is pressed
                  Navigator.pushNamed(context, '/settings');
                },
                color: Colors.lightBlue[800],
                shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(40)),
                child: const Text(
                  'Settings',
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
    );
  }
}
