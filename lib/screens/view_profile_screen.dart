// lib/screens/view_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart'; // Import the display widgets
// Corrected imports for profile models - assuming they are in a 'models' folder
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // Import FlatListingProfile model
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Import SeekingFlatmateProfile model

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

  // Variables to hold both profile types if they exist
  FlatListingProfile? _flatListingProfileData;
  SeekingFlatmateProfile? _seekingFlatmateProfileData;
  String? _currentDisplayProfileType; // To manage which profile is currently shown

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
      _userProfile = null; // Clear previous profile data
      _userType = null; // Clear previous user type
      _flatListingProfileData = null; // Clear previous flat listing profile data
      _seekingFlatmateProfileData = null; // Clear previous seeking flatmate profile data
      _currentDisplayProfileType = null; // Clear current display type
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
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);

      // Try to fetch 'flatListings' profile
      final flatListingsSnapshot = await userDocRef.collection('flatListings').limit(1).get();
      if (flatListingsSnapshot.docs.isNotEmpty) {
        final doc = flatListingsSnapshot.docs.first;
        _flatListingProfileData = FlatListingProfile.fromMap(doc.data(), doc.id);
      }

      // Try to fetch 'seekingFlatmateProfiles' profile
      final seekingFlatmateProfilesSnapshot = await userDocRef.collection('seekingFlatmateProfiles').limit(1).get();
      if (seekingFlatmateProfilesSnapshot.docs.isNotEmpty) {
        final doc = seekingFlatmateProfilesSnapshot.docs.first;
        _seekingFlatmateProfileData = SeekingFlatmateProfile.fromMap(doc.data(), doc.id);
      }

      // Determine which profile to display initially
      if (_flatListingProfileData != null && _seekingFlatmateProfileData != null) {
        // If both exist, default to Flat Listing or based on user preference
        _userProfile = _flatListingProfileData;
        _userType = 'flat_listing';
        _currentDisplayProfileType = 'flat_listing';
      } else if (_flatListingProfileData != null) {
        _userProfile = _flatListingProfileData;
        _userType = 'flat_listing';
        _currentDisplayProfileType = 'flat_listing';
      } else if (_seekingFlatmateProfileData != null) {
        _userProfile = _seekingFlatmateProfileData;
        _userType = 'seeking_flatmate';
        _currentDisplayProfileType = 'seeking_flatmate';
      } else {
        _errorMessage = 'No profile found for user ID: $targetUserId. Profile might be incomplete or not created.';
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

  // Method to switch the displayed profile
  void _switchProfile(String profileType) {
    setState(() {
      _currentDisplayProfileType = profileType;
      if (profileType == 'flat_listing') {
        _userProfile = _flatListingProfileData;
        _userType = 'flat_listing';
      } else if (profileType == 'seeking_flatmate') {
        _userProfile = _seekingFlatmateProfileData;
        _userType = 'seeking_flatmate';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId == null ? 'My Profile' : 'User Profile', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.userId == null && (_flatListingProfileData != null || _seekingFlatmateProfileData != null))
            PopupMenuButton<String>(
              onSelected: _switchProfile,
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<String>> items = [];
                if (_flatListingProfileData != null) {
                  items.add(
                    PopupMenuItem<String>(
                      value: 'flat_listing',
                      child: Text('My Flat Listing Profile'),
                    ),
                  );
                }
                if (_seekingFlatmateProfileData != null) {
                  items.add(
                    PopupMenuItem<String>(
                      value: 'seeking_flatmate',
                      child: Text('My Seeking Flatmate Profile'),
                    ),
                  );
                }
                return items;
              },
              icon: Icon(Icons.swap_horiz, color: Colors.white),
            ),
        ],
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          : _currentDisplayProfileType == 'seeking_flatmate'
          ? SeekingFlatmateProfileDisplay(profile: _userProfile as SeekingFlatmateProfile) // Display seeking flatmate profile
          : FlatListingProfileDisplay(profile: _userProfile as FlatListingProfile), // Display flat listing profile
    );
  }
}