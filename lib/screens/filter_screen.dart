// lib/screens/filter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:mytennat/screens/filter_options.dart'; // Make sure this path is correct
import 'package:intl/intl.dart'; // For date formatting

class FilterScreen extends StatefulWidget {
  final FilterOptions initialFilters;
  final bool isSeekingFlatmate; // To determine which filters to show/apply
  final ValueChanged<FilterOptions> onFiltersChanged; // <--- ADD THIS LINE
  const FilterScreen({
    super.key,
    required this.initialFilters,
    required this.isSeekingFlatmate,
    required this.onFiltersChanged, // <--- ADD THIS LINE
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterOptions _filters; // Working copy of filters

  // Text controllers for numerical inputs
  final TextEditingController _ageMinController = TextEditingController();
  final TextEditingController _ageMaxController = TextEditingController();
  final TextEditingController _rentMinController = TextEditingController();
  final TextEditingController _rentMaxController = TextEditingController();
  final TextEditingController _budgetMinController = TextEditingController();
  final TextEditingController _budgetMaxController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _desiredCityController = TextEditingController();
  final TextEditingController _areaPreferenceController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();


  // Date controllers (not actual controllers, just for display/selection)
  String _moveInDateText = '';
  String _availabilityDateText = '';

  // Dropdown options (add all possible values from your data models)
  final List<String> _genders = ['Male', 'Female', 'Other', 'Any'];
  final List<String> _flatTypes = ['1 BHK', '2 BHK', '3 BHK', 'Studio', 'Private Room', 'Shared Room', 'Villa', 'Other'];
  final List<String> _furnishedStatuses = ['Furnished', 'Semi-Furnished', 'Unfurnished'];
  final List<String> _availableForOptions = ['Male', 'Female', 'Couple', 'Family', 'Students', 'Professionals', 'Any'];

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
  // For occupation, you might have a long list or use a text field.

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


  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters.copyWith(); // Create a working copy

    // Initialize text controllers with current filter values
    _ageMinController.text = _filters.ageMin?.toString() ?? '';
    _ageMaxController.text = _filters.ageMax?.toString() ?? '';
    _rentMinController.text = _filters.rentPriceMin?.toString() ?? '';
    _rentMaxController.text = _filters.rentPriceMax?.toString() ?? '';
    _budgetMinController.text = _filters.budgetMin?.toString() ?? '';
    _budgetMaxController.text = _filters.budgetMax?.toString() ?? '';
    _bedroomsController.text = _filters.numberOfBedrooms?.toString() ?? '';
    _bathroomsController.text = _filters.numberOfBathrooms?.toString() ?? '';
    _desiredCityController.text = _filters.desiredCity ?? '';
    _areaPreferenceController.text = _filters.areaPreference ?? '';
    _occupationController.text = _filters.occupation ?? '';


    if (_filters.moveInDate != null) {
      _moveInDateText = DateFormat('dd/MM/yyyy').format(_filters.moveInDate!);
    }
    if (_filters.availabilityDate != null) {
      _availabilityDateText = DateFormat('dd/MM/yyyy').format(_filters.availabilityDate!);
    }
  }

  @override
  void dispose() {
    _ageMinController.dispose();
    _ageMaxController.dispose();
    _rentMinController.dispose();
    _rentMaxController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _desiredCityController.dispose();
    _areaPreferenceController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isMoveInDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
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
    // Parse text controller values to integers
    _filters.ageMin = int.tryParse(_ageMinController.text);
    _filters.ageMax = int.tryParse(_ageMaxController.text);
    _filters.rentPriceMin = int.tryParse(_rentMinController.text);
    _filters.rentPriceMax = int.tryParse(_rentMaxController.text);
    _filters.budgetMin = int.tryParse(_budgetMinController.text);
    _filters.budgetMax = int.tryParse(_budgetMaxController.text);
    _filters.numberOfBedrooms = int.tryParse(_bedroomsController.text);
    _filters.numberOfBathrooms = int.tryParse(_bathroomsController.text);

    // Basic validation for ranges
    if (_filters.ageMin != null && _filters.ageMax != null && _filters.ageMin! > _filters.ageMax!) {
      _showErrorSnackBar("Minimum age cannot be greater than maximum age.");
      return;
    }
    if (_filters.rentPriceMin != null && _filters.rentPriceMax != null && _filters.rentPriceMin! > _filters.rentPriceMax!) {
      _showErrorSnackBar("Minimum rent cannot be greater than maximum rent.");
      return;
    }
    if (_filters.budgetMin != null && _filters.budgetMax != null && _filters.budgetMin! > _filters.budgetMax!) {
      _showErrorSnackBar("Minimum budget cannot be greater than maximum budget.");
      return;
    }
    widget.onFiltersChanged(_filters); // <--- REPLACE 'Navigator.pop' WITH THIS LINE
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _ageMinController.clear();
      _ageMaxController.clear();
      _rentMinController.clear();
      _rentMaxController.clear();
      _budgetMinController.clear();
      _budgetMaxController.clear();
      _bedroomsController.clear();
      _bathroomsController.clear();
      _desiredCityController.clear();
      _areaPreferenceController.clear();
      _occupationController.clear();
      _moveInDateText = '';
      _availabilityDateText = '';
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Location & Price'),
            _buildTextField(
              controller: _desiredCityController,
              labelText: 'Desired City',
              onChanged: (value) => _filters.desiredCity = value,
            ),
            _buildTextField(
              controller: _areaPreferenceController,
              labelText: 'Area Preference',
              onChanged: (value) => _filters.areaPreference = value,
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
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: widget.isSeekingFlatmate ? _budgetMinController : _rentMinController,
                    labelText: widget.isSeekingFlatmate ? 'Min Budget' : 'Min Rent',
                    onChanged: (value) => widget.isSeekingFlatmate
                        ? _filters.budgetMin = int.tryParse(value)
                        : _filters.rentPriceMin = int.tryParse(value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    controller: widget.isSeekingFlatmate ? _budgetMaxController : _rentMaxController,
                    labelText: widget.isSeekingFlatmate ? 'Max Budget' : 'Max Rent',
                    onChanged: (value) => widget.isSeekingFlatmate
                        ? _filters.budgetMax = int.tryParse(value)
                        : _filters.rentPriceMax = int.tryParse(value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (widget.isSeekingFlatmate) ...[ // This section was already present, just re-arranged
              _buildSectionTitle('Flat Requirements'),
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
                      onChanged: (value) => _filters.numberOfBedrooms = int.tryParse(value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      controller: _bathroomsController,
                      labelText: 'Bathrooms',
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
              const SizedBox(height: 24),
            ],

            _buildSectionTitle('General Preferences'), // Renamed from "General Preferences" to match new structure
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
            _buildRangeInputFilter(
              label: 'Age Range',
              minController: _ageMinController,
              maxController: _ageMaxController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(
              controller: _occupationController,
              labelText: 'Occupation',
              onChanged: (value) => _filters.occupation = value,
            ),

            const SizedBox(height: 20),

            _buildSectionTitle('Lifestyle & Habits'),
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
            const SizedBox(height: 24),
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
            const SizedBox(height: 50), // Extra space for scroll
            Center(
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            hint: Text('Select $label'),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildRangeInputFilter({
    required String label,
    required TextEditingController minController,
    required TextEditingController maxController,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minController,
                  keyboardType: keyboardType,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Min',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: maxController,
                  keyboardType: keyboardType,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Max',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String labelText,
    required ValueChanged<String> onChanged,
  }) {
    return _buildTextField(
      controller: controller,
      labelText: labelText,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildDateSelection({
    required String labelText,
    required String displayDate,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            displayDate.isNotEmpty ? displayDate : 'Select Date',
            style: TextStyle(
              color: displayDate.isNotEmpty ? Colors.black : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

// Re-using the _FilterChipGroup you likely already have from your filter_screen.dart
// Ensure this class is defined in your project, e.g., at the bottom of filter_screen.dart
// or in a separate file if you prefer.
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
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
                    widget.onSelectionChanged(_localSelectedItems); // Notify parent of change
                  });
                },
                selectedColor: Colors.redAccent.withOpacity(0.3),
                checkmarkColor: Colors.redAccent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.redAccent.shade700 : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? Colors.redAccent : Colors.grey.shade400,
                    width: 1.0,
                  ),
                ),
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}