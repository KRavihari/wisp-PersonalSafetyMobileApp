import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class RegisterAsChildPage extends StatefulWidget {
  const RegisterAsChildPage({super.key});

  @override
  _RegisterAsChildPageState createState() => _RegisterAsChildPageState();
}

class _RegisterAsChildPageState extends State<RegisterAsChildPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FDFF),
      //backgroundColor: Colors.blueGrey[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Register As Child",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField("Enter name", Icons.person, _nameController),
                _buildTextField("Enter phone number", Icons.phone, _phoneController),
                _buildTextField("Enter email", Icons.email, _emailController),
                _buildTextField("Enter guardian's phone number", Icons.phone, _guardianPhoneController),
                _buildTextField("Enter guardian's email", Icons.email, _guardianEmailController),
                _buildPasswordField("Password", _isPasswordVisible, () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                }, _passwordController),
                _buildPasswordField("Retype password", _isConfirmPasswordVisible, () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                }, _confirmPasswordController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    "REGISTER",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    "Login with your account",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(String hintText, bool isVisible, VoidCallback toggleVisibility, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.grey[700]),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: GestureDetector(
            onTap: toggleVisibility,
            child: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[700],
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a password';
          }
          return null;
        },
      ),
    );
  }

Future<void> _register() async {
  if (_formKey.currentState!.validate()) {
    try {
      // 1. Create Auth user
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      // 2. Create Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'name': _nameController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
            'guardianPhone': _guardianPhoneController.text,
            'guardianEmail': _guardianEmailController.text,
            'role': 'child',
            'createdAt': FieldValue.serverTimestamp(),
          });

          //3. Create contact document for guardian
      await FirebaseFirestore.instance.collection('contacts').add({
        'name': _guardianEmailController.text, // Using email as name
        'number': _guardianPhoneController.text,
        'userId': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'isGuardian': true, // Optional: Add flag for guardian contacts
      });

      // 3. Navigate after successful creation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? "Authentication failed");
    } on FirebaseException catch (e) {
      _showErrorDialog("Database error: ${e.message}");
    } catch (e) {
      _showErrorDialog("Unexpected error: $e");
    }
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
