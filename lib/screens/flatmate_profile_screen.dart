// flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this
import 'package:intl/intl.dart'; // Add this

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

  // Looking for Preferences (previously desiredQualities, dealBreakers)
  String preferredFlatmateGender = ''; // New field
  String preferredFlatmateAge = ''; // New field
  String preferredFlatmateOccupation = ''; // New field
  List<String> desiredQualities = [];
  List<String> dealBreakers = [];

  // Flat Details (some existing, some new/renamed for clarity)
  String address = '';
  String rent = '';
  String deposit = '';
  DateTime? availabilityDate;
  String flatType = '';
  String roomType = '';
  String numExistingFlatmates = '';
  String genderExistingFlatmates = ''; // New field
  String petsAllowedFlat = ''; // Renamed from allowsPets for clarity
  String smokingAllowedFlat = ''; // Renamed from allowsSmoking for clarity
  String drinkingAllowedFlat = ''; // New field
  String guestsAllowedFlat = ''; // Renamed from allowsGuests for clarity
  String furnishedStatus = ''; // New field
  List<String> amenities = []; // Changed to List<String>
  String flatVibe = ''; // Moved from Habits to Flat Details for logical grouping
  String flatCleanliness = ''; // Moved from Habits to Flat Details
  String flatSocialVibe = ''; // Moved from Habits to Flat Details
  String flatNoiseLevel = ''; // Moved from Habits to Flat Details


  @override
  String toString() {
    return 'FlatListingProfile(\n'
        '  ownerName: $ownerName,\n'
        '  ownerAge: $ownerAge,\n'
        '  ownerGender: $ownerGender,\n'
        '  ownerOccupation: $ownerOccupation,\n'
        '  ownerBio: $ownerBio,\n'
        '  currentCity: $currentCity,\n'
        '  desiredCity: $desiredCity,\n'
        '  budgetMin: $budgetMin,\n'
        '  budgetMax: $budgetMax,\n'
        '  areaPreference: $areaPreference,\n'
        '  smokingHabit: $smokingHabit,\n'
        '  drinkingHabit: $drinkingHabit,\n'
        '  foodPreference: $foodPreference,\n'
        '  cleanlinessLevel: $cleanlinessLevel,\n'
        '  noiseLevel: $noiseLevel,\n'
        '  socialPreferences: $socialPreferences,\n'
        '  visitorsPolicy: $visitorsPolicy,\n'
        '  petOwnership: $petOwnership,\n'
        '  petTolerance: $petTolerance,\n'
        '  sleepingSchedule: $sleepingSchedule,\n'
        '  workSchedule: $workSchedule,\n'
        '  sharingCommonSpaces: $sharingCommonSpaces,\n'
        '  guestsOvernightPolicy: $guestsOvernightPolicy,\n'
        '  personalSpaceVsSocialization: $personalSpaceVsSocialization,\n'
        '  preferredFlatmateGender: $preferredFlatmateGender,\n'
        '  preferredFlatmateAge: $preferredFlatmateAge,\n'
        '  preferredFlatmateOccupation: $preferredFlatmateOccupation,\n'
        '  desiredQualities: $desiredQualities,\n'
        '  dealBreakers: $dealBreakers,\n'
        '  address: $address,\n'
        '  rent: $rent,\n'
        '  deposit: $deposit,\n'
        '  availabilityDate: $availabilityDate,\n'
        '  flatType: $flatType,\n'
        '  roomType: $roomType,\n'
        '  numExistingFlatmates: $numExistingFlatmates,\n'
        '  genderExistingFlatmates: $genderExistingFlatmates,\n'
        '  petsAllowedFlat: $petsAllowedFlat,\n'
        '  smokingAllowedFlat: $smokingAllowedFlat,\n'
        '  drinkingAllowedFlat: $drinkingAllowedFlat,\n'
        '  guestsAllowedFlat: $guestsAllowedFlat,\n'
        '  furnishedStatus: $furnishedStatus,\n'
        '  amenities: $amenities,\n'
        '  flatVibe: $flatVibe,\n'
        '  flatCleanliness: $flatCleanliness,\n'
        '  flatSocialVibe: $flatSocialVibe,\n'
        '  flatNoiseLevel: $flatNoiseLevel,\n'
        ')';
  }
}

// New Stateful Widget for Single Choice Questions (Copied from flat_with_flatmate_profile_screen.dart to ensure consistency)
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
                widget.onSelected(option); // Notify the parent
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
            widget.onSelected(option); // Notify the parent
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

