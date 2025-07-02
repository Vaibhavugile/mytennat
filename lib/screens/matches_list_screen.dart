// screens/matches_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/chat_screen.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:rxdart/rxdart.dart';

class MatchesListScreen extends StatefulWidget {
  const MatchesListScreen({super.key,
  required this.profileType, // Make it required
  required this.profileId,   });

  final String profileType; // Add this line
  final String profileId;   // Add this line

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
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Matches'),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Please log in to view your matches.'),
        ),
      );
    }

    final Stream<QuerySnapshot> matchesAsUser1Stream = _firestore
        .collection('matches')
        .where('user1_id', isEqualTo: _currentUser!.uid)
        .snapshots();

    final Stream<QuerySnapshot> matchesAsUser2Stream = _firestore
        .collection('matches')
        .where('user2_id', isEqualTo: _currentUser!.uid)
        .snapshots();

    final combinedMatchesStream = Rx.combineLatest2(
      matchesAsUser1Stream,
      matchesAsUser2Stream,
          (QuerySnapshot user1Matches, QuerySnapshot user2Matches) {
        final List<DocumentSnapshot> allDocs = [];
        allDocs.addAll(user1Matches.docs);
        allDocs.addAll(user2Matches.docs);
        return allDocs;
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Matches'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: combinedMatchesStream,
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Matches Stream: Connection waiting...");
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Matches Stream Error: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            print("Matches Stream: Snapshot has no data despite combineLatest.");
            return const Center(child: Text('No matches yet.'));
          }

          print("Matches Stream: Snapshot hasData: ${snapshot.hasData}");
          print("Matches Stream: Raw documents received from combineLatest: ${snapshot.data!.length}");
          for (var doc in snapshot.data!) {
            print("  - Raw Doc ID: ${doc.id}, user1_id: ${doc['user1_id']}, user2_id: ${doc['user2_id']}");
          }

          final List<DocumentSnapshot> allUniqueMatches = [];
          final Set<String> processedMatchIds = {};

          for (var doc in snapshot.data!) {
            if (!processedMatchIds.contains(doc.id)) {
              allUniqueMatches.add(doc);
              processedMatchIds.add(doc.id);
            }
          }

          print("Matches Stream: Total unique matches after processing: ${allUniqueMatches.length}");

          if (allUniqueMatches.isEmpty) {
            return const Center(child: Text('No matches yet.'));
          }

          return ListView.builder(
            itemCount: allUniqueMatches.length,
            itemBuilder: (context, index) {
              final matchDoc = allUniqueMatches[index];
              final matchData = matchDoc.data() as Map<String, dynamic>;

              final String user1Id = matchData['user1_id'] ?? '';
              final String user2Id = matchData['user2_id'] ?? '';

              final String partnerId = user1Id == _currentUser!.uid ? user2Id : user1Id;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(partnerId).get(),
                builder: (context, partnerSnapshot) {
                  if (partnerSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading match...'),
                      leading: CircularProgressIndicator(),
                    );
                  }

                  if (partnerSnapshot.hasError) {
                    print("Partner Profile Error: ${partnerSnapshot.error}");
                    return ListTile(
                      title: Text('Error loading partner: ${partnerSnapshot.error}'),
                    );
                  }

                  if (!partnerSnapshot.hasData || !partnerSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final partnerProfileData = partnerSnapshot.data!.data() as Map<String, dynamic>;
                  String partnerName = '';
                  String partnerProfileImageUrl = '';

                  final String partnerUserType = partnerProfileData['userType'] ?? '';

                  if (partnerUserType == 'flat_listing') {
                    partnerName = partnerProfileData['displayName'] ?? 'Flat Owner';
                    List<dynamic>? flatImages = partnerProfileData['flatImages'];
                    if (flatImages != null && flatImages.isNotEmpty) {
                      partnerProfileImageUrl = flatImages[0]['url'] ?? '';
                    }
                  } else if (partnerUserType == 'seeking_flatmate') {
                    partnerName = partnerProfileData['displayName'] ?? 'Flatmate Seeker';
                    partnerProfileImageUrl = partnerProfileData['profilePictureUrl'] ?? '';
                  } else {
                    partnerName = 'Unknown User';
                  }

                  final String currentUid = _currentUser!.uid;
                  final List<String> sortedChatUids = [currentUid, partnerId]..sort();
                  final String chatRoomId = '${sortedChatUids[0]}_${sortedChatUids[1]}';

                  print('ChatStreamDebug: Current User ID: $currentUid');
                  print('ChatStreamDebug: Partner ID: $partnerId');
                  print('ChatStreamDebug: Calculated chatRoomId: $chatRoomId');

                  // --- NEW FutureBuilder for initial get ---
                  return FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('chats').doc(chatRoomId).get(),
                    builder: (context, initialChatSnapshot) {
                      print('InitialChatGetDebug: For chatRoomId: $chatRoomId');
                      print('InitialChatGetDebug: Connection State: ${initialChatSnapshot.connectionState}');
                      print('InitialChatGetDebug: Has Error: ${initialChatSnapshot.hasError}');

                      if (initialChatSnapshot.connectionState == ConnectionState.done) {
                        if (initialChatSnapshot.hasData) {
                          print('InitialChatGetDebug: Has Data: true');
                          print('InitialChatGetDebug: Data Exists: ${initialChatSnapshot.data!.exists}');
                          if (initialChatSnapshot.data!.exists) {
                            print('InitialChatGetDebug: Raw Initial Chat Data: ${initialChatSnapshot.data!.data()}');
                            final initialChatDocData = initialChatSnapshot.data!.data() as Map<String, dynamic>;
                            final initialLastMessage = initialChatDocData['lastMessage'] as String? ?? 'No messages yet (initial)';
                            print('InitialChatGetDebug: Initial lastMessage string: "$initialLastMessage"');
                          } else {
                            print('InitialChatGetDebug: Initial get: Data exists, but document does not exist!');
                          }
                        } else {
                          print('InitialChatGetDebug: Has Data: false (initial get)');
                        }
                      }
                      // --- END NEW FutureBuilder for initial get ---

                      return StreamBuilder<DocumentSnapshot>(
                        stream: _firestore.collection('chats').doc(chatRoomId).snapshots(),
                        builder: (context, chatSnapshot) {
                          print('ChatSnapshotDebug: For chatRoomId: $chatRoomId');
                          print('ChatSnapshotDebug: Connection State: ${chatSnapshot.connectionState}');
                          print('ChatSnapshotDebug: Has Error: ${chatSnapshot.hasError}');
                          if (chatSnapshot.hasData) {
                            print('ChatSnapshotDebug: Has Data: true');
                            print('ChatSnapshotDebug: Data Exists: ${chatSnapshot.data!.exists}');
                            if (chatSnapshot.data!.exists) {
                              print('ChatSnapshotDebug: Raw Chat Data: ${chatSnapshot.data!.data()}');
                            } else {
                              print('ChatSnapshotDebug: Data exists, but document does not exist!');
                            }
                          } else {
                            print('ChatSnapshotDebug: Has Data: false');
                          }

                          if (chatSnapshot.connectionState == ConnectionState.waiting) {
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: partnerProfileImageUrl.isNotEmpty
                                      ? NetworkImage(partnerProfileImageUrl)
                                      : null,
                                  child: partnerProfileImageUrl.isEmpty
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                  backgroundColor: Colors.grey[300],
                                ),
                                title: Text(partnerName),
                                subtitle: const Text('Loading chat info...'),
                              ),
                            );
                          }

                          if (chatSnapshot.hasError) {
                            print("Chat Stream Error for chatRoomId $chatRoomId: ${chatSnapshot.error}");
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                title: Text(partnerName),
                                subtitle: Text('Chat error: ${chatSnapshot.error}'),
                              ),
                            );
                          }

                          final bool chatExists = chatSnapshot.hasData && chatSnapshot.data!.exists;
                          final chatDocData = chatExists ? chatSnapshot.data!.data() as Map<String, dynamic> : null;
                          final lastMessage = chatDocData?['lastMessage'] as String? ?? 'No messages yet';

                          print('ChatSnapshotDebug: Final lastMessage string: "$lastMessage"');

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 4,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      chatPartnerId: partnerId,
                                      chatPartnerName: partnerName,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: partnerProfileImageUrl.isNotEmpty
                                          ? NetworkImage(partnerProfileImageUrl)
                                          : null,
                                      child: partnerProfileImageUrl.isEmpty
                                          ? const Icon(Icons.person, size: 30, color: Colors.white)
                                          : null,
                                      backgroundColor: Colors.grey[300],
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            partnerName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            lastMessage,
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                                  ],
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
          );
        },
      ),
    );
  }
}