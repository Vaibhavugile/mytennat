// flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this
import 'package:intl/intl.dart'; // Add this
import 'package:mytennat/screens/home_page.dart';


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
        '  flatType: $flatType,\n'
        '  furnishedStatus: $furnishedStatus,\n'
        '  availableFor: $availableFor,\n'
        '  availabilityDate: $availabilityDate,\n'
        '  rentPrice: $rentPrice,\n'
        '  depositAmount: $depositAmount,\n'
        '  bathroomType: $bathroomType,\n'
        '  balconyAvailability: $balconyAvailability,\n'
        '  parkingAvailability: $parkingAvailability,\n'
        '  amenities: $amenities,\n'
        '  address: $address,\n'
        '  landmark: $landmark,\n'
        '  flatDescription: $flatDescription,\n'
        '  preferredGender: $preferredGender,\n'
        '  preferredAgeGroup: $preferredAgeGroup,\n'
        '  preferredOccupation: $preferredOccupation,\n'
        '  preferredHabits: $preferredHabits,\n'
        '  flatmateIdealQualities: $flatmateIdealQualities,\n'
        '  flatmateDealBreakers: $flatmateDealBreakers,\n'
        ')';
  }
}

// Stateful Widget for Single Choice Questions
class SingleChoiceQuestionWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Function(String) onSelected;
  final bool isCard;
  final String? initialValue; // New parameter for initial value

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
    // Update selected option if initialValue changes from parent
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

// Stateful Widget for Multi Choice Questions
class MultiChoiceQuestionWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Function(List<String>) onSelected;
  final List<String> initialValues; // New parameter for initial values

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
    // Update selected options if initialValues change from parent
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

class FlatmateProfileScreen extends StatefulWidget {
  const FlatmateProfileScreen({super.key});

  @override
  State<FlatmateProfileScreen> createState() => _FlatmateProfileScreenState();
}

class _FlatmateProfileScreenState extends State<FlatmateProfileScreen> {
  final PageController _pageController = PageController();
  final FlatListingProfile _flatListingProfile = FlatListingProfile();
  int _currentPage = 0;

  // Change _pages from late final to a getter
  List<Widget> get _pages => _buildPages();

  // Declare TextEditingControllers for all text input fields
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerAgeController;
  late TextEditingController _ownerOccupationController;
  late TextEditingController _ownerBioController;
  late TextEditingController _currentCityController;
  late TextEditingController _desiredCityController;
  late TextEditingController _budgetMinController;
  late TextEditingController _budgetMaxController;
  late TextEditingController _areaPreferenceController;
  late TextEditingController _rentPriceController;
  late TextEditingController _depositAmountController;
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _flatDescriptionController;


