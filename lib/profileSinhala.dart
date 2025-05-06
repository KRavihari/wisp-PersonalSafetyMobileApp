import 'package:flutter/material.dart';
import 'package:app_wisp/models/user_model.dart';
import 'package:app_wisp/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePageSin extends StatefulWidget {
  const ProfilePageSin({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageSin> {
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
          title: const Text('පැතිකඩ සංස්කරණය'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('නම', nameController),
                _buildTextField('දුරකථන අංකය', phoneController),
                _buildTextField('විද්යුත් තැපෑල', emailController),
                _buildTextField('භාරකරුගේ දුරකථන අංකය', guardianPhoneController),
                _buildTextField('භාරකරුගේ විද්යුත් තැපෑල', guardianEmailController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text('අවලංගු කරන්න'),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                
                if (uid == null) return;
                
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
                  setState(() => _loadUserData());
                }

                Navigator.of(context).pop();
              }, 
              child: const Text('සුරකින්න'),
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
        title: const Text('පැතිකඩ'),
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
            return Center(child: Text('දෝෂය: ${snapshot.error}'));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileItem('නම', user.name),
                _buildProfileItem('දුරකථන අංකය', user.phone),
                _buildProfileItem('විද්යුත් තැපෑල', user.email),
                _buildProfileItem('භාරකරුගේ දුරකථන අංකය', user.guardianPhone),
                _buildProfileItem('භාරකරුගේ විද්යුත් තැපෑල', user.guardianEmail),
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