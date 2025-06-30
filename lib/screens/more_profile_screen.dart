// lib/screens/more_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart'; // Import the display widgets
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Import FlatListingProfile model
import 'package:mytennat/screens/edit_profile_screen.dart'; // To navigate to edit profile
import 'package:mytennat/screens/selection_screen.dart'; // To navigate to select/create new profile type

class MoreProfileScreen extends StatefulWidget {
  const MoreProfileScreen({super.key});

  @override
  State<MoreProfileScreen> createState() => _MoreProfileScreenState();
}

class _MoreProfileScreenState extends State<MoreProfileScreen> {
  dynamic _userProfile;
  String? _userType;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _userProfile = null;
      _userType = null;
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'User not logged in. Please log in to view your profile.';
        _isLoading = false;
      });
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      // Try to fetch 'flatListings' profile
      final flatListingsSnapshot = await userDocRef.collection('flatListings').limit(1).get();
      if (flatListingsSnapshot.docs.isNotEmpty) {
        final doc = flatListingsSnapshot.docs.first;
        _userProfile = FlatListingProfile.fromMap(doc.data(), doc.id);
        _userType = 'flat_listing';
      } else {
        // If no 'flatListings' profile, try to fetch 'seekingFlatmateProfiles' profile
        final seekingFlatmateProfilesSnapshot = await userDocRef.collection('seekingFlatmateProfiles').limit(1).get();
        if (seekingFlatmateProfilesSnapshot.docs.isNotEmpty) {
          final doc = seekingFlatmateProfilesSnapshot.docs.first;
          _userProfile = SeekingFlatmateProfile.fromMap(doc.data(), doc.id);
          _userType = 'seeking_flatmate';
        }
      }

      if (_userProfile == null) {
        _errorMessage = 'No active profile found. Please create one to get started.';
      }
    } catch (e) {
      _errorMessage = 'Error fetching profile: ${e.toString()}';
      print('Error fetching profile for current user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to navigate to EditProfileScreen and refresh data
  void _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    _fetchUserProfile(); // Refresh profile data after returning from edit screen
  }

  // Helper method to navigate to SelectionScreen for new profile type
  void _navigateToSelectionScreen() async {
    // You might want to add a confirmation dialog here before potentially
    // allowing a user to switch their primary profile type, as this might
    // imply deleting or inactivating the existing one.
    // For simplicity, directly navigate for now.
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectionScreen()),
    );
    _fetchUserProfile(); // Refresh profile data after returning
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchUserProfile,
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
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You don\'t have an active profile yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToEditProfile, // Go to profile setup/creation
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Create My Profile'),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userType == 'seeking_flatmate')
              SeekingFlatmateProfileDisplay(profile: _userProfile as SeekingFlatmateProfile)
            else if (_userType == 'flat_listing')
              FlatListingProfileDisplay(profile: _userProfile as FlatListingProfile),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _navigateToEditProfile,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit My Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // This button offers to create the *other* type of profile.
                  // Consider your app's logic: Can a user have both active?
                  // If not, this might need to delete the current one or be more explicit.
                  ElevatedButton.icon(
                    onPressed: _navigateToSelectionScreen,
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(
                      _userType == 'seeking_flatmate'
                          ? 'Become a Flat Lister'
                          : 'Seek a Flatmate',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // You can add more options here like settings, privacy, etc.
                  // Example:
                  // ElevatedButton.icon(
                  //   onPressed: () { /* Navigate to Settings */ },
                  //   icon: const Icon(Icons.settings),
                  //   label: const Text('Settings'),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.grey,
                  //     foregroundColor: Colors.white,
                  //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  //     textStyle: const TextStyle(fontSize: 18),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}