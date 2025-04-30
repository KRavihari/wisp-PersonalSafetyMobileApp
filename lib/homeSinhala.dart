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
import 'profileSinhala.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SafetyApp());
}

class SafetyApp extends StatelessWidget {
  const SafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePageSin(),
    );
  }
}

class HomePageSin extends StatefulWidget {
  const HomePageSin({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageSin> {
  ShakeDetector? _detector;
  String _lastShakeInfo = 'තවම සෙලවීම් හඳුනාගෙන නැත';
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

  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();

    _detector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        setState(() {
          _lastShakeInfo = 'සෙලවීම හඳුනාගෙන ඇත:\n'
              'දිශාව: ${event.direction}\n'
              'බලය: ${event.force.toStringAsFixed(2)}\n'
              'වේලාව: ${event.timestamp.toString()}';
        });
      },
      minimumShakeCount: _minimumShakeCount,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: _shakeThreshold,
      useFilter: _useFilter,
    );

   _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
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
      const ProfilePageSin(),
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
    _carouselTimer?.cancel();
    _detector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('සුරක්ෂිත යෙදුම'),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "මුල් පිටුව"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "කතාබහ"),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: "අත්වැල"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "පැතිකඩ"),
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
            mode: LaunchMode.externalApplication,
          );
        } else {
          print('ඇමතුම ආරම්භ කිරීමට නොහැකි විය: $number');
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
            const SnackBar(content: Text("පරිශීලකයා ඇතුල් වී නැත")),
          );
          return;
        }
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          String message = "අනතුරු ඇඟවීම! මගේ වර්තමාන ස්ථානය: "
              "https://www.google.com/maps/search/?api=1&query="
              "${position.latitude},${position.longitude}";

        List<String> numbers = await _getContacts();

          if (numbers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("අනතුරු ඇඳීම් අංක නැත")),
          );
          return;
        }

        await sendSMS(
          message: message,
          recipients: numbers,
          sendDirect: true,
        );

          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${numbers.length} අංකවලට යැවුණි")),
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("දෝෂය: ${e.toString()}")),
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
                  "ස්ථාන තොරතුරු යවන්න",
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
          "ඔබට ත්රස්තවාදය නැවැත්විය යුතුය",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            lastShakeInfo,
            textAlign: TextAlign.center,
          ),
        ),
        _locationSender(context),
        Column(
          children: [
            _emergencyItem("පොලිස් අනතුරු ඇඳීම් අංකය", "118/119"),
            _emergencyItem("අම්බුලන්ස් සේවය", "1990"),
            _emergencyItem("මිනින්දෝරු සේවය", "110"),
            _emergencyItem("මහිලා සහාය අංකය", "1938"),
          ],
        ),

        Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.map),
            title: const Text(
              "ඔබ වටා බලන්න",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Google Maps හි ඔබගේ වර්තමාන ස්ථානය අරින්න"),
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
                    const SnackBar(content: Text("Google Maps අරින්න අසමත් විය")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("දෝෂය: ${e.toString()}")),
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