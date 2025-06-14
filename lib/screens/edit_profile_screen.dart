import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For formatting dates

// Re-using data models from your provided files
// You should ensure these classes are accessible in your project
// If not, you'll need to define them or adjust imports.

// Data model to hold all the answers for the user seeking a flat
class SeekingFlatmateProfile {
  // Basic Info
  String name = '';
  String age = '';
  String gender = '';
  String occupation = '';
  String currentLocation = '';
  String desiredCity = ''; // New field
  DateTime? moveInDate;
  String budgetMin = ''; // Updated from budget
  String budgetMax = ''; // New field
  String areaPreference = ''; // New field
  String bio = '';

  // Habits
  String cleanliness = '';
  String socialHabits = '';
  String workSchedule = '';
  String noiseLevel = '';
  String smokingHabits = ''; // Updated from isSmoker
  String drinkingHabits = ''; // Updated from drinkingHabit
  String foodPreference = ''; // Updated from dietaryPreference
  String guestsFrequency = '';
  String visitorsPolicy = ''; // New field
  String petOwnership = ''; // Updated from hasPets
  String petTolerance = ''; // New field
  String sleepingSchedule = ''; // New field
  String sharingCommonSpaces = ''; // New field
  String guestsPolicyOvernight = ''; // New field
  String personalSpaceVsSocialization = '';

  // Looking For Preferences
  List<String> interests = [];
  String personality = '';
  String flatmateGenderPreference = '';
  String flatmateAgePreference = '';
  String flatmateOccupationPreference = '';
  List<String> idealQualities = [];
  List<String> dealBreakers = [];
  String relationshipGoal = '';

  // Flat Requirements
  String locationPreference = '';
  String flatPreference = '';
  String furnishedUnfurnished = '';
  String attachedBathroom = '';
  String balcony = '';
  String parking = '';
  String wifi = '';


  SeekingFlatmateProfile({
    this.name = '',
    this.age = '',
    this.gender = '',
    this.occupation = '',
    this.currentLocation = '',
    this.desiredCity = '',
    this.moveInDate,
    this.budgetMin = '',
    this.budgetMax = '',
    this.areaPreference = '',
    this.bio = '',
    this.cleanliness = '',
    this.socialHabits = '',
    this.workSchedule = '',
    this.noiseLevel = '',
    this.smokingHabits = '',
    this.drinkingHabits = '',
    this.foodPreference = '',
    this.guestsFrequency = '',
    this.visitorsPolicy = '',
    this.petOwnership = '',
    this.petTolerance = '',
    this.sleepingSchedule = '',
    this.sharingCommonSpaces = '',
    this.guestsPolicyOvernight = '',
    this.personalSpaceVsSocialization = '',
    this.interests = const [],
    this.personality = '',
    this.flatmateGenderPreference = '',
    this.flatmateAgePreference = '',
    this.flatmateOccupationPreference = '',
    this.idealQualities = const [],
    this.dealBreakers = const [],
    this.relationshipGoal = '',
    this.locationPreference = '',
    this.flatPreference = '',
    this.furnishedUnfurnished = '',
    this.attachedBathroom = '',
    this.balcony = '',
    this.parking = '',
    this.wifi = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'currentLocation': currentLocation,
      'desiredCity': desiredCity,
      'moveInDate': moveInDate?.toIso8601String(),
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'areaPreference': areaPreference,
      'bio': bio,
      'cleanliness': cleanliness,
      'socialHabits': socialHabits,
      'workSchedule': workSchedule,
      'noiseLevel': noiseLevel,
      'smokingHabits': smokingHabits,
      'drinkingHabits': drinkingHabits,
      'foodPreference': foodPreference,
      'guestsFrequency': guestsFrequency,
      'visitorsPolicy': visitorsPolicy,
      'petOwnership': petOwnership,
      'petTolerance': petTolerance,
      'sleepingSchedule': sleepingSchedule,
      'sharingCommonSpaces': sharingCommonSpaces,
      'guestsPolicyOvernight': guestsPolicyOvernight,
      'personalSpaceVsSocialization': personalSpaceVsSocialization,
      'interests': interests,
      'personality': personality,
      'flatmateGenderPreference': flatmateGenderPreference,
      'flatmateAgePreference': flatmateAgePreference,
      'flatmateOccupationPreference': flatmateOccupationPreference,
      'idealQualities': idealQualities,
      'dealBreakers': dealBreakers,
      'relationshipGoal': relationshipGoal,
      'locationPreference': locationPreference,
      'flatPreference': flatPreference,
      'furnishedUnfurnished': furnishedUnfurnished,
      'attachedBathroom': attachedBathroom,
      'balcony': balcony,
      'parking': parking,
      'wifi': wifi,
    };
  }

  factory SeekingFlatmateProfile.fromMap(Map<String, dynamic> map) {
    return SeekingFlatmateProfile(
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      gender: map['gender'] ?? '',
      occupation: map['occupation'] ?? '',
      currentLocation: map['currentLocation'] ?? '',
      desiredCity: map['desiredCity'] ?? '',
      moveInDate: map['moveInDate'] != null ? DateTime.parse(map['moveInDate']) : null,
      budgetMin: map['budgetMin'] ?? '',
      budgetMax: map['budgetMax'] ?? '',
      areaPreference: map['areaPreference'] ?? '',
      bio: map['bio'] ?? '',
      cleanliness: map['cleanliness'] ?? '',
      socialHabits: map['socialHabits'] ?? '',
      workSchedule: map['workSchedule'] ?? '',
      noiseLevel: map['noiseLevel'] ?? '',
      smokingHabits: map['smokingHabits'] ?? '',
      drinkingHabits: map['drinkingHabits'] ?? '',
      foodPreference: map['foodPreference'] ?? '',
      guestsFrequency: map['guestsFrequency'] ?? '',
      visitorsPolicy: map['visitorsPolicy'] ?? '',
      petOwnership: map['petOwnership'] ?? '',
      petTolerance: map['petTolerance'] ?? '',
      sleepingSchedule: map['sleepingSchedule'] ?? '',
      sharingCommonSpaces: map['sharingCommonSpaces'] ?? '',
      guestsPolicyOvernight: map['guestsPolicyOvernight'] ?? '',
      personalSpaceVsSocialization: map['personalSpaceVsSocialization'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      personality: map['personality'] ?? '',
      flatmateGenderPreference: map['flatmateGenderPreference'] ?? '',
      flatmateAgePreference: map['flatmateAgePreference'] ?? '',
      flatmateOccupationPreference: map['flatmateOccupationPreference'] ?? '',
      idealQualities: List<String>.from(map['idealQualities'] ?? []),
      dealBreakers: List<String>.from(map['dealBreakers'] ?? []),
      relationshipGoal: map['relationshipGoal'] ?? '',
      locationPreference: map['locationPreference'] ?? '',
      flatPreference: map['flatPreference'] ?? '',
      furnishedUnfurnished: map['furnishedUnfurnished'] ?? '',
      attachedBathroom: map['attachedBathroom'] ?? '',
      balcony: map['balcony'] ?? '',
      parking: map['parking'] ?? '',
      wifi: map['wifi'] ?? '',
    );
  }
}

// Data model to hold all the answers for the user listing a flat
class FlatListingProfile {
  // Basic Info
  String ownerName = '';
  String ownerAge = '';
  String ownerGender = '';
  String ownerOccupation = '';
  String ownerBio = '';
  String currentCity = '';
  String desiredCity = ''; // New field
  String budgetMin = ''; // New field
  String budgetMax = ''; // New field
  String areaPreference = ''; // New field