  @override
  void initState() {
    super.initState();
    // Initialize controllers with current profile values
    _ownerNameController = TextEditingController(text: _flatListingProfile.ownerName);
    _ownerAgeController = TextEditingController(text: _flatListingProfile.ownerAge);
    _ownerOccupationController = TextEditingController(text: _flatListingProfile.ownerOccupation);
    _ownerBioController = TextEditingController(text: _flatListingProfile.ownerBio);
    _currentCityController = TextEditingController(text: _flatListingProfile.currentCity);
    _desiredCityController = TextEditingController(text: _flatListingProfile.desiredCity);
    _budgetMinController = TextEditingController(text: _flatListingProfile.budgetMin);
    _budgetMaxController = TextEditingController(text: _flatListingProfile.budgetMax);
    _areaPreferenceController = TextEditingController(text: _flatListingProfile.areaPreference);
    _rentPriceController = TextEditingController(text: _flatListingProfile.rentPrice);
    _depositAmountController = TextEditingController(text: _flatListingProfile.depositAmount);
    _addressController = TextEditingController(text: _flatListingProfile.address);
    _landmarkController = TextEditingController(text: _flatListingProfile.landmark);
    _flatDescriptionController = TextEditingController(text: _flatListingProfile.flatDescription);


    // Add listeners to update the profile model as text changes
    _ownerNameController.addListener(() {
      _flatListingProfile.ownerName = _ownerNameController.text;
    });
    _ownerAgeController.addListener(() {
      _flatListingProfile.ownerAge = _ownerAgeController.text;
    });
    _ownerOccupationController.addListener(() {
      _flatListingProfile.ownerOccupation = _ownerOccupationController.text;
    });
    _ownerBioController.addListener(() {
      _flatListingProfile.ownerBio = _ownerBioController.text;
    });
    _currentCityController.addListener(() {
      _flatListingProfile.currentCity = _currentCityController.text;
    });
    _desiredCityController.addListener(() {
      _flatListingProfile.desiredCity = _desiredCityController.text;
    });
    _budgetMinController.addListener(() {
      _flatListingProfile.budgetMin = _budgetMinController.text;
    });
    _budgetMaxController.addListener(() {
      _flatListingProfile.budgetMax = _budgetMaxController.text;
    });
    _areaPreferenceController.addListener(() {
      _flatListingProfile.areaPreference = _areaPreferenceController.text;
    });
    _rentPriceController.addListener(() {
      _flatListingProfile.rentPrice = _rentPriceController.text;
    });
    _depositAmountController.addListener(() {
      _flatListingProfile.depositAmount = _depositAmountController.text;
    });
    _addressController.addListener(() {
      _flatListingProfile.address = _addressController.text;
    });
    _landmarkController.addListener(() {
      _flatListingProfile.landmark = _landmarkController.text;
    });
    _flatDescriptionController.addListener(() {
      _flatListingProfile.flatDescription = _flatDescriptionController.text;
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _ownerNameController.dispose();
    _ownerAgeController.dispose();
    _ownerOccupationController.dispose();
    _ownerBioController.dispose();
    _currentCityController.dispose();
    _desiredCityController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _areaPreferenceController.dispose();
    _rentPriceController.dispose();
    _depositAmountController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _flatDescriptionController.dispose();
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
                            : DateFormat('dd/MM/yyyy').format(selectedDate!),
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

  // --- Page Definitions ---

  List<Widget> _buildPages() {
    return [
      // --- Owner Info Subsection ---
      // Page 1: Owner Name
      _buildTextQuestion(
        title: "What's your name?",
        subtitle: "This will be visible to potential flatmates.",
        hintText: "Enter your name",
        controller: _ownerNameController,
      ),

      // Page 2: Owner Age
      _buildTextQuestion(
        title: "How old are you?",
        subtitle: "This helps flatmates understand your age group.",
        hintText: "Enter your age",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _ownerAgeController,
      ),

      // Page 3: Owner Gender
      SingleChoiceQuestionWidget(
        title: "What's your gender?",
        subtitle: "This helps potential flatmates relate to you.",
        options: ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.ownerGender = value;
          });
        },
        initialValue: _flatListingProfile.ownerGender,
      ),

      // Page 4: Owner Occupation
      _buildTextQuestion(
        title: "What do you do for a living?",
        subtitle: "Share your profession or student status.",
        hintText: "e.g., Software Engineer, Student, Freelancer",
        controller: _ownerOccupationController,
      ),

      // Page 5: Owner Bio
      _buildTextQuestion(
        title: "Tell us a bit about yourself as a flat owner/current flatmate.",
        subtitle: "Share something interesting! This helps others get to know you.",
        hintText: "e.g., I'm a quiet person who loves reading...",
        controller: _ownerBioController,
        maxLines: 5,
      ),

      // Page 6: Current City
      // _buildTextQuestion(
      //   title: "In which city is your current flat located?",
      //   subtitle: "This helps us identify the location of your flat.",
      //   hintText: "Enter current city/locality",
      //   controller: _currentCityController,
      // ),

      // Page 7: Desired City (This seems redundant for a flat listing. Assuming it means the city the flat is *in*)
      _buildTextQuestion(
        title: "Which city is the flat available in?",
        subtitle: "Confirm the city where your flat is located.",
        hintText: "e.g., Pune, Mumbai",
        controller: _desiredCityController,
      ),

      // Page 8: Minimum Budget Expected (This is for the flatmate you're looking for, or rent you want)
      // _buildTextQuestion(
      //   title: "What's the minimum budget you expect from a flatmate?",
      //   subtitle: "Enter the lowest rent you are comfortable with (in ₹).",
      //   hintText: "e.g., ₹10000",
      //   keyboardType: TextInputType.number,
      //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      //   controller: _budgetMinController,
      // ),

      // Page 9: Maximum Budget Expected
      // _buildTextQuestion(
      //   title: "What's the maximum budget you expect from a flatmate?",
      //   subtitle: "Enter the highest rent you expect (in ₹).",
      //   hintText: "e.g., ₹15000",
      //   keyboardType: TextInputType.number,
      //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      //   controller: _budgetMaxController,
      // ),

      // Page 10: Area Preference (This is for the flat's area)
      _buildTextQuestion(
        title: "What's the area/locality of your flat?",
        subtitle: "e.g., Koregaon Park, Viman Nagar, Hinjewadi.",
        hintText: "Enter the area/locality",
        controller: _areaPreferenceController,
      ),

      // --- Habits Subsection (Owner's Habits) ---
      // Page 11: Smoking Habits (Owner's)
      SingleChoiceQuestionWidget(
        title: "What are your smoking habits?",
        subtitle: "This helps in matching with compatible flatmates.",
        options: ['Never', 'Occasionally', 'Socially', 'Regularly'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.smokingHabit = value;
          });
        },
        initialValue: _flatListingProfile.smokingHabit,
      ),
      // Page 12: Drinking Habits (Owner's)
      SingleChoiceQuestionWidget(
        title: "What are your drinking habits?",
        subtitle: "Are you a non-drinker, social drinker, or regular drinker?",
        options: ['Never', 'Occasionally', 'Socially', 'Regularly'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.drinkingHabit = value;
          });
        },
        initialValue: _flatListingProfile.drinkingHabit,
      ),
      // Page 13: Food Preference (Owner's)
      SingleChoiceQuestionWidget(
        title: "What is your food preference?",
        subtitle: "Any specific dietary habits or restrictions?",
        options: ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian', 'Jain', 'Other'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.foodPreference = value;
          });
        },
        initialValue: _flatListingProfile.foodPreference,
      ),

      // Page 14: Cleanliness Level (Owner's)
      SingleChoiceQuestionWidget(
        title: "How clean are you?",
        subtitle: "Be honest! This helps manage expectations.",
        options: ['Very Tidy', 'Moderately Tidy', 'Flexible', 'Can be messy at times'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.cleanlinessLevel = value;
          });
        },
        initialValue: _flatListingProfile.cleanlinessLevel,
      ),

      // Page 15: Noise level (Owner's preference)
      SingleChoiceQuestionWidget(
        title: "What's your preferred noise level in a flat?",
        subtitle: "How quiet or lively do you like the home to be?",
        options: ['Very quiet', 'Moderate noise', 'Lively', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.noiseLevel = value;
          });
        },
        initialValue: _flatListingProfile.noiseLevel,
      ),

      // Page 16: Social Habits (Owner's)
      SingleChoiceQuestionWidget(
        title: "What are your social habits?",
        subtitle: "Do you enjoy social gatherings or prefer quiet?",
        options: ['Social & outgoing', 'Occasional gatherings', 'Quiet & private', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.socialPreferences = value;
          });
        },
        initialValue: _flatListingProfile.socialPreferences,
      ),

      // Page 17: Visitors policy (Owner's)
      SingleChoiceQuestionWidget(
        title: "What's your policy on visitors?",
        subtitle: "How often do you plan to have guests over?",
        options: ['Frequent visitors', 'Occasional visitors', 'Rarely have visitors', 'No visitors'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.visitorsPolicy = value;
          });
        },
        initialValue: _flatListingProfile.visitorsPolicy,
      ),

      // Page 18: Pet ownership (Owner's)
      SingleChoiceQuestionWidget(
        title: "Do you currently own pets?",
        subtitle: "Are you bringing any furry friends?",
        options: ['Yes', 'No', 'Planning to get one'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.petOwnership = value;
          });
        },
        initialValue: _flatListingProfile.petOwnership,
      ),
      // Page 19: Pet tolerance (Owner's)
      SingleChoiceQuestionWidget(
        title: "What's your tolerance for flatmates with pets?",
        subtitle: "Are you comfortable living with pets?",
        options: ['Comfortable with pets', 'Tolerant of pets', 'Prefer no pets', 'Allergic to pets'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.petTolerance = value;
          });
        },
        initialValue: _flatListingProfile.petTolerance,
      ),
      // Page 20: Sleeping schedule (Owner's)
      SingleChoiceQuestionWidget(
        title: "What's your typical sleeping schedule?",
        subtitle: "Are you an early bird or a night owl?",
        options: ['Early riser', 'Night Owl', 'Flexible', 'Irregular'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.sleepingSchedule = value;
          });
        },
        initialValue: _flatListingProfile.sleepingSchedule,
      ),
      // Page 21: Work schedule (Owner's)
      SingleChoiceQuestionWidget(
        title: "What's your typical work/study schedule?",
        subtitle: "This helps in understanding common space usage.",
        options: ['9-5 Office hours', 'Freelance/Flexible hours', 'Night shifts', 'Student schedule', 'Mixed'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.workSchedule = value;
          });
        },
        initialValue: _flatListingProfile.workSchedule,
      ),

      // Page 22: Sharing Common Spaces (Owner's)
      SingleChoiceQuestionWidget(
        title: "How do you prefer sharing common spaces?",
        subtitle: "Do you like to share everything or prefer separate items?",
        options: ['Share everything', 'Share some items', 'Prefer separate items', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.sharingCommonSpaces = value;
          });
        },
        initialValue: _flatListingProfile.sharingCommonSpaces,
      ),
      // Page 23: Guests Policy for Overnight Stays (Owner's)
      SingleChoiceQuestionWidget(
        title: "What's your policy on overnight guests?",
        subtitle: "How often do you expect to have guests stay overnight?",
        options: ['Frequently', 'Occasionally', 'Rarely', 'Never'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.guestsOvernightPolicy = value;
          });
        },
        initialValue: _flatListingProfile.guestsOvernightPolicy,
      ),
      // Page 24: Personal Space (Owner's)
      SingleChoiceQuestionWidget(
        title: "How do you balance personal space and socialization?",
        subtitle: "Do you value quiet personal time or enjoy interactive common spaces?",
        options: ['Value personal space highly', 'Enjoy a balance', 'Prefer more socialization', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.personalSpaceVsSocialization = value;
          });
        },
        initialValue: _flatListingProfile.personalSpaceVsSocialization,
      ),

      // --- Flat Details Subsection ---
      // Page 25: Flat Type
      SingleChoiceQuestionWidget(
        title: "What type of flat are you listing?",
        subtitle: "Studio, 1BHK, 2BHK, etc.",
        options: ['Studio Apartment', '1BHK', '2BHK', '3BHK', '4BHK+', 'Other'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.flatType = value;
          });
        },
        initialValue: _flatListingProfile.flatType,
      ),

      // Page 26: Furnished Status
      SingleChoiceQuestionWidget(
        title: "Is the flat furnished, semi-furnished, or unfurnished?",
        subtitle: "Specify what's included in the flat.",
        options: ['Furnished', 'Semi-furnished', 'Unfurnished'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.furnishedStatus = value;
          });
        },
        initialValue: _flatListingProfile.furnishedStatus,
      ),

      // Page 27: Available For
      SingleChoiceQuestionWidget(
        title: "Who is the flat available for?",
        subtitle: "Select the preferred gender/group.",
        options: ['Boys', 'Girls', 'Couples', 'Anyone'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.availableFor = value;
          });
        },
        initialValue: _flatListingProfile.availableFor,
      ),

      // Page 28: Availability Date
      _buildDateQuestion(
        title: "When is the flat available from?",
        subtitle: "Approximate date works best.",
        onDateSelected: (date) {
          setState(() {
            _flatListingProfile.availabilityDate = date;
          });
        },
        initialDate: _flatListingProfile.availabilityDate,
      ),

      // Page 29: Rent Price
      _buildTextQuestion(
        title: "What is the monthly rent for the flat/room?",
        subtitle: "Enter the rent amount in ₹.",
        hintText: "e.g., ₹12000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _rentPriceController,
      ),

      // Page 30: Deposit Amount
      _buildTextQuestion(
        title: "What is the security deposit amount?",
        subtitle: "Enter the deposit amount in ₹.",
        hintText: "e.g., ₹24000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _depositAmountController,
      ),

      // Page 31: Bathroom Type
      SingleChoiceQuestionWidget(
        title: "What kind of bathroom is available?",
        subtitle: "Attached to the room or shared?",
        options: ['Attached Bathroom', 'Shared Bathroom'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.bathroomType = value;
          });
        },
        initialValue: _flatListingProfile.bathroomType,
      ),

      // Page 32: Balcony Availability
      SingleChoiceQuestionWidget(
        title: "Does the flat have a balcony?",
        subtitle: "Yes, No, or Specific Room.",
        options: ['Yes', 'No', 'Only in living room', 'Only in bedroom'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.balconyAvailability = value;
          });
        },
        initialValue: _flatListingProfile.balconyAvailability,
      ),

      // Page 33: Parking Availability
      SingleChoiceQuestionWidget(
        title: "Is parking available?",
        subtitle: "For car, two-wheeler, or both.",
        options: ['Yes, for Car', 'Yes, for Two-wheeler', 'Both', 'No'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.parkingAvailability = value;
          });
        },
        initialValue: _flatListingProfile.parkingAvailability,
      ),

      // Page 34: Amenities (Multi-choice)
      MultiChoiceQuestionWidget(
        title: "What amenities are available in the flat?",
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
            _flatListingProfile.amenities = selected;
          });
        },
        initialValues: _flatListingProfile.amenities,
      ),

      // Page 35: Address
      _buildTextQuestion(
        title: "What is the full address of the flat?",
        subtitle: "Include Building/Society Name, Street, Locality.",
        hintText: "Enter full address",
        controller: _addressController,
        maxLines: 3,
      ),

      // Page 36: Landmark
      _buildTextQuestion(
        title: "Add a nearby landmark (optional).",
        subtitle: "Helps in easy navigation.",
        hintText: "e.g., Near D-Mart, Beside XYZ Cafe",
        controller: _landmarkController,
      ),

      // Page 37: Flat Description
      _buildTextQuestion(
        title: "Describe your flat.",
        subtitle: "Highlight key features, vibe, and what makes it a great place.",
        hintText: "e.g., Spacious 2BHK with great sunlight, friendly neighborhood...",
        controller: _flatDescriptionController,
        maxLines: 5,
      ),

      // --- Flatmate Preferences Subsection ---
      // Page 38: Preferred Flatmate Gender
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate gender?",
        subtitle: "This helps in finding a compatible match.",
        options: ['Male', 'Female', 'No preference', 'Other'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.preferredGender = value;
          });
        },
        initialValue: _flatListingProfile.preferredGender,
      ),

      // Page 39: Preferred Flatmate Age Group
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate age group?",
        subtitle: "This helps in finding a compatible match.",
        options: ['18-24', '25-30', '30-40', '40+', 'No preference'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.preferredAgeGroup = value;
          });
        },
        initialValue: _flatListingProfile.preferredAgeGroup,
      ),

      // Page 40: Preferred Flatmate Occupation
      SingleChoiceQuestionWidget(
        title: "What's your preferred flatmate occupation type?",
        subtitle: "Student, working professional, or no preference?",
        options: ['Student', 'Working Professional', 'Both', 'No preference'],
        onSelected: (value) {
          setState(() {
            _flatListingProfile.preferredOccupation = value;
          });
        },
        initialValue: _flatListingProfile.preferredOccupation,
      ),

      // Page 41: Preferred Flatmate Habits (Multi-choice)
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
            _flatListingProfile.preferredHabits = selected;
          });
        },
        initialValues: _flatListingProfile.preferredHabits,
      ),

      // Page 42: Ideal Qualities in a Flatmate (Multi-choice)
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
            _flatListingProfile.flatmateIdealQualities = selected;
          });
        },
        initialValues: _flatListingProfile.flatmateIdealQualities,
      ),

      // Page 43: Deal Breakers (Multi-choice)
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
            _flatListingProfile.flatmateDealBreakers = selected;
          });
        },
        initialValues: _flatListingProfile.flatmateDealBreakers,
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

  // --- Firebase Integration Method ---
  Future<void> _submitProfileToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit your profile.')),
      );
      return;
    }

    // Prepare data for Firestore
    final profileData = {
      "uid": user.uid,
      "email": user.email,
      "displayName": _flatListingProfile.ownerName,
      "age": int.tryParse(_flatListingProfile.ownerAge) ?? 0,
      "gender": _flatListingProfile.ownerGender,
      "occupation": _flatListingProfile.ownerOccupation,
      "bio": _flatListingProfile.ownerBio,
      "currentCity": _flatListingProfile.currentCity,
      "desiredCity": _flatListingProfile.desiredCity,
      "budgetMinExpected": int.tryParse(_flatListingProfile.budgetMin) ?? 0,
      "budgetMaxExpected": int.tryParse(_flatListingProfile.budgetMax) ?? 0,
      "areaPreference": _flatListingProfile.areaPreference,
      "userType": "flat_listing",
      "ownerHabits": {
        "smoking": _flatListingProfile.smokingHabit,
        "drinking": _flatListingProfile.drinkingHabit,
        "food": _flatListingProfile.foodPreference,
        "cleanliness": _flatListingProfile.cleanlinessLevel,
        "noiseTolerance": _flatListingProfile.noiseLevel,
        "socialPreferences": _flatListingProfile.socialPreferences,
        "visitorsPolicy": _flatListingProfile.visitorsPolicy,
        "petOwnership": _flatListingProfile.petOwnership,
        "petTolerance": _flatListingProfile.petTolerance,
        "sleepingSchedule": _flatListingProfile.sleepingSchedule,
        "workSchedule": _flatListingProfile.workSchedule,
        "sharingCommonSpaces": _flatListingProfile.sharingCommonSpaces,
        "guestOvernightStays": _flatListingProfile.guestsOvernightPolicy,
        "personalSpaceVsSocializing": _flatListingProfile.personalSpaceVsSocialization,
      },
      "flatDetails": {
        "flatType": _flatListingProfile.flatType,
        "furnishedStatus": _flatListingProfile.furnishedStatus,
        "availableFor": _flatListingProfile.availableFor,
        "availabilityDate": _flatListingProfile.availabilityDate != null
            ? Timestamp.fromDate(_flatListingProfile.availabilityDate!)
            : null,
        "rentPrice": int.tryParse(_flatListingProfile.rentPrice) ?? 0,
        "depositAmount": int.tryParse(_flatListingProfile.depositAmount) ?? 0,
        "bathroomType": _flatListingProfile.bathroomType,
        "balconyAvailability": _flatListingProfile.balconyAvailability,
        "parkingAvailability": _flatListingProfile.parkingAvailability,
        "amenities": _flatListingProfile.amenities,
        "address": _flatListingProfile.address,
        "landmark": _flatListingProfile.landmark,
        "description": _flatListingProfile.flatDescription,
      },
      "flatmatePreferences": {
        "preferredGender": _flatListingProfile.preferredGender,
        "preferredAgeGroup": _flatListingProfile.preferredAgeGroup,
        "preferredOccupation": _flatListingProfile.preferredOccupation,
        "preferredHabits": _flatListingProfile.preferredHabits,
        "idealQualities": _flatListingProfile.flatmateIdealQualities,
        "dealBreakers": _flatListingProfile.flatmateDealBreakers,
      },
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
        const SnackBar(content: Text('Flat Listing Profile Submitted Successfully!')),
      );
      // Navigate to HomePage after successful submission
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      print('Error submitting flat listing profile to Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit profile: $e')),
      );
    }
  }

  void _submitProfile() {
    print('Submitting Flat Listing Profile:');
    print(_flatListingProfile.toString());

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
          // The "Skip" button is now removed. "Finish" button is handled by the main button.
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