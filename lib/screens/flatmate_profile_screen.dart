// lib/screens/flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mytennat/screens/home_page.dart';
import 'package:mytennat/data/location_data.dart'; // Adjust path as needed

// Data model to hold all the answers for the user listing a flat
class FlatListingProfile {
  String documentId; // Added: To store the Firestore document ID
  String? uid; // Added: To store the user ID (UID)

  // Basic Info
  String ownerName;
  int? ownerAge; // Changed to nullable int
  String ownerGender;
  String ownerOccupation;
  String ownerBio;
  String desiredCity;
  String areaPreference;

  // Habits
  String smokingHabit;
  String drinkingHabit;
  String foodPreference;
  String cleanlinessLevel;
  String noiseLevel;
  String socialPreferences;
  String visitorsPolicy; // Mapped from Firestore 'visitorsPolicy'
  String petOwnership;
  String petTolerance;
  String sleepingSchedule;
  String workSchedule;
  String sharingCommonSpaces;
  String guestsOvernightPolicy; // Mapped from Firestore 'guestOvernightStays'
  String personalSpaceVsSocialization;

  // Flat Details
  String flatType;
  String furnishedStatus;
  String availableFor;
  DateTime? availabilityDate;
  int? rentPrice; // Changed to nullable int
  int? depositAmount; // Changed to nullable int
  String bathroomType;
  String balconyAvailability;
  String parkingAvailability;
  List<String> amenities;
  String address;
  String landmark;
  String flatDescription; // Mapped from Firestore 'description'

  // Flatmate Preferences
  String preferredGender; // Mapped from Firestore 'preferredFlatmateGender'
  String preferredAgeGroup; // Mapped from Firestore 'preferredFlatmateAge'
  String preferredOccupation;
  List<String> preferredHabits;
  List<String> flatmateIdealQualities; // Mapped from Firestore 'idealQualities'
  List<String> flatmateDealBreakers; // Mapped from Firestore 'dealBreakers'

  // Added: List of image URLs for the flat
  List<String>? imageUrls;

  FlatListingProfile({
    this.documentId = '',
    this.uid, // Initialize uid
    this.ownerName = '',
    this.ownerAge,
    this.ownerGender = '',
    this.ownerOccupation = '',
    this.ownerBio = '',
    this.desiredCity = '',
    this.areaPreference = '',
    this.smokingHabit = '',
    this.drinkingHabit = '',
    this.foodPreference = '',
    this.cleanlinessLevel = '',
    this.noiseLevel = '',
    this.socialPreferences = '',
    this.visitorsPolicy = '',
    this.petOwnership = '',
    this.petTolerance = '',
    this.sleepingSchedule = '',
    this.workSchedule = '',
    this.sharingCommonSpaces = '',
    this.guestsOvernightPolicy = '',
    this.personalSpaceVsSocialization = '',
    this.flatType = '',
    this.furnishedStatus = '',
    this.availableFor = '',
    this.availabilityDate,
    this.rentPrice,
    this.depositAmount,
    this.bathroomType = '',
    this.balconyAvailability = '',
    this.parkingAvailability = '',
    List<String>? amenities, // Make nullable for constructor init
    this.address = '',
    this.landmark = '',
    this.flatDescription = '',
    this.preferredGender = '',
    this.preferredAgeGroup = '',
    this.preferredOccupation = '',
    List<String>? preferredHabits, // Make nullable for constructor init
    List<String>? flatmateIdealQualities, // Make nullable for constructor init
    List<String>? flatmateDealBreakers, // Make nullable for constructor init
    List<String>? imageUrls, // Added to constructor
  })  : amenities = amenities ?? const [], // Initialize amenities list
        preferredHabits = preferredHabits ?? const [], // Initialize preferredHabits list
        flatmateIdealQualities = flatmateIdealQualities ?? const [], // Initialize flatmateIdealQualities list
        flatmateDealBreakers = flatmateDealBreakers ?? const [], // Initialize flatmateDealBreakers list
        imageUrls = imageUrls; // Initialize imageUrls

