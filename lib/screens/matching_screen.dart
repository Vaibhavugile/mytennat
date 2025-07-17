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
import 'package:mytennat/screens/view_profile_screen.dart'; // Import ViewProfileScreen
import 'package:mytennat/screens/banner_popup_screen.dart'; // NEW: Import the banner popup screen
import 'package:mytennat/screens/PlansScreen.dart';
import 'package:mytennat/screens/ad_page.dart'; // NEW: Import the AdPage

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
  bool _isBannerPopupShowing = false; // NEW: Flag to prevent multiple popups
  // Data for banner and liked/liked by me logic
  // Key: current user's active profile ID, Value: List of profiles that liked it
  final Map<String, List<dynamic>> _incomingLikes = {};
  // Key: current user's active profile ID, Value: List of profiles liked by it
  final Map<String, List<dynamic>> _outgoingLikes = {};

  String? _bannerMessage;
  String? _lastLikedProfileName; // Name of the person you just liked who didn't like back

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for Scaffold

  int _interactionCount = 0; // NEW: Counter for likes/dislikes
  int _remainingContacts = 0; // State to hold remaining contacts
  String? _currentPlanName; // State to hold current plan name
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
    super.dispose();
  }

  // Helper to get display name for a profile
  String _getProfileDisplayName(dynamic profile) {
    if (profile is FlatListingProfile) {
      return profile.ownerName ?? 'Unnamed Flat Listing';
    } else if (profile is SeekingFlatmateProfile) {
      return profile.name ?? 'Unnamed Flatmate Seeker';
    }
    return 'Unknown Profile';
  }

  // Helper to get display type for a profile
  String _getProfileTypeDisplay(dynamic profile) {
    if (profile is FlatListingProfile) {
      return 'Flat Listing';
    } else if (profile is SeekingFlatmateProfile) {
      return 'Seeking Flatmate';
    }
    return 'Unknown Type';
  }

  Future<void> _fetchUserProfile({bool applyFilters = false}) async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
      _interactionCount = 0; // NEW: Reset interaction count when fetching new profiles
    });

    try {
      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          setState(() {
            _remainingContacts = userData['remainingContacts'] as int? ?? 0;
            _currentPlanName = userData['currentPlan'] as String?;
          });
        }
      }
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
          // Fetch likes after the current user's profile is loaded
          await _fetchIncomingLikes(_currentUser!.uid, widget.profileId);
          await _fetchOutgoingLikes(_currentUser!.uid, widget.profileId);
          // If current user is 'flat_listing', they are looking for 'seeking_flatmate' profiles
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
          // Fetch likes after the current user's profile is loaded
          await _fetchIncomingLikes(_currentUser!.uid, widget.profileId);
          await _fetchOutgoingLikes(_currentUser!.uid, widget.profileId);
          // If current user is 'seeking_flatmate', they are looking for 'flat_listing' profiles
          await _fetchFlatListingProfiles(applyFilters: applyFilters);
        } else {
          _showAlertDialog('Profile Not Found', 'The selected Seeking Flatmate profile could not be found.', () {
            // Navigate back to profile selection or home
          });
        }
      } else {
        _showAlertDialog('Profile Type Not Found', 'Your active profile type could not be determined from the provided data.', () {});
      }
      _checkForBanner(); // Initial check for banner after all data is loaded
    } catch (e) {
      _showAlertDialog('Error', 'Failed to fetch user profile: $e', () {});
      print('Firebase Firestore Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _currentIndex = 0; // Reset index when new profiles are fetched
        // _bannerMessage is now set by _checkForBanner()
      });
    }
  }

  Future<void> _fetchIncomingLikes(String currentUserId, String currentProfileId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collectionGroup('likes') // Query across all 'likes' subcollections
          .where('likedUserId', isEqualTo: currentUserId)
          .where('likedProfileDocumentId', isEqualTo: currentProfileId)
          .get();

      List<dynamic> likedMeProfiles = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String likingUserId = data['likingUserId'];
        final String likingUserProfileId = data['likingUserProfileId'];
        final String likingUserProfileType = data['likingUserProfileType'];

        DocumentSnapshot? profileDoc;
        if (likingUserProfileType == 'flat_listing') {
          profileDoc = await _firestore.collection('users').doc(likingUserId).collection('flatListings').doc(likingUserProfileId).get();
        } else if (likingUserProfileType == 'seeking_flatmate') {
          profileDoc = await _firestore.collection('users').doc(likingUserId).collection('seekingFlatmateProfiles').doc(likingUserProfileId).get();
        }

        if (profileDoc != null && profileDoc.exists) {
          if (likingUserProfileType == 'flat_listing') {
            likedMeProfiles.add(FlatListingProfile.fromMap(profileDoc.data() as Map<String, dynamic>, profileDoc.id));
          } else if (likingUserProfileType == 'seeking_flatmate') {
            likedMeProfiles.add(SeekingFlatmateProfile.fromMap(profileDoc.data() as Map<String, dynamic>, profileDoc.id));
          }
        }
      }
      setState(() {
        _incomingLikes[currentProfileId] = likedMeProfiles;
      });
    } catch (e) {
      print('Error fetching incoming likes: $e');
    }
  }

  Future<void> _fetchOutgoingLikes(String currentUserId, String currentProfileId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('user_likes')
          .doc(currentUserId)
          .collection('likes')
          .where('likingUserProfileId', isEqualTo: currentProfileId)
          .get();

      List<dynamic> likedByMeProfiles = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String likedUserId = data['likedUserId'];
        final String likedProfileDocumentId = data['likedProfileDocumentId'];
        final String likedUserProfileType = data['likedUserProfileType'];

        DocumentSnapshot? profileDoc;
        if (likedUserProfileType == 'flat_listing') {
          profileDoc = await _firestore.collection('users').doc(likedUserId).collection('flatListings').doc(likedProfileDocumentId).get();
        } else if (likedUserProfileType == 'seeking_flatmate') {
          profileDoc = await _firestore.collection('users').doc(likedUserId).collection('seekingFlatmateProfiles').doc(likedProfileDocumentId).get();
        }

        if (profileDoc != null && profileDoc.exists) {
          if (likedUserProfileType == 'flat_listing') {
            likedByMeProfiles.add(FlatListingProfile.fromMap(profileDoc.data() as Map<String, dynamic>, profileDoc.id));
          } else if (likedUserProfileType == 'seeking_flatmate') {
            likedByMeProfiles.add(SeekingFlatmateProfile.fromMap(profileDoc.data() as Map<String, dynamic>, profileDoc.id));
          }
        }
      }
      setState(() {
        _outgoingLikes[currentProfileId] = likedByMeProfiles;
      });
    } catch (e) {
      print('Error fetching outgoing likes: $e');
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

        if (_currentFilters.occupation != null && _currentFilters.occupation!.isNotEmpty) {
          query = query.where('ownerOccupation', isEqualTo: _currentFilters.occupation);
        }
      }

      QuerySnapshot querySnapshot = await query.get();

      List<dynamic> fetchedProfiles = querySnapshot.docs
          .map((doc) => FlatListingProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Filter out profiles already liked by or that have liked the current active profile
      _profiles = fetchedProfiles; // Assign all fetched profiles directly

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

        if (_currentFilters.occupation != null && _currentFilters.occupation!.isNotEmpty) {
          query = query.where('occupation', isEqualTo: _currentFilters.occupation);
        }
      }

      QuerySnapshot querySnapshot = await query.get();

      List<dynamic> fetchedProfiles = querySnapshot.docs
          .map((doc) => SeekingFlatmateProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Filter out profiles already liked by or that have liked the current active profile
      _profiles = fetchedProfiles; // Assign all fetched profiles directly

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

// matching_screen.dart
// matching_screen.dart

  // matching_screen.dart

  Future<void> _processLike(String likedUserId, String likedProfileDocumentId) async {
    if (_currentUser == null) {
      print("_processLike: Current user is null. Aborting like process.");
      return;
    }

    final currentUserId = _currentUser!.uid;
    final String currentUserProfileType = widget.profileType;

    print("_processLike: User $currentUserId (active profile ${widget.profileId}) attempting to like user $likedUserId's profile $likedProfileDocumentId.");

    String likedUserProfileType;
    if (currentUserProfileType == 'seeking_flatmate') {
      likedUserProfileType = 'flat_listing';
    } else if (currentUserProfileType == 'flat_listing') {
      likedUserProfileType = 'seeking_flatmate';
    } else {
      print("Warning: Unknown current user profile type: ${currentUserProfileType}. Assigning 'unknown' to likedUserProfileType.");
      likedUserProfileType = 'unknown';
    }
    print('Determined likedUserProfileType: $likedUserProfileType');


    try {
      print("_processLike (Op1): Attempting to record like for $currentUserId on $likedProfileDocumentId.");
      try {
        await _firestore.collection('user_likes').doc(currentUserId).collection('likes').doc(likedProfileDocumentId).set({
          'timestamp': FieldValue.serverTimestamp(),
          'likedUserId': likedUserId,
          'likedProfileDocumentId': likedProfileDocumentId,
          'likingUserProfileId': widget.profileId,
          'likingUserId': currentUserId,
          'likingUserProfileType': currentUserProfileType,
          'likedUserProfileType': likedUserProfileType,
        });
        print("_processLike (Op1): Successfully recorded like for $currentUserId on profile $likedProfileDocumentId.");

        // Update local outgoing likes
        setState(() {
          // Replaced firstWhere with a manual loop for robustness (previous fix)
          dynamic likedProfile;
          for (var p in _profiles) {
            if (p.documentId == likedProfileDocumentId) {
              likedProfile = p;
              break;
            }
          }

          if (likedProfile != null) {
            if (!_outgoingLikes.containsKey(widget.profileId)) {
              _outgoingLikes[widget.profileId] = [];
            }
            if (!_outgoingLikes[widget.profileId]!.any((p) => p.documentId == likedProfile.documentId)) {
              _outgoingLikes[widget.profileId]!.add(likedProfile);
            }
          } else {
            print("Warning: Liked profile with ID $likedProfileDocumentId not found in _profiles list during outgoing likes update.");
          }
        });

        // --- NEW ADDITION: Contact Reveal Logic ---
        // MODIFICATION START: Replaced firstWhere with a manual loop for robustness here too
        dynamic likedProfileObject;
        for (var profile in _profiles) {
          if (profile.documentId == likedProfileDocumentId) {
            likedProfileObject = profile;
            break;
          }
        }
        // MODIFICATION END

        if (likedProfileObject != null) {
          if (_remainingContacts > 0) {
            // Show contact reveal popup if contacts are available
            _showContactRevealPopup(likedUserId, likedProfileObject); // MODIFIED LINE
          } else {
            // Show out of contacts message or direct to plans
            _showOutOfContactsPopup();
          }
        } else {
          print("Warning: Liked profile object not found in _profiles for contact reveal.");
        }
        // --- END NEW ADDITION ---

      } catch (e) {
        print("_processLike (Op1) ERROR: Failed to SET like document: $e");
        _showAlertDialog('Error', 'Failed to record your like: ${e.toString()}', () {});
        return; // Exit if recording the like failed
      }

      print("_processLike (Op2): Checking if user $likedUserId has liked our active profile ${widget.profileId}.");
      QuerySnapshot otherUserLikesOurProfile;
      try {
        otherUserLikesOurProfile = await _firestore.collection('user_likes').doc(likedUserId).collection('likes')
            .where('likedUserId', isEqualTo: currentUserId)
            .where('likedProfileDocumentId', isEqualTo: widget.profileId)
            .get();
        print("_processLike (Op2): Other user like check completed. Exists: ${otherUserLikesOurProfile.docs.isNotEmpty}");
      } catch (e) {
        print("_processLike (Op2) ERROR: Failed to GET other user's like: $e");
        _showAlertDialog('Error', 'Failed to check for mutual like: ${e.toString()}', () {});
        return; // Exit if checking for mutual like failed
      }

      if (otherUserLikesOurProfile.docs.isNotEmpty) {
        print("_processLike: Mutual like detected! IT'S A MATCH!");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('It\'s a MATCH! 🎉'))
        );

        setState(() {
          _bannerMessage = null;
          _lastLikedProfileName = null;
        });

        try {
          await _createMatchAndChatRoom(
            currentUserId,
            widget.profileId,
            currentUserProfileType,
            likedUserId,
            likedProfileDocumentId,
            likedUserProfileType,
          );
          print("_processLike (Op3): _createMatchAndChatRoom call completed successfully.");
        } catch (e) {
          print("_processLike (Op3) ERROR: _createMatchAndChatRoom failed: $e");
          _showAlertDialog('Error', 'Failed to create match/chat: ${e.toString()}', () {});
          return; // Exit if match/chat creation failed
        }

        String chatPartnerNameForDialog = 'that user';
        try {
          // This firstWhere call should be safe as it's outside the problematic context
          final matchedProfile = _profiles.firstWhere((p) => p.documentId == likedProfileDocumentId);
          chatPartnerNameForDialog = _getProfileDisplayName(matchedProfile);
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
// New: Function to show contact reveal popup
  void _showContactRevealPopup(String likedUserId, dynamic matchedProfile) {
    String profileName = '';

    if (matchedProfile is FlatListingProfile) {
      profileName = matchedProfile.ownerName ?? 'Flat Owner';
    } else if (matchedProfile is SeekingFlatmateProfile) {
      profileName = matchedProfile.name ?? 'Flatmate Seeker';
    }
    String? imageUrl; // Get the actual image URL here
    if ( matchedProfile  is FlatListingProfile && matchedProfile .imageUrls != null && matchedProfile .imageUrls!.isNotEmpty) {
      imageUrl = matchedProfile .imageUrls!.first;
    } else if (matchedProfile  is SeekingFlatmateProfile && matchedProfile .imageUrls != null && matchedProfile .imageUrls!.isNotEmpty) {
      imageUrl = matchedProfile .imageUrls!.first;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BannerPopupScreen(
          message: 'Get Contact Details?',
          subMessage: 'You have $_remainingContacts contacts remaining.\nDo you want to reveal $profileName\'s contact information for 1 contact?',
          profileImageUrl:imageUrl, // Assuming your profile models have this property
          buttonText: 'Get Contact',
          onButtonPressed: () async {
            Navigator.of(context).pop(); // Dismiss popup
            await _revealContactAndDecrement(likedUserId, matchedProfile);
          },
        );
      },
    );
  }
  // New: Function to show out of contacts popup
  void _showOutOfContactsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BannerPopupScreen(
          message: 'Out of Contacts!',
          subMessage: 'You have no remaining contacts. Please purchase a plan to get more contacts.',
          buttonText: 'View Plans',
          onButtonPressed: () {
            Navigator.of(context).pop(); // Dismiss this popup
            Navigator.pushNamed(context, '/plans');
          },
        );
      },
    );
  }


  // New: Function to reveal contact and decrement remaining contacts
  Future<void> _revealContactAndDecrement(
      String targetUserId,
      dynamic matchedProfile,
      ) async {
    if (_currentUser == null) return;

    final String targetProfileId = matchedProfile.documentId;

    try {
      if (_remainingContacts > 0) {
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'remainingContacts': FieldValue.increment(-1),
        });
        setState(() {
          _remainingContacts--;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No remaining contacts to reveal.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final likeDocRef = _firestore
          .collection('user_likes')
          .doc(_currentUser!.uid)
          .collection('likes')
          .doc(targetProfileId);

      final docSnapshot = await likeDocRef.get();
      if (docSnapshot.exists) {
        await likeDocRef.update({
          'contactRevealed': true,
        });
      } else {
        print('Warning: Like document with ID $targetProfileId not found for marking contact revealed. This might be an issue.');
      }

      String contactNumber = '';
      String contactEmail = '';
      String profileName = '';

      if (matchedProfile is FlatListingProfile) {
        // contactNumber = matchedProfile.ownerPhoneNumber ?? 'N/A'; // Assuming this property exists
        // contactEmail = matchedProfile.ownerEmail ?? 'N/A';     // Assuming this property exists
        profileName = matchedProfile.ownerName ?? 'Flat Owner';
      } else if (matchedProfile is SeekingFlatmateProfile) {
        //contactNumber = matchedProfile.phoneNumber ?? 'N/A'; // Assuming this property exists
        //  contactEmail = matchedProfile.email ?? 'N/A';       // Assuming this property exists
        profileName = matchedProfile.name ?? 'Flatmate Seeker';
      }
      String? imageUrl; // Get the actual image URL here
      if ( matchedProfile  is FlatListingProfile && matchedProfile .imageUrls != null && matchedProfile .imageUrls!.isNotEmpty) {
        imageUrl = matchedProfile .imageUrls!.first;
      } else if (matchedProfile  is SeekingFlatmateProfile && matchedProfile .imageUrls != null && matchedProfile .imageUrls!.isNotEmpty) {
        imageUrl = matchedProfile .imageUrls!.first;
      }


      // Display contact details using BannerPopupScreen
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return BannerPopupScreen(
            message: '$profileName\'s Contact Details',
            subMessage: 'Remaining contacts: $_remainingContacts',
            profileImageUrl: imageUrl, // Assuming profile models have this
            // contactPhoneNumber: contactNumber, // Pass the revealed phone number
            buttonText: 'Close',
            onButtonPressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact revealed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error revealing contact or decrementing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reveal contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // This function checks if the banner should be displayed
  void _checkForBanner() async { // Make this function async
    setState(() {
      // Clear existing message first if you want the banner to re-evaluate entirely
      // _bannerMessage = null;
      // _lastLikedProfileName = null;

      // NEW: Only show banner if interaction count is 2 or more
      if (_interactionCount < 2 || _interactionCount % 2 != 0) {
        return; // Exit if not enough interactions or if it's an odd count
      }
    });

    final List<dynamic> currentOutgoingLikes = _outgoingLikes[widget.profileId] ?? [];
    final List<dynamic> currentIncomingLikes = _incomingLikes[widget.profileId] ?? [];

    // Find the first profile that the current user liked, but hasn't liked them back
    dynamic pendingLikedProfile;
    for (var outgoingProfile in currentOutgoingLikes) {
      final bool hasLikedMeBack = currentIncomingLikes
          .any((incomingProfile) => incomingProfile.documentId == outgoingProfile.documentId);

      if (!hasLikedMeBack) {
        // --- NEW ADDITION START ---
        // Check Firestore to see if contact was already revealed for this like
        final likeDocRef = _firestore
            .collection('user_likes')
            .doc(_currentUser!.uid) // Ensure _currentUser is not null here
            .collection('likes')
            .doc(outgoingProfile.documentId);

        try {
          final docSnapshot = await likeDocRef.get();
          if (docSnapshot.exists && docSnapshot.data() != null) {
            final data = docSnapshot.data()!;
            final bool contactRevealed = data['contactRevealed'] ?? false;
            if (contactRevealed) {
              print("Skipping banner for ${outgoingProfile.documentId} as contact was already revealed.");
              continue; // Skip this profile, move to the next one in the loop
            }
          }
        } catch (e) {
          print("Error checking contactRevealed status for ${outgoingProfile.documentId}: $e");
          // Continue anyway, maybe assume contact not revealed to be safe, or handle error
        }
        // --- NEW ADDITION END ---

        pendingLikedProfile = outgoingProfile;
        break; // Found the first eligible one, no need to check further
      }
    }

    if (pendingLikedProfile != null) {
      _showBannerPopup(pendingLikedProfile);
    }
  }

  void _moveToNextProfile() {
    setState(() {
      _currentIndex++;
      if (_currentIndex >= _profiles.length) {
        // Handle end of profiles (e.g., show a message, fetch more)
        _profiles.clear(); // Clear to prevent out of bounds access

        _interactionCount = 0; // NEW: Reset interaction count if profiles run out
      }
      // Re-evaluate banner state after moving to the next profile or if profiles end
      _checkForBanner();
    });
  }
  // NEW: Function to show the banner popup
  Future<void> _showBannerPopup(dynamic pendingLikedProfile) {
    if (_isBannerPopupShowing) {
      return Future.value();
    }

    _isBannerPopupShowing = true;
    final String profileName = _getProfileDisplayName(pendingLikedProfile);
    final String message = 'You\'ve sent a Connect to $profileName!';
    final String sub = 'Waiting for them to like you back.'; // The sub-message

    String? imageUrl; // Get the actual image URL here
    if (pendingLikedProfile is FlatListingProfile && pendingLikedProfile.imageUrls != null && pendingLikedProfile.imageUrls!.isNotEmpty) {
      imageUrl = pendingLikedProfile.imageUrls!.first;
    } else if (pendingLikedProfile is SeekingFlatmateProfile && pendingLikedProfile.imageUrls != null && pendingLikedProfile.imageUrls!.isNotEmpty) {
      imageUrl = pendingLikedProfile.imageUrls!.first;
    }
    // If imageUrl is still null, the BannerPopupScreen will show the person icon.

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BannerPopupScreen(
          message: message,
          subMessage: sub, // Pass the sub-message
          profileImageUrl: imageUrl, // Pass the image URL
          buttonText: 'OK',
          onButtonPressed: () {
            setState(() {
              _isBannerPopupShowing = false;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // --- NEW: Ad Banner Widget ---
  Widget _buildAdBanner(String title, String imageUrl) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // Handle ad banner tap, e.g., navigate to a promotional page
          print('Ad Banner Tapped: $title');
          // In a real app, you'd use url_launcher package:
          // import 'package:url_launcher/url_launcher.dart';
          // launchUrl(Uri.parse('your_ad_link_here'));
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 100, // Adjust height as needed for your ads
                errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW: Ad Panel Widget ---
  Widget _buildAdPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Advertisements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Ad Banner 1
          _buildAdBanner(
              'Ad 1: Exclusive Deals!', 'https://via.placeholder.com/300x150/FF0000/FFFFFF?text=Ad+1'),
          const SizedBox(height: 16),
          // Ad Banner 2
          _buildAdBanner(
              'Ad 2: Find Your Dream Flat!', 'https://firebasestorage.googleapis.com/v0/b/renting-wala-27d06.appspot.com/o/products%2F4444%2FIMG-20250516-WA0065.jpg?alt=media&token=edb3308a-cd11-4d39-a1a1-5026188fe1d6'),
          const SizedBox(height: 16),
          // Ad Banner 3
          _buildAdBanner(
              'Ad 3: Premium Features!', 'https://via.placeholder.com/300x150/0000FF/FFFFFF?text=Ad+3'),
          const SizedBox(height: 24),
          // Button to navigate to a dedicated Ad Page
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('View All Ads', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // This function is for creating a match document and a chat room
  Future<void> _createMatchAndChatRoom(
      String user1Uid,
      String user1ProfileId,
      String user1ProfileType,
      String user2Uid,
      String user2ProfileId,
      String user2ProfileType,
      ) async {
    // Create a unique ID for the match based on the two *profile* IDs
    // This ensures a unique match document for each profile pair.
    List<String> sortedProfileIds = [user1ProfileId, user2ProfileId]..sort();
    String matchDocId = '${sortedProfileIds[0]}_${sortedProfileIds[1]}';
    print("createMatchAndChatRoom: Attempting to check existence of match for profiles: $matchDocId");
    try {
      DocumentSnapshot matchDoc = await _firestore.collection('matches').doc(matchDocId).get();
      print("createMatchAndChatRoom: Match document existence check result: ${matchDoc.exists}");
      if (!matchDoc.exists) {
        print("createMatchAndChatRoom: Match document for profiles does not exist. Proceeding to create chat and match.");
        DocumentReference chatRef = await _firestore.collection('chats').add({
          'participants': [user1Uid, user2Uid], // Keep UIDs for general chat participants
          'participants_profile_ids': sortedProfileIds, // Store specific profile IDs that matched
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageSenderId': '',
          'lastMessageTimestamp': null,
        });
        String chatRoomId = chatRef.id;
        print("createMatchAndChatRoom: Chat room created with ID: $chatRoomId");
        // The _userProfileType print here refers to a class member, not the function parameter.
        // print("user1profiletyppe: $_userProfileType"); // This line might be using a class variable, remove if not intended for user1ProfileType param
        await _firestore.collection('matches').doc(matchDocId).set({
          'user1_uid': user1Uid,
          'user2_uid': user2Uid,
          'user1_profile_id': user1ProfileId,
          'user2_profile_id': user2ProfileId,
          'user1_profile_type': user1ProfileType, // Add this line
          'user2_profile_type': user2ProfileType, // Add this line
          'chatRoomId': chatRoomId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("createMatchAndChatRoom: Match document created successfully for profiles: $matchDocId");
      } else {
        print("createMatchAndChatRoom: Match document for profiles already exists.");
        // If match already exists, ensure chatRoomId is fetched
        String chatRoomId = (matchDoc.data() as Map<String, dynamic>)['chatRoomId'];
        print("createMatchAndChatRoom: Existing chatRoomId: $chatRoomId");
      }
    } catch (e) {
      print("createMatchAndChatRoom ERROR: $e");
      rethrow; // Re-throw the error to be caught by the caller
    }
  }


  void _showMatchDialog(String title, String message, VoidCallback onChatPressed) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
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
    if (_profiles.isEmpty || _currentIndex >= _profiles.length) {
      print("_handleProfileDismissed: No profiles to dismiss or index out of bounds.");
      return;
    }

    setState(() {
      final dismissedProfile = _profiles[_currentIndex];
      String likedOrPassedUserId = '';
      String dismissedProfileDocId = ''; // Variable to hold the document ID

      if (dismissedProfile is FlatListingProfile) {
        likedOrPassedUserId = dismissedProfile.uid!;
        dismissedProfileDocId = dismissedProfile.documentId!; // Get documentId
      } else if (dismissedProfile is SeekingFlatmateProfile) {
        likedOrPassedUserId = dismissedProfile.uid!;
        dismissedProfileDocId = dismissedProfile.documentId!; // Get documentId
      } else {
        print("Error: Unknown profile type encountered in _handleProfileDismissed");
        return;
      }
      // NEW: Increment interaction count regardless of like or dislike
      _interactionCount++;
      if (direction == DismissDirection.endToStart) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Passed'))
        );
        _moveToNextProfile(); // Move to next even if disliked
      } else if (direction == DismissDirection.startToEnd) {
        _processLike(likedOrPassedUserId, dismissedProfileDocId); // Pass both IDs
        _moveToNextProfile(); // Move to next after like process
      }
    });
  }

  double _calculateMatchPercentage(dynamic userProfile, dynamic otherProfile) {
    // Implement your matching logic here
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
      drawer: isLargeScreen ? null // No drawer on large screens, as filter is inline
          : Drawer(
        child: FilterScreen(
          initialFilters: _currentFilters.copyWith(),
          isSeekingFlatmate: _userProfileType == 'seeking_flatmate',
          onFiltersChanged: _onFiltersChanged,
        ),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _profiles.isEmpty ? Center(
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
                _fetchUserProfile(applyFilters: true);
                if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                  Navigator.of(context).pop(); // Close drawer if it was somehow closed
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
      ) : isLargeScreen ? Row(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Banner Area
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Plan: ${_currentPlanName ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                        Text('Contacts Left: $_remainingContacts', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _profiles.isNotEmpty && _currentIndex < _profiles.length // Add index check
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
                          profileType: 'flat_listing', // Pass profile type
                        )
                            : SeekingFlatmateProfileCard(
                          profile: _profiles[_currentIndex],
                          matchPercentage: _calculateMatchPercentage(_currentUserParsedProfile, _profiles[_currentIndex]),
                          imageUrls: (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls ?? [],
                          profileType: 'seeking_flatmate', // Pass profile type
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  if (_profiles.isNotEmpty && _currentIndex < _profiles.length) // Add index check for buttons
                    _buildActionButtons(
                        _profiles[_currentIndex] is FlatListingProfile
                            ? (_profiles[_currentIndex] as FlatListingProfile).uid!
                            : (_profiles[_currentIndex] as SeekingFlatmateProfile).uid!
                    ),
                ],
              ),
            ),
          ),
          // Ad Panel on the right for large screens
          SizedBox(
            width: math.min(350.0, screenWidth * 0.3), // Occupy 30% or max 350px
            child: _buildAdPanel(context), // Use the new ad panel here
          ),
        ],
      ) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _profiles.isNotEmpty && _currentIndex < _profiles.length // Add index check
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
                    profileType: 'flat_listing', // Pass profile type
                  )
                      : SeekingFlatmateProfileCard(
                    profile: _profiles[_currentIndex],
                    matchPercentage: _calculateMatchPercentage(_currentUserParsedProfile, _profiles[_currentIndex]),
                    imageUrls: (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls ?? [],
                    profileType: 'seeking_flatmate', // Pass profile type
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ),
            if (_profiles.isNotEmpty && _currentIndex < _profiles.length) // Add index check for buttons
              _buildActionButtons(
                  _profiles[_currentIndex] is FlatListingProfile
                      ? (_profiles[_currentIndex] as FlatListingProfile).uid!
                      : (_profiles[_currentIndex] as SeekingFlatmateProfile).uid!
              ),
          ],
        ),
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
  final List<String> imageUrls;
  final String profileType; // NEW PARAMETER

  const FlatListingProfileCard({
    super.key,
    required this.profile,
    required this.matchPercentage,
    required this.imageUrls,
    required this.profileType, // NEW PARAMETER
  });

  @override
  Widget build(BuildContext context) {
    // Determine actual images to display (with placeholder)
    final List<String> imagesToDisplay = (imageUrls.isNotEmpty) ? List<String>.from(imageUrls) : ['https://via.placeholder.com/400x300?text=No+Flat+Images'];

    return GestureDetector( // Wrap with GestureDetector
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewProfileScreen(
              userId: profile.uid, // Use uid for userId
              profileDocumentId: profile.documentId!, // Use documentId for profileDocumentId
            ),
          ),
        );
      },
      child: Card(
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
                                  color: currentImageLocalIndex == index ? Colors.redAccent : Colors.grey.withOpacity(0.5),
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
                          items: [profile.availabilityDate != null ? DateFormat('yyyy-MM-dd').format(profile.availabilityDate!) : null],
                          backgroundColor: Colors.teal.shade100,
                          textColor: Colors.teal.shade800,
                        ),
                      ],
                    ),
                    _buildInfoSection(
                      title: 'Location Preferences',
                      icon: Icons.location_on,
                      children: [
                        _buildChipList(
                          title: 'City:',
                          items: [profile.desiredCity],
                          backgroundColor: Colors.blue.shade100,
                          textColor: Colors.blue.shade800,
                        ),
                        _buildChipList(
                          title: 'Area:',
                          items: [profile.areaPreference],
                          backgroundColor: Colors.cyan.shade100,
                          textColor: Colors.cyan.shade800,
                        ),
                      ],
                    ),
                    _buildInfoSection(
                      title: 'Lifestyle & Habits',
                      icon: Icons.emoji_people,
                      children: [
                        _buildChipList(
                          title: 'Cleanliness:',
                          items: [profile.cleanlinessLevel],
                          backgroundColor: Colors.green.shade100,
                          textColor: Colors.green.shade800,
                        ),
                        _buildChipList(
                          title: 'Social:',
                          items: [profile.socialPreferences],
                          backgroundColor: Colors.red.shade100,
                          textColor: Colors.red.shade800,
                        ),
                        _buildChipList(
                          title: 'Smoking:',
                          items: [profile.smokingHabit],
                          backgroundColor: Colors.grey.shade100,
                          textColor: Colors.grey.shade800,
                        ),
                        _buildChipList(
                          title: 'Drinking:',
                          items: [profile.drinkingHabit],
                          backgroundColor: Colors.brown.shade100,
                          textColor: Colors.brown.shade800,
                        ),
                        _buildChipList(
                          title: 'Food:',
                          items: [profile.foodPreference],
                          backgroundColor: Colors.yellow.shade100,
                          textColor: Colors.yellow.shade800,
                        ),
                        _buildChipList(
                          title: 'Pets:',
                          items: [profile.petOwnership],
                          backgroundColor: Colors.orange.shade100,
                          textColor: Colors.orange.shade800,
                        ),
                        _buildChipList(
                          title: 'Pet Tolerance:',
                          items: [profile.petTolerance],
                          backgroundColor: Colors.deepOrange.shade100,
                          textColor: Colors.deepOrange.shade800,
                        ),
                      ],
                    ),
                    _buildInfoSection(
                      title: 'About Owner',
                      icon: Icons.person,
                      children: [
                        _buildChipList(
                          title: 'Occupation:',
                          items: [profile.ownerOccupation],
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
  final List<String> imageUrls;
  final String profileType; // NEW PARAMETER

  const SeekingFlatmateProfileCard({
    super.key,
    required this.profile,
    required this.matchPercentage,
    required this.imageUrls,
    required this.profileType, // NEW PARAMETER
  });

  @override
  Widget build(BuildContext context) {
    final List<String> imagesToDisplay = (imageUrls.isNotEmpty) ? List<String>.from(imageUrls) : ['https://via.placeholder.com/400x300?text=No+Flatmate+Images'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewProfileScreen(
              userId: profile.uid, // Use uid for userId
              profileDocumentId: profile.documentId!, // Use documentId for profileDocumentId
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 8.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  final PageController pageController = PageController();
                  int currentImageLocalIndex = 0;
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
                        height: 300,
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
                      if (imagesToDisplay.length > 1)
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
                                  color: currentImageLocalIndex == index ? Colors.redAccent : Colors.grey.withOpacity(0.5),
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
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
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
                          title: 'Move-in Date:',
                          items: [profile.moveInDate != null ? DateFormat('yyyy-MM-dd').format(profile.moveInDate!) : null],
                          backgroundColor: Colors.teal.shade100,
                          textColor: Colors.teal.shade800,
                        ),
                        _buildChipList(
                          title: 'Budget:',
                          items: [
                            profile.budgetMin != null && profile.budgetMax != null
                                ? '₹${profile.budgetMin!.toStringAsFixed(0)} - ₹${profile.budgetMax!.toStringAsFixed(0)}'
                                : null
                          ],
                          backgroundColor: Colors.deepPurple.shade100,
                          textColor: Colors.deepPurple.shade800,
                        ),
                      ],
                    ),
                    _buildInfoSection(
                      title: 'Location Preferences',
                      icon: Icons.location_on,
                      children: [
                        _buildChipList(
                          title: 'City:',
                          items: [profile.desiredCity],
                          backgroundColor: Colors.blue.shade100,
                          textColor: Colors.blue.shade800,
                        ),
                        _buildChipList(
                          title: 'Area:',
                          items: [profile.areaPreference],
                          backgroundColor: Colors.cyan.shade100,
                          textColor: Colors.cyan.shade800,
                        ),
                      ],
                    ),
                    _buildInfoSection(
                      title: 'Lifestyle & Habits',
                      icon: Icons.emoji_people,
                      children: [
                        _buildChipList(
                          title: 'Cleanliness:',
                          items: [profile.cleanliness],
                          backgroundColor: Colors.green.shade100,
                          textColor: Colors.green.shade800,
                        ),
                        _buildChipList(
                          title: 'Social Habits:',
                          items: [profile.socialHabits],
                          backgroundColor: Colors.pink.shade100,
                          textColor: Colors.pink.shade800,
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
                          title: 'Pet Ownership:',
                          items: [profile.petOwnership],
                          backgroundColor: Colors.lightGreen.shade100,
                          textColor: Colors.lightGreen.shade800,
                        ),
                        _buildChipList(
                          title: 'Pet Tolerance:',
                          items: [profile.petTolerance],
                          backgroundColor: Colors.lime.shade100,
                          textColor: Colors.lime.shade800,
                        ),
                      ],
                    ),
                    _buildInfoSection(
                      title: 'Occupation',
                      icon: Icons.work,
                      children: [
                        _buildChipList(
                          title: 'Occupation:',
                          items: [profile.occupation],
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
    required List<String?>? items,
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