import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For formatting dates

// Re-using data models from your provided files (ensure these are accessible)
// You might have these in a separate models/data_models.dart file.
// For demonstration purposes, I'm assuming they are defined or imported elsewhere.

// Data model to hold all the answers for the user seeking a flat
// class SeekingFlatmateProfile { /* ... your model definition ... */ }
// class FlatListingProfile { /* ... your model definition ... */ }


// Reusable custom widgets
class _QuestionWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Function(String) onSelected; // Corrected type
  final String? initialValue;

  const _QuestionWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected, // Corrected parameter
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16), // Added spacing
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4), // Added spacing
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0, // Added runSpacing for better multi-line wrapping
          children: options
              .map(
                (option) => ChoiceChip(
              label: Text(option),
              selected: initialValue == option,
              onSelected: (selected) {
                if (selected) {
                  onSelected(option);
                }
              },
              selectedColor: Colors.redAccent,
              labelStyle: TextStyle(
                color: initialValue == option ? Colors.white : Colors.black,
              ),
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder( // Ensure rounded corners
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
              .toList(),
        ),
        const SizedBox(height: 16), // Added spacing
      ],
    );
  }
}

class _MultiSelectQuestionWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Function(List<String>) onSelected; // Corrected type
  final List<String> initialValues;

  const _MultiSelectQuestionWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected, // Corrected parameter
    required this.initialValues,
  }) : super(key: key);

  @override
  _MultiSelectQuestionWidgetState createState() => _MultiSelectQuestionWidgetState();
}

class _MultiSelectQuestionWidgetState extends State<_MultiSelectQuestionWidget> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.from(widget.initialValues);
  }

  @override
  void didUpdateWidget(covariant _MultiSelectQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This is crucial for updating the initialValues when the parent rebuilds
    if (widget.initialValues != oldWidget.initialValues) {
      _selectedOptions = List.from(widget.initialValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16), // Added spacing
        Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4), // Added spacing
        Text(
          widget.subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0, // Added runSpacing for better multi-line wrapping
          children: widget.options
              .map(
                (option) => ChoiceChip(
              label: Text(option),
              selected: _selectedOptions.contains(option),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedOptions.add(option);
                  } else {
                    _selectedOptions.remove(option);
                  }
                  widget.onSelected(_selectedOptions);
                });
              },
              selectedColor: Colors.redAccent,
              labelStyle: TextStyle(
                color: _selectedOptions.contains(option) ? Colors.white : Colors.black,
              ),
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder( // Ensure rounded corners
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
              .toList(),
        ),
        const SizedBox(height: 16), // Added spacing
      ],
    );
  }
}


class EditProfileScreen extends StatefulWidget {
  final String? profileDocumentId; // New: Optional ID of the profile document to edit
  final String? initialUserType;   // New: Optional initial user type (e.g., 'seeking_flat' or 'listing_flat')

