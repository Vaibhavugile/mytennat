// lib/screens/view_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytennat/widgets/profile_display_widgets.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewProfileScreen extends StatefulWidget {
  final String? userId;
  // Add an optional profileDocumentId to allow direct linking to a specific sub-profile
  final String? profileDocumentId; // NEW

  const ViewProfileScreen({super.key, this.userId, this.profileDocumentId}); // MODIFIED

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  dynamic _userProfile;
  String? _userType;
  bool _isLoading = true;
  String? _errorMessage;

  List<FlatListingProfile> _flatListingProfiles = [];
  List<SeekingFlatmateProfile> _seekingFlatmateProfiles = [];
  String? _currentDisplayProfileId;

  static const String _lastSelectedProfileKey = 'lastSelectedProfileId_';

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
      _flatListingProfiles = [];
      _seekingFlatmateProfiles = [];
      _currentDisplayProfileId = null;
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? targetUserId = widget.userId ?? currentUser?.uid;

    print('[_fetchUserProfile] Target User ID: $targetUserId');

    if (targetUserId == null) {
      setState(() {
        _errorMessage = 'User ID not available. Please log in or provide a user ID.';
        _isLoading = false;
      });
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);

      final flatListingsSnapshot = await userDocRef.collection('flatListings').get();
      _flatListingProfiles = flatListingsSnapshot.docs
          .map((doc) => FlatListingProfile.fromMap(doc.data(), doc.id))
          .toList();
      print('[_fetchUserProfile] Fetched Flat Listing Profiles: ${_flatListingProfiles.length}');
      for (var p in _flatListingProfiles) {
        print('  - Flat Listing ID: ${p.documentId}, Owner Name: ${p.ownerName}');
      }

      final seekingFlatmateProfilesSnapshot = await userDocRef.collection('seekingFlatmateProfiles').get();
      _seekingFlatmateProfiles = seekingFlatmateProfilesSnapshot.docs
          .map((doc) => SeekingFlatmateProfile.fromMap(doc.data(), doc.id))
          .toList();
      print('[_fetchUserProfile] Fetched Seeking Flatmate Profiles: ${_seekingFlatmateProfiles.length}');
      for (var p in _seekingFlatmateProfiles) {
        print('  - Seeking Flatmate ID: ${p.documentId}, Name: ${p.name}');
      }

      // --- Logic to prioritize displaying the specific profileDocumentId if provided ---
      bool profileFoundAndSet = false;
      if (widget.profileDocumentId != null) { // NEW: Check if profileDocumentId is provided
        print('[_fetchUserProfile] Specific profileDocumentId provided: ${widget.profileDocumentId}');
        try {
          final foundFlatListing = _flatListingProfiles.firstWhere(
                  (p) => p.documentId == widget.profileDocumentId,
              orElse: () => throw Exception('Not found'));
          _userProfile = foundFlatListing;
          _userType = 'flat_listing';
          _currentDisplayProfileId = widget.profileDocumentId;
          profileFoundAndSet = true;
          print('[_fetchUserProfile] Set initial display to provided Flat Listing ID: $_currentDisplayProfileId');
        } catch (_) {
          try {
            final foundSeekingFlatmate = _seekingFlatmateProfiles.firstWhere(
                    (p) => p.documentId == widget.profileDocumentId,
                orElse: () => throw Exception('Not found'));
            _userProfile = foundSeekingFlatmate;
            _userType = 'seeking_flatmate';
            _currentDisplayProfileId = widget.profileDocumentId;
            profileFoundAndSet = true;
            print('[_fetchUserProfile] Set initial display to provided Seeking Flatmate ID: $_currentDisplayProfileId');
          } catch (__) {
            print('[_fetchUserProfile] Provided profileDocumentId not found in fetched profiles.');
          }
        }
      }

      // --- Original logic to load last selected profile from SharedPreferences (if no specific ID provided) ---
      if (!profileFoundAndSet && currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        final lastSelectedId = prefs.getString(_lastSelectedProfileKey + currentUser.uid);
        print('[_fetchUserProfile] Last selected profile ID from preferences: $lastSelectedId');

        if (lastSelectedId != null) {
          try {
            final foundFlatListing = _flatListingProfiles.firstWhere(
                    (p) => p.documentId == lastSelectedId,
                orElse: () => throw Exception('Not found'));
            _userProfile = foundFlatListing;
            _userType = 'flat_listing';
            _currentDisplayProfileId = lastSelectedId;
            profileFoundAndSet = true;
            print('[_fetchUserProfile] Set initial display to last selected Flat Listing: $_currentDisplayProfileId');
          } catch (_) {
            try {
              final foundSeekingFlatmate = _seekingFlatmateProfiles.firstWhere(
                      (p) => p.documentId == lastSelectedId,
                  orElse: () => throw Exception('Not found'));
              _userProfile = foundSeekingFlatmate;
              _userType = 'seeking_flatmate';
              _currentDisplayProfileId = lastSelectedId;
              profileFoundAndSet = true;
              print('[_fetchUserProfile] Set initial display to last selected Seeking Flatmate: $_currentDisplayProfileId');
            } catch (__) {
              print('[_fetchUserProfile] Last selected profile ID not found in fetched profiles (or was invalid).');
            }
          }
        }
      }

      // If no specific profile or last selected profile was found, default to first available
      if (!profileFoundAndSet) {
        if (_flatListingProfiles.isNotEmpty) {
          _userProfile = _flatListingProfiles.first;
          _userType = 'flat_listing';
          _currentDisplayProfileId = _flatListingProfiles.first.documentId;
          print('[_fetchUserProfile] Default initial display: First Flat Listing - ID: $_currentDisplayProfileId');
        } else if (_seekingFlatmateProfiles.isNotEmpty) {
          _userProfile = _seekingFlatmateProfiles.first;
          _userType = 'seeking_flatmate';
          _currentDisplayProfileId = _seekingFlatmateProfiles.first.documentId;
          print('[_fetchUserProfile] Default initial display: First Seeking Flatmate - ID: $_currentDisplayProfileId');
        } else {
          _errorMessage = 'No profile found for user ID: $targetUserId. Profile might be incomplete or not created.';
          print('[_fetchUserProfile] Error: $_errorMessage');
        }
      }
    } catch (e) {
      _errorMessage = 'Error fetching profile for $targetUserId: ${e.toString()}';
      print('[_fetchUserProfile] Error fetching profile for $targetUserId: $e');
    } finally {
      setState(() {
        _isLoading = false;
        print('[_fetchUserProfile] Loading complete. _userType: $_userType, _currentDisplayProfileId: $_currentDisplayProfileId');
      });
    }
  }

  void _switchProfile(String profileIdentifier) async {
    print('[_switchProfile] Attempting to switch to: $profileIdentifier');
    setState(() {
      _isLoading = true;
    });

    String profileType;
    String profileId;

    if (profileIdentifier.startsWith('flat_listing_')) {
      profileType = 'flat_listing';
      profileId = profileIdentifier.substring('flat_listing_'.length);
    } else if (profileIdentifier.startsWith('seeking_flatmate_')) {
      profileType = 'seeking_flatmate';
      profileId = profileIdentifier.substring('seeking_flatmate_'.length);
    } else {
      print('[_switchProfile] Invalid profile identifier format: $profileIdentifier');
      setState(() {
        _errorMessage = 'Invalid profile selection.';
        _isLoading = false;
      });
      return;
    }

    print('[_switchProfile] Parsed - Type: $profileType, ID: $profileId');

    try {
      dynamic selectedProfile;
      if (profileType == 'flat_listing') {
        selectedProfile = _flatListingProfiles.firstWhere((p) => p.documentId == profileId);
        _userType = 'flat_listing';
      } else if (profileType == 'seeking_flatmate') {
        selectedProfile = _seekingFlatmateProfiles.firstWhere((p) => p.documentId == profileId);
        _userType = 'seeking_flatmate';
      }

      if (selectedProfile != null) {
        _userProfile = selectedProfile;
        _currentDisplayProfileId = profileId;

        final prefs = await SharedPreferences.getInstance();
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await prefs.setString(_lastSelectedProfileKey + currentUser.uid, profileId);
          print('[_switchProfile] Saved last selected profile ID: $profileId for user ${currentUser.uid}');
        }
        print('[_switchProfile] Switched to $profileType - ID: $_currentDisplayProfileId');
      } else {
        throw Exception('Profile not found after parsing.');
      }

      _errorMessage = null;
    } catch (e) {
      print('[_switchProfile] Error finding or setting profile with ID $profileId and type $profileType: $e');
      _errorMessage = 'Could not find the selected profile. It might have been deleted.';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[build] Rebuilding ViewProfileScreen. IsLoading: $_isLoading, Error: $_errorMessage, UserType: $_userType');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId == null ? 'My Profile' : 'User Profile', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.userId == null && (_flatListingProfiles.isNotEmpty || _seekingFlatmateProfiles.isNotEmpty))
            PopupMenuButton<String>(
              onSelected: _switchProfile,
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<String>> items = [];

                if (_flatListingProfiles.isNotEmpty) {
                  items.add(
                    const PopupMenuItem<String>(
                      enabled: false,
                      child: Text('Flat Listing Profiles', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                  for (var profile in _flatListingProfiles) {
                    final String displayName = (profile.ownerName != null && profile.ownerName.isNotEmpty)
                        ? profile.ownerName
                        : 'Flat Listing (${profile.documentId.substring(0, 4)}...)';
                    items.add(
                      PopupMenuItem<String>(
                        value: 'flat_listing_${profile.documentId}',
                        child: Text(displayName),
                      ),
                    );
                  }
                }

                if (_seekingFlatmateProfiles.isNotEmpty) {
                  items.add(
                    const PopupMenuItem<String>(
                      enabled: false,
                      child: Text('Seeking Flatmate Profiles', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                  for (var profile in _seekingFlatmateProfiles) {
                    final String displayName = (profile.name != null && profile.name.isNotEmpty)
                        ? profile.name
                        : 'Seeking Flatmate (${profile.documentId.substring(0, 4)}...)';
                    items.add(
                      PopupMenuItem<String>(
                        value: 'seeking_flatmate_${profile.documentId}',
                        child: Text(displayName),
                      ),
                    );
                  }
                }
                print('[build] PopupMenuButton items generated. Total items: ${items.length}');
                return items;
              },
              icon: const Icon(Icons.swap_horiz, color: Colors.white),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      )
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              ElevatedButton(
                onPressed: _fetchUserProfile,
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
          : _userProfile == null
          ? const Center(
        child: Text(
          'No profile data available. This user might not have completed their profile.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : _userType == 'seeking_flatmate'
          ? SeekingFlatmateProfileDisplay(profile: _userProfile as SeekingFlatmateProfile)
          : FlatListingProfileDisplay(profile: _userProfile as FlatListingProfile),
    );
  }
}