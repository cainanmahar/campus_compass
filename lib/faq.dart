import 'package:flutter/material.dart';
//import 'package:my_app/login_page.dart';

class FaqPage extends StatelessWidget {
  final List<String> questions = [
    'How do I create an Account ?',
    'How can I reset my password ?',
    'How can I see my classes ?',
    '                          '
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
          title: const Text(
            'FAQ',
          ),
          backgroundColor: const Color.fromARGB(255, 240, 108, 7)),
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 30),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                '${index + 1}. ${questions[index]}',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}
