import 'package:flutter/material.dart';
//import 'package:my_app/login_page.dart';
import 'package:getwidget/getwidget.dart';

class FaqPage extends StatelessWidget {
  // list of faq questions
  final List<String> questions = [
    'How do I create an Account?',
    'How can I reset my password?',
    'How can I see my classes?',
  ];

  // list of faq answers
  final List<String> answers = [
    'You can create an account by clicking on the "Sign Up" button on the homepage.',
    'Click on the "Forgot Password" link on the login page to reset your password.',
    'After logging in, navigate to the "Add Classes" section in the collapisble menu on the map page.',
  ];
  FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text(
            'FAQ',
          ),
          backgroundColor: Colors.lightBlue[800]),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return GFAccordion(
            title: questions[index],
            content: answers[index],
            collapsedIcon: const Icon(Icons.add),
            expandedIcon: const Icon(Icons.arrow_drop_up),
          );
        },
      ),
    );
  }
}
