// matching_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // For FlatListingProfile
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // For SeekingFlatmateProfile
import 'package:intl/intl.dart';
import 'package:mytennat/screens/chat_screen.dart';
import 'package:mytennat/screens/filter_screen.dart';
import 'package:mytennat/screens/filter_options.dart';
import 'dart:math' as math; // Import for math.min

class MatchingScreen extends StatefulWidget {
  // Add these final fields to receive the active profile details
  final String profileType;
  final String profileId;

  const MatchingScreen({
    super.key,
    required this.profileType,
    required this.profileId,
  });

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  List<dynamic> _profiles = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _userProfileType;
  dynamic _currentUserParsedProfile; // Store the current user's parsed profile
  FilterOptions _currentFilters = FilterOptions(); // Current active filters


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for Scaffold

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    // Initialize _userProfileType and _currentUserParsedProfile from widget properties
    _userProfileType = widget.profileType;
    if (_currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog('Not Logged In', 'Please log in to use the matching feature.', () {
          // You might navigate to a login screen here
        });
      });
    } else {
      _fetchUserProfile(); // Now fetches using widget.profileId
    }
  }

  @override
  void dispose() {
    // Removed _pageController dispose as it's now handled within the card widgets
    super.dispose();
  }

  Future<void> _fetchUserProfile({bool applyFilters = false}) async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the profile type and ID passed from the HomePage
      // Instead of re-fetching userDoc to determine userType
      // _userProfileType is already set from widget.profileType
      // Fetch the specific profile using widget.profileId

      if (_userProfileType == 'flat_listing') {
        DocumentSnapshot flatListingDoc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('flatListings')
            .doc(widget.profileId) // Use the passed profileId
            .get();

        if (flatListingDoc.exists) {
          _currentUserParsedProfile = FlatListingProfile.fromMap(
              flatListingDoc.data() as Map<String, dynamic>,
              flatListingDoc.id
          );
          await _fetchSeekingFlatmateProfiles(applyFilters: applyFilters);
        } else {
          _showAlertDialog('Profile Not Found', 'The selected Flat Listing profile could not be found.', () {
            // Navigate back to profile selection or home
          });
        }
      } else if (_userProfileType == 'seeking_flatmate') {
        DocumentSnapshot seekingFlatmateDoc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('seekingFlatmateProfiles')
            .doc(widget.profileId) // Use the passed profileId
            .get();

        if (seekingFlatmateDoc.exists) {
          _currentUserParsedProfile = SeekingFlatmateProfile.fromMap(
              seekingFlatmateDoc.data() as Map<String, dynamic>,
              seekingFlatmateDoc.id
          );
          await _fetchFlatListingProfiles(applyFilters: applyFilters);
        } else {
          _showAlertDialog('Profile Not Found', 'The selected Seeking Flatmate profile could not be found.', () {
            // Navigate back to profile selection or home
          });
        }
      } else {
        _showAlertDialog('Profile Type Not Found', 'Your active profile type could not be determined from the provided data.', () {});
      }
    } catch (e) {
      _showAlertDialog('Error', 'Failed to fetch user profile: $e', () {});
      print('Firebase Firestore Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _currentIndex = 0; // Reset index when new profiles are fetched
        // Removed _pageController.jumpToPage(0) as it's now internal to card widgets
      });
    }
  }

  Future<void> _fetchFlatListingProfiles({bool applyFilters = false}) async {
    try {
      Query query = _firestore.collectionGroup('flatListings')
          .where('uid', isNotEqualTo: _currentUser!.uid);

      if (applyFilters && _currentUserParsedProfile is SeekingFlatmateProfile) {
        if (_currentFilters.desiredCity != null && _currentFilters.desiredCity!.isNotEmpty) {
          query = query.where('desiredCity', isEqualTo: _currentFilters.desiredCity);
        }
        if (_currentFilters.areaPreference != null && _currentFilters.areaPreference!.isNotEmpty) {
          query = query.where('areaPreference', isEqualTo: _currentFilters.areaPreference);
        }
        if (_currentFilters.availabilityDate != null) {
          query = query.where('flatDetails.availabilityDate', isGreaterThanOrEqualTo: _currentFilters.availabilityDate);
        }
        if (_currentFilters.rentPriceMin != null) {
          query = query.where('flatDetails.rentPrice', isGreaterThanOrEqualTo: _currentFilters.rentPriceMin);
        }
        if (_currentFilters.rentPriceMax != null) {
          query = query.where('flatDetails.rentPrice', isLessThanOrEqualTo: _currentFilters.rentPriceMax);
        }
        if (_currentFilters.flatType != null && _currentFilters.flatType!.isNotEmpty) {
          query = query.where('flatDetails.flatType', isEqualTo: _currentFilters.flatType);
        }
        if (_currentFilters.furnishedStatus != null && _currentFilters.furnishedStatus!.isNotEmpty) {
          query = query.where('flatDetails.furnishedStatus', isEqualTo: _currentFilters.furnishedStatus);
        }
        if (_currentFilters.numberOfBedrooms != null) {
          query = query.where('flatDetails.numberOfBedrooms', isEqualTo: _currentFilters.numberOfBedrooms);
        }
        if (_currentFilters.numberOfBathrooms != null) {
          query = query.where('flatDetails.numberOfBathrooms', isEqualTo: _currentFilters.numberOfBathrooms);
        }
        if (_currentFilters.amenitiesDesired.isNotEmpty) {
          query = query.where('flatDetails.amenities', arrayContainsAny: _currentFilters.amenitiesDesired);
        }
        if (_currentFilters.availableFor != null && _currentFilters.availableFor!.isNotEmpty) {
          query = query.where('flatDetails.availableFor', isEqualTo: _currentFilters.availableFor);
        }
        if (_currentFilters.gender != null && _currentFilters.gender!.isNotEmpty) {
          query = query.where('ownerGender', isEqualTo: _currentFilters.gender);
        }
        if (_currentFilters.ageMin != null) {
          query = query.where('ownerAge', isGreaterThanOrEqualTo: _currentFilters.ageMin);
        }
        if (_currentFilters.ageMax != null) {
          query = query.where('ownerAge', isLessThanOrEqualTo: _currentFilters.ageMax);
        }
        if (_currentFilters.cleanlinessLevel != null && _currentFilters.cleanlinessLevel!.isNotEmpty) {
          query = query.where('cleanlinessLevel', isEqualTo: _currentFilters.cleanlinessLevel);
        }
        if (_currentFilters.socialHabits != null && _currentFilters.socialHabits!.isNotEmpty) {
          query = query.where('socialPreferences', isEqualTo: _currentFilters.socialHabits);
        }
        if (_currentFilters.noiseLevel != null && _currentFilters.noiseLevel!.isNotEmpty) {
          query = query.where('noiseLevel', isEqualTo: _currentFilters.noiseLevel);
        }
        if (_currentFilters.smokingHabit != null && _currentFilters.smokingHabit!.isNotEmpty) {
          query = query.where('smokingHabit', isEqualTo: _currentFilters.smokingHabit);
        }
        if (_currentFilters.drinkingHabit != null && _currentFilters.drinkingHabit!.isNotEmpty) {
          query = query.where('drinkingHabit', isEqualTo: _currentFilters.drinkingHabit);
        }
        if (_currentFilters.foodPreference != null && _currentFilters.foodPreference!.isNotEmpty) {
          query = query.where('foodPreference', isEqualTo: _currentFilters.foodPreference);
        }
        if (_currentFilters.petOwnership != null && _currentFilters.petOwnership!.isNotEmpty) {
          query = query.where('petOwnership', isEqualTo: _currentFilters.petOwnership);
        }
        if (_currentFilters.petTolerance != null && _currentFilters.petTolerance!.isNotEmpty) {
          query = query.where('petTolerance', isEqualTo: _currentFilters.petTolerance);
        }
        if (_currentFilters.workSchedule != null && _currentFilters.workSchedule!.isNotEmpty) {
          query = query.where('workSchedule', isEqualTo: _currentFilters.workSchedule);
        }
        if (_currentFilters.sleepingSchedule != null && _currentFilters.sleepingSchedule!.isNotEmpty) {
          query = query.where('sleepingSchedule', isEqualTo: _currentFilters.sleepingSchedule);
        }
        if (_currentFilters.visitorsPolicy != null && _currentFilters.visitorsPolicy!.isNotEmpty) {
          query = query.where('visitorsPolicy', isEqualTo: _currentFilters.visitorsPolicy);
        }
        if (_currentFilters.guestsOvernightPolicy != null && _currentFilters.guestsOvernightPolicy!.isNotEmpty) {
          query = query.where('guestsOvernightPolicy', isEqualTo: _currentFilters.guestsOvernightPolicy);
        }
        if (_currentFilters.occupation != null && _currentFilters.occupation!.isNotEmpty) {
          query = query.where('ownerOccupation', isEqualTo: _currentFilters.occupation);
        }
      }

      QuerySnapshot querySnapshot = await query.get();

      _profiles = querySnapshot.docs
          .map((doc) => FlatListingProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      setState(() {});
    } catch (e) {
      _showAlertDialog('Error', 'Failed to load flat listing profiles: $e', () {});
      print('Firebase Firestore Error: $e');
    }
  }


  Future<void> _fetchSeekingFlatmateProfiles({bool applyFilters = false}) async {
    try {
      Query query = _firestore.collectionGroup('seekingFlatmateProfiles')
          .where('uid', isNotEqualTo: _currentUser!.uid);

      if (applyFilters && _currentUserParsedProfile is FlatListingProfile) {
        if (_currentFilters.desiredCity != null && _currentFilters.desiredCity!.isNotEmpty) {
          query = query.where('desiredCity', isEqualTo: _currentFilters.desiredCity);
        }
        if (_currentFilters.areaPreference != null && _currentFilters.areaPreference!.isNotEmpty) {
          query = query.where('areaPreference', isEqualTo: _currentFilters.areaPreference);
        }
        if (_currentFilters.moveInDate != null) {
          query = query.where('moveInDate', isLessThanOrEqualTo: _currentFilters.moveInDate);
        }
        if (_currentFilters.budgetMin != null) {
          query = query.where('budgetMin', isGreaterThanOrEqualTo: _currentFilters.budgetMin);
        }
        if (_currentFilters.budgetMax != null) {
          query = query.where('budgetMax', isLessThanOrEqualTo: _currentFilters.budgetMax);
        }
        if (_currentFilters.gender != null && _currentFilters.gender!.isNotEmpty) {
          query = query.where('gender', isEqualTo: _currentFilters.gender);
        }
        if (_currentFilters.ageMin != null) {
          query = query.where('age', isGreaterThanOrEqualTo: _currentFilters.ageMin);
        }
        if (_currentFilters.ageMax != null) {
          query = query.where('age', isLessThanOrEqualTo: _currentFilters.ageMax);
        }
        if (_currentFilters.cleanlinessLevel != null && _currentFilters.cleanlinessLevel!.isNotEmpty) {
          query = query.where('cleanliness', isEqualTo: _currentFilters.cleanlinessLevel);
        }
        if (_currentFilters.socialHabits != null && _currentFilters.socialHabits!.isNotEmpty) {
          query = query.where('socialHabits', isEqualTo: _currentFilters.socialHabits);
        }
        if (_currentFilters.noiseLevel != null && _currentFilters.noiseLevel!.isNotEmpty) {
          query = query.where('noiseLevel', isEqualTo: _currentFilters.noiseLevel);
        }
        if (_currentFilters.smokingHabit != null && _currentFilters.smokingHabit!.isNotEmpty) {
          query = query.where('smokingHabits', isEqualTo: _currentFilters.smokingHabit);
        }
        if (_currentFilters.drinkingHabit != null && _currentFilters.drinkingHabit!.isNotEmpty) {
          query = query.where('drinkingHabits', isEqualTo: _currentFilters.drinkingHabit);
        }
        if (_currentFilters.foodPreference != null && _currentFilters.foodPreference!.isNotEmpty) {
          query = query.where('foodPreference', isEqualTo: _currentFilters.foodPreference);
        }
        if (_currentFilters.petOwnership != null && _currentFilters.petOwnership!.isNotEmpty) {
          query = query.where('petOwnership', isEqualTo: _currentFilters.petOwnership);
        }
        if (_currentFilters.petTolerance != null && _currentFilters.petTolerance!.isNotEmpty) {
          query = query.where('petTolerance', isEqualTo: _currentFilters.petTolerance);
        }
        if (_currentFilters.workSchedule != null && _currentFilters.workSchedule!.isNotEmpty) {
          query = query.where('workSchedule', isEqualTo: _currentFilters.workSchedule);
        }
        if (_currentFilters.sleepingSchedule != null && _currentFilters.sleepingSchedule!.isNotEmpty) {
          query = query.where('sleepingSchedule', isEqualTo: _currentFilters.sleepingSchedule);
        }
        if (_currentFilters.visitorsPolicy != null && _currentFilters.visitorsPolicy!.isNotEmpty) {
          query = query.where('visitorsPolicy', isEqualTo: _currentFilters.visitorsPolicy);
        }
        if (_currentFilters.guestsOvernightPolicy != null && _currentFilters.guestsOvernightPolicy!.isNotEmpty) {
          query = query.where('guestsFrequency', isEqualTo: _currentFilters.guestsOvernightPolicy);
        }
        if (_currentFilters.occupation != null && _currentFilters.occupation!.isNotEmpty) {
          query = query.where('occupation', isEqualTo: _currentFilters.occupation);
        }
      }

      QuerySnapshot querySnapshot = await query.get();

      _profiles = querySnapshot.docs
          .map((doc) => SeekingFlatmateProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      setState(() {});
    } catch (e) {
      _showAlertDialog('Error', 'Failed to load seeking flatmate profiles: $e', () {});
      print('Firebase Firestore Error: $e');
    }
  }

  void _showAlertDialog(String title, String message, VoidCallback onPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onPressed();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _onFiltersChanged(FilterOptions newFilters) {
    setState(() {
      _currentFilters = newFilters;
    });
    _fetchUserProfile(applyFilters: true);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop(); // Close the drawer after applying filters
    }
  }


  Future<void> _processLike(String likedUserId) async {
    if (_currentUser == null) {
      print("_processLike: Current user is null. Aborting like process.");
      return;
    }

    final currentUserId = _currentUser!.uid;
    print("_processLike: User $currentUserId attempting to like $likedUserId.");

    try {
      print("_processLike (Op1): Attempting to record like for $currentUserId on $likedUserId.");
      try {
        await _firestore.collection('user_likes').doc(currentUserId).collection('likes').doc(likedUserId).set({
          'timestamp': FieldValue.serverTimestamp(),
          'likedUserId': likedUserId,
        });
        print("_processLike (Op1): Successfully recorded like for $currentUserId on $likedUserId.");
      } catch (e) {
        print("_processLike (Op1) ERROR: Failed to SET like document: $e");
        _showAlertDialog('Error', 'Failed to record your like: ${e.toString()}', () {});
        return;
      }

      print("_processLike (Op2): Checking if $likedUserId has liked $currentUserId.");
      DocumentSnapshot otherUserLikesMe;
      try {
        otherUserLikesMe = await _firestore.collection('user_likes').doc(likedUserId).collection('likes').doc(currentUserId).get();
        print("_processLike (Op2): Other user like check completed. Exists: ${otherUserLikesMe.exists}");
      } catch (e) {
        print("_processLike (Op2) ERROR: Failed to GET other user's like: $e");
        _showAlertDialog('Error', 'Failed to check for mutual like: ${e.toString()}', () {});
        return;
      }

      if (otherUserLikesMe.exists) {
        print("_processLike: Mutual like detected! IT'S A MATCH!");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('It\'s a MATCH! 🎉'))
        );
        print("_processLike (Op3): Calling _createMatchAndChatRoom...");
        try {
          await _createMatchAndChatRoom(currentUserId, likedUserId);
          print("_processLike (Op3): _createMatchAndChatRoom call completed successfully.");
        } catch (e) {
          print("_processLike (Op3) ERROR: _createMatchAndChatRoom failed: $e");
          _showAlertDialog('Error', 'Failed to create match/chat: ${e.toString()}', () {});
          return;
        }

        String chatPartnerNameForDialog = 'that user';
        try {
          final matchedProfile = _profiles.firstWhere((p) => (p is FlatListingProfile && p.uid == likedUserId) || (p is SeekingFlatmateProfile && p.uid == likedUserId)
          );
          chatPartnerNameForDialog = matchedProfile is FlatListingProfile ? matchedProfile.ownerName ?? 'Match' : (matchedProfile as SeekingFlatmateProfile).name ?? 'Match';
        } catch (e) {
          print("_processLike: Could not find matched profile in _profiles for dialog. Error: $e");
        }

        if (mounted) {
          _showMatchDialog(
            'It\'s a Match!',
            'You and ${chatPartnerNameForDialog} have liked each other! Start chatting now?',
                () {
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatPartnerId: likedUserId,
                      chatPartnerName: chatPartnerNameForDialog,
                    ),
                  ),
                );
              }
            },
          );
        }
      } else {
        print("_processLike: No mutual like yet. Liked profile, awaiting response.");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Liked! Awaiting their response.'))
        );
      }
    } catch (e) {
      print("_processLike: UNEXPECTED GLOBAL ERROR: $e");
      _showAlertDialog('Error', 'An unexpected error occurred: ${e.toString()}', () {});
    }
  }

  Future<void> _createMatchAndChatRoom(String user1Id, String user2Id) async {
    if (_currentUser == null) {
      print("createMatchAndChatRoom: _currentUser is null.");
      return;
    }

    List<String> sortedUids = [user1Id, user2Id]..sort();
    String matchDocId = '${sortedUids[0]}_${sortedUids[1]}';
    print("createMatchAndChatRoom: Attempting to check existence of match: $matchDocId");

    try {
      DocumentSnapshot matchDoc = await _firestore.collection('matches').doc(matchDocId).get();
      print("createMatchAndChatRoom: Match document existence check result: ${matchDoc.exists}");

      if (!matchDoc.exists) {
        print("createMatchAndChatRoom: Match document does not exist. Proceeding to create chat and match.");
        DocumentReference chatRef = await _firestore.collection('chats').add({
          'participants': sortedUids,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageSenderId': '',
          'lastMessageTimestamp': null,
        });
        String chatRoomId = chatRef.id;
        print("createMatchAndChatRoom: Chat room created with ID: $chatRoomId");

        await _firestore.collection('matches').doc(matchDocId).set({
          'user1_id': sortedUids[0],
          'user2_id': sortedUids[1],
          'chatRoomId': chatRoomId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("createMatchAndChatRoom: Match document created successfully for $matchDocId");

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatPartnerId: (user1Id == _currentUser!.uid) ? user2Id : user1Id,
                chatPartnerName: "Match!",
              ),
            ),
          );
        }
      } else {
        print("createMatchAndChatRoom: Match document already exists for $matchDocId. Not creating.");
        final Map<String, dynamic>? matchData = matchDoc.data() as Map<String, dynamic>?;
        if (matchData != null && matchData['chatRoomId'] != null) {
          final existingChatRoomId = matchData['chatRoomId'] as String;
          print("createMatchAndChatRoom: Existing chatRoomId: $existingChatRoomId");
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatPartnerId: (user1Id == _currentUser!.uid) ? user2Id : user1Id,
                  chatPartnerName: "Match!",
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      print("createMatchAndChatRoom: ERROR during match/chat creation process: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating match: $e')),
      );
    }
  }

  void _showMatchDialog(String title, String message, VoidCallback onChatPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: onChatPressed,
              child: const Text('Chat Now'),
            ),
          ],
        );
      },
    );
  }

  void _handleProfileDismissed(DismissDirection direction) {
    setState(() {
      if (_profiles.isNotEmpty) {
        final dismissedProfile = _profiles[_currentIndex];
        String likedOrPassedUserId;
        if (dismissedProfile is FlatListingProfile) {
          likedOrPassedUserId = dismissedProfile.uid!; // Use uid and assert non-null
        } else if (dismissedProfile is SeekingFlatmateProfile) {
          likedOrPassedUserId = dismissedProfile.uid!; // Use uid and assert non-null
        } else {
          print("Error: Unknown profile type encountered in _handleProfileDismissed");
          return; // Cannot proceed without a valid user ID
        }
        if (direction == DismissDirection.endToStart) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile Passed'))
          );
        } else if (direction == DismissDirection.startToEnd) {
          _processLike(likedOrPassedUserId);
        }
        _profiles.removeAt(_currentIndex);
        if (_profiles.isEmpty) {
          _showAlertDialog('No More Profiles', 'You\'ve viewed all available profiles for now.', () {
          });
        }
      }
    });
  }

  double _calculateMatchPercentage(dynamic userProfile, dynamic otherProfile) {
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900; // Define your breakpoint for web layout

    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      appBar: AppBar(
        title: const Text('MyTennant Matching', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (!isLargeScreen) // Show filter icon only on smaller screens
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer(); // Open the drawer
              },
            ),
        ],
      ),
      drawer: isLargeScreen
          ? null // No drawer on large screens, as filter is inline
          : Drawer(
        child: FilterScreen(
          initialFilters: _currentFilters.copyWith(),
          isSeekingFlatmate: _userProfileType == 'seeking_flatmate',
          onFiltersChanged: _onFiltersChanged,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No profiles found matching your criteria.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentFilters.clear(); // Clear filters
                });
                _fetchUserProfile(applyFilters: false); // Refetch without filters
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Filters & Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                if (isLargeScreen) {
                  // For large screens, simply ensure the filter panel is visible and scroll to top
                  // This is a fallback if the user expects to "open" filters on web
                  // In a truly responsive design, the filter panel would always be visible on large screens
                  _scaffoldKey.currentState?.openDrawer(); // Open drawer to show filters for large screen as well if it was somehow closed
                } else {
                  _scaffoldKey.currentState?.openDrawer(); // Open drawer for small screens
                }
              },
              icon: const Icon(Icons.filter_list),
              label: const Text('Adjust Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      )
          : isLargeScreen
          ? Row(
        children: [
          // Filter Panel on the left for large screens
          SizedBox(
            width: math.min(350.0, screenWidth * 0.3), // Occupy 30% or max 350px
            child: FilterScreen(
              initialFilters: _currentFilters.copyWith(),
              isSeekingFlatmate: _userProfileType == 'seeking_flatmate',
              onFiltersChanged: _onFiltersChanged,
            ),
          ),
          // Main Matching Content
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _profiles.isNotEmpty
                    ? Dismissible(
                  key: ValueKey(_profiles[_currentIndex].documentId),
                  direction: DismissDirection.horizontal,
                  onDismissed: _handleProfileDismissed,
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 40),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.close, color: Colors.white, size: 40),
                  ),
                  child: _profiles[_currentIndex] is FlatListingProfile
                      ? FlatListingProfileCard(
                    profile: _profiles[_currentIndex],
                    matchPercentage: _calculateMatchPercentage(_currentUserParsedProfile, _profiles[_currentIndex]),
                    imageUrls: (_profiles[_currentIndex] as FlatListingProfile).imageUrls ?? [],
                  )
                      : SeekingFlatmateProfileCard(
                    profile: _profiles[_currentIndex],
                    matchPercentage: _calculateMatchPercentage(_currentUserParsedProfile, _profiles[_currentIndex]),
                    imageUrls: (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls ?? [],
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      )
          : Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _profiles.isNotEmpty
                    ? Dismissible(
                  key: ValueKey(_profiles[_currentIndex].documentId),
                  direction: DismissDirection.horizontal,
                  onDismissed: _handleProfileDismissed,
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 40),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.close, color: Colors.white, size: 40),
                  ),
                  child: _profiles[_currentIndex] is FlatListingProfile
                      ? FlatListingProfileCard(
                    profile: _profiles[_currentIndex],
                    matchPercentage: _calculateMatchPercentage(_currentUserParsedProfile, _profiles[_currentIndex]),
                    imageUrls: (_profiles[_currentIndex] as FlatListingProfile).imageUrls ?? [],
                  )
                      : SeekingFlatmateProfileCard(
                    profile: _profiles[_currentIndex],
                    matchPercentage: _calculateMatchPercentage(_currentUserParsedProfile, _profiles[_currentIndex]),
                    imageUrls: (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls ?? [],
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          // Buttons for mobile view, allowing explicit like/pass without full swipe
          if (_profiles.isNotEmpty)
            _buildActionButtons(
                _profiles[_currentIndex] is FlatListingProfile
                    ? (_profiles[_currentIndex] as FlatListingProfile).uid!
                    : (_profiles[_currentIndex] as SeekingFlatmateProfile).uid!
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String targetUserId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'passBtn',
            onPressed: () {
              _handleProfileDismissed(DismissDirection.endToStart); // Simulate swipe left
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.close, color: Colors.white),
          ),
          FloatingActionButton(
            heroTag: 'likeBtn',
            onPressed: () {
              _handleProfileDismissed(DismissDirection.startToEnd); // Simulate swipe right
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// Placeholder for your actual profile display widgets
// You would replace these with your existing widgets like FlatListingProfileDisplay
// and SeekingFlatmateProfileDisplay, adapting them to take a matchPercentage if needed.
class FlatListingProfileCard extends StatelessWidget {
  final FlatListingProfile profile;
  final double matchPercentage;
  final List<String> imageUrls; // NEW PARAMETER

  const FlatListingProfileCard({
    super.key,
    required this.profile,
    required this.matchPercentage,
    required this.imageUrls, // NEW PARAMETER
  });

  @override
  Widget build(BuildContext context) {
    // Determine actual images to display (with placeholder)
    final List<String> imagesToDisplay = (imageUrls.isNotEmpty)
        ? List<String>.from(imageUrls)
        : ['https://via.placeholder.com/400x300?text=No+Flat+Images'];

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // Wrap the Column with SingleChildScrollView
      child: SingleChildScrollView( // Added SingleChildScrollView here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Carousel with Indicators
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final PageController pageController = PageController();
                int currentImageLocalIndex = 0;

                // Listener to update the index for dot indicators
                pageController.addListener(() {
                  if (pageController.page != null) {
                    setState(() {
                      currentImageLocalIndex = pageController.page!.round();
                    });
                  }
                });

                return Column(
                  children: [
                    SizedBox(
                      height: 300, // Fixed height for the image carousel
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: imagesToDisplay.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              imagesToDisplay[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image, size: 100)),
                            ),
                          );
                        },
                      ),
                    ),
                    if (imagesToDisplay.length > 1) // Show indicators only if more than one image
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(imagesToDisplay.length, (index) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentImageLocalIndex == index
                                    ? Colors.redAccent
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.ownerName ?? 'N/A',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${profile.ownerAge ?? 'N/A'} years old, ${profile.ownerGender ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: 'Match Score',
                    value: '${matchPercentage.toStringAsFixed(0)}%',
                    icon: Icons.percent,
                    isMatchScore: true,
                  ),
                  _buildInfoSection(
                    title: 'Flat Details',
                    icon: Icons.home,
                    children: [
                      _buildChipList(
                        title: 'Type:',
                        items: [profile.flatType],
                        backgroundColor: Colors.lightBlue.shade100,
                        textColor: Colors.lightBlue.shade800,
                      ),
                      _buildChipList(
                        title: 'Furnishing:',
                        items: [profile.furnishedStatus],
                        backgroundColor: Colors.lightGreen.shade100,
                        textColor: Colors.lightGreen.shade800,
                      ),
                      _buildChipList(
                        title: 'Available For:',
                        items: [profile.availableFor],
                        backgroundColor: Colors.pink.shade100,
                        textColor: Colors.pink.shade800,
                      ),
                      _buildChipList(
                        title: 'Rent:',
                        items: [profile.rentPrice != null ? '₹${profile.rentPrice!.toStringAsFixed(0)}' : null],
                        backgroundColor: Colors.deepPurple.shade100,
                        textColor: Colors.deepPurple.shade800,
                      ),

                      _buildChipList(
                        title: 'Availability Date:',
                        items: [profile.availabilityDate != null ? DateFormat('dd MMM yyyy').format(profile.availabilityDate!) : null],
                        backgroundColor: Colors.indigo.shade100,
                        textColor: Colors.indigo.shade800,
                      ),
                    ],
                  ),
                  _buildInfoSection(
                    title: 'Amenities',
                    icon: Icons.spa,
                    children: [
                      _buildChipList(
                        items: profile.amenities,
                        backgroundColor: Colors.green.shade100,
                        textColor: Colors.green.shade800,
                      ),
                    ],
                  ),
                  _buildInfoSection(
                    title: 'About the Flat',
                    value: profile.flatDescription,
                    icon: Icons.description,
                  ),
                  _buildInfoSection(
                    title: 'Owner Bio',
                    value: profile.ownerBio,
                    icon: Icons.person,
                  ),
                  _buildInfoSection(
                    title: 'Lifestyle & Habits',
                    icon: Icons.self_improvement,
                    children: [
                      _buildChipList(
                        title: 'Occupation:',
                        items: [profile.ownerOccupation],
                        backgroundColor: Colors.purple.shade100,
                        textColor: Colors.purple.shade800,
                      ),
                      _buildChipList(
                        title: 'Smoking:',
                        items: [profile.smokingHabit],
                        backgroundColor: Colors.deepOrange.shade100,
                        textColor: Colors.deepOrange.shade800,
                      ),
                      _buildChipList(
                        title: 'Drinking:',
                        items: [profile.drinkingHabit],
                        backgroundColor: Colors.cyan.shade100,
                        textColor: Colors.cyan.shade800,
                      ),
                      _buildChipList(
                        title: 'Food:',
                        items: [profile.foodPreference],
                        backgroundColor: Colors.amber.shade100,
                        textColor: Colors.amber.shade800,
                      ),
                      _buildChipList(
                        title: 'Cleanliness:',
                        items: [profile.cleanlinessLevel],
                        backgroundColor: Colors.blue.shade100,
                        textColor: Colors.blue.shade800,
                      ),
                      _buildChipList(
                        title: 'Noise:',
                        items: [profile.noiseLevel],
                        backgroundColor: Colors.red.shade100,
                        textColor: Colors.red.shade800,
                      ),
                      _buildChipList(
                        title: 'Social:',
                        items: [profile.socialPreferences],
                        backgroundColor: Colors.pink.shade100,
                        textColor: Colors.pink.shade800,
                      ),
                      _buildChipList(
                        title: 'Visitors:',
                        items: [profile.visitorsPolicy],
                        backgroundColor: Colors.brown.shade100,
                        textColor: Colors.brown.shade800,
                      ),
                      _buildChipList(
                        title: 'Pets (Owner):',
                        items: [profile.petOwnership],
                        backgroundColor: Colors.lightGreen.shade100,
                        textColor: Colors.lightGreen.shade800,
                      ),
                      _buildChipList(
                        title: 'Pets (Tolerance):',
                        items: [profile.petTolerance],
                        backgroundColor: Colors.teal.shade100,
                        textColor: Colors.teal.shade800,
                      ),
                      _buildChipList(
                        title: 'Sleeping:',
                        items: [profile.sleepingSchedule],
                        backgroundColor: Colors.indigo.shade100,
                        textColor: Colors.indigo.shade800,
                      ),
                      _buildChipList(
                        title: 'Work:',
                        items: [profile.workSchedule],
                        backgroundColor: Colors.grey.shade300,
                        textColor: Colors.grey.shade800,
                      ),
                      _buildChipList(
                        title: 'Common Spaces:',
                        items: [profile.sharingCommonSpaces],
                        backgroundColor: Colors.deepPurple.shade100,
                        textColor: Colors.deepPurple.shade800,
                      ),
                      _buildChipList(
                        title: 'Overnight Guests:',
                        items: [profile.guestsOvernightPolicy],
                        backgroundColor: Colors.lime.shade100,
                        textColor: Colors.lime.shade800,
                      ),
                      _buildChipList(
                        title: 'Personal Space:',
                        items: [profile.personalSpaceVsSocialization],
                        backgroundColor: Colors.amber.shade100,
                        textColor: Colors.amber.shade800,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    IconData? icon,
    String? value,
    List<Widget>? children,
    bool isMatchScore = false,
  }) {
    if (value == null && (children == null || children.isEmpty)) {
      return const SizedBox.shrink(); // Don't show if no content
    }
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, color: isMatchScore ? Colors.green : Colors.redAccent, size: 24),
                if (icon != null) const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isMatchScore ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
                if (isMatchScore && value != null) ...[
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ],
            ),
            if (value != null && !isMatchScore) ...[
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
            if (children != null && children.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0, // horizontal space between chips
                runSpacing: 8.0, // vertical space between lines of chips
                children: children,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChipList({
    String? title,
    required List<String?>? items, // Corrected: Made items nullable in the signature
    Color backgroundColor = Colors.redAccent,
    Color textColor = Colors.white,
  }) {
    final nonNullItems = (items ?? []).where((item) => item != null && item.isNotEmpty).toList();
    if (nonNullItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        if (title != null) const SizedBox(height: 5),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: nonNullItems.map((item) {
            return Chip(
              label: Text(
                item!,
                style: TextStyle(color: textColor),
              ),
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: textColor.withOpacity(0.5), width: 0.8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SeekingFlatmateProfileCard extends StatelessWidget {
  final SeekingFlatmateProfile profile;
  final double matchPercentage;
  final List<String> imageUrls; // NEW PARAMETER

  const SeekingFlatmateProfileCard({
    super.key,
    required this.profile,
    required this.matchPercentage,
    required this.imageUrls, // NEW PARAMETER
  });

  @override
  Widget build(BuildContext context) {
    // Determine actual images to display (with placeholder)
    final List<String> imagesToDisplay = (imageUrls.isNotEmpty)
        ? List<String>.from(imageUrls)
        : ['https://via.placeholder.com/400x300?text=No+Profile+Images'];

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // Wrap the Column with SingleChildScrollView
      child: SingleChildScrollView( // Added SingleChildScrollView here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Carousel with Indicators
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                final PageController pageController = PageController();
                int currentImageLocalIndex = 0;

                // Listener to update the index for dot indicators
                pageController.addListener(() {
                  if (pageController.page != null) {
                    setState(() {
                      currentImageLocalIndex = pageController.page!.round();
                    });
                  }
                });

                return Column(
                  children: [
                    SizedBox(
                      height: 300, // Fixed height for the image carousel
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: imagesToDisplay.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              imagesToDisplay[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image, size: 100)),
                            ),
                          );
                        },
                      ),
                    ),
                    if (imagesToDisplay.length > 1) // Show indicators only if more than one image
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(imagesToDisplay.length, (index) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentImageLocalIndex == index
                                    ? Colors.redAccent
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name ?? 'N/A',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${profile.age ?? 'N/A'} years old, ${profile.gender ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: 'Match Score',
                    value: '${matchPercentage.toStringAsFixed(0)}%',
                    icon: Icons.percent,
                    isMatchScore: true,
                  ),
                  _buildInfoSection(
                    title: 'Looking For',
                    icon: Icons.search,
                    children: [
                      _buildChipList(
                        title: 'Desired City:',
                        items: [profile.desiredCity],
                        backgroundColor: Colors.blue.shade100,
                        textColor: Colors.blue.shade800,
                      ),
                      _buildChipList(
                        title: 'Area Preference:',
                        items: [profile.areaPreference],
                        backgroundColor: Colors.green.shade100,
                        textColor: Colors.green.shade800,
                      ),
                      _buildChipList(
                        title: 'Move-in Date:',
                        items: [
                          profile.moveInDate != null
                              ? DateFormat('MMM dd, yyyy').format(profile.moveInDate!)
                              : 'Flexible'
                        ],
                        backgroundColor: Colors.orange.shade100,
                        textColor: Colors.orange.shade800,
                      ),
                      _buildChipList(
                        title: 'Budget:',
                        items: [
                          profile.budgetMin != null && profile.budgetMax != null
                              ? '₹${NumberFormat('#,##0').format(profile.budgetMin)} - ₹${NumberFormat('#,##0').format(profile.budgetMax)}'
                              : 'N/A'
                        ],
                        backgroundColor: Colors.red.shade100,
                        textColor: Colors.red.shade800,
                      ),
                    ],
                  ),
                  _buildInfoSection(
                    title: 'Bio',
                    value: profile.bio,
                    icon: Icons.info,
                  ),
                  _buildInfoSection(
                    title: 'Lifestyle & Habits',
                    icon: Icons.self_improvement,
                    children: [
                      _buildChipList(
                        title: 'Occupation:',
                        items: [profile.occupation],
                        backgroundColor: Colors.purple.shade100,
                        textColor: Colors.purple.shade800,
                      ),
                      _buildChipList(
                        title: 'Cleanliness:',
                        items: [profile.cleanliness],
                        backgroundColor: Colors.blue.shade100,
                        textColor: Colors.blue.shade800,
                      ),
                      _buildChipList(
                        title: 'Social Habits:',
                        items: [profile.socialHabits],
                        backgroundColor: Colors.pink.shade100,
                        textColor: Colors.pink.shade800,
                      ),
                      _buildChipList(
                        title: 'Work Schedule:',
                        items: [profile.workSchedule],
                        backgroundColor: Colors.grey.shade300,
                        textColor: Colors.grey.shade800,
                      ),
                      _buildChipList(
                        title: 'Noise Level:',
                        items: [profile.noiseLevel],
                        backgroundColor: Colors.red.shade100,
                        textColor: Colors.red.shade800,
                      ),
                      _buildChipList(
                        title: 'Smoking Habits:',
                        items: [profile.smokingHabits],
                        backgroundColor: Colors.deepOrange.shade100,
                        textColor: Colors.deepOrange.shade800,
                      ),
                      _buildChipList(
                        title: 'Drinking Habits:',
                        items: [profile.drinkingHabits],
                        backgroundColor: Colors.cyan.shade100,
                        textColor: Colors.cyan.shade800,
                      ),
                      _buildChipList(
                        title: 'Food Preference:',
                        items: [profile.foodPreference],
                        backgroundColor: Colors.amber.shade100,
                        textColor: Colors.amber.shade800,
                      ),
                      _buildChipList(
                        title: 'Guests Frequency:',
                        items: [profile.guestsFrequency],
                        backgroundColor: Colors.brown.shade100,
                        textColor: Colors.brown.shade800,
                      ),
                      _buildChipList(
                        title: 'Visitors Policy:',
                        items: [profile.visitorsPolicy],
                        backgroundColor: Colors.teal.shade100,
                        textColor: Colors.teal.shade800,
                      ),
                      _buildChipList(
                        title: 'Pet Ownership:',
                        items: [profile.petOwnership],
                        backgroundColor: Colors.lightGreen.shade100,
                        textColor: Colors.lightGreen.shade800,
                      ),
                      _buildChipList(
                        title: 'Pet Tolerance:',
                        items: [profile.petTolerance],
                        backgroundColor: Colors.teal.shade100,
                        textColor: Colors.teal.shade800,
                      ),
                      _buildChipList(
                        title: 'Sleeping Schedule:',
                        items: [profile.sleepingSchedule],
                        backgroundColor: Colors.indigo.shade100,
                        textColor: Colors.indigo.shade800,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    IconData? icon,
    String? value,
    List<Widget>? children,
    bool isMatchScore = false,
  }) {
    if (value == null && (children == null || children.isEmpty)) {
      return const SizedBox.shrink(); // Don't show if no content
    }
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, color: isMatchScore ? Colors.green : Colors.redAccent, size: 24),
                if (icon != null) const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isMatchScore ? Colors.green.shade700 : Colors.black87,
                  ),
                ),
                if (isMatchScore && value != null) ...[
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ],
            ),
            if (value != null && !isMatchScore) ...[
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
            if (children != null && children.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0, // horizontal space between chips
                runSpacing: 8.0, // vertical space between lines of chips
                children: children,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChipList({
    String? title,
    required List<String?>? items, // Corrected: Already nullable in this class, consistent
    Color backgroundColor = Colors.redAccent,
    Color textColor = Colors.white,
  }) {
    final nonNullItems = (items ?? []).where((item) => item != null && item.isNotEmpty).toList();
    if (nonNullItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        if (title != null) const SizedBox(height: 5),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: nonNullItems.map((item) {
            return Chip(
              label: Text(
                item!,
                style: TextStyle(color: textColor),
              ),
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: textColor.withOpacity(0.5), width: 0.8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            );
          }).toList(),
        ),
      ],
    );
  }
}