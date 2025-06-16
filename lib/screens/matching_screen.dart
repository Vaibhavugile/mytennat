import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // Import for FlatListingProfile
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Import for SeekingFlatmateProfile
import 'package:intl/intl.dart'; // For date formatting

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  List<dynamic> _profiles = []; // Can hold FlatListingProfile or SeekingFlatmateProfile
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _userProfileType; // 'flat_listing' or 'seeking_flatmate'

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog('Not Logged In', 'Please log in to use the matching feature.', () {
          // You might navigate to a login screen here
          Navigator.of(context).pop(); // Pop the dialog
          // Example: Navigator.of(context).pushReplacementNamed('/login');
        });
      });
      return;
    }
    _determineUserProfileTypeAndFetchProfiles();
  }

  Future<void> _determineUserProfileTypeAndFetchProfiles() async {
    final userId = _currentUser!.uid;
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch the current user's profile from the 'users' collection
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null && userDoc.data()!.containsKey('profileType')) {
        _userProfileType = userDoc.data()!['profileType'];
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAlertDialog('Profile Missing', 'Please complete your profile first to start matching.', () {
            Navigator.of(context).pop(); // Pop the dialog
            // You might navigate back to the home page or profile creation page
            // Example: Navigator.of(context).pushReplacementNamed('/home');
          });
        });
        return;
      }
      await _fetchProfiles(); // Fetch profiles once type is determined
    } catch (e) {
      print('Error determining user profile type: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog('Error', 'Failed to determine your profile. Please try again.', () {
          Navigator.of(context).pop();
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProfiles() async {
    if (_currentUser == null || _userProfileType == null) return;

    try {
      String targetProfileType;
      if (_userProfileType == 'seeking_flatmate') {
        // Current user is seeking a flatmate and flat, so show them flat listings (people with flats)
        targetProfileType = 'flat_listing';
      } else if (_userProfileType == 'flat_listing') {
        // Current user has a flat listing, so show them seeking flatmate profiles
        targetProfileType = 'seeking_flatmate';
      } else {
        _profiles = []; // Unknown profile type
        return;
      }

      final querySnapshot = await _firestore
          .collection('users') // Query the main 'users' collection
          .where('profileType', isEqualTo: targetProfileType) // Filter by the target profile type
          .where(FieldPath.documentId, isNotEqualTo: _currentUser!.uid) // Don't show own profile
          .get();

      // Dynamically instantiate profiles based on their 'profileType'
      _profiles = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final id = doc.id; // Document ID is the userId
        if (data['profileType'] == 'flat_listing') {
          return FlatListingProfile.fromMap(data, id);
        } else if (data['profileType'] == 'seeking_flatmate') {
          return SeekingFlatmateProfile.fromMap(data, id);
        }
        return null; // Should not happen if profileType is correctly set
      }).where((profile) => profile != null).toList();

      // TODO: In a real app, filter out profiles the user has already liked/disliked
      // You would fetch the 'likes' sub-collection or a separate 'interactions' collection
      // for the current user and remove those profiles from _profiles list.

    } catch (e) {
      print('Error fetching profiles: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog('Error', 'Failed to load profiles. Please try again later.', () => Navigator.of(context).pop());
      });
    } finally {
      setState(() {
        _isLoading = false;
        _currentIndex = 0; // Reset index when new profiles are fetched
      });
    }
  }

  void _likeProfile(String targetUserId) async {
    if (_currentUser == null) return;

    final currentUserUid = _currentUser!.uid;

    // Record the like in a 'likes' collection (e.g., as top-level collection)
    // Or, you could use a sub-collection for likes under each user:
    // _firestore.collection('users').doc(currentUserUid).collection('likes').doc(targetUserId).set({});
    await _firestore.collection('likes').add({
      'likerId': currentUserUid,
      'likedId': targetUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'likerProfileType': _userProfileType, // Store current user's profile type
      'likedProfileType': _userProfileType == 'seeking_flatmate' ? 'flat_listing' : 'seeking_flatmate', // Store liked profile's type
    });

    // Check for a mutual match: did the target user also like the current user?
    final querySnapshot = await _firestore
        .collection('likes')
        .where('likerId', isEqualTo: targetUserId)
        .where('likedId', isEqualTo: currentUserUid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // It's a mutual match!
      await _firestore.collection('matches').add({
        'user1Id': currentUserUid,
        'user2Id': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'user1ProfileType': _userProfileType,
        'user2ProfileType': _userProfileType == 'seeking_flatmate' ? 'flat_listing' : 'seeking_flatmate',
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlertDialog('It\'s a Match!', 'You and this person have liked each other! You can now chat.', () {
          Navigator.of(context).pop(); // Pop the dialog
          _nextProfile(); // Move to next profile
        });
      });
    } else {
      _nextProfile(); // No match yet, move to next profile
    }
  }

  void _dislikeProfile(String targetUserId) async {
    if (_currentUser == null) return;

    // Optionally record dislikes to avoid showing the same profile again
    // For now, we just move to the next profile.
    print('Disliked profile: $targetUserId');
    _nextProfile();
  }

  void _nextProfile() {
    setState(() {
      if (_currentIndex < _profiles.length - 1) {
        _currentIndex++;
      } else {
        // No more profiles
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAlertDialog('No More Profiles', 'You\'ve seen all available profiles for now!', () {
            Navigator.of(context).pop(); // Pop the dialog
            // Optionally, refetch profiles or navigate elsewhere
          });
        });
        _profiles = []; // Clear profiles after all are seen
        _currentIndex = 0;
      }
    });
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
              onPressed: onPressed,
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
      return Scaffold(
        appBar: AppBar(
          title: const Text('mytennat Matching'),
          backgroundColor: Colors.redAccent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_profiles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('mytennat Matching'),
          backgroundColor: Colors.redAccent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              const Text(
                'No profiles available at the moment.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchProfiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Refresh Profiles'),
              ),
            ],
          ),
        ),
      );
    }

    final currentProfile = _profiles[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('mytennat Matching'),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    // Check if currentProfile has a documentId before performing action
                    String? profileIdToActOn;
                    if (currentProfile is FlatListingProfile) {
                      profileIdToActOn = currentProfile.documentId;
                    } else if (currentProfile is SeekingFlatmateProfile) {
                      profileIdToActOn = currentProfile.documentId;
                    }

                    if (profileIdToActOn != null) {
                      if (details.primaryVelocity! > 0) {
                        // Swiped right (Like)
                        _likeProfile(profileIdToActOn);
                      } else if (details.primaryVelocity! < 0) {
                        // Swiped left (Dislike)
                        _dislikeProfile(profileIdToActOn);
                      }
                    } else {
                      print('Error: currentProfile.documentId is null.');
                      _nextProfile(); // Move to next to avoid being stuck
                    }
                  },
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildProfileContent(currentProfile),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'dislikeBtn',
                    onPressed: () {
                      String? profileIdToActOn;
                      if (currentProfile is FlatListingProfile) {
                        profileIdToActOn = currentProfile.documentId;
                      } else if (currentProfile is SeekingFlatmateProfile) {
                        profileIdToActOn = currentProfile.documentId;
                      }
                      if (profileIdToActOn != null) {
                        _dislikeProfile(profileIdToActOn);
                      } else {
                        print('Error: currentProfile.documentId is null for dislike.');
                        _nextProfile();
                      }
                    },
                    backgroundColor: Colors.red[100],
                    child: Icon(Icons.close, color: Colors.red[700], size: 40),
                  ),
                  FloatingActionButton(
                    heroTag: 'likeBtn',
                    onPressed: () {
                      String? profileIdToActOn;
                      if (currentProfile is FlatListingProfile) {
                        profileIdToActOn = currentProfile.documentId;
                      } else if (currentProfile is SeekingFlatmateProfile) {
                        profileIdToActOn = currentProfile.documentId;
                      }
                      if (profileIdToActOn != null) {
                        _likeProfile(profileIdToActOn);
                      } else {
                        print('Error: currentProfile.documentId is null for like.');
                        _nextProfile();
                      }
                    },
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.favorite, color: Colors.green[700], size: 40),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(dynamic profile) {
    if (profile is FlatListingProfile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            profile.ownerName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '${profile.ownerAge ?? 'N/A'} years old, ${profile.ownerOccupation}',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          const SizedBox(height: 15),
          Text(
            profile.ownerBio,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 30),
          _buildProfileDetailRow(Icons.location_on, 'Desired City:', profile.desiredCity),
          _buildProfileDetailRow(Icons.house, 'Flat Type:', profile.flatType),
          _buildProfileDetailRow(Icons.attach_money, 'Rent:', '${profile.rentPrice ?? 'N/A'} / month'),
          _buildProfileDetailRow(Icons.smoke_free, 'Smoking:', profile.smokingHabit),
          _buildProfileDetailRow(Icons.local_bar, 'Drinking:', profile.drinkingHabit),
          _buildProfileDetailRow(Icons.pets, 'Pets:', profile.petOwnership),
          _buildProfileDetailRow(Icons.clean_hands, 'Cleanliness:', profile.cleanlinessLevel),
          _buildProfileDetailRow(Icons.volume_up, 'Noise Level:', profile.noiseLevel),
          _buildProfileDetailRow(Icons.food_bank, 'Food Preference:', profile.foodPreference),
          _buildProfileDetailRow(Icons.bedtime, 'Sleeping Schedule:', profile.sleepingSchedule),
          _buildProfileDetailRow(Icons.work, 'Work Schedule:', profile.workSchedule),
          _buildProfileDetailRow(Icons.people, 'Social Preferences:', profile.socialPreferences),
          _buildProfileDetailRow(Icons.person_outline, 'Personal Space:', profile.personalSpaceVsSocialization),
          _buildProfileDetailRow(Icons.group, 'Sharing Common Spaces:', profile.sharingCommonSpaces),
          _buildProfileDetailRow(Icons.event_seat, 'Guests Policy:', profile.visitorsPolicy),
          _buildProfileDetailRow(Icons.hotel, 'Overnight Guests:', profile.guestsOvernightPolicy),
          _buildProfileDetailRow(Icons.calendar_today, 'Available From:', profile.availabilityDate != null ? DateFormat('dd/MM/yyyy').format(profile.availabilityDate!) : 'N/A'),
        ],
      );
    } else if (profile is SeekingFlatmateProfile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            profile.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '${profile.age ?? 'N/A'} years old, ${profile.occupation}',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          const SizedBox(height: 15),
          Text(
            profile.bio,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 30),
          _buildProfileDetailRow(Icons.location_on, 'Desired City:', profile.desiredCity),
          _buildProfileDetailRow(Icons.calendar_today, 'Move-in Date:', profile.moveInDate != null ? DateFormat('dd/MM/yyyy').format(profile.moveInDate!) : 'N/A'),
          _buildProfileDetailRow(Icons.attach_money, 'Budget:', '${profile.budgetMin ?? 'N/A'} - ${profile.budgetMax ?? 'N/A'} / month'),
          _buildProfileDetailRow(Icons.area_chart, 'Area Preference:', profile.areaPreference),
          _buildProfileDetailRow(Icons.smoke_free, 'Smoking:', profile.smokingHabits),
          _buildProfileDetailRow(Icons.local_bar, 'Drinking:', profile.drinkingHabits),
          _buildProfileDetailRow(Icons.pets, 'Pets:', profile.petOwnership),
          _buildProfileDetailRow(Icons.clean_hands, 'Cleanliness:', profile.cleanliness),
          _buildProfileDetailRow(Icons.volume_up, 'Noise Level:', profile.noiseLevel),
          _buildProfileDetailRow(Icons.food_bank, 'Food Preference:', profile.foodPreference),
          _buildProfileDetailRow(Icons.bedtime, 'Sleeping Schedule:', profile.sleepingSchedule),
          _buildProfileDetailRow(Icons.work, 'Work Schedule:', profile.workSchedule),
          _buildProfileDetailRow(Icons.people, 'Social Habits:', profile.socialHabits),
          _buildProfileDetailRow(Icons.person_outline, 'Personal Space:', profile.personalSpaceVsSocialization),
          _buildProfileDetailRow(Icons.group, 'Sharing Common Spaces:', profile.sharingCommonSpaces),
          _buildProfileDetailRow(Icons.event_seat, 'Guests Frequency:', profile.guestsFrequency),
          _buildProfileDetailRow(Icons.hotel, 'Visitors Policy:', profile.visitorsPolicy),
        ],
      );
    }
    return const Text('Error: Unknown Profile Type or Missing Data');
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}