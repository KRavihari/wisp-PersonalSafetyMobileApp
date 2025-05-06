import 'package:cloud_firestore/cloud_firestore.dart';
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
//import 'package:flutter_tawkto/flutter_tawk.dart';
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

 // Future<List<String>> _getContacts() async {
 // return ['+1234567890', '+0987654321']; // Example numbers
//}

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
      backgroundColor: const Color(0xFFF5FDFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FDFF),
        //title: const Text('Safety App'),
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
          path: number,
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
          final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not logged in")),
          );
          return;
        }
          // Get current location
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // Format message
          String message = "Emergency! My current location is: "
              "https://www.google.com/maps/search/?api=1&query="
              "${position.latitude},${position.longitude}";

          // Get contacts from Firestore
        List<String> numbers = await _getContacts();

          if (numbers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No emergency contacts found")),
          );
          return;
        }

          // Send SMS to all contacts
        await sendSMS(
          message: message,
          recipients: numbers,
          sendDirect: true,
        );


          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sent to ${numbers.length} contacts")),
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

  // Updated _getContacts implementation
Future<List<String>> _getContacts() async {
  final List<String> numbers = [];
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {print(' User not authenticated');
      return numbers;
    }
    print('User UID: ${user.uid}');

    /*Get user document from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      print("User document not found");
      return numbers;
    }*/

    // Get contacts for this user
    final contactsQuery = await FirebaseFirestore.instance
        .collection('contacts')
        .where('userId', isEqualTo: user.uid)
        .get();
  
  print(' Found ${contactsQuery.docs.length} contacts');

    // Extract and validate numbers
    for (final doc in contactsQuery.docs) {
      print('Document ID: ${doc.id}');
      print(' Document data: ${doc.data()}');
      final number = doc.get('number')?.toString();
      print(' Extracted number: $number');
      
      if (number != null && number.isNotEmpty) {
        numbers.add(number);
      }
    }
    
    print('message was sent to $numbers');
  } catch (e) {
    print('Error: $e');
  }
  return numbers;
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
       // const SizedBox(height: 10),
        //const Text(
        //  "",
        //  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //  textAlign: TextAlign.center,
       // ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            lastShakeInfo,
            textAlign: TextAlign.center,
          ),
        ),
        _locationSender(context),
        Column(  // <- Just a Column instead of ListView+Expanded
          children: [
            _emergencyItem("Police Emergency Hotline", "118/119"),
            _emergencyItem("Ambulance Service", "1990"),
            _emergencyItem("Fire Brigade", "110"),
            _emergencyItem("Women’s Helpline", "1938"),
          ],
        ),

        // "Look Around You" Card
        Card(
          color: Colors.white,
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.map),
            title: const Text(
              "Look Around You",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Open your current location in Google Maps"),
            onTap: () async {
              try {
                Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );

                final Uri mapsUrl = Uri.parse(
                  "https://www.google.com/maps/search/?api=1&query="
                  "${position.latitude},${position.longitude}"
                );

                if (await canLaunchUrl(mapsUrl)) {
                  await launchUrl(
                    mapsUrl,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not launch Google Maps")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            },
          ),
        ),

      ],
    ),
  );
}
}