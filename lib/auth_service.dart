import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // Method to register with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Method to send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    return await _auth.sendPasswordResetEmail(email: email);
  }

  // Method to sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Method to get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Method to listen to auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Method to update the user's email
  Future<void> updateEmail(String newEmail) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateEmail(newEmail);
    } else {
      throw FirebaseAuthException(
        code: 'no-user-signed-in',
        message: 'No user signed in to update email',
      );
    }
  }
}
