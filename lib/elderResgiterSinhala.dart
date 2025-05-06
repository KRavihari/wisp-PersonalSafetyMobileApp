import 'package:app_wisp/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterAsElderPageSinhala extends StatefulWidget {
  const RegisterAsElderPageSinhala({super.key});

  @override
  _RegisterAsElderPageState createState() => _RegisterAsElderPageState();
}

class _RegisterAsElderPageState extends State<RegisterAsElderPageSinhala> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FDFF),
      //backgroundColor: Colors.blueGrey[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                "ජ්‍යේෂ්ඨයා ලෙස ලියාපදිංචි වන්න",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField("නම ඇතුළත් කරන්න", Icons.person),
              _buildTextField("දුරකථන අංකය ඇතුළත් කරන්න", Icons.phone),
              _buildTextField("ඊමේල් ලිපිනය ඇතුළත් කරන්න", Icons.email),
              _buildPasswordField("මුරපදය", _isPasswordVisible, () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              }),
              _buildPasswordField("මුරපදය නැවත ඇතුළත් කරන්න", _isConfirmPasswordVisible, () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "ලියාපදිංචි වන්න",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  await AuthService().signup(
                    email: _buildTextField.text,
                    password: _buildPasswordField.text
                  );
                },
                child: const Text(
                  "ඔබේ ගිණුම සමඟ ප්‍රවිෂ්ට වන්න",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hintText, bool isVisible, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
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
      ),
    );
  }
}

extension on Widget Function(String hintText, bool isVisible, VoidCallback toggleVisibility) {
  get text => null;
}

extension on Widget Function(String hintText, IconData icon) {
  get text => null;
}
