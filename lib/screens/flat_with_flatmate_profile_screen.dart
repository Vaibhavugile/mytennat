// flat_with_flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Data model to hold all the answers for the user seeking a flat
class SeekingFlatmateProfile {
  String name = '';
  String age = '';
  String gender = '';
  String occupation = '';
  String currentLocation = '';
  DateTime? moveInDate;
  String budget = '';
  String bio = '';
  String cleanliness = '';
  String socialHabits = '';
  String workSchedule = '';
  String noiseLevel = '';
  String isSmoker = '';
  String drinkingHabit = '';
  String hasPets = '';
  String dietaryPreference = '';
  String guestsFrequency = '';
  List<String> interests = [];
  String personality = '';
  List<String> idealQualities = [];
  List<String> dealBreakers = [];
  String locationPreference = '';
  String flatPreference = '';
  String relationshipGoal = '';

  @override
  String toString() {
    return 'SeekingFlatmateProfile(\n'
        '  name: $name,\n'
        '  age: $age,\n'
        '  gender: $gender,\n'
        '  occupation: $occupation,\n'
        '  currentLocation: $currentLocation,\n'
        '  moveInDate: $moveInDate,\n'
        '  budget: $budget,\n'
        '  bio: $bio,\n'
        '  cleanliness: $cleanliness,\n'
        '  socialHabits: $socialHabits,\n'
        '  workSchedule: $workSchedule,\n'
        '  noiseLevel: $noiseLevel,\n'
        '  isSmoker: $isSmoker,\n'
        '  drinkingHabit: $drinkingHabit,\n'
        '  hasPets: $hasPets,\n'
        '  dietaryPreference: $dietaryPreference,\n'
        '  guestsFrequency: $guestsFrequency,\n'
        '  interests: $interests,\n'
        '  personality: $personality,\n'
        '  idealQualities: $idealQualities,\n'
        '  dealBreakers: $dealBreakers,\n'
        '  locationPreference: $locationPreference,\n'
        '  flatPreference: $flatPreference,\n'
        '  relationshipGoal: $relationshipGoal,\n'
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
  late TextEditingController _budgetController;
  late TextEditingController _bioController;
  late TextEditingController _workScheduleController;


  @override
  void initState() {
    super.initState();
    // Initialize controllers with current profile values
    _nameController = TextEditingController(text: _seekingFlatmateProfile.name);
    _ageController = TextEditingController(text: _seekingFlatmateProfile.age);
    _occupationController = TextEditingController(text: _seekingFlatmateProfile.occupation);
    _currentLocationController = TextEditingController(text: _seekingFlatmateProfile.currentLocation);
    _budgetController = TextEditingController(text: _seekingFlatmateProfile.budget);
    _bioController = TextEditingController(text: _seekingFlatmateProfile.bio);
    _workScheduleController = TextEditingController(text: _seekingFlatmateProfile.workSchedule);

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
    _budgetController.addListener(() {
      _seekingFlatmateProfile.budget = _budgetController.text;
    });
    _bioController.addListener(() {
      _seekingFlatmateProfile.bio = _bioController.text;
    });
    _workScheduleController.addListener(() {
      _seekingFlatmateProfile.workSchedule = _workScheduleController.text;
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _currentLocationController.dispose();
    _budgetController.dispose();
    _bioController.dispose();
    _workScheduleController.dispose();
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


      // Page 2: Name
      _buildTextQuestion(
        title: "What's your name?",
        subtitle: "This will be visible to potential flatmates.",
        hintText: "Enter your name",
        controller: _nameController, // Use the controller
      ),
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('👋', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${_seekingFlatmateProfile.name.isEmpty ? 'Seeker' : _seekingFlatmateProfile.name}!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Let's find you a perfect flatmate and flat.",
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
            TextButton(
              onPressed: () {
                _pageController.jumpToPage(1);
              },
              child: const Text('Edit name',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // Page 3: Age
      _buildTextQuestion(
        title: "How old are you?",
        subtitle: "This helps flatmates understand your age group.",
        hintText: "Enter your age",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _ageController, // Use the controller
      ),

      // Page 4: Gender
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

      // Page 5: Occupation
      _buildTextQuestion(
        title: "What do you do for a living?",
        subtitle: "Share your profession or student status.",
        hintText: "e.g., Software Engineer, Student, Freelancer",
        controller: _occupationController, // Use the controller
      ),

      // Page 6: Current Location
      _buildTextQuestion(
        title: "Where are you currently located?",
        subtitle: "This helps us find flats near you.",
        hintText: "Enter your current city/locality",
        controller: _currentLocationController, // Use the controller
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

      // Page 8: Budget
      _buildTextQuestion(
        title: "What's your monthly budget for rent?",
        subtitle: "Specify your comfortable budget range.",
        hintText: "e.g., ₹10000 - ₹15000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _budgetController, // Use the controller
      ),

      // Page 9: Bio
      _buildTextQuestion(
        title: "Tell us a bit about yourself as a flatmate.",
        subtitle: "Share something interesting! This helps flatmates get to know you.",
        hintText: "e.g., I'm a quiet person who loves reading...",
        controller: _bioController, // Use the controller
      ),

      // Page 10: Cleanliness
      SingleChoiceQuestionWidget(
        title: "How clean are you?",
        subtitle: "Your personal cleanliness habits.",
        options: ['Very Clean', 'Moderately Clean', 'Flexible', 'Can be messy'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.cleanliness = value;
          });
        },
        initialValue: _seekingFlatmateProfile.cleanliness,
      ),

      // Page 11: Social Habits
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

      // Page 12: Work Schedule
      _buildTextQuestion(
        title: "What's your typical work/study schedule?",
        subtitle: "Day, night, or variable?",
        hintText: "e.g., 9-5 job, night shifts, student",
        controller: _workScheduleController, // Use the controller
      ),

      // Page 13: Noise Level
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

      // Page 14: Is Smoker
      SingleChoiceQuestionWidget(
        title: "Are you a smoker?",
        subtitle: "Indoors or outdoors only?",
        options: ['Yes, indoors', 'Yes, outdoors only', 'No'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.isSmoker = value;
          });
        },
        initialValue: _seekingFlatmateProfile.isSmoker,
      ),

      // Page 15: Drinking Habit
      SingleChoiceQuestionWidget(
        title: "What are your drinking habits?",
        subtitle: "Socially, regularly, or not at all?",
        options: ['Socially', 'Regularly', 'Never'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.drinkingHabit = value;
          });
        },
        initialValue: _seekingFlatmateProfile.drinkingHabit,
      ),

      // Page 16: Has Pets
      SingleChoiceQuestionWidget(
        title: "Do you have pets?",
        subtitle: "Are you bringing any furry friends?",
        options: ['Yes', 'No', 'Planning to get one'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.hasPets = value;
          });
        },
        initialValue: _seekingFlatmateProfile.hasPets,
      ),

