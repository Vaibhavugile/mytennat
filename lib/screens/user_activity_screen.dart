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

class _UserActivityScreenState extends State<UserActivityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = true;

  // Data structures to hold aggregated information
  // key: userProfileId, value: parsedProfileObject (FlatListingProfile or SeekingFlatmateProfile)
  final Map<String, dynamic> _userProfiles = {};
  // key: userProfileId (of current user), value: list of profiles that liked it
  final Map<String, List<dynamic>> _incomingLikes = {};
  // key: userProfileId (of current user), value: list of profiles it liked
  final Map<String, List<dynamic>> _outgoingLikes = {};
  // key: userProfileId (of current user), value: list of matched profiles with chatRoomId
  final Map<String, List<Map<String, dynamic>>> _matches = {};

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    print('initState: _currentUser is ${_currentUser != null ? _currentUser!.uid : 'null'}'); // Print
    if (_currentUser == null) {
      // Handle not logged in, maybe navigate to login screen
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // You might want to show a message or navigate away
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
    });

    try {
      final String currentUserId = _currentUser!.uid;
      print('Fetching activities for current user ID: $currentUserId'); // Print

      // 1. Fetch all of the current user's profiles
      print('Fetching all user profiles...'); // Print
      await _fetchAllUserProfiles(currentUserId);
      print('Fetched user profiles: ${_userProfiles.keys.length} profiles found.'); // Print

      // 2. Fetch incoming likes for each of the user's profiles
      print('Fetching incoming likes...'); // Print
      await _fetchIncomingLikes(currentUserId);
      print('Incoming likes processed. Total entries: ${_incomingLikes.keys.length}'); // Print

      // 3. Fetch outgoing likes from each of the user's profiles
      print('Fetching outgoing likes...'); // Print
      await _fetchOutgoingLikes(currentUserId);
      print('Outgoing likes processed. Total entries: ${_outgoingLikes.keys.length}'); // Print

      // 4. Fetch matches involving any of the user's profiles
      print('Fetching matches...'); // Print
      await _fetchMatches(currentUserId);
      print('Matches processed. Total entries: ${_matches.keys.length}'); // Print

    } catch (e) {
      print('Error fetching user activities: $e'); // Original error print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load activities: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('Finished fetching user activities. Is loading: $_isLoading'); // Print
    }
  }

  Future<void> _fetchAllUserProfiles(String userId) async {
    _userProfiles.clear();
    print('fetchAllUserProfiles: Clearing existing profiles.'); // Print

    // Fetch Flat Listings
    print('fetchAllUserProfiles: Fetching flatListings for $userId'); // Print
    QuerySnapshot flatListings = await _firestore
        .collection('users')
        .doc(userId)
        .collection('flatListings')
        .get();
    print('fetchAllUserProfiles: Found ${flatListings.docs.length} flatListings.'); // Print
    for (var doc in flatListings.docs) {
      _userProfiles[doc.id] = FlatListingProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      print('fetchAllUserProfiles: Added FlatListing ${doc.id}'); // Print
    }

    // Fetch Seeking Flatmate Profiles
    print('fetchAllUserProfiles: Fetching seekingFlatmateProfiles for $userId'); // Print
    QuerySnapshot seekingFlatmateProfiles = await _firestore
        .collection('users')
        .doc(userId)
        .collection('seekingFlatmateProfiles')
        .get();
    print('fetchAllUserProfiles: Found ${seekingFlatmateProfiles.docs.length} seekingFlatmateProfiles.'); // Print
    for (var doc in seekingFlatmateProfiles.docs) {
      _userProfiles[doc.id] = SeekingFlatmateProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      print('fetchAllUserProfiles: Added SeekingFlatmateProfile ${doc.id}'); // Print
    }
  }

  Future<void> _fetchIncomingLikes(String userId) async {
    _incomingLikes.clear();
    print('fetchIncomingLikes: Clearing existing incoming likes.'); // Print
    for (var userProfileId in _userProfiles.keys) {
      print('fetchIncomingLikes: Querying collectionGroup "likes" for userProfileId: $userProfileId (likedUserId: $userId)'); // Print
      // Query 'likes' subcollections across all users where this specific profile was liked
      QuerySnapshot incomingLikesSnapshot = await _firestore.collectionGroup('likes')
          .where('likedUserId', isEqualTo: userId)
          .where('likedProfileDocumentId', isEqualTo: userProfileId)
          .get();
      print('fetchIncomingLikes: Found ${incomingLikesSnapshot.docs.length} incoming likes for profile $userProfileId.'); // Print

      List<dynamic> profilesThatLikedMe = [];
      for (var doc in incomingLikesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final likingUserId = data['likingUserId'];
        final likingUserProfileId = data['likingUserProfileId'];
        final likingUserProfileType = data['likingUserProfileType'];
        print('fetchIncomingLikes: Processing incoming like from likingUserId: $likingUserId, likingUserProfileId: $likingUserProfileId, type: $likingUserProfileType'); // Print

        dynamic likedByProfile;
        try {
          if (likingUserProfileType == 'flat_listing') {
            print('fetchIncomingLikes: Fetching FlatListing for $likingUserId/$likingUserProfileId'); // Print
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likingUserId)
                .collection('flatListings')
                .doc(likingUserProfileId)
                .get();
            if (otherDoc.exists) {
              likedByProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
              print('fetchIncomingLikes: FlatListing found: ${otherDoc.id}'); // Print
            } else {
              print('fetchIncomingLikes: FlatListing not found for $likingUserId/$likingUserProfileId'); // Print
            }
          } else if (likingUserProfileType == 'seeking_flatmate') {
            print('fetchIncomingLikes: Fetching SeekingFlatmateProfile for $likingUserId/$likingUserProfileId'); // Print
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likingUserId)
                .collection('seekingFlatmateProfiles')
                .doc(likingUserProfileId)
                .get();
            if (otherDoc.exists) {
              likedByProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
              print('fetchIncomingLikes: SeekingFlatmateProfile found: ${otherDoc.id}'); // Print
            } else {
              print('fetchIncomingLikes: SeekingFlatmateProfile not found for $likingUserId/$likingUserProfileId'); // Print
            }
          }
        } catch (e) {
          print("Error fetching liking profile details for incoming like: $e"); // Original error print
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
    print('fetchOutgoingLikes: Clearing existing outgoing likes.'); // Print
    for (var userProfileId in _userProfiles.keys) {
      print('fetchOutgoingLikes: Querying user_likes/${userId}/likes for likingUserProfileId: $userProfileId'); // Print
      // Query the specific user_likes/{userId}/likes subcollection
      QuerySnapshot outgoingLikesSnapshot = await _firestore.collection('user_likes')
          .doc(userId)
          .collection('likes')
          .where('likingUserProfileId', isEqualTo: userProfileId)
          .get();
      print('fetchOutgoingLikes: Found ${outgoingLikesSnapshot.docs.length} outgoing likes for profile $userProfileId.'); // Print

      List<dynamic> profilesLikedByMe = [];
      for (var doc in outgoingLikesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final likedUserId = data['likedUserId'];
        final likedProfileDocumentId = data['likedProfileDocumentId'];
        final likedUserProfileType = data['likedUserProfileType'];
        print('fetchOutgoingLikes: Processing outgoing like to likedUserId: $likedUserId, likedProfileDocumentId: $likedProfileDocumentId, type: $likedUserProfileType'); // Print

        dynamic likedProfile;
        try {
          if (likedUserProfileType == 'flat_listing') {
            print('fetchOutgoingLikes: Fetching FlatListing for $likedUserId/$likedProfileDocumentId'); // Print
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likedUserId)
                .collection('flatListings')
                .doc(likedProfileDocumentId)
                .get();
            if (otherDoc.exists) {
              likedProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
              print('fetchOutgoingLikes: FlatListing found: ${otherDoc.id}'); // Print
            } else {
              print('fetchOutgoingLikes: FlatListing not found for $likedUserId/$likedProfileDocumentId'); // Print
            }
          } else if (likedUserProfileType == 'seeking_flatmate') {
            print('fetchOutgoingLikes: Fetching SeekingFlatmateProfile for $likedUserId/$likedProfileDocumentId'); // Print
            DocumentSnapshot otherDoc = await _firestore
                .collection('users')
                .doc(likedUserId)
                .collection('seekingFlatmateProfiles')
                .doc(likedProfileDocumentId)
                .get();
            if (otherDoc.exists) {
              likedProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
              print('fetchOutgoingLikes: SeekingFlatmateProfile found: ${otherDoc.id}'); // Print
            } else {
              print('fetchOutgoingLikes: SeekingFlatmateProfile not found for $likedUserId/$likedProfileDocumentId'); // Print
            }
          }
        } catch (e) {
          print("Error fetching liked profile details for outgoing like: $e"); // Original error print
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
    print('fetchMatches: Clearing existing matches.'); // Print

    print('fetchMatches: Querying matches where user1_uid is $userId'); // Print
    QuerySnapshot matchesSnapshot1 = await _firestore.collection('matches')
        .where('user1_uid', isEqualTo: userId)
        .get();
    print('fetchMatches: Found ${matchesSnapshot1.docs.length} matches as user1.'); // Print

    print('fetchMatches: Querying matches where user2_uid is $userId'); // Print
    QuerySnapshot matchesSnapshot2 = await _firestore.collection('matches')
        .where('user2_uid', isEqualTo: userId)
        .get();
    print('fetchMatches: Found ${matchesSnapshot2.docs.length} matches as user2.'); // Print

    final allMatchDocs = {...matchesSnapshot1.docs, ...matchesSnapshot2.docs};
    print('fetchMatches: Total unique match documents: ${allMatchDocs.length}'); // Print

    for (var doc in allMatchDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final String user1Uid = data['user1_uid'];
      final String user2Uid = data['user2_uid'];
      final String user1ProfileId = data['user1_profile_id'];
      final String user2ProfileId = data['user2_profile_id'];
      final String user1ProfileType = data['user1_profile_type'];
      final String user2ProfileType = data['user2_profile_type'];
      final String chatRoomId = data['chatRoomId'];
      print('fetchMatches: Processing match document: ${doc.id}'); // Print
      print('fetchMatches: Match details - user1: $user1Uid ($user1ProfileId, $user1ProfileType), user2: $user2Uid ($user2ProfileId, $user2ProfileType), chatRoomId: $chatRoomId'); // Print

      String currentUserProfileIdInMatch;
      String otherUserUid;
      String otherUserProfileId;
      String otherUserProfileType;

      if (user1Uid == userId) {
        currentUserProfileIdInMatch = user1ProfileId;
        otherUserUid = user2Uid;
        otherUserProfileId = user2ProfileId;
        otherUserProfileType = user2ProfileType;
        print('fetchMatches: Current user is user1. Matched with user2: $otherUserUid'); // Print
      } else {
        currentUserProfileIdInMatch = user2ProfileId;
        otherUserUid = user1Uid;
        otherUserProfileId = user1ProfileId;
        otherUserProfileType = user1ProfileType;
        print('fetchMatches: Current user is user2. Matched with user1: $otherUserUid'); // Print
      }

      // Fetch the details of the other user's profile involved in the match
      dynamic otherProfile;
      try {
        if (otherUserProfileType == 'flat_listing') {
          print('fetchMatches: Fetching matched FlatListing for $otherUserUid/$otherUserProfileId'); // Print
          DocumentSnapshot otherDoc = await _firestore
              .collection('users')
              .doc(otherUserUid)
              .collection('flatListings')
              .doc(otherUserProfileId)
              .get();
          if (otherDoc.exists) {
            otherProfile = FlatListingProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            print('fetchMatches: Matched FlatListing found: ${otherDoc.id}'); // Print
          } else {
            print('fetchMatches: Matched FlatListing NOT found: $otherUserUid/$otherUserProfileId'); // Print
          }
        } else if (otherUserProfileType == 'seeking_flatmate') {
          print('fetchMatches: Fetching matched SeekingFlatmateProfile for $otherUserUid/$otherUserProfileId'); // Print
          DocumentSnapshot otherDoc = await _firestore
              .collection('users')
              .doc(otherUserUid)
              .collection('seekingFlatmateProfiles')
              .doc(otherUserProfileId)
              .get();
          if (otherDoc.exists) {
            otherProfile = SeekingFlatmateProfile.fromMap(otherDoc.data() as Map<String, dynamic>, otherDoc.id);
            print('fetchMatches: Matched SeekingFlatmateProfile found: ${otherDoc.id}'); // Print
          } else {
            print('fetchMatches: Matched SeekingFlatmateProfile NOT found: $otherUserUid/$otherUserProfileId'); // Print
          }
        }
      } catch (e) {
        print("Error fetching matched profile details: $e"); // Original error print
      }

      if (otherProfile != null) {
        if (!_matches.containsKey(currentUserProfileIdInMatch)) {
          _matches[currentUserProfileIdInMatch] = [];
          print('fetchMatches: Initializing match list for profile $currentUserProfileIdInMatch'); // Print
        }
        _matches[currentUserProfileIdInMatch]!.add({
          'profile': otherProfile,
          'chatRoomId': chatRoomId,
        });
        print('fetchMatches: Added match for profile $currentUserProfileIdInMatch: ${otherProfile.documentId}'); // Print
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Connections'),
        backgroundColor: Colors.redAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfiles.isEmpty
          ? const Center(child: Text('No profiles found for this user.'))
          : ListView(
        padding: const EdgeInsets.all(8.0),
        children: _userProfiles.entries.map((entry) {
          final String userProfileId = entry.key;
          final dynamic userProfile = entry.value;

          String userProfileDisplayName = '';
          String userProfileTypeDisplay = '';

          if (userProfile is FlatListingProfile) {
            userProfileDisplayName = userProfile.ownerName ?? 'Flat Listing';
            userProfileTypeDisplay = 'Flat Listing';
          } else if (userProfile is SeekingFlatmateProfile) {
            userProfileDisplayName = userProfile.name ?? 'Seeking Flatmate';
            userProfileTypeDisplay = 'Seeking Flatmate';
          }

          print('Building UI for Your Profile: $userProfileDisplayName ($userProfileTypeDisplay) - ID: $userProfileId'); // Print

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: ExpansionTile(
              leading: const Icon(Icons.person_outline, color: Colors.redAccent),
              title: Text(
                'Your Profile: $userProfileDisplayName ($userProfileTypeDisplay)',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              children: [
                _buildSection(
                  title: 'Who Liked This Profile',
                  profiles: _incomingLikes[userProfileId],
                  emptyMessage: 'No one has liked this profile yet.',
                  onTapProfile: (profile) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(
                      userId: profile.uid!,
                      profileDocumentId: profile.documentId!,
                    )));
                  },
                  getChatRoomId: (profile) => _findChatRoomId(userProfileId, profile.uid!, profile.documentId!),
                ),
                _buildSection(
                  title: 'Profiles Liked by This Profile',
                  profiles: _outgoingLikes[userProfileId],
                  emptyMessage: 'This profile has not liked anyone yet.',
                  onTapProfile: (profile) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(
                      userId: profile.uid!,
                      profileDocumentId: profile.documentId!,
                    )));
                  },
                  getChatRoomId: (profile) => _findChatRoomId(userProfileId, profile.uid!, profile.documentId!),
                ),
                _buildSection(
                  title: 'Matches for This Profile',
                  profiles: _matches[userProfileId]?.map((m) => m['profile']).toList(),
                  emptyMessage: 'No matches for this profile yet.',
                  onTapProfile: (profile) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(
                      userId: profile.uid!,
                      profileDocumentId: profile.documentId!,
                    )));
                  },
                  getChatRoomId: (profile) => _findChatRoomId(userProfileId, profile.uid!, profile.documentId!),
                  isMatchSection: true,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String? _findChatRoomId(String currentUserProfileId, String otherUserUid, String otherUserProfileId) {
    final List<Map<String, dynamic>>? matchesForCurrentUserProfile = _matches[currentUserProfileId];
    if (matchesForCurrentUserProfile == null) {
      print('_findChatRoomId: No matches found for current profile ID: $currentUserProfileId'); // Print
      return null;
    }

    for (var match in matchesForCurrentUserProfile) {
      final dynamic matchedProfile = match['profile'];
      if (matchedProfile != null && matchedProfile.uid == otherUserUid && matchedProfile.documentId == otherUserProfileId) {
        print('_findChatRoomId: Found chatRoomId ${match['chatRoomId']} for matched profile ${otherUserProfileId}'); // Print
        return match['chatRoomId'];
      }
    }
    print('_findChatRoomId: No chatRoomId found for current profile ID: $currentUserProfileId and other profile ID: $otherUserProfileId'); // Print
    return null;
  }

  Widget _buildSection({
    required String title,
    List<dynamic>? profiles,
    required String emptyMessage,
    required Function(dynamic profile) onTapProfile,
    required String? Function(dynamic profile) getChatRoomId,
    bool isMatchSection = false,
  }) {
    print('Building section: $title. Profiles count: ${profiles?.length ?? 0}'); // Print
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
          ),
          const SizedBox(height: 10),
          if (profiles == null || profiles.isEmpty)
            Text(emptyMessage, style: const TextStyle(color: Colors.grey))
          else
            Column(
              children: profiles.map((profile) {
                String name = '';
                if (profile is FlatListingProfile) {
                  name = profile.ownerName ?? 'Flat Listing';
                } else if (profile is SeekingFlatmateProfile) {
                  name = profile.name ?? 'Seeking Flatmate';
                } else {
                  name = 'Unknown Profile';
                }

                final chatRoomId = getChatRoomId(profile);
                final canChat = isMatchSection && chatRoomId != null;
                print('ListTile for profile: $name (ID: ${profile.documentId}), Can Chat: $canChat (chatRoomId: $chatRoomId)'); // Print

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('ID: ${profile.documentId}', style: const TextStyle(color: Colors.grey)),
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
              }).toList(),
            ),
        ],
      ),
    );
  }
}