  // Habits
  String smokingHabit = ''; // New field
  String drinkingHabit = ''; // New field
  String foodPreference = ''; // New field
  String cleanlinessLevel = ''; // New field
  String noiseLevel = ''; // New field
  String socialPreferences = ''; // New field
  String visitorsPolicy = ''; // New field
  String petOwnership = ''; // New field
  String petTolerance = ''; // New field
  String sleepingSchedule = ''; // New field
  String workSchedule = ''; // New field
  String sharingCommonSpaces = ''; // New field
  String guestsOvernightPolicy = ''; // New field
  String personalSpaceVsSocialization = ''; // New field

  // Flat Details
  String flatType = ''; // New field (e.g., Studio, 1BHK)
  String furnishedStatus = ''; // New field (Furnished, Unfurnished)
  String availableFor = ''; // New field (e.g., Boys, Girls, Couple)
  DateTime? availabilityDate; // New field
  String rentPrice = ''; // New field
  String depositAmount = ''; // New field
  String bathroomType = ''; // New field (Attached, Shared)
  String balconyAvailability = ''; // New field
  String parkingAvailability = ''; // New field
  List<String> amenities = []; // New field (e.g., Wi-Fi, AC, Geyser)
  String address = ''; // New field
  String landmark = ''; // New field
  String flatDescription = ''; // New field

  // Flatmate Preferences
  String preferredGender = ''; // New field
  String preferredAgeGroup = ''; // New field
  String preferredOccupation = ''; // New field
  List<String> preferredHabits = []; // New field (e.g., non-smoker)
  List<String> flatmateIdealQualities = []; // New field
  List<String> flatmateDealBreakers = []; // New field

  FlatListingProfile({
    this.ownerName = '',
    this.ownerAge = '',
    this.ownerGender = '',
    this.ownerOccupation = '',
    this.ownerBio = '',
    this.currentCity = '',
    this.desiredCity = '',
    this.budgetMin = '',
    this.budgetMax = '',
    this.areaPreference = '',
    this.smokingHabit = '',
    this.drinkingHabit = '',
    this.foodPreference = '',
    this.cleanlinessLevel = '',
    this.noiseLevel = '',
    this.socialPreferences = '',
    this.visitorsPolicy = '',
    this.petOwnership = '',
    this.petTolerance = '',
    this.sleepingSchedule = '',
    this.workSchedule = '',
    this.sharingCommonSpaces = '',
    this.guestsOvernightPolicy = '',
    this.personalSpaceVsSocialization = '',
    this.flatType = '',
    this.furnishedStatus = '',
    this.availableFor = '',
    this.availabilityDate,
    this.rentPrice = '',
    this.depositAmount = '',
    this.bathroomType = '',
    this.balconyAvailability = '',
    this.parkingAvailability = '',
    this.amenities = const [],
    this.address = '',
    this.landmark = '',
    this.flatDescription = '',
    this.preferredGender = '',
    this.preferredAgeGroup = '',
    this.preferredOccupation = '',
    this.preferredHabits = const [],
    this.flatmateIdealQualities = const [],
    this.flatmateDealBreakers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerName': ownerName,
      'ownerAge': ownerAge,
      'ownerGender': ownerGender,
      'ownerOccupation': ownerOccupation,
      'ownerBio': ownerBio,
      'currentCity': currentCity,
      'desiredCity': desiredCity,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'areaPreference': areaPreference,
      'smokingHabit': smokingHabit,
      'drinkingHabit': drinkingHabit,
      'foodPreference': foodPreference,
      'cleanlinessLevel': cleanlinessLevel,
      'noiseLevel': noiseLevel,
      'socialPreferences': socialPreferences,
      'visitorsPolicy': visitorsPolicy,
      'petOwnership': petOwnership,
      'petTolerance': petTolerance,
      'sleepingSchedule': sleepingSchedule,
      'workSchedule': workSchedule,
      'sharingCommonSpaces': sharingCommonSpaces,
      'guestsOvernightPolicy': guestsOvernightPolicy,
      'personalSpaceVsSocialization': personalSpaceVsSocialization,
      'flatType': flatType,
      'furnishedStatus': furnishedStatus,
      'availableFor': availableFor,
      'availabilityDate': availabilityDate?.toIso8601String(),
      'rentPrice': rentPrice,
      'depositAmount': depositAmount,
      'bathroomType': bathroomType,
      'balconyAvailability': balconyAvailability,
      'parkingAvailability': parkingAvailability,
      'amenities': amenities,
      'address': address,
      'landmark': landmark,
      'flatDescription': flatDescription,
      'preferredGender': preferredGender,
      'preferredAgeGroup': preferredAgeGroup,
      'preferredOccupation': preferredOccupation,
      'preferredHabits': preferredHabits,
      'flatmateIdealQualities': flatmateIdealQualities,
      'flatmateDealBreakers': flatmateDealBreakers,
    };
  }

