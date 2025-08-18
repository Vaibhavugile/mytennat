// File: complete_user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/data/user_profile.dart';
import 'package:mytennat/screens/home_page.dart';
import 'package:mytennat/screens/verification_screen.dart'; // Import the new verification screen

class CompleteUserProfileScreen extends StatefulWidget {
  const CompleteUserProfileScreen({Key? key}) : super(key: key);

  @override
  _CompleteUserProfileScreenState createState() => _CompleteUserProfileScreenState();
}

class _CompleteUserProfileScreenState extends State<CompleteUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _occupation;
  String? _religion;
  String? _smokingHabit;
  String? _drinkingHabit;
  String? _foodPreference;
  String? _cleanlinessLevel;
  String? _socialPreferences;
  String? _petOwnership;
  String? _petTolerance;
  String? _guestsFrequency;
  String? _bio;

  final List<String> _occupationOptions = [
    'Student',
    'Engineer',
    'Doctor',
    'Artist',
    'Teacher',
    'IT Professional',
    'Freelancer',
    'Marketing',
    'Other',
  ];

  final List<String> _religionOptions = [
    'Christianity',
    'Islam',
    'Hinduism',
    'Buddhism',
    'Sikhism',
    'Judaism',
    'Agnostic',
    'Atheist',
    'Other',
  ];

  bool _isLoading = false;
  UserProfile? _currentUserProfile;
  double _completionPercentage = 0.0;
  final double _initialPercentage = 25.0;
  final double _maxPercentage = 90.0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _currentUserProfile = UserProfile.fromMap(doc.data() as Map<String, dynamic>, user.uid);
          _prefillData();
        }
      } catch (e) {
        print("Error loading user profile: $e");
      }
    }
  }

  void _prefillData() {
    if (_currentUserProfile != null) {
      setState(() {
        _occupation = _currentUserProfile!.occupation;
        _religion = _currentUserProfile!.religion;
        _bio = _currentUserProfile!.bio;
        _smokingHabit = _currentUserProfile!.smokingHabit;
        _drinkingHabit = _currentUserProfile!.drinkingHabit;
        _foodPreference = _currentUserProfile!.foodPreference;
        _cleanlinessLevel = _currentUserProfile!.cleanlinessLevel;
        _socialPreferences = _currentUserProfile!.socialPreferences;
        _petOwnership = _currentUserProfile!.petOwnership;
        _petTolerance = _currentUserProfile!.petTolerance;
        _guestsFrequency = _currentUserProfile!.guestsFrequency;
      });
      _calculateAndSetCompletionPercentage();
    }
  }

  void _calculateAndSetCompletionPercentage() {
    final List<dynamic?> completeProfileFields = [
      _occupation,
      _religion,
      _smokingHabit,
      _drinkingHabit,
      _foodPreference,
      _cleanlinessLevel,
      _socialPreferences,
      _petOwnership,
      _petTolerance,
      _guestsFrequency,
      _bio,
    ];

    final double totalFieldsOnThisPage = completeProfileFields.length.toDouble();
    int completedFieldsOnThisPage = 0;

    for (var field in completeProfileFields) {
      if (field != null && field.toString().isNotEmpty) {
        completedFieldsOnThisPage++;
      }
    }

    final double percentageIncrease = _maxPercentage - _initialPercentage;
    final double percentagePerField = percentageIncrease / totalFieldsOnThisPage;

    setState(() {
      _completionPercentage = _initialPercentage + (completedFieldsOnThisPage * percentagePerField);
    });
  }

  Future<void> _saveCompleteProfile() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    form.save();

    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final Map<String, dynamic> data = {
        'occupation': _occupation,
        'religion': _religion,
        'bio': _bio,
        'smokingHabit': _smokingHabit,
        'drinkingHabit': _drinkingHabit,
        'foodPreference': _foodPreference,
        'cleanlinessLevel': _cleanlinessLevel,
        'socialPreferences': _socialPreferences,
        'petOwnership': _petOwnership,
        'petTolerance': _petTolerance,
        'guestsFrequency': _guestsFrequency,
      };

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(data, SetOptions(merge: true));

      _calculateAndSetCompletionPercentage();

      if (_completionPercentage >= 90.0) {
        _showVerificationDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully!')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Part of the _CompleteUserProfileScreenState class

  // Part of the _CompleteUserProfileScreenState class

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 15,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurple.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.verified_user_rounded,
                    size: 60,
                    color: Color(0xFFAD1457),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Profile Almost Complete!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF6A1B9A),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Your profile is ${_completionPercentage.toStringAsFixed(0)}% complete.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _completionPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 8,
                ),
                SizedBox(height: 20),
                Text(
                  "Verify your identity to unlock all features and increase your trust score.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Color(0xFFAD1457),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Color(0xFFAD1457), width: 1),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "Skip",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [Color(0xFFAD1457), Color(0xFF6A1B9A)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => VerificationScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            "Verify Now",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complete Your Profile',
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
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                const Text(
                  'A Little More About You!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black38,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'These details will help you find the best match for your lifestyle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: _completionPercentage, end: _completionPercentage),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, double value, child) {
                    return Column(
                      children: [
                        Text(
                          'Profile Completion: ${value.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: value / 100,
                          backgroundColor: Colors.white38,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                          minHeight: 10,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildDropdownField(
                          labelText: 'Occupation',
                          value: _occupation,
                          items: _occupationOptions,
                          onChanged: (val) {
                            setState(() => _occupation = val);
                            _calculateAndSetCompletionPercentage();
                          },
                          icon: Icons.work,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          labelText: 'Religion',
                          value: _religion,
                          items: _religionOptions,
                          onChanged: (val) {
                            setState(() => _religion = val);
                            _calculateAndSetCompletionPercentage();
                          },
                          icon: Icons.favorite,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          labelText: 'Smoking Habit',
                          value: _smokingHabit,
                          items: ['Socially', 'Never', 'Occasionally', 'Regularly'],
                          onChanged: (val) {
                            setState(() => _smokingHabit = val);
                            _calculateAndSetCompletionPercentage();
                          },
                          icon: Icons.smoke_free,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          labelText: 'Drinking Habit',
                          value: _drinkingHabit,
                          items: ['Socially', 'Never', 'Occasionally', 'Regularly'],
                          onChanged: (val) {
                            setState(() => _drinkingHabit = val);
                            _calculateAndSetCompletionPercentage();
                          },
                          icon: Icons.local_bar,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          labelText: 'Food Preference',
                          value: _foodPreference,
                          items: ['Veg', 'Non-Veg', 'Both'],
                          onChanged: (val) {
                            setState(() => _foodPreference = val);
                            _calculateAndSetCompletionPercentage();
                          },
                          icon: Icons.fastfood,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          labelText: 'Cleanliness Level',
                          value: _cleanlinessLevel,
                          items: ['Very clean', 'Moderately clean', 'Not so clean'],
                          onChanged: (val) {
                            setState(() => _cleanlinessLevel = val);
                            _calculateAndSetCompletionPercentage();
                          },
                          icon: Icons.cleaning_services,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          labelText: 'Social Preferences',
                          value: _socialPreferences,
                          items: ['Extrovert', 'Introvert', 'Both'],
                          onChanged: (val) {
                            setState(() => _socialPreferences = val);
                            _calculateAndSetCompletionPercentage();
                          },
                          icon: Icons.people,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          labelText: 'Pet Ownership',
                          value: _petOwnership,
                          items: ['Yes', 'No'],
                          onChanged: (val) {
                            setState(() => _petOwnership = val);
                            _calculateAndSetCompletionPercentage();
                          },
                          icon: Icons.pets,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          labelText: 'Pet Tolerance',
                          value: _petTolerance,
                          items: ['Yes', 'No', 'Sometimes'],
                          onChanged: (val) {
                            setState(() => _petTolerance = val);
                            _calculateAndSetCompletionPercentage();
                          },
                          icon: Icons.pets_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          labelText: 'Guests Frequency',
                          value: _guestsFrequency,
                          items: ['Never', 'Rarely', 'Sometimes', 'Frequently'],
                          onChanged: (val) {
                            setState(() => _guestsFrequency = val);
                            _calculateAndSetCompletionPercentage();
                          },
                          icon: Icons.group,
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          label: 'Short Bio',
                          icon: Icons.description,
                          initialValue: _bio,
                          maxLines: 4,
                          onSaved: (value) {
                            _bio = value;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveCompleteProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFAD1457),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 8,
                              shadowColor: const Color(0xFFAD1457).withOpacity(0.6),
                            ),
                            child: const Text(
                              'Save & Continue',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required IconData icon,
    String? initialValue,
    int maxLines = 1,
    required FormFieldSetter<String> onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple[300]),
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      onSaved: onSaved,
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.deepPurple[300]),
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('Select an option'),
        ),
        ...items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ],
      onChanged: onChanged,
      onSaved: (val) {
        // This onSaved callback ensures the value is set before saving
        if (labelText == 'Smoking Habit') {
          _smokingHabit = val;
        } else if (labelText == 'Drinking Habit') {
          _drinkingHabit = val;
        } else if (labelText == 'Food Preference') {
          _foodPreference = val;
        } else if (labelText == 'Cleanliness Level') {
          _cleanlinessLevel = val;
        } else if (labelText == 'Social Preferences') {
          _socialPreferences = val;
        } else if (labelText == 'Pet Ownership') {
          _petOwnership = val;
        } else if (labelText == 'Pet Tolerance') {
          _petTolerance = val;
        } else if (labelText == 'Guests Frequency') {
          _guestsFrequency = val;
        } else if (labelText == 'Occupation') {
          _occupation = val;
        } else if (labelText == 'Religion') {
          _religion = val;
        }
        _calculateAndSetCompletionPercentage();
      },
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please select a $labelText';
        }
        return null;
      },
    );
  }
}