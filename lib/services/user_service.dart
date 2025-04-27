import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_wisp/models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserData> getCurrentUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User authentication required");
    }

    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();

      if (!snapshot.exists) {
        throw Exception("User document not found in database");
      }

      final data = snapshot.data();

      if (data is! Map<String, dynamic>) {
        throw FormatException("Invalid user data structure");
      }

      return UserData.fromMap(data);
    } on FirebaseException catch (e) {
      throw Exception("Firestore operation failed: ${e.code} - ${e.message}");
    } catch (e) {
      throw Exception("User data fetch failed: ${e.toString()}");
    }
  }

  Future<void> updateUserData(UserData userData) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User authentication required");
    }

    try {
      await _firestore.collection('users').doc(user.uid).update(userData.toMap());
    } on FirebaseException catch (e) {
      throw Exception("Firestore update failed: ${e.code} - ${e.message}");
    } catch (e) {
      throw Exception("User data update failed: ${e.toString()}");
    }
  }
}
