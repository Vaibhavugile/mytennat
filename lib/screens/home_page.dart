import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/screens/edit_profile_screen.dart'; // Import the new edit profile screen
import 'package:mytennat/screens/matching_screen.dart'; // Import the MatchingScreen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userProfileType; // To store the fetched profile type
  bool _isLoadingProfileType = true; // Added to manage loading state

  @override
  void initState() {
    super.initState();
    _fetchUserProfileType();
  }

  // Fetch the user's profile type from Firestore
  Future<void> _fetchUserProfileType() async {
    setState(() {
      _isLoadingProfileType = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('userType')) { // Changed 'profileType' to 'userType'
          setState(() {
            _userProfileType = doc.data()!['userType']; // Changed 'profileType' to 'userType'
          });
        } else {
          setState(() {
            _userProfileType = null; // Ensure it's null if userType is not found
          });
        }
      } catch (e) {
        print("Error fetching user profile type: $e");
        setState(() {
          _userProfileType = null; // Set to null on error to prompt profile setup
        });
      }
    } else {
      setState(() {
        _userProfileType = null; // No user logged in
      });
    }
    setState(() {
      _isLoadingProfileType = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTennat'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login'); // Navigate to login
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _isLoadingProfileType
                ? const CircularProgressIndicator(color: Colors.redAccent)
                : _userProfileType != null // Check if profile type is set
                ? Column(
              children: [
                Text(
                  'Your profile type: ${_userProfileType == 'seekingFlatmate' ? 'Seeking a Flatmate' : 'Listing a Flat'}',
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to matching screen based on profile type
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MatchingScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.group),
                  label: const Text('Find Matches'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ).then((_) => _fetchUserProfileType()); // Refresh profile type after editing
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            )
                : Column(
              children: [
                const Text(
                  'Please complete your profile to start matching.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ).then((_) => _fetchUserProfileType()); // Refresh profile type after editing
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Go to Profile Setup'),
                ),
              ],
            ),
            // Other homepage content can go here
          ],
        ),
      ),
    );
  }
}