// flat_with_flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firebase Import
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth Import for UID and Email
import 'package:mytennat/screens/home_page.dart';



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
  String personalSpaceVsSocialization = ''; // New field


  // Looking For Preferences
  List<String> interests = [];
  String personality = '';
  String flatmateGenderPreference = ''; // New field
  String flatmateAgePreference = ''; // New field
  String flatmateOccupationPreference = ''; // New field
  List<String> idealQualities = []; // Renamed from idealQualities
  List<String> dealBreakers = []; // Renamed from dealBreakers
  String relationshipGoal = '';

  // Flat Requirements
  String locationPreference = ''; // Kept as is, but might be redundant with areaPreference
  String flatPreference = '';
  String furnishedUnfurnished = ''; // New field
  String attachedBathroom = ''; // New field
  String balcony = ''; // New field
  String parking = ''; // New field
  String wifi = ''; // New field


  @override
  String toString() {
    return 'SeekingFlatmateProfile(\n'
        '  // Basic Info\n'
        '  name: $name,\n'
        '  age: $age,\n'
        '  gender: $gender,\n'
        '  occupation: $occupation,\n'
        '  currentLocation: $currentLocation,\n'
        '  desiredCity: $desiredCity,\n'
        '  moveInDate: $moveInDate,\n'
        '  budgetMin: $budgetMin,\n'
        '  budgetMax: $budgetMax,\n'
        '  areaPreference: $areaPreference,\n'
        '  bio: $bio,\n'
        '  // Habits\n'
        '  cleanliness: $cleanliness,\n'
        '  socialHabits: $socialHabits,\n'
        '  workSchedule: $workSchedule,\n'
        '  noiseLevel: $noiseLevel,\n'
        '  smokingHabits: $smokingHabits,\n'
        '  drinkingHabits: $drinkingHabits,\n'
        '  foodPreference: $foodPreference,\n'
        '  guestsFrequency: $guestsFrequency,\n'
        '  visitorsPolicy: $visitorsPolicy,\n'
        '  petOwnership: $petOwnership,\n'
        '  petTolerance: $petTolerance,\n'
        '  sleepingSchedule: $sleepingSchedule,\n'
        '  sharingCommonSpaces: $sharingCommonSpaces,\n'
        '  guestsPolicyOvernight: $guestsPolicyOvernight,\n'
        '  personalSpaceVsSocialization: $personalSpaceVsSocialization,\n'
        '  // Looking For Preferences\n'
        '  interests: $interests,\n'
        '  personality: $personality,\n'
        '  flatmateGenderPreference: $flatmateGenderPreference,\n'
        '  flatmateAgePreference: $flatmateAgePreference,\n'
        '  flatmateOccupationPreference: $flatmateOccupationPreference,\n'
        '  idealQualities: $idealQualities,\n'
        '  dealBreakers: $dealBreakers,\n'
        '  relationshipGoal: $relationshipGoal,\n'
        '  // Flat Requirements\n'
        '  locationPreference: $locationPreference,\n'
        '  flatPreference: $flatPreference,\n'
        '  furnishedUnfurnished: $furnishedUnfurnished,\n'
        '  attachedBathroom: $attachedBathroom,\n'
        '  balcony: $balcony,\n'
        '  parking: $parking,\n'
        '  wifi: $wifi,\n'
        ')';
  }
}

// Stateful Widget for Single Choice Questions (Ensuring consistency across files)
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

class FlatWithFlatmateProfileScreen extends StatefulWidget {
  const FlatWithFlatmateProfileScreen({super.key});

  @override
  State<FlatWithFlatmateProfileScreen> createState() =>
      _FlatWithFlatmateProfileScreenState();
}

