// lib/screens/view_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart'; // Import the display widgets
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Import SeekingFlatmateProfile model
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // Import FlatListingProfile model

class ViewProfileScreen extends StatefulWidget {
  // Make userId optional, allowing it to be null if viewing own profile
  final String? userId;

  const ViewProfileScreen({super.key, this.userId});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  // Variable to store the fetched user profile data
  dynamic _userProfile;
  // Variable to store the user's profile type (e.g., 'seeking_flatmate', 'flat_listing')
  String? _userType;
  // Loading indicator state
  bool _isLoading = true;
  // Error message state
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Fetch the user's profile when the widget is initialized
    _fetchUserProfile();
  }

  /// Fetches the user's profile data from Firestore.
  /// If widget.userId is provided, it fetches that specific user's profile.
  /// Otherwise, it fetches the current authenticated user's profile.
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true; // Set loading to true while fetching
      _errorMessage = null; // Clear any previous error messages
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;
    // Determine the target user ID: use the one passed via widget, or the current authenticated user's ID
    final String? targetUserId = widget.userId ?? currentUser?.uid;

    if (targetUserId == null) {
      setState(() {
        _errorMessage = 'User ID not available. Please log in or provide a user ID.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch the user's document directly from the 'users' collection
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(targetUserId).get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!; // Get all data from the user document

        if (userData.containsKey('userType')) {
          _userType = userData['userType']; // Get the user's profile type

          // Based on userType, create the specific profile data object
          // Pass the entire userData map and the document ID (targetUserId)
          if (_userType == 'seeking_flatmate') {
            _userProfile = SeekingFlatmateProfile.fromMap(userData, targetUserId);
          } else if (_userType == 'flat_listing') {
            _userProfile = FlatListingProfile.fromMap(userData, targetUserId);
          } else {
            _errorMessage = 'Unknown user profile type: $_userType for user ID: $targetUserId';
          }
        } else {
          _errorMessage = 'User type not defined in profile for user ID: $targetUserId. Profile might be incomplete.';
        }
      } else {
        _errorMessage = 'User profile not found for user ID: $targetUserId. It might have been deleted or never created.';
      }
    } catch (e) {
      // Catch and display any errors during the fetch process
      _errorMessage = 'Error fetching profile for $targetUserId: ${e.toString()}';
      print('Error fetching profile for $targetUserId: $e'); // Log the error for debugging
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false once fetching is complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Dynamically set title based on whether it's current user's profile or another's
        title: Text(widget.userId == null ? 'My Profile' : 'User Profile', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent), // Show loading indicator
      )
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                _errorMessage!, // Display error message
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchUserProfile, // Retry button
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      )
          : _userProfile == null
          ? const Center(
        child: Text(
          'No profile data available. This user might not have completed their profile.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : _userType == 'seeking_flatmate'
          ? SeekingFlatmateProfileDisplay(
          profile: _userProfile as SeekingFlatmateProfile) // Display seeking flatmate profile
          : FlatListingProfileDisplay(
          profile: _userProfile as FlatListingProfile), // Display flat listing profile
    );
  }
}
