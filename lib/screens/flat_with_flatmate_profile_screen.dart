// flat_with_flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'package:intl/intl.dart'; // Ensure this is imported for date formatting

// Data model to hold all the answers for the user seeking a flat
class SeekingFlatmateProfile {
  // Basic Info
  String name = '';
  String age = '';
  String gender = '';
  String occupation = '';
  String currentLocation = '';
  String desiredCity = '';
  String moveInDate = ''; // Changed to String to store formatted date
  String budgetMin = '';
  String budgetMax = '';
  String areaPreference = '';
  String bio = '';

  // Habits
  String cleanliness = '';
  String socialHabits = '';
  String workSchedule = '';
  String noiseLevel = '';
  String smokingHabits = '';
  String drinkingHabits = '';
  String foodPreference = '';
  String guestsFrequency = '';
  String visitorsPolicy = '';
  String petOwnership = '';
  String petTolerance = '';
  String sleepingSchedule = '';
  String sharingCommonSpaces = '';
  String guestsPolicyOvernight = '';
  String personalSpaceVsSocialization = '';

  // Looking For Preferences
  List<String> interests = []; // Consider how this will be handled in UI
  String personality = '';
  String flatmateGenderPreference = '';
  String flatmateAgeRangePreference = ''; // New field
  String flatmateOccupationPreference = ''; // New field
  String flatmateSmokingPreference = ''; // New field
  String flatmateDrinkingPreference = ''; // New field
  String flatmatePetPreference = ''; // New field
  String flatmateCleanlinessPreference = ''; // New field
  String flatmateNoiseLevelPreference = ''; // New field
  String flatmateSocialPreference = ''; // New field
  String flatmatePreferredCommuteTime = ''; // New field
  String flatmateTransportationAccess = ''; // New field
  String flatmateParkingAvailability = ''; // New field
  String flatmateProximityToAmenities = ''; // New field

  // Flat Preferences
  String leaseDuration = '';
  String furnishingPreference = '';
  String propertyType = '';
  String flatAmenities = '';
  String numberOfBedrooms = ''; // New field
  String numberOfBathrooms = ''; // New field
  String hasBalcony = ''; // New field
  String hasGarden = ''; // New field

  // Financials
  String rentPaymentFrequency = '';
  String billsPaymentResponsibility = '';
  String securityDepositExpectation = ''; // New field
  String financialStabilityProofComfort = ''; // New field

  // Other
  String anyOtherComments = '';

  SeekingFlatmateProfile();

  // Method to convert the object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      // Basic Info
      'name': name,
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'currentLocation': currentLocation,
      'desiredCity': desiredCity,
      'moveInDate': moveInDate,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'areaPreference': areaPreference,
      'bio': bio,

      // Habits
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

      // Looking For Preferences
      'interests': interests,
      'personality': personality,
      'flatmateGenderPreference': flatmateGenderPreference,
      'flatmateAgeRangePreference': flatmateAgeRangePreference,
      'flatmateOccupationPreference': flatmateOccupationPreference,
      'flatmateSmokingPreference': flatmateSmokingPreference,
      'flatmateDrinkingPreference': flatmateDrinkingPreference,
      'flatmatePetPreference': flatmatePetPreference,
      'flatmateCleanlinessPreference': flatmateCleanlinessPreference,
      'flatmateNoiseLevelPreference': flatmateNoiseLevelPreference,
      'flatmateSocialPreference': flatmateSocialPreference,
      'flatmatePreferredCommuteTime': flatmatePreferredCommuteTime,
      'flatmateTransportationAccess': flatmateTransportationAccess,
      'flatmateParkingAvailability': flatmateParkingAvailability,
      'flatmateProximityToAmenities': flatmateProximityToAmenities,

      // Flat Preferences
      'leaseDuration': leaseDuration,
      'furnishingPreference': furnishingPreference,
      'propertyType': propertyType,
      'flatAmenities': flatAmenities,
      'numberOfBedrooms': numberOfBedrooms,
      'numberOfBathrooms': numberOfBathrooms,
      'hasBalcony': hasBalcony,
      'hasGarden': hasGarden,

