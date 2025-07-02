// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/screens/edit_profile_screen.dart';
import 'package:mytennat/screens/matching_screen.dart';
import 'package:mytennat/screens/matches_list_screen.dart';
import 'package:mytennat/screens/ActivityScreen.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart';
import 'package:mytennat/screens/view_profile_screen.dart';
import 'package:mytennat/screens/more_profile_screen.dart'; // Import the MoreProfileScreen
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

// Assuming these models are accessible
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // For FlatListingProfile
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // For SeekingFlatmateProfile

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userProfileType;
  String? _currentActiveProfileId; // New: To store the ID of the active profile
  bool _isLoadingProfileType = true;

  // Key for SharedPreferences to store the last selected profile ID (must match ViewProfileScreen)
  static const String _lastSelectedProfileKey = 'lastSelectedProfileId_';

  @override
  void initState() {
    super.initState();
    _fetchUserProfileType();
  }

  Future<void> _fetchUserProfileType() async {
    setState(() {
      _isLoadingProfileType = true;
      _userProfileType = null;
      _currentActiveProfileId = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

        // Fetch all flat listing profiles
        final flatListingsSnapshot = await userDocRef.collection('flatListings').get();
        final List<FlatListingProfile> flatListings = flatListingsSnapshot.docs
            .map((doc) => FlatListingProfile.fromMap(doc.data(), doc.id))
            .toList();

        // Fetch all seeking flatmate profiles
        final seekingFlatmateProfilesSnapshot = await userDocRef.collection('seekingFlatmateProfiles').get();
        final List<SeekingFlatmateProfile> seekingFlatmateProfiles = seekingFlatmateProfilesSnapshot.docs
            .map((doc) => SeekingFlatmateProfile.fromMap(doc.data(), doc.id))
            .toList();

        // Check if user has any profiles at all
        if (flatListings.isEmpty && seekingFlatmateProfiles.isEmpty) {
          setState(() {
            _userProfileType = null; // Indicate no profiles exist
          });
          return;
        }

        // Try to load the last selected profile ID from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final lastSelectedId = prefs.getString(_lastSelectedProfileKey + user.uid);
        print('[HomePage][_fetchUserProfileType] Last selected profile ID: $lastSelectedId');

        bool profileSet = false;

        if (lastSelectedId != null) {
          // Try to find the last selected profile among flat listings
          try {
            final activeFlatListing = flatListings.firstWhere((p) => p.documentId == lastSelectedId);
            setState(() {
              _userProfileType = 'flat_listing';
              _currentActiveProfileId = activeFlatListing.documentId;
            });
            profileSet = true;
            print('[HomePage][_fetchUserProfileType] Active profile set to Flat Listing: $_currentActiveProfileId');
          } catch (_) {
            // Not a flat listing, try to find it among seeking flatmate profiles
            try {
              final activeSeekingFlatmate = seekingFlatmateProfiles.firstWhere((p) => p.documentId == lastSelectedId);
              setState(() {
                _userProfileType = 'seeking_flatmate';
                _currentActiveProfileId = activeSeekingFlatmate.documentId;
              });
              profileSet = true;
              print('[HomePage][_fetchUserProfileType] Active profile set to Seeking Flatmate: $_currentActiveProfileId');
            } catch (__) {
              print('[HomePage][_fetchUserProfileType] Last selected profile ID ($lastSelectedId) not found in current profiles.');
              // Last selected ID not found, proceed to default logic
            }
          }
        }

        // If no specific profile was set (either no previous selection or invalid ID),
        // default to the first available profile
        if (!profileSet) {
          if (flatListings.isNotEmpty) {
            setState(() {
              _userProfileType = 'flat_listing';
              _currentActiveProfileId = flatListings.first.documentId;
            });
            print('[HomePage][_fetchUserProfileType] Defaulting to first Flat Listing: $_currentActiveProfileId');
          } else if (seekingFlatmateProfiles.isNotEmpty) {
            setState(() {
              _userProfileType = 'seeking_flatmate';
              _currentActiveProfileId = seekingFlatmateProfiles.first.documentId;
            });
            print('[HomePage][_fetchUserProfileType] Defaulting to first Seeking Flatmate: $_currentActiveProfileId');
          } else {
            // This case should ideally be caught by the initial empty check, but as a fallback:
            setState(() {
              _userProfileType = null; // Still no profiles
            });
          }
        }
      } catch (e) {
        print('[HomePage][_fetchUserProfileType] Error fetching user profile type: $e');
        setState(() {
          _userProfileType = null; // Indicate error or no profile
        });
      }
    } else {
      print('[HomePage][_fetchUserProfileType] No user logged in.');
      setState(() {
        _userProfileType = null; // No user, so no profile
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
        title: const Text('MyTennant', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewProfileScreen()),
              ).then((_) => _fetchUserProfileType()); // Refresh when returning from ViewProfileScreen
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MoreProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoadingProfileType
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/images/MyTennant.png',
              height: 150,
            ),
            const SizedBox(height: 30),
            const Text(
              'Welcome to MyTennant!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              'Find your perfect flatmate or flat with ease.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 40),
            _userProfileType != null && _currentActiveProfileId != null
                ? Column(
              children: [
                if (_userProfileType == 'flat_listing')
                  const Text(
                    'You are currently looking for flatmates for your flat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )
                else if (_userProfileType == 'seeking_flatmate')
                  const Text(
                    'You are currently looking for a flat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchingScreen(
                          profileType: _userProfileType!,
                          profileId: _currentActiveProfileId!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Start Matching'),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchesListScreen(
                          profileType: _userProfileType!,
                          profileId: _currentActiveProfileId!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('View Matches'),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityScreen(
                          profileType: _userProfileType!, // Pass the active profile type
                          profileId: _currentActiveProfileId!, // Pass the active profile ID
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('View Activity'),
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
                    ).then((_) => _fetchUserProfileType()); // Refresh when returning from profile setup
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
          ],
        ),
      ),
    );
  }
}