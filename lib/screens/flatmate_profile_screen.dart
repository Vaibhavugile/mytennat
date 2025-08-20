// lib/screens/flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mytennat/screens/home_page.dart';
import 'package:mytennat/data/location_data.dart';
import 'package:mytennat/data/user_profile.dart';

// Data model to hold all the answers for the user listing a flat
class FlatListingProfile {
  String documentId;
  String? uid;
  UserProfile userProfile;

  String flatType;
  String roomType;
  String furnishedStatus;
  String availableFor;
  DateTime? availabilityDate;
  int? rentPrice;
  int? depositAmount;
  String bathroomType;
  List<String> amenities;
  String address;
  String landmark;
  String flatDescription;

  String preferredGender;
  String preferredAgeGroup;
  String preferredOccupation;
  List<String> preferredHabits;
  List<String> flatmateIdealQualities;
  List<String> flatmateDealBreakers;

  List<String>? imageUrls;

  FlatListingProfile({
    this.documentId = '',
    this.uid,
    required this.userProfile,
    this.flatType = '',
    this.roomType = '',
    this.furnishedStatus = '',
    this.availableFor = '',
    this.availabilityDate,
    this.rentPrice,
    this.depositAmount,
    this.bathroomType = '',
    List<String>? amenities,
    this.address = '',
    this.landmark = '',
    this.flatDescription = '',
    this.preferredGender = '',
    this.preferredAgeGroup = '',
    this.preferredOccupation = '',
    List<String>? preferredHabits,
    List<String>? flatmateIdealQualities,
    List<String>? flatmateDealBreakers,
    List<String>? imageUrls,
  })  : amenities = amenities ?? const [],
        preferredHabits = preferredHabits ?? const [],
        flatmateIdealQualities = flatmateIdealQualities ?? const [],
        flatmateDealBreakers = flatmateDealBreakers ?? const [],
        imageUrls = imageUrls;

  factory FlatListingProfile.fromMap(Map<String, dynamic> data, String documentId) {
    print('Document ID: $documentId, Raw Data: $data');

    Map<String, dynamic> flatDetails = data['flatDetails'] ?? {};
    Map<String, dynamic> flatmatePreferences = data['flatmatePreferences'] ?? {};
    final Map<String, dynamic>? userProfileData = data['userProfile'] as Map<String, dynamic>?;

    print('UserProfile Data: $userProfileData');

    final UserProfile profile = userProfileData != null
        ? UserProfile.fromMap(userProfileData, data['uid'] as String? ?? '')
        : UserProfile(uid: data['uid'] as String? ?? '');

    return FlatListingProfile(
      documentId: documentId,
      uid: data['uid'] as String? ?? '',
      userProfile: profile,
      flatType: flatDetails['flatType'] ?? '',
      roomType: flatDetails['roomType'] ?? '',
      furnishedStatus: flatDetails['furnishedStatus'] ?? '',
      availableFor: flatDetails['availableFor'] ?? '',
      availabilityDate: (flatDetails['availabilityDate'] is Timestamp)
          ? (flatDetails['availabilityDate'] as Timestamp).toDate()
          : null,
      rentPrice: flatDetails['rentPrice'] is int
          ? flatDetails['rentPrice']
          : (flatDetails['rentPrice'] is String
          ? int.tryParse(flatDetails['rentPrice'])
          : null),
      depositAmount: flatDetails['depositAmount'] is int
          ? flatDetails['depositAmount']
          : (flatDetails['depositAmount'] is String
          ? int.tryParse(flatDetails['depositAmount'])
          : null),
      bathroomType: flatDetails['bathroomType'] ?? '',
      amenities: List<String>.from(flatDetails['amenities'] ?? []),
      address: flatDetails['address'] ?? '',
      landmark: flatDetails['landmark'] ?? '',
      flatDescription: flatDetails['description'] ?? '',
      preferredGender: flatmatePreferences['preferredFlatmateGender'] ?? '',
      preferredAgeGroup: flatmatePreferences['preferredFlatmateAge'] ?? '',
      preferredOccupation: flatmatePreferences['preferredOccupation'] ?? '',
      preferredHabits: List<String>.from(flatmatePreferences['preferredHabits'] ?? []),
      flatmateIdealQualities: List<String>.from(flatmatePreferences['idealQualities'] ?? []),
      flatmateDealBreakers: List<String>.from(flatmatePreferences['dealBreakers'] ?? []),
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userProfile': userProfile.toMap(),
      'userType': 'flat_listing',
      'documentId': documentId,
      'rentPrice': rentPrice,
      'depositAmount': depositAmount,
      'flatType': flatType,
      'roomType': roomType,
      'furnishedStatus': furnishedStatus,
      'availableFor': availableFor,
      'availabilityDate': availabilityDate != null ? Timestamp.fromDate(availabilityDate!) : null,
      'amenities': amenities,
      'address': address,
      'landmark': landmark,
      'flatDescription': flatDescription,
      'preferredFlatmateGender': preferredGender,
      'preferredFlatmateAge': preferredAgeGroup,
      'preferredOccupation': preferredOccupation,
      'idealQualities': flatmateIdealQualities,
      'dealBreakers': flatmateDealBreakers,
      'isProfileComplete': true,
    };
  }

