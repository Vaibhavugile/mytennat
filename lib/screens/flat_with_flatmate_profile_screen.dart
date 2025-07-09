// lib/screens/flat_with_flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firebase Import
import 'package:firebase_auth/firebase_auth.dart';// Added Firebase Auth Import for UID and Email
import 'package:mytennat/screens/home_page.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:mytennat/data/location_data.dart'; // Adjust path as needed

// Data model to hold all the answers for the user seeking a flat
class SeekingFlatmateProfile {
  // Basic Info
  String documentId; // Added for Firestore document ID
  String? uid; // Added: To store the user ID (UID)

  String name;
  int? age; // Changed to nullable int
  String gender;
  String occupation;
  String currentLocation;
  String desiredCity; // New field
  DateTime? moveInDate;
  int? budgetMin; // Changed to nullable int
  int? budgetMax; // Changed to nullable int
  String areaPreference; // New field
  String bio;

  // Habits
  String cleanliness;
  String socialHabits;
  String workSchedule;
  String noiseLevel;
  String smokingHabits; // Updated from isSmoker
  String drinkingHabits; // Updated from drinkingHabit
  String foodPreference; // Updated from dietaryPreference
  String guestsFrequency;
  String visitorsPolicy; // New field
  String petOwnership; // Updated from hasPets
  String petTolerance; // New field
  String sleepingSchedule; // New field
  String sharingCommonSpaces; // New field
  String guestsOvernightPolicy; // New field
  String personalSpaceVsSocialization; // New field

  // Flat Requirements
  String preferredFlatType;
  String preferredFurnishedStatus;
  List<String> amenitiesDesired;

  // Flatmate Preferences
  String preferredFlatmateGender;
  String preferredFlatmateAge;
  String preferredOccupation;
  List<String> preferredHabits;
  List<String> idealQualities;
  List<String> dealBreakers;

  // Added: List of image URLs for the profile
  List<String>? imageUrls;

  SeekingFlatmateProfile({
    this.documentId = '', // Initialize documentId
    this.uid, // Initialize uid
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
    this.guestsOvernightPolicy = '',
    this.personalSpaceVsSocialization = '',
    this.preferredFlatType = '',
    this.preferredFurnishedStatus = '',
    List<String>? amenitiesDesired,
    this.preferredFlatmateGender = '',
    this.preferredFlatmateAge = '',
    this.preferredOccupation = '',
    List<String>? preferredHabits,
    List<String>? idealQualities,
    List<String>? dealBreakers,
    List<String>? imageUrls, // Added to constructor
  })  : amenitiesDesired = amenitiesDesired ?? [],
        preferredHabits = preferredHabits ?? [],
        idealQualities = idealQualities ?? [],
        dealBreakers = dealBreakers ?? [],
        imageUrls = imageUrls; // Initialize imageUrls