  factory FlatListingProfile.fromMap(Map<String, dynamic> map) {
    return FlatListingProfile(
      ownerName: map['ownerName'] ?? '',
      ownerAge: map['ownerAge'] ?? '',
      ownerGender: map['ownerGender'] ?? '',
      ownerOccupation: map['ownerOccupation'] ?? '',
      ownerBio: map['ownerBio'] ?? '',
      currentCity: map['currentCity'] ?? '',
      desiredCity: map['desiredCity'] ?? '',
      budgetMin: map['budgetMin'] ?? '',
      budgetMax: map['budgetMax'] ?? '',
      areaPreference: map['areaPreference'] ?? '',
      smokingHabit: map['smokingHabit'] ?? '',
      drinkingHabit: map['drinkingHabit'] ?? '',
      foodPreference: map['foodPreference'] ?? '',
      cleanlinessLevel: map['cleanlinessLevel'] ?? '',
      noiseLevel: map['noiseLevel'] ?? '',
      socialPreferences: map['socialPreferences'] ?? '',
      visitorsPolicy: map['visitorsPolicy'] ?? '',
      petOwnership: map['petOwnership'] ?? '',
      petTolerance: map['petTolerance'] ?? '',
      sleepingSchedule: map['sleepingSchedule'] ?? '',
      workSchedule: map['workSchedule'] ?? '',
      sharingCommonSpaces: map['sharingCommonSpaces'] ?? '',
      guestsOvernightPolicy: map['guestsOvernightPolicy'] ?? '',
      personalSpaceVsSocialization: map['personalSpaceVsSocialization'] ?? '',
      flatType: map['flatType'] ?? '',
      furnishedStatus: map['furnishedStatus'] ?? '',
      availableFor: map['availableFor'] ?? '',
      availabilityDate: map['availabilityDate'] != null ? DateTime.parse(map['availabilityDate']) : null,
      rentPrice: map['rentPrice'] ?? '',
      depositAmount: map['depositAmount'] ?? '',
      bathroomType: map['bathroomType'] ?? '',
      balconyAvailability: map['balconyAvailability'] ?? '',
      parkingAvailability: map['parkingAvailability'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
      address: map['address'] ?? '',
      landmark: map['landmark'] ?? '',
      flatDescription: map['flatDescription'] ?? '',
      preferredGender: map['preferredGender'] ?? '',
      preferredAgeGroup: map['preferredAgeGroup'] ?? '',
      preferredOccupation: map['preferredOccupation'] ?? '',
      preferredHabits: List<String>.from(map['preferredHabits'] ?? []),
      flatmateIdealQualities: List<String>.from(map['flatmateIdealQualities'] ?? []),
      flatmateDealBreakers: List<String>.from(map['dealBreakers'] ?? []),
    );
  }
}

// Reusable custom widgets
class _QuestionWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Function(String) onSelected;
  final String? initialValue;

  const _QuestionWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected,
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
  final Function(List<String>) onSelected;
  final List<String> initialValues;

  const _MultiSelectQuestionWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected,
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
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  // This now represents the selected profile type for the dropdown
  String _selectedProfileType = 'Seeking a Flatmate'; // Default value

  // SeekingFlatmateProfile data
  String _name = '';
  String _age = '';
  String _gender = '';
  String _occupation = '';
  String _currentLocation = '';
  String _desiredCity = '';
  DateTime? _moveInDate;
  String _budgetMin = '';
  String _budgetMax = '';
  String _areaPreference = '';
  String _bio = '';
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
  String _personality = '';
  String _flatmateGenderPreference = '';
  String _flatmateAgePreference = '';
  String _flatmateOccupationPreference = '';
  List<String> _idealQualities = [];
  List<String> _dealBreakers = [];
  String _relationshipGoal = '';
  String _locationPreference = '';
  String _flatPreference = '';
  String _furnishedUnfurnished = '';
  String _attachedBathroom = '';
  String _balcony = '';
  String _parking = '';
  String _wifi = '';

  // FlatListingProfile data
  String _ownerName = '';
  String _ownerAge = '';
  String _ownerGender = '';
  String _ownerOccupation = '';
  String _ownerBio = '';
  String _ownerCurrentCity = '';
  String _ownerDesiredCity = '';
  String _ownerBudgetMin = '';
  String _ownerBudgetMax = '';
  String _ownerAreaPreference = '';
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
  String _rentPrice = '';
  String _depositAmount = '';
  String _bathroomType = '';
  String _balconyAvailability = '';
  String _parkingAvailability = '';
  List<String> _flatAmenities = [];
  String _address = '';
  String _landmark = '';
  String _flatDescription = '';
  String _preferredGender = '';
  String _preferredAgeGroup = '';
  String _preferredOccupation = '';
  List<String> _preferredHabits = [];
  List<String> _flatmateIdealQualities = [];
  List<String> _flatmateDealBreakers = [];


  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // *** IMPORTANT CHANGE: Fetch from 'users' collection ***
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          print("Profile data loaded from Firestore: $data"); // Debugging print