  @override
  String toString() {
    return 'FlatListingProfile(\n'
        '  documentId: $documentId,\n'
        '  uid: $uid,\n'
        '  userProfile: ${userProfile.toString()},\n'
        '  flatType: $flatType,\n'
        '  roomType: $roomType,\n'
        '  furnishedStatus: $furnishedStatus,\n'
        '  availableFor: $availableFor,\n'
        '  availabilityDate: $availabilityDate,\n'
        '  rentPrice: $rentPrice,\n'
        '  depositAmount: $depositAmount,\n'
        '  bathroomType: $bathroomType,\n'
        '  amenities: $amenities,\n'
        '  address: $address,\n'
        '  landmark: $landmark,\n'
        '  flatDescription: $flatDescription,\n'
        '  preferredGender: $preferredGender,\n'
        '  preferredAgeGroup: $preferredAgeGroup,\n'
        '  preferredOccupation: $preferredOccupation,\n'
        '  preferredHabits: $preferredHabits,\n'
        '  flatmateIdealQualities: $flatmateIdealQualities,\n'
        '  dealBreakers: $flatmateDealBreakers,\n'
        '  imageUrls: $imageUrls,\n'
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
  State<MultiChoiceQuestionWidget> createState() => _MultiChoiceQuestionWidgetState();
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
                          Icon(Icons.check, size: 18, color: accentColor),
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

class FlatmateProfileScreen extends StatefulWidget {
  final String? initialPhoneNumber;
  const FlatmateProfileScreen({super.key,this.initialPhoneNumber});
  @override
  State<FlatmateProfileScreen> createState() => _FlatmateProfileScreenState();
}

class _FlatmateProfileScreenState extends State<FlatmateProfileScreen> {
  final PageController _pageController = PageController();
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  late final FlatListingProfile _flatListingProfile;
  int _currentPage = 0;
  bool _isSubmitting = false;
  final accentColor = const Color(0xFFAD1457);

  List<Widget> get _pages => _buildPages();

  late TextEditingController _rentPriceController;
  late TextEditingController _depositAmountController;
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _flatDescriptionController;

  final List<Map<String, dynamic>> _sections = [
    {'title': 'About You', 'startPage': 0, 'endPage': 2},
    {'title': 'Flat Details', 'startPage': 3, 'endPage': 8},
    {'title': 'Flatmate Preferences', 'startPage': 9, 'endPage': 13},
  ];

  String _getCurrentSectionTitle() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] && _currentPage <= section['endPage']) {
        return section['title'];
      }
    }
    return '';
  }

  double _getCurrentSectionProgress() {
    for (var section in _sections) {
      if (_currentPage >= section['startPage'] && _currentPage <= section['endPage']) {
        final int pagesInSection = (section['endPage'] as int) - (section['startPage'] as int) + 1;
        final int currentPageInSection = _currentPage - (section['startPage'] as int);
        return (currentPageInSection + 1) / pagesInSection;
      }
    }
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    _flatListingProfile = FlatListingProfile(
      userProfile: UserProfile(uid: currentUserUid!),
    );
    _rentPriceController = TextEditingController(
        text: _flatListingProfile.rentPrice?.toString() ?? '');
    _depositAmountController = TextEditingController(
        text: _flatListingProfile.depositAmount?.toString() ?? '');
    _addressController = TextEditingController(text: _flatListingProfile.address);
    _landmarkController = TextEditingController(text: _flatListingProfile.landmark);
    _flatDescriptionController = TextEditingController(text: _flatListingProfile.flatDescription);
  }

  @override
  void dispose() {
    _rentPriceController.dispose();
    _depositAmountController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _flatDescriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildTextQuestion({
    required String title,
    required String subtitle,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
    Widget? prefixIcon,
    Widget? suffixIcon,
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
                            primary: accentColor,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: accentColor,
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
                            ? 'Select Availability Date'
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
    required String minHint,
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
        ],
      ),
    );
  }


  List<Widget> _buildPages() {
    return [
      SingleChoiceQuestionWidget(
        title: 'Flat Type',
        subtitle: 'What kind of flat are you listing?',
        options: const ['1BHK', '2BHK', '3BHK', '4BHK+'],
        onSelected: (option) => _flatListingProfile.flatType = option,
        isCard: true,
        initialValue: _flatListingProfile.flatType,
      ),
      SingleChoiceQuestionWidget(
        title: 'Room Type',
        subtitle: 'What kind of room are you listing?',
        options: const ['Shared Room', 'Private Room'],
        onSelected: (option) => _flatListingProfile.roomType = option,
        initialValue: _flatListingProfile.roomType,
      ),
      SingleChoiceQuestionWidget(
        title: 'Furnished Status',
        subtitle: 'Is the flat furnished or unfurnished?',
        options: const ['Furnished', 'Semi-Furnished', 'Unfurnished'],
        onSelected: (option) => _flatListingProfile.furnishedStatus = option,
        initialValue: _flatListingProfile.furnishedStatus,
      ),
      SingleChoiceQuestionWidget(
        title: 'Available For',
        subtitle: 'Who can rent the flat?',
        options: const ['Male', 'Female', 'Family', 'All'],
        onSelected: (option) => _flatListingProfile.availableFor = option,
        initialValue: _flatListingProfile.availableFor,
      ),
      _buildDateQuestion(
        title: 'Availability Date',
        subtitle: 'When is the flat available?',
        onDateSelected: (date) => _flatListingProfile.availabilityDate = date,
        initialDate: _flatListingProfile.availabilityDate,
      ),
      _buildRangeQuestion(
        title: 'Monthly Rent',
        subtitle: 'What is the monthly rent for the flat?',
        minController: _rentPriceController,
        minHint: 'Monthly Rent',
      ),
      _buildRangeQuestion(
        title: 'Deposit Amount',
        subtitle: 'What is the deposit amount?',
        minController: _depositAmountController,
        minHint: 'Deposit Amount',
      ),
      SingleChoiceQuestionWidget(
        title: 'Bathroom Type',
        subtitle: 'Is the bathroom attached or shared?',
        options: const ['Attached', 'Shared'],
        onSelected: (option) => _flatListingProfile.bathroomType = option,
        initialValue: _flatListingProfile.bathroomType,
      ),
      MultiChoiceQuestionWidget(
        title: 'Amenities',
        subtitle: 'What amenities are available in the flat?',
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
        onSelected: (options) => _flatListingProfile.amenities = options,
        initialValues: _flatListingProfile.amenities,
      ),
      _buildTextQuestion(
        title: 'Address',
        subtitle: 'What is the full address of the flat?',
        hintText: 'Enter full address...',
        controller: _addressController,
        maxLines: 3,
      ),
      _buildTextQuestion(
        title: 'Landmark',
        subtitle: 'Please provide a nearby landmark for the flat.',
        hintText: 'e.g., Near City Mall',
        controller: _landmarkController,
      ),
      _buildTextQuestion(
        title: 'Flat Description',
        subtitle: 'Please provide a detailed description of the flat.',
        hintText: 'e.g., A spacious 2BHK with a balcony facing the park...',
        controller: _flatDescriptionController,
        maxLines: 5,
      ),
      SingleChoiceQuestionWidget(
        title: 'Preferred Flatmate Gender',
        subtitle: 'Who would you prefer to live with?',
        options: const ['Male', 'Female', 'No preference'],
        onSelected: (option) => _flatListingProfile.preferredGender = option,
        initialValue: _flatListingProfile.preferredGender,
      ),
      SingleChoiceQuestionWidget(
        title: 'Preferred Flatmate Age',
        subtitle: 'What is the age range of your ideal flatmate?',
        options: const [
          '18-24',
          '25-30',
          '31-40',
          '41+',
          'No preference'
        ],
        onSelected: (option) => _flatListingProfile.preferredAgeGroup = option,
        initialValue: _flatListingProfile.preferredAgeGroup,
      ),
      SingleChoiceQuestionWidget(
        title: 'Preferred Occupation',
        subtitle: 'Do you have a preference for your flatmate\'s occupation?',
        options: const ['Student', 'Working Professional', 'No preference'],
        onSelected: (option) => _flatListingProfile.preferredOccupation = option,
        initialValue: _flatListingProfile.preferredOccupation,
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
        onSelected: (options) => _flatListingProfile.preferredHabits = options,
        initialValues: _flatListingProfile.preferredHabits,
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
        onSelected: (options) => _flatListingProfile.flatmateIdealQualities = options,
        initialValues: _flatListingProfile.flatmateIdealQualities,
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
        onSelected: (options) => _flatListingProfile.flatmateDealBreakers = options,
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
      final profileCollectionRef = userDocRef.collection('flatListingProfiles');

      final existingProfiles = await profileCollectionRef.where('uid', isEqualTo: user.uid).get();

      if (existingProfiles.docs.isNotEmpty) {
        final docId = existingProfiles.docs.first.id;
        await profileCollectionRef.doc(docId).update(_flatListingProfile.toMap());
        print('Flat Listing Profile updated successfully!');
      } else {
        final newDoc = await profileCollectionRef.add(_flatListingProfile.toMap());
        _flatListingProfile.documentId = newDoc.id;
        print('New Flat Listing Profile created with ID: ${newDoc.id}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flat Listing Profile saved successfully!')),
      );

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
          if (_isSubmitting)
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