class FlatmateProfileScreen extends StatefulWidget {
  const FlatmateProfileScreen({super.key});

  @override
  State<FlatmateProfileScreen> createState() => _FlatmateProfileScreenState();
}

class _FlatmateProfileScreenState extends State<FlatmateProfileScreen> {
  final PageController _pageController = PageController();
  final FlatListingProfile _profile = FlatListingProfile();
  int _currentPage = 0;
  bool _isSubmitting = false; // Add this line
  // Changed _pages from late final to a getter
// lib/flatmate_profile_screen.dart

  late final List<Widget> _pages;  // Declare controllers for text fields
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerAgeController;
  late TextEditingController _ownerOccupationController;
  late TextEditingController _ownerBioController;
  late TextEditingController _currentCityController; // New
  late TextEditingController _desiredCityController; // New
  late TextEditingController _budgetMinController; // New
  late TextEditingController _budgetMaxController; // New
  late TextEditingController _areaPreferenceController; // New

  late TextEditingController _addressController;
  late TextEditingController _rentController;
  late TextEditingController _depositController;
  late TextEditingController _numExistingFlatmatesController;


  @override
  void initState() {
    super.initState();
    // Initialize controllers with initial profile values
    _ownerNameController = TextEditingController(text: _profile.ownerName);
    _ownerAgeController = TextEditingController(text: _profile.ownerAge);
    _ownerOccupationController = TextEditingController(text: _profile.ownerOccupation);
    _ownerBioController = TextEditingController(text: _profile.ownerBio);
    _currentCityController = TextEditingController(text: _profile.currentCity); // New
    _desiredCityController = TextEditingController(text: _profile.desiredCity); // New
    _budgetMinController = TextEditingController(text: _profile.budgetMin); // New
    _budgetMaxController = TextEditingController(text: _profile.budgetMax); // New
    _areaPreferenceController = TextEditingController(text: _profile.areaPreference); // New

    _addressController = TextEditingController(text: _profile.address);
    _rentController = TextEditingController(text: _profile.rent);
    _depositController = TextEditingController(text: _profile.deposit);
    _numExistingFlatmatesController = TextEditingController(text: _profile.numExistingFlatmates);

    // Add listeners to update _profile when text changes
    _ownerNameController.addListener(() {
      _profile.ownerName = _ownerNameController.text;
    });
    _ownerAgeController.addListener(() {
      _profile.ownerAge = _ownerAgeController.text;
    });
    _ownerOccupationController.addListener(() {
      _profile.ownerOccupation = _ownerOccupationController.text;
    });
    _ownerBioController.addListener(() {
      _profile.ownerBio = _ownerBioController.text;
    });
    _currentCityController.addListener(() { // New
      _profile.currentCity = _currentCityController.text;
    });
    _desiredCityController.addListener(() { // New
      _profile.desiredCity = _desiredCityController.text;
    });
    _budgetMinController.addListener(() { // New
      _profile.budgetMin = _budgetMinController.text;
    });
    _budgetMaxController.addListener(() { // New
      _profile.budgetMax = _budgetMaxController.text;
    });
    _areaPreferenceController.addListener(() { // New
      _profile.areaPreference = _areaPreferenceController.text;
    });

    _addressController.addListener(() {
      _profile.address = _addressController.text;
    });
    _rentController.addListener(() {
      _profile.rent = _rentController.text;
    });
    _depositController.addListener(() {
      _profile.deposit = _depositController.text;
    });
    _numExistingFlatmatesController.addListener(() {
      _profile.numExistingFlatmates = _numExistingFlatmatesController.text;
      _profile.numExistingFlatmates = _numExistingFlatmatesController.text;
    });
    _pages = _buildPages();
  }

