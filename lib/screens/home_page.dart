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
import 'package:mytennat/screens/PlansScreen.dart'; // Import the PlansScreen

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

  static const String _lastSelectedProfileKey = 'lastSelectedProfileId_';

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
          });
          return;
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
      });
    }

    setState(() {
      _isLoadingProfileType = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String profileName = '';
    if (_activeProfileObject != null) {
      if (_userProfileType == 'flat_listing' && _activeProfileObject is FlatListingProfile) {
        profileName = (_activeProfileObject as FlatListingProfile).ownerName ?? 'Your Flat Listing';
      } else if (_userProfileType == 'seeking_flatmate' && _activeProfileObject is SeekingFlatmateProfile) {
        profileName = (_activeProfileObject as SeekingFlatmateProfile).name ?? 'Your Flatmate Profile';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTennant', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        actions: [
          // NEW: View Plans Button
          IconButton(
            icon: const Icon(Icons.card_membership, color: Colors.white), // or Icons.local_activity, Icons.payments
            tooltip: 'View Plans',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlansScreen()),
              ).then((_) => _fetchUserData()); // Refresh all data when returning from PlansScreen
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'My Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewProfileScreen()),
              ).then((_) => _fetchUserData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            tooltip: 'More Options',
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
            if (_userProfileType != null && _currentActiveProfileId != null)
              Column(
                children: [
                  if (profileName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Active Profile: $profileName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ),
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
                ],
              ),

            if (_currentPlanName != null)
              Column(
                children: [
                  const Divider(height: 30, thickness: 1, color: Colors.grey),
                  Text(
                    'Your Current Plan: $_currentPlanName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  if (_currentPlanContacts != null)
                    Text(
                      'Total Contacts: $_currentPlanContacts',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  if (_remainingContacts != null)
                    Text(
                      'Remaining Contacts: $_remainingContacts',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  const SizedBox(height: 20),
                  // This button is now redundant if we have an icon in the AppBar for PlansScreen
                  // but kept for demonstration if you prefer a button here as well.
                  // ElevatedButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => const PlansScreen()),
                  //     ).then((_) => _fetchUserData());
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.purple,
                  //     foregroundColor: Colors.white,
                  //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  //   ),
                  //   child: const Text('Manage Plans'),
                  // ),
                  const Divider(height: 30, thickness: 1, color: Colors.grey),
                  const SizedBox(height: 20),
                ],
              ),
            _userProfileType != null && _currentActiveProfileId != null
                ? Column(
              children: [
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
                        builder: (context) => const UserActivityScreen(),
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
                    ).then((_) => _fetchUserData());
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