  // Factory constructor to create a SeekingFlatmateProfile from a map (Firestore data)
  factory SeekingFlatmateProfile.fromMap(Map<String, dynamic> data, String documentId) {
    Map<String, dynamic> habitsData = data['habits'] ?? {};
    Map<String, dynamic> flatRequirementsData = data['flatRequirements'] ?? {};
    Map<String, dynamic> flatmatePreferencesData = data['flatmatePreferences'] ?? {};

    return SeekingFlatmateProfile(
      documentId: documentId,
      uid: data['uid'] as String?,
      name: data['displayName'] as String? ?? '', // Assuming 'displayName' at root level
      age: data['age'] is int ? data['age'] : (data['age'] is String ? int.tryParse(data['age']) : null),
      gender: data['gender'] as String? ?? '',
      occupation: data['occupation'] as String? ?? '',
      currentLocation: data['currentLocation'] as String? ?? '',
      desiredCity: data['desiredCity'] as String? ?? '',
      moveInDate: (data['moveInDate'] as Timestamp?)?.toDate(),
      budgetMin: data['budgetMin'] is int ? data['budgetMin'] : (data['budgetMin'] is String ? int.tryParse(data['budgetMin']) : null),
      budgetMax: data['budgetMax'] is int ? data['budgetMax'] : (data['budgetMax'] is String ? int.tryParse(data['budgetMax']) : null),
      areaPreference: data['areaPreference'] as String? ?? '',
      bio: data['bio'] as String? ?? '',

      // Habits
      cleanliness: habitsData['cleanliness'] as String? ?? '',
      socialHabits: habitsData['socialPreferences'] as String? ?? '', // Mapped from 'socialPreferences'
      workSchedule: habitsData['workSchedule'] as String? ?? '',
      noiseLevel: habitsData['noiseTolerance'] as String? ?? '', // Mapped from 'noiseTolerance'
      smokingHabits: habitsData['smoking'] as String? ?? '', // Mapped from 'smoking'
      drinkingHabits: habitsData['drinking'] as String? ?? '', // Mapped from 'drinking'
      foodPreference: habitsData['food'] as String? ?? '', // Mapped from 'food'
      guestsFrequency: habitsData['guestsFrequency'] as String? ?? '',
      visitorsPolicy: habitsData['visitorsPolicy'] as String? ?? '',
      petOwnership: habitsData['petOwnership'] as String? ?? '',
      petTolerance: habitsData['petTolerance'] as String? ?? '',
      sleepingSchedule: habitsData['sleepingSchedule'] as String? ?? '',
      sharingCommonSpaces: habitsData['sharingCommonSpaces'] as String? ?? '',
      guestsOvernightPolicy: habitsData['guestOvernightStays'] as String? ?? '', // Mapped from 'guestOvernightStays'
      personalSpaceVsSocialization: habitsData['personalSpaceVsSocializing'] as String? ?? '',

      // Flat Requirements
      preferredFlatType: flatRequirementsData['preferredFlatType'] as String? ?? '',
      preferredFurnishedStatus: flatRequirementsData['preferredFurnishedStatus'] as String? ?? '',
      amenitiesDesired: List<String>.from(flatRequirementsData['amenitiesDesired'] as List? ?? []),

      // Flatmate Preferences
      preferredFlatmateGender: flatmatePreferencesData['preferredFlatmateGender'] as String? ?? '',
      preferredFlatmateAge: flatmatePreferencesData['preferredFlatmateAge'] as String? ?? '',
      preferredOccupation: flatmatePreferencesData['preferredOccupation'] as String? ?? '',
      preferredHabits: List<String>.from(flatmatePreferencesData['preferredHabits'] as List? ?? []),
      idealQualities: List<String>.from(flatmatePreferencesData['idealQualities'] as List? ?? []),
      dealBreakers: List<String>.from(flatmatePreferencesData['dealBreakers'] as List? ?? []),
      // Parse imageUrls from Firestore map
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  // Method to convert the object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // Include uid when converting to map
      'name': name, // This might need to be 'displayName' if that's how it's stored at root
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'currentLocation': currentLocation,
      'desiredCity': desiredCity,
      'moveInDate': moveInDate != null ? Timestamp.fromDate(moveInDate!) : null,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'areaPreference': areaPreference,
      'bio': bio,
      'habits': {
        'cleanliness': cleanliness,
        'socialPreferences': socialHabits, // Mapped to 'socialPreferences'
        'workSchedule': workSchedule,
        'noiseTolerance': noiseLevel, // Mapped to 'noiseTolerance'
        'smoking': smokingHabits, // Mapped to 'smoking'
        'drinking': drinkingHabits, // Mapped to 'drinking'
        'food': foodPreference, // Mapped to 'food'
        'guestsFrequency': guestsFrequency,
        'visitorsPolicy': visitorsPolicy,
        'petOwnership': petOwnership,
        'petTolerance': petTolerance,
        'sleepingSchedule': sleepingSchedule,
        'sharingCommonSpaces': sharingCommonSpaces,
        'guestOvernightStays': guestsOvernightPolicy, // Mapped to 'guestOvernightStays'
        'personalSpaceVsSocializing': personalSpaceVsSocialization,
      },
      'flatRequirements': {
        'preferredFlatType': preferredFlatType,
        'preferredFurnishedStatus': preferredFurnishedStatus,
        'amenitiesDesired': amenitiesDesired,
      },
      'flatmatePreferences': {
        'preferredFlatmateGender': preferredFlatmateGender,
        'preferredFlatmateAge': preferredFlatmateAge,
        'preferredOccupation': preferredOccupation,
        'preferredHabits': preferredHabits,
        'idealQualities': idealQualities,
        'dealBreakers': dealBreakers,
      },
      'imageUrls': imageUrls, // Include imageUrls when converting to map
      // Fields like 'createdAt', 'lastUpdated', 'isProfileComplete', 'uid', 'userType', 'email'
      // are typically handled outside this toMap method or added at the point of saving
      // the document to Firestore, as they might not be part of the profile data model directly.
    };
  }
}


// Stateful Widget for Single Choice Questions
class SingleChoiceQuestionWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Function(String) onSelected;
  final bool isCard;
  final String? initialValue;

  const SingleChoiceQuestionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected,
    this.isCard = false,
    this.initialValue,
  });

  @override
  State<SingleChoiceQuestionWidget> createState() =>
      _SingleChoiceQuestionWidgetState();
}

