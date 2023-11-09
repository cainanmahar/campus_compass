import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');

  final DatabaseReference _coursesRef =
      FirebaseDatabase.instance.ref().child('courses');

  final FirebaseAuth auth =
      FirebaseAuth.instance; // Firebase authentication instance

  // Method to create a new user profile in the database
  Future<void> createUserProfile(
      String uid, Map<String, dynamic> userData) async {
    await _usersRef.child(uid).set(userData);
  }

  // Method to update the user's name
  Future<void> updateUserName(
      String uid, String firstName, String lastName) async {
    await _usersRef.child(uid).update({
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  // Method to update the user's email in the database
  Future<void> updateUserEmail(String uid, String newEmail) async {
    await _usersRef.child(uid).update({
      'email': newEmail,
    });
  }

  // method to fetch all courses
  Future<Map<String, dynamic>?> fetchCourses() async {
    // retrieves the snapshot for the courses
    DataSnapshot snapshot = await _coursesRef.get();
    // check if the snapshop exists and the value is a Map
    if (snapshot.exists && snapshot.value is Map) {
      // cast the snapshot value to Map<String, dynamic> and return it
      return Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
    }
    // return null if no data is found or the data is not a Map
    return null;
  }

  // method to fetch sections for a specific course
  Future<List<Map<String, dynamic>>> fetchSections(String courseKey) async {
    try {
      print('Fetching sections for course key: $courseKey'); // debugging

      // retrieves the snapshot for the sections under a specific course
      DataSnapshot snapshot =
          await _coursesRef.child(courseKey).child('sections').get();
      print('Snapshot key: ${snapshot.key}'); // debugging

      // check if snapshot exists
      if (snapshot.exists) {
        print('Snapshot exists, raw value: ${snapshot.value}'); // debugging
        if (snapshot.value is List) {
          // initialize an empty list to hold the sections
          List<Map<String, dynamic>> sections = [];
          // iterate through the list to hold the sections
          for (var value in (snapshot.value as List)) {
            // skip null values
            if (value != null) {
              // add the section to the list after casting it to a Map<String, dynamic>
              sections.add(Map<String, dynamic>.from(value));
            }
          }
          // return the list of sections
          return sections;
        } else {
          print('Snapshot value is not a List'); // debugging
        }
      } else {
        print(
            'Snapshot does not exist for course key: $courseKey'); // debugging
      }
    } catch (e) {
      print(
          'Error fetching sections for course key: $courseKey, Error: $e'); // error logging
    }
    return [];
  }
  // Add database methods here
}