  factory FlatListingProfile.fromMap(Map<String, dynamic> data, String documentId) {
    Map<String, dynamic> habits = data['habits'] ?? {};
    Map<String, dynamic> flatDetails = data['flatDetails'] ?? {};
    Map<String, dynamic> flatmatePreferences = data['flatmatePreferences'] ?? {};

    return FlatListingProfile(
      documentId: documentId,
      uid: data['uid'] as String?,
      ownerName: data['displayName'] ?? '', // Assuming ownerName is 'displayName' at root level
      ownerAge: data['age'] is int ? data['age'] : (data['age'] is String ? int.tryParse(data['age']) : null), // Assuming age is at root level
      ownerGender: data['gender'] ?? '', // Assuming gender is at root level
      ownerOccupation: data['occupation'] ?? '', // Assuming occupation is at root level
      ownerBio: data['bio'] ?? '', // Assuming bio is at root level
      desiredCity: data['desiredCity'] ?? '', // Assuming desiredCity is at root level
      areaPreference: data['areaPreference'] ?? '', // Assuming areaPreference is at root level

      // Habits
      smokingHabit: habits['smoking'] ?? '',
      drinkingHabit: habits['drinking'] ?? '',
      foodPreference: habits['food'] ?? '',
      cleanlinessLevel: habits['cleanliness'] ?? '',
      noiseLevel: habits['noiseTolerance'] ?? '',
      socialPreferences: habits['socialPreferences'] ?? '',
      visitorsPolicy: habits['visitorsPolicy'] ?? '',
      petOwnership: habits['petOwnership'] ?? '',
      petTolerance: habits['petTolerance'] ?? '',
      sleepingSchedule: habits['sleepingSchedule'] ?? '',
      workSchedule: habits['workSchedule'] ?? '',
      sharingCommonSpaces: habits['sharingCommonSpaces'] ?? '',
      guestsOvernightPolicy: habits['guestOvernightStays'] ?? '',
      personalSpaceVsSocialization: habits['personalSpaceVsSocializing'] ?? '',

      // Flat Details
      flatType: flatDetails['flatType'] ?? '',
      furnishedStatus: flatDetails['furnishedStatus'] ?? '',
      availableFor: flatDetails['availableFor'] ?? '',
      availabilityDate: (flatDetails['availabilityDate'] is Timestamp)
          ? (flatDetails['availabilityDate'] as Timestamp).toDate()
          : null,
      rentPrice: flatDetails['rentPrice'] is int ? flatDetails['rentPrice'] : (flatDetails['rentPrice'] is String ? int.tryParse(flatDetails['rentPrice']) : null),
      depositAmount: flatDetails['depositAmount'] is int ? flatDetails['depositAmount'] : (flatDetails['depositAmount'] is String ? int.tryParse(flatDetails['depositAmount']) : null),
      bathroomType: flatDetails['bathroomType'] ?? '',
      balconyAvailability: flatDetails['balconyAvailability'] ?? '',
      parkingAvailability: flatDetails['parkingAvailability'] ?? '',
      amenities: List<String>.from(flatDetails['amenities'] ?? []),
      address: flatDetails['address'] ?? '',
      landmark: flatDetails['landmark'] ?? '',
      flatDescription: flatDetails['description'] ?? '', // Firestore has 'description'

      // Flatmate Preferences
      preferredGender: flatmatePreferences['preferredFlatmateGender'] ?? '',
      preferredAgeGroup: flatmatePreferences['preferredFlatmateAge'] ?? '',
      preferredOccupation: flatmatePreferences['preferredOccupation'] ?? '',
      preferredHabits: List<String>.from(flatmatePreferences['preferredHabits'] ?? []),
      flatmateIdealQualities: List<String>.from(flatmatePreferences['idealQualities'] ?? []),
      flatmateDealBreakers: List<String>.from(flatmatePreferences['dealBreakers'] ?? []),
      // Parse imageUrls from Firestore map
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  // Method to convert the object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // Include uid when converting to map
      'ownerName': ownerName,
      'ownerAge': ownerAge,
      'ownerGender': ownerGender,
      'ownerOccupation': ownerOccupation,
      'ownerBio': ownerBio,
      'desiredCity': desiredCity,
      'areaPreference': areaPreference,
      'habits': {
        'smoking': smokingHabit,
        'drinking': drinkingHabit,
        'food': foodPreference,
        'cleanliness': cleanlinessLevel,
        'noiseTolerance': noiseLevel,
        'socialPreferences': socialPreferences,
        'visitorsPolicy': visitorsPolicy,
        'petOwnership': petOwnership,
        'petTolerance': petTolerance,
        'sleepingSchedule': sleepingSchedule,
        'workSchedule': workSchedule,
        'sharingCommonSpaces': sharingCommonSpaces,
        'guestOvernightStays': guestsOvernightPolicy,
        'personalSpaceVsSocializing': personalSpaceVsSocialization,
      },
      'flatDetails': {
        'flatType': flatType,
        'furnishedStatus': furnishedStatus,
        'availableFor': availableFor,
        'availabilityDate': availabilityDate != null ? Timestamp.fromDate(availabilityDate!) : null,
        'rentPrice': rentPrice,
        'depositAmount': depositAmount,
        'bathroomType': bathroomType,
        'balconyAvailability': balconyAvailability,
        'parkingAvailability': parkingAvailability,
        'amenities': amenities,
        'address': address,
        'landmark': landmark,
        'description': flatDescription, // Map to 'description' for Firestore
      },
      'flatmatePreferences': {
        'preferredFlatmateGender': preferredGender,
        'preferredFlatmateAge': preferredAgeGroup,
        'preferredOccupation': preferredOccupation,
        'preferredHabits': preferredHabits,
        'idealQualities': flatmateIdealQualities,
        'dealBreakers': flatmateDealBreakers,
      },
      'imageUrls': imageUrls, // Include imageUrls when converting to map
    };
  }

