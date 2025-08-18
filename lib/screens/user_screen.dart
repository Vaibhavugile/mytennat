import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/data/user_profile.dart';
import 'package:mytennat/screens/complete_user_profile_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _showAdditionalData = false;
  double _completionPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        setState(() {
          _userProfile = UserProfile.fromMap(docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
          _calculateCompletionPercentage();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateCompletionPercentage() {
    if (_userProfile == null) return;

    final List<dynamic?> allProfileFields = [
      _userProfile!.name,
      _userProfile!.age,
      _userProfile!.gender,
      _userProfile!.city,
      _userProfile!.profilePhotoUrl,
      _userProfile!.occupation,
      _userProfile!.religion,
      _userProfile!.bio,
      _userProfile!.smokingHabit,
      _userProfile!.drinkingHabit,
      _userProfile!.foodPreference,
      _userProfile!.cleanlinessLevel,
      _userProfile!.socialPreferences,
      _userProfile!.petOwnership,
      _userProfile!.petTolerance,
      _userProfile!.guestsFrequency,
    ];

    final double totalFields = allProfileFields.length.toDouble();
    int completedFields = 0;

    for (var field in allProfileFields) {
      if (field != null && field.toString().isNotEmpty) {
        completedFields++;
      }
    }

    setState(() {
      _completionPercentage = (completedFields / totalFields) * 100;
    });
  }

  void _navigateToUpdateProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompleteUserProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _userProfile == null
              ? const Center(child: Text('Profile not found.', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _completionPercentage / 100),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, value, child) {
                        return SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 5,
                            backgroundColor: Colors.white38,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                          ),
                        );
                      },
                    ),
                    if (_userProfile!.profilePhotoUrl != null && _userProfile!.profilePhotoUrl!.isNotEmpty)
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(_userProfile!.profilePhotoUrl!),
                      )
                    else
                      const CircleAvatar(
                        radius: 60,
                        child: Icon(Icons.person, size: 60),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${_completionPercentage.toStringAsFixed(0)}% Complete',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _userProfile!.name ?? 'Name Not Provided',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  '${_userProfile!.age ?? 'N/A'} years old, ${_userProfile!.gender ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                Text(
                  _userProfile!.city ?? 'City Not Provided',
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                _buildActionButton(
                  label: _showAdditionalData ? 'Hide Additional Profile Data' : 'View Additional Profile Data',
                  icon: _showAdditionalData ? Icons.visibility_off : Icons.visibility,
                  onPressed: () {
                    setState(() {
                      _showAdditionalData = !_showAdditionalData;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  label: 'Update Profile',
                  icon: Icons.edit,
                  onPressed: _navigateToUpdateProfile,
                ),
                if (_showAdditionalData) ...[
                  const SizedBox(height: 30),
                  _buildProfileDetailCard(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF6A1B9A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 8,
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildProfileDetailCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Bio', _userProfile!.bio),
            _buildDetailRow('Occupation', _userProfile!.occupation),
            _buildDetailRow('Religion', _userProfile!.religion),
            _buildDetailRow('Smoking Habit', _userProfile!.smokingHabit),
            _buildDetailRow('Drinking Habit', _userProfile!.drinkingHabit),
            _buildDetailRow('Food Preference', _userProfile!.foodPreference),
            _buildDetailRow('Cleanliness Level', _userProfile!.cleanlinessLevel),
            _buildDetailRow('Social Preferences', _userProfile!.socialPreferences),
            _buildDetailRow('Pet Ownership', _userProfile!.petOwnership),
            _buildDetailRow('Pet Tolerance', _userProfile!.petTolerance),
            _buildDetailRow('Guests Frequency', _userProfile!.guestsFrequency),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}