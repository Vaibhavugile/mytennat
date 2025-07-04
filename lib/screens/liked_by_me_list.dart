import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // Ensure these are imported from your project
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Ensure these are imported from your project
import 'package:mytennat/screens/chat_screen.dart'; // For chat navigation
import 'package:mytennat/screens/view_profile_screen.dart'; // Add this import

class LikedByMeList extends StatefulWidget {
  final String currentUserId;

  const LikedByMeList({super.key, required this.currentUserId});

  @override
  State<LikedByMeList> createState() => _LikedByMeListState();
}

class _LikedByMeListState extends State<LikedByMeList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> _likedProfiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLikedByMeProfiles();
  }

  Future<void> _fetchLikedByMeProfiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all users that the current user has liked
      QuerySnapshot likedSnapshot = await _firestore
          .collection('user_likes')
          .doc(widget.currentUserId)
          .collection('likes')
          .get();

      List<dynamic> profiles = [];
      for (var doc in likedSnapshot.docs) {
        String likedUserId = doc.id; // The document ID here is the ID of the liked user

        // NEW: Fetch the liked user's actual profile from their subcollections
        DocumentSnapshot? userProfileDoc;
        Map<String, dynamic>? userData;
        String? userProfileId; // This will hold the actual profile document ID

        // Try to fetch from seekingFlatmateProfiles subcollection
        DocumentSnapshot seekingFlatmateProfileDoc = await _firestore
            .collection('users')
            .doc(likedUserId)
            .collection('seekingFlatmateProfiles')
            .doc(likedUserId) // Assuming profileId is the same as userId
            .get();

        if (seekingFlatmateProfileDoc.exists && seekingFlatmateProfileDoc.data() != null) {
          userProfileDoc = seekingFlatmateProfileDoc;
          userData = userProfileDoc.data() as Map<String, dynamic>;
          userProfileId = userProfileDoc.id; // Get the actual profile document ID
          profiles.add(SeekingFlatmateProfile.fromMap(userData, userProfileId));
        } else {
          // If not found, try to fetch from flatListings subcollection
          DocumentSnapshot flatListingProfileDoc = await _firestore
              .collection('users')
              .doc(likedUserId)
              .collection('flatListings')
              .doc(likedUserId) // Assuming profileId is the same as userId
              .get();

          if (flatListingProfileDoc.exists && flatListingProfileDoc.data() != null) {
            userProfileDoc = flatListingProfileDoc;
            userData = userProfileDoc.data() as Map<String, dynamic>;
            userProfileId = userProfileDoc.id; // Get the actual profile document ID
            profiles.add(FlatListingProfile.fromMap(userData, userProfileId));
          }
        }
      }

      setState(() {
        _likedProfiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching liked by me profiles: $e');
      setState(() {
        _isLoading = false;
      });
      _showAlertDialog('Error', 'Failed to load profiles you liked: $e');
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

    if (_likedProfiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              'You haven\'t liked anyone yet!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Explore profiles on the Matching screen!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _likedProfiles.length,
      itemBuilder: (context, index) {
        final profile = _likedProfiles[index];
        String name = '';
        String imageUrl = '';
        String subtitle = '';
        String profileId = profile.documentId; // This is the userId of the liked profile

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
                  final chatRoomId = (snapshot.data!.data() as Map<String, dynamic>)['chatRoomId'];
                  return ElevatedButton.icon(
                    onPressed: () {
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
                  return const Icon(Icons.favorite_border, color: Colors.redAccent);
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

  String _getMatchDocId(String user1Id, String user2Id) {
    List<String> sortedUids = [user1Id, user2Id]..sort();
    return '${sortedUids[0]}_${sortedUids[1]}';
  }
}