  @override
  String toString() {
    return 'FlatListingProfile(\n'
        '  documentId: $documentId,\n'
        '  uid: $uid,\n'
        '  ownerName: $ownerName,\n'
        '  ownerAge: $ownerAge,\n'
        '  ownerGender: $ownerGender,\n'
        '  ownerOccupation: $ownerOccupation,\n'
        '  ownerBio: $ownerBio,\n'
        '  desiredCity: $desiredCity,\n'
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
        '  dealBreakers: $flatmateDealBreakers,\n'
        '  imageUrls: $imageUrls,\n' // Include imageUrls in toString
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
                      borderRadius: BorderRadius.circular(30),
                    ),
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
  bool _isSubmitting = false; // Added for loading indicator

  // Change _pages from late final to a getter
  List<Widget> get _pages => _buildPages();

  // Declare TextEditingControllers for all text input fields
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerAgeController;
  late TextEditingController _ownerOccupationController;
  late TextEditingController _ownerBioController;
  late TextEditingController _desiredCityController;
  late TextEditingController _areaPreferenceController;
  late TextEditingController _rentPriceController;
  late TextEditingController _depositAmountController;
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _flatDescriptionController;

  // Define your sections - UPDATED
  final List<Map<String, dynamic>> _sections = [
    {'title': 'About You', 'startPage': 0, 'endPage': 6}, // Pages 0-6
    {'title': 'Your Habits', 'startPage': 7, 'endPage': 20}, // Pages 7-20
    {'title': 'Flat Details', 'startPage': 21, 'endPage': 33}, // Pages 21-33
    {'title': 'Flatmate Preferences', 'startPage': 34, 'endPage': 39}, // Pages...
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
        final int pagesInSection = (section['endPage'] as int) - (section['startPage'] as int) + 1; // Explicit cast to int
        final int currentPageInSection = _currentPage - (section['startPage'] as int); // Explicit cast to int
        return (currentPageInSection + 1) / pagesInSection;
      }
    }
    return 0.0;
  }

  // Method to check if the current page's input is valid
  bool _isCurrentPageValid() {
    switch (_currentPage) {
      case 0: // Owner Name
        return _ownerNameController.text.isNotEmpty;
      case 1: // Owner Age
        final age = int.tryParse(_ownerAgeController.text);
        return age != null && age >= 18 && age <= 99;
      case 2: // Owner Gender
        return _flatListingProfile.ownerGender.isNotEmpty;
      case 3: // Owner Occupation
        return _ownerOccupationController.text.isNotEmpty;
      case 4: // Owner Bio
        return _ownerBioController.text.isNotEmpty;
      case 5: // Desired City (Flat Location)
        return _desiredCityController.text.isNotEmpty;
      case 6: // Area Preference
        return _areaPreferenceController.text.isNotEmpty;
      case 7: // Smoking Habits
        return _flatListingProfile.smokingHabit.isNotEmpty;
      case 8: // Drinking Habits
        return _flatListingProfile.drinkingHabit.isNotEmpty;
      case 9: // Food Preference
        return _flatListingProfile.foodPreference.isNotEmpty;
      case 10: // Cleanliness Level
        return _flatListingProfile.cleanlinessLevel.isNotEmpty;
      case 11: // Noise Level
        return _flatListingProfile.noiseLevel.isNotEmpty;
      case 12: // Social Habits
        return _flatListingProfile.socialPreferences.isNotEmpty;
      case 13: // Visitors policy
        return _flatListingProfile.visitorsPolicy.isNotEmpty;
      case 14: // Pet ownership
        return _flatListingProfile.petOwnership.isNotEmpty;
      case 15: // Pet tolerance
        return _flatListingProfile.petTolerance.isNotEmpty;
      case 16: // Sleeping schedule
        return _flatListingProfile.sleepingSchedule.isNotEmpty;
      case 17: // Work schedule
        return _flatListingProfile.workSchedule.isNotEmpty;
      case 18: // Sharing Common Spaces
        return _flatListingProfile.sharingCommonSpaces.isNotEmpty;
      case 19: // Guests Policy for Overnight Stays
        return _flatListingProfile.guestsOvernightPolicy.isNotEmpty;
      case 20: // Personal Space
        return _flatListingProfile.personalSpaceVsSocialization.isNotEmpty;
      case 21: // Flat Type
        return _flatListingProfile.flatType.isNotEmpty;
      case 22: // Furnished Status
        return _flatListingProfile.furnishedStatus.isNotEmpty;
      case 23: // Available For
        return _flatListingProfile.availableFor.isNotEmpty;
      case 24: // Availability Date
        return _flatListingProfile.availabilityDate != null;
      case 25: // Rent Price
        return _flatListingProfile.rentPrice != null && _flatListingProfile.rentPrice! > 0;
      case 26: // Deposit Amount
        return _flatListingProfile.depositAmount != null && _flatListingProfile.depositAmount! >= 0;
      case 27: // Bathroom Type
        return _flatListingProfile.bathroomType.isNotEmpty;
      case 28: // Balcony Availability
        return _flatListingProfile.balconyAvailability.isNotEmpty;
      case 29: // Parking Availability
        return _flatListingProfile.parkingAvailability.isNotEmpty;
      case 30: // Amenities
        return _flatListingProfile.amenities.isNotEmpty; // At least one amenity selected
      case 31: // Address
        return _addressController.text.isNotEmpty;
      case 32: // Landmark (optional, so always valid if we don't enforce it)
        return true;
      case 33: // Flat Description
        return _flatDescriptionController.text.isNotEmpty;
      case 34: // Preferred Flatmate Gender
        return _flatListingProfile.preferredGender.isNotEmpty;
      case 35: // Preferred Flatmate Age Group
        return _flatListingProfile.preferredAgeGroup.isNotEmpty;
      case 36: // Preferred Flatmate Occupation
        return _flatListingProfile.preferredOccupation.isNotEmpty;
      case 37: // Preferred Flatmate Habits
        return _flatListingProfile.preferredHabits.isNotEmpty;
      case 38: // Ideal Qualities in a Flatmate
        return _flatListingProfile.flatmateIdealQualities.isNotEmpty;
      case 39: // Deal Breakers
        return _flatListingProfile.flatmateDealBreakers.isNotEmpty;
      default:
        return true; // Fallback for pages not explicitly handled
    }
  }


  @override
  void initState() {
    super.initState();
    // Initialize controllers with current profile values
    _ownerNameController = TextEditingController(text: _flatListingProfile.ownerName);
    _ownerAgeController = TextEditingController(text: _flatListingProfile.ownerAge?.toString() ?? '');
    _ownerOccupationController = TextEditingController(text: _flatListingProfile.ownerOccupation);
    _ownerBioController = TextEditingController(text: _flatListingProfile.ownerBio);
    _desiredCityController = TextEditingController(text: _flatListingProfile.desiredCity);
    _areaPreferenceController = TextEditingController(text: _flatListingProfile.areaPreference);
    _rentPriceController = TextEditingController(text: _flatListingProfile.rentPrice?.toString() ?? '');
    _depositAmountController = TextEditingController(text: _flatListingProfile.depositAmount?.toString() ?? '');
    _addressController = TextEditingController(text: _flatListingProfile.address);
    _landmarkController = TextEditingController(text: _flatListingProfile.landmark);
    _flatDescriptionController = TextEditingController(text: _flatListingProfile.flatDescription);


    // Add listeners to update the profile model as text changes
    _ownerNameController.addListener(() {
      _flatListingProfile.ownerName = _ownerNameController.text;
      setState(() {}); // Trigger rebuild to update button state
    });
    _ownerAgeController.addListener(() {
      _flatListingProfile.ownerAge = int.tryParse(_ownerAgeController.text);
      setState(() {}); // Trigger rebuild to update button state
    });
    _ownerOccupationController.addListener(() {
      _flatListingProfile.ownerOccupation = _ownerOccupationController.text;
      setState(() {});
    });
    _ownerBioController.addListener(() {
      _flatListingProfile.ownerBio = _ownerBioController.text;
      setState(() {});
    });
    _desiredCityController.addListener(() {
      _flatListingProfile.desiredCity = _desiredCityController.text;
      setState(() {});
    });
    _areaPreferenceController.addListener(() {
      _flatListingProfile.areaPreference = _areaPreferenceController.text;
      setState(() {});
    });
    _rentPriceController.addListener(() {
      _flatListingProfile.rentPrice = int.tryParse(_rentPriceController.text);
      setState(() {});
    });
    _depositAmountController.addListener(() {
      _flatListingProfile.depositAmount = int.tryParse(_depositAmountController.text);
      setState(() {});
    });
    _addressController.addListener(() {
      _flatListingProfile.address = _addressController.text;
      setState(() {});
    });
    _landmarkController.addListener(() {
      _flatListingProfile.landmark = _landmarkController.text;
      setState(() {});
    });
    _flatDescriptionController.addListener(() {
      _flatListingProfile.flatDescription = _flatDescriptionController.text;
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    _ownerNameController.dispose();
    _ownerAgeController.dispose();
    _ownerOccupationController.dispose();
    _ownerBioController.dispose();
    _desiredCityController.dispose();
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
                              foregroundColor:
                              Colors.redAccent,
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

  // --- Page Definitions ---

  List<Widget> _buildPages() {
    return [
      // --- Section 1: About You (Pages 0-6) ---
      // Page 0: Owner Name
      _buildTextQuestion(
        title: "What's your name?",
        subtitle: "This will be visible to potential flatmates.",
        hintText: "Enter your name",
        controller: _ownerNameController,
      ),

      // Page 1: Owner Age
      _buildTextQuestion(
        title: "How old are you?",
        subtitle: "This helps flatmates understand your age group.",
        hintText: "e.g., 25",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _ownerAgeController,
      ),

      // Page 2: Owner Gender
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

      // Page 3: Owner Occupation
      _buildTextQuestion(
        title: "What do you do for a living?",
        subtitle: "Share your profession or student status.",
        hintText: "e.g., Software Engineer, Student, Freelancer",
        controller: _ownerOccupationController,
      ),

      // Page 4: Owner Bio
      _buildTextQuestion(
        title: "Tell us a bit about yourself as a flat owner/current flatmate.",
        subtitle: "Share something interesting! This helps others get to know you.",
        hintText: "e.g., I'm a quiet person who loves reading...",
        controller: _ownerBioController,
        maxLines: 5,
      ),

      // Page 5: Desired City (This is the city the flat is *in*)


      // Page 6: Area Preference (This is for the flat's area)
      _buildCitySelectionQuestion(
        title: "Which city does your flat located ?",
        subtitle: "This helps us filter relevant listings for you.",
        onCitySelected: (value) {
          setState(() {
            _flatListingProfile.desiredCity = value;
            // Clear area preference when city changes
            _flatListingProfile.areaPreference = '';
            _areaPreferenceController.clear();
          });
        },
        initialValue: _flatListingProfile.desiredCity,
        cities: maharashtraLocations.keys.toList(),
      ),
      _buildAreaSelectionQuestion(
        title: "What is your flat located  areas/localities?",
        subtitle: "Select preferred areas within ${(_flatListingProfile.desiredCity.isNotEmpty ? _flatListingProfile.desiredCity : 'the selected city')}.",
        onAreaSelected: (value) {
          setState(() {
            _flatListingProfile.areaPreference = value;
          });
        },
        initialValue: _flatListingProfile.areaPreference,
        areas: maharashtraLocations[_flatListingProfile.desiredCity] ?? [], // Dynamically load areas
        selectedCity: _flatListingProfile.desiredCity, // Pass selected city to enable/disable
      ),
      // --- Section 2: Your Habits (Owner's Habits) (Pages 7-20) ---
      // Page 7: Smoking Habits (Owner's)
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
      // Page 8: Drinking Habits (Owner's)
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
      // Page 9: Food Preference (Owner's)
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

      // Page 10: Cleanliness Level (Owner's)
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

      // Page 11: Noise level (Owner's preference)
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

      // Page 12: Social Habits (Owner's)
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

      // Page 13: Visitors policy (Owner's)
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

      // Page 14: Pet ownership (Owner's)
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
      // Page 15: Pet tolerance (Owner's)
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
      // Page 16: Sleeping schedule (Owner's)
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
      // Page 17: Work schedule (Owner's)
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

      // Page 18: Sharing Common Spaces (Owner's)
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
      // Page 19: Guests Policy for Overnight Stays (Owner's)
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
      // Page 20: Personal Space (Owner's)
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


      // --- Section 3: Flat Details (Pages 21-33) ---
      // Page 21: Flat Type
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

      // Page 22: Furnished Status
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

      // Page 23: Available For
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

      // Page 24: Availability Date
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

      // Page 25: Rent Price
      _buildTextQuestion(
        title: "What is the monthly rent for the flat/room?",
        subtitle: "Enter the rent amount in ₹.",
        hintText: "e.g., 12000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _rentPriceController,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('₹', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      ),

      // Page 26: Deposit Amount
      _buildTextQuestion(
        title: "What is the security deposit amount?",
        subtitle: "Enter the deposit amount in ₹.",
        hintText: "e.g., 24000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _depositAmountController,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('₹', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      ),

      // Page 27: Bathroom Type
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

      // Page 28: Balcony Availability
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

      // Page 29: Parking Availability
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

      // Page 30: Amenities (Multi-choice)
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

      // Page 31: Address
      _buildTextQuestion(
        title: "What is the full address of the flat?",
        subtitle: "Include Building/Society Name, Street, Locality.",
        hintText: "Enter full address",
        controller: _addressController,
        maxLines: 3,
      ),

      // Page 32: Landmark
      _buildTextQuestion(
        title: "Add a nearby landmark (optional).",
        subtitle: "Helps in easy navigation.",
        hintText: "e.g., Near D-Mart, Beside XYZ Cafe",
        controller: _landmarkController,
      ),

      // Page 33: Flat Description
      _buildTextQuestion(
        title: "Describe your flat.",
        subtitle: "Highlight key features, vibe, and what makes it a great place.",
        hintText: "e.g., Spacious 2BHK with great sunlight, friendly neighborhood...",
        controller: _flatDescriptionController,
        maxLines: 5,
      ),

      // --- Section 4: Flatmate Preferences (Pages 34-39) ---
      // Page 34: Preferred Flatmate Gender
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

      // Page 35: Preferred Flatmate Age Group
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

      // Page 36: Preferred Flatmate Occupation
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

      // Page 37: Preferred Flatmate Habits (Multi-choice)
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

      // Page 38: Ideal Qualities in a Flatmate (Multi-choice)
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

      // Page 39: Deal Breakers (Multi-choice)
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
    // Removed the _isCurrentPageValid() check and SnackBar for
    // allowing progression without strict validation at each step,
    // as per the user's request "do not make anything compulsory".
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

    // Get a reference to the 'flatListings' subcollection for the current user
    final CollectionReference flatListingsCollection =
    FirebaseFirestore.instance.collection('users').doc(user.uid).collection('flatListings');

    // --- Use your provided profileData structure ---
    final Map<String, dynamic> profileData = {
      "uid": user.uid,
      "email": user.email, //
      "displayName": _flatListingProfile.ownerName,
      "age": _flatListingProfile.ownerAge ?? 0,
      "gender": _flatListingProfile.ownerGender,
      "occupation": _flatListingProfile.ownerOccupation,
      "bio": _flatListingProfile.ownerBio,
      "desiredCity": _flatListingProfile.desiredCity,//
      "areaPreference": _flatListingProfile.areaPreference,//
      "userType": "flat_listing",
      "habits": {
        "smoking": _flatListingProfile.smokingHabit,
        "drinking": _flatListingProfile.drinkingHabit,
        "food": _flatListingProfile.foodPreference,
        "cleanliness": _flatListingProfile.cleanlinessLevel,
        "noiseTolerance": _flatListingProfile.noiseLevel,//
        "socialPreferences": _flatListingProfile.socialPreferences,
        "visitorsPolicy": _flatListingProfile.visitorsPolicy,//
        "petOwnership": _flatListingProfile.petOwnership,
        "petTolerance": _flatListingProfile.petTolerance,
        "sleepingSchedule": _flatListingProfile.sleepingSchedule,//
        "workSchedule": _flatListingProfile.workSchedule,//
        "sharingCommonSpaces": _flatListingProfile.sharingCommonSpaces,//
        "guestOvernightStays": _flatListingProfile.guestsOvernightPolicy,//
        "personalSpaceVsSocialization": _flatListingProfile.personalSpaceVsSocialization,//
      },
      "flatDetails": {
        "flatType": _flatListingProfile.flatType,
        "furnishedStatus": _flatListingProfile.furnishedStatus,
        "availableFor": _flatListingProfile.availableFor,
        "availabilityDate": _flatListingProfile.availabilityDate != null
            ? Timestamp.fromDate(_flatListingProfile.availabilityDate!)
            : null,
        "rentPrice": _flatListingProfile.rentPrice ?? 0,
        "depositAmount": _flatListingProfile.depositAmount ?? 0,
        "bathroomType": _flatListingProfile.bathroomType,
        "balconyAvailability": _flatListingProfile.balconyAvailability,//
        "parkingAvailability": _flatListingProfile.parkingAvailability,//
        "amenities": _flatListingProfile.amenities,
        "address": _flatListingProfile.address,
        "landmark": _flatListingProfile.landmark,
        "description": _flatListingProfile.flatDescription,
      },
      "flatmatePreferences": {
        "preferredFlatmateGender": _flatListingProfile.preferredGender,
        "preferredFlatmateAge": _flatListingProfile.preferredAgeGroup,
        "preferredOccupation": _flatListingProfile.preferredOccupation,
        "idealQualities": _flatListingProfile.flatmateIdealQualities,
        "dealBreakers": _flatListingProfile.flatmateDealBreakers,
        // Ensure preferredHabits is included if it's a field in your model,
        // it was missing from your habits section in the provided `profileData`
        // if you want it here: "preferredHabits": _flatListingProfile.preferredHabits,
      },
      "isProfileComplete": true,
      // Timestamps will be handled below based on new/update
      // "createdAt": FieldValue.serverTimestamp(), // Removed from here
      // "lastUpdated": FieldValue.serverTimestamp(), // Removed from here
    };

    try {
      if (_flatListingProfile.documentId.isEmpty) {
        // This is a new listing, add it to the subcollection
        profileData['createdAt'] = FieldValue.serverTimestamp();
        profileData['lastUpdated'] = FieldValue.serverTimestamp();

        DocumentReference newDocRef = await flatListingsCollection.add(profileData);
        // Update the local model with the new Firestore document ID
        _flatListingProfile.documentId = newDocRef.id;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New Flat Listing Profile Created Successfully!')),
        );
      } else {
        // This is an existing listing, update it
        profileData['lastUpdated'] = FieldValue.serverTimestamp();
        // Do not update 'createdAt' on existing documents
        profileData.remove('createdAt');

        await flatListingsCollection.doc(_flatListingProfile.documentId).update(profileData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flat Listing Profile Updated Successfully!')),
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()), // Consider MyProfilesScreen
        );
      }
    } catch (e) {
      print('Error submitting flat listing profile to Firebase: $e');
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
    print('Submitting Flat Listing Profile:');
    print(_flatListingProfile.toString());
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
                      'Section ${_sections.indexOf(_sections.firstWhere((s) => _currentPage >= s['startPage'] && _currentPage <= s['endPage'])) + 1} of ${_sections.length}: ${_getCurrentSectionTitle()}',
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
                          side: BorderSide(color: _currentPage > 0 ? Colors.redAccent : Colors.grey),
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
                        onPressed: _nextPage, // Always enabled
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent, // Always red
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