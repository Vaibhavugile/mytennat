import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // For FlatListingProfile
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // For SeekingFlatmateProfile
import 'package:mytennat/screens/chat_screen.dart'; // For ChatScreen
import 'package:mytennat/screens/view_profile_screen.dart'; // For ViewProfileScreen
import 'package:url_launcher/url_launcher.dart'; // Import for making phone calls
import 'package:mytennat/screens/home_page.dart'; // Import HomePage
import 'package:mytennat/screens/matching_screen.dart'; // Import MatchingScreen
import 'package:mytennat/screens/matches_list_screen.dart'; // Import MatchesListScreen
import 'package:mytennat/screens/more_profile_screen.dart'; // Import MoreProfileScreen


class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = true;

  List<dynamic> _userProfilesList = []; // List of all current user's profiles (FlatListing and SeekingFlatmate)

  // key: userProfileId, value: list of profiles that liked it
  final Map<String, List<dynamic>> _incomingLikes = {};
  // key: userProfileId, value: list of profiles it liked
  final Map<String, List<dynamic>> _outgoingLikes = {};
  // key: userProfileId, value: list of matched profiles with chatRoomId
  final Map<String, List<Map<String, dynamic>>> _matches = {};

  // Bottom Navigation Bar state
  int _selectedIndex = 3; // Set initial index to 3 for 'Activity'


  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    print('initState: _currentUser is ${_currentUser != null ? _currentUser!.uid : 'null'}');

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

  Future<void> _fetchUserActivities() async {
    setState(() {
      _isLoading = true;
      _userProfilesList.clear();
      _incomingLikes.clear();
      _outgoingLikes.clear();
      _matches.clear();
    });

    try {
      final String currentUserId = _currentUser!.uid;
      print('Fetching activities for current user ID: $currentUserId');

      // 1. Fetch all of the current user's profiles
      print('Fetching all user profiles...');
      await _fetchAllUserProfiles(currentUserId);
      print('Fetched user profiles: ${_userProfilesList.length} profiles found.');

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
    print('fetchAllUserProfiles: Clearing existing profiles.');

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
  }

  Future<void> _fetchIncomingLikes(String userId) async {
    _incomingLikes.clear();
    print('fetchIncomingLikes: Clearing existing incoming likes.');

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

        dynamic likedByProfile;
        try {
          if (likingUserProfileType == 'flat_listing') {
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likingUserId)
                .collection('flatListings')
                .doc(likingUserProfileId)
                .get();
            if (otherDoc.exists) {
              likedByProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            }
          } else if (likingUserProfileType == 'seeking_flatmate') {
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likingUserId)
                .collection('seekingFlatmateProfiles')
                .doc(likingUserProfileId)
                .get();
            if (otherDoc.exists) {
              likedByProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            }
          }
        } catch (e) {
          print("Error fetching liking profile details for incoming like: $e");
        }

        if (likedByProfile != null) {
          profilesThatLikedMe.add(likedByProfile);
        }
      }
      if (profilesThatLikedMe.isNotEmpty) {
        _incomingLikes[userProfileId] = profilesThatLikedMe;
      }
    }
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

      List<dynamic> profilesLikedByMe = [];
      for (var doc in outgoingLikesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final likedUserId = data['likedUserId'];
        final likedProfileDocumentId = data['likedProfileDocumentId'];
        final likedUserProfileType = data['likedUserProfileType'];

        dynamic likedProfile;
        try {
          if (likedUserProfileType == 'flat_listing') {
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likedUserId)
                .collection('flatListings')
                .doc(likedProfileDocumentId)
                .get();
            if (otherDoc.exists) {
              likedProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            }
          } else if (likedUserProfileType == 'seeking_flatmate') {
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likedUserId)
                .collection('seekingFlatmateProfiles')
                .doc(likedProfileDocumentId)
                .get();
            if (otherDoc.exists) {
              likedProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
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

    QuerySnapshot matchesSnapshot1 = await _firestore.collection('matches')
        .where('user1_uid', isEqualTo: userId)
        .get();

    QuerySnapshot matchesSnapshot2 = await _firestore.collection('matches')
        .where('user2_uid', isEqualTo: userId)
        .get();

    final allMatchDocs = {...matchesSnapshot1.docs, ...matchesSnapshot2.docs};

    for (var doc in allMatchDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final String user1Uid = data['user1_uid'];
      final String user2Uid = data['user2_uid'];
      final String user1ProfileId = data['user1_profile_id'];
      final String user2ProfileId = data['user2_profile_id'];
      final String user1ProfileType = data['user1_profile_type'];
      final String user2ProfileType = data['user2_profile_type'];
      final String chatRoomId = data['chatRoomId'];

      String currentUserProfileIdInMatch;
      String otherUserUid;
      String otherUserProfileId;
      String otherUserProfileType;

      if (user1Uid == userId) {
        currentUserProfileIdInMatch = user1ProfileId;
        otherUserUid = user2Uid;
        otherUserProfileId = user2ProfileId;
        otherUserProfileType = user2ProfileType;
      } else {
        currentUserProfileIdInMatch = user2ProfileId;
        otherUserUid = user1Uid;
        otherUserProfileId = user1ProfileId;
        otherUserProfileType = user1ProfileType;
      }

      // Fetch the details of the other user's profile involved in the match
      dynamic otherProfile;
      try {
        if (otherUserProfileType == 'flat_listing') {
          DocumentSnapshot otherDoc = await _firestore
              .collection('users')
              .doc(otherUserUid)
              .collection('flatListings')
              .doc(otherUserProfileId)
              .get();
          if (otherDoc.exists) {
            otherProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
          }
        } else if (otherUserProfileType == 'seeking_flatmate') {
          DocumentSnapshot otherDoc = await _firestore
              .collection('users')
              .doc(otherUserUid)
              .collection('seekingFlatmateProfiles')
              .doc(otherUserProfileId)
              .get();
          if (otherDoc.exists) {
            otherProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
          }
        }
      } catch (e) {
        print("Error fetching matched profile details: $e");
      }

      if (otherProfile != null) {
        if (!_matches.containsKey(currentUserProfileIdInMatch)) {
          _matches[currentUserProfileIdInMatch] = [];
        }
        _matches[currentUserProfileIdInMatch]!.add({
          'profile': otherProfile,
          'chatRoomId': chatRoomId,
        });
      }
    }
  }

  String? _findChatRoomId(String currentUserProfileId, String otherUserUid, String otherUserProfileId) {
    final List<Map<String, dynamic>>? matchesForCurrentUserProfile = _matches[currentUserProfileId];
    if (matchesForCurrentUserProfile == null) {
      return null;
    }

    for (var match in matchesForCurrentUserProfile) {
      final dynamic matchedProfile = match['profile'];
      // Assuming 'uid' is a property on both FlatListingProfile and SeekingFlatmateProfile
      if (matchedProfile != null && matchedProfile.uid == otherUserUid && matchedProfile.documentId == otherUserProfileId) {
        return match['chatRoomId'];
      }
    }
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
      return 'flat_listing'; // Return raw type for filtering
    } else if (profile is SeekingFlatmateProfile) {
      return 'seeking_flatmate'; // Return raw type for filtering
    }
    return 'unknown';
  }

  // New function for making phone calls
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber')),
      );
    }
  }

  // --- New Aggregation Methods ---

  List<dynamic> _getAggregatedIncomingLikes(String profileType) {
    List<dynamic> aggregatedProfiles = [];
    for (var profile in _userProfilesList) {
      if (_getProfileTypeDisplay(profile) == profileType) {
        final profileId = profile.documentId!;
        if (_incomingLikes.containsKey(profileId)) {
          aggregatedProfiles.addAll(_incomingLikes[profileId]!);
        }
      }
    }
    // You might want to remove duplicates if the same 'liking' profile liked multiple of your profiles of the same type.
    return aggregatedProfiles.toSet().toList(); // Using toSet().toList() for basic deduplication
  }

  List<dynamic> _getAggregatedOutgoingLikes(String profileType) {
    List<dynamic> aggregatedProfiles = [];
    for (var profile in _userProfilesList) {
      if (_getProfileTypeDisplay(profile) == profileType) {
        final profileId = profile.documentId!;
        if (_outgoingLikes.containsKey(profileId)) {
          aggregatedProfiles.addAll(_outgoingLikes[profileId]!);
        }
      }
    }
    return aggregatedProfiles.toSet().toList();
  }

  List<Map<String, dynamic>> _getAggregatedMatches(String profileType) {
    List<Map<String, dynamic>> aggregatedMatches = [];
    for (var profile in _userProfilesList) {
      if (_getProfileTypeDisplay(profile) == profileType) {
        final profileId = profile.documentId!;
        if (_matches.containsKey(profileId)) {
          // Add the matched profiles along with their chatRoomId
          for (var matchEntry in _matches[profileId]!) {
            // Check if this specific match (profile + chatRoomId) is already added
            bool isDuplicate = aggregatedMatches.any((existingMatch) =>
            existingMatch['profile'].documentId == matchEntry['profile'].documentId &&
                existingMatch['profile'].uid == matchEntry['profile'].uid && // Also check UID for uniqueness
                existingMatch['chatRoomId'] == matchEntry['chatRoomId']
            );
            if (!isDuplicate) {
              // Add a reference to the current user's profile ID that generated this match
              aggregatedMatches.add({
                ...matchEntry,
                'currentOwnerProfileId': profileId, // Add this crucial piece of information
              });
            }
          }
        }
      }
    }
    return aggregatedMatches;
  }


  // Method to handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1: // Matches (Now refers to MatchingScreen)
        if (_userProfilesList.isNotEmpty) {
          String? defaultProfileType = _getProfileTypeDisplay(_userProfilesList[0]);
          String? defaultProfileId = _userProfilesList[0].documentId;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MatchingScreen(
                profileType: defaultProfileType!,
                profileId: defaultProfileId!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please create a profile to view matches.')),
          );
        }
        break;
      case 2: // Chat (MatchesListScreen)
        if (_userProfilesList.isNotEmpty) {
          String? defaultProfileType = _getProfileTypeDisplay(_userProfilesList[0]);
          String? defaultProfileId = _userProfilesList[0].documentId;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MatchesListScreen(
                profileType: defaultProfileType!,
                profileId: defaultProfileId!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please create a profile to view chat/matches.')),
          );
        }
        break;
      case 3: // Activity
      // Stay on UserActivityScreen, or pop if it's not the root
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        break;
      case 4: // More
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MoreProfileScreen()),
        );
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController( // Outer Tab Controller for "Room Listings" and "Seeking Flatmates"
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Connections',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: const TabBar( // The main tabs in the AppBar
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Room Listings', icon: Icon(Icons.home)),
              Tab(text: 'Seeking Flatmates', icon: Icon(Icons.group)),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView( // Outer TabBarView corresponding to the AppBar tabs
          children: [
            // Content for "Room Listings" tab
            _buildProfileActivityView(
              profileType: 'flat_listing',
              emptyMessage: 'No Room Listing profiles available.',
            ),
            // Content for "Seeking Flatmates" tab
            _buildProfileActivityView(
              profileType: 'seeking_flatmate',
              emptyMessage: 'No Seeking Flatmate profiles available.',
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFAD1457),
          unselectedItemColor: Colors.grey[600],
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
      ),
    );
  }

  // Renamed from _buildMainProfileSection to represent the content of each main tab
  Widget _buildProfileActivityView({
    required String profileType,
    required String emptyMessage,
  }) {
    // Filter profiles belonging to this type
    final List<dynamic> profilesOfType = _userProfilesList.where((p) => _getProfileTypeDisplay(p) == profileType).toList();

    return DefaultTabController( // Inner Tab Controller for "Liked Me", "Liked By Me", "Matches"
        length: 3,
        child: Column(
            children: [
            // Optional: You can add a small header here if you want text like "Activity for Room Listings"
            // but the top level tab already gives context.
            if (profilesOfType.isEmpty)
        Expanded( // Use Expanded to ensure it takes available space in the column
    child: Center(
    child: Text(emptyMessage, style: const TextStyle(color: Colors.grey, fontSize: 16)),
    ),
    )
    else ...[
    TabBar( // Inner TabBar
    indicatorColor: const Color(0xFFAD1457), // Match app bar accent
    labelColor: const Color(0xFF6A1B9A), // Match app bar primary
    unselectedLabelColor: Colors.grey[600],
    tabs: const [
    Tab(text: 'Liked Me', icon: Icon(Icons.favorite)),
    Tab(text: 'Liked By Me', icon: Icon(Icons.thumb_up)),
    Tab(text: 'Matches', icon: Icon(Icons.handshake)),
    ],
    ),
    Expanded( // Crucial: Expanded makes TabBarView fill remaining space
    child: TabBarView( // Inner TabBarView
    children: [
    _buildSectionContent(
    profiles: _getAggregatedIncomingLikes(profileType),
    emptyMessage: 'No one has liked these profiles yet.',
    isMatchSection: false,
    isLikedByMeSection: false,
    profileTypeFilter: profileType,
    ),
    _buildSectionContent(
    profiles: _getAggregatedOutgoingLikes(profileType),
    emptyMessage: 'These profiles have not liked anyone yet.',
    isMatchSection: false,
    isLikedByMeSection: true,
    profileTypeFilter: profileType,
    ),
    _buildSectionContent(
    profiles: _getAggregatedMatches(profileType),
    emptyMessage: 'No matches for these profiles yet.',
    isMatchSection: true,
    isLikedByMeSection: false,
    profileTypeFilter: profileType,
    ),
    ],
    ),
    ),
    ],

    ]
        )
    );
  }

  // Re-designed _buildSectionContent to be more generic and use aggregated data
  Widget _buildSectionContent({
    List<dynamic>? profiles, // This can now be List<dynamic> (for incoming/outgoing) or List<Map<String, dynamic>> (for matches)
    required String emptyMessage,
    required bool isMatchSection,
    required bool isLikedByMeSection,
    required String profileTypeFilter, // The type of profiles this section is displaying activities for
  }) {
    if (profiles == null || profiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(emptyMessage, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      );
    }

    return ListView.builder(
      // Important: Use AlwaysScrollableScrollPhysics if the content within the inner tab
      // might exceed the TabBarView's height. This will make only this inner list scrollable.
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true, // This is crucial for ListView.builder inside an Expanded
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        dynamic profile;
        String? chatRoomId;
        String? currentOwnerProfileId;

        if (isMatchSection) {
          final Map<String, dynamic> matchEntry = profiles[index];
          profile = matchEntry['profile'];
          chatRoomId = matchEntry['chatRoomId'];
          currentOwnerProfileId = matchEntry['currentOwnerProfileId'];
        } else {
          profile = profiles[index];
        }


        String name = _getProfileDisplayName(profile);
        String typeDisplay = _getProfileTypeDisplay(profile); // Still used for icon/label
        String? profileImageUrl;
        String? phoneNumber;

        if (profile is FlatListingProfile) {
          // profileImageUrl = profile.ownerImageUrl; // Uncomment if you have this field
          phoneNumber = profile.ownerPhonenumber;
        } else if (profile is SeekingFlatmateProfile) {
          // profileImageUrl = profile.profileImageUrl; // Uncomment if you have this field
          phoneNumber = profile.phoneNumber;
        }


        return _buildProfileCard(
          profile: profile,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(
              userId: profile.uid!,
              profileDocumentId: profile.documentId!,
            )));
          },
          showChatButton: isMatchSection && chatRoomId != null && currentOwnerProfileId != null,
          showCallButton: isLikedByMeSection && phoneNumber != null && phoneNumber.isNotEmpty,
          chatRoomId: chatRoomId,
          currentOwnerProfileId: currentOwnerProfileId,
        );
      },
    );
  }

  // Reusable card widget for displaying profiles in lists
  Widget _buildProfileCard({
    required dynamic profile,
    required VoidCallback onTap,
    required bool showChatButton,
    required bool showCallButton,
    String? chatRoomId,
    String? currentOwnerProfileId, // The ID of the user's own profile involved in this match
  }) {
    String name = _getProfileDisplayName(profile);
    String typeDisplay = _getProfileTypeDisplay(profile); // Still used for icon/label
    String? profileImageUrl;
    String? phoneNumber;

    if (profile is FlatListingProfile) {
      // profileImageUrl = profile.ownerImageUrl; // Uncomment if you have this field
      phoneNumber = profile.ownerPhonenumber;
    } else if (profile is SeekingFlatmateProfile) {
      // profileImageUrl = profile.profileImageUrl; // Uncomment if you have this field
      phoneNumber = profile.phoneNumber;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), // Added horizontal margin
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
              ? NetworkImage(profileImageUrl)
              : null,
          child: profileImageUrl == null || profileImageUrl.isEmpty
              ? Icon(
            typeDisplay == 'flat_listing' ? Icons.home : Icons.group,
            color: Colors.white,
          )
              : null,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          typeDisplay == 'flat_listing' ? 'Room Listing' : 'Seeking Flatmate',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showChatButton) // chatRoomId and currentOwnerProfileId checked in _buildSectionContent
              ElevatedButton.icon(
                onPressed: () {
                  // Ensure chatRoomId and currentOwnerProfileId are non-null here
                  if (chatRoomId != null && currentOwnerProfileId != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                      chatPartnerId: profile.uid!,
                      chatPartnerName: name,
                      chatRoomId: chatRoomId,
                    )));
                  }
                },
                icon: const Icon(Icons.chat),
                label: const Text('Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            if (showCallButton && phoneNumber != null && phoneNumber.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: showChatButton ? 8.0 : 0.0),
                child: IconButton(
                  icon: const Icon(Icons.call, color: Colors.blue),
                  onPressed: () => _makePhoneCall(phoneNumber!),
                  tooltip: 'Call $name',
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

// Dummy classes for FlatListingProfile and SeekingFlatmateProfile
// (Ensure these match your actual implementations, potentially in a shared models file)
// Make sure these classes have a 'uid' field if you are using it for navigation.
class FlatListingProfile {
  final String documentId;
  final String? ownerName;
  final String? ownerPhonenumber;
  final String? uid; // Add UID
  // Add other fields from your FlatListingProfile here

  FlatListingProfile({required this.documentId, this.ownerName, this.ownerPhonenumber, this.uid});

  factory FlatListingProfile.fromMap(Map<String, dynamic> data, String id) {
    return FlatListingProfile(
      documentId: id,
      ownerName: data['ownerName'],
      ownerPhonenumber: data['ownerPhonenumber'],
      uid: data['uid'], // Assuming 'uid' is stored in Firestore document
    );
  }

  // Override hashCode and equals for proper deduplication with toSet()
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FlatListingProfile &&
              runtimeType == other.runtimeType &&
              documentId == other.documentId &&
              uid == other.uid; // Also compare UID for uniqueness

  @override
  int get hashCode => documentId.hashCode ^ uid.hashCode; // Combine hash codes
}

class SeekingFlatmateProfile {
  final String documentId;
  final String? name;
  final String? phoneNumber;
  final String? uid; // Add UID
  // Add other fields from your SeekingFlatmateProfile here

  SeekingFlatmateProfile({required this.documentId, this.name, this.phoneNumber, this.uid});

  factory SeekingFlatmateProfile.fromMap(Map<String, dynamic> data, String id) {
    return SeekingFlatmateProfile(
      documentId: id,
      name: data['name'],
      phoneNumber: data['phoneNumber'],
      uid: data['uid'], // Assuming 'uid' is stored in Firestore document
    );
  }

  // Override hashCode and equals for proper deduplication with toSet()
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SeekingFlatmateProfile &&
              runtimeType == other.runtimeType &&
              documentId == other.documentId &&
              uid == other.uid; // Also compare UID for uniqueness

  @override
  int get hashCode => documentId.hashCode ^ uid.hashCode; // Combine hash codes
}