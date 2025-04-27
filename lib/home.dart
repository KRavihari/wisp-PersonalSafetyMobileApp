import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shake/shake.dart';
import 'login.dart';
import 'package:flutter_sms/flutter_sms.dart'; 
import 'chat.dart';
import 'contacts.dart';
import 'profile.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SafetyApp());
}

class SafetyApp extends StatelessWidget {
  const SafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ShakeDetector? _detector;
  String _lastShakeInfo = 'No shake detected yet';
  double _shakeThreshold = 2.7;
  bool _useFilter = false;
  int _minimumShakeCount = 1;

  int _currentNavIndex = 0;
  int _currentIndex = 0;
  late List<Widget> _pages;

  final List<String> images = [
    'assets/home1.png',
    'assets/home2.png',
    'assets/home3.png',
    'assets/home4.png',
    'assets/home6.png',
  ];

  Future<List<String>> _getContacts() async {
  return ['+1234567890', '+0987654321']; // Example numbers
}

// Add Timer variable
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();

    // Initialize shake detector
    _detector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        setState(() {
          _lastShakeInfo = 'Shake detected:\n'
              'Direction: ${event.direction}\n'
              'Force: ${event.force.toStringAsFixed(2)}\n'
              'Time: ${event.timestamp.toString()}';
        });
      },
      minimumShakeCount: _minimumShakeCount,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: _shakeThreshold,
      useFilter: _useFilter,
    );

    // Image carousel with timer stored
   _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) { // Check if widget is still in the tree
        setState(() {
          _currentIndex = (_currentIndex + 1) % images.length;
        });
      }
    });

    _pages = [
      HomeContentPage(
        images: images,
        currentIndex: _currentIndex,
        lastShakeInfo: _lastShakeInfo,
      ),
      const ChatsPage(),
      const ContactsPage(),
      const ProfilePage(),
    ];
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _carouselTimer?.cancel(); // Cancel the timer
    _detector?.stopListening(); // Stop the shake detector to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _pages[_currentNavIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 4, 33, 57),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[300],
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: "Contacts"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeContentPage extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final String lastShakeInfo;

  const HomeContentPage({
    super.key,
    required this.images,
    required this.currentIndex,
    required this.lastShakeInfo,
  });

  Widget _emergencyItem(String title, String number) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(number),
      onTap: () async {
        final Uri launchUri = Uri(
          scheme: 'tel',
          path: '+94771553566',
        );
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(
            launchUri,
            mode: LaunchMode.externalApplication, // <-- Important for automatic call
          );
        } else {
          print('Could not launch $number');
        }
      },
    ),
    );
  }


   Widget _locationSender(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          // Get current location
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // Format message
          String message = "Emergency! My current location is: "
              "https://www.google.com/maps/search/?api=1&query="
              "${position.latitude},${position.longitude}";

          // Get contacts (you'll need to implement this)
          List<String> contacts = await _getContacts(); // Implement contact retrieval

          // Send SMS
          String result = await sendSMS(
            message: message,
            recipients: contacts,
            sendDirect: true,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result)),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Image.asset('location1.png', width: 40),
            const Expanded(
              child: Center(
                child: Text(
                  "SEND LOCATION TO CONTACTS",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Image.asset('location2.png', width: 40),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _getContacts() async {
    // Dummy contacts list
    return ['+94771553566'];
  }



  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(images[currentIndex], height: 200, fit: BoxFit.cover),
        const SizedBox(height: 10),
        const Text(
          "You Have to End Violence",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          "",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            lastShakeInfo,
            textAlign: TextAlign.center,
          ),
        ),
        Column(  // <- Just a Column instead of ListView+Expanded
          children: [
            _emergencyItem("Police Emergency Hotline", "118/119"),
            _emergencyItem("Ambulance Service", "1990"),
            _emergencyItem("Fire Brigade", "110"),
            _emergencyItem("Women’s Helpline", "1938"),
          ],
        ),
        _locationSender(context),
      ],
    ),
  );
}
}
