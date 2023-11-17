import 'package:flutter/material.dart';

mixin formValidation {
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
