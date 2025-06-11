// flatmate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Data model to hold all the answers for the user listing a flat
class FlatListingProfile {
  String ownerName = '';
  String ownerAge = '';
  String ownerGender = '';
  String ownerOccupation = '';
  String ownerBio = '';
  String address = '';
  String rent = '';
  String deposit = '';
  DateTime? availabilityDate;
  String flatType = '';
  String roomType = '';
  String numExistingFlatmates = '';
  String flatmateGenderAge = '';
  String flatVibe = '';
  String amenities = '';
  String flatCleanliness = '';
  String flatSocialVibe = '';
  String flatNoiseLevel = '';
  String allowsSmoking = '';
  String allowsPets = '';
  String allowsGuests = '';
  List<String> desiredQualities = [];
  List<String> dealBreakers = [];

  @override
  String toString() {
    return 'FlatListingProfile(\n'
        '  ownerName: $ownerName,\n'
        '  ownerAge: $ownerAge,\n'
        '  ownerGender: $ownerGender,\n'
        '  ownerOccupation: $ownerOccupation,\n'
        '  ownerBio: $ownerBio,\n'
        '  address: $address,\n'
        '  rent: $rent,\n'
        '  deposit: $deposit,\n'
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

  // Changed _pages from late final to a getter
  List<Widget> get _pages => _buildPages();

  @override
  void initState() {
    super.initState();
    // Removed _pages = _buildPages(); from initState
  }

  // --- Common Question Builders (Copied for consistency, ensure these are identical) ---

  Widget _buildTextQuestion({
    required String title,
    required String subtitle,
    required String hintText,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
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
          TextField(
            controller: TextEditingController(text: initialValue),
            onChanged: onChanged,
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

      // Page 2: Owner Name
      _buildTextQuestion(
        title: "What's your name?",
        subtitle: "This will be visible to potential flatmates.",
        hintText: "Enter your name",
        onChanged: (value) {
          setState(() {
            _profile.ownerName = value;
          });
        },
        initialValue: _profile.ownerName,
      ),

      // Page 3: Owner Age
      _buildTextQuestion(
        title: "How old are you?",
        subtitle: "This helps flatmates understand the age group.",
        hintText: "Enter your age",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {
            _profile.ownerAge = value;
          });
        },
        initialValue: _profile.ownerAge,
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
        onChanged: (value) {
          setState(() {
            _profile.ownerOccupation = value;
          });
        },
        initialValue: _profile.ownerOccupation,
      ),

      // Page 6: Owner Bio
      _buildTextQuestion(
        title: "Tell us a bit about yourself as an owner/current flatmate.",
        subtitle: "Share something interesting! This helps flatmates get to know you.",
        hintText: "e.g., I'm a quiet person who loves reading...",
        onChanged: (value) {
          setState(() {
            _profile.ownerBio = value;
          });
        },
        initialValue: _profile.ownerBio,
      ),

      // Page 7: Address
      _buildTextQuestion(
        title: "What's the full address of the flat?",
        subtitle: "This will be used for location-based matching.",
        hintText: "Enter flat address",
        onChanged: (value) {
          setState(() {
            _profile.address = value;
          });
        },
        initialValue: _profile.address,
      ),

      // Page 8: Rent
      _buildTextQuestion(
        title: "What is the monthly rent?",
        subtitle: "Specify the rent for the room/flat.",
        hintText: "e.g., ₹15000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {
            _profile.rent = value;
          });
        },
        initialValue: _profile.rent,
      ),

      // Page 9: Deposit
      _buildTextQuestion(
        title: "What is the security deposit?",
        subtitle: "Enter the refundable security deposit amount.",
        hintText: "e.g., ₹30000",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {
            _profile.deposit = value;
          });
        },
        initialValue: _profile.deposit,
      ),

      // Page 10: Availability Date
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

      // Page 11: Flat Type
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

      // Page 12: Room Type
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

      // Page 13: Number of Existing Flatmates
      _buildTextQuestion(
        title: "How many flatmates currently live there?",
        subtitle: "Excluding yourself, if you live there.",
        hintText: "e.g., 1, 2, None",
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {
            _profile.numExistingFlatmates = value;
          });
        },
        initialValue: _profile.numExistingFlatmates,
      ),

      // Page 14: Flatmate Gender/Age Preference
      SingleChoiceQuestionWidget(
        title: "Any preference for flatmate gender/age?",
        subtitle: "This helps in finding a compatible match.",
        options: ['Male', 'Female', 'No preference', 'Specific age range'],
        onSelected: (value) {
          setState(() {
            _profile.flatmateGenderAge = value;
          });
        },
        initialValue: _profile.flatmateGenderAge,
      ),

      // Page 15: Flat Vibe
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

      // Page 16: Amenities
      _buildMultiChoiceQuestion(
        title: "What amenities does the flat offer?",
        subtitle: "Select all available amenities.",
        options: [
          'Furnished', 'AC', 'Washing Machine', 'Refrigerator', 'Geyser',
          'Wi-Fi', 'Parking', 'Gym', 'Swimming Pool', 'Security'
        ],
        onSelected: (selected) {
          setState(() {
            _profile.amenities = selected.join(', '); // Store as a comma-separated string
          });
        },
        initialValues: _profile.amenities.split(', ').where((s) => s.isNotEmpty).toList(),
      ),

      // Page 17: Flat Cleanliness Expectations
      SingleChoiceQuestionWidget(
        title: "What are your cleanliness expectations?",
        subtitle: "How clean do you expect your flatmate to be?",
        options: ['Very Clean', 'Moderately Clean', 'Flexible', 'Don\'t mind mess'],
        onSelected: (value) {
          setState(() {
            _profile.flatCleanliness = value;
          });
        },
        initialValue: _profile.flatCleanliness,
      ),

      // Page 18: Flat Social Vibe Expectations
      SingleChoiceQuestionWidget(
        title: "What's the social vibe you prefer in the flat?",
        subtitle: "Do you enjoy social gatherings or prefer quiet?",
        options: ['Social & outgoing', 'Occasional gatherings', 'Quiet & private', 'Flexible'],
        onSelected: (value) {
          setState(() {
            _profile.flatSocialVibe = value;
          });
        },
        initialValue: _profile.flatSocialVibe,
      ),

      // Page 19: Flat Noise Level Expectations
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

      // Page 20: Allows Smoking
      SingleChoiceQuestionWidget(
        title: "Is smoking allowed in the flat?",
        subtitle: "Indoors or outdoors only?",
        options: ['Indoors & Outdoors', 'Outdoors Only', 'Not Allowed'],
        onSelected: (value) {
          setState(() {
            _profile.allowsSmoking = value;
          });
        },
        initialValue: _profile.allowsSmoking,
      ),

      // Page 21: Allows Pets
      SingleChoiceQuestionWidget(
        title: "Are pets allowed in the flat?",
        subtitle: "Specify your pet policy.",
        options: ['Yes', 'No', 'Negotiable'],
        onSelected: (value) {
          setState(() {
            _profile.allowsPets = value;
          });
        },
        initialValue: _profile.allowsPets,
      ),

      // Page 22: Allows Guests
      SingleChoiceQuestionWidget(
        title: "Are guests allowed in the flat?",
        subtitle: "Specify policy regarding guests.",
        options: ['Yes, freely', 'Yes, with notice', 'Only day guests', 'No overnight guests'],
        onSelected: (value) {
          setState(() {
            _profile.allowsGuests = value;
          });
        },
        initialValue: _profile.allowsGuests,
      ),

      // Page 23: Desired Flatmate Qualities (Multi-choice)
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
          'Independent'
        ],
        onSelected: (selected) {
          setState(() {
            _profile.desiredQualities = selected;
          });
        },
        initialValues: _profile.desiredQualities,
      ),

      // Page 24: Deal Breakers (Multi-choice)
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
          });
        },
        initialValues: _profile.dealBreakers,
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
          ElevatedButton(
            onPressed: _submitProfile,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: const Text("Find my Flatmate",
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
    // This is where you would typically send the _profile data to a backend
    // or save it locally.
    // print('Submitting Flat Listing Profile:');
    // print(_profile.toString());

    // For demonstration, navigate away or show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Flat Listing Submitted Successfully! Check console for data.')),
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