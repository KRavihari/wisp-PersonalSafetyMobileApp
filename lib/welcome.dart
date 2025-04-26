import 'package:flutter/material.dart';
import 'openingSinhala.dart'; // Import the Sinhala screen
import 'opening.dart'; // Import the English screen

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        color: Colors.lightBlue[100], // Set background color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please select a language',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Sinhala screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OpeningPageSi()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button background color
                  foregroundColor: Colors.indigo[900], // Button text color
                ),
                child: Text('සිංහල'), // Sinhala button
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the English screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OpeningPageEn()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button background color
                  foregroundColor: Colors.indigo[900], // Button text color
                ),
                child: Text('English'), // English button
              ),
            ],
          ),
        ),
      ),
    );
  }
}