class _FlatWithFlatmateProfileScreenState
    extends State<FlatWithFlatmateProfileScreen> {
  final PageController _pageController = PageController();
  final SeekingFlatmateProfile _seekingFlatmateProfile = SeekingFlatmateProfile();
  int _currentPage = 0;

  // Change _pages from late final to a getter
  List<Widget> get _pages => _buildPages();

  // Declare TextEditingControllers for all text input fields
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _occupationController;
  late TextEditingController _currentLocationController;
  late TextEditingController _desiredCityController; // New controller
  late TextEditingController _budgetMinController; // New controller
  late TextEditingController _budgetMaxController; // New controller
  late TextEditingController _areaPreferenceController; // New controller
  late TextEditingController _bioController;
  late TextEditingController _workScheduleController;
  late TextEditingController _sleepingScheduleController; // New controller


  @override
  void initState() {
    super.initState();
    // Initialize controllers with current profile values
    _nameController = TextEditingController(text: _seekingFlatmateProfile.name);
    _ageController = TextEditingController(text: _seekingFlatmateProfile.age);
    _occupationController = TextEditingController(text: _seekingFlatmateProfile.occupation);
    _currentLocationController = TextEditingController(text: _seekingFlatmateProfile.currentLocation);
    _desiredCityController = TextEditingController(text: _seekingFlatmateProfile.desiredCity); // Init
    _budgetMinController = TextEditingController(text: _seekingFlatmateProfile.budgetMin); // Init
    _budgetMaxController = TextEditingController(text: _seekingFlatmateProfile.budgetMax); // Init
    _areaPreferenceController = TextEditingController(text: _seekingFlatmateProfile.areaPreference); // Init
    _bioController = TextEditingController(text: _seekingFlatmateProfile.bio);
    _workScheduleController = TextEditingController(text: _seekingFlatmateProfile.workSchedule);
    _sleepingScheduleController = TextEditingController(text: _seekingFlatmateProfile.sleepingSchedule); // Init


    // Add listeners to update the profile model as text changes
    _nameController.addListener(() {
      _seekingFlatmateProfile.name = _nameController.text;
    });
    _ageController.addListener(() {
      _seekingFlatmateProfile.age = _ageController.text;
    });
    _occupationController.addListener(() {
      _seekingFlatmateProfile.occupation = _occupationController.text;
    });
    _currentLocationController.addListener(() {
      _seekingFlatmateProfile.currentLocation = _currentLocationController.text;
    });
    _desiredCityController.addListener(() { // Listener
      _seekingFlatmateProfile.desiredCity = _desiredCityController.text;
    });
    _budgetMinController.addListener(() { // Listener
      _seekingFlatmateProfile.budgetMin = _budgetMinController.text;
    });
    _budgetMaxController.addListener(() { // Listener
      _seekingFlatmateProfile.budgetMax = _budgetMaxController.text;
    });
    _areaPreferenceController.addListener(() { // Listener
      _seekingFlatmateProfile.areaPreference = _areaPreferenceController.text;
    });
    _bioController.addListener(() {
      _seekingFlatmateProfile.bio = _bioController.text;
    });
    _workScheduleController.addListener(() {
      _seekingFlatmateProfile.workSchedule = _workScheduleController.text;
    });
    _sleepingScheduleController.addListener(() { // Listener
      _seekingFlatmateProfile.sleepingSchedule = _sleepingScheduleController.text;
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _currentLocationController.dispose();
    _desiredCityController.dispose(); // Dispose
    _budgetMinController.dispose(); // Dispose
    _budgetMaxController.dispose(); // Dispose
    _areaPreferenceController.dispose(); // Dispose
    _bioController.dispose();
    _workScheduleController.dispose();
    _sleepingScheduleController.dispose(); // Dispose
    _pageController.dispose();
    super.dispose();
  }

  // --- Common Question Builders ---

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
  List<Widget> _buildPages() {

    return [

      // --- Basic Info Subsection ---

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
        subtitle: "This helps flatmates understand your age group.",
        hintText: "Enter your age",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _ageController,
      ),

      // Page 3: Gender
      SingleChoiceQuestionWidget(
        title: "What's your gender?",
        subtitle: "This helps potential flatmates relate to you.",
        options: ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.gender = value;
          });
        },
        initialValue: _seekingFlatmateProfile.gender,
      ),

      // Page 4: Occupation
      _buildTextQuestion(
        title: "What do you do for a living?",
        subtitle: "Share your profession or student status.",
        hintText: "e.g., Software Engineer, Student, Freelancer",
        controller: _occupationController,
      ),

      // Page 5: Current Location
      _buildTextQuestion(
        title: "Where are you currently located?",
        subtitle: "This helps us understand your current proximity.",
        hintText: "Enter your current city/locality",
        controller: _currentLocationController,
      ),

      // Page 6: Desired City (New)
      _buildTextQuestion(
        title: "Which city are you looking for a flat in?",
        subtitle: "Specify your desired city for flat-hunting.",
        hintText: "e.g., Pune, Mumbai",
        controller: _desiredCityController,
      ),

      // Page 7: Move-in Date
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

      // Page 8: Budget Min
      _buildTextQuestion(
        title: "What's your minimum monthly budget for rent?",
        subtitle: "Enter the lowest rent you are comfortable paying (in ₹).",
        hintText: "e.g., ₹10000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _budgetMinController,
      ),

      // Page 9: Budget Max
      _buildTextQuestion(
        title: "What's your maximum monthly budget for rent?",
        subtitle: "Enter the highest rent you are comfortable paying (in ₹).",
        hintText: "e.g., ₹15000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _budgetMaxController,
      ),

      // Page 10: Area Preference (New)
      _buildTextQuestion(
        title: "Do you have any specific area preferences?",
        subtitle: "e.g., Near IT Hubs, Quiet Neighborhoods, City Center.",
        hintText: "Enter preferred areas or 'No preference'",
        controller: _areaPreferenceController,
      ),

      // Page 11: Bio
      _buildTextQuestion(
        title: "Tell us a bit about yourself as a flatmate.",
        subtitle: "Share something interesting! This helps flatmates get to know you.",
        hintText: "e.g., I'm a quiet person who loves reading...",
        controller: _bioController,
      ),

      // --- Habits Subsection ---
      // Page 12: Smoking Habits (New)
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
      // Page 13: Drinking Habits (New)
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
      // Page 14: Food Preference (New)
      SingleChoiceQuestionWidget(
        title: "What is your food preference?",
        subtitle: "Any specific dietary habits or restrictions?",
        options: ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian', 'Jain', 'Other'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.foodPreference = value;
          });
        },
        initialValue: _seekingFlatmateProfile.foodPreference,
      ),

      // Page 15: Cleanliness
      SingleChoiceQuestionWidget(
        title: "How clean are you?",
        subtitle: "Be honest! This helps manage expectations.",
        options: ['Very Tidy', 'Moderately Tidy', 'Flexible', 'Can be messy at times'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.cleanliness = value;
          });
        },
        initialValue: _seekingFlatmateProfile.cleanliness,
      ),

      // Page 16: Noise level
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

      // Page 17: Social Habits
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

      // Page 18: Visitors policy
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

      // Page 19: Pet ownership
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
      // Page 20: Pet tolerance
      SingleChoiceQuestionWidget(
        title: "What's your tolerance for flatmates with pets?",
        subtitle: "Are you comfortable living with pets?",
        options: ['Comfortable with pets', 'Tolerant of pets', 'Prefer no pets', 'Allergic to pets'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.petTolerance = value;
          });
        },
        initialValue: _seekingFlatmateProfile.petTolerance,
      ),
      // Page 21: Sleeping schedule
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
      // Page 22: Work schedule
      SingleChoiceQuestionWidget(
        title: "What's your typical work/study schedule?",
        subtitle: "This helps in understanding common space usage.",
        options: ['9-5 Office hours', 'Freelance/Flexible hours', 'Night shifts', 'Student schedule', 'Mixed'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.workSchedule = value;
          });
        },
        initialValue: _seekingFlatmateProfile.workSchedule,
      ),

      // Page 23: Sharing Common Spaces
      SingleChoiceQuestionWidget(
        title: "How do you prefer sharing common spaces?",
        subtitle: "Do you like to share everything or prefer separate items?",
        options: ['Share everything', 'Share some items', 'Prefer separate items', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.sharingCommonSpaces = value;
          });
        },
        initialValue: _seekingFlatmateProfile.sharingCommonSpaces,
      ),
      // Page 24: Guests Policy for Overnight Stays (New)
      SingleChoiceQuestionWidget(
        title: "What's your policy on overnight guests?",
        subtitle: "How often do you expect to have guests stay overnight?",
        options: ['Frequently', 'Occasionally', 'Rarely', 'Never'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.guestsPolicyOvernight = value;
          });
        },
        initialValue: _seekingFlatmateProfile.guestsPolicyOvernight,
      ),
      // Page 25: Personal Space
      SingleChoiceQuestionWidget(
        title: "How do you balance personal space and socialization?",
        subtitle: "Do you value quiet personal time or enjoy interactive common spaces?",
        options: ['Value personal space highly', 'Enjoy a balance', 'Prefer more socialization', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.personalSpaceVsSocialization = value;
          });
        },
        initialValue: _seekingFlatmateProfile.personalSpaceVsSocialization,
      ),
      // Page 26: Interests (Multi-choice)
      _buildMultiChoiceQuestion(
        title: "What are your interests or hobbies?",
        subtitle: "Select all that apply.",
        options: [
          'Reading',
          'Gaming',
          'Cooking',
          'Fitness',
          'Movies/TV',
          'Music',
          'Travel',
          'Sports',
          'Art',
          'Outdoors',
          'Technology',
          'Fashion',
          'Volunteering'
        ],
        onSelected: (selected) {
          setState(() {
            _seekingFlatmateProfile.interests = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.interests,
      ),

      // Page 27: Preferred Flatmate Gender (New)
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate gender?",
        subtitle: "This helps in finding a compatible match.",
        options: ['Male', 'Female', 'No preference', 'Other'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.flatmateGenderPreference = value;
          });
        },
        initialValue: _seekingFlatmateProfile.flatmateGenderPreference,
      ),

      // Page 28: Preferred Flatmate Age (New)
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate age group?",
        subtitle: "This helps in finding a compatible match.",
        options: ['18-24', '25-30', '30-40', '40+', 'No preference'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.flatmateAgePreference = value;
          });
        },
        initialValue: _seekingFlatmateProfile.flatmateAgePreference,
      ),

      // Page 29: Preferred Flatmate Occupation (New)
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate occupation type?",
        subtitle: "Student, working professional, or no preference?",
        options: ['9-5 Office hours', 'Freelance/Flexible hours', 'Night shifts', 'Student schedule', 'Mixed'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.flatmateOccupationPreference = value;
          });
        },
        initialValue: _seekingFlatmateProfile.flatmateOccupationPreference,
      ),

      // Page 30: Ideal Qualities in a Flatmate (Multi-choice - Renamed)
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
            _seekingFlatmateProfile.idealQualities = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.idealQualities,
      ),

      // Page 31: Deal Breakers (Multi-choice - Renamed)
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
            _seekingFlatmateProfile.dealBreakers = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.dealBreakers,
      ),

      // Page 32: Flat Type Preference
      SingleChoiceQuestionWidget(
        title: "What type of flat are you looking for?",
        subtitle: "Studio, 1BHK, 2BHK, etc.",
        options: ['Studio Apartment', '1BHK', '2BHK', '3BHK', '4BHK+', 'Any'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.flatPreference = value;
          });
        },
        initialValue: _seekingFlatmateProfile.flatPreference,
      ),

      // Page 33: Furnished/Unfurnished Preference (New)
      SingleChoiceQuestionWidget(
        title: "Do you prefer a furnished or unfurnished flat?",
        subtitle: "Furnished means it comes with furniture.",
        options: ['Furnished', 'Unfurnished', 'Semi-furnished', 'No preference'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.furnishedUnfurnished = value;
          });
        },
        initialValue: _seekingFlatmateProfile.furnishedUnfurnished,
      ),

      // Page 34: Attached Bathroom Preference (New)
      SingleChoiceQuestionWidget(
        title: "Do you prefer an attached bathroom?",
        subtitle: "Having a private bathroom connected to your room.",
        options: ['Yes, attached bathroom', 'No, shared is fine'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.attachedBathroom = value;
          });
        },
        initialValue: _seekingFlatmateProfile.attachedBathroom,
      ),

      // Page 35: Balcony Preference (New)
      SingleChoiceQuestionWidget(
        title: "Is a balcony important to you?",
        subtitle: "Do you want a flat with a balcony?",
        options: ['Yes, a balcony is a must', 'Nice to have, but not essential', 'Not important'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.balcony = value;
          });
        },
        initialValue: _seekingFlatmateProfile.balcony,
      ),

      // Page 36: Parking Preference (New)
      SingleChoiceQuestionWidget(
        title: "Do you require parking space?",
        subtitle: "For a car or a two-wheeler.",
        options: ['Yes, for car', 'Yes, for two-wheeler', 'No, not required', 'Both car and two-wheeler'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.parking = value;
          });
        },
        initialValue: _seekingFlatmateProfile.parking,
      ),

      // Page 37: Wi-Fi Preference (New)
      SingleChoiceQuestionWidget(
        title: "Is in-built Wi-Fi a necessity?",
        subtitle: "Do you need the flat to come with Wi-Fi already set up?",
        options: ['Yes, essential', 'Nice to have', 'Not essential, I can arrange'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.wifi = value;
          });
        },
        initialValue: _seekingFlatmateProfile.wifi,
      ),
    ];
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

  // --- Firebase Integration Method ---
  Future<void> _submitProfileToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case where the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit your profile.')),
      );
      return;
    }

    // Prepare data for Firestore
    final profileData = {
      "uid": user.uid,
      "email": user.email,
      "displayName": _seekingFlatmateProfile.name,
      "age": int.tryParse(_seekingFlatmateProfile.age) ?? 0,
      "gender": _seekingFlatmateProfile.gender,
      "occupation": _seekingFlatmateProfile.occupation,
      "currentCity": _seekingFlatmateProfile.currentLocation,
      "desiredCity": _seekingFlatmateProfile.desiredCity,
      "moveInDate": _seekingFlatmateProfile.moveInDate != null
          ? Timestamp.fromDate(_seekingFlatmateProfile.moveInDate!)
          : null,
      "budgetMinExpected": int.tryParse(_seekingFlatmateProfile.budgetMin) ?? 0,
      "budgetMaxExpected": int.tryParse(_seekingFlatmateProfile.budgetMax) ?? 0,
      "areaPreference": _seekingFlatmateProfile.areaPreference.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      "userType": "seeking_flat",
      "habits": {
        "smoking": _seekingFlatmateProfile.smokingHabits,
        "drinking": _seekingFlatmateProfile.drinkingHabits,
        "food": _seekingFlatmateProfile.foodPreference,
        "cleanliness": _seekingFlatmateProfile.cleanliness,
        "noiseTolerance": _seekingFlatmateProfile.noiseLevel,
        "socialPreferences": _seekingFlatmateProfile.socialHabits,
        "visitorsPolicy": _seekingFlatmateProfile.visitorsPolicy,
        "petOwnership": _seekingFlatmateProfile.petOwnership,
        "petTolerance": _seekingFlatmateProfile.petTolerance,
        "sleepingSchedule": _seekingFlatmateProfile.sleepingSchedule,
        "workSchedule": _seekingFlatmateProfile.workSchedule,
        "sharingCommonSpaces": _seekingFlatmateProfile.sharingCommonSpaces,
        "guestOvernightStays": _seekingFlatmateProfile.guestsPolicyOvernight,
        "personalSpaceVsSocializing": _seekingFlatmateProfile.personalSpaceVsSocialization,
      },
      "flatmatePreferences": {
        "preferredFlatmateGender": _seekingFlatmateProfile.flatmateGenderPreference,
        "flatmateAgeRangeMin": _seekingFlatmateProfile.flatmateAgePreference.contains('No preference') ? null : (int.tryParse(_seekingFlatmateProfile.flatmateAgePreference.split('-')[0]) ?? 0),
        "flatmateAgeRangeMax": _seekingFlatmateProfile.flatmateAgePreference.contains('No preference') ? null : (int.tryParse(_seekingFlatmateProfile.flatmateAgePreference.split('-').last) ?? 0),
        "preferredOccupation": _seekingFlatmateProfile.flatmateOccupationPreference.isNotEmpty ? [_seekingFlatmateProfile.flatmateOccupationPreference] : [],
        "idealQualities": _seekingFlatmateProfile.idealQualities,
        "dealBreakers": _seekingFlatmateProfile.dealBreakers,
        "flatRequirements": {
          "furnishedStatus": _seekingFlatmateProfile.furnishedUnfurnished,
          "bathroomType": _seekingFlatmateProfile.attachedBathroom ,
          "balconyAvailability": _seekingFlatmateProfile.balcony,
          "parkingAvailability": _seekingFlatmateProfile.parking, // Covers car and two-wheeler
          "wifiIncluded": _seekingFlatmateProfile.wifi,
        }
      },
      "bio": _seekingFlatmateProfile.bio,
      "hobbies": _seekingFlatmateProfile.interests,
      "isProfileComplete": true,
      "createdAt": FieldValue.serverTimestamp(),
      "lastUpdated": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Use user's UID as document ID
          .set(profileData, SetOptions(merge: true)); // Merge to avoid overwriting other fields

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seeking Flatmate Profile Submitted Successfully!')),
      );
      // Navigate to HomePage after successful submission
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      print('Error submitting profile to Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit profile: $e')),
      );
    }
  }

  void _submitProfile() {
    // This is where you would typically send the _seekingFlatmateProfile data to a backend
    // or save it locally.
    print('Submitting Seeking Flatmate Profile:');
    print(_seekingFlatmateProfile.toString());

    _submitProfileToFirebase(); // Call the Firebase submission method
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
          if (_currentPage == _pages.length - 1) // Show "Finish" only on the last question page
            TextButton(
              onPressed: _submitProfile,
              child: const Text(
                'Finish',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
          if (_currentPage < _pages.length - 1) // Show "Skip" on all but the last question page
            TextButton(
              onPressed: _nextPage,
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator should be visible on all question pages
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _pages.length,
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
                    child: Text(
                        _currentPage == _pages.length - 1 ? 'Finish' : 'Next',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
//
// final profileData = {
//   "uid": user.uid,
//   "email": user.email,
//   "displayName": _seekingFlatmateProfile.name,
//   "age": int.tryParse(_seekingFlatmateProfile.age) ?? 0,
//   "gender": _seekingFlatmateProfile.gender,
//   "occupation": _seekingFlatmateProfile.occupation,
//   "currentCity": _seekingFlatmateProfile.currentLocation,
//   "desiredCity": _seekingFlatmateProfile.desiredCity,
//   "moveInDate": _seekingFlatmateProfile.moveInDate,
//   "budgetMinExpected": int.tryParse(_seekingFlatmateProfile.budgetMin) ?? 0,
//   "budgetMaxExpected": int.tryParse(_seekingFlatmateProfile.budgetMax) ?? 0,
//   "areaPreference": _seekingFlatmateProfile.areaPreference,
//   "bio": _seekingFlatmateProfile.bio,
//   "userType": "seeking_flatmate", // Explicitly set user type for seeking flatmate
//
//   "habits": {
//     "smoking":_seekingFlatmateProfile.smokingHabits,
//     "drinking": _seekingFlatmateProfile.drinkingHabits,
//     "food": _seekingFlatmateProfile.foodPreference,
//     "cleanliness": _seekingFlatmateProfile.cleanliness,
//     "noiseTolerance": _seekingFlatmateProfile.noiseLevel,
//     "socialPreferences": _seekingFlatmateProfile.socialHabits,
//     "visitorsPolicy": _seekingFlatmateProfile.visitorsPolicy,
//     "petOwnership": _seekingFlatmateProfile.petOwnership,
//     "petTolerance": _seekingFlatmateProfile.petTolerance,
//     "sleepingSchedule": _seekingFlatmateProfile.sleepingSchedule,
//     "workSchedule": _seekingFlatmateProfile.workSchedule,
//     "sharingCommonSpaces": _seekingFlatmateProfile.sharingCommonSpaces,
//     "guestOvernightStay": _seekingFlatmateProfile.guestsFrequency,
//     "personalSpaceVsSocializing": _seekingFlatmateProfile.personalSpaceVsSocialization,
//   },
//   "flatmatePreferences": {
//     "preferredFlatmateGender": _seekingFlatmateProfile
//         .preferredFlatmateGender,
//     "preferredFlatmateAge": _seekingFlatmateProfile.preferredFlatmateAge,
//     "preferredOccupation": _seekingFlatmateProfile.preferredOccupation,
//     "preferredHabits": _seekingFlatmateProfile.preferredHabits,
//     "idealQualities": _seekingFlatmateProfile.idealQualities,
//     "dealBreakers": _seekingFlatmateProfile.dealBreakers,
//   },
//   "flatRequirements":{
//     "preferredFlatType": _seekingFlatmateProfile.preferredFlatType,
//     "preferredFurnishedStatus": _seekingFlatmateProfile.preferredFurnishedStatus,
//     "amenitiesDesired": _seekingFlatmateProfile.amenitiesDesired,
//   },
//   "isProfileComplete": true,
//   "createdAt": FieldValue.serverTimestamp(),
//   "lastUpdated": FieldValue.serverTimestamp(),
// };
