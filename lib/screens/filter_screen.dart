// lib/screens/filter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:mytennat/screens/filter_options.dart'; // Make sure this path is correct
import 'package:intl/intl.dart'; // For date formatting
import 'package:mytennat/data/location_data.dart'; // Import the new location data

class FilterScreen extends StatefulWidget {
  final FilterOptions initialFilters;
  final bool isSeekingFlatmate; // To determine which filters to show/apply
  final ValueChanged<FilterOptions> onFiltersChanged; // Callback for changes

  const FilterScreen({
    super.key,
    required this.initialFilters,
    required this.isSeekingFlatmate,
    required this.onFiltersChanged,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> with SingleTickerProviderStateMixin {
  late FilterOptions _filters; // Working copy of filters

  // Text controllers for numerical inputs (kept for non-slider inputs)
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController(); // Only occupation remains a text field

  // RangeValues for sliders
  late RangeValues _ageRange;
  late RangeValues _rentRange;
  late RangeValues _budgetRange;

  // Date controllers (not actual controllers, just for display/selection)
  String _moveInDateText = '';
  String _availabilityDateText = '';

  // Dropdown options (add all possible values from your data models)
  final List<String> _genders = ['Male', 'Female', 'Other', 'Any'];
  final List<String> _flatTypes = ['1BHK', '2 BHK', '3 BHK', 'Studio', 'Private Room', 'Shared Room', 'Villa', 'Other'];
  final List<String> _furnishedStatuses = ['Furnished', 'Semi-Furnished', 'Unfurnished'];
  final List<String> _availableForOptions = ['Male', 'Female', 'Couple', 'Family', 'Students', 'Professionals', 'Any'];

  // Updated: Lists for Desired City and Area Preference dropdowns
  late List<String> _cities; // Will be initialized from maharashtraLocations
  late List<String> _areas; // Will be dynamically updated based on selected city

  // Lifestyle & Habits options (ensure these match your profile data's values)
  final List<String> _cleanlinessLevels = ['Very Clean', 'Moderately Clean', 'Flexible', 'Any'];
  final List<String> _socialHabitsOptions = ['Very Social', 'Moderately Social', 'Quiet/Introvert', 'Any'];
  final List<String> _noiseLevels = ['Quiet', 'Moderate', 'Lively', 'Any'];
  final List<String> _smokingHabitsOptions = ['Non-Smoker', 'Social Smoker', 'Smoker', 'Any'];
  final List<String> _drinkingHabitsOptions = ['Non-Drinker', 'Social Drinker', 'Heavy Drinker', 'Any'];
  final List<String> _foodPreferences = ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggetarian', 'Any'];
  final List<String> _petOwnershipOptions = ['Has Pets', 'No Pets', 'Any'];
  final List<String> _petToleranceOptions = ['Pet-Friendly', 'Not Pet-Friendly', 'Specific Pets Only', 'Any'];
  final List<String> _workScheduleOptions = ['9-5 Office', 'Flexible Remote', 'Night Shift', 'Student', 'Any'];
  final List<String> _sleepingScheduleOptions = ['Early Riser', 'Night Owl', 'Flexible', 'Any'];
  final List<String> _visitorsPolicyOptions = ['Guests Welcome', 'Occasional Guests', 'No Guests', 'Any'];
  final List<String> _guestsOvernightPolicyOptions = ['Allowed', 'Not Allowed', 'Occasional', 'Any'];

  // Multi-select options (reusing _FilterChipGroup)
  final List<String> _amenitiesOptions = [
    'AC', 'Geyser', 'Washing Machine', 'Refrigerator', 'RO Water', 'Wi-Fi',
    'Parking', 'Security', 'Lift', 'Gym', 'Swimming Pool', 'Clubhouse',
    'Power Backup', 'Gas Pipeline', 'Modular Kitchen', 'Wardrobe',
  ];
  final List<String> _commonQualities = [
    'Organized', 'Responsible', 'Friendly', 'Respectful', 'Good Communicator',
    'Clean', 'Easygoing', 'Independent',
  ];
  final List<String> _commonDealBreakers = [
    'Smoking Indoors', 'Excessive Noise', 'Untidiness', 'Frequent Parties',
    'Undeclared Guests', 'Pets (if not allowed)',
  ];

  late TabController _tabController; // Tab controller

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters.copyWith(); // Create a working copy

    // Initialize TabController
    _tabController = TabController(length: 2, vsync: this);

    // Initialize text controllers with current filter values
    _bedroomsController.text = _filters.numberOfBedrooms?.toString() ?? '';
    _bathroomsController.text = _filters.numberOfBathrooms?.toString() ?? '';
    _occupationController.text = _filters.occupation ?? '';

    // Initialize RangeValues based on initial filters or default values
    _ageRange = RangeValues(
      _filters.ageMin?.toDouble() ?? 18,
      _filters.ageMax?.toDouble() ?? 60,
    );
    _rentRange = RangeValues(
      _filters.rentPriceMin?.toDouble() ?? 0,
      _filters.rentPriceMax?.toDouble() ?? 50000,
    );
    _budgetRange = RangeValues(
      _filters.budgetMin?.toDouble() ?? 0,
      _filters.budgetMax?.toDouble() ?? 50000,
    );

    if (_filters.moveInDate != null) {
      _moveInDateText = DateFormat('dd/MM/yyyy').format(_filters.moveInDate!);
    }
    if (_filters.availabilityDate != null) {
      _availabilityDateText = DateFormat('dd/MM/yyyy').format(_filters.availabilityDate!);
    }

    // Initialize cities and areas
    _cities = ['Any'] + maharashtraLocations.keys.toList(); // Add 'Any' option
    _areas = _getAreasForCity(_filters.desiredCity); // Get initial areas based on selected city
  }

  // Helper method to get areas for a given city
  List<String> _getAreasForCity(String? city) {
    if (city == null || city == 'Any' || !maharashtraLocations.containsKey(city)) {
      return ['Any']; // Return only 'Any' if no specific city or 'Any' is selected
    }
    return ['Any'] + maharashtraLocations[city]!; // Add 'Any' option to specific city areas
  }

  @override
  void dispose() {
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _occupationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isMoveInDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.redAccent,
            colorScheme: const ColorScheme.light(primary: Colors.redAccent),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isMoveInDate) {
          _filters.moveInDate = picked;
          _moveInDateText = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _filters.availabilityDate = picked;
          _availabilityDateText = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  void _applyFilters() {
    _filters.numberOfBedrooms = int.tryParse(_bedroomsController.text);
    _filters.numberOfBathrooms = int.tryParse(_bathroomsController.text);

    widget.onFiltersChanged(_filters);
    // Navigator.of(context).pop(); // Close the filter screen after applying
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _bedroomsController.clear();
      _bathroomsController.clear();
      _occupationController.clear();
      _moveInDateText = '';
      _availabilityDateText = '';

      // Reset RangeSliders to default values
      _ageRange = const RangeValues(18, 60);
      _rentRange = const RangeValues(0, 50000);
      _budgetRange = const RangeValues(0, 50000);

      // Reset city and areas
      _filters.desiredCity = null;
      _filters.areaPreference = null;
      _areas = _getAreasForCity(null); // Reset areas to only 'Any'
    });
    widget.onFiltersChanged(_filters);
  }

  // NOTE: This method is defined but not called in filter_screen.dart.
  // The Firebase error you showed in the screenshot is likely from your data fetching logic.
  // This method would typically be used to show a SnackBar for client-side validation errors,
  // not for backend/Firestore errors like the one you observed.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Profiles', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0, // Remove app bar shadow for a flatter look
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Text color for the button
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('Clear All'),
          ),
          const SizedBox(width: 8), // Add some spacing
        ],
      ),
      body: Column(
        children: [
          // TabBar for "Filters" and "Premium Filters"
          Material(
            elevation: 2, // Slightly reduced elevation
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Filters'),
                Tab(text: 'Premium Filters'),
              ],
              labelColor: Colors.redAccent,
              unselectedLabelColor: Colors.grey.shade600, // Darker grey for better contrast
              indicatorColor: Colors.redAccent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3.0,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold), // Bold active tab text
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Content for "Filters" Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location & Price Section
                      _buildFilterSection(
                        title: 'Location & Price',
                        children: [
                          _buildDropdownFilter(
                            label: 'Desired City',
                            value: _filters.desiredCity,
                            items: _cities,
                            onChanged: (String? newValue) {
                              setState(() {
                                _filters.desiredCity = newValue == 'Any' ? null : newValue;
                                // Reset area preference and update available areas when city changes
                                _filters.areaPreference = null;
                                _areas = _getAreasForCity(_filters.desiredCity);
                              });
                            },
                          ),
                          _buildDropdownFilter(
                            label: 'Area Preference',
                            value: _filters.areaPreference,
                            items: _areas, // Dynamically loaded areas
                            onChanged: (String? newValue) {
                              setState(() {
                                _filters.areaPreference = newValue == 'Any' ? null : newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          if (widget.isSeekingFlatmate)
                            _buildDateSelection(
                              labelText: 'Move-in Date',
                              displayDate: _moveInDateText,
                              onTap: () => _selectDate(context, true),
                            ),
                          if (!widget.isSeekingFlatmate)
                            _buildDateSelection(
                              labelText: 'Availability Date',
                              displayDate: _availabilityDateText,
                              onTap: () => _selectDate(context, false),
                            ),
                          const SizedBox(height: 16),
                          _buildRangeSliderFilter(
                            label: widget.isSeekingFlatmate ? 'Budget Range' : 'Rent Range',
                            currentRange: widget.isSeekingFlatmate ? _budgetRange : _rentRange,
                            onRangeChanged: (newRange) {
                              setState(() {
                                if (widget.isSeekingFlatmate) {
                                  _budgetRange = newRange;
                                  _filters.budgetMin = newRange.start.round();
                                  _filters.budgetMax = newRange.end.round();
                                } else {
                                  _rentRange = newRange;
                                  _filters.rentPriceMin = newRange.start.round();
                                  _filters.rentPriceMax = newRange.end.round();
                                }
                              });
                            },
                            min: 0,
                            max: 100000,
                            divisions: 20,
                            icon: Icons.attach_money,
                            prefixText: '₹',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (widget.isSeekingFlatmate)
                        _buildFilterSection(
                          title: 'Flat Requirements',
                          children: [
                            _buildDropdownFilter(
                              label: 'Preferred Flat Type',
                              value: _filters.flatType,
                              items: _flatTypes,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _filters.flatType = newValue;
                                });
                              },
                            ),
                            _buildDropdownFilter(
                              label: 'Furnished Status',
                              value: _filters.furnishedStatus,
                              items: _furnishedStatuses,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _filters.furnishedStatus = newValue;
                                });
                              },
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNumberField(
                                    controller: _bedroomsController,
                                    labelText: 'Bedrooms',
                                    icon: Icons.king_bed,
                                    onChanged: (value) => _filters.numberOfBedrooms = int.tryParse(value),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildNumberField(
                                    controller: _bathroomsController,
                                    labelText: 'Bathrooms',
                                    icon: Icons.wc,
                                    onChanged: (value) => _filters.numberOfBathrooms = int.tryParse(value),
                                  ),
                                ),
                              ],
                            ),
                            _FilterChipGroup(
                              title: 'Desired Amenities',
                              availableItems: _amenitiesOptions,
                              selectedItems: _filters.amenitiesDesired,
                              onSelectionChanged: (selected) => setState(() => _filters.amenitiesDesired = selected),
                            ),
                            _buildDropdownFilter(
                              label: 'Available For',
                              value: _filters.availableFor,
                              items: _availableForOptions,
                              onChanged: (value) => setState(() => _filters.availableFor = value),
                            ),
                          ],
                        ),
                      if (widget.isSeekingFlatmate) const SizedBox(height: 24),

                      // General Preferences Section
                      _buildFilterSection(
                        title: 'General Preferences',
                        children: [
                          _buildDropdownFilter(
                            label: 'Gender',
                            value: _filters.gender,
                            items: _genders,
                            onChanged: (String? newValue) {
                              setState(() {
                                _filters.gender = newValue == 'Any' ? null : newValue;
                              });
                            },
                          ),
                          _buildRangeSliderFilter(
                            label: 'Age Range',
                            currentRange: _ageRange,
                            onRangeChanged: (newRange) {
                              setState(() {
                                _ageRange = newRange;
                                _filters.ageMin = newRange.start.round();
                                _filters.ageMax = newRange.end.round();
                              });
                            },
                            min: 18,
                            max: 80,
                            divisions: 62,
                            icon: Icons.person,
                          ),
                          _buildTextField(
                            controller: _occupationController,
                            labelText: 'Occupation',
                            icon: Icons.work,
                            onChanged: (value) => _filters.occupation = value,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Content for "Premium Filters" Tab (Lifestyle & Habits)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lifestyle & Habits Section
                      _buildFilterSection(
                        title: 'Lifestyle & Habits',
                        children: [
                          _buildDropdownFilter(
                            label: 'Cleanliness Level',
                            value: _filters.cleanlinessLevel,
                            items: _cleanlinessLevels,
                            onChanged: (value) => setState(() => _filters.cleanlinessLevel = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Social Habits',
                            value: _filters.socialHabits,
                            items: _socialHabitsOptions,
                            onChanged: (value) => setState(() => _filters.socialHabits = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Noise Level',
                            value: _filters.noiseLevel,
                            items: _noiseLevels,
                            onChanged: (value) => setState(() => _filters.noiseLevel = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Smoking Habits',
                            value: _filters.smokingHabit,
                            items: _smokingHabitsOptions,
                            onChanged: (value) => setState(() => _filters.smokingHabit = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Drinking Habits',
                            value: _filters.drinkingHabit,
                            items: _drinkingHabitsOptions,
                            onChanged: (value) => setState(() => _filters.drinkingHabit = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Food Preference',
                            value: _filters.foodPreference,
                            items: _foodPreferences,
                            onChanged: (value) => setState(() => _filters.foodPreference = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Pet Ownership',
                            value: _filters.petOwnership,
                            items: _petOwnershipOptions,
                            onChanged: (value) => setState(() => _filters.petOwnership = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Pet Tolerance',
                            value: _filters.petTolerance,
                            items: _petToleranceOptions,
                            onChanged: (value) => setState(() => _filters.petTolerance = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Work Schedule',
                            value: _filters.workSchedule,
                            items: _workScheduleOptions,
                            onChanged: (value) => setState(() => _filters.workSchedule = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Sleeping Schedule',
                            value: _filters.sleepingSchedule,
                            items: _sleepingScheduleOptions,
                            onChanged: (value) => setState(() => _filters.sleepingSchedule = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Visitors Policy',
                            value: _filters.visitorsPolicy,
                            items: _visitorsPolicyOptions,
                            onChanged: (value) => setState(() => _filters.visitorsPolicy = value == 'Any' ? null : value),
                          ),
                          _buildDropdownFilter(
                            label: 'Guests Overnight Policy',
                            value: _filters.guestsOvernightPolicy,
                            items: _guestsOvernightPolicyOptions,
                            onChanged: (value) => setState(() => _filters.guestsOvernightPolicy = value == 'Any' ? null : value),
                          ),
                          _FilterChipGroup(
                            title: 'Ideal Qualities',
                            availableItems: _commonQualities,
                            selectedItems: _filters.selectedIdealQualities,
                            onSelectionChanged: (selected) => setState(() => _filters.selectedIdealQualities = selected),
                          ),
                          _FilterChipGroup(
                            title: 'Deal Breakers',
                            availableItems: _commonDealBreakers,
                            selectedItems: _filters.selectedDealBreakers,
                            onSelectionChanged: (selected) => setState(() => _filters.selectedDealBreakers = selected),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Apply Filters Button (outside TabBarView so it's always visible)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                  shadowColor: Colors.redAccent.shade200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build consistent filter sections
  Widget _buildFilterSection({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 4, // Increased elevation for a more prominent look
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // More rounded corners
      child: Padding(
        padding: const EdgeInsets.all(18.0), // Slightly more padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title),
            const SizedBox(height: 12), // Slightly more space below title
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24, // Slightly larger title font
        fontWeight: FontWeight.w700, // Bolder title
        color: Colors.redAccent,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText, {IconData? icon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: icon != null ? Icon(icon, color: Colors.redAccent.shade400) : null, // Icon color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // More rounded input borders
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5), // Slightly bolder enabled border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.5), // Prominent focused border
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), // More padding
      filled: true,
      fillColor: Colors.white, // Explicitly white fill
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(color: Colors.grey.shade700), // Label text style
      hintStyle: TextStyle(color: Colors.grey.shade400),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Increased vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: value,
            decoration: _buildInputDecoration('Select $label'),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.black87)),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.redAccent.shade400, size: 28), // Modern dropdown icon
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            dropdownColor: Colors.white,
            elevation: 2, // Add elevation to dropdown menu
            borderRadius: BorderRadius.circular(12), // Rounded corners for dropdown menu
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSliderFilter({
    required String label,
    required RangeValues currentRange,
    required ValueChanged<RangeValues> onRangeChanged,
    required double min,
    required double max,
    int divisions = 1,
    IconData? icon,
    String? prefixText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 10),
          Row(
            children: [
              if (icon != null) Icon(icon, color: Colors.redAccent.shade400),
              if (icon != null) const SizedBox(width: 10),
              SizedBox(
                width: 70, // Increased width for values
                child: Text(
                  '${prefixText ?? ''}${currentRange.start.round()}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.redAccent,
                    inactiveTrackColor: Colors.redAccent.withOpacity(0.2), // Lighter inactive track
                    thumbColor: Colors.redAccent,
                    overlayColor: Colors.redAccent.withOpacity(0.1),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0), // Slightly larger thumb
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0), // Larger overlay
                    trackHeight: 6.0, // Thicker track
                    valueIndicatorColor: Colors.redAccent.shade700,
                    valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  child: RangeSlider(
                    values: currentRange,
                    min: min,
                    max: max,
                    divisions: divisions,
                    labels: RangeLabels(
                      '${prefixText ?? ''}${currentRange.start.round()}',
                      '${prefixText ?? ''}${currentRange.end.round()}',
                    ),
                    onChanged: onRangeChanged,
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  '${prefixText ?? ''}${currentRange.end.round()}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: _buildInputDecoration(labelText, icon: icon),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        cursorColor: Colors.redAccent, // Custom cursor color
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String labelText,
    required ValueChanged<String> onChanged,
    IconData? icon,
  }) {
    return _buildTextField(
      controller: controller,
      labelText: labelText,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      icon: icon,
    );
  }

  Widget _buildDateSelection({
    required String labelText,
    required String displayDate,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12), // Apply border radius to InkWell
        child: InputDecorator(
          decoration: _buildInputDecoration(labelText, icon: Icons.calendar_today_outlined), // Outlined icon
          child: Text(
            displayDate.isNotEmpty ? displayDate : 'Select Date',
            style: TextStyle(
              color: displayDate.isNotEmpty ? Colors.black87 : Colors.grey.shade600, // Darker grey for placeholder
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChipGroup extends StatefulWidget {
  final String title;
  final List<String> availableItems;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;

  const _FilterChipGroup({
    super.key,
    required this.title,
    required this.availableItems,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  State<_FilterChipGroup> createState() => _FilterChipGroupState();
}

class _FilterChipGroupState extends State<_FilterChipGroup> {
  late List<String> _localSelectedItems;

  @override
  void initState() {
    super.initState();
    _localSelectedItems = List.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(covariant _FilterChipGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItems != oldWidget.selectedItems) {
      _localSelectedItems = List.from(widget.selectedItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Consistent padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10.0, // Increased spacing between chips
            runSpacing: 10.0,
            children: widget.availableItems.map((item) {
              final isSelected = _localSelectedItems.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _localSelectedItems.add(item);
                    } else {
                      _localSelectedItems.remove(item);
                    }
                    widget.onSelectionChanged(_localSelectedItems);
                  });
                },
                selectedColor: Colors.redAccent.withOpacity(0.2), // Lighter selected color for modern feel
                checkmarkColor: Colors.redAccent.shade700,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.redAccent.shade700 : Colors.grey.shade800, // Better contrast
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24), // More rounded chips
                  side: BorderSide(
                    color: isSelected ? Colors.redAccent.shade400 : Colors.grey.shade300, // Softer border
                    width: 1.0,
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: isSelected ? 2 : 1, // Slightly more elevation when selected
                pressElevation: 4,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}