import 'package:flutter/material.dart';
//import 'package:my_app/login_page.dart';

class FaqPage extends StatelessWidget {
  final List<String> questions = [
    'How do I create an Account?',
    'How can I reset my password?',
    'How can I see my classes?',
  ];

  final List<String> answers = [
    'You can create an account by clicking on the "Sign Up" button on the homepage.',
    'Click on the "Forgot Password" link on the login page to reset your password.',
    'After logging in, navigate to the "Add Classes" section in the collapisble menu on the map page.',
  ];
  FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
          title: const Text(
            'FAQ',
          ),
          backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 30),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${questions[index]}',
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    answers[index],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
