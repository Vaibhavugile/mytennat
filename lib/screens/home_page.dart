// mytennat/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/screens/edit_profile_screen.dart'; // Import the new edit profile screen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userProfileType; // To store the fetched profile type

  @override
  void initState() {
    super.initState();
    _fetchUserProfileType();
  }

  // Fetch the user's profile type from Firestore
  Future<void> _fetchUserProfileType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('profileType')) {
        setState(() {
          _userProfileType = doc.data()!['profileType'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTennat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(), // <-- This line should be changed
                ),
              ).then((_) => _fetchUserProfileType()); // Refresh profile type after editing
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to your homepage!'),
            if (_userProfileType != null)
              Text('Your current profile type: $_userProfileType'),
            // Other homepage content
          ],
        ),
      ),
    );
  }
}