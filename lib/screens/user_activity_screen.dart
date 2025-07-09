import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // For FlatListingProfile
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // For SeekingFlatmateProfile
import 'package:mytennat/screens/chat_screen.dart'; // For ChatScreen
import 'package:mytennat/screens/view_profile_screen.dart'; // For ViewProfileScreen

class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = true;

  // Data structures to hold aggregated information
  List<dynamic> _userProfilesList = []; // List of current user's profiles
  int _currentProfileDisplayIndex = 0; // Index for the PageView

  // Declared as state variables to be accessible consistently
  String _currentProfileDisplayName = 'No Profiles';
  String _currentProfileTypeDisplay = '';

  // key: userProfileId, value: list of profiles that liked it
  final Map<String, List<dynamic>> _incomingLikes = {};
  // key: userProfileId, value: list of profiles it liked
  final Map<String, List<dynamic>> _outgoingLikes = {};
  // key: userProfileId, value: list of matched profiles with chatRoomId
  final Map<String, List<Map<String, dynamic>>> _matches = {};

  // Notification tracking per profile
  final Map<String, bool> _profileHasNewNotification = {};

  // For TabBar
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    print('initState: _currentUser is ${_currentUser != null ? _currentUser!.uid : 'null'}');
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection); // Add listener for tab changes

    if (_currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your activities.')),
        );
      });
    } else {
      _fetchUserActivities();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // Remove listener
    _tabController.dispose();
    super.dispose();
  }

  // Method to handle tab selection and clear notifications
  void _handleTabSelection() {
    if (!_tabController.indexIsChanging && _userProfilesList.isNotEmpty) {
      final currentProfileId = _userProfilesList[_currentProfileDisplayIndex].documentId!;
      // If user views 'Liked Me' (index 0) or 'Matches' (index 2) tab, mark notification as seen
      if (_tabController.index == 0 || _tabController.index == 2) {
        if (_profileHasNewNotification[currentProfileId] == true) {
          setState(() {
            _profileHasNewNotification[currentProfileId] = false;
            print('Notification for profile $currentProfileId marked as seen on tab switch to ${_tabController.index}');
          });
        }
      }
    }
  }

  // Method to update display names based on current profile index
  void _updateCurrentProfileDisplayInfo() {
    if (_userProfilesList.isNotEmpty && _currentProfileDisplayIndex < _userProfilesList.length) {
      final dynamic profile = _userProfilesList[_currentProfileDisplayIndex];
      _currentProfileDisplayName = _getProfileDisplayName(profile);
      _currentProfileTypeDisplay = _getProfileTypeDisplay(profile);
    } else {
      _currentProfileDisplayName = 'No Profiles';
      _currentProfileTypeDisplay = '';
    }
  }

  Future<void> _fetchUserActivities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String currentUserId = _currentUser!.uid;
      print('Fetching activities for current user ID: $currentUserId');

      // 1. Fetch all of the current user's profiles
      print('Fetching all user profiles...');
      await _fetchAllUserProfiles(currentUserId);
      print('Fetched user profiles: ${_userProfilesList.length} profiles found.');
      _updateCurrentProfileDisplayInfo(); // Update display info after initial fetch

      // 2. Fetch incoming likes for each of the user's profiles
      print('Fetching incoming likes...');
      await _fetchIncomingLikes(currentUserId);
      print('Incoming likes processed. Total entries: ${_incomingLikes.keys.length}');

      // 3. Fetch outgoing likes from each of the user's profiles
      print('Fetching outgoing likes...');
      await _fetchOutgoingLikes(currentUserId);
      print('Outgoing likes processed. Total entries: ${_outgoingLikes.keys.length}');

      // 4. Fetch matches involving any of the user's profiles
      print('Fetching matches...');
      await _fetchMatches(currentUserId);
      print('Matches processed. Total entries: ${_matches.keys.length}');

      // Initialize/Update notification status based on fetched data
      _userProfilesList.forEach((profile) {
        final profileId = profile.documentId!;
        final hasIncoming = _incomingLikes.containsKey(profileId) && _incomingLikes[profileId]!.isNotEmpty;
        final hasMatches = _matches.containsKey(profileId) && _matches[profileId]!.isNotEmpty;
        if (hasIncoming || hasMatches) {
          _profileHasNewNotification[profileId] = true;
        } else {
          _profileHasNewNotification[profileId] = false; // Ensure it's false if no likes/matches
        }
      });
      print('Initial notification states: $_profileHasNewNotification');

    } catch (e) {
      print('Error fetching user activities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load activities: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('Finished fetching user activities. Is loading: $_isLoading');
    }
  }

  Future<void> _fetchAllUserProfiles(String userId) async {
    _userProfilesList.clear();
    _incomingLikes.clear();
    _outgoingLikes.clear();
    _matches.clear();
    _profileHasNewNotification.clear(); // Clear notification states too
    print('fetchAllUserProfiles: Clearing existing profiles and related data.');

    // Fetch Flat Listings
    print('fetchAllUserProfiles: Fetching flatListings for $userId');
    QuerySnapshot flatListings = await _firestore
        .collection('users')
        .doc(userId)
        .collection('flatListings')
        .get();
    print('fetchAllUserProfiles: Found ${flatListings.docs.length} flatListings.');
    for (var doc in flatListings.docs) {
      _userProfilesList.add(FlatListingProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id));
      print('fetchAllUserProfiles: Added FlatListing ${doc.id}');
    }

    // Fetch Seeking Flatmate Profiles
    print('fetchAllUserProfiles: Fetching seekingFlatmateProfiles for $userId');
    QuerySnapshot seekingFlatmateProfiles = await _firestore
        .collection('users')
        .doc(userId)
        .collection('seekingFlatmateProfiles')
        .get();
    print('fetchAllUserProfiles: Found ${seekingFlatmateProfiles.docs.length} seekingFlatmateProfiles.');
    for (var doc in seekingFlatmateProfiles.docs) {
      _userProfilesList.add(SeekingFlatmateProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id));
      print('fetchAllUserProfiles: Added SeekingFlatmateProfile ${doc.id}');
    }
    // Set initial index to 0, or handle if no profiles are found
    if (_userProfilesList.isEmpty) {
      _currentProfileDisplayIndex = 0;
    } else {
      _currentProfileDisplayIndex = 0;
    }
  }

  Future<void> _fetchIncomingLikes(String userId) async {
    _incomingLikes.clear();
    print('fetchIncomingLikes: Clearing existing incoming likes.');
    if (_userProfilesList.isEmpty) { // Added for debugging
      print('fetchIncomingLikes: _userProfilesList is empty. Cannot fetch incoming likes.');
      return;
    }

    for (var userProfile in _userProfilesList) {
      final String userProfileId = userProfile.documentId!;
      print('fetchIncomingLikes: Querying collectionGroup "likes" for userProfileId: $userProfileId (likedUserId: $userId)');
      QuerySnapshot incomingLikesSnapshot = await _firestore.collectionGroup('likes')
          .where('likedUserId', isEqualTo: userId)
          .where('likedProfileDocumentId', isEqualTo: userProfileId)
          .get();
      print('fetchIncomingLikes: Found ${incomingLikesSnapshot.docs.length} incoming likes for profile $userProfileId.');

      List<dynamic> profilesThatLikedMe = [];
      for (var doc in incomingLikesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final likingUserId = data['likingUserId'];
        final likingUserProfileId = data['likingUserProfileId'];
        final likingUserProfileType = data['likingUserProfileType'];
        print('fetchIncomingLikes: Processing incoming like from likingUserId: $likingUserId, likingUserProfileId: $likingUserProfileId, type: $likingUserProfileType, data: $data'); // Added data print

        dynamic likedByProfile;
        try {
          if (likingUserProfileType == 'flat_listing') {
            print('fetchIncomingLikes: Attempting to fetch FlatListing for $likingUserId/$likingUserProfileId');
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likingUserId)
                .collection('flatListings')
                .doc(likingUserProfileId)
                .get();
            if (otherDoc.exists) {
              likedByProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
              print('fetchIncomingLikes: FlatListing found: ${otherDoc.id} (Name: ${likedByProfile.ownerName})'); // Added name print
            } else {
              print('fetchIncomingLikes: FlatListing NOT found for $likingUserId/$likingUserProfileId');
            }
          } else if (likingUserProfileType == 'seeking_flatmate') {
            print('fetchIncomingLikes: Attempting to fetch SeekingFlatmateProfile for $likingUserId/$likingUserProfileId');
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likingUserId)
                .collection('seekingFlatmateProfiles')
                .doc(likingUserProfileId)
                .get();
            if (otherDoc.exists) {
              likedByProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
              print('fetchIncomingLikes: SeekingFlatmateProfile found: ${otherDoc.id} (Name: ${likedByProfile.name})'); // Added name print
            } else {
              print('fetchIncomingLikes: SeekingFlatmateProfile NOT found for $likingUserId/$likingUserProfileId');
            }
          }
        } catch (e) {
          print("Error fetching liking profile details for incoming like: $e");
        }

        if (likedByProfile != null) {
          profilesThatLikedMe.add(likedByProfile);
          print('fetchIncomingLikes: Added likedByProfile: ${likedByProfile.documentId} to list.'); // Added print
        } else {
          print('fetchIncomingLikes: likedByProfile was null, not added.'); // Added print
        }
      }
      if (profilesThatLikedMe.isNotEmpty) {
        _incomingLikes[userProfileId] = profilesThatLikedMe;
        print('fetchIncomingLikes: _incomingLikes[$userProfileId] populated with ${profilesThatLikedMe.length} profiles.'); // Added print
      } else {
        print('fetchIncomingLikes: No profiles liked this userProfile ($userProfileId). _incomingLikes not updated for it.'); // Added print
      }
    }
    print('fetchIncomingLikes: Final _incomingLikes state: ${_incomingLikes.keys.map((k) => '$k: ${_incomingLikes[k]?.length} profiles').join(', ')}'); // Final state print
  }

  Future<void> _fetchOutgoingLikes(String userId) async {
    _outgoingLikes.clear();
    print('fetchOutgoingLikes: Clearing existing outgoing likes.');
    for (var userProfile in _userProfilesList) {
      final String userProfileId = userProfile.documentId!;
      print('fetchOutgoingLikes: Querying user_likes/${userId}/likes for likingUserProfileId: $userProfileId');
      QuerySnapshot outgoingLikesSnapshot = await _firestore.collection('user_likes')
          .doc(userId)
          .collection('likes')
          .where('likingUserProfileId', isEqualTo: userProfileId)
          .get();
      print('fetchOutgoingLikes: Found ${outgoingLikesSnapshot.docs.length} outgoing likes for profile $userProfileId.');

      List<dynamic> profilesLikedByMe = [];
      for (var doc in outgoingLikesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final likedUserId = data['likedUserId'];
        final likedProfileDocumentId = data['likedProfileDocumentId'];
        final likedUserProfileType = data['likedUserProfileType'];
        print('fetchOutgoingLikes: Processing outgoing like to likedUserId: $likedUserId, likedProfileDocumentId: $likedProfileDocumentId, type: $likedUserProfileType');

        dynamic likedProfile;
        try {
          if (likedUserProfileType == 'flat_listing') {
            print('fetchOutgoingLikes: Fetching FlatListing for $likedUserId/$likedProfileDocumentId');
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likedUserId)
                .collection('flatListings')
                .doc(likedProfileDocumentId)
                .get();
            if (otherDoc.exists) {
              likedProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
              print('fetchOutgoingLikes: FlatListing found: ${otherDoc.id}');
            } else {
              print('fetchOutgoingLikes: FlatListing not found for $likedUserId/$likedProfileDocumentId');
            }
          } else if (likedUserProfileType == 'seeking_flatmate') {
            print('fetchOutgoingLikes: Fetching SeekingFlatmateProfile for $likedUserId/$likedProfileDocumentId');
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likedUserId)
                .collection('seekingFlatmateProfiles')
                .doc(likedProfileDocumentId)
                .get();
            if (otherDoc.exists) {
              likedProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
              print('fetchOutgoingLikes: SeekingFlatmateProfile found: ${otherDoc.id}');
            } else {
              print('fetchOutgoingLikes: SeekingFlatmateProfile not found for $likedUserId/$likedProfileDocumentId');
            }
          }
        } catch (e) {
          print("Error fetching liked profile details for outgoing like: $e");
        }

        if (likedProfile != null) {
          profilesLikedByMe.add(likedProfile);
        }
      }
      if (profilesLikedByMe.isNotEmpty) {
        _outgoingLikes[userProfileId] = profilesLikedByMe;
      }
    }
  }

  Future<void> _fetchMatches(String userId) async {
    _matches.clear();
    print('fetchMatches: Clearing existing matches.');

    print('fetchMatches: Querying matches where user1_uid is $userId');
    QuerySnapshot matchesSnapshot1 = await _firestore.collection('matches')
        .where('user1_uid', isEqualTo: userId)
        .get();
    print('fetchMatches: Found ${matchesSnapshot1.docs.length} matches as user1.');

    print('fetchMatches: Querying matches where user2_uid is $userId');
    QuerySnapshot matchesSnapshot2 = await _firestore.collection('matches')
        .where('user2_uid', isEqualTo: userId)
        .get();
    print('fetchMatches: Found ${matchesSnapshot2.docs.length} matches as user2.');

    final allMatchDocs = {...matchesSnapshot1.docs, ...matchesSnapshot2.docs};
    print('fetchMatches: Total unique match documents: ${allMatchDocs.length}');

    for (var doc in allMatchDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final String user1Uid = data['user1_uid'];
      final String user2Uid = data['user2_uid'];
      final String user1ProfileId = data['user1_profile_id'];
      final String user2ProfileId = data['user2_profile_id'];
      final String user1ProfileType = data['user1_profile_type'];
      final String user2ProfileType = data['user2_profile_type'];
      final String chatRoomId = data['chatRoomId'];
      print('fetchMatches: Processing match document: ${doc.id}');
      print('fetchMatches: Match details - user1: $user1Uid ($user1ProfileId, $user1ProfileType), user2: $user2Uid ($user2ProfileId, $user2ProfileType), chatRoomId: $chatRoomId');

      String currentUserProfileIdInMatch;
      String otherUserUid;
      String otherUserProfileId;
      String otherUserProfileType;

      if (user1Uid == userId) {
        currentUserProfileIdInMatch = user1ProfileId;
        otherUserUid = user2Uid;
        otherUserProfileId = user2ProfileId;
        otherUserProfileType = user2ProfileType;
        print('fetchMatches: Current user is user1. Matched with user2: $otherUserUid');
      } else {
        currentUserProfileIdInMatch = user2ProfileId;
        otherUserUid = user1Uid;
        otherUserProfileId = user1ProfileId;
        otherUserProfileType = user1ProfileType;
        print('fetchMatches: Current user is user2. Matched with user1: $otherUserUid');
      }

      // Fetch the details of the other user's profile involved in the match
      dynamic otherProfile;
      try {
        if (otherUserProfileType == 'flat_listing') {
          print('fetchMatches: Fetching matched FlatListing for $otherUserUid/$otherUserProfileId');
          DocumentSnapshot otherDoc = await _firestore
              .collection('users')
              .doc(otherUserUid)
              .collection('flatListings')
              .doc(otherUserProfileId)
              .get();
          if (otherDoc.exists) {
            otherProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            print('fetchMatches: Matched FlatListing found: ${otherDoc.id}');
          } else {
            print('fetchMatches: Matched FlatListing NOT found: $otherUserUid/$otherUserProfileId');
          }
        } else if (otherUserProfileType == 'seeking_flatmate') {
          print('fetchMatches: Fetching matched SeekingFlatmateProfile for $otherUserUid/$otherUserProfileId');
          DocumentSnapshot otherDoc = await _firestore
              .collection('users')
              .doc(otherUserUid)
              .collection('seekingFlatmateProfiles')
              .doc(otherUserProfileId)
              .get();
          if (otherDoc.exists) {
            otherProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            print('fetchMatches: Matched SeekingFlatmateProfile found: ${otherDoc.id}');
          } else {
            print('fetchMatches: Matched SeekingFlatmateProfile NOT found: $otherUserUid/$otherUserProfileId');
          }
        }
      } catch (e) {
        print("Error fetching matched profile details: $e");
      }

      if (otherProfile != null) {
        if (!_matches.containsKey(currentUserProfileIdInMatch)) {
          _matches[currentUserProfileIdInMatch] = [];
          print('fetchMatches: Initializing match list for profile $currentUserProfileIdInMatch');
        }
        _matches[currentUserProfileIdInMatch]!.add({
          'profile': otherProfile,
          'chatRoomId': chatRoomId,
        });
        print('fetchMatches: Added match for profile $currentUserProfileIdInMatch: ${otherProfile.documentId}');
      }
    }
  }

  String? _findChatRoomId(String currentUserProfileId, String otherUserUid, String otherUserProfileId) {
    final List<Map<String, dynamic>>? matchesForCurrentUserProfile = _matches[currentUserProfileId];
    if (matchesForCurrentUserProfile == null) {
      print('_findChatRoomId: No matches found for current profile ID: $currentUserProfileId');
      return null;
    }

    for (var match in matchesForCurrentUserProfile) {
      final dynamic matchedProfile = match['profile'];
      if (matchedProfile != null && matchedProfile.uid == otherUserUid && matchedProfile.documentId == otherUserProfileId) {
        print('_findChatRoomId: Found chatRoomId ${match['chatRoomId']} for matched profile ${otherUserProfileId}');
        return match['chatRoomId'];
      }
    }
    print('_findChatRoomId: No chatRoomId found for current profile ID: $currentUserProfileId and other profile ID: $otherUserProfileId');
    return null;
  }

  String _getProfileDisplayName(dynamic profile) {
    if (profile is FlatListingProfile) {
      return profile.ownerName ?? 'Flat Listing';
    } else if (profile is SeekingFlatmateProfile) {
      return profile.name ?? 'Seeking Flatmate';
    }
    return 'Unknown Profile';
  }

  String _getProfileTypeDisplay(dynamic profile) {
    if (profile is FlatListingProfile) {
      return 'Flat Listing';
    } else if (profile is SeekingFlatmateProfile) {
      return 'Seeking Flatmate';
    }
    return 'Unknown';
  }

  // Method to show the profile selection sheet
  void _showProfileSelectionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make column only take required space
            children: [
              Text(
                'Select Your Active Profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              // Use Flexible or Expanded if ListView could be very long
              Flexible( // Use Flexible to prevent render overflow if many profiles
                child: ListView.builder(
                  shrinkWrap: true, // Allow ListView to take only as much space as its children
                  itemCount: _userProfilesList.length,
                  itemBuilder: (context, index) {
                    final profile = _userProfilesList[index];
                    final profileName = _getProfileDisplayName(profile);
                    final profileType = _getProfileTypeDisplay(profile);
                    final isSelected = index == _currentProfileDisplayIndex;
                    final hasNotification = _profileHasNewNotification[profile.documentId!] == true; // Check notification for this specific profile

                    return Card(
                      color: isSelected ? Colors.redAccent.withOpacity(0.1) : null, // Highlight selected
                      elevation: isSelected ? 2 : 1,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? Colors.redAccent : Colors.blueGrey,
                          child: Icon(
                            profile is FlatListingProfile ? Icons.home : Icons.group,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(profileName),
                        subtitle: Text(profileType),
                        trailing: hasNotification
                            ? const Icon(Icons.notifications_active, color: Colors.amber) // Show notification icon in list
                            : null,
                        onTap: () {
                          setState(() {
                            _currentProfileDisplayIndex = index; // Update the index
                            _updateCurrentProfileDisplayInfo(); // Update display names
                            // Mark notification for the newly selected profile as seen
                            final selectedProfileId = _userProfilesList[_currentProfileDisplayIndex].documentId!;
                            _profileHasNewNotification[selectedProfileId] = false;
                            print('Notification for profile $selectedProfileId marked as seen on selection from sheet');
                          });
                          Navigator.pop(context); // Close the bottom sheet
                          ScaffoldMessenger.of(context).showSnackBar( // Show confirmation
                            SnackBar(
                              content: Text('Switched to: $_currentProfileDisplayName'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    dynamic currentDisplayedProfile;
    String currentProfileId = '';

    if (_userProfilesList.isNotEmpty && _currentProfileDisplayIndex < _userProfilesList.length) {
      currentDisplayedProfile = _userProfilesList[_currentProfileDisplayIndex];
      currentProfileId = currentDisplayedProfile.documentId!;
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Connections'),
          backgroundColor: Colors.redAccent,
          actions: [
            if (_userProfilesList.isNotEmpty)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_outline, size: 28, color: Colors.white),
                    onPressed: () {
                      // Now, clicking the icon shows the selection sheet
                      _showProfileSelectionSheet();
                    },
                  ),
                  // Check notification status for the CURRENTLY active profile
                  if (currentProfileId.isNotEmpty && _profileHasNewNotification[currentProfileId] == true)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: const Text(
                          '!',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              ),
            const SizedBox(width: 10),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Liked Me', icon: Icon(Icons.favorite)),
              Tab(text: 'Liked By Me', icon: Icon(Icons.thumb_up)),
              Tab(text: 'Matches', icon: Icon(Icons.handshake)),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userProfilesList.isEmpty
            ? const Center(child: Text('No profiles found for this user. Please create one.'))
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Container(
                  height: 120,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.redAccent,
                        child: Icon(
                          currentDisplayedProfile is FlatListingProfile ? Icons.home : Icons.group,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Your Active Profile:',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            Text(
                              _currentProfileDisplayName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '(${_currentProfileTypeDisplay})',
                              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSectionContent(
                    profiles: _incomingLikes[currentProfileId],
                    emptyMessage: 'No one has liked this profile yet.',
                    onTapProfile: (profile) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(
                        userId: profile.uid!,
                        profileDocumentId: profile.documentId!,
                      )));
                    },
                    getChatRoomId: (profile) => _findChatRoomId(currentProfileId, profile.uid!, profile.documentId!),
                    isMatchSection: false,
                  ),

                  _buildSectionContent(
                    profiles: _outgoingLikes[currentProfileId],
                    emptyMessage: 'This profile has not liked anyone yet.',
                    onTapProfile: (profile) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(
                        userId: profile.uid!,
                        profileDocumentId: profile.documentId!,
                      )));
                    },
                    getChatRoomId: (profile) => _findChatRoomId(currentProfileId, profile.uid!, profile.documentId!),
                    isMatchSection: false,
                  ),

                  _buildSectionContent(
                    profiles: _matches[currentProfileId]?.map((m) => m['profile']).toList(),
                    emptyMessage: 'No matches for this profile yet.',
                    onTapProfile: (profile) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(
                        userId: profile.uid!,
                        profileDocumentId: profile.documentId!,
                      )));
                    },
                    getChatRoomId: (profile) => _findChatRoomId(currentProfileId, profile.uid!, profile.documentId!),
                    isMatchSection: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent({
    List<dynamic>? profiles,
    required String emptyMessage,
    required Function(dynamic profile) onTapProfile,
    required String? Function(dynamic profile) getChatRoomId,
    bool isMatchSection = false,
  }) {
    print('Building section content. Profiles count: ${profiles?.length ?? 0}. Is Match Section: $isMatchSection'); // Added print
    return profiles == null || profiles.isEmpty
        ? Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey, fontSize: 16)))
        : ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        String name = _getProfileDisplayName(profile);
        String typeDisplay = _getProfileTypeDisplay(profile);

        final chatRoomId = getChatRoomId(profile);
        final canChat = isMatchSection && chatRoomId != null;
        print('ListTile for profile: $name (ID: ${profile.documentId}), Can Chat: $canChat (chatRoomId: $chatRoomId)');

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(
                profile is FlatListingProfile ? Icons.home : Icons.group,
                color: Colors.white,
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('$typeDisplay (ID: ${profile.documentId})', style: const TextStyle(color: Colors.grey)),
            trailing: canChat
                ? ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                  chatPartnerId: profile.uid!,
                  chatPartnerName: name,
                  chatRoomId: chatRoomId,
                )));
              },
              icon: const Icon(Icons.chat),
              label: const Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            )
                : null,
            onTap: () => onTapProfile(profile),
          ),
        );
      },
    );
  }
}