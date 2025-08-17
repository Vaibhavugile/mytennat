import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking image
import 'dart:io'; // For File
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For uploading image
import 'package:mytennat/data/user_profile.dart'; // Import your UserProfile model
import 'package:mytennat/screens/complete_user_profile_screen.dart'; // New screen for complete profile
import 'package:mytennat/screens/home_page.dart'; // Your main home screen

class InitialProfileScreen extends StatefulWidget {
  const InitialProfileScreen({Key? key}) : super(key: key);

  @override
  _InitialProfileScreenState createState() => _InitialProfileScreenState();
}

class _InitialProfileScreenState extends State<InitialProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String _selectedGender = 'Male'; // Default gender
  File? _profileImageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profileImageFile = File(pickedFile.path);
      }
    });
  }

  Future<String?> _uploadImage(File imageFile, String uid) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('$uid.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _saveInitialProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle case where user is not logged in (shouldn't happen if redirected after login)
        print("User not logged in.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String? profileImageUrl;
      if (_profileImageFile != null) {
        profileImageUrl = await _uploadImage(_profileImageFile!, user.uid);
      }

      final userProfile = UserProfile(
        uid: user.uid,
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        city: _cityController.text.trim(),
        profilePhotoUrl: profileImageUrl,
      );

      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          userProfile.toMap(),
          SetOptions(merge: true), // Use merge to avoid overwriting existing fields if any
        );

        // Show success message or navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );

        // Navigate to the "Complete Profile" or "Home" screen choice
        _showProfileCompletionDialog();
      } catch (e) {
        print("Error saving initial profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showProfileCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Created!'),
          content: const Text('Your basic profile is X% complete. Do you want to complete your profile for better matches, or skip to view available listings?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Skip to View Listings'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()), // Navigate to your HomeScreen
                );
              },
            ),
            ElevatedButton(
              child: const Text('Complete Your Profile'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CompleteUserProfileScreen()), // Navigate to the new Complete Profile screen
                );
              },
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
        title: const Text('Create Your Profile'),
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
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _profileImageFile != null
                        ? FileImage(_profileImageFile!)
                        : null,
                    child: _profileImageFile == null
                        ? Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.grey[600],
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveInitialProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit',
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
}