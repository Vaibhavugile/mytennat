// lib/screens/view_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart'; // Import the display widgets
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // Import FlatListingProfile model
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Import SeekingFlatmateProfile model
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:mytennat/screens/chat_screen.dart'; // Import for chat navigation

class ViewProfileScreen extends StatefulWidget {
  // Make userId optional, allowing it to be null if viewing own profile
  final String? userId;
  // NEW: Add profileDocumentId to specify which profile to show if user has multiple
  final String? profileDocumentId;

  // NEW: Add parameters for the current user's active profile
  final String? currentUserActiveProfileId;
  final String? currentUserActiveProfileType;

  const ViewProfileScreen({
    super.key,
    this.userId,
    this.profileDocumentId, // NEW PARAMETER
    this.currentUserActiveProfileId, // NEW
    this.currentUserActiveProfileType, // NEW
  });

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  dynamic _userProfile;
  String? _userType;
  bool _isLoading = true;
  String? _errorMessage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  // State variables for the current user's active profile, needed for liking
  String? _currentUserActiveProfileId;
  String? _currentUserActiveProfileType;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _currentUserActiveProfileId = widget.currentUserActiveProfileId;
    _currentUserActiveProfileType = widget.currentUserActiveProfileType;
    _fetchUserProfile();
    _loadCurrentUserActiveProfile();
  }

  // Load active profile from SharedPreferences if not passed
  Future<void> _loadCurrentUserActiveProfile() async {
    if (_currentUserActiveProfileId == null || _currentUserActiveProfileType == null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserActiveProfileId = prefs.getString('currentActiveProfileId');
        _currentUserActiveProfileType = prefs.getString('userProfileType');
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String targetUserId = widget.userId ?? _currentUser!.uid; // Default to current user's ID
      final String? targetProfileDocumentId = widget.profileDocumentId;

      if (targetProfileDocumentId == null) {
        // If profileDocumentId is not provided, fetch the first available profile
        QuerySnapshot flatListings = await _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('flatListings')
            .limit(1)
            .get();

        if (flatListings.docs.isNotEmpty) {
          final doc = flatListings.docs.first;
          // FIX: Pass only 2 arguments, assuming 'uid' is handled internally by fromMap
          _userProfile = FlatListingProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          _userType = 'flat_listing';
        } else {
          QuerySnapshot seekingFlatmateProfiles = await _firestore
              .collection('users')
              .doc(targetUserId)
              .collection('seekingFlatmateProfiles')
              .limit(1)
              .get();

          if (seekingFlatmateProfiles.docs.isNotEmpty) {
            final doc = seekingFlatmateProfiles.docs.first;
            // FIX: Pass only 2 arguments, assuming 'uid' is handled internally by fromMap
            _userProfile = SeekingFlatmateProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            _userType = 'seeking_flatmate';
          }
        }
      } else {
        // If profileDocumentId IS provided, determine type and fetch specific profile
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('flatListings')
            .doc(targetProfileDocumentId)
            .get();

        if (doc.exists) {
          // FIX: Pass only 2 arguments, assuming 'uid' is handled internally by fromMap
          _userProfile = FlatListingProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          _userType = 'flat_listing';
        } else {
          doc = await _firestore
              .collection('users')
              .doc(targetUserId)
              .collection('seekingFlatmateProfiles')
              .doc(targetProfileDocumentId)
              .get();
          if (doc.exists) {
            // FIX: Pass only 2 arguments, assuming 'uid' is handled internally by fromMap
            _userProfile = SeekingFlatmateProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            _userType = 'seeking_flatmate';
          }
        }
      }

      // After fetching the profile, if it's not null, ensure the 'uid' property is set.
      // If the 'fromMap' constructor doesn't set it from the map data, it should be set here
      // as it's critical for the like/dislike logic.
      // This assumes FlatListingProfile and SeekingFlatmateProfile have a 'uid' field.
      // If they don't, this needs to be added to the model classes.
      if (_userProfile != null) {
        // This is a crucial line. If the models' fromMap constructors
        // don't take a `uid` parameter, they must read it from the map
        // (e.g., data['uid'] or data['userId']) or it should be set
        // to the targetUserId (which is the user's UID that owns this profile).
        // For now, assuming the models have a settable 'uid' or it's read from data.
        // If the models were updated to have a 'uid' field,
        // we should ensure it's populated correctly.
        // For FlatListingProfile and SeekingFlatmateProfile, the 'uid' property
        // refers to the ID of the user who owns that specific profile.
        // If it's not set by fromMap, we must set it.
        // This assumes the models have a 'uid' field.
        if (_userProfile.uid == null) {
          _userProfile.uid = targetUserId; // Ensure the UID is associated
        }
      }


      if (_userProfile == null) {
        _errorMessage = 'Profile not found.';
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
      print('Error fetching user profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Determine if the currently viewed profile belongs to the logged-in user
  bool _isMyOwnProfile() {
    return _currentUser != null &&
        widget.userId == _currentUser!.uid;
  }

  Future<void> _likeProfile() async {
    if (_currentUser == null || _currentUserActiveProfileId == null || _currentUserActiveProfileType == null || _userProfile == null) {
      print("Cannot like: Missing current user, active profile, or viewed profile details.");
      return;
    }

    final String currentUserId = _currentUser!.uid;
    final String likedUserId = _userProfile.uid; // This _userProfile.uid must be correctly populated
    final String likedProfileDocumentId = _userProfile.documentId;
    final String likedUserProfileType = _userType!; // flat_listing or seeking_flatmate

    print("Liking profile: current user active profile: $_currentUserActiveProfileId (type: $_currentUserActiveProfileType) -> liked profile: $likedProfileDocumentId (type: $likedUserProfileType)");

    // 1. Record the outgoing like from current user's active profile
    await _firestore.collection('user_likes').doc(currentUserId).collection('likes').add({
      'likingUserProfileId': _currentUserActiveProfileId,
      'likingUserProfileType': _currentUserActiveProfileType,
      'likedUserId': likedUserId,
      'likedProfileDocumentId': likedProfileDocumentId,
      'likedUserProfileType': likedUserProfileType,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('Outgoing like recorded.');

    // 2. Check for a mutual like (match)
    // Check if the target profile has already liked the current user's active profile
    final QuerySnapshot incomingLikeCheck = await _firestore.collectionGroup('likes')
        .where('likingUserId', isEqualTo: likedUserId) // The person we just liked
        .where('likingUserProfileId', isEqualTo: likedProfileDocumentId) // Their profile that liked us
        .where('likedUserId', isEqualTo: currentUserId) // Us
        .where('likedProfileDocumentId', isEqualTo: _currentUserActiveProfileId) // Our active profile
        .get();

    if (incomingLikeCheck.docs.isNotEmpty) {
      print('Mutual like detected! Creating match...');
      // It's a match! Create a chat room / match entry
      // Ensure a unique and consistent chat room ID (e.g., sort UIDs + profile IDs)
      List<String> participants = [currentUserId, likedUserId];
      participants.sort(); // Sort UIDs for consistency

      List<String> profileIds = [_currentUserActiveProfileId!, likedProfileDocumentId];
      profileIds.sort(); // Sort profile IDs for consistency

      // Combine sorted UIDs and sorted profile IDs for a unique chat room ID
      String chatRoomId = '${participants.join('_')}_${profileIds.join('_')}';

      await _firestore.collection('matches').doc(chatRoomId).set({
        'user1_uid': currentUserId,
        'user1_profile_id': _currentUserActiveProfileId,
        'user1_profile_type': _currentUserActiveProfileType,
        'user2_uid': likedUserId,
        'user2_profile_id': likedProfileDocumentId,
        'user2_profile_type': likedUserProfileType,
        'timestamp': FieldValue.serverTimestamp(),
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
      print('Match created with ID: $chatRoomId');

      // Optionally, navigate to chat screen or show a match animation
      _showMatchDialog(context, chatRoomId, likedProfileDocumentId, likedUserId);

    } else {
      print('No mutual like yet. Awaiting their like.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You liked ${(_userProfile is FlatListingProfile ? _userProfile.propertyName : _userProfile.name) ?? 'this profile'}!')),
      );
    }
  }

  Future<void> _dislikeProfile() async {
    if (_currentUser == null || _currentUserActiveProfileId == null || _userProfile == null) {
      print("Cannot dislike: Missing current user, active profile, or viewed profile details.");
      return;
    }

    final String currentUserId = _currentUser!.uid;
    final String dislikedUserId = _userProfile.uid; // This _userProfile.uid must be correctly populated
    final String dislikedProfileDocumentId = _userProfile.documentId;
    final String dislikedUserProfileType = _userType!;

    print("Disliking profile: current user active profile: $_currentUserActiveProfileId (type: $_currentUserActiveProfileType) -> disliked profile: $dislikedProfileDocumentId (type: $dislikedUserProfileType)");

    // Record the dislike
    await _firestore.collection('user_dislikes').doc(currentUserId).collection('dislikes').add({
      'dislikingUserProfileId': _currentUserActiveProfileId,
      'dislikingUserProfileType': _currentUserActiveProfileType,
      'dislikedUserId': dislikedUserId,
      'dislikedProfileDocumentId': dislikedProfileDocumentId,
      'dislikedUserProfileType': dislikedUserProfileType,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print('Dislike recorded.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You disliked ${(_userProfile is FlatListingProfile ? _userProfile.propertyName : _userProfile.name) ?? 'this profile'}')),
    );
  }

  void _showMatchDialog(BuildContext context, String chatRoomId, String matchedProfileId, String matchedUserId) {
    String matchedProfileName = (_userProfile is FlatListingProfile) ? (_userProfile.propertyName ?? 'a Flat Listing') : (_userProfile.name ?? 'a Flatmate Profile');
    String? matchedProfileImageUrl = (_userProfile is FlatListingProfile) ? _userProfile.propertyPhotos?.first : _userProfile.profilePictureUrl;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('It\'s a Match!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: matchedProfileImageUrl != null ? NetworkImage(matchedProfileImageUrl) : null,
                child: matchedProfileImageUrl == null
                    ? Icon(
                  (_userProfile is FlatListingProfile) ? Icons.home : Icons.person,
                  size: 50,
                  color: Colors.green,
                )
                    : null,
              ),
              const SizedBox(height: 15),
              Text(
                'You and $matchedProfileName have matched!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Keep Browse', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Pop ViewProfileScreen to return to MatchingScreen
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Send Message'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacement( // Use pushReplacement to replace the current screen (ViewProfileScreen)
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatPartnerId: matchedUserId,
                      chatPartnerName: matchedProfileName,
                      chatPartnerImageUrl: matchedProfileImageUrl,
                      chatRoomId: chatRoomId,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isMyOwnProfile() ? 'My Profile' : 'View Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
          ? const Center(
        child: Text(
          'No profile data available. This user might not have completed their profile.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : Stack(
        children: [
          _userType == 'seeking_flatmate'
              ? SeekingFlatmateProfileDisplay(profile: _userProfile as SeekingFlatmateProfile)
              : FlatListingProfileDisplay(profile: _userProfile as FlatListingProfile),
          // Like/Dislike buttons only if viewing another user's profile and current user has an active profile
          if (!_isMyOwnProfile() && _currentUserActiveProfileId != null && _currentUserActiveProfileType != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: 'dislikeBtn',
                      onPressed: _dislikeProfile,
                      backgroundColor: Colors.redAccent,
                      child: const Icon(Icons.close, color: Colors.white, size: 30),
                    ),
                    FloatingActionButton(
                      heroTag: 'likeBtn',
                      onPressed: _likeProfile,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.favorite, color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}