class _SingleChoiceQuestionWidgetState extends State<SingleChoiceQuestionWidget> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant SingleChoiceQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _selectedOption) {
      setState(() {
        _selectedOption = widget.initialValue;
      });
    }
  }

  Widget _buildChipOptions(List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: options.map((option) {
          final isSelected = _selectedOption == option;

          return ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) {
                setState(() {
                  _selectedOption = option;
                });
                widget.onSelected(option);
              }
            },
            selectedColor: Colors.red[700],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: isSelected ? Colors.red[700]! : Colors.grey.shade300,
                width: 2,
              ),
            ),
            backgroundColor: Colors.transparent,
            showCheckmark: true,
            checkmarkColor: Colors.white,
            elevation: 0,
            pressElevation: 0,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardOptions(List<String> options) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      padding: EdgeInsets.zero,
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = _selectedOption == option;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedOption = option;
            });
            widget.onSelected(option);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.red.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? Colors.redAccent : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.redAccent : Colors.black,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle,
                      color: Colors.redAccent, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: widget.isCard
                ? _buildCardOptions(widget.options)
                : _buildChipOptions(widget.options),
          ),
        ],
      ),
    );
  }
}

// Stateful Widget for Multi Choice Questions
class MultiChoiceQuestionWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Function(List<String>) onSelected;
  final List<String> initialValues;

  const MultiChoiceQuestionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.onSelected,
    this.initialValues = const [],
  });

  @override
  State<MultiChoiceQuestionWidget> createState() =>
      _MultiChoiceQuestionWidgetState();
}

