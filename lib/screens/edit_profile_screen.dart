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
  int? age; // Changed to nullable int
  String gender = '';
  String occupation = '';
  String currentLocation = '';
  String desiredCity = ''; // New field (assuming it was new or updated)
  DateTime? moveInDate;
  int? budgetMin; // Changed to nullable int
  int? budgetMax; // Changed to nullable int
  String areaPreference = ''; // New field (assuming it was new or updated)
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
  String guestsOvernightPolicy = ''; // Corrected name
  String personalSpaceVsSocialization = ''; // New field

  // Looking For Preferences (renamed from Flat Requirements based on flat_with_flatmate_profile_screen)
  String preferredFlatType = '';
  String preferredFurnishedStatus = '';
  List<String> amenitiesDesired = [];

  // Flatmate Preferences (new section based on flat_with_flatmate_profile_screen)
  String preferredFlatmateGender = '';
  String preferredFlatmateAge = '';
  String preferredOccupation = '';
  List<String> preferredHabits = [];
  List<String> idealQualities = [];
  List<String> dealBreakers = [];


  SeekingFlatmateProfile({
    this.name = '',
    this.age,
    this.gender = '',
    this.occupation = '',
    this.currentLocation = '',
    this.desiredCity = '',
    this.moveInDate,
    this.budgetMin,
    this.budgetMax,
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
    this.guestsOvernightPolicy = '', // Corrected name
    this.personalSpaceVsSocialization = '',
    this.preferredFlatType = '',
    this.preferredFurnishedStatus = '',
    this.amenitiesDesired = const [],
    this.preferredFlatmateGender = '',
    this.preferredFlatmateAge = '',
    this.preferredOccupation = '',
    this.preferredHabits = const [],
    this.idealQualities = const [],
    this.dealBreakers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age, // Storing int? directly
      'gender': gender,
      'occupation': occupation,
      'currentLocation': currentLocation,
      'desiredCity': desiredCity,
      'moveInDate': moveInDate?.toIso8601String(),
      'budgetMin': budgetMin, // Storing int? directly
      'budgetMax': budgetMax, // Storing int? directly
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
      'guestsOvernightPolicy': guestsOvernightPolicy, // Corrected name
      'personalSpaceVsSocialization': personalSpaceVsSocialization,
      'preferredFlatType': preferredFlatType,
      'preferredFurnishedStatus': preferredFurnishedStatus,
      'amenitiesDesired': amenitiesDesired,
      'preferredFlatmateGender': preferredFlatmateGender,
      'preferredFlatmateAge': preferredFlatmateAge,
      'preferredOccupation': preferredOccupation,
      'preferredHabits': preferredHabits,
      'idealQualities': idealQualities,
      'dealBreakers': dealBreakers,
    };
  }

  factory SeekingFlatmateProfile.fromMap(Map<String, dynamic> map) {
    return SeekingFlatmateProfile(
      name: map['name'] ?? '',
      age: map['age'] as int?, // Reading as int?
      gender: map['gender'] ?? '',
      occupation: map['occupation'] ?? '',
      currentLocation: map['currentLocation'] ?? '',
      desiredCity: map['desiredCity'] ?? '',
      moveInDate: map['moveInDate'] != null ? DateTime.parse(map['moveInDate']) : null,
      budgetMin: map['budgetMin'] as int?, // Reading as int?
      budgetMax: map['budgetMax'] as int?, // Reading as int?
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
      guestsOvernightPolicy: map['guestsOvernightPolicy'] ?? '', // Corrected name
      personalSpaceVsSocialization: map['personalSpaceVsSocialization'] ?? '',
      preferredFlatType: map['preferredFlatType'] ?? '',
      preferredFurnishedStatus: map['preferredFurnishedStatus'] ?? '',
      amenitiesDesired: List<String>.from(map['amenitiesDesired'] ?? []),
      preferredFlatmateGender: map['preferredFlatmateGender'] ?? '',
      preferredFlatmateAge: map['preferredFlatmateAge'] ?? '',
      preferredOccupation: map['preferredOccupation'] ?? '',
      preferredHabits: List<String>.from(map['preferredHabits'] ?? []),
      idealQualities: List<String>.from(map['idealQualities'] ?? []),
      dealBreakers: List<String>.from(map['dealBreakers'] ?? []),
    );
  }
}

// Data model to hold all the answers for the user listing a flat
class FlatListingProfile {
  // Basic Info
  String ownerName = '';
  int? ownerAge; // Changed to nullable int
  String ownerGender = '';
  String ownerOccupation = '';
  String ownerBio = '';
  String desiredCity = '';
  String areaPreference = '';

  // Habits
  String smokingHabit = '';
  String drinkingHabit = '';
  String foodPreference = '';
  String cleanlinessLevel = '';
  String noiseLevel = '';
  String socialPreferences = '';
  String visitorsPolicy = '';
  String petOwnership = '';
  String petTolerance = '';
  String sleepingSchedule = '';
  String workSchedule = '';
  String sharingCommonSpaces = '';
  String guestsOvernightPolicy = '';
  String personalSpaceVsSocialization = '';

  // Flat Details
  String flatType = '';
  String furnishedStatus = '';
  String availableFor = '';
  DateTime? availabilityDate;
  int? rentPrice; // Changed to nullable int
  int? depositAmount; // Changed to nullable int
  String bathroomType = '';
  String balconyAvailability = '';
  String parkingAvailability = '';
  List<String> amenities = [];
  String address = '';
  String landmark = '';
  String flatDescription = '';

