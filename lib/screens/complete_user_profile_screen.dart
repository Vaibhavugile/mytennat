import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/data/user_profile.dart'; // Import your UserProfile model
import 'package:mytennat/screens/home_page.dart'; // Your main home screen

class CompleteUserProfileScreen extends StatefulWidget {
  const CompleteUserProfileScreen({Key? key}) : super(key: key);

  @override
  _CompleteUserProfileScreenState createState() => _CompleteUserProfileScreenState();
}

class _CompleteUserProfileScreenState extends State<CompleteUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Habit controllers/variables (will need to initialize with existing user data)
  String? _smokingHabit;
  String? _drinkingHabit;
  String? _foodPreference;
  String? _cleanlinessLevel;
  String? _socialPreferences;
  String? _petOwnership;
  String? _petTolerance;
  String? _guestsFrequency;

  bool _isLoading = false;
  UserProfile? _currentUserProfile; // To pre-fill data if available

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            _currentUserProfile = UserProfile.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);

            _occupationController.text = _currentUserProfile!.occupation ?? '';
            _religionController.text = _currentUserProfile!.religion ?? '';
            _bioController.text = _currentUserProfile!.bio ?? '';

            _smokingHabit = _currentUserProfile!.smokingHabit;
            _drinkingHabit = _currentUserProfile!.drinkingHabit;
            _foodPreference = _currentUserProfile!.foodPreference;
            _cleanlinessLevel = _currentUserProfile!.cleanlinessLevel;
            _socialPreferences = _currentUserProfile!.socialPreferences;
            _petOwnership = _currentUserProfile!.petOwnership;
            _petTolerance = _currentUserProfile!.petTolerance;
            _guestsFrequency = _currentUserProfile!.guestsFrequency;
          });
        }
      } catch (e) {
        print("Error loading user profile for completion: $e");
      }
    }
  }

  Future<void> _saveCompleteProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create a map for data to update, merging with existing _currentUserProfile data
      Map<String, dynamic> updateData = {
        'occupation': _occupationController.text.trim(),
        'religion': _religionController.text.trim(),
        'bio': _bioController.text.trim(),
        'habits': {
          'smoking': _smokingHabit,
          'drinking': _drinkingHabit,
          'food': _foodPreference,
          'cleanliness': _cleanlinessLevel,
          'socialPreferences': _socialPreferences,
          'petOwnership': _petOwnership,
          'petTolerance': _petTolerance,
          'guestsFrequency': _guestsFrequency,
        }
      };

      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          updateData,
          SetOptions(merge: true), // Crucial: merge to not overwrite initial profile data
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile completion saved successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()), // Navigate to home screen after completion
        );
      } catch (e) {
        print("Error saving complete profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile completion: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Basic Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(
                  labelText: 'Occupation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your occupation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _religionController,
                decoration: const InputDecoration(
                  labelText: 'Religion',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your religion';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Tell us about yourself (Bio)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write something about yourself';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              const Text('Your Habits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildDropdownField(
                labelText: 'Smoking Habit',
                value: _smokingHabit,
                items: ['Smoker', 'Non-smoker', 'Occasionally'],
                onChanged: (value) => setState(() => _smokingHabit = value),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                labelText: 'Drinking Habit',
                value: _drinkingHabit,
                items: ['Drinker', 'Non-drinker', 'Occasionally'],
                onChanged: (value) => setState(() => _drinkingHabit = value),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                labelText: 'Food Preference',
                value: _foodPreference,
                items: ['Vegetarian', 'Non-vegetarian', 'Vegan', 'Eggetarian'],
                onChanged: (value) => setState(() => _foodPreference = value),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                labelText: 'Cleanliness Level',
                value: _cleanlinessLevel,
                items: ['Very Clean', 'Moderately Clean', 'Messy'],
                onChanged: (value) => setState(() => _cleanlinessLevel = value),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                labelText: 'Social Preferences',
                value: _socialPreferences,
                items: ['Introvert', 'Extrovert', 'Ambivert'],
                onChanged: (value) => setState(() => _socialPreferences = value),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                labelText: 'Pet Ownership',
                value: _petOwnership,
                items: ['Yes', 'No'],
                onChanged: (value) => setState(() => _petOwnership = value),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                labelText: 'Pet Tolerance',
                value: _petTolerance,
                items: ['Very Tolerant', 'Moderately Tolerant', 'Not Tolerant'],
                onChanged: (value) => setState(() => _petTolerance = value),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                labelText: 'Guests Frequency',
                value: _guestsFrequency,
                items: ['Often', 'Sometimes', 'Rarely', 'Never'],
                onChanged: (value) => setState(() => _guestsFrequency = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCompleteProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save & Continue',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please select a $labelText';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _occupationController.dispose();
    _religionController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}