// flat_with_flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firebase Import
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth Import for UID and Email
import 'package:intl/intl.dart'; // Added for date formatting
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

  // Flatmate Preferences
  String preferredFlatmateGender = ''; // New field
  String preferredFlatmateAge = ''; // New field
  String preferredOccupation = ''; // New field
  List<String> preferredHabits = []; // New field
  List<String> dealBreakers = []; // New field
  String preferredFlatType = ''; // New field
  String preferredFurnishedStatus = ''; // New field
  List<String> amenitiesDesired = []; // New field
  // Assuming these will be collected via text input for now, adjust if they become single choice
  String securityDepositBudget = ''; // Added field
  List<String> commonInterests = []; // Added field, assuming multi-choice for now


  @override
  String toString() {
    return 'SeekingFlatmateProfile(\n'
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
        '  preferredFlatmateGender: $preferredFlatmateGender,\n'
        '  preferredFlatmateAge: $preferredFlatmateAge,\n'
        '  preferredOccupation: $preferredOccupation,\n'
        '  preferredHabits: $preferredHabits,\n'
        '  dealBreakers: $dealBreakers,\n'
        '  preferredFlatType: $preferredFlatType,\n'
        '  preferredFurnishedStatus: $preferredFurnishedStatus,\n'
        '  amenitiesDesired: $amenitiesDesired,\n'
        '  securityDepositBudget: $securityDepositBudget,\n'
        '  commonInterests: $commonInterests,\n'
        ')';
  }
}

// Stateful Widget for Single Choice Questions (Copied from previous interaction to ensure consistency)
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
    return Column(
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
        widget.isCard
            ? _buildCardOptions(widget.options)
            : _buildChipOptions(widget.options),
      ],
    );
  }
}