  const EditProfileScreen({
    Key? key,
    this.profileDocumentId,
    this.initialUserType,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  // This now represents the selected profile type for the dropdown
  String _selectedProfileType = 'Seeking a Flatmate'; // Default value
  String? _currentLoadedProfileDocId; // Stores the ID of the loaded profile for saving

  // Controllers for SeekingFlatmateProfile data
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  // late String _gender; // Managed by _QuestionWidget
  late TextEditingController _occupationController;
  late TextEditingController _currentLocationController;
  late TextEditingController _desiredCityController;
  late TextEditingController _budgetMinController;
  late TextEditingController _budgetMaxController;
  late TextEditingController _areaPreferenceController;
  late TextEditingController _bioController;
  late TextEditingController _personalityController;
  // late List<String> _interests; // Managed by _MultiSelectQuestionWidget
  // late String _flatmateGenderPreference; // Managed by _QuestionWidget
  // late String _flatmateAgePreference; // Managed by _QuestionWidget
  // late String _flatmateOccupationPreference; // Managed by _QuestionWidget
  // late List<String> _idealQualities; // Managed by _MultiSelectQuestionWidget
  // late List<String> _dealBreakers; // Managed by _MultiSelectQuestionWidget
  late TextEditingController _relationshipGoalController;
  late TextEditingController _locationPreferenceController;
  late TextEditingController _flatPreferenceController;

  // Controllers for FlatListingProfile data
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerAgeController;
  // late String _ownerGender; // Managed by _QuestionWidget
  late TextEditingController _ownerOccupationController;
  late TextEditingController _ownerBioController;
  late TextEditingController _ownerCurrentCityController;
  late TextEditingController _ownerDesiredCityController;
  late TextEditingController _ownerBudgetMinController;
  late TextEditingController _ownerBudgetMaxController;
  late TextEditingController _ownerAreaPreferenceController;
  late TextEditingController _rentPriceController;
  late TextEditingController _depositAmountController;
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _flatDescriptionController;
  // late String _preferredGender; // Managed by _QuestionWidget
  // late String _preferredAgeGroup; // Managed by _QuestionWidget
  // late String _preferredOccupation; // Managed by _QuestionWidget
  // late List<String> _preferredHabits; // Managed by _MultiSelectQuestionWidget
  // late List<String> _flatmateIdealQualities; // Managed by _MultiSelectQuestionWidget
  // late List<String> _flatmateDealBreakers; // Managed by _MultiSelectQuestionWidget

  // State variables for dropdowns and date pickers
  String _gender = '';
  DateTime? _moveInDate;

  String _cleanliness = '';
  String _socialHabits = '';
  String _workSchedule = '';
  String _noiseLevel = '';
  String _smokingHabits = '';
  String _drinkingHabits = '';
  String _foodPreference = '';
  String _guestsFrequency = '';
  String _visitorsPolicy = '';
  String _petOwnership = '';
  String _petTolerance = '';
  String _sleepingSchedule = '';
  String _sharingCommonSpaces = '';
  String _guestsPolicyOvernight = '';
  String _personalSpaceVsSocialization = '';
  List<String> _interests = [];

  String _flatmateGenderPreference = '';
  String _flatmateAgePreference = '';
  String _flatmateOccupationPreference = '';
  List<String> _idealQualities = [];
  List<String> _dealBreakers = [];

  String _furnishedUnfurnished = '';
  String _attachedBathroom = '';
  String _balcony = '';
  String _parking = '';
  String _wifi = '';


  // Flat listing specific state variables
  String _ownerGender = '';
  String _ownerSmokingHabit = '';
  String _ownerDrinkingHabit = '';
  String _ownerFoodPreference = '';
  String _ownerCleanlinessLevel = '';
  String _ownerNoiseLevel = '';
  String _ownerSocialPreferences = '';
  String _ownerVisitorsPolicy = '';
  String _ownerPetOwnership = '';
  String _ownerPetTolerance = '';
  String _ownerSleepingSchedule = '';
  String _ownerWorkSchedule = '';
  String _ownerSharingCommonSpaces = '';
  String _ownerGuestsOvernightPolicy = '';
  String _ownerPersonalSpaceVsSocialization = '';

  String _flatType = '';
  String _furnishedStatus = '';
  String _availableFor = '';
  DateTime? _availabilityDate;
  String _bathroomType = '';
  String _balconyAvailability = '';
  String _parkingAvailability = '';
  List<String> _flatAmenities = [];

  String _preferredGender = '';
  String _preferredAgeGroup = '';
  String _preferredOccupation = '';
  List<String> _preferredHabits = [];
  List<String> _flatmateIdealQualities = [];
  List<String> _flatmateDealBreakers = [];


  @override
  void initState() {
    super.initState();
    // Initialize all controllers
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _occupationController = TextEditingController();
    _currentLocationController = TextEditingController();
    _desiredCityController = TextEditingController();
    _budgetMinController = TextEditingController();
    _budgetMaxController = TextEditingController();
    _areaPreferenceController = TextEditingController();
    _bioController = TextEditingController();
    _personalityController = TextEditingController();
    _relationshipGoalController = TextEditingController();
    _locationPreferenceController = TextEditingController();
    _flatPreferenceController = TextEditingController();

    _ownerNameController = TextEditingController();
    _ownerAgeController = TextEditingController();
    _ownerOccupationController = TextEditingController();
    _ownerBioController = TextEditingController();
    _ownerCurrentCityController = TextEditingController();
    _ownerDesiredCityController = TextEditingController();
    _ownerBudgetMinController = TextEditingController();
    _ownerBudgetMaxController = TextEditingController();
    _ownerAreaPreferenceController = TextEditingController();
    _rentPriceController = TextEditingController();
    _depositAmountController = TextEditingController();
    _addressController = TextEditingController();
    _landmarkController = TextEditingController();
    _flatDescriptionController = TextEditingController();

    // Set initial profile type if passed from HomePage
    if (widget.initialUserType != null) {
      _selectedProfileType = (widget.initialUserType == 'seeking_flat') ? 'Seeking a Flatmate' : 'Listing a Flat';
    }

    _loadUserProfile();
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _currentLocationController.dispose();
    _desiredCityController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _areaPreferenceController.dispose();
    _bioController.dispose();
    _personalityController.dispose();
    _relationshipGoalController.dispose();
    _locationPreferenceController.dispose();
    _flatPreferenceController.dispose();

    _ownerNameController.dispose();
    _ownerAgeController.dispose();
    _ownerOccupationController.dispose();
    _ownerBioController.dispose();
    _ownerCurrentCityController.dispose();
    _ownerDesiredCityController.dispose();
    _ownerBudgetMinController.dispose();
    _ownerBudgetMaxController.dispose();
    _ownerAreaPreferenceController.dispose();
    _rentPriceController.dispose();
    _depositAmountController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _flatDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch the main user document to get the userType if initialUserType not provided
        if (widget.initialUserType == null) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            String userTypeFromDoc = userData['userType'] ?? 'listing_flat'; // Default to 'listing_flat' if not found
            _selectedProfileType = (userTypeFromDoc == 'seeking_flat') ? 'Seeking a Flatmate' : 'Listing a Flat';
            print("Determined user type from doc: $_selectedProfileType"); // Debugging print
          } else {
            // If main user document doesn't exist, default to 'Listing a Flat'
            _selectedProfileType = 'Listing a Flat';
            print("Main user document not found. Defaulting to: $_selectedProfileType"); // Debugging print
          }
        } else {
          print("Using initial user type from widget: $_selectedProfileType");
        }


        DocumentSnapshot? profileDoc;
        String collectionPath = (_selectedProfileType == 'Seeking a Flatmate')
            ? 'seekingFlatmateProfiles'
            : 'flatListings';

        if (widget.profileDocumentId != null && widget.profileDocumentId!.isNotEmpty) {
          // Fetch specific profile if ID is provided
          profileDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(collectionPath)
              .doc(widget.profileDocumentId)
              .get();
          print("Attempting to load specific profile: ${widget.profileDocumentId} from $collectionPath");
        } else {
          // Fallback to fetching the first document if no specific ID or ID is empty
          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection(collectionPath)
              .get();
          profileDoc = snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
          if (profileDoc != null) {
            print("No specific profile ID provided, loaded first document: ${profileDoc.id} from $collectionPath");
          } else {
            print("No profile documents found in $collectionPath.");
          }
        }

        if (profileDoc != null && profileDoc.exists) {
          final data = profileDoc.data() as Map<String, dynamic>; // Explicit cast
          print("Profile data loaded from Firestore: $data"); // Debugging print

          setState(() {
            _currentLoadedProfileDocId = profileDoc!.id; // Store the ID of the loaded profile
            print("Initial selected profile type: $_selectedProfileType"); // Debugging print

            // Load SeekingFlatmateProfile data based on the provided structure
            if (_selectedProfileType == 'Seeking a Flatmate') {
              _nameController.text = data['displayName'] ?? ''; // Map displayName to name
              _ageController.text = (data['age'] ?? '').toString();
              _gender = data['gender'] ?? '';
              _occupationController.text = data['occupation'] ?? '';
              _currentLocationController.text = data['currentCity'] ?? ''; // Map currentCity to currentLocation
              _desiredCityController.text = data['desiredCity'] ?? '';

              if (data['moveInDate'] != null) {
                // Firestore timestamp conversion
                Timestamp timestamp = data['moveInDate'];
                _moveInDate = timestamp.toDate();
              } else {
                _moveInDate = null;
              }

              _budgetMinController.text = (data['budgetMinExpected'] ?? '').toString();
              _budgetMaxController.text = (data['budgetMaxExpected'] ?? '').toString();

              // areaPreference is an array in user's data, but string in state.
              // Taking the first element, or empty if null/empty.
              List<String> preferredAreasList = List<String>.from(data['areaPreference'] ?? []);
              _areaPreferenceController.text = preferredAreasList.isNotEmpty ? preferredAreasList.first : '';

              _bioController.text = data['bio'] ?? '';

              // Habits
              Map<String, dynamic> habits = Map<String, dynamic>.from(data['habits'] ?? {});
              _cleanliness = habits['cleanliness'] ?? '';
              _socialHabits = habits['socialPreferences'] ?? ''; // Map socialPreferences to socialHabits
              _workSchedule = habits['workSchedule'] ?? '';
              _noiseLevel = habits['noiseTolerance'] ?? ''; // Map noiseTolerance to noiseLevel
              _smokingHabits = habits['smoking'] ?? ''; // Map smoking to smokingHabits
              _drinkingHabits = habits['drinking'] ?? ''; // Map drinking to drinkingHabits
              _foodPreference = habits['food'] ?? '';
              _guestsFrequency = habits['guestOvernightStays'] ?? ''; // Map guestOvernightStays to guestsFrequency
              _visitorsPolicy = habits['visitorsPolicy'] ?? '';
              _petOwnership = habits['petOwnership'] ?? '';
              _petTolerance = habits['petTolerance'] ?? '';
              _sleepingSchedule = habits['sleepingSchedule'] ?? '';
              _sharingCommonSpaces = habits['sharingCommonSpaces'] ?? '';
              _guestsPolicyOvernight = habits['guestOvernightStays'] ?? ''; // Using the same field for consistency
              _personalSpaceVsSocialization = habits['personalSpaceVsSocializing'] ?? '';

              _interests = List<String>.from(data['hobbies'] ?? []); // Map hobbies to interests
              _personalityController.text = data['personality'] ?? '';


              // Looking For Preferences
              Map<String, dynamic> lookingFor = Map<String, dynamic>.from(data['flatmatePreferences'] ?? {});
              _flatmateGenderPreference = lookingFor['preferredFlatmateGender'] ?? '';

              // Handle flatmateAgeRangeMin and Max
              int? minAge = lookingFor['flatmateAgeRangeMin'];
              int? maxAge = lookingFor['flatmateAgeRangeMax'];
              if (minAge != null && maxAge != null) {
                _flatmateAgePreference = '$minAge-$maxAge';
              } else {
                _flatmateAgePreference = '';
              }

              // flatmateOccupation is an array in user's data, but string in state.
              List<String> flatmateOccupationList = List<String>.from(lookingFor['preferredOccupation'] ?? []);
              _flatmateOccupationPreference = flatmateOccupationList.isNotEmpty ? flatmateOccupationList.first : '';

              _idealQualities = List<String>.from(lookingFor['idealQualities'] ?? []); // Map importantQualities to idealQualities
              _dealBreakers = List<String>.from(lookingFor['dealBreakers'] ?? []);
              _relationshipGoalController.text = data['relationshipGoal'] ?? '';


              // Flat Requirements
              Map<String, dynamic> flatRequirements = Map<String, dynamic>.from(data['flatRequirements'] ?? {});
              _locationPreferenceController.text = data['locationPreference'] ?? ''; // Assuming direct access for now, adjust if nested
              _flatPreferenceController.text = flatRequirements['preferredFlatType'] ?? ''; // Fixed: Map preferredFlatType to flatPreference
              _furnishedUnfurnished = flatRequirements['furnished'] ?? ''; // Map furnished to furnishedUnfurnished
              _attachedBathroom = flatRequirements['attachedBathroom'] ?? '';
              _balcony = flatRequirements['balcony'] ?? '';
              _parking = flatRequirements['parking'] ?? '';
              _wifi = flatRequirements['wifiIncluded'] ?? ''; // Map wifi back to wifiIncluded

            } else {
              // Load FlatListingProfile data based on the desired structure
              _ownerNameController.text = data['displayName'] ?? ''; // Map displayName to ownerName
              _ownerAgeController.text = (data['age'] ?? '').toString();
              _ownerGender = data['gender'] ?? '';
              _ownerOccupationController.text = data['occupation'] ?? '';
              _ownerBioController.text = data['bio'] ?? '';
              _ownerCurrentCityController.text = data['currentCity'] ?? '';
              _ownerDesiredCityController.text = data['desiredCity'] ?? '';
              _ownerBudgetMinController.text = (data['budgetMinExpected'] ?? '').toString(); // Map budgetMinExpected
              _ownerBudgetMaxController.text = (data['budgetMaxExpected'] ?? '').toString(); // Map budgetMaxExpected
              _ownerAreaPreferenceController.text = data['areaPreference'] ?? '';

              Map<String, dynamic> ownerHabits = Map<String, dynamic>.from(data['habits'] ?? {});
              _ownerSmokingHabit = ownerHabits['smoking'] ?? '';
              _ownerDrinkingHabit = ownerHabits['drinking'] ?? '';
              _ownerFoodPreference = ownerHabits['food'] ?? '';
              _ownerCleanlinessLevel = ownerHabits['cleanliness'] ?? '';
              _ownerNoiseLevel = ownerHabits['noiseTolerance'] ?? '';
              _ownerSocialPreferences = ownerHabits['socialPreferences'] ?? '';
              _ownerVisitorsPolicy = ownerHabits['visitorsPolicy'] ?? '';
              _ownerPetOwnership = ownerHabits['petOwnership'] ?? '';
              _ownerPetTolerance = ownerHabits['petTolerance'] ?? '';
              _ownerSleepingSchedule = ownerHabits['sleepingSchedule'] ?? '';
              _ownerWorkSchedule = ownerHabits['workSchedule'] ?? '';
              _ownerSharingCommonSpaces = ownerHabits['sharingCommonSpaces'] ?? '';
              _ownerGuestsOvernightPolicy = ownerHabits['guestOvernightStays'] ?? '';
              _ownerPersonalSpaceVsSocialization = ownerHabits['personalSpaceVsSocializing'] ?? '';

              Map<String, dynamic> flatDetails = Map<String, dynamic>.from(data['flatDetails'] ?? {});
              _flatType = flatDetails['flatType'] ?? '';
              _furnishedStatus = flatDetails['furnishedStatus'] ?? '';
              _availableFor = flatDetails['availableFor'] ?? '';
              _availabilityDate = flatDetails['availabilityDate'] != null ? (flatDetails['availabilityDate'] as Timestamp).toDate() : null;
              _rentPriceController.text = (flatDetails['rentPrice'] ?? '').toString();
              _depositAmountController.text = (flatDetails['depositAmount'] ?? '').toString();
              _bathroomType = flatDetails['bathroomType'] ?? '';
              _balconyAvailability = flatDetails['balconyAvailability'] ?? '';
              _parkingAvailability = flatDetails['parkingAvailability'] ?? '';
              _flatAmenities = List<String>.from(flatDetails['amenities'] ?? []);
              _addressController.text = flatDetails['address'] ?? '';
              _landmarkController.text = flatDetails['landmark'] ?? '';
              _flatDescriptionController.text = flatDetails['flatDescription'] ?? '';

              Map<String, dynamic> flatmatePreferences = Map<String, dynamic>.from(data['flatmatePreferences'] ?? {});
              _preferredGender = flatmatePreferences['preferredFlatmateGender'] ?? '';
              _preferredAgeGroup = flatmatePreferences['preferredAgeGroup'] ?? '';
              _preferredOccupation = flatmatePreferences['preferredOccupation'] ?? '';
              _preferredHabits = List<String>.from(flatmatePreferences['preferredHabits'] ?? []);
              _flatmateIdealQualities = List<String>.from(flatmatePreferences['idealQualities'] ?? []);
              _flatmateDealBreakers = List<String>.from(flatmatePreferences['dealBreakers'] ?? []);
            }
          });
          print("State variables and controllers updated."); // Debugging print
        } else {
          print("No detailed profile found for user in subcollections based on determined/defaulted type or provided ID."); // Debugging print
          setState(() {
            _currentLoadedProfileDocId = null; // Clear if no profile was loaded
          });
        }
      } else {
        print("User is null. Cannot load profile."); // Debugging print
      }
    } catch (e) {
      print("Error loading user profile: $e"); // Debugging print
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profileData = <String, dynamic>{
          'uid': user.uid,
          'email': user.email,
          'userType': _selectedProfileType == 'Seeking a Flatmate' ? 'seeking_flat' : 'listing_flat',
          'isProfileComplete': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        // Use the loaded document ID if available, otherwise use 'default'
        String docIdToSave = _currentLoadedProfileDocId ?? 'default';
        print("Saving profile with ID: $docIdToSave for type: $_selectedProfileType"); // Debugging print


        if (_selectedProfileType == 'Seeking a Flatmate') {
          profileData.addAll({
            'displayName': _nameController.text,
            'age': int.tryParse(_ageController.text) ?? 0,
            'gender': _gender,
            'occupation': _occupationController.text,
            'currentCity': _currentLocationController.text,
            'desiredCity': _desiredCityController.text,
            'moveInDate': _moveInDate != null ? Timestamp.fromDate(_moveInDate!) : null,
            'budgetMinExpected': int.tryParse(_budgetMinController.text) ?? 0,
            'budgetMaxExpected': int.tryParse(_budgetMaxController.text) ?? 0,
            'areaPreference': _areaPreferenceController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
            'bio': _bioController.text,
            'habits': {
              'smoking': _smokingHabits,
              'drinking': _drinkingHabits,
              'food': _foodPreference,
              'cleanliness': _cleanliness,
              'noiseTolerance': _noiseLevel,
              'socialPreferences': _socialHabits,
              'visitorsPolicy': _visitorsPolicy,
              'petOwnership': _petOwnership,
              'petTolerance': _petTolerance,
              'sleepingSchedule': _sleepingSchedule,
              'workSchedule': _workSchedule,
              'sharingCommonSpaces': _sharingCommonSpaces,
              'guestOvernightStays': _guestsPolicyOvernight,
              'personalSpaceVsSocializing': _personalSpaceVsSocialization,
            },
            'flatmatePreferences': {
              'preferredFlatmateGender': _flatmateGenderPreference,
              'flatmateAgeRangeMin': _flatmateAgePreference.contains('No preference') ? null : (int.tryParse(_flatmateAgePreference.split('-')[0]) ?? 0),
              'flatmateAgeRangeMax': _flatmateAgePreference.contains('No preference') ? null : (int.tryParse(_flatmateAgePreference.split('-').last) ?? 0),
              'preferredOccupation': _flatmateOccupationPreference.isNotEmpty ? [_flatmateOccupationPreference] : [],
              'idealQualities': _idealQualities,
              'dealBreakers': _dealBreakers,
              'flatRequirements': {
                "preferredFlatType": _flatPreferenceController.text,
                'furnished': _furnishedUnfurnished,
                'attachedBathroom': _attachedBathroom,
                'balcony': _balcony,
                'parking': _parking,
                'wifiIncluded': _wifi,
              }
            },
            'hobbies': _interests,
            'personality': _personalityController.text,
            'relationshipGoal': _relationshipGoalController.text,
          });
          await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('seekingFlatmateProfiles').doc(docIdToSave).set(profileData, SetOptions(merge: true));
        } else {
          // 'Listing a Flat'
          profileData.addAll({
            'displayName': _ownerNameController.text,
            'age': int.tryParse(_ownerAgeController.text) ?? 0,
            'gender': _ownerGender,
            'occupation': _ownerOccupationController.text,
            'bio': _ownerBioController.text,
            'currentCity': _ownerCurrentCityController.text,
            'desiredCity': _ownerDesiredCityController.text,
            'budgetMinExpected': int.tryParse(_ownerBudgetMinController.text) ?? 0,
            'budgetMaxExpected': int.tryParse(_ownerBudgetMaxController.text) ?? 0,
            'areaPreference': _ownerAreaPreferenceController.text,
            'habits': {
              'smoking': _ownerSmokingHabit,
              'drinking': _ownerDrinkingHabit,
              'food': _ownerFoodPreference,
              'cleanliness': _ownerCleanlinessLevel,
              'noiseTolerance': _ownerNoiseLevel,
              'socialPreferences': _ownerSocialPreferences,
              'visitorsPolicy': _ownerVisitorsPolicy,
              'petOwnership': _ownerPetOwnership,
              'petTolerance': _ownerPetTolerance,
              'sleepingSchedule': _ownerSleepingSchedule,
              'workSchedule': _ownerWorkSchedule,
              'sharingCommonSpaces': _ownerSharingCommonSpaces,
              'guestOvernightStays': _ownerGuestsOvernightPolicy,
              'personalSpaceVsSocializing': _ownerPersonalSpaceVsSocialization,
            },
            'flatDetails': {
              'flatType': _flatType,
              'furnishedStatus': _furnishedStatus,
              'availableFor': _availableFor,
              'availabilityDate': _availabilityDate != null ? Timestamp.fromDate(_availabilityDate!) : null,
              'rentPrice': (int.tryParse(_rentPriceController.text) ?? 0),
              'depositAmount': (int.tryParse(_depositAmountController.text) ?? 0),
              'bathroomType': _bathroomType,
              'balconyAvailability': _balconyAvailability,
              'parkingAvailability': _parkingAvailability,
              'amenities': _flatAmenities,
              'address': _addressController.text,
              'landmark': _landmarkController.text,
              'flatDescription': _flatDescriptionController.text,
            },
            'flatmatePreferences': {
              'preferredFlatmateGender': _preferredGender,
              'preferredAgeGroup': _preferredAgeGroup,
              'preferredOccupation': _preferredOccupation,
              'preferredHabits': _preferredHabits,
              'idealQualities': _flatmateIdealQualities,
              'dealBreakers': _flatmateDealBreakers,
            },
          });
          await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('flatListings').doc(docIdToSave).set(profileData, SetOptions(merge: true));
        }

        // Also update the main user document with the userType
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'userType': _selectedProfileType == 'Seeking a Flatmate' ? 'seeking_flat' : 'listing_flat'},
          SetOptions(merge: true),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper for text input fields
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }

  // Date picker helper
  Future<void> _selectDate(BuildContext context, DateTime? currentDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.redAccent, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != currentDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedProfileType,
                decoration: InputDecoration(
                  labelText: 'Profile Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                items: <String>['Seeking a Flatmate', 'Listing a Flat']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedProfileType = newValue!;
                    // When profile type changes, clear and reload to prevent data mix-up
                    // A full clear might be too aggressive if user is just switching back and forth.
                    // Instead, rely on _loadUserProfile to populate correctly.
                    _currentLoadedProfileDocId = null; // Clear ID when type changes
                    _loadUserProfile(); // Reload data for the newly selected type
                  });
                },
              ),
              const SizedBox(height: 20),

              if (_selectedProfileType == 'Seeking a Flatmate')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Basic Information',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    const Divider(),
                    _buildTextField(
                      label: 'Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    _buildTextField(
                      label: 'Age',
                      hint: 'Enter your age',
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value!.isEmpty ? 'Age cannot be empty' : null,
                    ),
                    _QuestionWidget(
                      title: "What is your gender?",
                      subtitle: "This helps us match you better.",
                      options: const ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
                      onSelected: (selected) {
                        setState(() => _gender = selected);
                      },
                      initialValue: _gender,
                    ),
                    _buildTextField(
                      label: 'Occupation',
                      hint: 'e.g., Software Engineer, Student',
                      controller: _occupationController,
                    ),
                    _buildTextField(
                      label: 'Current Location (City)',
                      hint: 'e.g., Pune, Mumbai',
                      controller: _currentLocationController,
                    ),
                    _buildTextField(
                      label: 'Desired City for Flat',
                      hint: 'e.g., Bangalore, Delhi',
                      controller: _desiredCityController,
                    ),
                    ListTile(
                      title: Text(_moveInDate == null
                          ? 'Select Move-in Date'
                          : 'Move-in Date: ${DateFormat('dd-MM-yyyy').format(_moveInDate!)}'),
                      trailing: const Icon(Icons.calendar_today, color: Colors.redAccent),
                      onTap: () => _selectDate(context, _moveInDate, (date) {
                        setState(() {
                          _moveInDate = date;
                        });
                      }),
                    ),
                    _buildTextField(
                      label: 'Budget Range (Min)',
                      hint: 'e.g., 5000',
                      controller: _budgetMinController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _buildTextField(
                      label: 'Budget Range (Max)',
                      hint: 'e.g., 15000',
                      controller: _budgetMaxController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _buildTextField(
                      label: 'Preferred Area/Locality (Comma separated)',
                      hint: 'e.g., Koregaon Park, Viman Nagar',
                      controller: _areaPreferenceController,
                    ),
                    _buildTextField(
                      label: 'Bio / About Yourself',
                      hint: 'Tell us a bit about yourself and what you are looking for.',
                      controller: _bioController,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Your Habits & Lifestyle',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    const Divider(),
                    _QuestionWidget(
                      title: "How tidy are you?",
                      subtitle: "Be honest! It helps find a compatible flatmate.",
                      options: const ['Very Tidy', 'Moderately Tidy', 'Flexible', 'Can be messy at times'],
                      onSelected: (selected) {
                        setState(() => _cleanliness = selected);
                      },
                      initialValue: _cleanliness,
                    ),
                    _QuestionWidget(
                      title: "What are your social habits like?",
                      subtitle: "Do you enjoy socializing or prefer quiet time?",
                      options: const ['Social & outgoing', 'Occasional gatherings', 'Quiet & private'],
                      onSelected: (selected) {
                        setState(() => _socialHabits = selected);
                      },
                      initialValue: _socialHabits,
                    ),
                    _QuestionWidget(
                      title: "What's your typical work/study schedule?",
                      subtitle: "Helps in understanding routines.",
                      options: const ['9-5 Office hours', 'Freelance/Flexible hours', 'Night shifts', 'Student schedule', 'Mixed'],
                      onSelected: (selected) {
                        setState(() => _workSchedule = selected);
                      },
                      initialValue: _workSchedule,
                    ),
                    _QuestionWidget(
                      title: "What's your preferred noise level at home?",
                      subtitle: "Are you sensitive to noise or prefer a lively environment?",
                      options: const ['Very quiet', 'Moderate noise', 'Lively'],
                      onSelected: (selected) {
                        setState(() => _noiseLevel = selected);
                      },
                      initialValue: _noiseLevel,
                    ),
                    _QuestionWidget(
                      title: "Smoking habits?",
                      subtitle: "Indicate your smoking frequency.",
                      options: const ['Never', 'Occasionally', 'Socially', 'Regularly'],
                      onSelected: (selected) {
                        setState(() => _smokingHabits = selected);
                      },
                      initialValue: _smokingHabits,
                    ),
                    _QuestionWidget(
                      title: "Drinking habits?",
                      subtitle: "Indicate your drinking frequency.",
                      options: const ['Never', 'Occasionally', 'Socially', 'Regularly'],
                      onSelected: (selected) {
                        setState(() => _drinkingHabits = selected);
                      },
                      initialValue: _drinkingHabits,
                    ),
                    _QuestionWidget(
                      title: "Food Preference?",
                      subtitle: "Share your dietary habits.",
                      options: const ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian', 'Jain'],
                      onSelected: (selected) {
                        setState(() => _foodPreference = selected);
                      },
                      initialValue: _foodPreference,
                    ),
                    _QuestionWidget(
                      title: "How often do you have guests staying overnight?",
                      subtitle: "This helps manage expectations.",
                      options: const ['Frequently', 'Occasionally', 'Rarely', 'Never'],
                      onSelected: (selected) {
                        setState(() => _guestsPolicyOvernight = selected);
                      },
                      initialValue: _guestsPolicyOvernight,
                    ),
                    _QuestionWidget(
                      title: "How often do you have day visitors?",
                      subtitle: "This helps manage expectations.",
                      options: const ['Frequent visitors', 'Occasional visitors', 'Rarely have visitors', 'No visitors'],
                      onSelected: (selected) {
                        setState(() => _visitorsPolicy = selected);
                      },
                      initialValue: _visitorsPolicy,
                    ),
                    _QuestionWidget(
                      title: "Do you own pets?",
                      subtitle: "If yes, specify what kind.",
                      options: const ['Yes, I own pets', 'Planning to get one', 'No pets'],
                      onSelected: (selected) {
                        setState(() => _petOwnership = selected);
                      },
                      initialValue: _petOwnership,
                    ),
                    _QuestionWidget(
                      title: "What is your tolerance for flatmates having pets?",
                      subtitle: "Your comfort level with animals.",
                      options: const ['Comfortable with pets', 'Tolerant of pets', 'Prefer no pets', 'Allergic to pets'],
                      onSelected: (selected) {
                        setState(() => _petTolerance = selected);
                      },
                      initialValue: _petTolerance,
                    ),
                    _QuestionWidget(
                      title: "What's your general sleeping schedule?",
                      subtitle: "Early riser, night owl, or irregular?",
                      options: const ['Early riser', 'Night Owl', 'Irregular'],
                      onSelected: (selected) {
                        setState(() => _sleepingSchedule = selected);
                      },
                      initialValue: _sleepingSchedule,
                    ),
                    _QuestionWidget(
                      title: "How do you prefer sharing common spaces?",
                      subtitle: "Do you like to share items or prefer separate?",
                      options: const ['Share everything', 'Share some items', 'Prefer separate items'],
                      onSelected: (selected) {
                        setState(() => _sharingCommonSpaces = selected);
                      },
                      initialValue: _sharingCommonSpaces,
                    ),
                    _QuestionWidget(
                      title: "Personal space vs. Socialization?",
                      subtitle: "Your ideal balance.",
                      options: const ['Value personal space highly', 'Enjoy a balance', 'Prefer more socialization'],
                      onSelected: (selected) {
                        setState(() => _personalSpaceVsSocialization = selected);
                      },
                      initialValue: _personalSpaceVsSocialization,
                    ),
                    _MultiSelectQuestionWidget(
                      title: "What are your interests/hobbies?",
                      subtitle: "Select all that apply.",
                      options: const ['Reading', 'Gaming', 'Cooking', 'Sports', 'Movies', 'Music', 'Traveling', 'Hiking', 'Photography', 'Art', 'Writing', 'Technology', 'Fashion', 'Volunteering', 'Gardening', 'Fitness', 'Yoga', 'Meditation', 'Crafts', 'Board Games', 'Dancing', 'Singing', 'Learning New Languages'],
                      onSelected: (selected) {
                        setState(() => _interests = selected);
                      },
                      initialValues: _interests,
                    ),
                    _buildTextField(
                      label: 'Personality Traits',
                      hint: 'Describe your personality in a few words.',
                      controller: _personalityController,
                    ),
                    _buildTextField(
                      label: 'Relationship Goal with Flatmate',
                      hint: 'e.g., Friendship, Peaceful Coexistence',
                      controller: _relationshipGoalController,
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Flatmate Preferences',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    const Divider(),
                    _QuestionWidget(
                      title: "Preferred Flatmate Gender?",
                      subtitle: "Who would you prefer to live with?",
                      options: const ['Male', 'Female', 'No preference', 'Any'],
                      onSelected: (selected) {
                        setState(() => _flatmateGenderPreference = selected);
                      },
                      initialValue: _flatmateGenderPreference,
                    ),
                    _QuestionWidget(
                      title: "Preferred Flatmate Age Range?",
                      subtitle: "What age group do you prefer?",
                      options: const ['18-24', '25-34', '35-45', '45+', 'No preference'],
                      onSelected: (selected) {
                        setState(() => _flatmateAgePreference = selected);
                      },
                      initialValue: _flatmateAgePreference,
                    ),
                    _QuestionWidget(
                      title: "Preferred Flatmate Occupation?",
                      subtitle: "Any specific occupation preference?",
                      options: const ['Student', 'Working Professional', 'Freelancer', 'No preference'],
                      onSelected: (selected) {
                        setState(() => _flatmateOccupationPreference = selected);
                      },
                      initialValue: _flatmateOccupationPreference,
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Ideal Qualities in a Flatmate?",
                      subtitle: "Select the most important traits.",
                      options: const ['Responsible', 'Clean', 'Respectful', 'Communicative', 'Friendly', 'Quiet', 'Tidy', 'Social', 'Organized'],
                      onSelected: (selected) {
                        setState(() => _idealQualities = selected);
                      },
                      initialValues: _idealQualities,
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Any Deal Breakers?",
                      subtitle: "What you absolutely cannot tolerate.",
                      options: const ['Smoking', 'Excessive Noise', 'Untidiness', 'Frequent Parties', 'Pets', 'Guests staying over without notice'],
                      onSelected: (selected) {
                        setState(() => _dealBreakers = selected);
                      },
                      initialValues: _dealBreakers,
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Flat Requirements',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    const Divider(),
                    _buildTextField(
                      label: 'Location Preference',
                      hint: 'Specific areas or neighborhoods',
                      controller: _locationPreferenceController,
                    ),
                    _buildTextField(
                      label: 'Preferred Flat Type',
                      hint: 'e.g., Studio, 1BHK, 2BHK',
                      controller: _flatPreferenceController,
                    ),
                    _QuestionWidget(
                      title: "Furnished or Unfurnished?",
                      subtitle: "What kind of flat are you looking for?",
                      options: const ['Fully Furnished', 'Semi-Furnished', 'Unfurnished'],
                      onSelected: (selected) {
                        setState(() => _furnishedUnfurnished = selected);
                      },
                      initialValue: _furnishedUnfurnished,
                    ),
                    _QuestionWidget(
                      title: "Attached Bathroom?",
                      subtitle: "Do you require an attached bathroom?",
                      options: const ['Yes', 'No', 'No preference'],
                      onSelected: (selected) {
                        setState(() => _attachedBathroom = selected);
                      },
                      initialValue: _attachedBathroom,
                    ),
                    _QuestionWidget(
                      title: "Balcony availability?",
                      subtitle: "Is a balcony a must-have?",
                      options: const ['Yes', 'No', 'No preference'],
                      onSelected: (selected) {
                        setState(() => _balcony = selected);
                      },
                      initialValue: _balcony,
                    ),
                    _QuestionWidget(
                      title: "Parking availability?",
                      subtitle: "Do you need parking space?",
                      options: const ['Yes', 'No', 'No preference'],
                      onSelected: (selected) {
                        setState(() => _parking = selected);
                      },
                      initialValue: _parking,
                    ),
                    _QuestionWidget(
                      title: "Wi-Fi included?",
                      subtitle: "Is Wi-Fi a necessary amenity?",
                      options: const ['Yes, must be included', 'No, I can arrange', 'No preference'],
                      onSelected: (selected) {
                        setState(() => _wifi = selected);
                      },
                      initialValue: _wifi,
                    ),
                  ],
                )
              else if (_selectedProfileType == 'Listing a Flat')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Basic Information (Flat Owner)',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    const Divider(),
                    _buildTextField(
                      label: 'Your Name',
                      hint: 'Enter your full name',
                      controller: _ownerNameController,
                      validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    _buildTextField(
                      label: 'Your Age',
                      hint: 'Enter your age',
                      controller: _ownerAgeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value!.isEmpty ? 'Age cannot be empty' : null,
                    ),
                    _QuestionWidget(
                      title: "What is your gender?",
                      subtitle: "This helps in matching.",
                      options: const ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
                      onSelected: (selected) {
                        setState(() => _ownerGender = selected);
                      },
                      initialValue: _ownerGender,
                    ),
                    _buildTextField(
                      label: 'Your Occupation',
                      hint: 'e.g., Business Owner, Professional',
                      controller: _ownerOccupationController,
                    ),
                    _buildTextField(
                      label: 'Your Bio / About Yourself',
                      hint: 'Tell us a bit about yourself and your living style.',
                      controller: _ownerBioController,
                      maxLines: 3,
                    ),
                    _buildTextField(
                      label: 'Your Current City',
                      hint: 'e.g., Pune',
                      controller: _ownerCurrentCityController,
                    ),
                    _buildTextField(
                      label: 'Desired City (if different)',
                      hint: 'e.g., Mumbai',
                      controller: _ownerDesiredCityController,
                    ),
                    _buildTextField(
                      label: 'Your Budget Range (Min)',
                      hint: 'e.g., 5000',
                      controller: _ownerBudgetMinController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _buildTextField(
                      label: 'Your Budget Range (Max)',
                      hint: 'e.g., 15000',
                      controller: _ownerBudgetMaxController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    _buildTextField(
                      label: 'Your Area Preference',
                      hint: 'e.g., Koregaon Park',
                      controller: _ownerAreaPreferenceController,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Your Habits & Lifestyle (Owner)',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    const Divider(),
                    _QuestionWidget(
                      title: "Your Smoking habits?",
                      subtitle: "Your personal smoking frequency.",
                      options: const ['Never', 'Occasionally', 'Socially', 'Regularly'],
                      onSelected: (selected) {
                        setState(() => _ownerSmokingHabit = selected);
                      },
                      initialValue: _ownerSmokingHabit,
                    ),
                    _QuestionWidget(
                      title: "Your Drinking habits?",
                      subtitle: "Your personal drinking frequency.",
                      options: const ['Never', 'Occasionally', 'Socially', 'Regularly'],
                      onSelected: (selected) {
                        setState(() => _ownerDrinkingHabit = selected);
                      },
                      initialValue: _ownerDrinkingHabit,
                    ),
                    _QuestionWidget(
                      title: "Your Food Preference?",
                      subtitle: "Your dietary habits.",
                      options: const ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian', 'Jain'],
                      onSelected: (selected) {
                        setState(() => _ownerFoodPreference = selected);
                      },
                      initialValue: _ownerFoodPreference,
                    ),
                    _QuestionWidget(
                      title: "Your Cleanliness Level?",
                      subtitle: "How tidy are you?",
                      options: const ['Very Tidy', 'Moderately Tidy', 'Flexible', 'Can be messy at times'],
                      onSelected: (selected) {
                        setState(() => _ownerCleanlinessLevel = selected);
                      },
                      initialValue: _ownerCleanlinessLevel,
                    ),
                    _QuestionWidget(
                      title: "Your Preferred Noise Level?",
                      subtitle: "Your personal comfort with noise.",
                      options: const ['Very quiet', 'Moderate noise', 'Lively'],
                      onSelected: (selected) {
                        setState(() => _ownerNoiseLevel = selected);
                      },
                      initialValue: _ownerNoiseLevel,
                    ),
                    _QuestionWidget(
                      title: "Your Social Preferences?",
                      subtitle: "Your personal social habits.",
                      options: const ['Social & outgoing', 'Occasional gatherings', 'Quiet & private'],
                      onSelected: (selected) {
                        setState(() => _ownerSocialPreferences = selected);
                      },
                      initialValue: _ownerSocialPreferences,
                    ),
                    _QuestionWidget(
                      title: "Your Visitors Policy?",
                      subtitle: "How often do you allow day visitors?",
                      options: const ['Frequent visitors allowed', 'Occasional visitors allowed', 'Rarely allow visitors', 'No visitors allowed'],
                      onSelected: (selected) {
                        setState(() => _ownerVisitorsPolicy = selected);
                      },
                      initialValue: _ownerVisitorsPolicy,
                    ),
                    _QuestionWidget(
                      title: "Do you own pets?",
                      subtitle: "If yes, specify.",
                      options: const ['Yes, I own pets', 'No pets'],
                      onSelected: (selected) {
                        setState(() => _ownerPetOwnership = selected);
                      },
                      initialValue: _ownerPetOwnership,
                    ),
                    _QuestionWidget(
                      title: "What is your tolerance for flatmates having pets?",
                      subtitle: "Your comfort level with animals.",
                      options: const ['Comfortable with pets', 'Tolerant of pets', 'Prefer no pets', 'Allergic to pets'],
                      onSelected: (selected) {
                        setState(() => _ownerPetTolerance = selected);
                      },
                      initialValue: _ownerPetTolerance,
                    ),
                    _QuestionWidget(
                      title: "Your Sleeping Schedule?",
                      subtitle: "Early riser, night owl, or irregular?",
                      options: const ['Early riser', 'Night Owl', 'Irregular'],
                      onSelected: (selected) {
                        setState(() => _ownerSleepingSchedule = selected);
                      },
                      initialValue: _ownerSleepingSchedule,
                    ),
                    _QuestionWidget(
                      title: "Your Work Schedule?",
                      subtitle: "Helps in understanding routines.",
                      options: const ['9-5 Office hours', 'Freelance/Flexible hours', 'Night shifts', 'Student schedule', 'Mixed'],
                      onSelected: (selected) {
                        setState(() => _ownerWorkSchedule = selected);
                      },
                      initialValue: _ownerWorkSchedule,
                    ),
                    _QuestionWidget(
                      title: "How do you prefer sharing common spaces?",
                      subtitle: "Do you like to share items or prefer separate?",
                      options: const ['Share everything', 'Share some items', 'Prefer separate items'],
                      onSelected: (selected) {
                        setState(() => _ownerSharingCommonSpaces = selected);
                      },
                      initialValue: _ownerSharingCommonSpaces,
                    ),
                    _QuestionWidget(
                      title: "Guests Overnight Policy?",
                      subtitle: "Your policy on guests staying overnight.",
                      options: const ['Allowed frequently', 'Allowed occasionally', 'Rarely allowed', 'Not allowed'],
                      onSelected: (selected) {
                        setState(() => _ownerGuestsOvernightPolicy = selected);
                      },
                      initialValue: _ownerGuestsOvernightPolicy,
                    ),
                    _QuestionWidget(
                      title: "Personal space vs. Socialization?",
                      subtitle: "Your ideal balance.",
                      options: const ['Value personal space highly', 'Enjoy a balance', 'Prefer more socialization'],
                      onSelected: (selected) {
                        setState(() => _ownerPersonalSpaceVsSocialization = selected);
                      },
                      initialValue: _ownerPersonalSpaceVsSocialization,
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Flat Details',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    const Divider(),
                    _QuestionWidget(
                      title: "Flat Type?",
                      subtitle: "e.g., 1BHK, 2BHK, Studio",
                      options: const ['1RK', '1BHK', '2BHK', '3BHK', 'Studio Apartment', 'Shared Room'],
                      onSelected: (selected) {
                        setState(() => _flatType = selected);
                      },
                      initialValue: _flatType,
                    ),
                    _QuestionWidget(
                      title: "Furnished Status?",
                      subtitle: "Is the flat furnished, semi-furnished, or unfurnished?",
                      options: const ['Fully Furnished', 'Semi-Furnished', 'Unfurnished'],
                      onSelected: (selected) {
                        setState(() => _furnishedStatus = selected);
                      },
                      initialValue: _furnishedStatus,
                    ),
                    _QuestionWidget(
                      title: "Available For?",
                      subtitle: "Who is the flat available for?",
                      options: const ['Male', 'Female', 'Couples', 'Family', 'Anyone'],
                      onSelected: (selected) {
                        setState(() => _availableFor = selected);
                      },
                      initialValue: _availableFor,
                    ),
                    ListTile(
                      title: Text(_availabilityDate == null
                          ? 'Select Availability Date'
                          : 'Availability Date: ${DateFormat('dd-MM-yyyy').format(_availabilityDate!)}'),
                      trailing: const Icon(Icons.calendar_today, color: Colors.redAccent),
                      onTap: () => _selectDate(context, _availabilityDate, (date) {
                        setState(() {
                          _availabilityDate = date;
                        });
                      }),
                    ),
                    _buildTextField(
                      label: 'Rent Price (per month)',
                      hint: 'e.g., 12000',
                      controller: _rentPriceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value!.isEmpty ? 'Rent price cannot be empty' : null,
                    ),
                    _buildTextField(
                      label: 'Deposit Amount',
                      hint: 'e.g., 24000',
                      controller: _depositAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value!.isEmpty ? 'Deposit amount cannot be empty' : null,
                    ),
                    _QuestionWidget(
                      title: "Bathroom Type?",
                      subtitle: "Attached or Shared?",
                      options: const ['Attached', 'Shared', 'Both (multiple bathrooms)'],
                      onSelected: (selected) {
                        setState(() => _bathroomType = selected);
                      },
                      initialValue: _bathroomType,
                    ),
                    _QuestionWidget(
                      title: "Balcony Availability?",
                      subtitle: "Does the flat have a balcony?",
                      options: const ['Yes', 'No'],
                      onSelected: (selected) {
                        setState(() => _balconyAvailability = selected);
                      },
                      initialValue: _balconyAvailability,
                    ),
                    _QuestionWidget(
                      title: "Parking Availability?",
                      subtitle: "Is parking available for the flat?",
                      options: const ['Car Parking', 'Bike Parking', 'Both', 'None'],
                      onSelected: (selected) {
                        setState(() => _parkingAvailability = selected);
                      },
                      initialValue: _parkingAvailability,
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Flat Amenities",
                      subtitle: "Select all available amenities.",
                      options: const ['AC', 'Washing Machine', 'Refrigerator', 'Geyser', 'TV', 'Sofa', 'Bed', 'Wardrobe', 'Dining Table', 'Modular Kitchen', 'Wi-Fi', 'Power Backup', 'Gym', 'Swimming Pool', 'Security'],
                      onSelected: (selected) {
                        setState(() => _flatAmenities = selected);
                      },
                      initialValues: _flatAmenities,
                    ),
                    _buildTextField(
                      label: 'Full Address',
                      hint: 'Enter the complete address of the flat',
                      controller: _addressController,
                      maxLines: 2,
                      validator: (value) => value!.isEmpty ? 'Address cannot be empty' : null,
                    ),
                    _buildTextField(
                      label: 'Landmark',
                      hint: 'Nearby landmark for easy identification',
                      controller: _landmarkController,
                    ),
                    _buildTextField(
                      label: 'Flat Description',
                      hint: 'Describe your flat (e.g., features, neighborhood, pros)',
                      controller: _flatDescriptionController,
                      maxLines: 5,
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Preferred Flatmate (for your flat)',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    const Divider(),
                    _QuestionWidget(
                      title: "Preferred Flatmate Gender?",
                      subtitle: "Who would you prefer for your flat?",
                      options: const ['Male', 'Female', 'Couples', 'Any'],
                      onSelected: (selected) {
                        setState(() => _preferredGender = selected);
                      },
                      initialValue: _preferredGender,
                    ),
                    _QuestionWidget(
                      title: "Preferred Flatmate Age Group?",
                      subtitle: "What age group do you prefer?",
                      options: const ['18-24', '25-34', '35-45', '45+', 'No preference'],
                      onSelected: (selected) {
                        setState(() => _preferredAgeGroup = selected);
                      },
                      initialValue: _preferredAgeGroup,
                    ),
                    _QuestionWidget(
                      title: "Preferred Flatmate Occupation?",
                      subtitle: "Any specific occupation preference?",
                      options: const ['Student', 'Working Professional', 'Freelancer', 'No preference'],
                      onSelected: (selected) {
                        setState(() => _preferredOccupation = selected);
                      },
                      initialValue: _preferredOccupation,
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Preferred Flatmate Habits",
                      subtitle: "Select habits you prefer in a flatmate.",
                      options: const ['Non-smoker', 'Non-drinker', 'Vegetarian', 'Tidy', 'Quiet', 'Social', 'Early riser'],
                      onSelected: (selected) {
                        setState(() => _preferredHabits = selected);
                      },
                      initialValues: _preferredHabits,
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Ideal Qualities in a Flatmate?",
                      subtitle: "Select the most important traits.",
                      options: const ['Responsible', 'Clean', 'Respectful', 'Communicative', 'Friendly', 'Quiet', 'Tidy', 'Social', 'Organized'],
                      onSelected: (selected) {
                        setState(() => _flatmateIdealQualities = selected);
                      },
                      initialValues: _flatmateIdealQualities,
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Any Deal Breakers?",
                      subtitle: "What you absolutely cannot tolerate.",
                      options: const ['Smoking', 'Excessive Noise', 'Untidiness', 'Frequent Parties', 'Pets', 'Guests staying over without notice'],
                      onSelected: (selected) {
                        setState(() => _flatmateDealBreakers = selected);
                      },
                      initialValues: _flatmateDealBreakers,
                    ),
                  ],
                ),

              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Profile', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}