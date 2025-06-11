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
        ')';
  }
}

// New Stateful Widget for Single Choice Questions
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
    // Removed specific prints to clean up console for final version, but kept for understanding
    // print('SingleChoiceQuestionWidget: initState for "${widget.title}"');
    // print('  initialValue (from widget): ${widget.initialValue}');
    // print('  _selectedOption (after initState): $_selectedOption');
  }

  // This method ensures the local state updates if the parent passes a new initialValue
  @override
  void didUpdateWidget(covariant SingleChoiceQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Removed specific prints to clean up console for final version
    // print('SingleChoiceQuestionWidget: didUpdateWidget for "${widget.title}"');
    // print('  oldWidget.initialValue: ${oldWidget.initialValue}');
    // print('  widget.initialValue: ${widget.initialValue}');
    // print('  _selectedOption (before update): $_selectedOption');

    // Only update if the initialValue from parent has changed AND it's different from our current internal state
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _selectedOption) {
      setState(() {
        _selectedOption = widget.initialValue;
        // print('  _selectedOption (after didUpdateWidget setState): $_selectedOption');
      });
    } // Removed else print
  }

  Widget _buildChipOptions(List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: options.map((option) {
          final isSelected = _selectedOption == option;

          // Removed specific prints to clean up console for final version
          // print('Chip: $option for "${widget.title}"');
          // print('  isSelected: $isSelected (current _selectedOption: $_selectedOption)');
          // if (isSelected) {
          //   print('  Selected Color (Background): ${Colors.red[700]}');
          //   print('  Checkmark Color: ${Colors.white}');
          //   print('  Label Color (Selected): ${Colors.white}');
          // } else {
          //   print('  Background Color (Unselected): ${Colors.transparent}');
          //   print('  Label Color (Unselected): ${Colors.black}');
          // }

          return ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) {
                setState(() {
                  _selectedOption = option;
                });
                widget.onSelected(option); // Notify the parent
                print('Selected Chip Option for ${widget.title}: $option');
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
            print('Selected Card Option for ${widget.title}: $option');
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
    // Removed specific prints to clean up console for final version
    // print('SingleChoiceQuestionWidget: build for "${widget.title}"');
    // print('  _selectedOption (in build): $_selectedOption');
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
  final SeekingFlatmateProfile _profile = SeekingFlatmateProfile();
  int _currentPage = 0;

  // Changed _pages from late final to a getter
  List<Widget> get _pages => _buildPages();

  @override
  void initState() {
    super.initState();
    // Removed _pages = _buildPages(); from initState
  }

  // --- Common Question Builders ---

  Widget _buildTextQuestion({
    required String title,
    required String subtitle,
    required String hintText,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? initialValue,
  }) {
    // No StatefulBuilder here, as the state is managed by the parent and `onChanged` will trigger its setState
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
            controller: TextEditingController(text: initialValue),
            onChanged:
            onChanged, // Call the provided onChanged, which should include setState
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
                    onDateSelected(picked); // This calls the parent's setState
                    print('Selected Date: $picked'); // For debugging
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
                          mainAxisSize: MainAxisSize.min, // Corrected from MainAxisSize.shrink
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
                            print(
                                'Multi-choice option for $title: $selectedOptions'); // For debugging
                          });
                          onSelected(
                              selectedOptions); // This calls the parent's setState
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
              'Welcome, ${_profile.name.isEmpty ? 'Flatmate' : _profile.name}!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "There's a lot out there to discover. Let's get your profile set up.",
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

      // Page 2: Name
      _buildTextQuestion(
        title: "What's your name?",
        subtitle: "This will be visible to other users.",
        hintText: "Enter your name",
        onChanged: (value) {
          setState(() {
            _profile.name = value;
            print('Profile name set: ${_profile.name}');
          });
        },
        initialValue: _profile.name,
      ),

      // Page 3: Age
      _buildTextQuestion(
        title: "How old are you?",
        subtitle: "We use this to find suitable flatmates.",
        hintText: "Enter your age",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {
            _profile.age = value;
            print('Profile age set: ${_profile.age}');
          });
        },
        initialValue: _profile.age,
      ),

      // Page 4: Gender
      SingleChoiceQuestionWidget(
        title: "What's your gender?",
        subtitle: "This helps match you with compatible flatmates.",
        options: ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
        onSelected: (value) {
          setState(() {
            _profile.gender = value;
            print('Profile gender set: ${_profile.gender}');
          });
        },
        initialValue: _profile.gender,
      ),

      // Page 5: Occupation
      _buildTextQuestion(
        title: "What do you do for a living?",
        subtitle: "Share your profession or student status.",
        hintText: "e.g., Software Engineer, Student, Freelancer",
        onChanged: (value) {
          setState(() {
            _profile.occupation = value;
            print('Profile occupation set: ${_profile.occupation}');
          });
        },
        initialValue: _profile.occupation,
      ),

      // Page 6: Current Location
      _buildTextQuestion(
        title: "Where are you currently located?",
        subtitle: "Knowing your current area helps us understand your needs.",
        hintText: "e.g., Pune, Mumbai",
        onChanged: (value) {
          setState(() {
            _profile.currentLocation = value;
            print('Profile current location set: ${_profile.currentLocation}');
          });
        },
        initialValue: _profile.currentLocation,
      ),

      // Page 7: Move-in Date
      _buildDateQuestion(
        title: "When are you looking to move in?",
        subtitle: "This helps us find flats available around your preferred time.",
        onDateSelected: (date) {
          setState(() {
            _profile.moveInDate = date;
            print('Profile move-in date set: ${_profile.moveInDate}');
          });
        },
        initialDate: _profile.moveInDate,
      ),

      // Page 8: Budget
      _buildTextQuestion(
        title: "What's your ideal monthly budget?",
        subtitle: "Enter your maximum budget for rent.",
        hintText: "e.g., ₹15000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {
            _profile.budget = value;
            print('Profile budget set: ${_profile.budget}');
          });
        },
        initialValue: _profile.budget,
      ),

      // Page 9: Bio
      _buildTextQuestion(
        title: "Tell us a bit about yourself.",
        subtitle: "Share something interesting! This helps flatmates get to know you.",
        hintText: "e.g., I'm a quiet person who loves reading...",
        onChanged: (value) {
          setState(() {
            _profile.bio = value;
            print('Profile bio set: ${_profile.bio}');
          });
        },
        initialValue: _profile.bio,
      ),

      // Page 10: Cleanliness
      SingleChoiceQuestionWidget(
        title: "How do you rate your cleanliness?",
        subtitle: "Be honest! This is crucial for shared living.",
        options: ['Very Clean', 'Moderately Clean', 'Average', 'Can be messy at times'],
        onSelected: (value) {
          setState(() {
            _profile.cleanliness = value;
            print('Profile cleanliness set: ${_profile.cleanliness}');
          });
        },
        initialValue: _profile.cleanliness,
      ),

      // Page 11: Social Habits
      SingleChoiceQuestionWidget(
        title: "What are your social habits like?",
        subtitle: "Do you prefer a quiet home or a social hub?",
        options: ['Social Butterfly', 'Moderately Social', 'Quiet & Reserved', 'Prefer alone time'],
        onSelected: (value) {
          setState(() {
            _profile.socialHabits = value;
            print('Profile social habits set: ${_profile.socialHabits}');
          });
        },
        initialValue: _profile.socialHabits,
      ),

      // Page 12: Work Schedule
      SingleChoiceQuestionWidget(
        title: "What's your typical work schedule?",
        subtitle: "Day, night, or variable?",
        options: ['Day Job (9-5)', 'Night Shift', 'Student Schedule', 'Freelance/Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.workSchedule = value;
            print('Profile work schedule set: ${_profile.workSchedule}');
          });
        },
        initialValue: _profile.workSchedule,
      ),

      // Page 13: Noise Level
      SingleChoiceQuestionWidget(
        title: "What's your preferred noise level at home?",
        subtitle: "How quiet or lively do you like your living space?",
        options: ['Pin-drop silence', 'Quiet most of the time', 'Moderate noise is fine', 'Lively and energetic'],
        onSelected: (value) {
          setState(() {
            _profile.noiseLevel = value;
            print('Profile noise level set: ${_profile.noiseLevel}');
          });
        },
        initialValue: _profile.noiseLevel,
      ),

      // Page 14: Smoker
      SingleChoiceQuestionWidget(
        title: "Do you smoke?",
        subtitle: "This helps flatmates understand your habits.",
        options: ['Yes', 'No', 'Occasionally'],
        onSelected: (value) {
          setState(() {
            _profile.isSmoker = value;
            print('Profile smoker status set: ${_profile.isSmoker}');
          });
        },
        initialValue: _profile.isSmoker,
      ),

      // Page 15: Drinking Habit
      SingleChoiceQuestionWidget(
        title: "What's your drinking habit?",
        subtitle: "Do you drink alcohol?",
        options: ['Never', 'Rarely', 'Socially', 'Frequently'],
        onSelected: (value) {
          setState(() {
            _profile.drinkingHabit = value;
            print('Profile drinking habit set: ${_profile.drinkingHabit}');
          });
        },
        initialValue: _profile.drinkingHabit,
      ),

      // Page 16: Pets
      SingleChoiceQuestionWidget(
        title: "Do you have pets?",
        subtitle: "Some flats or flatmates have pet restrictions.",
        options: ['Yes', 'No', 'Plan to get one'],
        onSelected: (value) {
          setState(() {
            _profile.hasPets = value;
            print('Profile has pets set: ${_profile.hasPets}');
          });
        },
        initialValue: _profile.hasPets,
      ),

      // Page 17: Dietary Preference
      SingleChoiceQuestionWidget(
        title: "What's your dietary preference?",
        subtitle: "Helpful for shared cooking or meal planning.",
        options: ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian', 'Other'],
        onSelected: (value) {
          setState(() {
            _profile.dietaryPreference = value;
            print('Profile dietary preference set: ${_profile.dietaryPreference}');
          });
        },
        initialValue: _profile.dietaryPreference,
      ),

      // Page 18: Guests Frequency
      SingleChoiceQuestionWidget(
        title: "How often do you expect guests?",
        subtitle: "Lets flatmates know your social frequency.",
        options: ['Rarely', 'Occasionally', 'Often', 'Frequently'],
        onSelected: (value) {
          setState(() {
            _profile.guestsFrequency = value;
            print('Profile guests frequency set: ${_profile.guestsFrequency}');
          });
        },
        initialValue: _profile.guestsFrequency,
      ),

      // Page 19: Interests (Multi-choice)
      _buildMultiChoiceQuestion(
        title: "What are your interests?",
        subtitle: "Select all that apply. Find flatmates with similar hobbies!",
        options: [
          'Reading', 'Gaming', 'Cooking', 'Sports', 'Music', 'Movies', 'Travel',
          'Fitness', 'Art', 'Photography', 'Technology', 'Nature', 'Volunteering'
        ],
        onSelected: (selected) {
          setState(() {
            _profile.interests = selected;
            print('Profile interests set: ${_profile.interests}');
          });
        },
        initialValues: _profile.interests,
      ),

      // Page 20: Personality (Cards)
      SingleChoiceQuestionWidget(
        title: "How would you describe your personality?",
        subtitle: "Choose the option that best fits you.",
        options: [
          'Extrovert',
          'Introvert',
          'Ambivert',
          'Reserved',
          'Outgoing',
          'Easy-going',
          'Serious',
          'Creative'
        ],
        isCard: true,
        onSelected: (value) {
          setState(() {
            _profile.personality = value;
            print('Profile personality set: ${_profile.personality}');
          });
        },
        initialValue: _profile.personality,
      ),

      // Page 21: Ideal Flatmate Qualities (Multi-choice)
      _buildMultiChoiceQuestion(
        title: "What are your ideal flatmate qualities?",
        subtitle: "Select qualities you look for in a flatmate.",
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
            _profile.idealQualities = selected;
            print('Profile ideal qualities set: ${_profile.idealQualities}');
          });
        },
        initialValues: _profile.idealQualities,
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
            _profile.dealBreakers = selected;
            print('Profile deal breakers set: ${_profile.dealBreakers}');
          });
        },
        initialValues: _profile.dealBreakers,
      ),

      // Page 23: Location Preference
      _buildTextQuestion(
        title: "Where are you looking to live?",
        subtitle: "Specify preferred localities or areas.",
        hintText: "e.g., Koregaon Park, Viman Nagar",
        onChanged: (value) {
          setState(() {
            _profile.locationPreference = value;
            print('Profile location preference set: ${_profile.locationPreference}');
          });
        },
        initialValue: _profile.locationPreference,
      ),

      // Page 24: Flat Preference
      SingleChoiceQuestionWidget(
        title: "What type of flat are you looking for?",
        subtitle: "Studio, 1BHK, shared room, etc.",
        options: ['Shared Room', 'Studio Apartment', '1BHK', '2BHK (sharing)', '3BHK (sharing)'],
        onSelected: (value) {
          setState(() {
            _profile.flatPreference = value;
            print('Profile flat preference set: ${_profile.flatPreference}');
          });
        },
        initialValue: _profile.flatPreference,
      ),

      // Page 25: Relationship Goal (if applicable, e.g., friendship focus)
      SingleChoiceQuestionWidget(
        title: "What kind of relationship are you seeking with flatmates?",
        subtitle: "Are you looking for friends, or just co-habitants?",
        options: ['Close Friends', 'Friendly Acquaintances', 'Strictly Professional', 'Open to anything'],
        onSelected: (value) {
          setState(() {
            _profile.relationshipGoal = value;
            print('Profile relationship goal set: ${_profile.relationshipGoal}');
          });
        },
        initialValue: _profile.relationshipGoal,
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
            'Your profile is ready, ${_profile.name}!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "You're all set. Let's find you the perfect flat.",
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
            child: const Text("Find my Flat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _nextPage() {
    print('Navigating to next page. Current _currentPage: $_currentPage');
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
    print('Navigating to previous page. Current _currentPage: $_currentPage');
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _submitProfile() {
    // This is where you would typically send the _profile data to a backend
    // or save it locally.
    // print('Submitting Profile:');
    // print(_profile.toString());

    // For demonstration, navigate away or show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Profile Submitted Successfully! Check console for data.')),
    );
    // You might navigate to a different screen here, e.g.:
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    print('FlatWithFlatmateProfileScreen: Building entire screen.');
    print('  _profile.gender at build time: ${_profile.gender}');
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
                  print('PageView onPageChanged: _currentPage updated to $page');
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