// Stateful Widget for Multi Choice Questions (Copied from previous interaction to ensure consistency)
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
  State<MultiChoiceQuestionWidget> createState() => _MultiChoiceQuestionWidgetState();
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
    return Column(
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
        Wrap( // Changed from SingleChildScrollView for simpler layout in grouped view
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
                  if (isSelected) const Icon(Icons.check, size: 18, color: Colors.redAccent),
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
              labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              side: BorderSide(
                color: isSelected ? Colors.redAccent : Colors.grey.shade300,
                width: 1.5,
              ),
              backgroundColor: Colors.grey.shade50,
              selectedColor: Colors.red.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? Colors.redAccent : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
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
  late TextEditingController _securityDepositBudgetController; // New controller


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _seekingFlatmateProfile.name);
    _ageController = TextEditingController(text: _seekingFlatmateProfile.age);
    _occupationController = TextEditingController(text: _seekingFlatmateProfile.occupation);
    _currentLocationController = TextEditingController(text: _seekingFlatmateProfile.currentLocation);
    _desiredCityController = TextEditingController(text: _seekingFlatmateProfile.desiredCity);
    _budgetMinController = TextEditingController(text: _seekingFlatmateProfile.budgetMin);
    _budgetMaxController = TextEditingController(text: _seekingFlatmateProfile.budgetMax);
    _areaPreferenceController = TextEditingController(text: _seekingFlatmateProfile.areaPreference);
    _bioController = TextEditingController(text: _seekingFlatmateProfile.bio);
    _securityDepositBudgetController = TextEditingController(text: _seekingFlatmateProfile.securityDepositBudget);

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
    _desiredCityController.addListener(() {
      _seekingFlatmateProfile.desiredCity = _desiredCityController.text;
    });
    _budgetMinController.addListener(() {
      _seekingFlatmateProfile.budgetMin = _budgetMinController.text;
    });
    _budgetMaxController.addListener(() {
      _seekingFlatmateProfile.budgetMax = _budgetMaxController.text;
    });
    _areaPreferenceController.addListener(() {
      _seekingFlatmateProfile.areaPreference = _areaPreferenceController.text;
    });
    _bioController.addListener(() {
      _seekingFlatmateProfile.bio = _bioController.text;
    });
    _securityDepositBudgetController.addListener(() {
      _seekingFlatmateProfile.securityDepositBudget = _securityDepositBudgetController.text;
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
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _areaPreferenceController.dispose();
    _bioController.dispose();
    _securityDepositBudgetController.dispose();
    super.dispose();
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
    } else {
      Navigator.of(context).pop();
    }
  }

  // Helper for text input questions
  Widget _buildTextQuestion({
    required String title,
    required String subtitle,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
  }) {
    return Column(
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }

  // Helper for date input questions
  Widget _buildDateQuestion({
    required String title,
    required String subtitle,
    required Function(DateTime) onDateSelected,
    DateTime? initialDate,
  }) {
    return Column(
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
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  initialDate != null
                      ? DateFormat('dd MMMM yyyy').format(initialDate)
                      : 'Select Date',
                  style: TextStyle(
                    fontSize: 16,
                    color: initialDate != null ? Colors.black : Colors.grey[700],
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper for grouped questions (text or choice)
  Widget _buildGroupedQuestionsPage(List<Widget> questionWidgets) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: questionWidgets.expand((widget) => [
          widget,
          const SizedBox(height: 30), // Spacing after each question
        ]).toList()..removeLast(), // Remove the last SizedBox
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      // Group 1: Personal Details (Text Inputs)
      _buildGroupedQuestionsPage([
        _buildTextQuestion(
          title: "What's your name?",
          subtitle: "This will be visible to potential flatmates.",
          hintText: "Enter your name",
          controller: _nameController,
        ),
        _buildTextQuestion(
          title: "How old are you?",
          subtitle: "This helps flatmates understand your age group.",
          hintText: "Enter your age",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: _ageController,
        ),
        _buildTextQuestion(
          title: "What do you do for a living?",
          subtitle: "Share your profession or student status.",
          hintText: "e.g., Software Engineer, Student, Freelancer",
          controller: _occupationController,
        ),
      ]),

      // Group 2: Bio, Location & Budget (Text Inputs & Date)
      _buildGroupedQuestionsPage([
        _buildTextQuestion(
          title: "Tell us a bit about yourself.",
          subtitle: "Share something interesting! This helps others get to know you.",
          hintText: "e.g., I'm a quiet person who loves reading...",
          controller: _bioController,
          maxLines: 5,
        ),
        _buildTextQuestion(
          title: "Where are you currently located?",
          subtitle: "Your current city/locality.",
          hintText: "Enter current city/locality",
          controller: _currentLocationController,
        ),
        _buildTextQuestion(
          title: "Which city are you looking for a flat in?",
          subtitle: "The city where you want to find a flatmate.",
          hintText: "e.g., Pune, Mumbai",
          controller: _desiredCityController,
        ),
        _buildTextQuestion(
          title: "What is your preferred area/locality?",
          subtitle: "e.g., Koregaon Park, Viman Nagar, Hinjewadi.",
          hintText: "Enter preferred area/locality",
          controller: _areaPreferenceController,
        ),
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
      ]),

      // Group 3: Budget Details (Text Inputs)
      _buildGroupedQuestionsPage([
        _buildTextQuestion(
          title: "What is your minimum budget for rent per month?",
          subtitle: "Enter the amount in ₹.",
          hintText: "e.g., ₹8000",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: _budgetMinController,
        ),
        _buildTextQuestion(
          title: "What is your maximum budget for rent per month?",
          subtitle: "Enter the amount in ₹.",
          hintText: "e.g., ₹15000",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: _budgetMaxController,
        ),
        _buildTextQuestion(
          title: "What is your budget for security deposit?",
          subtitle: "Enter the amount in ₹.",
          hintText: "e.g., ₹20000",
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          controller: _securityDepositBudgetController,
        ),
      ]),

      // Group 4: Personal & Social Habits (Single Choice)
      _buildGroupedQuestionsPage([
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
        SingleChoiceQuestionWidget(
          title: "What's your preferred noise level?",
          subtitle: "How quiet or lively do you like the home to be?",
          options: ['Very quiet', 'Moderate noise', 'Lively', 'Flexible'],
          onSelected: (value) {
            setState(() {
              _seekingFlatmateProfile.noiseLevel = value;
            });
          },
          initialValue: _seekingFlatmateProfile.noiseLevel,
        ),
      ]),

      // Group 5: Specific Habits (Single Choice)
      _buildGroupedQuestionsPage([
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
        SingleChoiceQuestionWidget(
          title: "How often do you have guests?",
          subtitle: "This helps manage expectations regarding visitors.",
          options: ['Frequently', 'Occasionally', 'Rarely', 'Never'],
          onSelected: (value) {
            setState(() {
              _seekingFlatmateProfile.guestsFrequency = value;
            });
          },
          initialValue: _seekingFlatmateProfile.guestsFrequency,
        ),
      ]),

      // Group 6: Living Habits (Single Choice)
      _buildGroupedQuestionsPage([
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
        SingleChoiceQuestionWidget(
          title: "Do you own pets?",
          subtitle: "Are you bringing any furry friends?",
          options: ['Yes', 'No', 'Planning to get one'],
          onSelected: (value) {
            setState(() {
              _seekingFlatmateProfile.petOwnership = value;
            });
          },
          initialValue: _seekingFlatmateProfile.petOwnership,
        ),
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
      ]),

      // Group 7: Preferred Flatmate Criteria (Single Choice)
      _buildGroupedQuestionsPage([
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
      ]),

      // Group 8: Preferred Flat Type & Furnishing (Single Choice)
      _buildGroupedQuestionsPage([
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
        SingleChoiceQuestionWidget(
          title: "Do you prefer furnished, semi-furnished, or unfurnished?",
          subtitle: "Specify your preference for flat furnishing.",
          options: ['Furnished', 'Semi-furnished', 'Unfurnished', 'No Preference'],
          onSelected: (value) {
            setState(() {
              _seekingFlatmateProfile.preferredFurnishedStatus = value;
            });
          },
          initialValue: _seekingFlatmateProfile.preferredFurnishedStatus,
        ),
      ]),

      // Group 9: Desired Amenities (Multi-Choice)
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
          'Security',
          'Parking'
        ],
        onSelected: (selected) {
          setState(() {
            _seekingFlatmateProfile.amenitiesDesired = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.amenitiesDesired,
      ),

      // Group 10: Preferred Flatmate Habits (Multi-Choice)
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

      // Group 11: Flatmate Deal Breakers (Multi-Choice)
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

      // Group 12: Common Interests (Multi-Choice)
      MultiChoiceQuestionWidget(
        title: "What are some of your common interests?",
        subtitle: "Helps find a flatmate you can connect with.",
        options: [
          'Reading', 'Gaming', 'Cooking', 'Fitness', 'Movies',
          'Music', 'Travel', 'Hiking', 'Sports', 'Art', 'Photography',
          'Volunteering', 'Board Games', 'Yoga', 'Meditation'
        ],
        onSelected: (selected) {
          setState(() {
            _seekingFlatmateProfile.commonInterests = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.commonInterests,
      ),
    ];
  }


  Future<void> _submitProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    try {
      final profileData = {
        "uid": user.uid,
        "email": user.email,
        "displayName": _seekingFlatmateProfile.name,
        "age": int.tryParse(_seekingFlatmateProfile.age) ?? 0,
        "gender": _seekingFlatmateProfile.gender,
        "occupation": _seekingFlatmateProfile.occupation,
        "currentCity": _seekingFlatmateProfile.currentLocation,
        "desiredCity": _seekingFlatmateProfile.desiredCity,
        "moveInDate": _seekingFlatmateProfile.moveInDate,
        "budgetMinExpected": int.tryParse(_seekingFlatmateProfile.budgetMin) ?? 0,
        "budgetMaxExpected": int.tryParse(_seekingFlatmateProfile.budgetMax) ?? 0,
        "areaPreference": _seekingFlatmateProfile.areaPreference,
        "bio": _seekingFlatmateProfile.bio,
        "userType": "seeking_flatmate", // Explicitly set user type for seeking flatmate

        "habits": {
          "cleanliness": _seekingFlatmateProfile.cleanliness,
          "socialHabits": _seekingFlatmateProfile.socialHabits,
          "workSchedule": _seekingFlatmateProfile.workSchedule,
          "noiseTolerance": _seekingFlatmateProfile.noiseLevel,
          "smoking":_seekingFlatmateProfile.smokingHabits,
          "drinking": _seekingFlatmateProfile.drinkingHabits,
          "food": _seekingFlatmateProfile.foodPreference,
          "guestsFrequency": _seekingFlatmateProfile.guestsFrequency,
          "visitorsPolicy": _seekingFlatmateProfile.visitorsPolicy,
          "petOwnership": _seekingFlatmateProfile.petOwnership,
          "petTolerance": _seekingFlatmateProfile.petTolerance,
          "sleepingSchedule": _seekingFlatmateProfile.sleepingSchedule,
          "sharingCommonSpaces": _seekingFlatmateProfile.sharingCommonSpaces,
        },
        "preferences": {
          "preferredFlatmateGender": _seekingFlatmateProfile.preferredFlatmateGender,
          "preferredFlatmateAge": _seekingFlatmateProfile.preferredFlatmateAge,
          "preferredOccupation": _seekingFlatmateProfile.preferredOccupation,
          "preferredHabits": _seekingFlatmateProfile.preferredHabits,
          "dealBreakers": _seekingFlatmateProfile.dealBreakers,
          "preferredFlatType": _seekingFlatmateProfile.preferredFlatType,
          "preferredFurnishedStatus": _seekingFlatmateProfile.preferredFurnishedStatus,
          "amenitiesDesired": _seekingFlatmateProfile.amenitiesDesired,
          "securityDepositBudget": _seekingFlatmateProfile.securityDepositBudget,
          "commonInterests": _seekingFlatmateProfile.commonInterests,
        },
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase Auth Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seeking Flatmate Profile'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _pages.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swiping
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
      ),
    );
  }
}