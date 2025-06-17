// matching_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:mytennat/screens/chat_screen.dart'; // <--- NEW: Import your ChatScreen

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

  Future<void> _fetchUserProfile() async {
    if (_currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        _userProfileType = userDoc['userType'];
        if (_userProfileType == 'flat_listing') {
          await _fetchSeekingFlatmateProfiles();
        } else if (_userProfileType == 'seeking_flatmate') {
          await _fetchFlatListingProfiles();
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFlatListingProfiles() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users')
          .where('userType', isEqualTo: 'flat_listing')
          .where('uid', isNotEqualTo: _currentUser!.uid)
          .get();

      _profiles = querySnapshot.docs.map((doc) => FlatListingProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      setState(() {});
    } catch (e) {
      _showAlertDialog('Error', 'Failed to load flat listing profiles: $e', () {});
    }
  }

  Future<void> _fetchSeekingFlatmateProfiles() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users')
          .where('userType', isEqualTo: 'seeking_flatmate')
          .where('uid', isNotEqualTo: _currentUser!.uid)
          .get();

      _profiles = querySnapshot.docs.map((doc) => SeekingFlatmateProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      setState(() {});
    } catch (e) {
      _showAlertDialog('Error', 'Failed to load seeking flatmate profiles: $e', () {});
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

        // Remove the dismissed profile from the list
        _profiles.removeAt(_currentIndex);

        if (direction == DismissDirection.endToStart) { // Swiped left (Pass)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile Passed'))
          );
          // TODO: Optionally record the 'pass' in Firestore to avoid showing again
        } else if (direction == DismissDirection.startToEnd) { // Swiped right (Like)
          _processLike(dismissedProfileId); // Call the new like processing function
        }
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

  @override
  Widget build(BuildContext context) {
    // ... (rest of your build method remains the same) ...
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching Profiles', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.redAccent),
            SizedBox(height: 20),
            Text('Loading profiles...', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : _profiles.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Placeholder Image (add to your assets folder and pubspec.yaml)
            // Example: assets/no_profiles.png
            Image.asset(
              'assets/no_profiles.png', // <--- IMPORTANT: Replace with your image asset or remove if you don't have one
              height: 150,
              width: 150,
              color: Colors.grey[400], // Adjust color if it's a vector image
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
                // Action: e.g., navigate to edit preferences, or refresh
                // Navigator.push(context, MaterialPageRoute(builder: (context) => EditPreferencesScreen()));
                _fetchUserProfile(); // To refresh if user changed preferences externally
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Refresh / Adjust Preferences', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Dismissible(
                // Use a ValueKey with a unique identifier from the profile
                key: ValueKey(_profiles[_currentIndex].documentId),
                direction: DismissDirection.horizontal,
                onDismissed: _handleProfileDismissed, // Call the new handler
                // Enhanced Dismissible Backgrounds
                background: Container(
                  color: Colors.green.withOpacity(0.7), // Slightly transparent green
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
                  color: Colors.red.withOpacity(0.7), // Slightly transparent red
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
                          // Image carousel with Name/Age/Gender overlay
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 250,
                                  width: double.infinity,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    // Safely access imageUrls and determine itemCount
                                    itemCount: (_profiles[_currentIndex] is FlatListingProfile && (_profiles[_currentIndex] as FlatListingProfile).imageUrls != null && (_profiles[_currentIndex] as FlatListingProfile).imageUrls!.isNotEmpty)
                                        ? (_profiles[_currentIndex] as FlatListingProfile).imageUrls!.length
                                        : (_profiles[_currentIndex] is SeekingFlatmateProfile && (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls != null && (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls!.isNotEmpty)
                                        ? (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls!.length
                                        : 1, // Default to 1 if no images
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentImageIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      String? imageUrl;
                                      // Safely get imageUrl from the current profile
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

                                      // Placeholder if no image URL or an error occurs
                                      return imageUrl != null && imageUrl.isNotEmpty
                                          ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              // Fix: Correctly access expectedTotalBytes
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
                                            color: Colors.grey, // Adjusted color for visibility
                                          ),
                                        ),
                                      )
                                          : Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.person_outline,
                                          size: 100,
                                          color: Colors.grey, // Adjusted color for visibility
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Image indicators (dots)
                                Positioned(
                                  bottom: 10,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      // Safely determine the number of dots
                                      (_profiles[_currentIndex] is FlatListingProfile && (_profiles[_currentIndex] as FlatListingProfile).imageUrls != null && (_profiles[_currentIndex] as FlatListingProfile).imageUrls!.isNotEmpty)
                                          ? (_profiles[_currentIndex] as FlatListingProfile).imageUrls!.length
                                          : (_profiles[_currentIndex] is SeekingFlatmateProfile && (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls != null && (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls!.isNotEmpty)
                                          ? (_profiles[_currentIndex] as SeekingFlatmateProfile).imageUrls!.length
                                          : 1, // Default to 1 dot for placeholder
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
                                // Gradient overlay for text readability
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
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0), // Padding for the rest of the content
                            child: _buildProfileContent(_profiles[_currentIndex]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30), // This is the user's reported line 427
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.close,
                  label: 'Pass',
                  color: Colors.red,
                  onPressed: () {
                    // Simulate a swipe left (pass)
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
                    // Simulate a swipe right (like)
                    if (_profiles.isNotEmpty) {
                      _handleProfileDismissed(DismissDirection.startToEnd);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ... (rest of your helper methods: _buildActionButton, _buildProfileContent,
  // _buildProfileHeader, _buildProfileDetailRow, _buildCompactInfoRow,
  // _buildDetailCard, _buildChipList, _buildExpansionSection) ...

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
    //
    // IMPORTANT: For image carousel to work correctly,
    // FlatListingProfile and SeekingFlatmateProfile models MUST include:
    // List<String>? imageUrls;
    //
    // And their fromMap/toMap methods should handle this field.
    //
    // Example for FlatListingProfile (in flatmate_profile_screen.dart):
    // class FlatListingProfile {
    //   ...
    //   List<String>? imageUrls;
    //
    //   FlatListingProfile.fromMap(Map<String, dynamic> map, this.documentId)
    //       : imageUrls = (map['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList(), // Parse imageUrls
    //         ...;
    //
    //   Map<String, dynamic> toMap() {
    //     return {
    //       ...
    //       'imageUrls': imageUrls, // Add this line
    //       ...
    //     };
    //   }
    // }
    //
    // Similar changes for SeekingFlatmateProfile in flat_with_flatmate_profile_screen.dart.
    //

    if (profile is FlatListingProfile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and basic info are now handled in the Stack above, removed from here
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
              // Formatted Rent Price
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
          // Name and basic info are now handled in the Stack above, removed from here
          _buildDetailCard('About Me', profile.bio, Icons.info_outline),
          _buildCompactInfoRow(
            Icons.work, 'Occupation', profile.occupation,
            Icons.location_city, 'Desired City', profile.desiredCity,
          ),
          _buildCompactInfoRow(
            Icons.place, 'Area Preference', profile.areaPreference,
            Icons.calendar_today, 'Move-in Date', profile.moveInDate != null ? DateFormat('dd/MM/yyyy').format(profile.moveInDate!) : 'N/A',
          ),
          // Formatted Budget Range
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

  // Helper widget for the main profile header (name, age, gender) - now just text
  // The large image is handled directly in _buildProfileContent
  Widget _buildProfileHeader(String name, String subtitle) {
    // This helper is now largely unused as name/subtitle are part of _buildProfileContent directly
    // but kept for reference if you want to re-introduce a specific header widget.
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

  // Helper widget for individual detail rows
  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    if (value == '' || value == 'N/A' || value == '0') {
      return const SizedBox.shrink(); // Hide if value is empty or N/A or 0
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

  // Helper widget for showing two detail rows side-by-side
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
          if (show1 && show2) const SizedBox(width: 16), // Spacer between two items
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


  // Helper widget for larger text descriptions (Bio, Flat Description)
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

  // Helper widget for lists as chips
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
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
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

  // Helper for collapsible sections
  Widget _buildExpansionSection({required String title, required IconData icon, required List<Widget> children}) {
    // Filter out SizedBox.shrink from children to determine if section should be shown
    final visibleChildren = children.where((widget) => !(widget is SizedBox && widget.width == 0 && widget.height == 0)).toList();

    if (visibleChildren.isEmpty) {
      return const SizedBox.shrink(); // Hide the section if no visible children
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
        children: visibleChildren, // Pass only visible children
      ),
    );
  }
}