      // Page 17: Dietary Preference
      SingleChoiceQuestionWidget(
        title: "What is your dietary preference?",
        subtitle: "Any specific food habits or restrictions?",
        options: ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Other'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.dietaryPreference = value;
          });
        },
        initialValue: _seekingFlatmateProfile.dietaryPreference,
      ),

      // Page 18: Guests Frequency
      SingleChoiceQuestionWidget(
        title: "How often do you plan to have guests?",
        subtitle: "Occasional, frequent, or rarely?",
        options: ['Rarely', 'Occasionally', 'Frequently'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.guestsFrequency = value;
          });
        },
        initialValue: _seekingFlatmateProfile.guestsFrequency,
      ),

      // Page 19: Interests (Multi-choice)
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
          'Outdoors'
        ],
        onSelected: (selected) {
          setState(() {
            _seekingFlatmateProfile.interests = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.interests,
      ),

      // Page 20: Personality
      SingleChoiceQuestionWidget(
        title: "Describe your personality.",
        subtitle: "Are you an introvert or extrovert?",
        options: ['Introvert', 'Extrovert', 'Ambivert'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.personality = value;
          });
        },
        initialValue: _seekingFlatmateProfile.personality,
      ),

      // Page 21: Ideal Qualities in a Flatmate (Multi-choice)
      _buildMultiChoiceQuestion(
        title: "What are ideal qualities in a flatmate for you?",
        subtitle: "Select all that apply.",
        options: [
          'Respectful',
          'Tidy',
          'Communicative',
          'Friendly',
          'Responsible',
          'Quiet',
          'Social',
          'Independent'
        ],
        onSelected: (selected) {
          setState(() {
            _seekingFlatmateProfile.idealQualities = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.idealQualities,
      ),

      // Page 22: Deal Breakers (Multi-choice)
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
          'Late Night Guests'
        ],
        onSelected: (selected) {
          setState(() {
            _seekingFlatmateProfile.dealBreakers = selected;
          });
        },
        initialValues: _seekingFlatmateProfile.dealBreakers,
      ),

      // Page 23: Location Preference
      SingleChoiceQuestionWidget(
        title: "What's your preferred flat location?",
        subtitle: "City area, suburban, or near specific landmarks?",
        options: ['City Center', 'Suburban', 'Near University', 'Near Business Park', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.locationPreference = value;
          });
        },
        initialValue: _seekingFlatmateProfile.locationPreference,
      ),

      // Page 24: Flat Type Preference
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

      // Page 25: Relationship Goal
      SingleChoiceQuestionWidget(
        title: "What kind of flatmate relationship are you seeking?",
        subtitle: "Strictly roommates, friendly, or best friends?",
        options: ['Strictly roommates', 'Friendly but independent', 'Good friends', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _seekingFlatmateProfile.relationshipGoal = value;
          });
        },
        initialValue: _seekingFlatmateProfile.relationshipGoal,
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
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Text(
            'Your profile is ready, ${_seekingFlatmateProfile.name}!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "You're all set. Let's find your perfect flat and flatmate.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _submitProfile,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: const Text("Find my Flat & Flatmate",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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

  void _submitProfile() {
    // This is where you would typically send the _seekingFlatmateProfile data to a backend
    // or save it locally.
    // print('Submitting Seeking Flatmate Profile:');
    // print(_seekingFlatmateProfile.toString());

    // For demonstration, navigate away or show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Seeking Flatmate Profile Submitted Successfully! Check console for data.')),
    );
    // You might navigate to a different screen here, e.g.:
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: _nextPage,
              child: Text(
                _currentPage == _pages.length - 2 ? 'Finish' : 'Skip',
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