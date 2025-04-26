import 'package:flutter/material.dart';

class OpeningPageSi extends StatelessWidget {
  const OpeningPageSi({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'loginSi');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5FDFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ආයුබෝවන්",
                  style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Color(0xFF0B054E)),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  "ඔබගේ ආරක්ෂාව අපගේ ප්‍රමුඛතාවයයි",
                  style: TextStyle(fontSize: 18.0, color: Color(0xFF0B054E)),
                ),
                const SizedBox(height: 40.0),
                const CircleAvatar(
                  radius: 80.0,
                  backgroundImage: AssetImage('assets/wisp_logo.png'),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 40.0),
                const Text(
                  "WISP",
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Color(0xFF0B054E)),
                ),
                const Text(
                  "Where Instant Support Please",
                  style: TextStyle(fontSize: 16.0, color: Color(0xFF0B054E)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}