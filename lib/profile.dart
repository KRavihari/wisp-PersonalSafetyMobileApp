import 'package:flutter/material.dart';
import 'package:app_wisp/models/user_model.dart';
import 'package:app_wisp/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  late Future<UserData> _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _userData = _userService.getCurrentUserData();
  }

  void _showEditDialog(UserData user) {
    TextEditingController nameController = TextEditingController(text: user.name);
    TextEditingController phoneController = TextEditingController(text: user.phone);
    TextEditingController emailController = TextEditingController(text: user.email);
    TextEditingController guardianPhoneController = TextEditingController(text: user.guardianPhone);
    TextEditingController guardianEmailController = TextEditingController(text: user.guardianEmail);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Name', nameController),
                _buildTextField('Phone', phoneController),
                _buildTextField('Email', emailController),
                _buildTextField('Guardian Phone', guardianPhoneController),
                _buildTextField('Guardian Email', guardianEmailController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save changes to Firestore
                final uid = FirebaseAuth.instance.currentUser?.uid; // Use FirebaseAuth to get current user's UID

                if (uid == null) {
                  // Handle the case where the user is not logged in
                  return;
                }
                
                UserData updatedUser = UserData(
                  uid: uid, 
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  guardianPhone: guardianPhoneController.text,
                  guardianEmail: guardianEmailController.text,
                );

                await _userService.updateUserData(updatedUser);

                if (mounted) {
                  setState(() {
                    _loadUserData(); // reload data
                  });
                }

                Navigator.of(context).pop(); // close dialog
              }, 
              child: const Text('Save'),
            ),
          ],
        );
      }
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FDFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FDFF),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final user = await _userData;
              _showEditDialog(user);
            },
          )
        ],
      ),
      body: FutureBuilder<UserData>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileItem('Name', user.name),
                _buildProfileItem('Phone', user.phone),
                _buildProfileItem('Email', user.email),
                _buildProfileItem('Guardian Phone', user.guardianPhone),
                _buildProfileItem('Guardian Email', user.guardianEmail),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