class _MultiChoiceQuestionWidgetState extends State<MultiChoiceQuestionWidget> {
  late List<String> _selectedOptions;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List.from(widget.initialValues);
  }

  @override
  void didUpdateWidget(covariant MultiChoiceQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValues != oldWidget.initialValues) {
      setState(() {
        _selectedOptions = List.from(widget.initialValues);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.options.map((option) {
                  final isSelected = _selectedOptions.contains(option);
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(option),
                        if (isSelected) const SizedBox(width: 8),
                        if (isSelected)
                          const Icon(Icons.check,
                              size: 18, color: Colors.redAccent),
                      ],
                    ),
                    selected: isSelected,
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
                    labelPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    side: BorderSide(
                        color: isSelected
                            ? Colors.redAccent
                            : Colors.grey.shade300,
                        width: 1.5),
                    backgroundColor: Colors.grey.shade50,
                    selectedColor: Colors.red.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.redAccent : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
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
  final SeekingFlatmateProfile _seekingFlatmateProfile =
  SeekingFlatmateProfile();
  int _currentPage = 0;
  bool _isSubmitting = false; // Added for loading indicator

  // Change _pages from late final to a getter
  List<Widget> get _pages => _buildPages();

  // Declare TextEditingControllers for all text input fields
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _occupationController;
  late TextEditingController _currentLocationController;
  late TextEditingController _desiredCityController;
  late TextEditingController _budgetMinController;
  late TextEditingController _budgetMaxController;
  late TextEditingController _areaPreferenceController;
  late TextEditingController _bioController;

  // Define sections for progress tracking and navigation
  final List<Map<String, dynamic>> _sections = [
    {'title': 'Your Basic Info', 'startPage': 0, 'endPage': 10},
    {'title': 'Your Habits', 'startPage': 11, 'endPage': 24},
    {'title': 'Flat Requirements', 'startPage': 25, 'endPage': 27},
    {'title': 'Flatmate Preferences', 'startPage': 28, 'endPage': 33},
  ];

  String _getCurrentSectionTitle() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] &&
          _currentPage <= section['endPage']) {
        return section['title'];
      }
    }
    return 'Unknown Section'; // Default title if no section matches
  }

  double _getCurrentSectionProgress() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] &&
          _currentPage <= section['endPage']) {
        final int pagesInSection =
            (section['endPage'] as int) - (section['startPage'] as int) + 1;
        final int currentPageInSection =
            _currentPage - (section['startPage'] as int);
        return (currentPageInSection + 1) / pagesInSection;
      }
    }
    // Return 0.0 or a sensible default if the current page is not in any defined section
    return 0.0;
  }
  @override
  void initState() {
    super.initState();
    // Initialize controllers with current profile values
    _nameController = TextEditingController(text: _seekingFlatmateProfile.name);
    _ageController = TextEditingController(
        text: _seekingFlatmateProfile.age?.toString() ?? '');
    _occupationController =
        TextEditingController(text: _seekingFlatmateProfile.occupation);
    _currentLocationController =
        TextEditingController(text: _seekingFlatmateProfile.currentLocation);
    _desiredCityController =
        TextEditingController(text: _seekingFlatmateProfile.desiredCity);
    _budgetMinController = TextEditingController(
        text: _seekingFlatmateProfile.budgetMin?.toString() ?? '');
    _budgetMaxController = TextEditingController(
        text: _seekingFlatmateProfile.budgetMax?.toString() ?? '');
    _areaPreferenceController =
        TextEditingController(text: _seekingFlatmateProfile.areaPreference);
    _bioController = TextEditingController(text: _seekingFlatmateProfile.bio);

    // Add listeners to update the profile model as text changes
    _nameController.addListener(() {
      _seekingFlatmateProfile.name = _nameController.text;
    });
    _ageController.addListener(() {
      _seekingFlatmateProfile.age = int.tryParse(_ageController.text);
    });
    _occupationController.addListener(() {
      _seekingFlatmateProfile.occupation = _occupationController.text;
    });
    _currentLocationController.addListener(() {
      _seekingFlatmateProfile.currentLocation = _currentLocationController.text;
    });
    _desiredCityController.addListener(() {
      _seekingFlatmateProfile.desiredCity = _desiredCityController.text;
    });
    _budgetMinController.addListener(() {
      _seekingFlatmateProfile.budgetMin =
          int.tryParse(_budgetMinController.text);
    });
    _budgetMaxController.addListener(() {
      _seekingFlatmateProfile.budgetMax =
          int.tryParse(_budgetMaxController.text);
    });
    _areaPreferenceController.addListener(() {
      _seekingFlatmateProfile.areaPreference = _areaPreferenceController.text;
    });
    _bioController.addListener(() {
      _seekingFlatmateProfile.bio = _bioController.text;
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _currentLocationController.dispose();
    _desiredCityController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _areaPreferenceController.dispose();
    _bioController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // --- Common Question Builders ---

  Widget _buildTextQuestion({
    required String title,
    required String subtitle,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
    Widget? prefixIcon, // New parameter
    Widget? suffixIcon, // New parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
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
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateQuestion({
    required String title,
    required String subtitle,
    required Function(DateTime?) onDateSelected,
    DateTime? initialDate,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        DateTime? selectedDate = initialDate;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Colors.redAccent,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent, // For the "OK" and "CANCEL" buttons
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                    onDateSelected(picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        selectedDate == null ? 'Select a date' : DateFormat('dd/MM/yyyy').format(selectedDate!),
                        style: TextStyle(
                            fontSize: 16,
                            color: selectedDate == null ? Colors.grey[700] : Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildCitySelectionQuestion({
    required String title,
    required String subtitle,
    required Function(String) onCitySelected,
    required List<String> cities,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          DropdownButtonFormField<String>(
            value: initialValue == '' ? null : initialValue, // Set to null if initial value is empty string
            decoration: InputDecoration(
              hintText: "Select a city",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            items: cities.map((String city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onCitySelected(newValue);
              }
            },
            isExpanded: true,
          ),
        ],
      ),
    );
  }
  Widget _buildAreaSelectionQuestion({
    required String title,
    required String subtitle,
    required Function(String) onAreaSelected,
    required List<String> areas,
    String? initialValue,
    required String selectedCity, // To enable/disable based on city selection
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          DropdownButtonFormField<String>(
            value: initialValue == '' || !areas.contains(initialValue) ? null : initialValue,
            decoration: InputDecoration(
              hintText: selectedCity.isNotEmpty ? "Select an area" : "Select a city first",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            items: areas.map((String area) {
              return DropdownMenuItem<String>(
                value: area,
                child: Text(area),
              );
            }).toList(),
            onChanged: selectedCity.isNotEmpty // Enable only if a city is selected
                ? (String? newValue) {
              if (newValue != null) {
                onAreaSelected(newValue);
              }
            }
                : null, // Disable if no city is selected
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  // --- Page Definitions ---

  List<Widget> _buildPages() {
    return [
      // --- Section 1: Your Basic Info (Pages 0-10) ---
      // Page 0: Name
      _buildTextQuestion(
        title: "What's your name?",
        subtitle: "This will be visible to potential flatmates/owners.",
        hintText: "Enter your name",
        controller: _nameController,
      ),

      // Page 1: Age
      _buildTextQuestion(
        title: "How old are you?",
        subtitle: "This helps flatmates/owners understand your age group.",
        hintText: "e.g., 25",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _ageController,
      ),

      // Page 2: Gender
      SingleChoiceQuestionWidget(
        title: "What's your gender?",
        subtitle: "This helps potential flatmates/owners relate to you.",
        options: ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.gender = value;
          });
        },
        initialValue: _seekingFlatmateProfile.gender,
      ),

      // Page 3: Occupation
      _buildTextQuestion(
        title: "What do you do for a living?",
        subtitle: "Share your profession or student status.",
        hintText: "e.g., Software Engineer, Student, Freelancer",
        controller: _occupationController,
      ),

      // Page 4: Current Location
      _buildTextQuestion(
        title: "Where are you currently located?",
        subtitle: "This helps us understand your current city/area.",
        hintText: "e.g., Pune, Mumbai",
        controller: _currentLocationController,
      ),

      // Page 5: Desired City
      _buildCitySelectionQuestion(
        title: "Which city are you looking for a flat/flatmate in?",
        subtitle: "This helps us filter relevant listings for you.",
        onCitySelected: (value) {
          setState(() {
            _seekingFlatmateProfile.desiredCity = value;
            // Clear area preference when city changes
            _seekingFlatmateProfile.areaPreference = '';
            _areaPreferenceController.clear();
          });
        },
        initialValue: _seekingFlatmateProfile.desiredCity,
        cities: maharashtraLocations.keys.toList(),
      ),

      _buildAreaSelectionQuestion(
        title: "What are your preferred areas/localities?",
        subtitle: "Select preferred areas within ${(_seekingFlatmateProfile.desiredCity.isNotEmpty ? _seekingFlatmateProfile.desiredCity : 'the selected city')}.",
        onAreaSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.areaPreference = value;
          });
        },
        initialValue: _seekingFlatmateProfile.areaPreference,
        areas: maharashtraLocations[_seekingFlatmateProfile.desiredCity] ?? [], // Dynamically load areas
        selectedCity: _seekingFlatmateProfile.desiredCity, // Pass selected city to enable/disable
      ),

      // Page 6: Move-in Date
      _buildDateQuestion(
        title: "When are you looking to move in?",
        subtitle: "Approximate date works best.",
        onDateSelected: (date) {
          setState(() {
            _seekingFlatmateProfile.moveInDate = date;
          });
        },
        initialDate: _seekingFlatmateProfile.moveInDate,
      ),

      // Page 7: Budget Min
      _buildTextQuestion(
        title: "What is your minimum budget per month?",
        subtitle: "Enter the amount in ₹ for rent (per person, if sharing).",
        hintText: "e.g., 8000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _budgetMinController,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('₹', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      ),

      // Page 8: Budget Max
      _buildTextQuestion(
        title: "What is your maximum budget per month?",
        subtitle: "Enter the amount in ₹ for rent (per person, if sharing).",
        hintText: "e.g., 15000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _budgetMaxController,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('₹', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      ),

      // Page 9: Area Preference

      // Page 10: Bio
      _buildTextQuestion(
        title: "Tell us a bit about yourself.",
        subtitle:
        "Share something interesting! This helps others get to know you.",
        hintText: "e.g., I'm a quiet person who loves reading...",
        controller: _bioController,
        maxLines: 5,
      ),

      // --- Section 2: Your Habits (Pages 11-24) ---
      // Page 11: Cleanliness
      SingleChoiceQuestionWidget(
        title: "How clean are you?",
        subtitle: "Be honest! This helps manage expectations.",
        options: [
          'Very Tidy',
          'Moderately Tidy',
          'Flexible',
          'Can be messy at times'
        ],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.cleanliness = value;
          });
        },
        initialValue: _seekingFlatmateProfile.cleanliness,
      ),

      // Page 12: Social Habits
      SingleChoiceQuestionWidget(
        title: "What are your social habits?",
        subtitle: "Do you enjoy social gatherings or prefer quiet?",
        options: ['Social & outgoing', 'Occasional gatherings', 'Quiet & private', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.socialHabits = value;
          });
        },
        initialValue: _seekingFlatmateProfile.socialHabits,
      ),

      // Page 13: Work Schedule
      SingleChoiceQuestionWidget(
        title: "What's your typical work/study schedule?",
        subtitle: "This helps in understanding common space usage.",
        options: [
          '9-5 Office hours',
          'Freelance/Flexible hours',
          'Night shifts',
          'Student schedule',
          'Mixed'
        ],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.workSchedule = value;
          });
        },
        initialValue: _seekingFlatmateProfile.workSchedule,
      ),

      // Page 14: Noise Level
      SingleChoiceQuestionWidget(
        title: "What's your preferred noise level in a flat?",
        subtitle: "How quiet or lively do you like the home to be?",
        options: ['Very quiet', 'Moderate noise', 'Lively', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.noiseLevel = value;
          });
        },
        initialValue: _seekingFlatmateProfile.noiseLevel,
      ),

      // Page 15: Smoking Habits
      SingleChoiceQuestionWidget(
        title: "What are your smoking habits?",
        subtitle: "This helps in matching with compatible flatmates.",
        options: ['Never', 'Occasionally', 'Socially', 'Regularly'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.smokingHabits = value;
          });
        },
        initialValue: _seekingFlatmateProfile.smokingHabits,
      ),

      // Page 16: Drinking Habits
      SingleChoiceQuestionWidget(
        title: "What are your drinking habits?",
        subtitle: "Are you a non-drinker, social drinker, or regular drinker?",
        options: ['Never', 'Occasionally', 'Socially', 'Regularly'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.drinkingHabits = value;
          });
        },
        initialValue: _seekingFlatmateProfile.drinkingHabits,
      ),

      // Page 17: Food Preference
      SingleChoiceQuestionWidget(
        title: "What is your food preference?",
        subtitle: "Any specific dietary habits or restrictions?",
        options: [
          'Vegetarian',
          'Non-Vegetarian',
          'Vegan',
          'Eggetarian',
          'Jain',
          'Other'
        ],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.foodPreference = value;
          });
        },
        initialValue: _seekingFlatmateProfile.foodPreference,
      ),

      // Page 18: Guests Frequency
      SingleChoiceQuestionWidget(
        title: "How often do you have guests over?",
        subtitle: "This helps manage expectations with flatmates/owners.",
        options: [
          'Frequently (1-2 times/week)',
          'Occasionally (1-2 times/month)',
          'Rarely',
          'Never'
        ],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.guestsFrequency = value;
          });
        },
        initialValue: _seekingFlatmateProfile.guestsFrequency,
      ),

      // Page 19: Visitors Policy
      SingleChoiceQuestionWidget(
        title: "What's your policy on visitors staying overnight?",
        subtitle: "How often do you expect to have guests stay overnight?",
        options: ['Frequently', 'Occasionally', 'Rarely', 'Never'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.guestsOvernightPolicy = value;
          });
        },
        initialValue: _seekingFlatmateProfile.guestsOvernightPolicy,
      ),

      SingleChoiceQuestionWidget(
        title: "What's your policy on visitors?",
        subtitle: "How often do you plan to have guests over?",
        options: ['Frequent visitors', 'Occasional visitors', 'Rarely have visitors', 'No visitors'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.visitorsPolicy = value;
          });
        },
        initialValue: _seekingFlatmateProfile.visitorsPolicy,
      ),

      // Page 20: Pet Ownership
      SingleChoiceQuestionWidget(
        title: "Do you currently own pets?",
        subtitle: "Are you bringing any furry friends?",
        options: ['Yes', 'No', 'Planning to get one'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.petOwnership = value;
          });
        },
        initialValue: _seekingFlatmateProfile.petOwnership,
      ),

      // Page 21: Pet Tolerance
      SingleChoiceQuestionWidget(
        title: "What's your tolerance for flatmates/owners with pets?",
        subtitle: "Are you comfortable living with pets?",
        options: [
          'Comfortable with pets',
          'Tolerant of pets',
          'Prefer no pets',
          'Allergic to pets'
        ],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.petTolerance = value;
          });
        },
        initialValue: _seekingFlatmateProfile.petTolerance,
      ),

      // Page 22: Sleeping Schedule
      SingleChoiceQuestionWidget(
        title: "What's your typical sleeping schedule?",
        subtitle: "Are you an early bird or a night owl?",
        options: ['Early riser', 'Night Owl', 'Flexible', 'Irregular'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.sleepingSchedule = value;
          });
        },
        initialValue: _seekingFlatmateProfile.sleepingSchedule,
      ),

      // Page 23: Sharing Common Spaces
      SingleChoiceQuestionWidget(
        title: "How do you prefer sharing common spaces?",
        subtitle: "Do you like to share everything or prefer separate items?",
        options: [
          'Share everything',
          'Share some items',
          'Prefer separate items',
          'Flexible'
        ],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.sharingCommonSpaces = value;
          });
        },
        initialValue: _seekingFlatmateProfile.sharingCommonSpaces,
      ),

      // Page 24: Personal Space vs Socialization
      SingleChoiceQuestionWidget(
        title: "How do you balance personal space and socialization?",
        subtitle:
        "Do you value quiet personal time or enjoy interactive common spaces?",
        options: [
          'Value personal space highly',
          'Enjoy a balance',
          'Prefer more socialization',
          'Flexible'
        ],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.personalSpaceVsSocialization = value;
          });
        },
        initialValue: _seekingFlatmateProfile.personalSpaceVsSocialization,
      ),

      // --- Section 3: Flat Requirements (Pages 25-27) ---
      // Page 25: Preferred Flat Type
      SingleChoiceQuestionWidget(
        title: "What type of flat are you looking for?",
        subtitle: "Studio, 1BHK, 2BHK, etc.",
        options: ['Studio Apartment', '1BHK', '2BHK', '3BHK', '4BHK+', 'Any'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.preferredFlatType = value;
          });
        },
        initialValue: _seekingFlatmateProfile.preferredFlatType,
      ),

      // Page 26: Preferred Furnished Status
      SingleChoiceQuestionWidget(
        title: "What's your preferred furnished status for the flat?",
        subtitle: "Furnished, semi-furnished, or unfurnished?",
        options: ['Furnished', 'Semi-furnished', 'Unfurnished', 'Any'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.preferredFurnishedStatus = value;
          });
        },
        initialValue: _seekingFlatmateProfile.preferredFurnishedStatus,
      ),

      // Page 27: Amenities Desired (Multi-choice)
      MultiChoiceQuestionWidget(
        title: "What amenities are you looking for in a flat?",
        subtitle: "Select all that apply.",
        options: [
          'Wi-Fi',
          'AC',
          'Geyser',
          'Washing Machine',
          'Refrigerator',
          'Microwave',
          'Maid Service',
          'Cook',
          'Gym',
          'Swimming Pool',
          'Power Backup',
          'Security'
        ],
        onSelected: (selected) {
          setState(() {
            _seekingFlatmateProfile.amenitiesDesired = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.amenitiesDesired,
      ),

      // --- Section 4: Flatmate Preferences (Pages 28-33) ---
      // Page 28: Preferred Flatmate Gender
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate gender?",
        subtitle: "This helps in finding a compatible match.",
        options: ['Male', 'Female', 'No preference', 'Other'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.preferredFlatmateGender = value;
          });
        },
        initialValue: _seekingFlatmateProfile.preferredFlatmateGender,
      ),

      // Page 29: Preferred Flatmate Age
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate age group?",
        subtitle: "This helps in finding a compatible match.",
        options: ['18-24', '25-30', '30-40', '40+', 'No preference'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.preferredFlatmateAge = value;
          });
        },
        initialValue: _seekingFlatmateProfile.preferredFlatmateAge,
      ),

      // Page 30: Preferred Occupation
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate occupation type?",
        subtitle: "Student, working professional, or no preference?",
        options: ['Student', 'Working Professional', 'Both', 'No preference'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.preferredOccupation = value;
          });
        },
        initialValue: _seekingFlatmateProfile.preferredOccupation,
      ),

      // Page 31: Preferred Habits (Multi-choice)
      MultiChoiceQuestionWidget(
        title: "What habits do you prefer in a flatmate?",
        subtitle: "Select all that apply.",
        options: [
          'Non-smoker',
          'Non-drinker',
          'Vegetarian',
          'Tidy',
          'Quiet',
          'Social',
          'Respectful',
          'Financially responsible',
          'Pet-friendly'
        ],
        onSelected: (selected) {
          setState(() {
            _seekingFlatmateProfile.preferredHabits = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.preferredHabits,
      ),

      // Page 32: Ideal Qualities (Multi-choice)
      MultiChoiceQuestionWidget(
        title: "What qualities do you desire in a flatmate?",
        subtitle: "Select qualities you look for.",
        options: [
          'Respectful',
          'Tidy',
          'Communicative',
          'Friendly',
          'Responsible',
          'Quiet',
          'Social',
          'Independent',
          'Shares chores',
          'Financially stable'
        ],
        onSelected: (selected) {
          setState(() {
            _seekingFlatmateProfile.idealQualities = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.idealQualities,
      ),

      // Page 33: Deal Breakers (Multi-choice)
      MultiChoiceQuestionWidget(
        title: "Any deal breakers for a flatmate?",
        subtitle: "Things you absolutely cannot tolerate.",
        options: [
          'Excessive Noise',
          'Untidiness',
          'Frequent Parties',
          'Smoking Indoors',
          'Unpaid Bills',
          'Lack of Communication',
          'Pets (if not allowed)',
          'Late Night Guests',
          'Drugs',
          'Disrespectful behavior'
        ],
        onSelected: (selected) {
          setState(() {
            _seekingFlatmateProfile.dealBreakers = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.dealBreakers,
      ),
    ];
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _submitProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  // --- Method to show sections bottom sheet ---
  void _showSectionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Jump to Section',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Colors.grey),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  final section = _sections[index];
                  final bool isCurrentSection = _currentPage >= section['startPage'] && _currentPage <= section['endPage'];
                  return ListTile(
                    title: Text(
                      section['title'],
                      style: TextStyle(
                        fontWeight: isCurrentSection ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentSection ? Colors.redAccent : Colors.black,
                      ),
                    ),
                    trailing: isCurrentSection
                        ? const Icon(Icons.arrow_forward_ios, color: Colors.redAccent, size: 18)
                        : null,
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _pageController.jumpToPage(section['startPage'] as int); // Jump to the start of the selected section
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Firebase Integration Method ---
  Future<void> _submitProfileToFirebase() async {
    setState(() {
      _isSubmitting = true; // Show loading
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit your profile.')),
      );
      setState(() {
        _isSubmitting = false; // Hide loading
      });
      return;
    }

    // Get a reference to the 'seekingFlatmateProfiles' subcollection for the current user
    final CollectionReference seekingFlatmateProfilesCollection =
    FirebaseFirestore.instance.collection('users').doc(user.uid).collection('seekingFlatmateProfiles');

    // --- Use your provided profileData structure ---
    final Map<String, dynamic> profileData = {
      "uid": user.uid,
      "email": user.email,//
      "displayName": _seekingFlatmateProfile.name, // Using 'name' for displayName
      "age": _seekingFlatmateProfile.age ?? 0,
      "gender": _seekingFlatmateProfile.gender,
      "occupation": _seekingFlatmateProfile.occupation,
      "currentLocation": _seekingFlatmateProfile.currentLocation,//
      "desiredCity": _seekingFlatmateProfile.desiredCity,
      "moveInDate": _seekingFlatmateProfile.moveInDate != null
          ? Timestamp.fromDate(_seekingFlatmateProfile.moveInDate!)
          : null,
      "budgetMin": _seekingFlatmateProfile.budgetMin ?? 0,
      "budgetMax": _seekingFlatmateProfile.budgetMax ?? 0,
      "areaPreference": _seekingFlatmateProfile.areaPreference,
      "bio": _seekingFlatmateProfile.bio,
      "userType": "seeking_flatmate",
      "habits": {
        "cleanliness": _seekingFlatmateProfile.cleanliness,
        "socialPreferences": _seekingFlatmateProfile.socialHabits,
        "workSchedule": _seekingFlatmateProfile.workSchedule,//
        "noiseTolerance": _seekingFlatmateProfile.noiseLevel,//
        "smoking": _seekingFlatmateProfile.smokingHabits,
        "drinking": _seekingFlatmateProfile.drinkingHabits,
        "food": _seekingFlatmateProfile.foodPreference,
        "visitorsPolicy": _seekingFlatmateProfile.visitorsPolicy,//
        "petOwnership": _seekingFlatmateProfile.petOwnership,
        "petTolerance": _seekingFlatmateProfile.petTolerance,
        "sleepingSchedule": _seekingFlatmateProfile.sleepingSchedule,//
        "sharingCommonSpaces": _seekingFlatmateProfile.sharingCommonSpaces,//
        "guestOvernightStays": _seekingFlatmateProfile.guestsOvernightPolicy,//
        "personalSpaceVsSocialization": _seekingFlatmateProfile.personalSpaceVsSocialization,//
      },
      "flatRequirements": {
        "preferredFlatType": _seekingFlatmateProfile.preferredFlatType,
        "preferredFurnishedStatus": _seekingFlatmateProfile.preferredFurnishedStatus,
        "amenitiesDesired": _seekingFlatmateProfile.amenitiesDesired,
      },
      "flatmatePreferences": {
        "preferredFlatmateGender": _seekingFlatmateProfile.preferredFlatmateGender,
        "preferredFlatmateAge": _seekingFlatmateProfile.preferredFlatmateAge,
        "preferredOccupation": _seekingFlatmateProfile.preferredOccupation,
        "preferredHabits": _seekingFlatmateProfile.preferredHabits,
        "idealQualities": _seekingFlatmateProfile.idealQualities,
        "dealBreakers": _seekingFlatmateProfile.dealBreakers,
      },
      "isProfileComplete": true,
      // Timestamps will be handled below based on new/update
      // "createdAt": FieldValue.serverTimestamp(), // Removed from here
      // "lastUpdated": FieldValue.serverTimestamp(), // Removed from here
    };

    try {
      if (_seekingFlatmateProfile.documentId.isEmpty) {
        // This is a new profile, add it to the subcollection
        profileData['createdAt'] = FieldValue.serverTimestamp();
        profileData['lastUpdated'] = FieldValue.serverTimestamp();

        DocumentReference newDocRef = await seekingFlatmateProfilesCollection.add(profileData);
        // Update the local model with the new Firestore document ID
        _seekingFlatmateProfile.documentId = newDocRef.id;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New Seeking Flatmate Profile Created Successfully!')),
        );
      } else {
        // This is an existing profile, update it
        profileData['lastUpdated'] = FieldValue.serverTimestamp();
        // Do not update 'createdAt' on existing documents
        profileData.remove('createdAt');

        await seekingFlatmateProfilesCollection.doc(_seekingFlatmateProfile.documentId).update(profileData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seeking Flatmate Profile Updated Successfully!')),
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()), // Consider MyProfilesScreen
        );
      }
    } catch (e) {
      print('Error submitting seeking flatmate profile to Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit profile: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // Hide loading
      });
    }
  }

  void _submitProfile() {
    print('Submitting Seeking Flatmate Profile:');
    print(_seekingFlatmateProfile.toString());
    _submitProfileToFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: _previousPage,
        )
            : null,
        actions: [
          TextButton(
            onPressed: _showSectionsBottomSheet,
            child: const Text(
              'Sections',
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Section Title and Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  children: [
                    Text(
                      'Section ${_sections.indexOf(_sections.firstWhere(
                              (s) => _currentPage >= s['startPage'] && _currentPage <= s['endPage'],
                          orElse: () => {'title': 'Unknown Section', 'startPage': 0, 'endPage': 0} // Provide a default/fallback
                      )) + 1} of ${_sections.length}: ${_getCurrentSectionTitle()}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _getCurrentSectionProgress(),
                      backgroundColor: Colors.grey[300],
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pages.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _pages[index];
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentPage > 0 ? _previousPage : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(
                              color: _currentPage > 0 ? Colors.redAccent : Colors.grey),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child:
                        const Text('Back', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        child: Text(
                            _currentPage == _pages.length - 1 ? 'Finish' : 'Next',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isSubmitting) // Loading overlay
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }
}