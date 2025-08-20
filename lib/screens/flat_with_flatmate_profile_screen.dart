// lib/screens/flat_with_flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mytennat/screens/home_page.dart';
import 'package:intl/intl.dart';
import 'package:mytennat/data/location_data.dart';
import 'package:mytennat/data/user_profile.dart';

// Data model to hold all the answers for the user seeking a flat
class SeekingFlatmateProfile {
  // Basic Info
  String documentId;
  String? uid;
  UserProfile userProfile;

  // Fields that are specific to the flatmate search
  DateTime? moveInDate;
  int? budgetMin;
  int? budgetMax;

  // Flat Requirements
  String preferredFlatType;
  String preferredRoomType;
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
    this.documentId = '',
    this.uid,
    required this.userProfile,
    this.moveInDate,
    this.budgetMin,
    this.budgetMax,
    this.preferredFlatType = '',
    this.preferredRoomType = '',
    this.preferredFurnishedStatus = '',
    List<String>? amenitiesDesired,
    this.preferredFlatmateGender = '',
    this.preferredFlatmateAge = '',
    this.preferredOccupation = '',
    List<String>? preferredHabits,
    List<String>? idealQualities,
    List<String>? dealBreakers,
    List<String>? imageUrls,
  })  : amenitiesDesired = amenitiesDesired ?? const [],
        preferredHabits = preferredHabits ?? const [],
        idealQualities = idealQualities ?? const [],
        dealBreakers = dealBreakers ?? const [],
        imageUrls = imageUrls;

  // Factory constructor to create a SeekingFlatmateProfile from a map (Firestore data)
  factory SeekingFlatmateProfile.fromMap(Map<String, dynamic> data, String documentId) {
    // Add this print statement to see the raw data being processed
    print('Document ID: $documentId, Raw Data: $data');

    Map<String, dynamic> flatRequirementsData = data['flatRequirements'] ?? {};
    Map<String, dynamic> flatmatePreferencesData = data['flatmatePreferences'] ?? {};
    final Map<String, dynamic>? userProfileData = data['userProfile'] as Map<String, dynamic>?;

    // Add this print statement to see the userProfileData specifically
    print('UserProfile Data: $userProfileData');

    final UserProfile profile = userProfileData != null
        ? UserProfile.fromMap(userProfileData, data['uid'] as String? ?? '')
        : UserProfile(uid: data['uid'] as String? ?? '');

    return SeekingFlatmateProfile(
      documentId: documentId,
      uid: data['uid'] as String?,
      userProfile: profile,
      moveInDate: (data['moveInDate'] as Timestamp?)?.toDate(),
      budgetMin: data['budgetMin'] is int
          ? data['budgetMin']
          : (data['budgetMin'] is String ? int.tryParse(data['budgetMin']) : null),
      budgetMax: data['budgetMax'] is int
          ? data['budgetMax']
          : (data['budgetMax'] is String ? int.tryParse(data['budgetMax']) : null),
      preferredFlatType: flatRequirementsData['preferredFlatType'] as String? ?? '',
      preferredRoomType: flatRequirementsData['preferredRoomType'] as String? ?? '',
      preferredFurnishedStatus: flatRequirementsData['preferredFurnishedStatus'] as String? ?? '',
      amenitiesDesired: List<String>.from(flatRequirementsData['amenitiesDesired'] as List? ?? []),
      preferredFlatmateGender: flatmatePreferencesData['preferredFlatmateGender'] as String? ?? '',
      preferredFlatmateAge: flatmatePreferencesData['preferredFlatmateAge'] as String? ?? '',
      preferredOccupation: flatmatePreferencesData['preferredOccupation'] as String? ?? '',
      preferredHabits: List<String>.from(flatmatePreferencesData['preferredHabits'] as List? ?? []),
      idealQualities: List<String>.from(flatmatePreferencesData['idealQualities'] as List? ?? []),
      dealBreakers: List<String>.from(flatmatePreferencesData['dealBreakers'] as List? ?? []),
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  // Method to convert the object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userType': 'seeking_flatmate',
      'userProfile': userProfile.toMap(),
      'moveInDate': moveInDate != null ? Timestamp.fromDate(moveInDate!) : null,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'flatRequirements': {
        'preferredFlatType': preferredFlatType,
        'preferredRoomType': preferredRoomType,
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
      'imageUrls': imageUrls,
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
  final accentColor = const Color(0xFFAD1457);

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
            selectedColor: accentColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: isSelected ? accentColor : Colors.grey.shade300,
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
              color: isSelected ? accentColor.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? accentColor : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
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
                    color: isSelected ? accentColor : Colors.black,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle,
                      color: accentColor, size: 20),
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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
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
  final accentColor = const Color(0xFFAD1457);


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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
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
                          Icon(Icons.check,
                              size: 18, color: accentColor),
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
                        color: isSelected ? accentColor : Colors.grey.shade300,
                        width: 1.5),
                    backgroundColor: Colors.grey.shade50,
                    selectedColor: accentColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? accentColor : Colors.black,
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
  final String? initialPhoneNumber;
  const FlatWithFlatmateProfileScreen({super.key, this.initialPhoneNumber});

  @override
  State<FlatWithFlatmateProfileScreen> createState() => _FlatWithFlatmateProfileScreenState();
}

