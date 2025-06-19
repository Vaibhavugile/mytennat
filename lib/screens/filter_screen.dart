// lib/screens/filter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:mytennat/screens/matching_screen.dart'; // Import _FilterOptions class

class FilterScreen extends StatefulWidget {
  final FilterOptions initialFilters;
  final bool isSeekingFlatmate; // To determine which filters to show/apply

  const FilterScreen({
    super.key,
    required this.initialFilters,
    required this.isSeekingFlatmate,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterOptions _filters; // Working copy of filters
  final TextEditingController _ageMinController = TextEditingController();
  final TextEditingController _ageMaxController = TextEditingController();
  final TextEditingController _rentMinController = TextEditingController();
  final TextEditingController _rentMaxController = TextEditingController();
  final TextEditingController _budgetMinController = TextEditingController();
  final TextEditingController _budgetMaxController = TextEditingController();

  final List<String> _commonHabits = [
    'Non-Smoker', 'Social Drinker', 'Vegetarian', 'Non-Vegetarian',
    'Early Riser', 'Night Owl', 'Quiet', 'Lively',
    // Add more common habits as defined in your profile models
  ];

  final List<String> _commonQualities = [
    'Organized', 'Responsible', 'Friendly', 'Respectful',
    'Good Communicator', 'Clean', 'Easygoing', 'Independent',
    // Add more qualities
  ];

  final List<String> _commonDealBreakers = [
    'Smoking Indoors', 'Excessive Noise', 'Untidiness', 'Frequent Parties',
    'Undeclared Guests', 'Pets (if not allowed)',
    // Add more deal breakers
  ];

  final List<String> _genders = ['Male', 'Female', 'Other', 'Any'];
  final List<String> _flatTypes = ['1 BHK', '2 BHK', '3 BHK', 'Studio', 'Shared Room', 'Other'];
  final List<String> _furnishedStatuses = ['Furnished', 'Semi-Furnished', 'Unfurnished'];
  final List<String> _amenities = [
    'AC', 'Geyser', 'Washing Machine', 'Refrigerator', 'RO Water', 'Wi-Fi',
    'Parking', 'Security', 'Lift', 'Gym', 'Swimming Pool', 'Clubhouse',
    'Power Backup', 'Gas Pipeline', 'Modular Kitchen', 'Wardrobe',
    // Add more amenities
  ];


  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters.copyWith(); // Create a mutable copy

    // Populate text controllers from initial filters
    if (_filters.ageMin != null) _ageMinController.text = _filters.ageMin.toString();
    if (_filters.ageMax != null) _ageMaxController.text = _filters.ageMax.toString();
    if (_filters.rentPriceMin != null) _rentMinController.text = _filters.rentPriceMin.toString();
    if (_filters.rentPriceMax != null) _rentMaxController.text = _filters.rentPriceMax.toString();
    if (_filters.budgetMin != null) _budgetMinController.text = _filters.budgetMin.toString();
    if (_filters.budgetMax != null) _budgetMaxController.text = _filters.budgetMax.toString();
  }

  @override
  void dispose() {
    _ageMinController.dispose();
    _ageMaxController.dispose();
    _rentMinController.dispose();
    _rentMaxController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    // Parse numeric inputs
    _filters.ageMin = int.tryParse(_ageMinController.text);
    _filters.ageMax = int.tryParse(_ageMaxController.text);
    _filters.rentPriceMin = int.tryParse(_rentMinController.text);
    _filters.rentPriceMax = int.tryParse(_rentMaxController.text);
    _filters.budgetMin = int.tryParse(_budgetMinController.text);
    _filters.budgetMax = int.tryParse(_budgetMaxController.text);

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

    Navigator.pop(context, _filters); // Return the updated filters
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
    });
    // Optionally pop immediately if clear means no filters applied
    // Navigator.pop(context, _filters);
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
            _buildSectionTitle('General Preferences'),
            _buildDropdownFilter(
              label: 'Desired City',
              value: _filters.desiredCity,
              items: ['Pune', 'Mumbai', 'Bangalore', 'Delhi', 'Chennai', 'Hyderabad'], // Example cities
              onChanged: (String? newValue) {
                setState(() {
                  _filters.desiredCity = newValue;
                });
              },
            ),
            _buildRangeInputFilter(
              label: 'Age Range',
              minController: _ageMinController,
              maxController: _ageMaxController,
              keyboardType: TextInputType.number,
            ),
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
            const SizedBox(height: 20),

            _buildSectionTitle('Habits & Lifestyle'),
            _buildMultiSelectChipFilter(
              label: 'Preferred Habits',
              availableItems: _commonHabits,
              selectedItems: _filters.selectedHabits,
              onSelectionChanged: (List<String> newSelection) {
                setState(() {
                  _filters.selectedHabits = newSelection;
                });
              },
            ),
            _buildMultiSelectChipFilter(
              label: 'Ideal Qualities',
              availableItems: _commonQualities,
              selectedItems: _filters.selectedIdealQualities,
              onSelectionChanged: (List<String> newSelection) {
                setState(() {
                  _filters.selectedIdealQualities = newSelection;
                });
              },
            ),
            _buildMultiSelectChipFilter(
              label: 'Deal Breakers',
              availableItems: _commonDealBreakers,
              selectedItems: _filters.selectedDealBreakers,
              onSelectionChanged: (List<String> newSelection) {
                setState(() {
                  _filters.selectedDealBreakers = newSelection;
                });
              },
            ),
            const SizedBox(height: 20),

            // Flat Listing Specific Filters (if current user is seeking_flatmate)
            if (widget.isSeekingFlatmate) ...[
              _buildSectionTitle('Flat Requirements'),
              _buildRangeInputFilter(
                label: 'Rent Price Range (₹)',
                minController: _rentMinController,
                maxController: _rentMaxController,
                keyboardType: TextInputType.number,
              ),
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
              _buildMultiSelectChipFilter(
                label: 'Desired Amenities',
                availableItems: _amenities,
                selectedItems: _filters.amenitiesDesired,
                onSelectionChanged: (List<String> newSelection) {
                  setState(() {
                    _filters.amenitiesDesired = newSelection;
                  });
                },
              ),
              const SizedBox(height: 20),
            ],

            // Seeking Flatmate Specific Filters (if current user is flat_listing)
            if (!widget.isSeekingFlatmate) ...[
              _buildSectionTitle('Flatmate\'s Budget'),
              _buildRangeInputFilter(
                label: 'Flatmate Budget Range (₹)',
                minController: _budgetMinController,
                maxController: _budgetMaxController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
            ],

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

  Widget _buildMultiSelectChipFilter({
    required String label,
    required List<String> availableItems,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onSelectionChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: availableItems.map((item) {
              final isSelected = selectedItems.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      selectedItems.add(item);
                    } else {
                      selectedItems.remove(item);
                    }
                    onSelectionChanged(selectedItems); // Notify parent of change
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