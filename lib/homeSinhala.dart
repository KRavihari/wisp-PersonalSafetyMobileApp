import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
//import 'package:geolocator/geolocator.dart';
import 'login.dart'; 

void main() {
  runApp(SafetyApp());
}

class SafetyApp extends StatelessWidget {
  const SafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> images = [
    'assets/home1.png',
    'assets/home2.png',
    'assets/home3.png',
    'assets/home4.png',
    'assets/home6.png',
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % images.length;
      });
    });
  }

 // void _sendLocation() async {
 //   Position position = await Geolocator.getCurrentPosition(
 //       desiredAccuracy: LocationAccuracy.high);
 //   print("ස්ථානය: ${position.latitude}, ${position.longitude}");
 // }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ආරක්ෂක යෙදුම'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Image.asset(images[_currentIndex], height: 200, fit: BoxFit.cover),
          const Text(
            "ඔබට ප්‍රචණ්ඩත්වය නවතා දැමිය යුතුයි",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text("හදිසි ඇමතුම්", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _emergencyItem("පොලිස් හදිසි අංකය", "118/119"),
                _emergencyItem("ගිලන් රථ සේවය", "1990"),
                _emergencyItem("ගින්න මැඩපවත්වන ඒකකය", "110"),
                _emergencyItem("කාන්තා හදිසි ඇමතුම්", "1938"),
              ],
            ),
          ),
         // ElevatedButton(
         //   onPressed: _sendLocation,
         //   child: const Row(
         //     mainAxisAlignment: MainAxisAlignment.center,
         //     children: [
         //       Icon(Icons.location_on),
         //       SizedBox(width: 8),
         //       Text("ස්ථානය යවන්න"),
         //     ],
         //   ),
         // ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "මුල් පිටුව"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "සංවාද"),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: "සබඳතා"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "පැතිකඩ"),
        ],
      ),
    );
  }

  Widget _emergencyItem(String title, String number) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(number),
      ),
    );
  }
}
