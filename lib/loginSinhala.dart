import 'package:app_wisp/home.dart';
import 'package:app_wisp/homeSinhala.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:app_wisp/forgotPasswordPage.dart';
import 'childRegisterSinhala.dart';
import 'elderResgiterSinhala.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPageSi(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPageSi extends StatefulWidget {
  const LoginPageSi({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPageSi> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _loginUser(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageSin()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "පිවිසුම අසාර්ථක විය. කරුණාකර නැවත උත්සාහ කරන්න.";
      if (e.code == 'user-not-found') {
        errorMessage = "මෙම ඊමේල් ලිපිනය සමඟ පරිශීලකයෙක් හමු නොවීය.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "වැරදි මුරපදය.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Upper section with logo and title
            Container(
              color: Colors.indigo[900],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "WISP",
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "ක්ෂණික සහය සඳහා ඔබව සාදරයෙන් පිළිගනිමු",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // User Login section
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text(
                        "පරිශීලක පිවිසුම",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.lock, size: 30, color: Colors.black),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Email field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      labelText: "ඊමේල් ලිපිනය",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: "මුරපදය",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        child: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Login Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _loginUser(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("පිවිසෙන්න"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Forgot Password
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "මුරපදය අමතක වුණාද?\u00A0\u00A0",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: "මෙතැන ක්ලික් කරන්න",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Register options
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => const RegisterAsChildPageSinhala()),
                            );
                          },
                          child: Text(
                            "ළමයින් ලෙස ලියාපදිංචි වන්න",
                            style: TextStyle(
                              color: Colors.indigo[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => const RegisterAsElderPageSinhala()),
                            );
                          },
                          child: Text(
                            "මහලු අය ලෙස ලියාපදිංචි වන්න",
                            style: TextStyle(
                              color: Colors.indigo[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}