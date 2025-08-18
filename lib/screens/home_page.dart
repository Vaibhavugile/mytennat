// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/screens/edit_profile_screen.dart';
import 'package:mytennat/screens/matching_screen.dart';
import 'package:mytennat/screens/matches_list_screen.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart';
import 'package:mytennat/screens/view_profile_screen.dart';
import 'package:mytennat/screens/more_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mytennat/screens/user_activity_screen.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:mytennat/screens/PlansScreen.dart';
import 'package:mytennat/screens/user_screen.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userProfileType;
  String? _currentActiveProfileId;
  dynamic _activeProfileObject;
  bool _isLoadingProfileType = true;

  String? _currentPlanName;
  int? _currentPlanContacts;
  int? _remainingContacts;

  String _userName = 'User'; // Default user name

  static const String _lastSelectedProfileKey = 'lastSelectedProfileId_';

  int _selectedIndex = 0; // For Bottom Navigation Bar

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingProfileType = true;
      _userProfileType = null;
      _currentActiveProfileId = null;
      _activeProfileObject = null;
      _currentPlanName = null;
      _currentPlanContacts = null;
      _remainingContacts = null;
      _userName = 'User'; // Reset to a default before fetching
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        final userDocSnapshot = await userDocRef.get();
        if (userDocSnapshot.exists) {
          final userData = userDocSnapshot.data();
          if (userData != null) {
            setState(() {
              _userName = userData['name'] as String? ?? 'User'; // Fetch user's name
              _currentPlanName = userData['currentPlan'] as String?;
              _currentPlanContacts = userData['currentPlanContacts'] as int?;
              _remainingContacts = userData['remainingContacts'] as int?;
            });
            print('[HomePage][_fetchUserData] Fetched Plan: $_currentPlanName, Remaining Contacts: $_remainingContacts');
          }
        }

        final flatListingsSnapshot = await userDocRef.collection('flatListings').get();
        final List<FlatListingProfile> flatListings = flatListingsSnapshot.docs
            .map((doc) => FlatListingProfile.fromMap(doc.data(), doc.id))
            .toList();

        final seekingFlatmateProfilesSnapshot = await userDocRef.collection('seekingFlatmateProfiles').get();
        final List<SeekingFlatmateProfile> seekingFlatmateProfiles = seekingFlatmateProfilesSnapshot.docs
            .map((doc) => SeekingFlatmateProfile.fromMap(doc.data(), doc.id))
            .toList();

        if (flatListings.isEmpty && seekingFlatmateProfiles.isEmpty) {
          setState(() {
            _userProfileType = null;
            // No active profile, so nothing to set for _currentActiveProfileId or _activeProfileObject
            // _isLoadingProfileType will be set to false at the end of the method
          });
          // REMOVED THE 'return;' STATEMENT HERE
          // The function should continue to the final setState to turn off loading.
        }

        final prefs = await SharedPreferences.getInstance();
        final lastSelectedId = prefs.getString(_lastSelectedProfileKey + user.uid);
        print('[HomePage][_fetchUserData] Last selected profile ID: $lastSelectedId');

        bool profileSet = false;

        if (lastSelectedId != null) {
          try {
            final activeFlatListing = flatListings.firstWhere((p) => p.documentId == lastSelectedId);
            setState(() {
              _userProfileType = 'flat_listing';
              _currentActiveProfileId = activeFlatListing.documentId;
              _activeProfileObject = activeFlatListing;
            });
            profileSet = true;
            print('[HomePage][_fetchUserData] Active profile set to Flat Listing: $_currentActiveProfileId');
          } catch (_) {
            try {
              final activeSeekingFlatmate = seekingFlatmateProfiles.firstWhere((p) => p.documentId == lastSelectedId);
              setState(() {
                _userProfileType = 'seeking_flatmate';
                _currentActiveProfileId = activeSeekingFlatmate.documentId;
                _activeProfileObject = activeSeekingFlatmate;
              });
              profileSet = true;
              print('[HomePage][_fetchUserData] Active profile set to Seeking Flatmate: $_currentActiveProfileId');
            } catch (__) {
              print('[HomePage][_fetchUserData] Last selected profile ID ($lastSelectedId) not found in current profiles.');
            }
          }
        }

        if (!profileSet) {
          if (flatListings.isNotEmpty) {
            setState(() {
              _userProfileType = 'flat_listing';
              _currentActiveProfileId = flatListings.first.documentId;
              _activeProfileObject = flatListings.first;
            });
            print('[HomePage][_fetchUserData] Defaulting to first Flat Listing: $_currentActiveProfileId');
          } else if (seekingFlatmateProfiles.isNotEmpty) {
            setState(() {
              _userProfileType = 'seeking_flatmate';
              _currentActiveProfileId = seekingFlatmateProfiles.first.documentId;
              _activeProfileObject = seekingFlatmateProfiles.first;
            });
            print('[HomePage][_fetchUserData] Defaulting to first Seeking Flatmate: $_currentActiveProfileId');
          } else {
            setState(() {
              _userProfileType = null;
              _activeProfileObject = null;
            });
          }
        }
      } catch (e) {
        print('[HomePage][_fetchUserData] Error fetching user data: $e');
        setState(() {
          _userProfileType = null;
          _activeProfileObject = null;
          _currentPlanName = null;
          _currentPlanContacts = null;
          _remainingContacts = null;
          _userName = 'User';
        });
      }
    } else {
      print('[HomePage][_fetchUserData] No user logged in.');
      setState(() {
        _userProfileType = null;
        _activeProfileObject = null;
        _currentPlanName = null;
        _currentPlanContacts = null;
        _remainingContacts = null;
        _userName = 'User';
      });
    }

    // This must always run to turn off the loading indicator
    setState(() {
      _isLoadingProfileType = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on the selected index
    switch (index) {
      case 0: // Home
      // Stay on HomePage, or refresh if needed
        break;
      case 1: // Matches - Now navigates to MatchingScreen
        if (_userProfileType != null && _currentActiveProfileId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchingScreen(
                profileType: _userProfileType!,
                profileId: _currentActiveProfileId!,
              ),
            ),
          );
        } else {
          // This message is shown if the user doesn't have a 'flatListing' or 'seekingFlatmate' profile yet.
          // This is appropriate as matches are based on these profiles.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete your profile to view matches.')),
          );
        }
        break;
      case 2: // Chat - Still navigates to MatchesListScreen as per previous instruction
        if (_userProfileType != null && _currentActiveProfileId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchesListScreen(
                profileType: _userProfileType!,
                profileId: _currentActiveProfileId!,
              ),
            ),
          );
        } else {
          // This message is shown if the user doesn't have a 'flatListing' or 'seekingFlatmate' profile yet.
          // This is appropriate as chat/matches are based on these profiles.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete your profile to view chat/matches.')),
          );
        }
        break;
      case 3: // Activity
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserActivityScreen()),
        );
        break;
      case 4: // More
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MoreProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make Scaffold background transparent
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // No shadow
        toolbarHeight: 90, // Adjusted height for AppBar (increase if text feels too high)
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Make column take minimum space
          children: [
            // No SizedBox here to push text down, relying on body padding
            Text(
              'Hi $_userName Welcome To MyTennant!',
              style: const TextStyle(
                color: Colors.white, // White text for visibility on gradient
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Let\'s find your perfect FlatMate & Home',
              style: TextStyle(
                color: Colors.white, // White text for visibility on gradient
                fontSize:18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white, // White background for the icon circle
              child: Icon(Icons.person, color: Color(0xFFAD1457)), // A color that stands out
            ),
            tooltip: 'My Profile',
            onPressed: () {
              // Navigate to the new user screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserScreen()),
              );
            },
          ),
          const SizedBox(width: 16), // Padding for the profile icon
        ],
      ),
      extendBodyBehindAppBar: true, // This allows the body to extend behind the app bar
      body: Container(
        // Ensure the Container fills the entire screen
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)], // Deep Purple to Pink-Red
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoadingProfileType
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Consistent padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // This SizedBox dynamically pushes content lower, adjust value as needed
              SizedBox(height: MediaQuery.of(context).padding.top + AppBar().preferredSize.height + 80), // Pushes content below status bar + app bar + 30px gap

              // Search Location Bar - Background should be white to contrast with gradient
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // White background for search bar
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  style: TextStyle(color: Colors.black87), // Ensure input text is visible
                ),
              ),
              const SizedBox(height: 50),

              // Post Your Requirement Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Post Your Requirement',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), // White text on gradient
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade500, // Green background for FREE tag
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'FREE',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildRequirementCard(
                      context,
                      title: 'Need Room',
                      subtitle: 'with roommate',
                      imagePath: 'assets/images/need_room_illustration.png', // Placeholder image
                      color: const Color(0xFFC7BCEF), // Good-looking light lavender
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FlatWithFlatmateProfileScreen(initialPhoneNumber: null)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRequirementCard(
                      context,
                      title: 'Need Roommate',
                      subtitle: 'for your room',
                      imagePath: 'assets/images/need_roommate_illustration.png', // Placeholder image
                      color: const Color(0xFFFFD1DC), // Good-looking light rosy pink
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FlatmateProfileScreen(initialPhoneNumber: null)),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Padding before bottom nav bar (adjust as needed)
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Set a background color for the bottom nav bar
        type: BottomNavigationBarType.fixed, // Ensures all items are visible and evenly spaced
        selectedItemColor: const Color(0xFFAD1457), // Changed from green to matching pink-red
        unselectedItemColor: Colors.grey[600], // Muted color for unselected icons
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group), // Matches icon
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), // Chat icon
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity), // Activity icon
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz), // More icon
            label: 'More',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Helper widget for "Post Your Requirement" cards
  Widget _buildRequirementCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String imagePath,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180, // Height for the cards
        decoration: BoxDecoration(
          color: color, // Background color for the card
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54), // Arrow icon
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            // The image is at the bottom of the card, adjust its position
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                imagePath,
                height: 80, // Adjust image height as needed
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy classes for FlatListingProfile and SeekingFlatmateProfile
// You should ensure these are correctly defined in your 'profile_display_widgets.dart' or similar file
class FlatListingProfile {
  final String documentId;
  final String? ownerName;
  FlatListingProfile({required this.documentId, this.ownerName});
  factory FlatListingProfile.fromMap(Map<String, dynamic> data, String id) {
    return FlatListingProfile(documentId: id, ownerName: data['ownerName']);
  }
}

class SeekingFlatmateProfile {
  final String documentId;
  final String? name;
  SeekingFlatmateProfile({required this.documentId, this.name});
  factory SeekingFlatmateProfile.fromMap(Map<String, dynamic> data, String id) {
    return SeekingFlatmateProfile(documentId: id, name: data['name']);
  }
}