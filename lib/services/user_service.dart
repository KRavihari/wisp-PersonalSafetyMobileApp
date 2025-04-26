import 'package:app_wisp/models/user_model.dart';  // Only one import needed
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserData> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Enhanced error message
    if (user == null) throw Exception("User authentication required");
    
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      // More descriptive error
      if (!snapshot.exists) throw Exception("User document not found in database");
      
      final data = snapshot.data();
      
      // Type check with better error reporting
      if (data is! Map<String, dynamic>) {
        throw FormatException("Invalid user data structure");
      }
      
      return UserData.fromMap(data);
    } on FirebaseException catch (e) {
      // Preserve original error stack
      throw Exception("Firestore operation failed: ${e.code} - ${e.message}");
    } on Exception catch (e) {
      // Catch other exceptions
      throw Exception("User data fetch failed: ${e.toString()}");
    }
  }
}