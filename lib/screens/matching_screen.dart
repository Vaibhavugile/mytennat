// matching_screen.dart
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
        });
      });
    } else {
      _fetchUserProfile();
    }
  }

  Future<void> _fetchUserProfile() async {
    if (_currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        _userProfileType = userDoc['userType'];
        if (_userProfileType == 'flat_listing') {
          // If the current user is a flat lister, fetch seeking flatmate profiles
          await _fetchSeekingFlatmateProfiles();
        } else if (_userProfileType == 'seeking_flatmate') {
          // If the current user is seeking a flatmate, fetch flat listing profiles
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
          .where('uid', isNotEqualTo: _currentUser!.uid) // Exclude current user's profile
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
          .where('uid', isNotEqualTo: _currentUser!.uid) // Exclude current user's profile
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

  @override
  Widget build(BuildContext context) {
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
            Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              'No matching profiles found yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Try adjusting your preferences or check back later!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SingleChildScrollView(
                    child: Column( // Use a Column here to stack image and content
                      children: [
                        // Large Image Placeholder at the top
                        Container(
                          height: 250, // Increased height for a prominent image
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Icon(
                            Icons.person_outline, // Or any other suitable icon
                            size: 100, // Large icon for placeholder
                            color: Colors.grey[400],
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
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.close,
                  label: 'Pass',
                  color: Colors.red,
                  onPressed: _showNextProfile,
                ),
                _buildActionButton(
                  icon: Icons.favorite,
                  label: 'Connect',
                  color: Colors.green,
                  onPressed: () {
                    // Implement logic for "Connect" or "Like"
                    _showAlertDialog('Connect', 'You connected with this profile!', () {
                      _showNextProfile();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNextProfile() {
    setState(() {
      if (_currentIndex < _profiles.length - 1) {
        _currentIndex++;
      } else {
        _showAlertDialog('No More Profiles', 'You\'ve viewed all available profiles for now.', () {
          // Optionally, navigate to homepage or show a different state
          // Navigator.pop(context);
        });
      }
    });
  }

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
    if (profile is FlatListingProfile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and basic info now below the large image
          Text(
            profile.ownerName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            '${profile.ownerAge ?? 'N/A'} • ${profile.ownerGender}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20), // Spacing after name/age
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
              _buildCompactInfoRow(
                Icons.date_range, 'Availability Date', profile.availabilityDate != null ? DateFormat('dd/MM/yyyy').format(profile.availabilityDate!) : 'N/A',
                Icons.attach_money, 'Rent Price', profile.rentPrice?.toString() ?? 'N/A',
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
          // Name and basic info now below the large image
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            '${profile.age ?? 'N/A'} • ${profile.gender}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20), // Spacing after name/age
          _buildDetailCard('About Me', profile.bio, Icons.info_outline),
          _buildCompactInfoRow(
            Icons.work, 'Occupation', profile.occupation,
            Icons.location_city, 'Desired City', profile.desiredCity,
          ),
          _buildCompactInfoRow(
            Icons.place, 'Area Preference', profile.areaPreference,
            Icons.calendar_today, 'Move-in Date', profile.moveInDate != null ? DateFormat('dd/MM/yyyy').format(profile.moveInDate!) : 'N/A',
          ),
          _buildProfileDetailRow(Icons.money, 'Budget Range', '₹${profile.budgetMin?.toString() ?? 'N/A'} - ₹${profile.budgetMax?.toString() ?? 'N/A'}'),

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
    if (children.every((widget) => widget is SizedBox && widget.width == 0 && widget.height == 0)) {
      return const SizedBox.shrink(); // Hide the section if all its children are hidden
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
        children: children,
      ),
    );
  }
}