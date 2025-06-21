// matching_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:mytennat/screens/chat_screen.dart';
import 'package:mytennat/screens/filter_screen.dart';
import 'package:mytennat/screens/filter_options.dart';


class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

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
  dynamic _currentUserParsedProfile; // NEW: Store the current user's parsed profile
  FilterOptions _currentFilters = FilterOptions(); // NEW: Current active filters


  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog('Not Logged In', 'Please log in to use the matching feature.', () {
          // You might navigate to a login screen here
        });
      });
    } else {
      _fetchUserProfile();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile({bool applyFilters = false}) async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        _userProfileType = userDoc['userType'];
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (_userProfileType == 'flat_listing') {
          _currentUserParsedProfile = FlatListingProfile.fromMap(userData, userDoc.id);
          await _fetchSeekingFlatmateProfiles(applyFilters: applyFilters);
        } else if (_userProfileType == 'seeking_flatmate') {
          _currentUserParsedProfile = SeekingFlatmateProfile.fromMap(userData, userDoc.id);
          await _fetchFlatListingProfiles(applyFilters: applyFilters);
        } else {
          _showAlertDialog('Profile Type Not Found', 'Your profile type could not be determined.', () {});
        }
      } else {
        _showAlertDialog('Profile Not Found', 'Please complete your profile first.', () {
          // Navigate to profile creation screen
        });
      }
    } catch (e) {
      _showAlertDialog('Error', 'Failed to fetch user profile: $e', () {});
      print('Firebase Firestore Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _currentIndex = 0; // Reset index when new profiles are fetched
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0); // Reset image carousel
        }
      });
    }
  }

  Future<void> _fetchFlatListingProfiles({bool applyFilters = false}) async {
    try {
      Query query = _firestore.collection('users')
          .where('userType', isEqualTo: 'flat_listing')
          .where('uid', isNotEqualTo: _currentUser!.uid);

      if (applyFilters && _currentUserParsedProfile is SeekingFlatmateProfile) {
        // final SeekingFlatmateProfile userProfile = _currentUserParsedProfile as SeekingFlatmateProfile; // Not directly used for filters here

        // --- Location & Price Filters ---
        if (_currentFilters.desiredCity != null && _currentFilters.desiredCity!.isNotEmpty) {
          query = query.where('desiredCity', isEqualTo: _currentFilters.desiredCity);
        }
        if (_currentFilters.areaPreference != null && _currentFilters.areaPreference!.isNotEmpty) {
          query = query.where('areaPreference', isEqualTo: _currentFilters.areaPreference);
        }
        if (_currentFilters.availabilityDate != null) {
          // Query for dates greater than or equal to the filter date
          query = query.where('flatDetails.availabilityDate', isGreaterThanOrEqualTo: _currentFilters.availabilityDate);
        }
        if (_currentFilters.rentPriceMin != null) {
          query = query.where('flatDetails.rentPrice', isGreaterThanOrEqualTo: _currentFilters.rentPriceMin);
        }
        if (_currentFilters.rentPriceMax != null) {
          query = query.where('flatDetails.rentPrice', isLessThanOrEqualTo: _currentFilters.rentPriceMax);
        }

        // --- Flat Details Filters ---
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
          // Firestore only allows one arrayContainsAny per query. If you have many, consider client-side filtering.
          query = query.where('flatDetails.amenities', arrayContainsAny: _currentFilters.amenitiesDesired);
        }
        if (_currentFilters.availableFor != null && _currentFilters.availableFor!.isNotEmpty) {
          query = query.where('flatDetails.availableFor', isEqualTo: _currentFilters.availableFor);
        }

        // --- Lifestyle & Habit Filters (matching seeker's preferences with lister's habits) ---
        // Note: The field names here must match exactly what's stored in your FlatListingProfile in Firestore
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
          query = query.where('socialPreferences', isEqualTo: _currentFilters.socialHabits); // Assuming this mapping
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

        // --- Complex filtering (selectedIdealQualities, selectedDealBreakers) ---
        // For these list-based preferences, direct Firestore queries are limited.
        // You generally can only use one `arrayContainsAny` per query.
        // If you need to filter by multiple ideal qualities OR deal breakers from lists,
        // you will likely need to fetch a broader set of results and then filter them client-side.
        // Example for one:
        // if (_currentFilters.selectedIdealQualities.isNotEmpty) {
        //   query = query.where('idealQualities', arrayContainsAny: _currentFilters.selectedIdealQualities);
        // }
        // For multiple, consider client-side filtering or a backend solution.
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
      Query query = _firestore.collection('users')
          .where('userType', isEqualTo: 'seeking_flatmate')
          .where('uid', isNotEqualTo: _currentUser!.uid);

      if (applyFilters && _currentUserParsedProfile is FlatListingProfile) {
        // final FlatListingProfile userProfile = _currentUserParsedProfile as FlatListingProfile; // Not directly used for filters here

        // --- Location & Price Filters ---
        if (_currentFilters.desiredCity != null && _currentFilters.desiredCity!.isNotEmpty) {
          query = query.where('desiredCity', isEqualTo: _currentFilters.desiredCity);
        }
        if (_currentFilters.areaPreference != null && _currentFilters.areaPreference!.isNotEmpty) {
          query = query.where('areaPreference', isEqualTo: _currentFilters.areaPreference);
        }
        if (_currentFilters.moveInDate != null) {
          // Query for dates less than or equal to the filter date (i.e., they can move in by then)
          query = query.where('moveInDate', isLessThanOrEqualTo: _currentFilters.moveInDate);
        }
        if (_currentFilters.budgetMin != null) {
          query = query.where('budgetMin', isGreaterThanOrEqualTo: _currentFilters.budgetMin);
        }
        if (_currentFilters.budgetMax != null) {
          query = query.where('budgetMax', isLessThanOrEqualTo: _currentFilters.budgetMax);
        }

        // --- Lifestyle & Habit Filters (matching lister's preferences with seeker's habits) ---
        // Note: The field names here must match exactly what's stored in your SeekingFlatmateProfile in Firestore
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
          query = query.where('cleanliness', isEqualTo: _currentFilters.cleanlinessLevel); // Assuming this mapping
        }
        if (_currentFilters.socialHabits != null && _currentFilters.socialHabits!.isNotEmpty) {
          query = query.where('socialHabits', isEqualTo: _currentFilters.socialHabits);
        }
        if (_currentFilters.noiseLevel != null && _currentFilters.noiseLevel!.isNotEmpty) {
          query = query.where('noiseLevel', isEqualTo: _currentFilters.noiseLevel);
        }
        if (_currentFilters.smokingHabit != null && _currentFilters.smokingHabit!.isNotEmpty) {
          query = query.where('smokingHabits', isEqualTo: _currentFilters.smokingHabit); // Note field name
        }
        if (_currentFilters.drinkingHabit != null && _currentFilters.drinkingHabit!.isNotEmpty) {
          query = query.where('drinkingHabits', isEqualTo: _currentFilters.drinkingHabit); // Note field name
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
          // This field might be in FlatListingProfile's preferences for a seeker, not seeker's own profile.
          // You need to clarify where guestsOvernightPolicy is stored in SeekingFlatmateProfile to query it.
          // For now, I'll assume it exists directly in SeekingFlatmateProfile, but verify.
          query = query.where('guestsFrequency', isEqualTo: _currentFilters.guestsOvernightPolicy); // Assuming mapping
        }
        if (_currentFilters.occupation != null && _currentFilters.occupation!.isNotEmpty) {
          query = query.where('occupation', isEqualTo: _currentFilters.occupation);
        }
        // --- Complex filtering (selectedIdealQualities, selectedDealBreakers) ---
        // Same considerations as above, likely requiring client-side filtering.
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


  Future<void> _navigateToFilterScreen() async {
    // Pass a copy of current filters to the filter screen
    final FilterOptions? resultFilters = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          initialFilters: _currentFilters.copyWith(), // Pass a copy
          isSeekingFlatmate: _userProfileType == 'seeking_flatmate',
          onFiltersChanged: (newFilters) { // NEW: This callback is essential for the route case
            setState(() {
              _currentFilters = newFilters; // Update with new filters
            });
            // No need to call _fetchUserProfile here, as Navigator.pop will handle it
            // if _applyFilters in FilterScreen correctly pops the value.
            // However, to be robust if FilterScreen is designed to always call onFiltersChanged
            // without popping a result, then keeping this fetch is fine.
          },
        ),
      ),
    );

    // If resultFilters is not null (meaning filters were applied and popped)
    if (resultFilters != null) {
      setState(() {
        _currentFilters = resultFilters; // Update with new filters
      });
      // Re-fetch profiles with new filters applied
      _fetchUserProfile(applyFilters: true);
    } else {
      // If resultFilters is null (e.g., user pressed back without applying),
      // just re-fetch with current filters to refresh in case something changed implicitly.
      _fetchUserProfile(applyFilters: true);
    }
  }


  // --- NEW: Function to handle a 'like' action ---