          setState(() {
            // Determine initial dropdown selection based on 'userType'
            String userType = data['userType'] ?? '';
            _selectedProfileType = (userType == 'seeking_flat') ? 'Seeking a Flatmate' : 'Listing a Flat';
            print("Initial selected profile type: $_selectedProfileType"); // Debugging print

            // Load SeekingFlatmateProfile data based on the provided structure
            if (_selectedProfileType == 'Seeking a Flatmate') {
              _name = data['displayName'] ?? ''; // Map displayName to name
              _age = (data['age'] ?? '').toString();
              _gender = data['gender'] ?? '';
              _occupation = data['occupation'] ?? '';
              _currentLocation = data['currentCity'] ?? ''; // Map currentCity to currentLocation
              _desiredCity = data['desiredCity'] ?? '';

              if (data['moveInDate'] != null) {
                // Firestore timestamp conversion
                Timestamp timestamp = data['moveInDate'];
                _moveInDate = timestamp.toDate();
              } else {
                _moveInDate = null;
              }

              _budgetMin = (data['budgetMin'] ?? '').toString();
              _budgetMax = (data['budgetMax'] ?? '').toString();

              // areaPreference is an array in user's data, but string in state.
              // Taking the first element, or empty if null/empty.
              List<String> preferredAreasList = List<String>.from(data['preferredAreas'] ?? []);
              _areaPreference = preferredAreasList.isNotEmpty ? preferredAreasList.first : '';

              _bio = data['bio'] ?? '';

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
              // Personality is not directly available in provided 'seeking_flat' data, keep as is
              _personality = data['personality'] ?? '';


              // Looking For Preferences
              Map<String, dynamic> lookingFor = Map<String, dynamic>.from(data['lookingFor'] ?? {});
              _flatmateGenderPreference = lookingFor['flatmateGender'] ?? '';

              // Handle flatmateAgeRangeMin and Max
              int? minAge = lookingFor['flatmateAgeRangeMin'];
              int? maxAge = lookingFor['flatmateAgeRangeMax'];
              if (minAge != null && maxAge != null) {
                _flatmateAgePreference = '$minAge-$maxAge';
              } else {
                _flatmateAgePreference = '';
              }

              // flatmateOccupation is an array in user's data, but string in state.
              List<String> flatmateOccupationList = List<String>.from(lookingFor['flatmateOccupation'] ?? []);
              _flatmateOccupationPreference = flatmateOccupationList.isNotEmpty ? flatmateOccupationList.first : '';

              _idealQualities = List<String>.from(lookingFor['importantQualities'] ?? []); // Map importantQualities to idealQualities
              _dealBreakers = List<String>.from(lookingFor['dealBreakers'] ?? []);
              // relationshipGoal is not directly available in provided 'seeking_flat' data, keep as is
              _relationshipGoal = data['relationshipGoal'] ?? '';


              // Flat Requirements
              Map<String, dynamic> flatRequirements = Map<String, dynamic>.from(data['flatRequirements'] ?? {});
              _locationPreference = data['locationPreference'] ?? ''; // Assuming direct access for now, adjust if nested
              _flatPreference = data['flatPreference'] ?? ''; // Assuming direct access for now, adjust if nested
              _furnishedUnfurnished = flatRequirements['furnished'] ?? ''; // Map furnished to furnishedUnfurnished
              _attachedBathroom = flatRequirements['attachedBathroom'] ?? '';
              _balcony = flatRequirements['balcony'] ?? '';
              _parking = flatRequirements['parking'] ?? '';
              _wifi = flatRequirements['wifiIncluded'] ?? ''; // Map wifi back to wifiIncluded

            } else {
              // Load FlatListingProfile data based on the desired structure
              _ownerName = data['displayName'] ?? ''; // Map displayName to ownerName
              _ownerAge = (data['age'] ?? '').toString();
              _ownerGender = data['gender'] ?? '';
              _ownerOccupation = data['occupation'] ?? '';
              _ownerBio = data['bio'] ?? '';
              _ownerCurrentCity = data['currentCity'] ?? '';
              _ownerDesiredCity = data['desiredCity'] ?? '';
              _ownerBudgetMin = (data['budgetMinExpected'] ?? '').toString(); // Map budgetMinExpected
              _ownerBudgetMax = (data['budgetMaxExpected'] ?? '').toString(); // Map budgetMaxExpected
              _ownerAreaPreference = data['areaPreference'] ?? '';

              Map<String, dynamic> ownerHabits = Map<String, dynamic>.from(data['ownerHabits'] ?? {});
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
              _rentPrice = (flatDetails['rentPrice'] ?? '').toString();
              _depositAmount = (flatDetails['depositAmount'] ?? '').toString();
              _bathroomType = flatDetails['bathroomType'] ?? '';
              _balconyAvailability = flatDetails['balconyAvailability'] ?? '';
              _parkingAvailability = flatDetails['parkingAvailability'] ?? '';
              _flatAmenities = List<String>.from(flatDetails['amenities'] ?? []);
              _address = flatDetails['address'] ?? '';
              _landmark = flatDetails['landmark'] ?? '';
              _flatDescription = flatDetails['description'] ?? '';

              Map<String, dynamic> flatmatePreferences = Map<String, dynamic>.from(data['flatmatePreferences'] ?? {});
              _preferredGender = flatmatePreferences['preferredGender'] ?? '';
              _preferredAgeGroup = flatmatePreferences['preferredAgeGroup'] ?? '';
              _preferredOccupation = flatmatePreferences['preferredOccupation'] ?? '';
              _preferredHabits = List<String>.from(flatmatePreferences['preferredHabits'] ?? []);
              _flatmateIdealQualities = List<String>.from(flatmatePreferences['idealQualities'] ?? []);
              _flatmateDealBreakers = List<String>.from(flatmatePreferences['dealBreakers'] ?? []);
            }
          });
          print("State variables updated. Name (Seeking): $_name, Owner Name (Listing): $_ownerName"); // Debugging print
        } else {
          print("Document does not exist for user: ${user.uid} in 'users' collection."); // Debugging print
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

        if (_selectedProfileType == 'Seeking a Flatmate') {
          profileData.addAll({
            'displayName': _name,
            'age': int.tryParse(_age) ?? 0,
            'gender': _gender,
            'occupation': _occupation,
            'currentCity': _currentLocation,
            'desiredCity': _desiredCity,
            'moveInDate': _moveInDate != null ? Timestamp.fromDate(_moveInDate!) : null,
            'budgetMin': int.tryParse(_budgetMin) ?? 0,
            'budgetMax': int.tryParse(_budgetMax) ?? 0,
            'preferredAreas': _areaPreference.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
            'bio': _bio,
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
            'lookingFor': {
              'flatmateGender': _flatmateGenderPreference,
              'flatmateAgeRangeMin': _flatmateAgePreference.contains('No preference') ? null : (int.tryParse(_flatmateAgePreference.split('-')[0]) ?? 0),
              'flatmateAgeRangeMax': _flatmateAgePreference.contains('No preference') ? null : (int.tryParse(_flatmateAgePreference.split('-').last) ?? 0),
              'flatmateOccupation': _flatmateOccupationPreference.isNotEmpty ? [_flatmateOccupationPreference] : [],
              'importantQualities': _idealQualities,
              'dealBreakers': _dealBreakers,
              'flatRequirements': {
                'furnished': _furnishedUnfurnished,
                'attachedBathroom': _attachedBathroom,
                'balcony': _balcony,
                'parking': _parking,
                'wifiIncluded': _wifi,
              }
            },
            'hobbies': _interests,
            'personality': _personality, // Keep personality at top level as in data
            'relationshipGoal': _relationshipGoal,
            // locationPreference and flatPreference were removed from flatRequirements as per user's desired structure
          });
        } else { // 'Listing a Flat'
          profileData.addAll({
            'displayName': _ownerName,
            'age': int.tryParse(_ownerAge) ?? 0,
            'gender': _ownerGender,
            'occupation': _ownerOccupation,
            'bio': _ownerBio,
            'currentCity': _ownerCurrentCity,
            'desiredCity': _ownerDesiredCity,
            'budgetMinExpected': int.tryParse(_ownerBudgetMin) ?? 0, // Changed key
            'budgetMaxExpected': int.tryParse(_ownerBudgetMax) ?? 0, // Changed key
            'areaPreference': _ownerAreaPreference,
            'ownerHabits': {
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
              'rentPrice': int.tryParse(_rentPrice) ?? 0,
              'depositAmount': int.tryParse(_depositAmount) ?? 0,
              'bathroomType': _bathroomType,
              'balconyAvailability': _balconyAvailability,
              'parkingAvailability': _parkingAvailability,
              'amenities': _flatAmenities,
              'address': _address,
              'landmark': _landmark,
              'description': _flatDescription, // Changed key
            },
            'flatmatePreferences': {
              'preferredGender': _preferredGender,
              'preferredAgeGroup': _preferredAgeGroup,
              'preferredOccupation': _preferredOccupation,
              'preferredHabits': _preferredHabits,
              'idealQualities': _flatmateIdealQualities, // Changed key
              'dealBreakers': _flatmateDealBreakers, // Changed key
            },
          });
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(profileData, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
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

  @override
  Widget build(BuildContext context) {
    // Determine the boolean value from the selected string for conditional rendering
    bool isSeekingFlatmate = (_selectedProfileType == 'Seeking a Flatmate');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0), // Consistent padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align content to start
            children: [
              // Replaced SwitchListTile with DropdownButtonFormField
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Profile Type',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjust padding
                ),
                value: _selectedProfileType,
                items: const [
                  DropdownMenuItem(
                    value: 'Seeking a Flatmate',
                    child: Text('Seeking a Flatmate'),
                  ),
                  DropdownMenuItem(
                    value: 'Listing a Flat',
                    child: Text('Listing a Flat'),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    // --- Start: Logic to preserve common fields ---
                    String tempGender = isSeekingFlatmate ? _gender : _ownerGender;
                    String tempAge = isSeekingFlatmate ? _age : _ownerAge;
                    String tempOccupation = isSeekingFlatmate ? _occupation : _ownerOccupation;
                    String tempBio = isSeekingFlatmate ? _bio : _ownerBio;
                    String tempCurrentLocation = isSeekingFlatmate ? _currentLocation : _ownerCurrentCity;
                    String tempDesiredCity = isSeekingFlatmate ? _desiredCity : _ownerDesiredCity;
                    String tempBudgetMin = isSeekingFlatmate ? _budgetMin : _ownerBudgetMin;
                    String tempBudgetMax = isSeekingFlatmate ? _budgetMax : _ownerBudgetMax;
                    String tempAreaPreference = isSeekingFlatmate ? _areaPreference : _ownerAreaPreference;

                    // Habits
                    String tempCleanliness = isSeekingFlatmate ? _cleanliness : _ownerCleanlinessLevel;
                    String tempSocialHabits = isSeekingFlatmate ? _socialHabits : _ownerSocialPreferences;
                    String tempWorkSchedule = isSeekingFlatmate ? _workSchedule : _ownerWorkSchedule;
                    String tempNoiseLevel = isSeekingFlatmate ? _noiseLevel : _ownerNoiseLevel;
                    String tempSmokingHabits = isSeekingFlatmate ? _smokingHabits : _ownerSmokingHabit;
                    String tempDrinkingHabits = isSeekingFlatmate ? _drinkingHabits : _ownerDrinkingHabit;
                    String tempFoodPreference = isSeekingFlatmate ? _foodPreference : _ownerFoodPreference;
                    String tempGuestsFrequency = isSeekingFlatmate ? _guestsFrequency : _ownerGuestsOvernightPolicy;
                    String tempVisitorsPolicy = isSeekingFlatmate ? _visitorsPolicy : _ownerVisitorsPolicy;
                    String tempPetOwnership = isSeekingFlatmate ? _petOwnership : _ownerPetOwnership;
                    String tempPetTolerance = isSeekingFlatmate ? _petTolerance : _ownerPetTolerance;
                    String tempSleepingSchedule = isSeekingFlatmate ? _sleepingSchedule : _ownerSleepingSchedule;
                    String tempSharingCommonSpaces = isSeekingFlatmate ? _sharingCommonSpaces : _ownerSharingCommonSpaces;
                    String tempGuestsPolicyOvernight = isSeekingFlatmate ? _guestsPolicyOvernight : _ownerGuestsOvernightPolicy;
                    String tempPersonalSpaceVsSocialization = isSeekingFlatmate ? _personalSpaceVsSocialization : _ownerPersonalSpaceVsSocialization;
                    // --- End: Logic to preserve common fields ---

                    setState(() {
                      _selectedProfileType = newValue;

                      // --- Start: Apply preserved common fields to the new profile type ---
                      if (newValue == 'Seeking a Flatmate') {
                        _gender = tempGender;
                        _age = tempAge;
                        _occupation = tempOccupation;
                        _bio = tempBio;
                        _currentLocation = tempCurrentLocation;
                        _desiredCity = tempDesiredCity;
                        _budgetMin = tempBudgetMin;
                        _budgetMax = tempBudgetMax;
                        _areaPreference = tempAreaPreference;

                        _cleanliness = tempCleanliness;
                        _socialHabits = tempSocialHabits;
                        _workSchedule = tempWorkSchedule;
                        _noiseLevel = tempNoiseLevel;
                        _smokingHabits = tempSmokingHabits;
                        _drinkingHabits = tempDrinkingHabits;
                        _foodPreference = tempFoodPreference;
                        _guestsFrequency = tempGuestsFrequency;
                        _visitorsPolicy = tempVisitorsPolicy;
                        _petOwnership = tempPetOwnership;
                        _petTolerance = tempPetTolerance;
                        _sleepingSchedule = tempSleepingSchedule;
                        _workSchedule = tempWorkSchedule;
                        _sharingCommonSpaces = tempSharingCommonSpaces;
                        _guestsPolicyOvernight = tempGuestsPolicyOvernight;
                        _personalSpaceVsSocialization = tempPersonalSpaceVsSocialization;
                      } else { // Listing a Flat
                        _ownerGender = tempGender;
                        _ownerAge = tempAge;
                        _ownerOccupation = tempOccupation;
                        _ownerBio = tempBio;
                        _ownerCurrentCity = tempCurrentLocation;
                        _ownerDesiredCity = tempDesiredCity;
                        _ownerBudgetMin = tempBudgetMin;
                        _ownerBudgetMax = tempBudgetMax;
                        _ownerAreaPreference = tempAreaPreference;

                        _ownerCleanlinessLevel = tempCleanliness;
                        _ownerSocialPreferences = tempSocialHabits;
                        _ownerWorkSchedule = tempWorkSchedule;
                        _ownerNoiseLevel = tempNoiseLevel;
                        _ownerSmokingHabit = tempSmokingHabits;
                        _ownerDrinkingHabit = tempDrinkingHabits;
                        _ownerFoodPreference = tempFoodPreference;
                        _ownerGuestsOvernightPolicy = tempGuestsFrequency;
                        _ownerVisitorsPolicy = tempVisitorsPolicy;
                        _ownerPetOwnership = tempPetOwnership;
                        _ownerPetTolerance = tempPetTolerance;
                        _ownerSleepingSchedule = tempSleepingSchedule;
                        _ownerWorkSchedule = tempWorkSchedule;
                        _ownerSharingCommonSpaces = tempSharingCommonSpaces;
                        _ownerGuestsOvernightPolicy = tempGuestsPolicyOvernight;
                        _ownerPersonalSpaceVsSocialization = tempPersonalSpaceVsSocialization;
                      }
                      // --- End: Apply preserved common fields to the new profile type ---
                    });
                  }
                },
                style: const TextStyle(fontSize: 16, color: Colors.black), // Text style for dropdown
                icon: const Icon(Icons.arrow_drop_down, color: Colors.redAccent), // Dropdown icon color
              ),
              const SizedBox(height: 24), // Increased spacing after dropdown

              if (isSeekingFlatmate) // Use the boolean derived from _selectedProfileType
              // Fields for Seeking Flatmate Profile
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      onSaved: (value) => _name = value!,
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16), // Spacing for text fields
                    TextFormField(
                      initialValue: _age,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _age = value!,
                      validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
                    ),
                    _QuestionWidget(
                      title: "Your Gender",
                      subtitle: "Tell us your gender",
                      options: const ['Male', 'Female', 'Other'],
                      initialValue: _gender,
                      onSelected: (selected) {
                        setState(() => _gender = selected);
                      },
                    ),
                    TextFormField(
                      initialValue: _occupation,
                      decoration: const InputDecoration(labelText: 'Occupation'),
                      onSaved: (value) => _occupation = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _currentLocation,
                      decoration: const InputDecoration(labelText: 'Your Current City'),
                      onSaved: (value) => _currentLocation = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _desiredCity,
                      decoration: const InputDecoration(labelText: 'Desired City for Flat'),
                      onSaved: (value) => _desiredCity = value!,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(_moveInDate == null
                          ? 'Select Move-in Date'
                          : 'Move-in Date: ${DateFormat('yyyy-MM-dd').format(_moveInDate!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _moveInDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2028),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _moveInDate = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _budgetMin,
                      decoration: const InputDecoration(labelText: 'Minimum Budget'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _budgetMin = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _budgetMax,
                      decoration: const InputDecoration(labelText: 'Maximum Budget'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _budgetMax = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _areaPreference,
                      decoration: const InputDecoration(labelText: 'Preferred Area/Locality'),
                      onSaved: (value) => _areaPreference = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _bio,
                      decoration: const InputDecoration(labelText: 'Tell us about yourself (Bio)'),
                      maxLines: 3,
                      onSaved: (value) => _bio = value!,
                    ),
                    _QuestionWidget(
                      title: "Cleanliness",
                      subtitle: "How clean are you?",
                      options: const ['Very Clean', 'Moderately Clean', 'A Little Messy', 'Messy'],
                      initialValue: _cleanliness,
                      onSelected: (selected) {
                        setState(() => _cleanliness = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Social Habits",
                      subtitle: "How social are you?",
                      options: const ['Very Social', 'Moderately Social', 'Prefer Solitude', 'Introvert'],
                      initialValue: _socialHabits,
                      onSelected: (selected) {
                        setState(() => _socialHabits = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Work Schedule",
                      subtitle: "What's your typical work schedule?",
                      options: const ['9-5 Job', 'Flexible Hours', 'Night Shifts', 'Student', 'Freelancer'],
                      initialValue: _workSchedule,
                      onSelected: (selected) {
                        setState(() => _workSchedule = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Noise Level",
                      subtitle: "What's your preferred noise level?",
                      options: const ['Quiet', 'Moderate', 'Lively'],
                      initialValue: _noiseLevel,
                      onSelected: (selected) {
                        setState(() => _noiseLevel = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Smoking Habits",
                      subtitle: "Do you smoke?",
                      options: const ['Yes', 'No', 'Occasionally'],
                      initialValue: _smokingHabits,
                      onSelected: (selected) {
                        setState(() => _smokingHabits = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Drinking Habits",
                      subtitle: "Do you drink?",
                      options: const ['Yes', 'No', 'Socially'],
                      initialValue: _drinkingHabits,
                      onSelected: (selected) {
                        setState(() => _drinkingHabits = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Food Preference",
                      subtitle: "What are your food preferences?",
                      options: const ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian'],
                      initialValue: _foodPreference,
                      onSelected: (selected) {
                        setState(() => _foodPreference = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Guests Frequency",
                      subtitle: "How often do you have guests?",
                      options: const ['Rarely', 'Occasionally', 'Frequently'],
                      initialValue: _guestsFrequency,
                      onSelected: (selected) {
                        setState(() => _guestsFrequency = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Visitors Policy",
                      subtitle: "What is your policy on visitors?",
                      options: ['Open to visitors', 'Visitors occasionally', 'No visitors'],
                      initialValue: _visitorsPolicy,
                      onSelected: (selected) {
                        setState(() => _visitorsPolicy = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Pet Ownership",
                      subtitle: "Do you own pets?",
                      options: const ['Yes', 'No'],
                      initialValue: _petOwnership,
                      onSelected: (selected) {
                        setState(() => _petOwnership = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Pet Tolerance",
                      subtitle: "Are you comfortable living with pets?",
                      options: const ['Very comfortable', 'Moderately comfortable', 'Not comfortable'],
                      initialValue: _petTolerance,
                      onSelected: (selected) {
                        setState(() => _petTolerance = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Sleeping Schedule",
                      subtitle: "What's your typical sleeping schedule?",
                      options: const ['Early Bird', 'Night Owl', 'Flexible'],
                      initialValue: _sleepingSchedule,
                      onSelected: (selected) {
                        setState(() => _sleepingSchedule = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Sharing Common Spaces",
                      subtitle: "How do you prefer sharing common spaces?",
                      options: const ['Strictly divided', 'Flexible and shared', 'Minimal sharing'],
                      initialValue: _sharingCommonSpaces,
                      onSelected: (selected) {
                        setState(() => _sharingCommonSpaces = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Guests Overnight Policy",
                      subtitle: "What's your policy on overnight guests?",
                      options: ['Allowed with notice', 'Rarely allowed', 'Not allowed'],
                      initialValue: _guestsPolicyOvernight,
                      onSelected: (selected) {
                        setState(() => _guestsPolicyOvernight = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Personal Space vs. Socialization",
                      subtitle: "How do you balance personal space and socialization?",
                      options: const ['Need a lot of personal space', 'Balance of both', 'Enjoy socializing often'],
                      initialValue: _personalSpaceVsSocialization,
                      onSelected: (selected) {
                        setState(() => _personalSpaceVsSocialization = selected);
                      },
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Interests & Hobbies",
                      subtitle: "What are your interests/hobbies?",
                      options: const ['Reading', 'Sports', 'Gaming', 'Cooking', 'Movies', 'Music', 'Traveling', 'Art', 'Fitness', 'Outdoors'],
                      onSelected: (selected) {
                        setState(() => _interests = selected);
                      },
                      initialValues: _interests,
                    ),
                    _QuestionWidget(
                      title: "Personality Traits",
                      subtitle: "How would you describe your personality?",
                      options: const ['Extrovert', 'Introvert', 'Ambivert', 'Reserved', 'Outgoing'],
                      initialValue: _personality,
                      onSelected: (selected) {
                        setState(() => _personality = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Preferred Flatmate Gender",
                      subtitle: "What gender do you prefer your flatmate to be?",
                      options: const ['Male', 'Female', 'No Preference'],
                      initialValue: _flatmateGenderPreference,
                      onSelected: (selected) {
                        setState(() => _flatmateGenderPreference = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Preferred Flatmate Age",
                      subtitle: "What age group do you prefer your flatmate to be in?",
                      options: const ['18-24', '25-34', '35-44', '45+', 'No Preference'],
                      initialValue: _flatmateAgePreference,
                      onSelected: (selected) {
                        setState(() => _flatmateAgePreference = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Preferred Flatmate Occupation",
                      subtitle: "What occupation do you prefer your flatmate to have?",
                      options: const ['Student', 'Working Professional', 'Freelancer', 'No Preference'],
                      initialValue: _flatmateOccupationPreference,
                      onSelected: (selected) {
                        setState(() => _flatmateOccupationPreference = selected);
                      },
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Ideal Flatmate Qualities",
                      subtitle: "What qualities do you look for in an ideal flatmate?",
                      options: const ['Responsible', 'Friendly', 'Quiet', 'Clean', 'Respectful', 'Communicative', 'Independent', 'Organized'],
                      onSelected: (selected) {
                        setState(() => _idealQualities = selected);
                      },
                      initialValues: _idealQualities,
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Deal Breakers",
                      subtitle: "Are there any deal breakers for you?",
                      options: const ['Smoking', 'Excessive Noise', 'Untidiness', 'Frequent Parties', 'Pets', 'Guests staying over without notice'],
                      onSelected: (selected) {
                        setState(() => _dealBreakers = selected);
                      },
                      initialValues: _dealBreakers,
                    ),
                    _QuestionWidget(
                      title: "Relationship Goal with Flatmate",
                      subtitle: "What kind of relationship are you looking for with your flatmate?",
                      options: const ['Just roommates', 'Friendly', 'Close friends'],
                      initialValue: _relationshipGoal,
                      onSelected: (selected) {
                        setState(() => _relationshipGoal = selected);
                      },
                    ),
                    TextFormField(
                      initialValue: _locationPreference,
                      decoration: const InputDecoration(labelText: 'Preferred Location (Flat Requirement)'),
                      onSaved: (value) => _locationPreference = value!,
                    ),
                    const SizedBox(height: 16),
                    _QuestionWidget(
                      title: "Flat Preference",
                      subtitle: "What type of flat are you looking for?",
                      options: const ['Studio', '1BHK', '2BHK', '3BHK+', 'Villa', 'Apartment'],
                      initialValue: _flatPreference,
                      onSelected: (selected) {
                        setState(() => _flatPreference = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Furnished/Unfurnished",
                      subtitle: "Do you prefer a furnished or unfurnished flat?",
                      options: const ['Furnished', 'Unfurnished', 'Either'],
                      initialValue: _furnishedUnfurnished,
                      onSelected: (selected) {
                        setState(() => _furnishedUnfurnished = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Attached Bathroom",
                      subtitle: "Do you require an attached bathroom?",
                      options: const ['Yes', 'No', 'Preferred'],
                      initialValue: _attachedBathroom,
                      onSelected: (selected) {
                        setState(() => _attachedBathroom = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Balcony",
                      subtitle: "Is a balcony important to you?",
                      options: const ['Yes', 'No', 'Not a priority'],
                      initialValue: _balcony,
                      onSelected: (selected) {
                        setState(() => _balcony = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Parking",
                      subtitle: "Do you need parking space?",
                      options: const ['Yes', 'No'],
                      initialValue: _parking,
                      onSelected: (selected) {
                        setState(() => _parking = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Wi-Fi Availability",
                      subtitle: "Is Wi-Fi a necessity?",
                      options: const ['Yes', 'No', 'Can arrange myself'],
                      initialValue: _wifi,
                      onSelected: (selected) {
                        setState(() => _wifi = selected);
                      },
                    ),
                  ],
                )
              else
              // Fields for Flat Listing Profile
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: _ownerName,
                      decoration: const InputDecoration(labelText: 'Your Name'),
                      onSaved: (value) => _ownerName = value!,
                      validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _ownerAge,
                      decoration: const InputDecoration(labelText: 'Your Age'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _ownerAge = value!,
                      validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
                    ),
                    _QuestionWidget(
                      title: "Your Gender",
                      subtitle: "Tell us your gender",
                      options: const ['Male', 'Female', 'Other'],
                      initialValue: _ownerGender,
                      onSelected: (selected) {
                        setState(() => _ownerGender = selected);
                      },
                    ),
                    TextFormField(
                      initialValue: _ownerOccupation,
                      decoration: const InputDecoration(labelText: 'Your Occupation'),
                      onSaved: (value) => _ownerOccupation = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _ownerBio,
                      decoration: const InputDecoration(labelText: 'Tell us about yourself (Bio)'),
                      maxLines: 3,
                      onSaved: (value) => _ownerBio = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _ownerCurrentCity,
                      decoration: const InputDecoration(labelText: 'Current City'),
                      onSaved: (value) => _ownerCurrentCity = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _ownerDesiredCity,
                      decoration: const InputDecoration(labelText: 'Desired City (for flatmate, if applicable)'),
                      onSaved: (value) => _ownerDesiredCity = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _ownerBudgetMin,
                      decoration: const InputDecoration(labelText: 'Minimum Budget (for flatmate)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _ownerBudgetMin = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _ownerBudgetMax,
                      decoration: const InputDecoration(labelText: 'Maximum Budget (for flatmate)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _ownerBudgetMax = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _ownerAreaPreference,
                      decoration: const InputDecoration(labelText: 'Preferred Area/Locality (for flatmate)'),
                      onSaved: (value) => _ownerAreaPreference = value!,
                    ),
                    _QuestionWidget(
                      title: "Smoking Habit",
                      subtitle: "What is your smoking habit?",
                      options: const ['Smoker', 'Non-Smoker', 'Occasionally'],
                      initialValue: _ownerSmokingHabit,
                      onSelected: (selected) {
                        setState(() => _ownerSmokingHabit = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Drinking Habit",
                      subtitle: "What is your drinking habit?",
                      options: const ['Drinker', 'Non-Drinker', 'Socially'],
                      initialValue: _ownerDrinkingHabit,
                      onSelected: (selected) {
                        setState(() => _ownerDrinkingHabit = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Food Preference",
                      subtitle: "What is your food preference?",
                      options: const ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian'],
                      initialValue: _ownerFoodPreference,
                      onSelected: (selected) {
                        setState(() => _ownerFoodPreference = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Cleanliness Level",
                      subtitle: "How clean are you?",
                      options: const ['Very Clean', 'Moderately Clean', 'A Little Messy', 'Messy'],
                      initialValue: _ownerCleanlinessLevel,
                      onSelected: (selected) {
                        setState(() => _ownerCleanlinessLevel = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Noise Level",
                      subtitle: "What is your preferred noise level?",
                      options: const ['Quiet', 'Moderate', 'Lively'],
                      initialValue: _ownerNoiseLevel,
                      onSelected: (selected) {
                        setState(() => _ownerNoiseLevel = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Social Preferences",
                      subtitle: "What are your social preferences?",
                      options: const ['Very Social', 'Moderately Social', 'Prefer Solitude', 'Introvert'],
                      initialValue: _ownerSocialPreferences,
                      onSelected: (selected) {
                        setState(() => _ownerSocialPreferences = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Visitors Policy",
                      subtitle: "What is your policy on visitors?",
                      options: ['Open to visitors', 'Visitors occasionally', 'No visitors'],
                      initialValue: _ownerVisitorsPolicy,
                      onSelected: (selected) {
                        setState(() => _ownerVisitorsPolicy = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Pet Ownership",
                      subtitle: "Do you own pets?",
                      options: const ['Yes', 'No'],
                      initialValue: _ownerPetOwnership,
                      onSelected: (selected) {
                        setState(() => _ownerPetOwnership = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Pet Tolerance",
                      subtitle: "Are you comfortable living with pets?",
                      options: const ['Very comfortable', 'Moderately comfortable', 'Not comfortable'],
                      initialValue: _ownerPetTolerance,
                      onSelected: (selected) {
                        setState(() => _ownerPetTolerance = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Sleeping Schedule",
                      subtitle: "What's your typical sleeping schedule?",
                      options: const ['Early Bird', 'Night Owl', 'Flexible'],
                      initialValue: _ownerSleepingSchedule,
                      onSelected: (selected) {
                        setState(() => _ownerSleepingSchedule = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Work Schedule",
                      subtitle: "What's your typical work schedule?",
                      options: const ['9-5 Job', 'Flexible Hours', 'Night Shifts', 'Student', 'Freelancer'],
                      initialValue: _ownerWorkSchedule,
                      onSelected: (selected) {
                        setState(() => _ownerWorkSchedule = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Sharing Common Spaces",
                      subtitle: "How do you prefer sharing common spaces?",
                      options: const ['Strictly divided', 'Flexible and shared', 'Minimal sharing'],
                      initialValue: _ownerSharingCommonSpaces,
                      onSelected: (selected) {
                        setState(() => _ownerSharingCommonSpaces = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Guests Overnight Policy",
                      subtitle: "What's your policy on overnight guests?",
                      options: ['Allowed with notice', 'Rarely allowed', 'Not allowed'],
                      initialValue: _ownerGuestsOvernightPolicy,
                      onSelected: (selected) {
                        setState(() => _ownerGuestsOvernightPolicy = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Personal Space vs. Socialization",
                      subtitle: "How do you balance personal space and socialization?",
                      options: const ['Need a lot of personal space', 'Balance of both', 'Enjoy socializing often'],
                      initialValue: _ownerPersonalSpaceVsSocialization,
                      onSelected: (selected) {
                        setState(() => _ownerPersonalSpaceVsSocialization = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Flat Type",
                      subtitle: "What type of flat is it?",
                      options: const ['Studio', '1BHK', '2BHK', '3BHK+', 'Villa', 'Apartment'],
                      initialValue: _flatType,
                      onSelected: (selected) {
                        setState(() => _flatType = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Furnished Status",
                      subtitle: "Is the flat furnished, semi-furnished or unfurnished?",
                      options: const ['Furnished', 'Semi-Furnished', 'Unfurnished'],
                      initialValue: _furnishedStatus,
                      onSelected: (selected) {
                        setState(() => _furnishedStatus = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Available For",
                      subtitle: "Who is the flat available for?",
                      options: const ['Boys', 'Girls', 'Couple', 'Family', 'Anyone'],
                      initialValue: _availableFor,
                      onSelected: (selected) {
                        setState(() => _availableFor = selected);
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(_availabilityDate == null
                          ? 'Select Availability Date'
                          : 'Availability Date: ${DateFormat('yyyy-MM-dd').format(_availabilityDate!)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _availabilityDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2028),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _availabilityDate = pickedDate;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _rentPrice,
                      decoration: const InputDecoration(labelText: 'Rent Price'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _rentPrice = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _depositAmount,
                      decoration: const InputDecoration(labelText: 'Deposit Amount'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (value) => _depositAmount = value!,
                    ),
                    _QuestionWidget(
                      title: "Bathroom Type",
                      subtitle: "Is the bathroom attached or shared?",
                      options: const ['Attached', 'Shared'],
                      initialValue: _bathroomType,
                      onSelected: (selected) {
                        setState(() => _bathroomType = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Balcony Availability",
                      subtitle: "Is a balcony available?",
                      options: const ['Yes', 'No'],
                      initialValue: _balconyAvailability,
                      onSelected: (selected) {
                        setState(() => _balconyAvailability = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Parking Availability",
                      subtitle: "Is parking available?",
                      options: const ['Yes', 'No'],
                      initialValue: _parkingAvailability,
                      onSelected: (selected) {
                        setState(() => _parkingAvailability = selected);
                      },
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Amenities",
                      subtitle: "What amenities does your flat offer?",
                      options: const ['Furnished', 'AC', 'Washing Machine', 'Refrigerator', 'Geyser', 'Parking', 'Internet', 'Gym', 'Swimming Pool', 'Balcony'],
                      onSelected: (selected) {
                        setState(() => _flatAmenities = selected);
                      },
                      initialValues: _flatAmenities,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _address,
                      decoration: const InputDecoration(labelText: 'Flat Address'),
                      onSaved: (value) => _address = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _landmark,
                      decoration: const InputDecoration(labelText: 'Nearby Landmark'),
                      onSaved: (value) => _landmark = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _flatDescription,
                      decoration: const InputDecoration(labelText: 'Flat Description'),
                      maxLines: 3,
                      onSaved: (value) => _flatDescription = value!,
                    ),
                    _QuestionWidget(
                      title: "Preferred Flatmate Gender",
                      subtitle: "What gender do you prefer your flatmate to be?",
                      options: const ['Male', 'Female', 'No Preference'],
                      initialValue: _preferredGender,
                      onSelected: (selected) {
                        setState(() => _preferredGender = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Preferred Flatmate Age Group",
                      subtitle: "What age group do you prefer your flatmate to be in?",
                      options: const ['18-24', '25-34', '35-44', '45+', 'No Preference'],
                      initialValue: _preferredAgeGroup,
                      onSelected: (selected) {
                        setState(() => _preferredAgeGroup = selected);
                      },
                    ),
                    _QuestionWidget(
                      title: "Preferred Flatmate Occupation",
                      subtitle: "What occupation do you prefer your flatmate to have?",
                      options: const ['Student', 'Working Professional', 'Freelancer', 'No Preference'],
                      initialValue: _preferredOccupation,
                      onSelected: (selected) {
                        setState(() => _preferredOccupation = selected);
                      },
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Preferred Habits",
                      subtitle: "What habits do you prefer in your flatmate?",
                      options: const ['Non-Smoker', 'Non-Drinker', 'Clean', 'Quiet', 'Social'],
                      onSelected: (selected) {
                        setState(() => _preferredHabits = selected);
                      },
                      initialValues: _preferredHabits,
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Ideal Flatmate Qualities",
                      subtitle: "What qualities do you look for in an ideal flatmate?",
                      options: const ['Responsible', 'Friendly', 'Quiet', 'Clean', 'Respectful', 'Communicative', 'Independent', 'Organized'],
                      onSelected: (selected) {
                        setState(() => _flatmateIdealQualities = selected);
                      },
                      initialValues: _flatmateIdealQualities,
                    ),
                    _MultiSelectQuestionWidget(
                      title: "Flatmate Deal Breakers",
                      subtitle: "Are there any deal breakers for you in a flatmate?",
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