class _FlatWithFlatmateProfileScreenState extends State<FlatWithFlatmateProfileScreen> {
  final PageController _pageController = PageController();
  late final SeekingFlatmateProfile _seekingFlatmateProfile;
  int _currentPage = 0;
  bool _isSubmitting = false; // Added for loading indicator
  final accentColor = const Color(0xFFAD1457);
  final accentColor1 = const Color(0xFF6A1B9A);

  // Change _pages from late final to a getter
  List<Widget> get _pages => _buildPages();

  // Declare TextEditingControllers for all text input fields
  late TextEditingController _budgetMinController;
  late TextEditingController _budgetMaxController;

  // Define sections for progress tracking and navigation
  final List<Map<String, dynamic>> _sections = [
    {'title': 'Your Basic Info', 'startPage': 0, 'endPage': 2},
    {'title': 'Flat Requirements', 'startPage': 3, 'endPage': 5},
    {'title': 'Flatmate Preferences', 'startPage': 6, 'endPage': 10},
  ];

  String _getCurrentSectionTitle() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] && _currentPage <= section['endPage']) {
        return section['title'];
      }
    }
    return 'Unknown Section'; // Default title if no section matches
  }

  double _getCurrentSectionProgress() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] && _currentPage <= section['endPage']) {
        final int pagesInSection = (section['endPage'] as int) - (section['startPage'] as int) + 1;
        final int currentPageInSection = _currentPage - (section['startPage'] as int);
        return (currentPageInSection + 1) / pagesInSection;
      }
    }
    // Return 0.0 or a sensible default if the current page is not in any defined section
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    _seekingFlatmateProfile = SeekingFlatmateProfile(
      userProfile: UserProfile(uid: currentUserUid!),
    );
    _budgetMinController = TextEditingController(
        text: _seekingFlatmateProfile.budgetMin?.toString() ?? '');
    _budgetMaxController = TextEditingController(
        text: _seekingFlatmateProfile.budgetMax?.toString() ?? '');

    _budgetMinController.addListener(() {
      _seekingFlatmateProfile.budgetMin = int.tryParse(_budgetMinController.text);
    });
    _budgetMaxController.addListener(() {
      _seekingFlatmateProfile.budgetMax = int.tryParse(_budgetMaxController.text);
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
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
                borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: accentColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
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
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 15, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: accentColor, // header background color
                            onPrimary: Colors.white, // header text color
                            onSurface: Colors.black, // body text color
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: accentColor, // button text color
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                    onDateSelected(pickedDate);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: accentColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: accentColor.withOpacity(0.8)),
                      const SizedBox(width: 15),
                      Text(
                        selectedDate == null
                            ? 'Select Move-in Date'
                            : DateFormat('d MMMM y').format(selectedDate),
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedDate == null ? Colors.grey[700] : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_drop_down, color: accentColor),
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

  Widget _buildRangeQuestion({
    required String title,
    required String subtitle,
    required TextEditingController minController,
    required TextEditingController maxController,
    required String minHint,
    required String maxHint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: minHint,
                    prefixIcon: Icon(Icons.currency_rupee, color: accentColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text('to', style: TextStyle(fontSize: 16, color: Colors.white)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: maxController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: maxHint,
                    prefixIcon: Icon(Icons.currency_rupee, color: accentColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: accentColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // --- Page Content ---
  List<Widget> _buildPages() {
    return [
      _buildDateQuestion(
        title: 'Move-in Date',
        subtitle: 'When would you like to move into your new flat?',
        onDateSelected: (date) => _seekingFlatmateProfile.moveInDate = date,
        initialDate: _seekingFlatmateProfile.moveInDate,
      ),
      _buildRangeQuestion(
        title: 'Monthly Budget',
        subtitle: 'What is your comfortable monthly budget for rent?',
        minController: _budgetMinController,
        maxController: _budgetMaxController,
        minHint: 'Min Budget',
        maxHint: 'Max Budget',
      ),
      SingleChoiceQuestionWidget(
        title: 'Flat Type',
        subtitle: 'What kind of flat are you looking for?',
        options: const ['1BHK', '2BHK', '3BHK', '4BHK+'],
        onSelected: (option) => _seekingFlatmateProfile.preferredFlatType = option,
        isCard: true,
        initialValue: _seekingFlatmateProfile.preferredFlatType,
      ),
      SingleChoiceQuestionWidget(
        title: 'Room Type',
        subtitle: 'What kind of room do you prefer?',
        options: const ['Shared Room', 'Private Room'],
        onSelected: (option) => _seekingFlatmateProfile.preferredRoomType = option,
        initialValue: _seekingFlatmateProfile.preferredRoomType,
      ),
      SingleChoiceQuestionWidget(
        title: 'Furnished Status',
        subtitle: 'Are you looking for a furnished or unfurnished flat?',
        options: const ['Furnished', 'Semi-Furnished', 'Unfurnished'],
        onSelected: (option) => _seekingFlatmateProfile.preferredFurnishedStatus = option,
        initialValue: _seekingFlatmateProfile.preferredFurnishedStatus,
      ),
      MultiChoiceQuestionWidget(
        title: 'Desired Amenities',
        subtitle: 'What amenities are essential for your new flat?',
        options: const [
          'AC',
          'Washing Machine',
          'Refrigerator',
          'Geyser',
          'Microwave',
          'Parking',
          'Wi-Fi',
          'Gym',
          'Swimming Pool',
          'Security'
        ],
        onSelected: (options) => _seekingFlatmateProfile.amenitiesDesired = options,
        initialValues: _seekingFlatmateProfile.amenitiesDesired,
      ),
      SingleChoiceQuestionWidget(
        title: 'Flatmate Gender',
        subtitle: 'Who would you prefer to live with?',
        options: const ['Male', 'Female', 'No preference'],
        onSelected: (option) => _seekingFlatmateProfile.preferredFlatmateGender = option,
        initialValue: _seekingFlatmateProfile.preferredFlatmateGender,
      ),
      SingleChoiceQuestionWidget(
        title: 'Flatmate Age',
        subtitle: 'What is the age range of your ideal flatmate?',
        options: const [
          '18-24',
          '25-30',
          '31-40',
          '41+',
          'No preference'
        ],
        onSelected: (option) => _seekingFlatmateProfile.preferredFlatmateAge = option,
        initialValue: _seekingFlatmateProfile.preferredFlatmateAge,
      ),
      SingleChoiceQuestionWidget(
        title: 'Occupation',
        subtitle: 'Do you have a preference for your flatmate\'s occupation?',
        options: const ['Student', 'Working Professional', 'No preference'],
        onSelected: (option) => _seekingFlatmateProfile.preferredOccupation = option,
        initialValue: _seekingFlatmateProfile.preferredOccupation,
      ),
      MultiChoiceQuestionWidget(
        title: 'Lifestyle & Habits',
        subtitle: 'What habits are important to you?',
        options: const [
          'Smoking friendly',
          'Drinking friendly',
          'Night owl',
          'Morning person',
          'Introvert',
          'Extrovert'
        ],
        onSelected: (options) => _seekingFlatmateProfile.preferredHabits = options,
        initialValues: _seekingFlatmateProfile.preferredHabits,
      ),
      MultiChoiceQuestionWidget(
        title: 'Ideal Qualities',
        subtitle: 'What qualities do you look for in a flatmate?',
        options: const [
          'Clean & Tidy',
          'Responsible',
          'Respectful',
          'Sociable',
          'Quiet',
          'Good cook',
        ],
        onSelected: (options) => _seekingFlatmateProfile.idealQualities = options,
        initialValues: _seekingFlatmateProfile.idealQualities,
      ),
      MultiChoiceQuestionWidget(
        title: 'Deal Breakers',
        subtitle: 'What would you not be able to tolerate?',
        options: const [
          'Loud music',
          'Dirty dishes',
          'Overnight guests',
          'Smoking indoors',
          'Untidy flatmate',
          'Party person',
        ],
        onSelected: (options) => _seekingFlatmateProfile.dealBreakers = options,
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
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitProfile() async {
    setState(() {
      _isSubmitting = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in.')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final profileCollectionRef = userDocRef.collection('seekingFlatmateProfiles');

      // Check for an existing profile
      final existingProfiles = await profileCollectionRef.where('uid', isEqualTo: user.uid).get();

      if (existingProfiles.docs.isNotEmpty) {
        // Update the existing profile
        final docId = existingProfiles.docs.first.id;
        await profileCollectionRef.doc(docId).update(_seekingFlatmateProfile.toMap());
        print('Profile updated successfully!');
      } else {
        // Create a new profile
        final newDoc = await profileCollectionRef.add(_seekingFlatmateProfile.toMap());
        _seekingFlatmateProfile.documentId = newDoc.id;
        print('New profile created with ID: ${newDoc.id}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );

      // Navigate back to the home page after submission
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      print('Error submitting profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _previousPage,
        ),
        title: const Text(
          'My Flatmate Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCurrentSectionTitle(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: _getCurrentSectionProgress(),
                          backgroundColor: Colors.white38,
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: _pages,
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
                              backgroundColor: Colors.white,
                              foregroundColor: accentColor,

                              side: BorderSide(color: accentColor),
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
                                backgroundColor: accentColor,
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
            ),
          ),
          if (_isSubmitting) // Loading overlay
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(color: accentColor),
              ),
            ),
        ],
      ),
    );
  }
}