  // Flatmate Preferences
  String preferredGender = '';
  String preferredAgeGroup = '';
  String preferredOccupation = '';
  List<String> preferredHabits = [];
  List<String> flatmateIdealQualities = [];
  List<String> flatmateDealBreakers = [];


  FlatListingProfile({
    this.ownerName = '',
    this.ownerAge,
    this.ownerGender = '',
    this.ownerOccupation = '',
    this.ownerBio = '',
    this.desiredCity = '',
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
    this.rentPrice,
    this.depositAmount,
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
      'ownerAge': ownerAge, // Storing int? directly
      'ownerGender': ownerGender,
      'ownerOccupation': ownerOccupation,
      'ownerBio': ownerBio,
      'desiredCity': desiredCity,
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
      'rentPrice': rentPrice, // Storing int? directly
      'depositAmount': depositAmount, // Storing int? directly
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
      ownerAge: map['ownerAge'] as int?, // Reading as int?
      ownerGender: map['ownerGender'] ?? '',
      ownerOccupation: map['ownerOccupation'] ?? '',
      ownerBio: map['ownerBio'] ?? '',
      desiredCity: map['desiredCity'] ?? '',
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
      rentPrice: map['rentPrice'] as int?, // Reading as int?
      depositAmount: map['depositAmount'] as int?, // Reading as int?
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
      flatmateDealBreakers: List<String>.from(map['flatmateDealBreakers'] ?? []),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User? _currentUser;
  bool _isLoading = false;

  // Profile data
  String _profileType = 'SeekingFlatmateProfile'; // Or 'FlatListingProfile'
  // Initialize with empty profiles
  SeekingFlatmateProfile _seekingFlatmateProfile = SeekingFlatmateProfile();
  FlatListingProfile _flatListingProfile = FlatListingProfile();

  // Controllers for text fields - these need to be initialized in initState and disposed
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _occupationController;
  late TextEditingController _currentLocationController;
  late TextEditingController _desiredCityController;
  late TextEditingController _bioController;
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerAgeController;
  late TextEditingController _ownerOccupationController;
  late TextEditingController _ownerBioController;
  late TextEditingController _ownerDesiredCityController;
  late TextEditingController _ownerAreaPreferenceController;
  late TextEditingController _rentPriceController;
  late TextEditingController _depositAmountController;
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _flatDescriptionController;
  late TextEditingController _budgetMinController; // Added
  late TextEditingController _budgetMaxController; // Added


  // Single choice selections
  String? _gender;
  String? _cleanliness;
  String? _socialHabits;
  String? _workSchedule;
  String? _noiseLevel;
  String? _smokingHabits;
  String? _drinkingHabits;
  String? _foodPreference;
  String? _guestsFrequency;
  String? _visitorsPolicy;
  String? _petOwnership;
  String? _petTolerance;
  String? _sleepingSchedule;
  String? _sharingCommonSpaces;
  String? _guestsOvernightPolicy;
  String? _personalSpaceVsSocialization;
  String? _preferredFlatType;
  String? _preferredFurnishedStatus;
  String? _preferredFlatmateGender;
  String? _preferredFlatmateAge;
  String? _preferredOccupation;

  // FlatListingProfile specific single choices
  String? _ownerGender;
  String? _ownerSmokingHabit;
  String? _ownerDrinkingHabit;
  String? _ownerFoodPreference;
  String? _ownerCleanlinessLevel;
  String? _ownerNoiseLevel;
  String? _ownerSocialPreferences;
  String? _ownerVisitorsPolicy;
  String? _ownerPetOwnership;
  String? _ownerPetTolerance;
  String? _ownerSleepingSchedule;
  String? _ownerWorkSchedule;
  String? _ownerSharingCommonSpaces;
  String? _ownerGuestsOvernightPolicy;
  String? _ownerPersonalSpaceVsSocialization;
  String? _ownerFlatType;
  String? _ownerFurnishedStatus;
  String? _ownerAvailableFor;
  String? _ownerBathroomType;
  String? _ownerBalconyAvailability;
  String? _ownerParkingAvailability;
  String? _ownerPreferredGender;
  String? _ownerPreferredAgeGroup;
  String? _ownerPreferredOccupation;

  // Multi-choice selections
  List<String> _amenitiesDesired = [];
  List<String> _preferredHabits = [];
  List<String> _idealQualities = [];
  List<String> _dealBreakers = [];
  List<String> _ownerAmenities = [];
  List<String> _ownerPreferredHabits = [];
  List<String> _ownerFlatmateIdealQualities = [];
  List<String> _ownerFlatmateDealBreakers = [];

  // Date selection
  DateTime? _moveInDate;
  DateTime? _ownerAvailabilityDate;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _occupationController = TextEditingController();
    _currentLocationController = TextEditingController();
    _desiredCityController = TextEditingController();
    _bioController = TextEditingController();
    _ownerNameController = TextEditingController();
    _ownerAgeController = TextEditingController();
    _ownerOccupationController = TextEditingController();
    _ownerBioController = TextEditingController();
    _ownerDesiredCityController = TextEditingController();
    _ownerAreaPreferenceController = TextEditingController();
    _rentPriceController = TextEditingController();
    _depositAmountController = TextEditingController();
    _addressController = TextEditingController();
    _landmarkController = TextEditingController();
    _flatDescriptionController = TextEditingController();
    _budgetMinController = TextEditingController(); // Initialize
    _budgetMaxController = TextEditingController(); // Initialize
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _currentLocationController.dispose();
    _desiredCityController.dispose();
    _bioController.dispose();
    _ownerNameController.dispose();
    _ownerAgeController.dispose();
    _ownerOccupationController.dispose();
    _ownerBioController.dispose();
    _ownerDesiredCityController.dispose();
    _ownerAreaPreferenceController.dispose();
    _rentPriceController.dispose();
    _depositAmountController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _flatDescriptionController.dispose();
    _budgetMinController.dispose(); // Dispose
    _budgetMaxController.dispose(); // Dispose
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch directly from the 'users' collection
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(_currentUser!.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        String? savedProfileType = data['profileType'] as String?;

        if (savedProfileType == 'SeekingFlatmateProfile') {
          _profileType = 'SeekingFlatmateProfile';
          _seekingFlatmateProfile = SeekingFlatmateProfile.fromMap(data);

          // Populate controllers and state variables for SeekingFlatmateProfile
          _nameController.text = _seekingFlatmateProfile.name;
          _ageController.text = _seekingFlatmateProfile.age?.toString() ?? '';
          _occupationController.text = _seekingFlatmateProfile.occupation;
          _currentLocationController.text = _seekingFlatmateProfile.currentLocation;
          _desiredCityController.text = _seekingFlatmateProfile.desiredCity;
          _bioController.text = _seekingFlatmateProfile.bio;
          _budgetMinController.text = _seekingFlatmateProfile.budgetMin?.toString() ?? ''; // Populate
          _budgetMaxController.text = _seekingFlatmateProfile.budgetMax?.toString() ?? ''; // Populate

          _gender = _seekingFlatmateProfile.gender;
          _moveInDate = _seekingFlatmateProfile.moveInDate; // Load moveInDate
          _cleanliness = _seekingFlatmateProfile.cleanliness;
          _socialHabits = _seekingFlatmateProfile.socialHabits;
          _workSchedule = _seekingFlatmateProfile.workSchedule;
          _noiseLevel = _seekingFlatmateProfile.noiseLevel;
          _smokingHabits = _seekingFlatmateProfile.smokingHabits;
          _drinkingHabits = _seekingFlatmateProfile.drinkingHabits;
          _foodPreference = _seekingFlatmateProfile.foodPreference;
          _guestsFrequency = _seekingFlatmateProfile.guestsFrequency;
          _visitorsPolicy = _seekingFlatmateProfile.visitorsPolicy;
          _petOwnership = _seekingFlatmateProfile.petOwnership;
          _petTolerance = _seekingFlatmateProfile.petTolerance;
          _sleepingSchedule = _seekingFlatmateProfile.sleepingSchedule;
          _sharingCommonSpaces = _seekingFlatmateProfile.sharingCommonSpaces;
          _guestsOvernightPolicy = _seekingFlatmateProfile.guestsOvernightPolicy;
          _personalSpaceVsSocialization = _seekingFlatmateProfile.personalSpaceVsSocialization;
          _preferredFlatType = _seekingFlatmateProfile.preferredFlatType;
          _preferredFurnishedStatus = _seekingFlatmateProfile.preferredFurnishedStatus;
          _amenitiesDesired = _seekingFlatmateProfile.amenitiesDesired;
          _preferredFlatmateGender = _seekingFlatmateProfile.preferredFlatmateGender;
          _preferredFlatmateAge = _seekingFlatmateProfile.preferredFlatmateAge;
          _preferredOccupation = _seekingFlatmateProfile.preferredOccupation;
          _preferredHabits = _seekingFlatmateProfile.preferredHabits;
          _idealQualities = _seekingFlatmateProfile.idealQualities;
          _dealBreakers = _seekingFlatmateProfile.dealBreakers;

        } else if (savedProfileType == 'FlatListingProfile') {
          _profileType = 'FlatListingProfile';
          _flatListingProfile = FlatListingProfile.fromMap(data);

          // Populate controllers and state variables for FlatListingProfile
          _ownerNameController.text = _flatListingProfile.ownerName;
          _ownerAgeController.text = _flatListingProfile.ownerAge?.toString() ?? '';
          _ownerOccupationController.text = _flatListingProfile.ownerOccupation;
          _ownerBioController.text = _flatListingProfile.ownerBio;
          _ownerDesiredCityController.text = _flatListingProfile.desiredCity;
          _ownerAreaPreferenceController.text = _flatListingProfile.areaPreference;
          _rentPriceController.text = _flatListingProfile.rentPrice?.toString() ?? '';
          _depositAmountController.text = _flatListingProfile.depositAmount?.toString() ?? '';
          _addressController.text = _flatListingProfile.address;
          _landmarkController.text = _flatListingProfile.landmark;
          _flatDescriptionController.text = _flatListingProfile.flatDescription;

          _ownerGender = _flatListingProfile.ownerGender;
          _ownerSmokingHabit = _flatListingProfile.smokingHabit;
          _ownerDrinkingHabit = _flatListingProfile.drinkingHabit;
          _ownerFoodPreference = _flatListingProfile.foodPreference;
          _ownerCleanlinessLevel = _flatListingProfile.cleanlinessLevel;
          _ownerNoiseLevel = _flatListingProfile.noiseLevel;
          _ownerSocialPreferences = _flatListingProfile.socialPreferences;
          _ownerVisitorsPolicy = _flatListingProfile.visitorsPolicy;
          _ownerPetOwnership = _flatListingProfile.petOwnership;
          _ownerPetTolerance = _flatListingProfile.petTolerance;
          _ownerSleepingSchedule = _flatListingProfile.sleepingSchedule;
          _ownerWorkSchedule = _flatListingProfile.workSchedule;
          _ownerSharingCommonSpaces = _flatListingProfile.sharingCommonSpaces;
          _ownerGuestsOvernightPolicy = _flatListingProfile.guestsOvernightPolicy;
          _ownerPersonalSpaceVsSocialization = _flatListingProfile.personalSpaceVsSocialization;
          _ownerFlatType = _flatListingProfile.flatType;
          _ownerFurnishedStatus = _flatListingProfile.furnishedStatus;
          _ownerAvailableFor = _flatListingProfile.availableFor;
          _ownerAvailabilityDate = _flatListingProfile.availabilityDate; // Load availabilityDate
          _ownerBathroomType = _flatListingProfile.bathroomType;
          _ownerBalconyAvailability = _flatListingProfile.balconyAvailability;
          _ownerParkingAvailability = _flatListingProfile.parkingAvailability;
          _ownerAmenities = _flatListingProfile.amenities;
          _ownerPreferredGender = _flatListingProfile.preferredGender;
          _ownerPreferredAgeGroup = _flatListingProfile.preferredAgeGroup;
          _ownerPreferredOccupation = _flatListingProfile.preferredOccupation;
          _ownerPreferredHabits = _flatListingProfile.preferredHabits;
          _ownerFlatmateIdealQualities = _flatListingProfile.flatmateIdealQualities;
          _ownerFlatmateDealBreakers = _flatListingProfile.flatmateDealBreakers;

        } else {
          // If profileType field is missing or unknown, default to SeekingFlatmateProfile
          _profileType = 'SeekingFlatmateProfile';
        }
      } else {
        // No profile found for the user, default to SeekingFlatmateProfile
        _profileType = 'SeekingFlatmateProfile';
      }
    } catch (e) {
      print("Error loading profile: $e");
      // Handle error, maybe show a snackbar to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> dataToSave;

      if (_profileType == 'SeekingFlatmateProfile') {
        _seekingFlatmateProfile.name = _nameController.text;
        _seekingFlatmateProfile.age = int.tryParse(_ageController.text);
        _seekingFlatmateProfile.gender = _gender ?? '';
        _seekingFlatmateProfile.occupation = _occupationController.text;
        _seekingFlatmateProfile.currentLocation = _currentLocationController.text;
        _seekingFlatmateProfile.desiredCity = _desiredCityController.text;
        _seekingFlatmateProfile.moveInDate = _moveInDate;
        _seekingFlatmateProfile.budgetMin = int.tryParse(_budgetMinController.text); // Use correct controller
        _seekingFlatmateProfile.budgetMax = int.tryParse(_budgetMaxController.text); // Use correct controller
        _seekingFlatmateProfile.areaPreference = _seekingFlatmateProfile.areaPreference; // This should come from a controller/field if editable
        _seekingFlatmateProfile.bio = _bioController.text;
        _seekingFlatmateProfile.cleanliness = _cleanliness ?? '';
        _seekingFlatmateProfile.socialHabits = _socialHabits ?? '';
        _seekingFlatmateProfile.workSchedule = _workSchedule ?? '';
        _seekingFlatmateProfile.noiseLevel = _noiseLevel ?? '';
        _seekingFlatmateProfile.smokingHabits = _smokingHabits ?? '';
        _seekingFlatmateProfile.drinkingHabits = _drinkingHabits ?? '';
        _seekingFlatmateProfile.foodPreference = _foodPreference ?? '';
        _seekingFlatmateProfile.guestsFrequency = _guestsFrequency ?? '';
        _seekingFlatmateProfile.visitorsPolicy = _visitorsPolicy ?? '';
        _seekingFlatmateProfile.petOwnership = _petOwnership ?? '';
        _seekingFlatmateProfile.petTolerance = _petTolerance ?? '';
        _seekingFlatmateProfile.sleepingSchedule = _sleepingSchedule ?? '';
        _seekingFlatmateProfile.sharingCommonSpaces = _sharingCommonSpaces ?? '';
        _seekingFlatmateProfile.guestsOvernightPolicy = _guestsOvernightPolicy ?? '';
        _seekingFlatmateProfile.personalSpaceVsSocialization = _personalSpaceVsSocialization ?? '';
        _seekingFlatmateProfile.preferredFlatType = _preferredFlatType ?? '';
        _seekingFlatmateProfile.preferredFurnishedStatus = _preferredFurnishedStatus ?? '';
        _seekingFlatmateProfile.amenitiesDesired = _amenitiesDesired;
        _seekingFlatmateProfile.preferredFlatmateGender = _preferredFlatmateGender ?? '';
        _seekingFlatmateProfile.preferredFlatmateAge = _preferredFlatmateAge ?? '';
        _seekingFlatmateProfile.preferredOccupation = _preferredOccupation ?? '';
        _seekingFlatmateProfile.preferredHabits = _preferredHabits;
        _seekingFlatmateProfile.idealQualities = _idealQualities;
        _seekingFlatmateProfile.dealBreakers = _dealBreakers;

        dataToSave = _seekingFlatmateProfile.toMap();
        dataToSave['profileType'] = 'SeekingFlatmateProfile'; // Explicitly add profile type
      } else { // FlatListingProfile
        _flatListingProfile.ownerName = _ownerNameController.text;
        _flatListingProfile.ownerAge = int.tryParse(_ownerAgeController.text);
        _flatListingProfile.ownerGender = _ownerGender ?? '';
        _flatListingProfile.ownerOccupation = _ownerOccupationController.text;
        _flatListingProfile.ownerBio = _ownerBioController.text;
        _flatListingProfile.desiredCity = _ownerDesiredCityController.text;
        _flatListingProfile.areaPreference = _ownerAreaPreferenceController.text;
        _flatListingProfile.smokingHabit = _ownerSmokingHabit ?? '';
        _flatListingProfile.drinkingHabit = _ownerDrinkingHabit ?? '';
        _flatListingProfile.foodPreference = _ownerFoodPreference ?? '';
        _flatListingProfile.cleanlinessLevel = _ownerCleanlinessLevel ?? '';
        _flatListingProfile.noiseLevel = _ownerNoiseLevel ?? '';
        _flatListingProfile.socialPreferences = _ownerSocialPreferences ?? '';
        _flatListingProfile.visitorsPolicy = _ownerVisitorsPolicy ?? '';
        _flatListingProfile.petOwnership = _ownerPetOwnership ?? '';
        _flatListingProfile.petTolerance = _ownerPetTolerance ?? '';
        _flatListingProfile.sleepingSchedule = _ownerSleepingSchedule ?? '';
        _flatListingProfile.workSchedule = _ownerWorkSchedule ?? '';
        _flatListingProfile.sharingCommonSpaces = _ownerSharingCommonSpaces ?? '';
        _flatListingProfile.guestsOvernightPolicy = _ownerGuestsOvernightPolicy ?? '';
        _flatListingProfile.personalSpaceVsSocialization = _ownerPersonalSpaceVsSocialization ?? '';
        _flatListingProfile.flatType = _ownerFlatType ?? '';
        _flatListingProfile.furnishedStatus = _ownerFurnishedStatus ?? '';
        _flatListingProfile.availableFor = _ownerAvailableFor ?? '';
        _flatListingProfile.availabilityDate = _ownerAvailabilityDate;
        _flatListingProfile.rentPrice = int.tryParse(_rentPriceController.text);
        _flatListingProfile.depositAmount = int.tryParse(_depositAmountController.text);
        _flatListingProfile.bathroomType = _ownerBathroomType ?? '';
        _flatListingProfile.balconyAvailability = _ownerBalconyAvailability ?? '';
        _flatListingProfile.parkingAvailability = _ownerParkingAvailability ?? '';
        _flatListingProfile.amenities = _ownerAmenities;
        _flatListingProfile.address = _addressController.text;
        _flatListingProfile.landmark = _landmarkController.text;
        _flatListingProfile.flatDescription = _flatDescriptionController.text;
        _flatListingProfile.preferredGender = _ownerPreferredGender ?? '';
        _flatListingProfile.preferredAgeGroup = _ownerPreferredAgeGroup ?? '';
        _flatListingProfile.preferredOccupation = _ownerPreferredOccupation ?? '';
        _flatListingProfile.preferredHabits = _ownerPreferredHabits;
        _flatListingProfile.flatmateIdealQualities = _ownerFlatmateIdealQualities;
        _flatListingProfile.flatmateDealBreakers = _ownerFlatmateDealBreakers;

        dataToSave = _flatListingProfile.toMap();
        dataToSave['profileType'] = 'FlatListingProfile'; // Explicitly add profile type
      }

      // Save to the 'users' collection with the user's UID as the document ID
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .set(dataToSave);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
          );
          if (picked != null && picked != selectedDate) {
            onDateSelected(picked);
          }
        },
        child: AbsorbPointer(
          child: TextField(
            controller: TextEditingController(
              text: selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : '',
            ),
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleChoiceQuestion({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: options.map((option) {
              final isSelected = selectedValue == option;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    onSelected(option);
                  }
                },
                selectedColor: Colors.redAccent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiChoiceQuestion({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    List<String> updatedSelection = List.from(selectedValues);
                    if (selected) {
                      updatedSelection.add(option);
                    } else {
                      updatedSelection.remove(option);
                    }
                    onSelected(updatedSelection);
                  });
                },
                selectedColor: Colors.redAccent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Type Selection
            _buildSingleChoiceQuestion(
              title: "What are you looking for?",
              options: const ['Seeking a Flatmate', 'Listing a Flat'],
              selectedValue: _profileType == 'SeekingFlatmateProfile'
                  ? 'Seeking a Flatmate'
                  : 'Listing a Flat',
              onSelected: (selected) {
                setState(() {
                  _profileType = selected == 'Seeking a Flatmate'
                      ? 'SeekingFlatmateProfile'
                      : 'FlatListingProfile';
                });
              },
            ),
            const SizedBox(height: 20),

            // Dynamically show forms based on profile type
            if (_profileType == 'SeekingFlatmateProfile')
              _buildSeekingFlatmateForm(),
            if (_profileType == 'FlatListingProfile')
              _buildFlatListingForm(),

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
    );
  }

  Widget _buildSeekingFlatmateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Basic Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _buildTextField(controller: _nameController, label: 'Name'),
        _buildTextField(controller: _ageController, label: 'Age', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        _buildSingleChoiceQuestion(
          title: "Gender",
          options: const ['Male', 'Female', 'Other'],
          selectedValue: _gender,
          onSelected: (selected) {
            setState(() => _gender = selected);
          },
        ),
        _buildTextField(controller: _occupationController, label: 'Occupation'),
        _buildTextField(controller: _currentLocationController, label: 'Current Location'),
        _buildTextField(controller: _desiredCityController, label: 'Desired City'),
        _buildDatePickerField(
          label: 'Move-in Date',
          selectedDate: _moveInDate,
          onDateSelected: (date) {
            setState(() => _moveInDate = date);
          },
        ),
        _buildTextField(controller: _budgetMinController, label: 'Budget (Min)', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        _buildTextField(controller: _budgetMaxController, label: 'Budget (Max)', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        _buildTextField(controller: TextEditingController(text: _seekingFlatmateProfile.areaPreference), label: 'Area Preference'), // This needs a dedicated controller if editable
        _buildTextField(controller: _bioController, label: 'Bio', keyboardType: TextInputType.multiline),

        const SizedBox(height: 20),
        const Text('Habits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _buildSingleChoiceQuestion(
          title: "Cleanliness",
          options: const ['Very Clean', 'Moderately Clean', 'Flexible'],
          selectedValue: _cleanliness,
          onSelected: (selected) {
            setState(() => _cleanliness = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Social Habits",
          options: const ['Introvert', 'Extrovert', 'Balanced'],
          selectedValue: _socialHabits,
          onSelected: (selected) {
            setState(() => _socialHabits = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Work Schedule",
          options: const ['Day', 'Night', 'Flexible', 'Student'],
          selectedValue: _workSchedule,
          onSelected: (selected) {
            setState(() => _workSchedule = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Noise Level",
          options: const ['Quiet', 'Moderate', 'Lively'],
          selectedValue: _noiseLevel,
          onSelected: (selected) {
            setState(() => _noiseLevel = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Smoking Habits",
          options: const ['Non-Smoker', 'Occasional Smoker', 'Regular Smoker'],
          selectedValue: _smokingHabits,
          onSelected: (selected) {
            setState(() => _smokingHabits = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Drinking Habits",
          options: const ['Non-Drinker', 'Social Drinker', 'Frequent Drinker'],
          selectedValue: _drinkingHabits,
          onSelected: (selected) {
            setState(() => _drinkingHabits = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Food Preference",
          options: const ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian', 'Flexible'],
          selectedValue: _foodPreference,
          onSelected: (selected) {
            setState(() => _foodPreference = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Guests Frequency",
          options: const ['Never', 'Rarely', 'Sometimes', 'Frequently'],
          selectedValue: _guestsFrequency,
          onSelected: (selected) {
            setState(() => _guestsFrequency = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Visitors Policy",
          options: const ['No Visitors', 'Visitors Allowed (Day)', 'Visitors Allowed (Overnight)'],
          selectedValue: _visitorsPolicy,
          onSelected: (selected) {
            setState(() => _visitorsPolicy = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Pet Ownership",
          options: const ['No Pets', 'Have Pets (Small)', 'Have Pets (Large)'],
          selectedValue: _petOwnership,
          onSelected: (selected) {
            setState(() => _petOwnership = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Pet Tolerance",
          options: const ['Pet-Friendly', 'Tolerant to small pets', 'No pets please'],
          selectedValue: _petTolerance,
          onSelected: (selected) {
            setState(() => _petTolerance = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Sleeping Schedule",
          options: const ['Early Bird', 'Night Owl', 'Flexible'],
          selectedValue: _sleepingSchedule,
          onSelected: (selected) {
            setState(() => _sleepingSchedule = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Sharing Common Spaces",
          options: const ['Minimal Sharing', 'Moderate Sharing', 'Frequent Sharing'],
          selectedValue: _sharingCommonSpaces,
          onSelected: (selected) {
            setState(() => _sharingCommonSpaces = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Guests Overnight Policy",
          options: const ['Not Allowed', 'Allowed Rarely', 'Allowed Frequently'],
          selectedValue: _guestsOvernightPolicy,
          onSelected: (selected) {
            setState(() => _guestsOvernightPolicy = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Personal Space vs. Socialization",
          options: const ['Value Personal Space More', 'Value Socialization More', 'Balanced'],
          selectedValue: _personalSpaceVsSocialization,
          onSelected: (selected) {
            setState(() => _personalSpaceVsSocialization = selected);
          },
        ),


        const SizedBox(height: 20),
        const Text('Flat Requirements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _buildSingleChoiceQuestion(
          title: "Preferred Flat Type",
          options: const ['Studio', '1BHK', '2BHK', '3BHK+'],
          selectedValue: _preferredFlatType,
          onSelected: (selected) {
            setState(() => _preferredFlatType = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Preferred Furnished Status",
          options: const ['Furnished', 'Semi-Furnished', 'Unfurnished'],
          selectedValue: _preferredFurnishedStatus,
          onSelected: (selected) {
            setState(() => _preferredFurnishedStatus = selected);
          },
        ),
        _buildMultiChoiceQuestion(
          title: "Desired Amenities",
          options: const ['Wi-Fi', 'AC', 'Geyser', 'Washing Machine', 'Refrigerator', 'Parking', 'Balcony', 'Attached Bathroom', 'Gym', 'Swimming Pool'],
          selectedValues: _amenitiesDesired,
          onSelected: (selected) {
            setState(() => _amenitiesDesired = selected);
          },
        ),


        const SizedBox(height: 20),
        const Text('Flatmate Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _buildSingleChoiceQuestion(
          title: "Preferred Flatmate Gender",
          options: const ['Male', 'Female', 'Any'],
          selectedValue: _preferredFlatmateGender,
          onSelected: (selected) {
            setState(() => _preferredFlatmateGender = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Preferred Flatmate Age",
          options: const ['18-24', '25-34', '35-44', '45+', 'Any'],
          selectedValue: _preferredFlatmateAge,
          onSelected: (selected) {
            setState(() => _preferredFlatmateAge = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Preferred Flatmate Occupation",
          options: const ['Student', 'Working Professional', 'Any'],
          selectedValue: _preferredOccupation,
          onSelected: (selected) {
            setState(() => _preferredOccupation = selected);
          },
        ),
        _buildMultiChoiceQuestion(
          title: "Preferred Flatmate Habits",
          options: const ['Non-Smoker', 'Non-Drinker', 'Early Riser', 'Night Owl', 'Quiet', 'Social'],
          selectedValues: _preferredHabits,
          onSelected: (selected) {
            setState(() => _preferredHabits = selected);
          },
        ),
        _buildMultiChoiceQuestion(
          title: "Ideal Flatmate Qualities",
          options: const ['Respectful', 'Responsible', 'Friendly', 'Tidy', 'Communicative', 'Easy-going'],
          selectedValues: _idealQualities,
          onSelected: (selected) {
            setState(() => _idealQualities = selected);
          },
        ),
        _buildMultiChoiceQuestion(
          title: "Flatmate Deal Breakers",
          options: const ['Smoking', 'Excessive Noise', 'Untidiness', 'Frequent Parties', 'Pets', 'Guests staying over without notice'],
          selectedValues: _dealBreakers,
          onSelected: (selected) {
            setState(() => _dealBreakers = selected);
          },
        ),
      ],
    );
  }

  Widget _buildFlatListingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Owner Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _buildTextField(controller: _ownerNameController, label: 'Your Name'),
        _buildTextField(controller: _ownerAgeController, label: 'Your Age', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        _buildSingleChoiceQuestion(
          title: "Your Gender",
          options: const ['Male', 'Female', 'Other'],
          selectedValue: _ownerGender,
          onSelected: (selected) {
            setState(() => _ownerGender = selected);
          },
        ),
        _buildTextField(controller: _ownerOccupationController, label: 'Your Occupation'),
        _buildTextField(controller: _ownerBioController, label: 'Your Bio', keyboardType: TextInputType.multiline),
        _buildTextField(controller: _ownerDesiredCityController, label: 'Desired City'),
        _buildTextField(controller: _ownerAreaPreferenceController, label: 'Area Preference'),

        const SizedBox(height: 20),
        const Text('Your Habits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _buildSingleChoiceQuestion(
          title: "Smoking Habit",
          options: const ['Non-Smoker', 'Occasional Smoker', 'Regular Smoker'],
          selectedValue: _ownerSmokingHabit,
          onSelected: (selected) {
            setState(() => _ownerSmokingHabit = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Drinking Habit",
          options: const ['Non-Drinker', 'Social Drinker', 'Frequent Drinker'],
          selectedValue: _ownerDrinkingHabit,
          onSelected: (selected) {
            setState(() => _ownerDrinkingHabit = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Food Preference",
          options: const ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian', 'Flexible'],
          selectedValue: _ownerFoodPreference,
          onSelected: (selected) {
            setState(() => _ownerFoodPreference = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Cleanliness Level",
          options: const ['Very Clean', 'Moderately Clean', 'Flexible'],
          selectedValue: _ownerCleanlinessLevel,
          onSelected: (selected) {
            setState(() => _ownerCleanlinessLevel = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Noise Level",
          options: const ['Quiet', 'Moderate', 'Lively'],
          selectedValue: _ownerNoiseLevel,
          onSelected: (selected) {
            setState(() => _ownerNoiseLevel = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Social Preferences",
          options: const ['Introvert', 'Extrovert', 'Balanced'],
          selectedValue: _ownerSocialPreferences,
          onSelected: (selected) {
            setState(() => _ownerSocialPreferences = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Visitors Policy",
          options: const ['No Visitors', 'Visitors Allowed (Day)', 'Visitors Allowed (Overnight)'],
          selectedValue: _ownerVisitorsPolicy,
          onSelected: (selected) {
            setState(() => _ownerVisitorsPolicy = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Pet Ownership",
          options: const ['No Pets', 'Have Pets (Small)', 'Have Pets (Large)'],
          selectedValue: _ownerPetOwnership,
          onSelected: (selected) {
            setState(() => _ownerPetOwnership = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Pet Tolerance",
          options: const ['Pet-Friendly', 'Tolerant to small pets', 'No pets please'],
          selectedValue: _ownerPetTolerance,
          onSelected: (selected) {
            setState(() => _ownerPetTolerance = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Sleeping Schedule",
          options: const ['Early Bird', 'Night Owl', 'Flexible'],
          selectedValue: _ownerSleepingSchedule,
          onSelected: (selected) {
            setState(() => _ownerSleepingSchedule = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Work Schedule",
          options: const ['Day', 'Night', 'Flexible'],
          selectedValue: _ownerWorkSchedule,
          onSelected: (selected) {
            setState(() => _ownerWorkSchedule = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Sharing Common Spaces",
          options: const ['Minimal Sharing', 'Moderate Sharing', 'Frequent Sharing'],
          selectedValue: _ownerSharingCommonSpaces,
          onSelected: (selected) {
            setState(() => _ownerSharingCommonSpaces = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Guests Overnight Policy",
          options: const ['Not Allowed', 'Allowed Rarely', 'Allowed Frequently'],
          selectedValue: _ownerGuestsOvernightPolicy,
          onSelected: (selected) {
            setState(() => _ownerGuestsOvernightPolicy = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Personal Space vs. Socialization",
          options: const ['Value Personal Space More', 'Value Socialization More', 'Balanced'],
          selectedValue: _ownerPersonalSpaceVsSocialization,
          onSelected: (selected) {
            setState(() => _ownerPersonalSpaceVsSocialization = selected);
          },
        ),

        const SizedBox(height: 20),
        const Text('Flat Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _buildTextField(controller: _addressController, label: 'Address'),
        _buildTextField(controller: _landmarkController, label: 'Landmark'),
        _buildTextField(controller: _flatDescriptionController, label: 'Flat Description', keyboardType: TextInputType.multiline),
        _buildSingleChoiceQuestion(
          title: "Flat Type",
          options: const ['Studio', '1BHK', '2BHK', '3BHK+'],
          selectedValue: _ownerFlatType,
          onSelected: (selected) {
            setState(() => _ownerFlatType = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Furnished Status",
          options: const ['Furnished', 'Semi-Furnished', 'Unfurnished'],
          selectedValue: _ownerFurnishedStatus,
          onSelected: (selected) {
            setState(() => _ownerFurnishedStatus = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Available For",
          options: const ['Boys', 'Girls', 'Couple', 'Any'],
          selectedValue: _ownerAvailableFor,
          onSelected: (selected) {
            setState(() => _ownerAvailableFor = selected);
          },
        ),
        _buildDatePickerField(
          label: 'Availability Date',
          selectedDate: _ownerAvailabilityDate,
          onDateSelected: (date) {
            setState(() => _ownerAvailabilityDate = date);
          },
        ),
        _buildTextField(controller: _rentPriceController, label: 'Rent Price', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        _buildTextField(controller: _depositAmountController, label: 'Deposit Amount', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        _buildSingleChoiceQuestion(
          title: "Bathroom Type",
          options: const ['Attached', 'Shared'],
          selectedValue: _ownerBathroomType,
          onSelected: (selected) {
            setState(() => _ownerBathroomType = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Balcony Availability",
          options: const ['Yes', 'No'],
          selectedValue: _ownerBalconyAvailability,
          onSelected: (selected) {
            setState(() => _ownerBalconyAvailability = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Parking Availability",
          options: const ['Yes', 'No'],
          selectedValue: _ownerParkingAvailability,
          onSelected: (selected) {
            setState(() => _ownerParkingAvailability = selected);
          },
        ),
        _buildMultiChoiceQuestion(
          title: "Amenities",
          options: const ['Wi-Fi', 'AC', 'Geyser', 'Washing Machine', 'Refrigerator', 'Parking', 'Balcony', 'Attached Bathroom', 'Gym', 'Swimming Pool'],
          selectedValues: _ownerAmenities,
          onSelected: (selected) {
            setState(() => _ownerAmenities = selected);
          },
        ),

        const SizedBox(height: 20),
        const Text('Flatmate Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _buildSingleChoiceQuestion(
          title: "Preferred Gender",
          options: const ['Male', 'Female', 'Any'],
          selectedValue: _ownerPreferredGender,
          onSelected: (selected) {
            setState(() => _ownerPreferredGender = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Preferred Age Group",
          options: const ['18-24', '25-34', '35-44', '45+', 'Any'],
          selectedValue: _ownerPreferredAgeGroup,
          onSelected: (selected) {
            setState(() => _ownerPreferredAgeGroup = selected);
          },
        ),
        _buildSingleChoiceQuestion(
          title: "Preferred Occupation",
          options: const ['Student', 'Working Professional', 'Any'],
          selectedValue: _ownerPreferredOccupation,
          onSelected: (selected) {
            setState(() => _ownerPreferredOccupation = selected);
          },
        ),
        _buildMultiChoiceQuestion(
          title: "Preferred Habits",
          options: const ['Non-Smoker', 'Non-Drinker', 'Early Riser', 'Night Owl', 'Quiet', 'Social'],
          selectedValues: _ownerPreferredHabits,
          onSelected: (selected) {
            setState(() => _ownerPreferredHabits = selected);
          },
        ),
        _buildMultiChoiceQuestion(
          title: "Ideal Flatmate Qualities",
          options: const ['Respectful', 'Responsible', 'Friendly', 'Tidy', 'Communicative', 'Easy-going'],
          selectedValues: _ownerFlatmateIdealQualities,
          onSelected: (selected) {
            setState(() => _ownerFlatmateIdealQualities = selected);
          },
        ),
        _buildMultiChoiceQuestion(
          title: "Flatmate Deal Breakers",
          options: const ['Smoking', 'Excessive Noise', 'Untidiness', 'Frequent Parties', 'Pets', 'Guests staying over without notice'],
          selectedValues: _ownerFlatmateDealBreakers,
          onSelected: (selected) {
            setState(() => _ownerFlatmateDealBreakers = selected);
          },
        ),
      ],
    );
  }
}