// In matching_screen.dart, inside _MatchingScreenState class:
  Future<void> _processLike(String likedUserId) async {
    if (_currentUser == null) {
      print("_processLike: Current user is null. Aborting like process.");
      return;
    }

    final currentUserId = _currentUser!.uid;
    print("_processLike: User $currentUserId attempting to like $likedUserId.");

    try {
      // --- OPERATION 1: Recording the current user's like (SET operation) ---
      print("_processLike (Op1): Attempting to record like for $currentUserId on $likedUserId.");
      try {
        await _firestore.collection('user_likes').doc(currentUserId).collection('likes').doc(likedUserId).set({
          'timestamp': FieldValue.serverTimestamp(),
        });
        print("_processLike (Op1): Successfully recorded like for $currentUserId on $likedUserId.");
      } catch (e) {
        print("_processLike (Op1) ERROR: Failed to SET like document: $e");
        _showAlertDialog('Error', 'Failed to record your like: ${e.toString()}', () {});
        return; // Stop execution if this critical step fails
      }

      // --- OPERATION 2: Checking if the other user has also liked the current user (GET operation) ---
      print("_processLike (Op2): Checking if $likedUserId has liked $currentUserId.");
      DocumentSnapshot otherUserLikesMe;
      try {
        otherUserLikesMe = await _firestore.collection('user_likes').doc(likedUserId).collection('likes').doc(currentUserId).get();
        print("_processLike (Op2): Other user like check completed. Exists: ${otherUserLikesMe.exists}");
      } catch (e) {
        print("_processLike (Op2) ERROR: Failed to GET other user's like: $e");
        _showAlertDialog('Error', 'Failed to check for mutual like: ${e.toString()}', () {});
        return; // Stop execution if this critical step fails
      }


      if (otherUserLikesMe.exists) {
        print("_processLike: Mutual like detected! IT'S A MATCH!");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('It\'s a MATCH! 🎉'))
        );

        // --- OPERATION 3: Creating a match document and a chat room (calls _createMatchAndChatRoom) ---
        print("_processLike (Op3): Calling _createMatchAndChatRoom...");
        try {
          await _createMatchAndChatRoom(currentUserId, likedUserId);
          print("_processLike (Op3): _createMatchAndChatRoom call completed successfully.");
        } catch (e) {
          print("_processLike (Op3) ERROR: _createMatchAndChatRoom failed: $e");
          _showAlertDialog('Error', 'Failed to create match/chat: ${e.toString()}', () {});
          return; // Stop execution if this critical step fails
        }


        // Safely get matched profile name for the dialog
        String chatPartnerNameForDialog = 'that user';
        try {
          final matchedProfile = _profiles.firstWhere((p) => p.documentId == likedUserId);
          chatPartnerNameForDialog = matchedProfile is FlatListingProfile ? matchedProfile.ownerName : (matchedProfile as SeekingFlatmateProfile).name;
        } catch (e) {
          print("_processLike: Could not find matched profile in _profiles for dialog. Error: $e");
        }

        // Show match dialog and navigate to chat
        if (mounted) { // Ensure widget is still mounted before showing dialog
          _showMatchDialog(
            'It\'s a Match!',
            'You and $chatPartnerNameForDialog have liked each other! Start chatting now?',
                () {
              if (mounted) { // Ensure widget is still mounted before navigation
                Navigator.of(context).pop(); // Dismiss alert dialog
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
      // This outer catch should ideally not be hit if inner catches handle specific errors.
      // It's a fallback for unexpected issues.
      print("_processLike: UNEXPECTED GLOBAL ERROR: $e");
      _showAlertDialog('Error', 'An unexpected error occurred: ${e.toString()}', () {});
    }
  }

  // --- NEW: Function to create a match document and chat room ---
  // In matching_screen.dart, inside _MatchingScreenState class:
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

        // Create new chat room
        DocumentReference chatRef = await _firestore.collection('chats').add({
          'participants': sortedUids,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageSenderId': '',
          'lastMessageTimestamp': null,
        });
        String chatRoomId = chatRef.id;
        print("createMatchAndChatRoom: Chat room created with ID: $chatRoomId");

        // Create a new match document in the 'matches' collection
        await _firestore.collection('matches').doc(matchDocId).set({
          'user1_id': sortedUids[0],
          'user2_id': sortedUids[1],
          'chatRoomId': chatRoomId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("createMatchAndChatRoom: Match document created successfully for $matchDocId");

        // After creating match and chat, potentially navigate or update UI
        // Example: Navigate to chat screen immediately
        if (mounted) { // Check if the widget is still in the tree before navigating
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatPartnerId: (user1Id == _currentUser!.uid) ? user2Id : user1Id,
                chatPartnerName: "Match!", // You might fetch actual name here
              ),
            ),
          );
        }

      } else {
        print(
            "createMatchAndChatRoom: Match document already exists for $matchDocId. Not creating.");
        // Explicitly cast data to Map<String, dynamic>
        final Map<String, dynamic>? matchData = matchDoc.data() as Map<
            String,
            dynamic>?;

        if (matchData != null && matchData['chatRoomId'] != null) {
          final existingChatRoomId = matchData['chatRoomId'] as String;
          print(
              "createMatchAndChatRoom: Existing chatRoomId: $existingChatRoomId"); // Added log
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(
                      chatPartnerId: (user1Id == _currentUser!.uid)
                          ? user2Id
                          : user1Id,
                      chatPartnerName: "Match!", // You might fetch actual name here
                      // chatRoomId: existingChatRoomId, // <-- You might need to pass this to ChatScreen if it uses it for existing chats
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

  // --- NEW: Match Dialog ---
  void _showMatchDialog(String title, String message, VoidCallback onChatPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Just dismiss the dialog
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: onChatPressed,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Chat Now!', style: TextStyle(color: Colors.white)),
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
        final dismissedProfileId = dismissedProfile.documentId; // Assuming 'documentId' exists on your profile models

        if (direction == DismissDirection.endToStart) { // Swiped left (Pass)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile Passed'))
          );
          // TODO: Optionally record the 'pass' in Firestore to avoid showing again
        } else if (direction == DismissDirection.startToEnd) { // Swiped right (Like)
          _processLike(dismissedProfileId); // Call the new like processing function
        }

        // Remove the dismissed profile from the list AFTER processing
        // This ensures _processLike has the correct context of the dismissed profile
        _profiles.removeAt(_currentIndex);


      }

      // If no more profiles after removal, show the empty state
      if (_profiles.isEmpty) {
        _showAlertDialog('No More Profiles', 'You\'ve viewed all available profiles for now.', () {
          // Optionally, navigate to homepage or show a different state
        });
      }
      // Reset image index for the new card
      _currentImageIndex = 0;
      // Ensure page controller is attached before jumping
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  // NEW: Function to calculate matching percentage
  double _calculateMatchPercentage(dynamic userProfile, dynamic otherProfile) {
    if (userProfile == null || otherProfile == null) return 0.0;

    double score = 0;
    double maxScore = 0;

    // --- Weights for different categories (adjust as needed) ---
    const double basicInfoWeight = 0.2;
    const double habitsWeight = 0.4;
    const double requirementsPreferencesWeight = 0.4;

    if (userProfile is SeekingFlatmateProfile && otherProfile is FlatListingProfile) {
      // --- Basic Info Comparison ---
      // Max score for basic info (5 attributes * 1 point each)
      maxScore += 5 * basicInfoWeight; // Total for basic info

      // Desired City
      if (userProfile.desiredCity.toLowerCase() == otherProfile.desiredCity.toLowerCase()) {
        score += 1 * basicInfoWeight;
      }
      // Area Preference
      if (userProfile.areaPreference.toLowerCase() == otherProfile.areaPreference.toLowerCase()) {
        score += 1 * basicInfoWeight;
      }
      // Gender
      if (userProfile.gender.toLowerCase() == otherProfile.ownerGender.toLowerCase()) {
        score += 1 * basicInfoWeight;
      }

      // Age compatibility (e.g., if other user's age is within preferred range)
      if (userProfile.preferredFlatmateAge.isNotEmpty && otherProfile.ownerAge != null) {
        if (userProfile.preferredFlatmateAge.contains('-')) {
          final parts = userProfile.preferredFlatmateAge.split('-');
          if (parts.length == 2) {
            final minAge = int.tryParse(parts[0].trim());
            final maxAge = int.tryParse(parts[1].trim());
            if (minAge != null && maxAge != null && otherProfile.ownerAge! >= minAge && otherProfile.ownerAge! <= maxAge) {
              score += 1 * basicInfoWeight;
            }
          }
        } else if (userProfile.preferredFlatmateAge.toLowerCase() == 'any') {
          score += 1 * basicInfoWeight; // Considered a match if 'any'
        }
      }

      // Occupation Match (simple match for now)
      if (userProfile.preferredOccupation.toLowerCase() == otherProfile.ownerOccupation.toLowerCase() && userProfile.preferredOccupation.isNotEmpty) {
        score += 1 * basicInfoWeight;
      }

      // --- Habits Comparison (more nuanced) ---
      // NO fixed maxScore for habits here. Each habit adds its max potential.

      // Smoking
      maxScore += 2 * habitsWeight; // Max score for smoking
      final userSmokes = userProfile.smokingHabits.toLowerCase();
      final otherSmokes = otherProfile.smokingHabit.toLowerCase();

      if (
      (userSmokes == 'never' && otherSmokes == 'never') ||
          (userSmokes == 'occasionally' && (otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
          (userSmokes == 'socially' && (otherSmokes == 'socially' || otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
          (userSmokes == 'regularly' && otherSmokes == 'regularly') ||
          (userSmokes == 'tolerates' && (otherSmokes == 'occasionally' || otherSmokes == 'socially' || otherSmokes == 'regularly'))
      ) {
        score += 2 * habitsWeight;
      }

      // Drinking
      maxScore += 2 * habitsWeight; // Max score for drinking
      final userDrinksPref = userProfile.drinkingHabits.toLowerCase();
      final otherDrinksActual = otherProfile.drinkingHabit.toLowerCase();

      if (
      (userDrinksPref == 'never' && otherDrinksActual == 'never') ||
          (userDrinksPref == 'occasionally' && (otherDrinksActual == 'occasionally' || otherDrinksActual == 'never')) ||
          (userDrinksPref == 'socially' && (otherDrinksActual == 'socially' || otherDrinksActual == 'occasionally' || otherDrinksActual == 'never')) ||
          (userDrinksPref == 'regularly' && otherDrinksActual == 'regularly') ||
          (userDrinksPref == 'tolerates' && (otherDrinksActual == 'occasionally' || otherDrinksActual == 'socially' || otherDrinksActual == 'regularly'))
      ) {
        score += 2 * habitsWeight;
      }

      // Food Preference
      maxScore += 1 * habitsWeight; // Max score for food preference
      final userFood = userProfile.foodPreference.toLowerCase();
      final otherFood = otherProfile.foodPreference.toLowerCase();

      if (userFood == otherFood) {
        score += 1 * habitsWeight;
      } else if (
      (userFood == 'vegan' && (otherFood == 'vegetarian' || otherFood == 'eggetarian' || otherFood == 'jain')) ||
          (otherFood == 'vegan' && (userFood == 'vegetarian' || userFood == 'eggetarian' || userFood == 'jain'))
      ) {
        score += 0.75 * habitsWeight;
      } else if (
      (userFood == 'vegetarian' && (otherFood == 'eggetarian' || otherFood == 'jain')) ||
          (otherFood == 'vegetarian' && (userFood == 'eggetarian' || userFood == 'jain'))
      ) {
        score += 0.75 * habitsWeight;
      } else if (
      (userFood == 'eggetarian' && (otherFood == 'vegetarian' || otherFood == 'jain')) ||
          (otherFood == 'eggetarian' && (userFood == 'vegetarian' || userFood == 'jain'))
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userFood == 'jain' && (otherFood == 'vegetarian' || otherFood == 'vegan' || otherFood == 'eggetarian')) ||
          (otherFood == 'jain' && (userFood == 'vegetarian' || userFood == 'vegan' || userFood == 'eggetarian'))
      ) {
        score += 0.75 * habitsWeight;
      } else if ((userFood == 'other' || otherFood == 'other')) {
        score += 0.2 * habitsWeight;
      }

      // Cleanliness
      maxScore += 2 * habitsWeight; // Max score for cleanliness
      final userCleanliness = userProfile.cleanliness.toLowerCase();
      final otherCleanliness = otherProfile.cleanlinessLevel.toLowerCase();

      if (userCleanliness == otherCleanliness) {
        score += 2 * habitsWeight;
      } else if (
      (userCleanliness == 'very tidy' && otherCleanliness == 'moderately tidy') ||
          (otherCleanliness == 'very tidy' && userCleanliness == 'moderately tidy')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userCleanliness == 'moderately tidy' && otherCleanliness == 'flexible') ||
          (otherCleanliness == 'moderately tidy' && userCleanliness == 'flexible')
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userCleanliness == 'flexible' && otherCleanliness == 'can be messy at times') ||
          (otherCleanliness == 'flexible' && userCleanliness == 'can be messy at times')
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userCleanliness == 'very tidy' && (otherCleanliness == 'flexible' || otherCleanliness == 'can be messy at times')) ||
          (otherCleanliness == 'very tidy' && (userCleanliness == 'flexible' || userCleanliness == 'can be messy at times'))
      ) {
        score += 0.2 * habitsWeight;
      }

      // Noise Level
      maxScore += 2 * habitsWeight; // Max score for noise level
      final userNoise = userProfile.noiseLevel.toLowerCase();
      final otherNoise = otherProfile.noiseLevel.toLowerCase();

      if (userNoise == otherNoise) {
        score += 2 * habitsWeight;
      } else if (
      (userNoise == 'very quiet' && otherNoise == 'moderate noise') ||
          (otherNoise == 'very quiet' && userNoise == 'moderate noise')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userNoise == 'moderate noise' && (otherNoise == 'very quiet' || otherNoise == 'lively')) ||
          (otherNoise == 'moderate noise' && (userNoise == 'very quiet' || userNoise == 'lively'))
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userNoise == 'flexible' && (otherNoise == 'very quiet' || otherNoise == 'moderate noise' || otherNoise == 'lively')) ||
          (otherNoise == 'flexible' && (userNoise == 'very quiet' || userNoise == 'moderate noise' || userNoise == 'lively'))
      ) {
        score += 1.8 * habitsWeight;
      } else if (
      (userNoise == 'lively' && otherNoise == 'very quiet') ||
          (otherNoise == 'lively' && userNoise == 'very quiet')
      ) {
        // These are generally a bad match unless one is flexible. Score 0 here.
      }

      // Social Habits
      maxScore += 1 * habitsWeight; // Max score for social habits
      final userSocial = userProfile.socialHabits.toLowerCase();
      final otherSocial = otherProfile.socialPreferences.toLowerCase();

      if (userSocial == otherSocial) {
        score += 1 * habitsWeight;
      } else if (
      (userSocial == 'flexible' && (otherSocial == 'social & outgoing' || otherSocial == 'occasional gatherings' || otherSocial == 'quiet & private')) ||
          (otherSocial == 'flexible' && (userSocial == 'social & outgoing' || userSocial == 'occasional gatherings' || userSocial == 'quiet & private'))
      ) {
        score += 0.9 * habitsWeight;
      } else if (
      (userSocial == 'social & outgoing' && otherSocial == 'occasional gatherings') ||
          (otherSocial == 'social & outgoing' && userSocial == 'occasional gatherings')
      ) {
        score += 0.7 * habitsWeight;
      } else if (
      (userSocial == 'occasional gatherings' && otherSocial == 'quiet & private') ||
          (otherSocial == 'occasional gatherings' && userSocial == 'quiet & private')
      ) {
        score += 0.6 * habitsWeight;
      } else if (
      (userSocial == 'social & outgoing' && otherSocial == 'quiet & private') ||
          (otherSocial == 'social & outgoing' && userSocial == 'quiet & private')
      ) {
        score += 0.2 * habitsWeight;
      }

      // Pet Ownership/Tolerance
      maxScore += 2 * habitsWeight; // Max score for pet ownership/tolerance
      final userOwns = userProfile.petOwnership.toLowerCase();
      final otherOwns = otherProfile.petOwnership.toLowerCase();
      final userTolerates = (userProfile.petTolerance ?? '').toLowerCase();
      final otherTolerates = (otherProfile.petTolerance ?? '').toLowerCase();

      double currentPetScore = 0;
      if (userOwns == 'no' && otherOwns == 'no') {
        currentPetScore = 2.0 * habitsWeight;
      } else if (userOwns == 'yes' && otherOwns == 'yes') {
        currentPetScore = 2.0 * habitsWeight;
      } else if ((userOwns == 'yes' && otherTolerates == 'tolerates pets') || (otherOwns == 'yes' && userTolerates == 'tolerates pets')) {
        currentPetScore = 2.0 * habitsWeight;
      } else if (userOwns == 'planning to get one' && otherOwns == 'planning to get one') {
        currentPetScore = 1.8 * habitsWeight;
      } else if ((userOwns == 'yes' && otherOwns == 'planning to get one') || (otherOwns == 'yes' && userOwns == 'planning to get one')) {
        currentPetScore = 1.5 * habitsWeight;
      } else if ((userOwns == 'no' && otherOwns == 'planning to get one' && userTolerates == 'tolerates pets') || (otherOwns == 'no' && userOwns == 'planning to get one' && otherTolerates == 'tolerates pets')) {
        currentPetScore = 1.0 * habitsWeight;
      } else if ((userOwns == 'planning to get one' && otherTolerates == 'tolerates pets') || (otherOwns == 'planning to get one' && userTolerates == 'tolerates pets')) {
        currentPetScore = 1.0 * habitsWeight;
      }
      score += currentPetScore;

      // Visitors Policy
      maxScore += 2 * habitsWeight; // Max score for visitors policy
      final userVisitors = userProfile.visitorsPolicy.toLowerCase();
      final otherVisitors = otherProfile.visitorsPolicy.toLowerCase();

      if (userVisitors == otherVisitors) {
        score += 2 * habitsWeight;
      } else if (
      (userVisitors == 'frequent visitors' && otherVisitors == 'occasional visitors') ||
          (otherVisitors == 'frequent visitors' && userVisitors == 'occasional visitors')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userVisitors == 'occasional visitors' && otherVisitors == 'rarely have visitors') ||
          (otherVisitors == 'occasional visitors' && userVisitors == 'rarely have visitors')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userVisitors == 'rarely have visitors' && otherVisitors == 'no visitors') ||
          (otherVisitors == 'rarely have visitors' && userVisitors == 'no visitors')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userVisitors == 'occasional visitors' && otherVisitors == 'no visitors') ||
          (otherVisitors == 'occasional visitors' && userVisitors == 'no visitors')
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userVisitors == 'frequent visitors' && otherVisitors == 'rarely have visitors') ||
          (otherVisitors == 'frequent visitors' && userVisitors == 'rarely have visitors')
      ) {
        score += 0.2 * habitsWeight;
      } else if (
      (userVisitors == 'frequent visitors' && otherVisitors == 'no visitors') ||
          (otherVisitors == 'frequent visitors' && userVisitors == 'no visitors')
      ) {
        // strong mismatch, 0 points
      }

      // Sleeping Schedule
      maxScore += 2 * habitsWeight; // Max score for sleeping schedule
      final userSchedule = userProfile.sleepingSchedule.toLowerCase();
      final otherSchedule = otherProfile.sleepingSchedule.toLowerCase();

      if (userSchedule == otherSchedule) {
        score += 2 * habitsWeight;
      } else if (
      (userSchedule == 'flexible' && (otherSchedule == 'early riser' || otherSchedule == 'night owl')) ||
          (otherSchedule == 'flexible' && (userSchedule == 'early riser' || userSchedule == 'night owl'))
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userSchedule == 'flexible' && otherSchedule == 'irregular') ||
          (otherSchedule == 'flexible' && userSchedule == 'irregular')
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userSchedule == 'early riser' && otherSchedule == 'irregular') ||
          (otherSchedule == 'early riser' && userSchedule == 'irregular')
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userSchedule == 'night owl' && otherSchedule == 'irregular') ||
          (otherSchedule == 'night owl' && userSchedule == 'irregular')
      ) {
        score += 0.5 * habitsWeight;
      }

      // Work/Study Schedule
      maxScore += 2 * habitsWeight; // Max score for work/study schedule
      final userWork = userProfile.workSchedule.toLowerCase();
      final otherWork = otherProfile.workSchedule.toLowerCase();

      if (userWork == otherWork) {
        score += 2 * habitsWeight;
      } else if (
      (userWork == 'mixed' && (otherWork == 'freelance/flexible hours' || otherWork == '9-5 office hours' || otherWork == 'student schedule' || otherWork == 'night shifts')) ||
          (otherWork == 'mixed' && (userWork == 'freelance/flexible hours' || userWork == '9-5 office hours' || userWork == 'student schedule' || userWork == 'night shifts')) ||
          (userWork == 'freelance/flexible hours' && (otherWork == '9-5 office hours' || otherWork == 'student schedule')) ||
          (otherWork == 'freelance/flexible hours' && (userWork == '9-5 office hours' || userWork == 'student schedule'))
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userWork == '9-5 office hours' && otherWork == 'student schedule') ||
          (otherWork == '9-5 office hours' && userWork == 'student schedule')
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userWork == 'freelance/flexible hours' && otherWork == 'night shifts') ||
          (otherWork == 'freelance/flexible hours' && userWork == 'night shifts')
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userWork == 'night shifts' && otherWork == 'student schedule') ||
          (otherWork == 'night shifts' && userWork == 'student schedule')
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userWork == '9-5 office hours' && otherWork == 'night shifts') ||
          (otherWork == '9-5 office hours' && userWork == 'night shifts')
      ) {
        score += 0.2 * habitsWeight;
      }

      // Sharing Habits (assuming property is `sharingCommonSpaces`)
      maxScore += 2 * habitsWeight; // Max score for sharing habits
      final userSharing = userProfile.sharingCommonSpaces.toLowerCase();
      final otherSharing = otherProfile.sharingCommonSpaces.toLowerCase();

      if (userSharing == otherSharing) {
        score += 2 * habitsWeight;
      } else if (
      (userSharing == 'flexible' && (otherSharing == 'share everything' || otherSharing == 'share some items' || otherSharing == 'prefer separate items')) ||
          (otherSharing == 'flexible' && (userSharing == 'share everything' || userSharing == 'share some items' || userSharing == 'prefer separate items'))
      ) {
        score += 1.8 * habitsWeight;
      } else if (
      (userSharing == 'share everything' && otherSharing == 'share some items') ||
          (otherSharing == 'share everything' && userSharing == 'share some items')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userSharing == 'share some items' && otherSharing == 'prefer separate items') ||
          (otherSharing == 'share some items' && userSharing == 'prefer separate items')
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userSharing == 'share everything' && otherSharing == 'prefer separate items') ||
          (otherSharing == 'share everything' && userSharing == 'prefer separate items')
      ) {
        score += 0.5 * habitsWeight;
      }

      // Guests Overnight Policy
      maxScore += 2 * habitsWeight; // Max score for guests overnight policy
      final userGuests = userProfile.guestsOvernightPolicy.toLowerCase();
      final otherGuests = otherProfile.guestsOvernightPolicy.toLowerCase();

      if (userGuests == otherGuests) {
        score += 2 * habitsWeight;
      } else if (
      (userGuests == 'frequently' && otherGuests == 'occasionally') ||
          (otherGuests == 'frequently' && userGuests == 'occasionally')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userGuests == 'occasionally' && otherGuests == 'rarely') ||
          (otherGuests == 'occasionally' && userGuests == 'rarely')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userGuests == 'rarely' && otherGuests == 'never') ||
          (otherGuests == 'rarely' && userGuests == 'never')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userGuests == 'occasionally' && otherGuests == 'never') ||
          (otherGuests == 'occasionally' && userGuests == 'never')
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userGuests == 'frequently' && otherGuests == 'rarely') ||
          (otherGuests == 'frequently' && userGuests == 'rarely')
      ) {
        score += 0.2 * habitsWeight;
      } else if (
      (userGuests == 'frequently' && otherGuests == 'never') ||
          (otherGuests == 'frequently' && userGuests == 'never')
      ) {
        // strong mismatch, 0 points
      }

      // Personal Space vs. Socialization
      maxScore += 2 * habitsWeight; // Max score for personal space vs. socialization
      final userSpaceSocial = userProfile.personalSpaceVsSocialization.toLowerCase();
      final otherSpaceSocial = otherProfile.personalSpaceVsSocialization.toLowerCase();

      if (userSpaceSocial == otherSpaceSocial) {
        score += 2 * habitsWeight;
      } else if (
      (userSpaceSocial == 'flexible' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'enjoy a balance' || otherSpaceSocial == 'prefer more socialization')) ||
          (otherSpaceSocial == 'flexible' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'enjoy a balance' || userSpaceSocial == 'prefer more socialization'))
      ) {
        score += 1.8 * habitsWeight;
      } else if (
      (userSpaceSocial == 'enjoy a balance' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'prefer more socialization')) ||
          (otherSpaceSocial == 'enjoy a balance' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'prefer more socialization'))
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userSpaceSocial == 'value personal space highly' && otherSpaceSocial == 'prefer more socialization') ||
          (otherSpaceSocial == 'value personal space highly' && userSpaceSocial == 'prefer more socialization')
      ) {
        score += 0.2 * habitsWeight;
      }

      // --- Requirements/Preferences Comparison ---
      // NO fixed maxScore for requirements here. Each requirement adds its max potential.

      // Flat Type
      maxScore += 1 * requirementsPreferencesWeight; // Max score for flat type
      if (userProfile.preferredFlatType.toLowerCase() == otherProfile.flatType.toLowerCase()) {
        score += 1 * requirementsPreferencesWeight;
      }

      // Furnished Status
      maxScore += 1 * requirementsPreferencesWeight; // Max score for furnished status
      if (userProfile.preferredFurnishedStatus.toLowerCase() == otherProfile.furnishedStatus.toLowerCase()) {
        score += 1 * requirementsPreferencesWeight;
      }

      // Budget (check if otherProfile's rent is within userProfile's budget range)
      maxScore += 2 * requirementsPreferencesWeight; // Max score for budget
      if (userProfile.budgetMin != null && userProfile.budgetMax != null && otherProfile.rentPrice != null) {
        if (otherProfile.rentPrice! >= userProfile.budgetMin! && otherProfile.rentPrice! <= userProfile.budgetMax!) {
          score += 2 * requirementsPreferencesWeight;
        }
      }

      // Amenities Desired (overlap)
      maxScore += 2 * requirementsPreferencesWeight; // Max score for amenities
      final amenityIntersection = userProfile.amenitiesDesired.toSet().intersection(otherProfile.amenities.toSet());
      score += (amenityIntersection.length / (userProfile.amenitiesDesired.length > 0 ? userProfile.amenitiesDesired.length : 1)) * 2 * requirementsPreferencesWeight;

      // Preferred Habits (other user's actual habits matching preferred habits)
      maxScore += 2 * requirementsPreferencesWeight; // Max score for preferred habits
      final preferredHabitsIntersection = userProfile.preferredHabits.toSet().intersection([
        otherProfile.smokingHabit,
        otherProfile.drinkingHabit,
        otherProfile.foodPreference,
        otherProfile.cleanlinessLevel,
        otherProfile.noiseLevel,
        otherProfile.socialPreferences,
        otherProfile.visitorsPolicy,
        otherProfile.petOwnership,
        otherProfile.petTolerance,
        otherProfile.sleepingSchedule,
        otherProfile.workSchedule,
        otherProfile.sharingCommonSpaces,
        otherProfile.guestsOvernightPolicy,
        otherProfile.personalSpaceVsSocialization,
      ].map((e) => e.toLowerCase()).toSet());
      score += (preferredHabitsIntersection.length / (userProfile.preferredHabits.length > 0 ? userProfile.preferredHabits.length : 1)) * 2 * requirementsPreferencesWeight;

      // Ideal Qualities (overlap)
      maxScore += 2 * requirementsPreferencesWeight; // Max score for ideal qualities
      final idealQualitiesIntersection = userProfile.idealQualities.toSet().intersection(otherProfile.flatmateIdealQualities.toSet());
      score += (idealQualitiesIntersection.length / (userProfile.idealQualities.length > 0 ? userProfile.idealQualities.length : 1)) * 2 * requirementsPreferencesWeight;

      // Deal Breakers (penalty for overlap) - No maxScore addition as it's a penalty
      final dealBreakersIntersection = userProfile.dealBreakers.toSet().intersection(otherProfile.flatmateDealBreakers.toSet());
      score -= (dealBreakersIntersection.length * 5) * requirementsPreferencesWeight; // Penalize heavily

    } else if (userProfile is FlatListingProfile && otherProfile is SeekingFlatmateProfile) {
      // --- Basic Info Comparison ---
      // Max score for basic info (5 attributes * 1 point each)
      maxScore += 5 * basicInfoWeight; // Total for basic info

      // Desired City
      if (userProfile.desiredCity.toLowerCase() == otherProfile.desiredCity.toLowerCase()) {
        score += 1 * basicInfoWeight;
      }
      // Area Preference
      if (userProfile.areaPreference.toLowerCase() == otherProfile.areaPreference.toLowerCase()) {
        score += 1 * basicInfoWeight;
      }
      // Gender
      if (userProfile.ownerGender.toLowerCase() == otherProfile.gender.toLowerCase()) {
        score += 1 * basicInfoWeight;
      }

      // Age compatibility (e.g., if other user's age is within preferred range of the flat lister)
      if (userProfile.preferredAgeGroup.isNotEmpty && otherProfile.age != null) {
        if (userProfile.preferredAgeGroup.contains('-')) {
          final parts = userProfile.preferredAgeGroup.split('-');
          if (parts.length == 2) {
            final minAge = int.tryParse(parts[0].trim());
            final maxAge = int.tryParse(parts[1].trim());
            if (minAge != null && maxAge != null && otherProfile.age! >= minAge && otherProfile.age! <= maxAge) {
              score += 1 * basicInfoWeight;
            }
          }
        } else if (userProfile.preferredAgeGroup.toLowerCase() == 'any') {
          score += 1 * basicInfoWeight;
        }
      }

      // Occupation Match
      if (userProfile.preferredOccupation.toLowerCase() == otherProfile.occupation.toLowerCase() && userProfile.preferredOccupation.isNotEmpty) {
        score += 1 * basicInfoWeight;
      }

      // --- Habits Comparison (more nuanced) ---
      // NO fixed maxScore for habits here. Each habit adds its max potential.

      // Smoking
      maxScore += 2 * habitsWeight; // Max score for smoking
      final userSmokes = userProfile.smokingHabit.toLowerCase();
      final otherSmokes = otherProfile.smokingHabits.toLowerCase();

      if (
      (userSmokes == 'never' && otherSmokes == 'never') ||
          (userSmokes == 'occasionally' && (otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
          (userSmokes == 'socially' && (otherSmokes == 'socially' || otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
          (userSmokes == 'regularly' && otherSmokes == 'regularly') ||
          (otherSmokes == 'tolerates' && (userSmokes == 'occasionally' || userSmokes == 'socially' || userSmokes == 'regularly'))
      ) {
        score += 2 * habitsWeight;
      }

      // Drinking
      maxScore += 2 * habitsWeight; // Max score for drinking
      final userDrinksActual = userProfile.drinkingHabit.toLowerCase();
      final otherDrinksPref = otherProfile.drinkingHabits.toLowerCase();

      if (
      (userDrinksActual == 'never' && otherDrinksPref == 'never') ||
          (userDrinksActual == 'occasionally' && (otherDrinksPref == 'occasionally' || otherDrinksPref == 'never')) ||
          (userDrinksActual == 'socially' && (otherDrinksPref == 'socially' || otherDrinksPref == 'occasionally' || otherDrinksPref == 'never')) ||
          (userDrinksActual == 'regularly' && otherDrinksPref == 'regularly') ||
          (otherDrinksPref == 'tolerates' && (userDrinksActual == 'occasionally' || userDrinksActual == 'socially' || userDrinksActual == 'regularly'))
      ) {
        score += 2 * habitsWeight;
      }

      // Food Preference
      maxScore += 1 * habitsWeight; // Max score for food preference
      final userFood = userProfile.foodPreference.toLowerCase();
      final otherFood = otherProfile.foodPreference.toLowerCase();

      if (userFood == otherFood) {
        score += 1 * habitsWeight;
      } else if (
      (userFood == 'vegan' && (otherFood == 'vegetarian' || otherFood == 'eggetarian' || otherFood == 'jain')) ||
          (otherFood == 'vegan' && (userFood == 'vegetarian' || userFood == 'eggetarian' || userFood == 'jain'))
      ) {
        score += 0.75 * habitsWeight;
      } else if (
      (userFood == 'vegetarian' && (otherFood == 'eggetarian' || otherFood == 'jain')) ||
          (otherFood == 'vegetarian' && (userFood == 'eggetarian' || userFood == 'jain'))
      ) {
        score += 0.75 * habitsWeight;
      } else if (
      (userFood == 'eggetarian' && (otherFood == 'vegetarian' || otherFood == 'jain')) ||
          (otherFood == 'eggetarian' && (userFood == 'vegetarian' || userFood == 'jain'))
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userFood == 'jain' && (otherFood == 'vegetarian' || otherFood == 'vegan' || otherFood == 'eggetarian')) ||
          (otherFood == 'jain' && (userFood == 'vegetarian' || userFood == 'vegan' || userFood == 'eggetarian'))
      ) {
        score += 0.75 * habitsWeight;
      } else if ((userFood == 'other' || otherFood == 'other')) {
        score += 0.2 * habitsWeight;
      }

      // Cleanliness
      maxScore += 2 * habitsWeight; // Max score for cleanliness
      final userCleanliness = userProfile.cleanlinessLevel.toLowerCase();
      final otherCleanliness = otherProfile.cleanliness.toLowerCase();

      if (userCleanliness == otherCleanliness) {
        score += 2 * habitsWeight;
      } else if (
      (userCleanliness == 'very tidy' && otherCleanliness == 'moderately tidy') ||
          (otherCleanliness == 'very tidy' && userCleanliness == 'moderately tidy')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userCleanliness == 'moderately tidy' && otherCleanliness == 'flexible') ||
          (otherCleanliness == 'moderately tidy' && userCleanliness == 'flexible')
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userCleanliness == 'flexible' && otherCleanliness == 'can be messy at times') ||
          (otherCleanliness == 'flexible' && userCleanliness == 'can be messy at times')
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userCleanliness == 'very tidy' && (otherCleanliness == 'flexible' || otherCleanliness == 'can be messy at times')) ||
          (otherCleanliness == 'very tidy' && (userCleanliness == 'flexible' || userCleanliness == 'can be messy at times'))
      ) {
        score += 0.2 * habitsWeight;
      }

      // Noise Level
      maxScore += 2 * habitsWeight; // Max score for noise level
      final userNoise = userProfile.noiseLevel.toLowerCase();
      final otherNoise = otherProfile.noiseLevel.toLowerCase();

      if (userNoise == otherNoise) {
        score += 2 * habitsWeight;
      } else if (
      (userNoise == 'very quiet' && otherNoise == 'moderate noise') ||
          (otherNoise == 'very quiet' && userNoise == 'moderate noise')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userNoise == 'moderate noise' && (otherNoise == 'very quiet' || otherNoise == 'lively')) ||
          (otherNoise == 'moderate noise' && (userNoise == 'very quiet' || userNoise == 'lively'))
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userNoise == 'flexible' && (otherNoise == 'very quiet' || otherNoise == 'moderate noise' || otherNoise == 'lively')) ||
          (otherNoise == 'flexible' && (userNoise == 'very quiet' || userNoise == 'moderate noise' || userNoise == 'lively'))
      ) {
        score += 1.8 * habitsWeight;
      } else if (
      (userNoise == 'lively' && otherNoise == 'very quiet') ||
          (otherNoise == 'lively' && userNoise == 'very quiet')
      ) {
        // These are generally a bad match unless one is flexible. Score 0 here.
      }

      // Social Habits
      maxScore += 1 * habitsWeight; // Max score for social habits
      final userSocial = userProfile.socialPreferences.toLowerCase();
      final otherSocial = otherProfile.socialHabits.toLowerCase();

      if (userSocial == otherSocial) {
        score += 1 * habitsWeight;
      } else if (
      (userSocial == 'flexible' && (otherSocial == 'social & outgoing' || otherSocial == 'occasional gatherings' || otherSocial == 'quiet & private')) ||
          (otherSocial == 'flexible' && (userSocial == 'social & outgoing' || userSocial == 'occasional gatherings' || userSocial == 'quiet & private'))
      ) {
        score += 0.9 * habitsWeight;
      } else if (
      (userSocial == 'social & outgoing' && otherSocial == 'occasional gatherings') ||
          (otherSocial == 'social & outgoing' && userSocial == 'occasional gatherings')
      ) {
        score += 0.7 * habitsWeight;
      } else if (
      (userSocial == 'occasional gatherings' && otherSocial == 'quiet & private') ||
          (otherSocial == 'occasional gatherings' && userSocial == 'quiet & private')
      ) {
        score += 0.6 * habitsWeight;
      } else if (
      (userSocial == 'social & outgoing' && otherSocial == 'quiet & private') ||
          (otherSocial == 'social & outgoing' && userSocial == 'quiet & private')
      ) {
        score += 0.2 * habitsWeight;
      }

      // Pet Ownership/Tolerance
      maxScore += 2 * habitsWeight; // Max score for pet ownership/tolerance
      final userOwns = userProfile.petOwnership.toLowerCase();
      final otherOwns = otherProfile.petOwnership.toLowerCase();
      final userTolerates = (userProfile.petTolerance ?? '').toLowerCase();
      final otherTolerates = (otherProfile.petTolerance ?? '').toLowerCase();

      double currentPetScore = 0;
      if (userOwns == 'no' && otherOwns == 'no') {
        currentPetScore = 2.0 * habitsWeight;
      } else if (userOwns == 'yes' && otherOwns == 'yes') {
        currentPetScore = 2.0 * habitsWeight;
      } else if ((userOwns == 'yes' && otherTolerates == 'tolerates pets') || (otherOwns == 'yes' && userTolerates == 'tolerates pets')) {
        currentPetScore = 2.0 * habitsWeight;
      } else if (userOwns == 'planning to get one' && otherOwns == 'planning to get one') {
        currentPetScore = 1.8 * habitsWeight;
      } else if ((userOwns == 'yes' && otherOwns == 'planning to get one') || (otherOwns == 'yes' && userOwns == 'planning to get one')) {
        currentPetScore = 1.5 * habitsWeight;
      } else if ((userOwns == 'no' && otherOwns == 'planning to get one' && userTolerates == 'tolerates pets') || (otherOwns == 'no' && userOwns == 'planning to get one' && otherTolerates == 'tolerates pets')) {
        currentPetScore = 1.0 * habitsWeight;
      } else if ((userOwns == 'planning to get one' && otherTolerates == 'tolerates pets') || (otherOwns == 'planning to get one' && userTolerates == 'tolerates pets')) {
        currentPetScore = 1.0 * habitsWeight;
      }
      score += currentPetScore;

      // Visitors Policy
      maxScore += 2 * habitsWeight; // Max score for visitors policy
      final userVisitors = userProfile.visitorsPolicy.toLowerCase();
      final otherVisitors = otherProfile.visitorsPolicy.toLowerCase();

      if (userVisitors == otherVisitors) {
        score += 2 * habitsWeight;
      } else if (
      (userVisitors == 'frequent visitors' && otherVisitors == 'occasional visitors') ||
          (otherVisitors == 'frequent visitors' && userVisitors == 'occasional visitors')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userVisitors == 'occasional visitors' && otherVisitors == 'rarely have visitors') ||
          (otherVisitors == 'occasional visitors' && userVisitors == 'rarely have visitors')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userVisitors == 'rarely have visitors' && otherVisitors == 'no visitors') ||
          (otherVisitors == 'rarely have visitors' && userVisitors == 'no visitors')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userVisitors == 'occasional visitors' && otherVisitors == 'no visitors') ||
          (otherVisitors == 'occasional visitors' && userVisitors == 'no visitors')
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userVisitors == 'frequent visitors' && otherVisitors == 'rarely have visitors') ||
          (otherVisitors == 'frequent visitors' && userVisitors == 'rarely have visitors')
      ) {
        score += 0.2 * habitsWeight;
      } else if (
      (userVisitors == 'frequent visitors' && otherVisitors == 'no visitors') ||
          (otherVisitors == 'frequent visitors' && userVisitors == 'no visitors')
      ) {
        // strong mismatch, 0 points
      }

      // Sleeping Schedule
      maxScore += 2 * habitsWeight; // Max score for sleeping schedule
      final userSchedule = userProfile.sleepingSchedule.toLowerCase();
      final otherSchedule = otherProfile.sleepingSchedule.toLowerCase();

      if (userSchedule == otherSchedule) {
        score += 2 * habitsWeight;
      } else if (
      (userSchedule == 'flexible' && (otherSchedule == 'early riser' || otherSchedule == 'night owl')) ||
          (otherSchedule == 'flexible' && (userSchedule == 'early riser' || userSchedule == 'night owl'))
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userSchedule == 'flexible' && otherSchedule == 'irregular') ||
          (otherSchedule == 'flexible' && userSchedule == 'irregular')
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userSchedule == 'early riser' && otherSchedule == 'irregular') ||
          (otherSchedule == 'early riser' && userSchedule == 'irregular')
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userSchedule == 'night owl' && otherSchedule == 'irregular') ||
          (otherSchedule == 'night owl' && userSchedule == 'irregular')
      ) {
        score += 0.5 * habitsWeight;
      }

      // Work/Study Schedule
      maxScore += 2 * habitsWeight; // Max score for work/study schedule
      final userWork = userProfile.workSchedule.toLowerCase();
      final otherWork = otherProfile.workSchedule.toLowerCase();

      if (userWork == otherWork) {
        score += 2 * habitsWeight;
      } else if (
      (userWork == 'mixed' && (otherWork == 'freelance/flexible hours' || otherWork == '9-5 office hours' || otherWork == 'student schedule' || otherWork == 'night shifts')) ||
          (otherWork == 'mixed' && (userWork == 'freelance/flexible hours' || userWork == '9-5 office hours' || userWork == 'student schedule' || userWork == 'night shifts')) ||
          (userWork == 'freelance/flexible hours' && (otherWork == '9-5 office hours' || otherWork == 'student schedule')) ||
          (otherWork == 'freelance/flexible hours' && (userWork == '9-5 office hours' || userWork == 'student schedule'))
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userWork == '9-5 office hours' && otherWork == 'student schedule') ||
          (otherWork == '9-5 office hours' && userWork == 'student schedule')
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userWork == 'freelance/flexible hours' && otherWork == 'night shifts') ||
          (otherWork == 'freelance/flexible hours' && userWork == 'night shifts')
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userWork == 'night shifts' && otherWork == 'student schedule') ||
          (otherWork == 'night shifts' && userWork == 'student schedule')
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userWork == '9-5 office hours' && otherWork == 'night shifts') ||
          (otherWork == '9-5 office hours' && userWork == 'night shifts')
      ) {
        score += 0.2 * habitsWeight;
      }

      // Sharing Habits (assuming property is `sharingCommonSpaces`)
      maxScore += 2 * habitsWeight; // Max score for sharing habits
      final userSharing = userProfile.sharingCommonSpaces.toLowerCase();
      final otherSharing = otherProfile.sharingCommonSpaces.toLowerCase();

      if (userSharing == otherSharing) {
        score += 2 * habitsWeight;
      } else if (
      (userSharing == 'flexible' && (otherSharing == 'share everything' || otherSharing == 'share some items' || otherSharing == 'prefer separate items')) ||
          (otherSharing == 'flexible' && (userSharing == 'share everything' || userSharing == 'share some items' || userSharing == 'prefer separate items'))
      ) {
        score += 1.8 * habitsWeight;
      } else if (
      (userSharing == 'share everything' && otherSharing == 'share some items') ||
          (otherSharing == 'share everything' && userSharing == 'share some items')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userSharing == 'share some items' && otherSharing == 'prefer separate items') ||
          (otherSharing == 'share some items' && userSharing == 'prefer separate items')
      ) {
        score += 1.0 * habitsWeight;
      } else if (
      (userSharing == 'share everything' && otherSharing == 'prefer separate items') ||
          (otherSharing == 'share everything' && userSharing == 'prefer separate items')
      ) {
        score += 0.5 * habitsWeight;
      }

      // Guests Overnight Policy
      maxScore += 2 * habitsWeight; // Max score for guests overnight policy
      final userGuests = userProfile.guestsOvernightPolicy.toLowerCase();
      final otherGuests = otherProfile.guestsOvernightPolicy.toLowerCase();

      if (userGuests == otherGuests) {
        score += 2 * habitsWeight;
      } else if (
      (userGuests == 'frequently' && otherGuests == 'occasionally') ||
          (otherGuests == 'frequently' && userGuests == 'occasionally')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userGuests == 'occasionally' && otherGuests == 'rarely') ||
          (otherGuests == 'occasionally' && userGuests == 'rarely')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userGuests == 'rarely' && otherGuests == 'never') ||
          (otherGuests == 'rarely' && userGuests == 'never')
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userGuests == 'occasionally' && otherGuests == 'never') ||
          (otherGuests == 'occasionally' && userGuests == 'never')
      ) {
        score += 0.5 * habitsWeight;
      } else if (
      (userGuests == 'frequently' && otherGuests == 'rarely') ||
          (otherGuests == 'frequently' && userGuests == 'rarely')
      ) {
        score += 0.2 * habitsWeight;
      } else if (
      (userGuests == 'frequently' && otherGuests == 'never') ||
          (otherGuests == 'frequently' && userGuests == 'never')
      ) {
        // strong mismatch, 0 points
      }

      // Personal Space vs. Socialization
      maxScore += 2 * habitsWeight; // Max score for personal space vs. socialization
      final userSpaceSocial = userProfile.personalSpaceVsSocialization.toLowerCase();
      final otherSpaceSocial = otherProfile.personalSpaceVsSocialization.toLowerCase();

      if (userSpaceSocial == otherSpaceSocial) {
        score += 2 * habitsWeight;
      } else if (
      (userSpaceSocial == 'flexible' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'enjoy a balance' || otherSpaceSocial == 'prefer more socialization')) ||
          (otherSpaceSocial == 'flexible' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'enjoy a balance' || userSpaceSocial == 'prefer more socialization'))
      ) {
        score += 1.8 * habitsWeight;
      } else if (
      (userSpaceSocial == 'enjoy a balance' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'prefer more socialization')) ||
          (otherSpaceSocial == 'enjoy a balance' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'prefer more socialization'))
      ) {
        score += 1.5 * habitsWeight;
      } else if (
      (userSpaceSocial == 'value personal space highly' && otherSpaceSocial == 'prefer more socialization') ||
          (otherSpaceSocial == 'value personal space highly' && userSpaceSocial == 'prefer more socialization')
      ) {
        score += 0.2 * habitsWeight;
      }

      // --- Requirements/Preferences Comparison (from flat lister's perspective) ---
      // NO fixed maxScore for requirements here. Each requirement adds its max potential.

      // Preferred Flatmate Gender
      maxScore += 1 * requirementsPreferencesWeight; // Max score for preferred gender
      if (userProfile.preferredGender.toLowerCase() == otherProfile.gender.toLowerCase() || userProfile.preferredGender.toLowerCase() == 'any') {
        score += 1 * requirementsPreferencesWeight;
      }

      // Preferred Habits (overlap with other user's actual habits)
      maxScore += 2 * requirementsPreferencesWeight; // Max score for preferred habits
      final preferredHabitsIntersection = userProfile.preferredHabits.toSet().intersection([
        otherProfile.smokingHabits, // Note: seeking flatmate has 'smokingHabits', lister has 'smokingHabit'
        otherProfile.drinkingHabits, // Note: seeking flatmate has 'drinkingHabits', lister has 'drinkingHabit'
        otherProfile.foodPreference,
        otherProfile.cleanliness,
        otherProfile.noiseLevel,
        otherProfile.socialHabits,
        otherProfile.guestsFrequency, // This variable name might be different from guestsOvernightPolicy
        otherProfile.visitorsPolicy,
        otherProfile.petOwnership,
        otherProfile.petTolerance,
        otherProfile.sleepingSchedule,
        otherProfile.workSchedule,
        otherProfile.sharingCommonSpaces,
        otherProfile.guestsOvernightPolicy,
        otherProfile.personalSpaceVsSocialization,
      ].map((e) => e.toLowerCase()).toSet());
      score += (preferredHabitsIntersection.length / (userProfile.preferredHabits.length > 0 ? userProfile.preferredHabits.length : 1)) * 2 * requirementsPreferencesWeight;

      // Ideal Qualities (overlap)
      maxScore += 2 * requirementsPreferencesWeight; // Max score for ideal qualities
      final idealQualitiesIntersection = userProfile.flatmateIdealQualities.toSet().intersection(otherProfile.idealQualities.toSet());
      score += (idealQualitiesIntersection.length / (userProfile.flatmateIdealQualities.length > 0 ? userProfile.flatmateIdealQualities.length : 1)) * 2 * requirementsPreferencesWeight;

      // Deal Breakers (penalty for overlap) - No maxScore addition as it's a penalty
      final dealBreakersIntersection = userProfile.flatmateDealBreakers.toSet().intersection(otherProfile.dealBreakers.toSet());
      score -= (dealBreakersIntersection.length * 5) * requirementsPreferencesWeight; // Penalize heavily

    } else {
      return 0.0; // Mismatch in profile types or unexpected scenario
    }

    // Ensure score doesn't go below zero
    if (score < 0) score = 0;

    // Calculate percentage, ensuring maxScore is not zero to avoid division by zero
    double percentage = (maxScore > 0) ? (score / maxScore) * 100 : 0.0;
    return percentage.clamp(0.0, 100.0); // Ensure it's between 0 and 100
  }
  // This variable needs to be defined here so the Positioned widget can access it.


  // This variable needs to be defined here so the Positioned widget can access it.

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900; // Define your breakpoint for "large screen"

    final dynamic currentProfile = _profiles.isNotEmpty
        ? _profiles[_currentIndex]
        : null;

    final double matchPercentage = (currentProfile != null && _currentUserParsedProfile != null)
        ? _calculateMatchPercentage(_currentUserParsedProfile, currentProfile)
        : 0.0;

    // Correctly declare appBar as PreferredSizeWidget
    final PreferredSizeWidget appBar = AppBar(
      title: const Text('Matching Profiles', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.redAccent,
      elevation: 0,
      centerTitle: true,
      actions: [
        if (!isLargeScreen) // Only show filter button on smaller screens
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list, color: Colors.white, size: 28),
                if (_currentFilters.hasFilters())
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            onPressed: _navigateToFilterScreen,
          ),
      ],
    );

    Widget mainContent;

    if (_isLoading) {
      mainContent = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 20),
            Text('Loading profiles...', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    } else if (_profiles.isEmpty) {
      mainContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/no_profiles.png',
              height: 150,
              width: 150,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 30),
            const Text(
              'Oops! No matching profiles found yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            const Text(
              'Try broadening your search preferences or come back later. More matches are on their way!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                if (isLargeScreen) {
                  // On large screen, the FilterScreen is already present.
                  // Just trigger a re-fetch to reflect potential changes if user
                  // manually cleared filters on the FilterScreen itself.
                  _fetchUserProfile(applyFilters: true);
                } else {
                  _navigateToFilterScreen(); // Allow user to adjust filters
                }
              },
              icon: const Icon(Icons.filter_list, color: Colors.white),
              label: const Text('Adjust Filters', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            if (_currentFilters.hasFilters())
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentFilters.clear(); // Clear filters
                  });
                  _fetchUserProfile(applyFilters: true); // Re-fetch without filters
                },
                child: const Text('Clear All Filters', style: TextStyle(color: Colors.redAccent)),
              ),
          ],
        ),
      );
    } else {
      mainContent = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
        Expanded(
        child: Dismissible(
        key: ValueKey(_profiles[_currentIndex].documentId),
        direction: DismissDirection.horizontal,
        onDismissed: _handleProfileDismissed,
        background: Container(
          color: Colors.green.withOpacity(0.7),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 30.0),
          child: const Row(
            children: [
              Icon(Icons.favorite, color: Colors.white, size: 50),
              SizedBox(width: 10),
              Text('LIKE', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red.withOpacity(0.7),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 30.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('PASS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(width: 10),
              Icon(Icons.close, color: Colors.white, size: 50),
            ],
          ),
        ),

        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: (_profiles[_currentIndex] is FlatListingProfile && (_profiles[_currentIndex] as FlatListingProfile).imageUrls != null && (_profiles[_currentIndex] as FlatListingProfile).imageUrls!.isNotEmpty)
                                ? (_profiles[_currentIndex] as FlatListingProfile).imageUrls!.length
                                : (_profiles[_currentIndex] is SeekingFlatmateProfile && (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls != null && (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls!.isNotEmpty)
                                ? (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls!.length
                                : 1,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              String? imageUrl;
                              if (_profiles[_currentIndex] is FlatListingProfile) {
                                final profile = _profiles[_currentIndex] as FlatListingProfile;
                                if (profile.imageUrls != null && index < profile.imageUrls!.length) {
                                  imageUrl = profile.imageUrls![index];
                                }
                              } else if (_profiles[_currentIndex] is SeekingFlatmateProfile) {
                                final profile = _profiles[_currentIndex] as SeekingFlatmateProfile;
                                if (profile.imageUrls != null && index < profile.imageUrls!.length) {
                                  imageUrl = profile.imageUrls![index];
                                }
                              }

                              return imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: Colors.redAccent,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                                  : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.person_outline,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              (_profiles[_currentIndex] is FlatListingProfile && (_profiles[_currentIndex] as FlatListingProfile).imageUrls != null && (_profiles[_currentIndex] as FlatListingProfile).imageUrls!.isNotEmpty)
                                  ? (_profiles[_currentIndex] as FlatListingProfile).imageUrls!.length
                                  : (_profiles[_currentIndex] is SeekingFlatmateProfile && (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls != null && (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls!.isNotEmpty)
                                  ? (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls!.length
                                  : 1,
                                  (index) => Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                              ),
                            ),
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profiles[_currentIndex] is FlatListingProfile
                                      ? (_profiles[_currentIndex] as FlatListingProfile).ownerName
                                      : (_profiles[_currentIndex] as SeekingFlatmateProfile).name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _profiles[_currentIndex] is FlatListingProfile
                                      ? '${(_profiles[_currentIndex] as FlatListingProfile).ownerAge ?? 'N/A'} • ${(_profiles[_currentIndex] as FlatListingProfile).ownerGender}'
                                      : '${(_profiles[_currentIndex] as SeekingFlatmateProfile).age ?? 'N/A'} • ${(_profiles[_currentIndex] as SeekingFlatmateProfile).gender}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_currentUserParsedProfile != null
                        )
                          Positioned(
                            top: 15,
                            right: 15,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.redAccent, Colors.red],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: matchPercentage.toDouble()),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Text(
                                    '${value.toInt()}% Match',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildProfileContent(_profiles[_currentIndex]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    const SizedBox(height: 30),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
    _buildActionButton(
    icon: Icons.close,
    label: 'Pass',
    color: Colors.red,
    onPressed: () {
    if (_profiles.isNotEmpty) {
    _handleProfileDismissed(DismissDirection.endToStart);
    }
    },
    ),
    _buildActionButton(
    icon: Icons.favorite,
    label: 'Connect',
    color: Colors.green,
    onPressed: () {
    if (_profiles.isNotEmpty) {
    _handleProfileDismissed(DismissDirection.startToEnd);
    }
    },
    ),
    ],
    ),

    ],
    ),
    );
    }

    if (isLargeScreen) {
    return Scaffold(
    appBar: appBar,
    body: Row(
    children: [
    SizedBox(
    width: 350, // Fixed width for the filter panel
    child: FilterScreen(
    initialFilters: _currentFilters.copyWith(),
    isSeekingFlatmate: _userProfileType == 'seeking_flatmate',
    onFiltersChanged: (newFilters) {
    setState(() {
    _currentFilters = newFilters;
    });
    _fetchUserProfile(applyFilters: true);
    },
    ),
    ),
    const VerticalDivider(width: 1, thickness: 1),
    Expanded(
    child: mainContent,
    ),
    ],
    ),
    );
    } else {
    // For smaller screens, keep the existing layout
    return Scaffold(
    appBar: appBar,
    body: mainContent,
    );
    }
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 28),
          label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 5,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(dynamic profile) {
    if (profile is FlatListingProfile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard('About Me', profile.ownerBio, Icons.info_outline),
          _buildCompactInfoRow(
            Icons.work, 'Occupation', profile.ownerOccupation,
            Icons.location_city, 'Desired City', profile.desiredCity,
          ),
          _buildCompactInfoRow(
            Icons.place, 'Area Preference', profile.areaPreference,
            Icons.event_available, 'Available For', profile.availableFor,
          ),

          _buildExpansionSection(
            title: 'Flat Details',
            icon: Icons.home,
            children: [
              _buildCompactInfoRow(
                Icons.home, 'Flat Type', profile.flatType,
                Icons.chair, 'Furnished Status', profile.furnishedStatus,
              ),
              _buildCompactInfoRow(
                Icons.date_range, 'Availability Date', profile.availabilityDate != null ? DateFormat('dd/MM/yyyy').format(profile.availabilityDate!) : 'N/A',
                Icons.attach_money, 'Rent Price', profile.rentPrice != null ? NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(profile.rentPrice!) : 'N/A',
              ),
              _buildCompactInfoRow(
                Icons.account_balance_wallet, 'Deposit Amount', profile.depositAmount?.toString() ?? 'N/A',
                Icons.bathtub, 'Bathroom Type', profile.bathroomType,
              ),
              _buildCompactInfoRow(
                Icons.deck, 'Balcony', profile.balconyAvailability,
                Icons.directions_car, 'Parking', profile.parkingAvailability,
              ),
              _buildChipList('Amenities', profile.amenities, Icons.kitchen),
              _buildDetailCard('Address', profile.address, Icons.location_on),
              _buildProfileDetailRow(Icons.place_outlined, 'Landmark', profile.landmark),
              _buildDetailCard('Flat Description', profile.flatDescription, Icons.description),
            ],
          ),

          _buildExpansionSection(
            title: 'Habits',
            icon: Icons.self_improvement,
            children: [
              _buildCompactInfoRow(
                Icons.smoke_free, 'Smoking', profile.smokingHabit,
                Icons.local_bar, 'Drinking', profile.drinkingHabit,
              ),
              _buildCompactInfoRow(
                Icons.fastfood, 'Food', profile.foodPreference,
                Icons.cleaning_services, 'Cleanliness', profile.cleanlinessLevel,
              ),
              _buildCompactInfoRow(
                Icons.volume_up, 'Noise', profile.noiseLevel,
                Icons.people, 'Social', profile.socialPreferences,
              ),
              _buildCompactInfoRow(
                Icons.group, 'Visitors Policy', profile.visitorsPolicy,
                Icons.pets, 'Pet Ownership', profile.petOwnership,
              ),
              _buildCompactInfoRow(
                Icons.sentiment_satisfied_alt, 'Pet Tolerance', profile.petTolerance,
                Icons.bedtime, 'Sleeping', profile.sleepingSchedule,
              ),
              _buildCompactInfoRow(
                Icons.calendar_today, 'Work', profile.workSchedule,
                Icons.all_inclusive, 'Common Spaces', profile.sharingCommonSpaces,
              ),
              _buildCompactInfoRow(
                Icons.hotel, 'Guests Overnight', profile.guestsOvernightPolicy,
                Icons.person_outline, 'Personal Space', profile.personalSpaceVsSocialization,
              ),
            ],
          ),

          _buildExpansionSection(
            title: 'Flatmate Preferences',
            icon: Icons.favorite_border,
            children: [
              _buildCompactInfoRow(
                Icons.people_alt, 'Gender', profile.preferredGender,
                Icons.accessibility, 'Age Group', profile.preferredAgeGroup,
              ),
              _buildProfileDetailRow(Icons.work_outline, 'Occupation', profile.preferredOccupation),
              _buildChipList('Preferred Habits', profile.preferredHabits, Icons.lightbulb_outline),
              _buildChipList('Ideal Qualities', profile.flatmateIdealQualities, Icons.check_circle_outline),
              _buildChipList('Deal Breakers', profile.flatmateDealBreakers, Icons.cancel_outlined),
            ],
          ),
        ],
      );
    } else if (profile is SeekingFlatmateProfile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard('About Me', profile.bio, Icons.info_outline),
          _buildCompactInfoRow(
            Icons.work, 'Occupation', profile.occupation,
            Icons.location_city, 'Desired City', profile.desiredCity,
          ),
          _buildCompactInfoRow(
            Icons.place, 'Area Preference', profile.areaPreference,
            Icons.calendar_today, 'Move-in Date', profile.moveInDate != null ? DateFormat('dd/MM/yyyy').format(profile.moveInDate!) : 'N/A',
          ),
          _buildProfileDetailRow(
            Icons.money,
            'Budget Range',
            '₹${profile.budgetMin != null ? NumberFormat('#,##,###', 'en_IN').format(profile.budgetMin!) : 'N/A'} - ₹${profile.budgetMax != null ? NumberFormat('#,##,###', 'en_IN').format(profile.budgetMax!) : 'N/A'}',
          ),

          _buildExpansionSection(
            title: 'Habits',
            icon: Icons.self_improvement,
            children: [
              _buildCompactInfoRow(
                Icons.cleaning_services, 'Cleanliness', profile.cleanliness,
                Icons.people, 'Social Habits', profile.socialHabits,
              ),
              _buildCompactInfoRow(
                Icons.calendar_today, 'Work Schedule', profile.workSchedule,
                Icons.volume_up, 'Noise Level', profile.noiseLevel,
              ),
              _buildCompactInfoRow(
                Icons.smoke_free, 'Smoking Habits', profile.smokingHabits,
                Icons.local_bar, 'Drinking Habits', profile.drinkingHabits,
              ),
              _buildCompactInfoRow(
                Icons.fastfood, 'Food Preference', profile.foodPreference,
                Icons.group, 'Guests Frequency', profile.guestsFrequency,
              ),
              _buildCompactInfoRow(
                Icons.hotel, 'Guests Overnight', profile.guestsOvernightPolicy,
                Icons.pets, 'Pet Ownership', profile.petOwnership,
              ),
              _buildCompactInfoRow(
                Icons.sentiment_satisfied_alt, 'Pet Tolerance', profile.petTolerance,
                Icons.bedtime, 'Sleeping Schedule', profile.sleepingSchedule,
              ),
              _buildCompactInfoRow(
                Icons.all_inclusive, 'Common Spaces', profile.sharingCommonSpaces,
                Icons.person_outline, 'Personal Space', profile.personalSpaceVsSocialization,
              ),
            ],
          ),

          _buildExpansionSection(
            title: 'Flat Requirements',
            icon: Icons.apartment,
            children: [
              _buildCompactInfoRow(
                Icons.home, 'Preferred Flat Type', profile.preferredFlatType,
                Icons.chair, 'Furnished Status', profile.preferredFurnishedStatus,
              ),
              _buildChipList('Amenities Desired', profile.amenitiesDesired, Icons.kitchen),
            ],
          ),

          _buildExpansionSection(
            title: 'Flatmate Preferences',
            icon: Icons.favorite_border,
            children: [
              _buildCompactInfoRow(
                Icons.people_alt, 'Gender', profile.preferredFlatmateGender,
                Icons.accessibility, 'Age', profile.preferredFlatmateAge,
              ),
              _buildProfileDetailRow(Icons.work_outline, 'Occupation', profile.preferredOccupation),
              _buildChipList('Preferred Habits', profile.preferredHabits, Icons.lightbulb_outline),
              _buildChipList('Ideal Qualities', profile.idealQualities, Icons.check_circle_outline),
              _buildChipList('Deal Breakers', profile.dealBreakers, Icons.cancel_outlined),
            ],
          ),
        ],
      );
    }
    return const Text('Error: Unknown Profile Type or Missing Data');
  }

  Widget _buildProfileHeader(String name, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    if (value == '' || value == 'N/A' || value == '0') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.redAccent, size: 22),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoRow(
      IconData icon1, String label1, String value1,
      IconData icon2, String label2, String value2,
      ) {
    bool show1 = !(value1 == '' || value1 == 'N/A' || value1 == '0');
    bool show2 = !(value2 == '' || value2 == 'N/A' || value2 == '0');

    if (!show1 && !show2) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (show1)
            Expanded(
              child: Row(
                children: [
                  Icon(icon1, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$label1: ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          ),
                          TextSpan(
                            text: value1,
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                        ],
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          if (show1 && show2) const SizedBox(width: 16),
          if (show2)
            Expanded(
              child: Row(
                children: [
                  Icon(icon2, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$label2: ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          ),
                          TextSpan(
                            text: value2,
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                        ],
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String content, IconData icon) {
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.redAccent, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              content,
              style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipList(String title, List<String> items, IconData icon) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.redAccent, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: items.map((item) {
              return Chip(
                label: Text(item),
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                labelStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.redAccent, width: 0.8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionSection({required String title, required IconData icon, required List<Widget> children}) {
    final visibleChildren = children.where((widget) => !(widget is SizedBox && widget.width == 0 && widget.height == 0)).toList();

    if (visibleChildren.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: Icon(icon, color: Colors.redAccent, size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16.0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: visibleChildren,
      ),
    );
  }
}