// lib/screens/more_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart'; // Import the display widgets
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Import FlatListingProfile model
import 'package:mytennat/screens/edit_profile_screen.dart'; // To navigate to edit profile
import 'package:mytennat/screens/selection_screen.dart'; // To navigate to select/create new profile type

class MoreProfileScreen extends StatefulWidget {
  const MoreProfileScreen({super.key});

  @override
  State<MoreProfileScreen> createState() => _MoreProfileScreenState();
}

class _MoreProfileScreenState extends State<MoreProfileScreen> {
  dynamic _userProfile; // This will hold either SeekingFlatmateProfile or FlatListingProfile
  String? _userType; // 'seeking_flat' or 'listing_flat'
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _userProfile = null;
      _userType = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = "User not logged in.";
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        _errorMessage = "Main user document not found.";
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userData = userDoc.data()!;
      _userType = userData['userType'];

      if (_userType == null || _userType!.isEmpty) {
        _errorMessage = "User type not set. Please complete your profile setup first.";
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String collectionPath = '';
      if (_userType == 'seeking_flat') {
        collectionPath = 'seekingFlatmateProfiles';
      } else if (_userType == 'listing_flat') {
        collectionPath = 'flatListings';
      } else {
        _errorMessage = "Invalid user type: $_userType";
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final profileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(collectionPath)
          .limit(1)
          .get();

      if (profileSnapshot.docs.isNotEmpty) {
        final profileData = profileSnapshot.docs.first.data();
        final profileId = profileSnapshot.docs.first.id; // Get the document ID

        if (_userType == 'seeking_flat') {
          // Corrected: Pass profileData and profileId to fromMap
          _userProfile = SeekingFlatmateProfile.fromMap(profileData, profileId);
        } else if (_userType == 'listing_flat') {
          // Corrected: Pass profileData and profileId to fromMap
          _userProfile = FlatListingProfile.fromMap(profileData, profileId);
        }
      } else {
        _errorMessage = "No active profile found for type: $_userType";
      }
    } catch (e) {
      _errorMessage = "Error loading profile: $e";
      print("Error loading profile in MoreProfileScreen: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Options'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              // Conditional buttons for profile setup
              if (_errorMessage == "Main user document not found." ||
                  _errorMessage == "User type not set. Please complete your profile setup first." ||
                  (_errorMessage!.startsWith("No active profile found for type:") && _userType != null))
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to EditProfileScreen for setup
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              initialUserType: _userType, // Pass _userType if available, else null
                              profileDocumentId: null, // No existing profile document to load
                            ),
                          ),
                        ).then((_) => _fetchUserProfile()); // Refresh after setup attempt
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Go to Profile Setup'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ElevatedButton(
                onPressed: _fetchUserProfile, // Still allow retry for other errors or re-attempts
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_userProfile != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _userProfile.imageUrls != null && _userProfile.imageUrls!.isNotEmpty
                            ? NetworkImage(_userProfile.imageUrls![0]) as ImageProvider
                            : null,
                        child: _userProfile.imageUrls == null || _userProfile.imageUrls!.isEmpty
                            ? Icon(
                          _userType == 'seeking_flat' ? Icons.person : Icons.home,
                          size: 50,
                          color: Colors.grey.shade600,
                        )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _userProfile.displayName ?? 'No Name',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _userType == 'seeking_flat' ? 'Seeking a Flat' : 'Listing a Flat',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Ensure _userType and _userProfile?.id are available
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                initialUserType: _userType,
                                profileDocumentId: _userProfile?.id, // Pass the active profile's ID
                              ),
                            ),
                          ).then((_) => _fetchUserProfile()); // Refresh data when returning
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Edit Profile'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Other options
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Account Actions',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 30, thickness: 1),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Logic to change profile type
                        // This typically involves navigating to a screen where the user can select their new type
                        // and then updating the 'userType' in the main 'users' collection.
                        // You might also need to handle creation/deletion of sub-profiles here.
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SelectionScreen()),
                        ).then((_) => _fetchUserProfile()); // Refresh data after selection
                      },
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(
                        _userType == 'seeking_flat'
                            ? 'Switch to Listing a Flat'
                            : 'Switch to Seeking a Flatmate',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        // Navigate back to login screen
                        if (mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login', // Replace with your login route name
                                (Route<dynamic> route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Optionally, delete account
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Implement account deletion logic here
                        // This is a sensitive operation and should involve re-authentication
                        // and deleting user data from Firestore and Auth.
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Delete Account'),
                              content: const Text(
                                  'Are you sure you want to delete your account? This action cannot be undone.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Delete'),
                                  onPressed: () async {
                                    try {
                                      // Get the current user *here* where it's needed
                                      final currentUser = FirebaseAuth.instance.currentUser;
                                      if (currentUser != null) {
                                        // Re-authenticate user if needed (important for security)
                                        // AuthCredential credential = EmailAuthProvider.credential(email: user.email, password: 'user_password');
                                        // await currentUser.reauthenticateWithCredential(credential);

                                        // Delete user's Firestore data first
                                        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).delete();
                                        // Then delete authentication account
                                        await currentUser.delete();

                                        if (mounted) {
                                          Navigator.of(dialogContext).pop(); // Close dialog
                                          Navigator.of(context).pushNamedAndRemoveUntil(
                                            '/login', // Replace with your login route name
                                                (Route<dynamic> route) => false,
                                          );
                                        }
                                      } else {
                                        if (mounted) {
                                          Navigator.of(dialogContext).pop(); // Close dialog
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Error: User not logged in.')),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        Navigator.of(dialogContext).pop(); // Close dialog
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error deleting account: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Button to create/switch profile type
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SelectionScreen()),
                        ).then((_) => _fetchUserProfile()); // Refresh data after selection
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(
                        _userType == 'seeking_flat'
                            ? 'List a Flat'
                            : 'Seek a Flatmate',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // You can add more options here like settings, privacy, etc.
                    // Example:
                    // ElevatedButton.icon(
                    //   onPressed: () { /* Navigate to Settings */ },
                    //   icon: const Icon(Icons.settings),
                    //   label: const Text('Settings'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.grey,
                    //     foregroundColor: Colors.white,
                    //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    //     textStyle: const TextStyle(fontSize: 18),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}