  @override
  void dispose() {
    // Dispose of all controllers
    _ownerNameController.dispose();
    _ownerAgeController.dispose();
    _ownerOccupationController.dispose();
    _ownerBioController.dispose();
    _currentCityController.dispose(); // New
    _desiredCityController.dispose(); // New
    _budgetMinController.dispose(); // New
    _budgetMaxController.dispose(); // New
    _areaPreferenceController.dispose(); // New

    _addressController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _numExistingFlatmatesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // --- Common Question Builders (Copied for consistency, ensure these are identical) ---

  Widget _buildTextQuestion({
    required String title,
    required String subtitle,
    required String hintText,
    required TextEditingController controller, // Now accepts a controller
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
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
            controller: controller, // Use the provided controller
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
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
                              foregroundColor:
                              Colors.redAccent, // color of button's text
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
                  padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        selectedDate == null
                            ? 'Select a date'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        style: TextStyle(
                            fontSize: 16,
                            color: selectedDate == null
                                ? Colors.grey[700]
                                : Colors.black),
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

  Widget _buildMultiChoiceQuestion({
    required String title,
    required String subtitle,
    required List<String> options,
    required Function(List<String>) onSelected,
    List<String> initialValues = const [],
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        List<String> selectedOptions = List.from(initialValues);
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
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: options.map((option) {
                      final isSelected = selectedOptions.contains(option);
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
                            if (isSelected) {
                              selectedOptions.remove(option);
                            } else {
                              selectedOptions.add(option);
                            }
                          });
                          onSelected(selectedOptions);
                        },
                        labelPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
      },
    );
  }

  // --- Page Definitions ---

  List<Widget> _buildPages() {
    return [
      // Page 1: Welcome Screen
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('👋', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${_profile.ownerName.isEmpty ? 'Owner' : _profile.ownerName}!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Let's create your flat listing profile.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: const Text("Let's go",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitProfile, // Disable button when submitting
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: _isSubmitting
                  ? const CircularProgressIndicator( // Show loader
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : const Text("Find my Flatmate",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // --- Basic Info Section ---

      // Page 2: Owner Name
      _buildTextQuestion(
        title: "What's your name?",
        subtitle: "This will be visible to potential flatmates.",
        hintText: "Enter your name",
        controller: _ownerNameController,
      ),

      // Page 3: Owner Age
      _buildTextQuestion(
        title: "How old are you?",
        subtitle: "This helps flatmates understand the age group.",
        hintText: "Enter your age",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _ownerAgeController,
      ),

      // Page 4: Owner Gender
      SingleChoiceQuestionWidget(
        title: "What's your gender?",
        subtitle: "This helps potential flatmates relate to you.",
        options: ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
        onSelected: (value) {
          setState(() {
            _profile.ownerGender = value;
          });
        },
        initialValue: _profile.ownerGender,
      ),

      // Page 5: Owner Occupation
      _buildTextQuestion(
        title: "What do you do for a living?",
        subtitle: "Share your profession or student status.",
        hintText: "e.g., Software Engineer, Student, Freelancer",
        controller: _ownerOccupationController,
      ),

      // Page 6: Owner Bio
      _buildTextQuestion(
        title: "Tell us a bit about yourself as an owner/current flatmate.",
        subtitle: "Share something interesting! This helps flatmates get to know you.",
        hintText: "e.g., I'm a quiet person who loves reading...",
        controller: _ownerBioController,
      ),

      // Page 7: Current City (New)
      _buildTextQuestion(
        title: "Which city are you currently in?",
        subtitle: "This helps us understand your current location.",
        hintText: "e.g., Pune, Mumbai",
        controller: _currentCityController,
      ),

      // Page 8: Desired City (New - for finding a flatmate in a new city)
      _buildTextQuestion(
        title: "In which city are you looking for a flat/flatmate?",
        subtitle: "Specify the city where the flat is located or where you want to find a flatmate.",
        hintText: "e.g., Bangalore, Delhi",
        controller: _desiredCityController,
      ),

      // Page 9: Budget Min (New)
      _buildTextQuestion(
        title: "What's your minimum budget for rent?",
        subtitle: "Enter the minimum amount you are willing to pay/charge per month.",
        hintText: "e.g., ₹10000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _budgetMinController,
      ),

      // Page 10: Budget Max (New)
      _buildTextQuestion(
        title: "What's your maximum budget for rent?",
        subtitle: "Enter the maximum amount you are willing to pay/charge per month.",
        hintText: "e.g., ₹25000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _budgetMaxController,
      ),

      // Page 11: Area Preference (New)
      _buildTextQuestion(
        title: "Do you have any area preferences?",
        subtitle: "List specific localities or neighborhoods.",
        hintText: "e.g., Koregaon Park, Viman Nagar",
        controller: _areaPreferenceController,
      ),

      // --- Habits Section ---

      // Page 12: Smoking Habits (New)
      SingleChoiceQuestionWidget(
        title: "What are your smoking habits?",
        subtitle: "This helps in matching with compatible flatmates.",
        options: ['Never', 'Occasionally', 'Socially', 'Regularly'],
        onSelected: (value) {
          setState(() {
            _profile.smokingHabit = value;
          });
        },
        initialValue: _profile.smokingHabit,
      ),

      // Page 13: Drinking Habits (New)
      SingleChoiceQuestionWidget(
        title: "What are your drinking habits?",
        subtitle: "Are you a non-drinker, social drinker, or regular drinker?",
        options: ['Never', 'Occasionally', 'Socially', 'Regularly'],
        onSelected: (value) {
          setState(() {
            _profile.drinkingHabit = value;
          });
        },
        initialValue: _profile.drinkingHabit,
      ),

      // Page 14: Food Preference (New)
      SingleChoiceQuestionWidget(
        title: "What's your food preference?",
        subtitle: "Vegetarian, Non-vegetarian, or Vegan?",
        options: ['Vegetarian', 'Non-vegetarian', 'Vegan', 'Eggetarian', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.foodPreference = value;
          });
        },
        initialValue: _profile.foodPreference,
      ),

      // Page 15: Cleanliness Level (New - this is owner's personal cleanliness)
      SingleChoiceQuestionWidget(
        title: "How would you describe your cleanliness level?",
        subtitle: "Be honest! This helps manage expectations.",
        options: ['Very Tidy', 'Moderately Tidy', 'Flexible', 'Can be messy at times'],
        onSelected: (value) {
          setState(() {
            _profile.cleanlinessLevel = value;
          });
        },
        initialValue: _profile.cleanlinessLevel,
      ),

      // Page 16: Noise Level (New - this is owner's personal noise level)
      SingleChoiceQuestionWidget(
        title: "What's your preferred noise level at home?",
        subtitle: "Do you prefer a quiet environment or don't mind some noise?",
        options: ['Very quiet', 'Moderate noise', 'Lively', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.noiseLevel = value;
          });
        },
        initialValue: _profile.noiseLevel,
      ),

      // Page 17: Social Preferences (New)
      SingleChoiceQuestionWidget(
        title: "How social are you at home?",
        subtitle: "Do you like interacting with flatmates often or prefer privacy?",
        options: ['Very social', 'Occasionally social', 'Keep to myself', 'Depends'],
        onSelected: (value) {
          setState(() {
            _profile.socialPreferences = value;
          });
        },
        initialValue: _profile.socialPreferences,
      ),

      // Page 18: Visitors Policy (New - owner's preference for their own visitors)
      SingleChoiceQuestionWidget(
        title: "What's your policy on having visitors?",
        subtitle: "How often do you plan to have guests over?",
        options: ['Frequent visitors', 'Occasional visitors', 'Rarely have visitors', 'No visitors'],
        onSelected: (value) {
          setState(() {
            _profile.visitorsPolicy = value;
          });
        },
        initialValue: _profile.visitorsPolicy,
      ),

      // Page 19: Pet Ownership (New - owner's own pet status)
      SingleChoiceQuestionWidget(
        title: "Do you own any pets?",
        subtitle: "This is about your current pets.",
        options: ['Yes', 'No'],
        onSelected: (value) {
          setState(() {
            _profile.petOwnership = value;
          });
        },
        initialValue: _profile.petOwnership,
      ),

      // Page 20: Pet Tolerance (New - owner's tolerance for flatmate's pets)
      SingleChoiceQuestionWidget(
        title: "How tolerant are you of pets in the flat?",
        subtitle: "If a flatmate has pets, how do you feel about it?",
        options: ['Love pets', 'Tolerate small pets', 'Not ideal but can manage', 'Cannot tolerate pets'],
        onSelected: (value) {
          setState(() {
            _profile.petTolerance = value;
          });
        },
        initialValue: _profile.petTolerance,
      ),

      // Page 21: Sleeping Schedule (New)
      SingleChoiceQuestionWidget(
        title: "What's your typical sleeping schedule?",
        subtitle: "Are you an early bird or a night owl?",
        options: ['Early riser', 'Late sleeper', 'Flexible', 'Irregular'],
        onSelected: (value) {
          setState(() {
            _profile.sleepingSchedule = value;
          });
        },
        initialValue: _profile.sleepingSchedule,
      ),

      // Page 22: Work Schedule (New)
      SingleChoiceQuestionWidget(
        title: "What's your typical work/study schedule?",
        subtitle: "This helps in understanding common space usage.",
        options: ['9-5 Office hours', 'Freelance/Flexible hours', 'Night shifts', 'Student schedule', 'Mixed'],
        onSelected: (value) {
          setState(() {
            _profile.workSchedule = value;
          });
        },
        initialValue: _profile.workSchedule,
      ),

      // Page 23: Sharing Common Spaces (New)
      SingleChoiceQuestionWidget(
        title: "How do you prefer sharing common spaces?",
        subtitle: "Do you like to share everything or prefer separate items?",
        options: ['Share everything', 'Share some items', 'Prefer separate items', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.sharingCommonSpaces = value;
          });
        },
        initialValue: _profile.sharingCommonSpaces,
      ),

