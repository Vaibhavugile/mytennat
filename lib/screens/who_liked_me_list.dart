import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // Ensure these are imported from your project
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Ensure these are imported from your project
import 'package:mytennat/screens/chat_screen.dart'; // For chat navigation
import 'package:mytennat/screens/view_profile_screen.dart'; // Add this import

class WhoLikedMeList extends StatefulWidget {
  final String currentUserId;

  const WhoLikedMeList({super.key, required this.currentUserId});

  @override
  State<WhoLikedMeList> createState() => _WhoLikedMeListState();
}

class _WhoLikedMeListState extends State<WhoLikedMeList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> _likingProfiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWhoLikedMeProfiles();
  }

  Future<void> _fetchWhoLikedMeProfiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Find all 'likes' documents where 'likedUserId' is the current user's ID
      // This means we are querying collections under other users' 'user_likes' document
      // and checking if they liked the current user.

      // This is a more complex query and often requires a collection group query or
      // a different data structure in Firestore if you want to scale this directly.
      // For simplicity and assuming 'user_likes' structure, we will iterate
      // through all 'users' and then check their 'likes' subcollection.
      // NOTE: This approach can be inefficient for a very large number of users.
      // A more scalable approach would be to have a 'likesReceived' subcollection
      // under each user, or use Firebase Cloud Functions to denormalize this data.

      QuerySnapshot allUsersSnapshot = await _firestore.collection('users').get();
      List<String> potentialLikerIds = allUsersSnapshot.docs.map((doc) => doc.id).toList();

      List<dynamic> profiles = [];
      for (String userId in potentialLikerIds) {
        if (userId == widget.currentUserId) continue; // Skip current user's own likes

        DocumentSnapshot likeDoc = await _firestore.collection('user_likes').doc(userId).collection('likes').doc(widget.currentUserId).get();

        if (likeDoc.exists) {
          // This user (userId) has liked the current user. Fetch their full profile.
          DocumentSnapshot userProfileDoc = await _firestore.collection('users').doc(userId).get();
          if (userProfileDoc.exists && userProfileDoc.data() != null) {
            Map<String, dynamic> userData = userProfileDoc.data() as Map<String, dynamic>;
            if (userData['userType'] == 'flat_listing') {
              // Pass the entire userData map and the document ID
              profiles.add(FlatListingProfile.fromMap(userData, userProfileDoc.id));
            } else if (userData['userType'] == 'seeking_flatmate') {
              // Pass the entire userData map and the document ID
              profiles.add(SeekingFlatmateProfile.fromMap(userData, userProfileDoc.id));
            }
          }
        }
      }

      setState(() {
        _likingProfiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching who liked me profiles: $e');
      setState(() {
        _isLoading = false;
      });
      _showAlertDialog('Error', 'Failed to load profiles who liked you: $e');
    }
  }

  void _showAlertDialog(String title, String message) {
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
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
    }

    if (_likingProfiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              'No one has liked your profile yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Make sure your profile is complete and engaging!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _likingProfiles.length,
      itemBuilder: (context, index) {
        final profile = _likingProfiles[index];
        String name = '';
        String imageUrl = '';
        String subtitle = '';
        String profileId = profile.documentId;

        if (profile is FlatListingProfile) {
          name = profile.ownerName ?? 'N/A';
          imageUrl = profile.imageUrls != null && profile.imageUrls!.isNotEmpty ? profile.imageUrls![0] : '';
          subtitle = 'Flat Listing by ${profile.ownerGender ?? 'N/A'}';
        } else if (profile is SeekingFlatmateProfile) {
          name = profile.name ?? 'N/A';
          imageUrl = profile.imageUrls != null && profile.imageUrls!.isNotEmpty ? profile.imageUrls![0] : '';
          subtitle = 'Seeking Flatmate, ${profile.gender ?? 'N/A'}';
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                  : null,
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle),
            trailing: FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('matches').doc(_getMatchDocId(widget.currentUserId, profileId)).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                  );
                }
                if (snapshot.hasData && snapshot.data!.exists) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      final chatRoomId = (snapshot.data!.data() as Map<String, dynamic>)['chatRoomId'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatPartnerId: profileId,
                            chatPartnerName: name,
                            chatRoomId: chatRoomId, // Pass existing chat room ID
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  );
                } else {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      // Logic to "like back" and potentially create a match
                      await _processLikeBack(profileId);
                      // After liking back, refresh the list to reflect potential match status
                      _fetchWhoLikedMeProfiles();
                    },
                    icon: const Icon(Icons.favorite, size: 18),
                    label: const Text('Like Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  );
                }
              },
            ),
            onTap: () {
              // NEW: Navigate to ViewProfileScreen for the tapped user
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewProfileScreen(userId: profileId),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _processLikeBack(String likedUserId) async {
    final currentUserId = widget.currentUserId;
    try {
      // Record current user's like on the other user
      await _firestore.collection('user_likes').doc(currentUserId).collection('likes').doc(likedUserId).set({
        'timestamp': FieldValue.serverTimestamp(),
        'likedUserId': likedUserId,
      });

      // Check if the other user has already liked the current user (which they must have, to be in this list)
      DocumentSnapshot otherUserLikesMe = await _firestore.collection('user_likes').doc(likedUserId).collection('likes').doc(currentUserId).get();

      if (otherUserLikesMe.exists) {
        // It's a mutual like, create a match and chat room
        await _createMatchAndChatRoom(currentUserId, likedUserId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('It\'s a MATCH! 🎉'))
          );
          _showMatchDialog(
            'It\'s a Match!',
            'You and ${profileDisplayName(likedUserId)} have liked each other! Start chatting now?',
                () {
              if (mounted) {
                Navigator.of(context).pop(); // Dismiss alert dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatPartnerId: likedUserId,
                      chatPartnerName: profileDisplayName(likedUserId),
                    ),
                  ),
                );
              }
            },
          );
        }
      }
    } catch (e) {
      print('Error processing like back: $e');
      _showAlertDialog('Error', 'Failed to process like back: $e');
    }
  }

  Future<void> _createMatchAndChatRoom(String user1Id, String user2Id) async {
    List<String> sortedUids = [user1Id, user2Id]..sort();
    String matchDocId = '${sortedUids[0]}_${sortedUids[1]}';

    try {
      DocumentSnapshot matchDoc = await _firestore.collection('matches').doc(matchDocId).get();

      if (!matchDoc.exists) {
        DocumentReference chatRef = await _firestore.collection('chats').add({
          'participants': sortedUids,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageSenderId': '',
          'lastMessageTimestamp': null,
        });
        String chatRoomId = chatRef.id;

        await _firestore.collection('matches').doc(matchDocId).set({
          'user1_id': sortedUids[0],
          'user2_id': sortedUids[1],
          'chatRoomId': chatRoomId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("ERROR during match/chat creation process in _createMatchAndChatRoom: $e");
      // Consider re-throwing or handling more gracefully
    }
  }

  String _getMatchDocId(String user1Id, String user2Id) {
    List<String> sortedUids = [user1Id, user2Id]..sort();
    return '${sortedUids[0]}_${sortedUids[1]}';
  }

  // Helper to get display name for dialog
  String profileDisplayName(String userId) {
    try {
      final matchedProfile = _likingProfiles.firstWhere((p) => p.documentId == userId);
      return matchedProfile is FlatListingProfile ? matchedProfile.ownerName : (matchedProfile as SeekingFlatmateProfile).name;
    } catch (e) {
      return 'that user';
    }
  }

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
                Navigator.of(context).pop();
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
}
