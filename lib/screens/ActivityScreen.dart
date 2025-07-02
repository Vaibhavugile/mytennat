import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/liked_by_me_list.dart'; // Import the new widgets
import 'package:mytennat/screens/who_liked_me_list.dart'; // Import the new widgets

class ActivityScreen extends StatefulWidget {
  final String profileType; // Add this line
  final String profileId;
  const ActivityScreen({  super.key,
    required this.profileType, // Make it required
    required this.profileId,   // Make it required
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Activity', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Please log in to view your activity.', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return DefaultTabController(
      length: 2, // Two tabs: Liked by Me, Who Liked Me
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Liked By Me', icon: Icon(Icons.favorite)),
              Tab(text: 'Who Liked Me', icon: Icon(Icons.handshake)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LikedByMeList(currentUserId: _currentUser!.uid),
            WhoLikedMeList(currentUserId: _currentUser!.uid),
          ],
        ),
      ),
    );
  }
}