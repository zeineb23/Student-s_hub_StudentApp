import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersCRUD {
  static Future<Map<String, String>> fetchUserDetails(User? user) async {
    late String username;
    late String email;

    try {
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('student')
            .doc(user.email)
            .get();

        if (userSnapshot.exists) {
          username = userSnapshot.get('username') ?? '';
          email = user.email ?? '';
        } else {
          // Initialize in case userSnapshot doesn't exist
          username = '';
          email = '';
        }
      } else {
        // Initialize when user is null
        username = '';
        email = '';
      }
    } catch (e) {
      print('Error fetching user details: $e');
      // Initialize in case of error
      username = '';
      email = '';
    }
    return {'username': username, 'email': email};
  }
}