      // Financials
      'rentPaymentFrequency': rentPaymentFrequency,
      'billsPaymentResponsibility': billsPaymentResponsibility,
      'securityDepositExpectation': securityDepositExpectation,
      'financialStabilityProofComfort': financialStabilityProofComfort,

      // Other
      'anyOtherComments': anyOtherComments,
    };
  }
}

class FlatWithFlatmateProfileScreen extends StatefulWidget {
  const FlatWithFlatmateProfileScreen({super.key});

  @override
  State<FlatWithFlatmateProfileScreen> createState() =>
      _FlatWithFlatmateProfileScreenState();
}

class _FlatWithFlatmateProfileScreenState
    extends State<FlatWithFlatmateProfileScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final SeekingFlatmateProfile _profile = SeekingFlatmateProfile();

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _currentLocationController =
  TextEditingController();
  final TextEditingController _desiredCityController = TextEditingController();
  final TextEditingController _moveInDateController = TextEditingController();
  final TextEditingController _budgetMinController = TextEditingController();
  final TextEditingController _budgetMaxController = TextEditingController();
  final TextEditingController _areaPreferenceController =
  TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _flatAmenitiesController =
  TextEditingController();
  final TextEditingController _numberOfBedroomsController =
  TextEditingController();
  final TextEditingController _numberOfBathroomsController =
  TextEditingController();
  final TextEditingController _securityDepositExpectationController =
  TextEditingController();
  final TextEditingController _anyOtherCommentsController =
  TextEditingController();
  final TextEditingController _flatmatePreferredCommuteTimeController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });

    // Add listeners to update _profile on text changes
    _nameController.addListener(() {
      _profile.name = _nameController.text;
    });
    _ageController.addListener(() {
      _profile.age = _ageController.text;
    });
    _occupationController.addListener(() {
      _profile.occupation = _occupationController.text;
    });
    _currentLocationController.addListener(() {
      _profile.currentLocation = _currentLocationController.text;
    });
    _desiredCityController.addListener(() {
      _profile.desiredCity = _desiredCityController.text;
    });
    _moveInDateController.addListener(() {
      _profile.moveInDate = _moveInDateController.text;
    });
    _budgetMinController.addListener(() {
      _profile.budgetMin = _budgetMinController.text;
    });
    _budgetMaxController.addListener(() {
      _profile.budgetMax = _budgetMaxController.text;
    });
    _areaPreferenceController.addListener(() {
      _profile.areaPreference = _areaPreferenceController.text;
    });
    _bioController.addListener(() {
      _profile.bio = _bioController.text;
    });
    _flatAmenitiesController.addListener(() {
      _profile.flatAmenities = _flatAmenitiesController.text;
    });
    _numberOfBedroomsController.addListener(() {
      _profile.numberOfBedrooms = _numberOfBedroomsController.text;
    });
    _numberOfBathroomsController.addListener(() {
      _profile.numberOfBathrooms = _numberOfBathroomsController.text;
    });
    _securityDepositExpectationController.addListener(() {
      _profile.securityDepositExpectation =
          _securityDepositExpectationController.text;
    });
    _anyOtherCommentsController.addListener(() {
      _profile.anyOtherComments = _anyOtherCommentsController.text;
    });
    _flatmatePreferredCommuteTimeController.addListener(() {
      _profile.flatmatePreferredCommuteTime =
          _flatmatePreferredCommuteTimeController.text;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _currentLocationController.dispose();
    _desiredCityController.dispose();
    _moveInDateController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _areaPreferenceController.dispose();
    _bioController.dispose();
    _flatAmenitiesController.dispose();
    _numberOfBedroomsController.dispose();
    _numberOfBathroomsController.dispose();
    _securityDepositExpectationController.dispose();
    _anyOtherCommentsController.dispose();
    _flatmatePreferredCommuteTimeController.dispose();
    super.dispose();
  }

  List<Widget> get _pages {
    return [
      // Page 1: Name
      _buildTextQuestion(
        title: "What's your name?",
        subtitle: "This will be visible to potential flatmates.",
        hintText: "Enter your name",
        controller: _nameController,
      ),
      // Page 2: Age
      _buildTextQuestion(
        title: "How old are you?",
        subtitle: "This helps us match you with suitable flatmates.",
        hintText: "Enter your age",
        controller: _ageController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      // Page 3: Gender
      SingleChoiceQuestionWidget(
        title: "What's your gender?",
        subtitle: "This helps in finding compatible matches.",
        options: ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
        onSelected: (value) {
          setState(() {
            _profile.gender = value;
          });
        },
        initialValue: _profile.gender,
      ),
      // Page 4: Occupation
      _buildTextQuestion(
        title: "What's your occupation?",
        subtitle: "Are you a student, working professional, or something else?",
        hintText: "e.g., Software Engineer, Student, Artist",
        controller: _occupationController,
      ),
      // Page 5: Current Location
      _buildTextQuestion(
        title: "Which city are you currently in?",
        subtitle: "Your current location helps us understand your needs.",
        hintText: "e.g., Mumbai, Bangalore",
        controller: _currentLocationController,
      ),
      // Page 6: Desired City
      _buildTextQuestion(
        title: "Which city are you looking for a flat in?",
        subtitle: "This is the primary location for your flatmate search.",
        hintText: "e.g., Pune, Hyderabad",
        controller: _desiredCityController,
      ),
      // Page 7: Move-in Date
      _buildDateQuestion(
        title: "When are you looking to move in?",
        subtitle: "Select your ideal move-in date.",
        controller: _moveInDateController,
        onDateSelected: (selectedDate) {
          setState(() {
            _profile.moveInDate = DateFormat('dd/MM/yyyy').format(selectedDate);
          });
        },
      ),
      // Page 8: Budget Min
      _buildTextQuestion(
        title: "What's your minimum monthly budget for rent?",
        subtitle: "Please enter the amount in INR.",
        hintText: "e.g., 10000",
        controller: _budgetMinController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      // Page 9: Budget Max
      _buildTextQuestion(
        title: "What's your maximum monthly budget for rent?",
        subtitle: "Please enter the amount in INR.",
        hintText: "e.g., 25000",
        controller: _budgetMaxController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      // Page 10: Area Preference
      _buildTextQuestion(
        title: "Do you have any preferred areas or localities?",
        subtitle: "List a few areas you'd like to live in.",
        hintText: "e.g., Koregaon Park, Viman Nagar",
        controller: _areaPreferenceController,
      ),
      // Page 11: Bio
      _buildTextQuestion(
        title: "Tell us a bit about yourself.",
        subtitle: "Share your hobbies, interests, and what you're like as a flatmate.",
        hintText: "I'm a quiet person who enjoys reading...",
        controller: _bioController,
        maxLines: 5,
      ),
      // Page 12: Cleanliness
      SingleChoiceQuestionWidget(
        title: "How would you describe your cleanliness level?",
        subtitle: "Are you tidy, messy, or somewhere in between?",
        options: ['Very tidy', 'Average', 'Relaxed'],
        onSelected: (value) {
          setState(() {
            _profile.cleanliness = value;
          });
        },
        initialValue: _profile.cleanliness,
      ),
      // Page 13: Social Habits
      SingleChoiceQuestionWidget(
        title: "What are your social habits?",
        subtitle: "Do you prefer a quiet space or a social environment?",
        options: ['Quiet & Private', 'Balanced', 'Social & Lively'],
        onSelected: (value) {
          setState(() {
            _profile.socialHabits = value;
          });
        },
        initialValue: _profile.socialHabits,
      ),
      // Page 14: Work Schedule
      SingleChoiceQuestionWidget(
        title: "What's your typical work schedule?",
        subtitle: "Day shift, night shift, or remote?",
        options: ['Day shift', 'Night shift', 'Remote', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.workSchedule = value;
          });
        },
        initialValue: _profile.workSchedule,
      ),
      // Page 15: Noise Level
      SingleChoiceQuestionWidget(
        title: "What's your preferred noise level in a flat?",
        subtitle: "How quiet or lively do you prefer the home to be?",
        options: ['Very quiet', 'Moderate noise', 'Lively', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.noiseLevel = value;
          });
        },
        initialValue: _profile.noiseLevel,
      ),
      // Page 16: Smoking Habits
      SingleChoiceQuestionWidget(
        title: "What's your smoking habit?",
        subtitle: "Be honest, it helps find a compatible living situation.",
        options: ['Non-smoker', 'Occasional smoker', 'Regular smoker'],
        onSelected: (value) {
          setState(() {
            _profile.smokingHabits = value;
          });
        },
        initialValue: _profile.smokingHabits,
      ),
      // Page 17: Drinking Habits
      SingleChoiceQuestionWidget(
        title: "What's your drinking habit?",
        subtitle: "How often do you consume alcohol?",
        options: ['Non-drinker', 'Social drinker', 'Regular drinker'],
        onSelected: (value) {
          setState(() {
            _profile.drinkingHabits = value;
          });
        },
        initialValue: _profile.drinkingHabits,
      ),
      // Page 18: Food Preference
      SingleChoiceQuestionWidget(
        title: "What's your food preference?",
        subtitle: "Vegetarian, Non-vegetarian, or something else?",
        options: ['Vegetarian', 'Non-vegetarian', 'Eggetarian', 'Vegan'],
        onSelected: (value) {
          setState(() {
            _profile.foodPreference = value;
          });
        },
        initialValue: _profile.foodPreference,
      ),
      // Page 19: Guests Frequency
      SingleChoiceQuestionWidget(
        title: "How often do you expect to have guests over?",
        subtitle: "This helps manage expectations with flatmates.",
        options: ['Rarely', 'Occasionally', 'Frequently'],
        onSelected: (value) {
          setState(() {
            _profile.guestsFrequency = value;
          });
        },
        initialValue: _profile.guestsFrequency,
      ),
      // Page 20: Visitors Policy
      SingleChoiceQuestionWidget(
        title: "What's your stance on visitors?",
        subtitle: "How often do you expect to have guests over?",
        options: ['No visitors', 'Occasional visitors', 'Frequent visitors'],
        onSelected: (value) {
          setState(() {
            _profile.visitorsPolicy = value;
          });
        },
        initialValue: _profile.visitorsPolicy,
      ),
      // Page 21: Pet Ownership
      SingleChoiceQuestionWidget(
        title: "Do you own any pets?",
        subtitle: "Please specify if you plan to bring them.",
        options: ['Yes', 'No'],
        onSelected: (value) {
          setState(() {
            _profile.petOwnership = value;
          });
        },
        initialValue: _profile.petOwnership,
      ),
      // Page 22: Pet Tolerance
      SingleChoiceQuestionWidget(
        title: "Are you comfortable living with pets?",
        subtitle: "This includes pets owned by other flatmates.",
        options: ['Yes', 'No', 'Prefer not to say'],
        onSelected: (value) {
          setState(() {
            _profile.petTolerance = value;
          });
        },
        initialValue: _profile.petTolerance,
      ),
      // Page 23: Sleeping Schedule
      SingleChoiceQuestionWidget(
        title: "What's your typical sleeping schedule?",
        subtitle: "Early bird, night owl, or flexible?",
        options: ['Early riser', 'Night owl', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.sleepingSchedule = value;
          });
        },
        initialValue: _profile.sleepingSchedule,
      ),
      // Page 24: Sharing Common Spaces
      SingleChoiceQuestionWidget(
        title: "How do you prefer sharing common spaces?",
        subtitle: "Do you like to keep them shared or more private?",
        options: ['Shared often', 'Shared sometimes', 'More private'],
        onSelected: (value) {
          setState(() {
            _profile.sharingCommonSpaces = value;
          });
        },
        initialValue: _profile.sharingCommonSpaces,
      ),
      // Page 25: Guests Policy Overnight
      SingleChoiceQuestionWidget(
        title: "What's your policy on overnight guests?",
        subtitle: "Are they allowed, and if so, how often?",
        options: ['No overnight guests', 'Occasional overnight guests', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.guestsPolicyOvernight = value;
          });
        },
        initialValue: _profile.guestsPolicyOvernight,
      ),
      // Page 26: Personal Space vs. Socialization
      SingleChoiceQuestionWidget(
        title: "How important is personal space versus socialization?",
        subtitle: "Do you prefer more alone time or communal activities?",
        options: ['High personal space', 'Balanced', 'High socialization'],
        onSelected: (value) {
          setState(() {
            _profile.personalSpaceVsSocialization = value;
          });
        },
        initialValue: _profile.personalSpaceVsSocialization,
      ),
      // Page 27: Flatmate Gender Preference
      SingleChoiceQuestionWidget(
        title: "Do you have a gender preference for your flatmates?",
        subtitle: "This helps in finding compatible living arrangements.",
        options: ['Male', 'Female', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateGenderPreference = value;
          });
        },
        initialValue: _profile.flatmateGenderPreference,
      ),
      // Page 28: Flatmate Age Range Preference
      SingleChoiceQuestionWidget(
        title: "What's your preferred age range for flatmates?",
        subtitle: "Are you looking for someone around your age?",
        options: ['18-24', '25-30', '30-40', '40+', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateAgeRangePreference = value;
          });
        },
        initialValue: _profile.flatmateAgeRangePreference,
      ),
      // Page 29: Flatmate Occupation Preference
      SingleChoiceQuestionWidget(
        title: "Do you have an occupation preference for flatmates?",
        subtitle: "Student, professional, or open to all?",
        options: ['Student', 'Working Professional', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateOccupationPreference = value;
          });
        },
        initialValue: _profile.flatmateOccupationPreference,
      ),
      // Page 30: Flatmate Smoking Preference
      SingleChoiceQuestionWidget(
        title: "What's your preference regarding flatmate smoking habits?",
        subtitle: "Are you okay with smokers?",
        options: ['Non-smoker preferred', 'Occasional smoker ok', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateSmokingPreference = value;
          });
        },
        initialValue: _profile.flatmateSmokingPreference,
      ),
      // Page 31: Flatmate Drinking Preference
      SingleChoiceQuestionWidget(
        title: "What's your preference regarding flatmate drinking habits?",
        subtitle: "Are you okay with drinkers?",
        options: ['Non-drinker preferred', 'Social drinker ok', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateDrinkingPreference = value;
          });
        },
        initialValue: _profile.flatmateDrinkingPreference,
      ),
      // Page 32: Flatmate Pet Preference
      SingleChoiceQuestionWidget(
        title: "What's your preference regarding flatmate pet ownership?",
        subtitle: "Are you okay with flatmates having pets?",
        options: ['Pets welcome', 'No pets preferred', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.flatmatePetPreference = value;
          });
        },
        initialValue: _profile.flatmatePetPreference,
      ),
      // Page 33: Flatmate Cleanliness Preference
      SingleChoiceQuestionWidget(
        title: "What's your preferred cleanliness level for flatmates?",
        subtitle: "How tidy should your flatmates be?",
        options: ['Very tidy', 'Average', 'Relaxed'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateCleanlinessPreference = value;
          });
        },
        initialValue: _profile.flatmateCleanlinessPreference,
      ),
      // Page 34: Flatmate Noise Level Preference
      SingleChoiceQuestionWidget(
        title: "What's your preferred noise level for the flat?",
        subtitle: "Do you prefer a quiet or more lively environment?",
        options: ['Very quiet', 'Moderate noise', 'Lively', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateNoiseLevelPreference = value;
          });
        },
        initialValue: _profile.flatmateNoiseLevelPreference,
      ),
      // Page 35: Flatmate Social Preference
      SingleChoiceQuestionWidget(
        title: "What's your social preference for flatmates?",
        subtitle: "Do you prefer social flatmates or independent ones?",
        options: ['Social', 'Independent', 'Balanced', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateSocialPreference = value;
          });
        },
        initialValue: _profile.flatmateSocialPreference,
      ),
      // Page 36: Flatmate Preferred Commute Time
      _buildTextQuestion(
        title: "What's your flatmate's preferred maximum commute time?",
        subtitle: "Specify in minutes.",
        hintText: "e.g., 30 minutes",
        controller: _flatmatePreferredCommuteTimeController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      // Page 37: Flatmate Transportation Access
      SingleChoiceQuestionWidget(
        title: "How important is access to public transportation for your flatmate?",
        subtitle: "Do they rely on buses, metro, etc.?",
        options: ['Very important', 'Moderately important', 'Not important'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateTransportationAccess = value;
          });
        },
        initialValue: _profile.flatmateTransportationAccess,
      ),
      // Page 38: Flatmate Parking Availability
      SingleChoiceQuestionWidget(
        title: "How important is parking availability for your flatmate?",
        subtitle: "Do they own a vehicle?",
        options: ['Very important', 'Moderately important', 'Not important'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateParkingAvailability = value;
          });
        },
        initialValue: _profile.flatmateParkingAvailability,
      ),
      // Page 39: Flatmate Proximity to Amenities
      SingleChoiceQuestionWidget(
        title: "How important is proximity to amenities for your flatmate?",
        subtitle: "e.g., supermarkets, gyms, restaurants",
        options: ['Very important', 'Moderately important', 'Not important'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateProximityToAmenities = value;
          });
        },
        initialValue: _profile.flatmateProximityToAmenities,
      ),
      // Page 40: Lease Duration
      SingleChoiceQuestionWidget(
        title: "What's your preferred lease duration?",
        subtitle: "How long are you looking to stay?",
        options: ['Less than 6 months', '6-12 months', '1 year+', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.leaseDuration = value;
          });
        },
        initialValue: _profile.leaseDuration,
      ),
      // Page 41: Furnishing Preference
      SingleChoiceQuestionWidget(
        title: "What's your furnishing preference?",
        subtitle: "Are you looking for a furnished, semi-furnished, or unfurnished flat?",
        options: ['Furnished', 'Semi-furnished', 'Unfurnished'],
        onSelected: (value) {
          setState(() {
            _profile.furnishingPreference = value;
          });
        },
        initialValue: _profile.furnishingPreference,
      ),
      // Page 42: Property Type
      SingleChoiceQuestionWidget(
        title: "What type of property are you looking for?",
        subtitle: "Apartment, house, or something else?",
        options: ['Apartment', 'Independent House/Villa', 'Studio Apartment', 'PG/Co-living'],
        onSelected: (value) {
          setState(() {
            _profile.propertyType = value;
          });
        },
        initialValue: _profile.propertyType,
      ),
      // Page 43: Flat Amenities
      _buildTextQuestion(
        title: "What essential amenities are you looking for in a flat?",
        subtitle: "List things like AC, parking, security, etc.",
        hintText: "e.g., AC, 24/7 water, Gated Community",
        controller: _flatAmenitiesController,
        maxLines: 3,
      ),
      // Page 44: Number of Bedrooms
      SingleChoiceQuestionWidget(
        title: "How many bedrooms are you looking for?",
        subtitle: "This helps us narrow down suitable flats.",
        options: ['1BHK', '2BHK', '3BHK', '3BHK+'],
        onSelected: (value) {
          setState(() {
            _profile.numberOfBedrooms = value;
          });
        },
        initialValue: _profile.numberOfBedrooms,
      ),
      // Page 45: Number of Bathrooms
      SingleChoiceQuestionWidget(
        title: "How many bathrooms are you looking for?",
        subtitle: "This helps us narrow down suitable flats.",
        options: ['1', '2', '3', '3+'],
        onSelected: (value) {
          setState(() {
            _profile.numberOfBathrooms = value;
          });
        },
        initialValue: _profile.numberOfBathrooms,
      ),
      // Page 46: Has Balcony
      SingleChoiceQuestionWidget(
        title: "Is a balcony a must-have?",
        subtitle: "Important for fresh air and views.",
        options: ['Yes', 'No', 'Optional'],
        onSelected: (value) {
          setState(() {
            _profile.hasBalcony = value;
          });
        },
        initialValue: _profile.hasBalcony,
      ),
      // Page 47: Has Garden
      SingleChoiceQuestionWidget(
        title: "Is a garden/lawn important?",
        subtitle: "For outdoor space or pet-friendliness.",
        options: ['Yes', 'No', 'Optional'],
        onSelected: (value) {
          setState(() {
            _profile.hasGarden = value;
          });
        },
        initialValue: _profile.hasGarden,
      ),
      // Page 48: Rent Payment Frequency
      SingleChoiceQuestionWidget(
        title: "What's your preferred rent payment frequency?",
        subtitle: "Monthly, quarterly, etc.",
        options: ['Monthly', 'Quarterly', 'Annually'],
        onSelected: (value) {
          setState(() {
            _profile.rentPaymentFrequency = value;
          });
        },
        initialValue: _profile.rentPaymentFrequency,
      ),
      // Page 49: Bills Payment Responsibility
      SingleChoiceQuestionWidget(
        title: "How do you prefer to handle utility bills and other shared expenses?",
        subtitle: "Split equally, based on usage, etc.",
        options: ['Split Equally', 'Based on Usage', 'One person pays, others reimburse'],
        onSelected: (value) {
          setState(() {
            _profile.billsPaymentResponsibility = value;
          });
        },
        initialValue: _profile.billsPaymentResponsibility,
      ),
      // Page 50: Security Deposit Expectation
      _buildTextQuestion(
        title: "What's your expectation for a security deposit?",
        subtitle: "Typically 1-3 months' rent.",
        hintText: "e.g., 2 months rent",
        controller: _securityDepositExpectationController,
      ),
      // Page 51: Financial Stability Proof Comfort
      SingleChoiceQuestionWidget(
        title: "Are you comfortable providing proof of financial stability?",
        subtitle: "e.g., salary slips, bank statements.",
        options: ['Yes', 'No', 'Prefer not to say'],
        onSelected: (value) {
          setState(() {
            _profile.financialStabilityProofComfort = value;
          });
        },
        initialValue: _profile.financialStabilityProofComfort,
      ),
      // Page 52: Any Other Comments
      _buildTextQuestion(
        title: "Any other comments or specific requirements?",
        subtitle: "Include anything else that's important for your flatmate search.",
        hintText: "e.g., 'Looking for a female flatmate only', 'Need furnished room'",
        controller: _anyOtherCommentsController,
        maxLines: 5,
      ),
      // Page 53: Completion Screen
      _buildCompletionScreen(),
    ];
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (_currentPage == _pages.length - 1) {
      // This is the completion screen, so submit the profile
      _submitProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _submitProfile() async {
    // Basic validation (can be expanded)
    if (_profile.name.isEmpty || _profile.age.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields (Name and Age).')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Please log in to save your profile.')),
        );
        return;
      }

      // Save the profile to Firestore
      await FirebaseFirestore.instance
          .collection('seekingFlatmateProfiles') // A new collection for this profile type
          .doc(user.uid) // Use user's UID as document ID
          .set(_profile.toMap()); // Convert profile object to map

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flatmate seeking profile submitted successfully!')),
      );
      // You can add navigation here, e.g., Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting profile: $e')),
      );
      print('Firestore submission error: $e'); // Print error to console for debugging
    }
  }

  Widget _buildTextQuestion({
    required String title,
    required String subtitle,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateQuestion({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required Function(DateTime) onDateSelected,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Select Date',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                onDateSelected(pickedDate);
                controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline,
              color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text(
            'All Done!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your flatmate seeking profile is complete. Click below to find your perfect flat!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _submitProfile, // This will now trigger the Firebase save
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: const Text("Find my Flat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Flatmate Seeking Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: () {
                if (_currentPage == _pages.length - 2) {
                  _nextPage();
                } else {
                  _nextPage();
                }
              },
              child: Text(
                _currentPage == _pages.length - 2 ? 'Finish' : 'Skip',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _pages.length,
              backgroundColor: Colors.grey[300],
              valueColor:
              const AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics:
              const NeverScrollableScrollPhysics(), // Disable swiping
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: _pages,
            ),
          ),
          // Navigation Buttons
          if (_currentPage < _pages.length && _currentPage != _pages.length - 1)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child:
                        const Text('Back', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: const Text('Next',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// SingleChoiceQuestionWidget (remains unchanged)
class SingleChoiceQuestionWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final String? initialValue;

  const SingleChoiceQuestionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected,
    this.initialValue,
  });

  @override
  State<SingleChoiceQuestionWidget> createState() =>
      _SingleChoiceQuestionWidgetState();
}

class _SingleChoiceQuestionWidgetState
    extends State<SingleChoiceQuestionWidget> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              final option = widget.options[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ChoiceChip(
                  label: Text(option),
                  selected: _selectedValue == option,
                  onSelected: (selected) {
                    setState(() {
                      _selectedValue = selected ? option : null;
                      if (_selectedValue != null) {
                        widget.onSelected(_selectedValue!);
                      }
                    });
                  },
                  selectedColor: Colors.redAccent,
                  labelStyle: TextStyle(
                    color: _selectedValue == option ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _selectedValue == option
                          ? Colors.redAccent
                          : Colors.grey,
                      width: 1,
                    ),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}