      // Page 24: Guests Policy for Overnight Stays (New - owner's own guests)
      SingleChoiceQuestionWidget(
        title: "What's your policy for *your own* overnight guests?",
        subtitle: "How often do you expect to have guests stay overnight?",
        options: ['Frequently', 'Occasionally', 'Rarely', 'Never'],
        onSelected: (value) {
          setState(() {
            _profile.guestsOvernightPolicy = value;
          });
        },
        initialValue: _profile.guestsOvernightPolicy,
      ),

      // Page 25: Personal Space vs. Socialization (New)
      SingleChoiceQuestionWidget(
        title: "How do you balance personal space and socialization?",
        subtitle: "Do you value quiet personal time or enjoy interactive common spaces?",
        options: ['Value personal space highly', 'Enjoy a balance', 'Prefer more socialization', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.personalSpaceVsSocialization = value;
          });
        },
        initialValue: _profile.personalSpaceVsSocialization,
      ),

      // --- Looking for Preferences Section ---

      // Page 26: Preferred Flatmate Gender (Renamed from flatmateGenderAge)
      SingleChoiceQuestionWidget(
        title: "What's your preference for flatmate gender?",
        subtitle: "This helps in finding a compatible match.",
        options: ['Male', 'Female', 'No preference', 'Other'],
        onSelected: (value) {
          setState(() {
            _profile.preferredFlatmateGender = value;
          });
        },
        initialValue: _profile.preferredFlatmateGender,
      ),

      // Page 27: Preferred Flatmate Age (New)
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate age range?",
        subtitle: "This helps in finding a compatible match.",
        options: ['18-24', '25-30', '30-40', '40+', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.preferredFlatmateAge = value;
          });
        },
        initialValue: _profile.preferredFlatmateAge,
      ),

      // Page 28: Preferred Flatmate Occupation (New)
      SingleChoiceQuestionWidget(
        title: "Any preference for flatmate's occupation?",
        subtitle: "E.g., student, working professional.",
        options: ['Student', 'Working Professional', 'Flexible', 'No preference'],
        onSelected: (value) {
          setState(() {
            _profile.preferredFlatmateOccupation = value;
          });
        },
        initialValue: _profile.preferredFlatmateOccupation,
      ),

      // Page 29: Desired Flatmate Qualities (Multi-choice)
      _buildMultiChoiceQuestion(
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
            _profile.desiredQualities = selected;
          });
        },
        initialValues: _profile.desiredQualities,
      ),

      // Page 30: Deal Breakers (Multi-choice)
      _buildMultiChoiceQuestion(
        title: "Any deal breakers for a flatmate?",
        subtitle: "Things you absolutely cannot tolerate.",
        options: [
          'Excessive Noise',
          'Untidiness',
          'Frequent Parties',
          'Smoking Indoors',
          'Unpaid Bills',
          'Lack of Communication',
          'Pets (if allergic/dislike)',
          'Late Night Guests',
          'Drugs',
          'Disrespectful behavior'
        ],
        onSelected: (selected) {
          setState(() {
            _profile.dealBreakers = selected;
          });
        },
        initialValues: _profile.dealBreakers,
      ),

      // --- Flat Details Section ---

      // Page 31: Address
      _buildTextQuestion(
        title: "What's the full address of the flat?",
        subtitle: "This will be used for location-based matching.",
        hintText: "Enter flat address",
        controller: _addressController,
      ),

      // Page 32: Rent
      _buildTextQuestion(
        title: "What is the monthly rent?",
        subtitle: "Specify the rent for the room/flat.",
        hintText: "e.g., ₹15000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _rentController,
      ),

      // Page 33: Deposit
      _buildTextQuestion(
        title: "What is the security deposit?",
        subtitle: "Enter the refundable security deposit amount.",
        hintText: "e.g., ₹30000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _depositController,
      ),

      // Page 34: Availability Date
      _buildDateQuestion(
        title: "When is the flat/room available?",
        subtitle: "Select the date from which the flat is ready for move-in.",
        onDateSelected: (date) {
          setState(() {
            _profile.availabilityDate = date;
          });
        },
        initialDate: _profile.availabilityDate,
      ),

      // Page 35: Flat Type
      SingleChoiceQuestionWidget(
        title: "What type of flat is it?",
        subtitle: "E.g., Studio, 1BHK, 2BHK.",
        options: ['Studio Apartment', '1BHK', '2BHK', '3BHK', '4BHK+'],
        onSelected: (value) {
          setState(() {
            _profile.flatType = value;
          });
        },
        initialValue: _profile.flatType,
      ),

      // Page 36: Room Type
      SingleChoiceQuestionWidget(
        title: "What type of room is available?",
        subtitle: "Is it a private room or a shared space?",
        options: ['Private Room', 'Shared Room', 'Entire Flat'],
        onSelected: (value) {
          setState(() {
            _profile.roomType = value;
          });
        },
        initialValue: _profile.roomType,
      ),

      // Page 37: Number of Existing Flatmates
      _buildTextQuestion(
        title: "How many flatmates currently live there?",
        subtitle: "Excluding yourself, if you live there.",
        hintText: "e.g., 1, 2, 0 (if none)",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _numExistingFlatmatesController,
      ),

      // Page 38: Gender of Existing Flatmates (New)
      SingleChoiceQuestionWidget(
        title: "What is the gender of existing flatmates?",
        subtitle: "Select all that apply, or 'Mixed' if applicable.",
        options: ['All Male', 'All Female', 'Mixed', 'Not applicable (no existing flatmates)'],
        onSelected: (value) {
          setState(() {
            _profile.genderExistingFlatmates = value;
          });
        },
        initialValue: _profile.genderExistingFlatmates,
      ),

      // Page 39: Pets Allowed in Flat
      SingleChoiceQuestionWidget(
        title: "Are pets allowed in the flat?",
        subtitle: "Specify your pet policy for the flat.",
        options: ['Yes', 'No', 'Negotiable'],
        onSelected: (value) {
          setState(() {
            _profile.petsAllowedFlat = value;
          });
        },
        initialValue: _profile.petsAllowedFlat,
      ),

      // Page 40: Smoking Allowed in Flat
      SingleChoiceQuestionWidget(
        title: "Is smoking allowed in the flat?",
        subtitle: "Indoors or outdoors only?",
        options: ['Indoors & Outdoors', 'Outdoors Only', 'Not Allowed'],
        onSelected: (value) {
          setState(() {
            _profile.smokingAllowedFlat = value;
          });
        },
        initialValue: _profile.smokingAllowedFlat,
      ),

      // Page 41: Drinking Allowed in Flat (New)
      SingleChoiceQuestionWidget(
        title: "Is drinking alcohol allowed in the flat?",
        subtitle: "Specify your policy regarding alcohol consumption.",
        options: ['Yes, freely', 'Yes, occasionally', 'No, not allowed'],
        onSelected: (value) {
          setState(() {
            _profile.drinkingAllowedFlat = value;
          });
        },
        initialValue: _profile.drinkingAllowedFlat,
      ),

      // Page 42: Guests Allowed in Flat
      SingleChoiceQuestionWidget(
        title: "Are guests allowed in the flat?",
        subtitle: "Specify policy regarding guests in general.",
        options: ['Yes, freely', 'Yes, with notice', 'Only day guests', 'No guests'],
        onSelected: (value) {
          setState(() {
            _profile.guestsAllowedFlat = value;
          });
        },
        initialValue: _profile.guestsAllowedFlat,
      ),

      // Page 43: Furnished Status (New)
      SingleChoiceQuestionWidget(
        title: "Is the flat furnished?",
        subtitle: "Indicate whether the flat comes furnished, semi-furnished, or unfurnished.",
        options: ['Fully Furnished', 'Semi-Furnished', 'Unfurnished'],
        onSelected: (value) {
          setState(() {
            _profile.furnishedStatus = value;
          });
        },
        initialValue: _profile.furnishedStatus,
      ),

      // Page 44: Amenities
      _buildMultiChoiceQuestion(
        title: "What amenities does the flat offer?",
        subtitle: "Select all available amenities.",
        options: [
          'Furnished', 'AC', 'Washing Machine', 'Refrigerator', 'Geyser',
          'Wi-Fi', 'Parking', 'Gym', 'Swimming Pool', 'Security', 'Balcony', 'Modular Kitchen', 'Power Backup'
        ],
        onSelected: (selected) {
          setState(() {
            _profile.amenities = selected; // Store as List<String>
          });
        },
        initialValues: _profile.amenities,
      ),

      // Page 45: Flat Vibe (Moved to Flat Details for logical grouping)
      SingleChoiceQuestionWidget(
        title: "What's the general vibe of the flat?",
        subtitle: "Describe the atmosphere of your home.",
        options: ['Quiet & Peaceful', 'Lively & Social', 'Balanced', 'Party-friendly'],
        onSelected: (value) {
          setState(() {
            _profile.flatVibe = value;
          });
        },
        initialValue: _profile.flatVibe,
      ),

      // Page 46: Flat Cleanliness Expectations (Moved to Flat Details)
      SingleChoiceQuestionWidget(
        title: "What are the cleanliness expectations for the flat?",
        subtitle: "How clean do you expect the common areas to be kept?",
        options: ['Very Clean', 'Moderately Clean', 'Flexible', 'Don\'t mind mess'],
        onSelected: (value) {
          setState(() {
            _profile.flatCleanliness = value;
          });
        },
        initialValue: _profile.flatCleanliness,
      ),

      // Page 47: Flat Social Vibe Expectations (Moved to Flat Details)
      SingleChoiceQuestionWidget(
        title: "What's the social vibe you prefer in the flat?",
        subtitle: "Do you enjoy social gatherings in the flat or prefer quiet?",
        options: ['Social & outgoing', 'Occasional gatherings', 'Quiet & private', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.flatSocialVibe = value;
          });
        },
        initialValue: _profile.flatSocialVibe,
      ),

      // Page 48: Flat Noise Level Expectations (Moved to Flat Details)
      SingleChoiceQuestionWidget(
        title: "What's the expected noise level in the flat?",
        subtitle: "How quiet or lively is the home generally?",
        options: ['Very quiet', 'Moderate noise', 'Lively', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.flatNoiseLevel = value;
          });
        },
        initialValue: _profile.flatNoiseLevel,
      ),


      // Final Page: Completion Screen
      _buildCompletionScreen(),
    ];
  }

  Widget _buildCompletionScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('✅', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Text(
            'Your flat listing is ready, ${_profile.ownerName}!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "You're all set. Let's find you the perfect flatmate.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Spacer(),
          // inside _buildCompletionScreen()

          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitProfile, // Disable button when submitting
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: _isSubmitting
                ? const CircularProgressIndicator( // Show loader
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : const Text("Find my Flatmate",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _nextPage() {
    // If we are on the last page of questions (before the completion screen)
    // or if we are on the welcome screen and there are more pages
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (_currentPage == _pages.length - 1) {
      // If we are already on the completion screen, pressing next (or finish)
      // should trigger submission. This case handles the "Find my Flatmate" button.
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

// Inside _FlatmateProfileScreenState class

  // Helper function to safely parse string to int
  int? _parseInt(String? value) {
    if (value == null || value.isEmpty) return null;
    // Removes any non-digit characters before parsing
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  // Helper to parse age range string like "25-30" or "40+"
  List<int?> _parseAgeRange(String ageRange) {
    if (ageRange.isEmpty) return [null, null];
    if (ageRange.contains('+')) {
      final minAge = _parseInt(ageRange.replaceAll('+', ''));
      return [minAge, null]; // No max age
    }
    final parts = ageRange.split('-');
    if (parts.length == 2) {
      return [_parseInt(parts[0].trim()), _parseInt(parts[1].trim())];
    }
    return [null, null];
  }

  void _submitProfile() async {
    setState(() {
      _isSubmitting = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text('No user logged in. Please log in again.')),
      );
      setState(() {
        _isSubmitting = false;
      });
      // Optionally, navigate to login screen
      // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
      return;
    }

    try {
      final ageRange = _parseAgeRange(_profile.preferredFlatmateAge);

      // 1. Transform data from _profile into the desired nested map structure
      final Map<String, dynamic> userProfileData = {
        'uid': user.uid,
        'displayName': _profile.ownerName,
        'age': _parseInt(_profile.ownerAge),
        'gender': _profile.ownerGender,
        'occupation': _profile.ownerOccupation,
        'currentCity': _profile.currentCity,
        'desiredCity': _profile.desiredCity,
        'moveInDate': _profile.availabilityDate != null
            ? DateFormat('yyyy-MM-dd').format(_profile.availabilityDate!)
            : null,
        'budgetMin': _parseInt(_profile.budgetMin),
        'budgetMax': _parseInt(_profile.budgetMax),
        'preferredAreas': _profile.areaPreference.isNotEmpty
            ? _profile.areaPreference.split(',').map((e) => e.trim()).toList()
            : [],
        'userType': 'offering_flat_room', // Static value for this user flow
        'bio': _profile.ownerBio,
        'isProfileComplete': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),

        'habits': {
          'smoking': _profile.smokingHabit,
          'drinking': _profile.drinkingHabit,
          'food': _profile.foodPreference,
          'cleanliness': _profile.cleanlinessLevel,
          'noiseTolerance': _profile.noiseLevel,
          'socialPreferences': _profile.socialPreferences,
          'visitorsPolicy': _profile.visitorsPolicy,
          'petOwnership': _profile.petOwnership.toLowerCase() == 'yes',
          'petTolerance': _profile.petTolerance.toLowerCase() != 'cannot tolerate pets',
          'sleepingSchedule': _profile.sleepingSchedule,
          'workSchedule': _profile.workSchedule,
          'sharingCommonSpaces': _profile.sharingCommonSpaces,
          'guestOvernightStays': _profile.guestsOvernightPolicy,
          'personalSpaceVsSocializing': _profile.personalSpaceVsSocialization,
        },

        'lookingFor': {
          'flatmateGender': _profile.preferredFlatmateGender,
          'flatmateAgeRangeMin': ageRange[0],
          'flatmateAgeRangeMax': ageRange[1],
          'flatmateOccupation': _profile.preferredFlatmateOccupation.isNotEmpty
              ? [_profile.preferredFlatmateOccupation]
              : [],
          'importantQualities': _profile.desiredQualities,
          'dealBreakers': _profile.dealBreakers,
        },

        'flatDetails': {
          'type': _profile.flatType,
          'rent': _parseInt(_profile.rent),
          'securityDeposit': _parseInt(_profile.deposit),
          'existingFlatmatesCount': _parseInt(_profile.numExistingFlatmates),
          'existingFlatmatesGender': _profile.genderExistingFlatmates,
          'petsAllowedInFlat': _profile.petsAllowedFlat,
          'smokingAllowedInFlat': _profile.smokingAllowedFlat,
          'drinkingAllowedInFlat': _profile.drinkingAllowedFlat,
          'guestsAllowedInFlat': _profile.guestsAllowedFlat,
          'furnishedStatus': _profile.furnishedStatus,
          'amenities': _profile.amenities,
          'locality': _profile.address,
          'availabilityDate': _profile.availabilityDate != null
              ? DateFormat('yyyy-MM-dd').format(_profile.availabilityDate!)
              : null,
          'flatVibe': _profile.flatVibe,
          'flatCleanliness': _profile.flatCleanliness,
          'flatSocialVibe': _profile.flatSocialVibe,
          'flatNoiseLevel': _profile.flatNoiseLevel,
          // 'pictures' can be added here once you implement image uploads
        },
      };

      // 2. Save the data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userProfileData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Profile saved successfully!')),
      );
      print("E");

      // 3. Navigate to a home screen or dashboard after submission
      // Example: Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));

    } catch (e) {
      print("Error submitting profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('An error occurred. Please try again. Error: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
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
          if (_currentPage < _pages.length - 1 && _currentPage != 0) // Hide 'Skip' on welcome and final screen
            TextButton(
              onPressed: () {
                if (_currentPage == _pages.length - 2) { // If on the second to last page (i.e., the last question)
                  _nextPage(); // This will navigate to the completion screen
                } else {
                  // For other pages, 'Skip' button acts as 'Next'
                  _nextPage();
                }
              },
              child: Text(
                _currentPage == _pages.length - 2 ? 'Finish' : 'Skip', // 'Finish' on the last question
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_currentPage > 0 && _currentPage < _pages.length - 1)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: LinearProgressIndicator(
                value: (_currentPage) / (_pages.length - 1),
                backgroundColor: Colors.grey[300],
                color: Colors.redAccent,
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
          if (_currentPage < _pages.length - 1 && _currentPage > 0)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
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
                      child: const Text('Next',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          if (_currentPage == 0) const SizedBox(height: 20),
        ],
      ),
    );
  }
}