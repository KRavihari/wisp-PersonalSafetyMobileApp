import 'package:flutter/material.dart';
import 'package:app_wisp/welcome.dart';
import 'package:app_wisp/login.dart';
import 'package:app_wisp/loginSinhala.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),   //setting openning page as the startup screen
      routes: {
        'login': (context) => const LoginPage(),
        'loginSi': (context) => const LoginPageSi(),
      }
    );
  }
}


_initializeFirebase() async{
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
}
