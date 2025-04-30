import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; 

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // automaticallyImplyLeading: false,
        title: const Text('Contacts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('contacts')
            .where('userId', isEqualTo: _user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final contactData = doc.data() as Map<String, dynamic>;
              
              return ListTile(
                title: Text(contactData['name'] ?? ''),
                subtitle: Text(contactData['number'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () => _makeCall(contactData['number']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteContact(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final numberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && 
                  numberController.text.isNotEmpty) {
                await _addContact(
                  nameController.text, 
                  numberController.text
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Add this new method for making calls
  Future<void> _makeCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch call: $number')),
      );
    }
  }

   Future<void> _addContact(String name, String number) async {
    final docRef = _firestore.collection('contacts').doc();
    await docRef.set({
      'id': docRef.id,
      'name': name,
      'number': number,
      'userId': _user!.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteContact(String contactId) async {
    await _firestore.collection('contacts').doc(contactId).delete();
  }
}


