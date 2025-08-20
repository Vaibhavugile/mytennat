import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

// Assuming these models exist in your project. Adjust paths if necessary.
import 'package:mytennat/screens/chat_screen.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // FlatListingProfile
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // SeekingFlatmateProfile

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({
    super.key,
    required this.profileType, // Make it required
    required this.profileId,
  });

  final String profileType; // Add this line
  final String profileId; // Add this line

  @override
  State<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends State<MatchesListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      print("Logged in user UID in MatchesListScreen: ${_currentUser!.uid}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold( // Removed const here
        backgroundColor: Colors.white, // Consistent white background
        appBar: AppBar(
          title: const Text('Matches', style: TextStyle(color: Colors.white)),
          flexibleSpace: Container( // Removed const here
            decoration: const BoxDecoration( // BoxDecoration can be const
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)], // Deep Purple to Pink-Red
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: const Center( // Added const here for the text widget
          child: Text(
            'Please log in to view matches.',
            style: TextStyle(color: Colors.black54), // Darker text on white background
          ),
        ),
      );
    }

    final currentUserId = _currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white, // Full page background is now white
      appBar: AppBar(
        title: const Text('Matches', style: TextStyle(color: Colors.white)),
        // Apply the same gradient as PlansScreen background
        flexibleSpace: Container(
          decoration: const BoxDecoration( // BoxDecoration can be const
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)], // Deep Purple to Pink-Red
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        // Combine streams for matches and chat rooms
        stream: Rx.combineLatest2(
          _firestore
              .collection('matches')
              .where('user1_uid', isEqualTo: currentUserId)
              .snapshots(),
          _firestore
              .collection('matches')
              .where('user2_uid', isEqualTo: currentUserId)
              .snapshots(),
              (QuerySnapshot snapshot1, QuerySnapshot snapshot2) {
            return [snapshot1, snapshot2];
          },
        ),
        builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6A1B9A))); // Purple indicator on white bg
          }
          if (snapshots.hasError) {
            print('Matches Stream Error: ${snapshots.error}');
            return Center(child: Text('Error loading matches: ${snapshots.error}', style: const TextStyle(color: Colors.black54)));
          }

          final List<DocumentSnapshot> allMatchDocs = [];
          if (snapshots.hasData) {
            allMatchDocs.addAll(snapshots.data![0].docs);
            allMatchDocs.addAll(snapshots.data![1].docs);
          }

          // Use a map to store unique match IDs to avoid duplicates if a match appears in both user1_uid and user2_uid queries
          final Map<String, DocumentSnapshot> uniqueMatchesMap = {};
          for (var doc in allMatchDocs) {
            // A match is unique by its combination of user1_uid and user2_uid, regardless of query direction.
            // Create a consistent key for unique identification
            String key;
            String user1 = doc['user1_uid'];
            String user2 = doc['user2_uid'];
            if (user1.compareTo(user2) < 0) { // Ensures consistent ordering for key
              key = '${user1}_${user2}';
            } else {
              key = '${user2}_${user1}';
            }
            if (!uniqueMatchesMap.containsKey(key)) {
              uniqueMatchesMap[key] = doc;
            }
          }
          final List<DocumentSnapshot> uniqueMatches = uniqueMatchesMap.values.toList();


          print('Matches Stream: Snapshot hasData: ${snapshots.hasData}');
          print('Matches Stream: Raw documents received from combineLatest: ${allMatchDocs.length}');
          for (var doc in allMatchDocs) {
            print('  - Raw Doc ID: ${doc.id}, user1_uid: ${doc['user1_uid']}, user2_uid: ${doc['user2_uid']}');
          }
          print('Matches Stream: Total unique matches after processing: ${uniqueMatches.length}');


          if (uniqueMatches.isEmpty) {
            return const Center(
              child: Text(
                'No matches yet. Keep swiping to find your ideal match!',
                style: TextStyle(fontSize: 16, color: Colors.grey), // Grey text on white background
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: uniqueMatches.length,
            itemBuilder: (context, index) {
              final matchDoc = uniqueMatches[index];
              final matchData = matchDoc.data() as Map<String, dynamic>;

              final partnerId = (matchData['user1_uid'] == currentUserId)
                  ? matchData['user2_uid']
                  : matchData['user1_uid'];

              // Extract partner's specific profile ID and type from the match document
              final partnerProfileId = (matchData['user1_uid'] == currentUserId)
                  ? matchData['user2_profile_id']
                  : matchData['user1_profile_id'];

              final partnerProfileType = (matchData['user1_uid'] == currentUserId)
                  ? matchData['user2_profile_type']
                  : matchData['user1_profile_type'];

              final chatRoomId = matchData['chatRoomId'] as String?;

              if (partnerProfileId == null || partnerProfileType == null) {
                print('Error: Partner profile ID or type is null for match ${matchDoc.id}');
                return const SizedBox.shrink(); // Hide problematic matches
              }

              // Use FutureBuilder to fetch the partner's specific profile data from the subcollection
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore
                    .collection('users')
                    .doc(partnerId)
                    .collection(partnerProfileType == 'flat_listing' ? 'flatListings' : 'seekingFlatmateProfiles')
                    .doc(partnerProfileId)
                    .get(),
                builder: (context, partnerProfileSnapshot) {
                  if (partnerProfileSnapshot.connectionState == ConnectionState.waiting) {
                    return Card( // Maintain card structure while loading
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        child: const ListTile(
                          title: Text('Loading partner profile...', style: TextStyle(color: Colors.white)),
                          subtitle: LinearProgressIndicator(color: Colors.white70), // White progress bar
                        ),
                      ),
                    );
                  }
                  if (partnerProfileSnapshot.hasError) {
                    print('Partner Profile Error: ${partnerProfileSnapshot.error}');
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        child: ListTile(
                          title: const Text('Error loading partner profile', style: TextStyle(color: Colors.white)),
                          subtitle: Text('Could not fetch details for this match: ${partnerProfileSnapshot.error}', style: const TextStyle(color: Colors.white70)),
                        ),
                      ),
                    );
                  }
                  if (!partnerProfileSnapshot.hasData || !partnerProfileSnapshot.data!.exists) {
                    print('Partner Profile not found for UID: $partnerId, ProfileID: $partnerProfileId, Type: $partnerProfileType');
                    return const SizedBox.shrink(); // Hide this match if profile is truly missing
                  }

                  String partnerName = 'Unknown';
                  String partnerProfileImageUrl = 'https://via.placeholder.com/150'; // Default placeholder image

                  final profileData = partnerProfileSnapshot.data!.data() as Map<String, dynamic>;

                  // Determine name and image based on profile type
                  if (partnerProfileType == 'flat_listing') {
                    final profile = FlatListingProfile.fromMap(profileData, partnerProfileId);
                    partnerName = profile.userProfile.name ?? 'Flat Owner';
                    if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty) {
                      partnerProfileImageUrl = profile.imageUrls![0];
                    }
                  } else if (partnerProfileType == 'seeking_flatmate') {
                    final profile = SeekingFlatmateProfile.fromMap(profileData, partnerProfileId);
                    partnerName = profile.userProfile.name ?? 'Flatmate Seeker';
                    if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty) {
                      partnerProfileImageUrl = profile.imageUrls![0];
                    }
                  }

                  // Conditionally show StreamBuilder only if chatRoomId is not null
                  return (chatRoomId == null)
                      ? GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chat not available for this match.')),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(partnerProfileImageUrl),
                                onBackgroundImageError: (exception, stackTrace) {
                                  print('Image loading error: $exception');
                                },
                                child: (partnerProfileImageUrl == 'https://via.placeholder.com/150')
                                    ? const Icon(Icons.person, size: 40, color: Color(0xFFAD1457))
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No Chat Found',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Tap to learn more about this match.',
                                      style: TextStyle(fontSize: 14, color: Colors.white70),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      : StreamBuilder<QuerySnapshot<Object?>>( // Specify the type for QuerySnapshot
                    stream: _firestore
                        .collection('chats')
                        .doc(chatRoomId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, chatSnapshot) {
                      String lastMessage = 'No messages yet';
                      if (chatSnapshot.hasData && chatSnapshot.data!.docs.isNotEmpty) {
                        lastMessage = chatSnapshot.data!.docs.first['content'] as String;
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatPartnerId: partnerId,
                                chatPartnerName: partnerName,
                                chatPartnerImageUrl: partnerProfileImageUrl, // Pass image URL
                                chatRoomId: chatRoomId, // Pass chatRoomId
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          clipBehavior: Clip.antiAlias, // Important for gradient to follow rounded corners
                          child: Container( // This Container will hold the gradient
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)], // Gradient for the card
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white, // White background for avatar
                                    backgroundImage: NetworkImage(partnerProfileImageUrl),
                                    onBackgroundImageError: (exception, stackTrace) {
                                      print('Image loading error: $exception');
                                    },
                                    child: (partnerProfileImageUrl == 'https://via.placeholder.com/150')
                                        ? const Icon(Icons.person, size: 40, color: Color(0xFFAD1457)) // Icon color
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          partnerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.white, // White text on gradient
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          lastMessage,
                                          style: const TextStyle(fontSize: 14, color: Colors.white70), // Lighter white
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18), // White icon
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}