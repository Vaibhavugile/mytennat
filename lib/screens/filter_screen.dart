// lib/screens/filter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:mytennat/screens/filter_options.dart'; // Make sure this path is correct
import 'package:intl/intl.dart'; // For date formatting

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

class _FilterScreenState extends State<FilterScreen> {
  late FilterOptions _filters; // Working copy of filters

  // Text controllers for numerical inputs (kept for non-slider inputs)
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _desiredCityController = TextEditingController();
  final TextEditingController _areaPreferenceController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();

  // RangeValues for sliders
  late RangeValues _ageRange;
  late RangeValues _rentRange;
  late RangeValues _budgetRange;


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
    _bedroomsController.text = _filters.numberOfBedrooms?.toString() ?? '';
    _bathroomsController.text = _filters.numberOfBathrooms?.toString() ?? '';
    _desiredCityController.text = _filters.desiredCity ?? '';
    _areaPreferenceController.text = _filters.areaPreference ?? '';
    _occupationController.text = _filters.occupation ?? '';

    // Initialize RangeValues based on initial filters or default values
    _ageRange = RangeValues(
      _filters.ageMin?.toDouble() ?? 18,
      _filters.ageMax?.toDouble() ?? 60,
    );
    _rentRange = RangeValues(
      _filters.rentPriceMin?.toDouble() ?? 0,
      _filters.rentPriceMax?.toDouble() ?? 50000, // Adjust max as per your data
    );
    _budgetRange = RangeValues(
      _filters.budgetMin?.toDouble() ?? 0,
      _filters.budgetMax?.toDouble() ?? 50000, // Adjust max as per your data
    );


    if (_filters.moveInDate != null) {
      _moveInDateText = DateFormat('dd/MM/yyyy').format(_filters.moveInDate!);
    }
    if (_filters.availabilityDate != null) {
      _availabilityDateText = DateFormat('dd/MM/yyyy').format(_filters.availabilityDate!);
    }
  }

  @override
  void dispose() {
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
    // Parse text controller values to integers (only for non-slider inputs)
    _filters.numberOfBedrooms = int.tryParse(_bedroomsController.text);
    _filters.numberOfBathrooms = int.tryParse(_bathroomsController.text);

    // Range slider values are already updated in setState in _buildRangeSliderFilter
    // No need for validation here as RangeSlider inherently handles min/max

    widget.onFiltersChanged(_filters);
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _bedroomsController.clear();
      _bathroomsController.clear();
      _desiredCityController.clear();
      _areaPreferenceController.clear();
      _occupationController.clear();
      _moveInDateText = '';
      _availabilityDateText = '';

      // Reset RangeSliders to default values
      _ageRange = const RangeValues(18, 60);
      _rentRange = const RangeValues(0, 50000);
      _budgetRange = const RangeValues(0, 50000);
    });
    // Notify the parent that filters have been cleared
    widget.onFiltersChanged(_filters);
  }

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
            // Location & Price Section
            _buildFilterSection(
              title: 'Location & Price',
              children: [
                _buildTextField(
                  controller: _desiredCityController,
                  labelText: 'Desired City',
                  icon: Icons.location_city,
                  onChanged: (value) => _filters.desiredCity = value,
                ),
                _buildTextField(
                  controller: _areaPreferenceController,
                  labelText: 'Area Preference',
                  icon: Icons.map,
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
                  max: 100000, // Max value for rent/budget
                  divisions: 20, // Adjust divisions for desired step (e.g., 100000 / 20 = 5000 steps)
                  icon: Icons.attach_money,
                  prefixText: '₹',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Flat Requirements Section (conditionally shown)
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
                  max: 80, // Max age
                  divisions: 62, // (80 - 18) for single year increments
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
                  shadowColor: Colors.redAccent.shade200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent filter sections
  Widget _buildFilterSection({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title),
            const SizedBox(height: 10),
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
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.redAccent,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText, {IconData? icon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.grey[50],
      floatingLabelBehavior: FloatingLabelBehavior.auto,
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
            decoration: _buildInputDecoration('Select $label'),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            // The icon for dropdown
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            dropdownColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // UPDATED: This widget now uses RangeSlider with improved styling
  Widget _buildRangeSliderFilter({
    required String label,
    required RangeValues currentRange,
    required ValueChanged<RangeValues> onRangeChanged,
    required double min,
    required double max,
    int divisions = 1, // Default to 1 division if not specified
    IconData? icon,
    String? prefixText, // e.g., '₹' for currency
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
              if (icon != null) Icon(icon, color: Colors.grey[600]),
              if (icon != null) const SizedBox(width: 8),
              SizedBox(
                width: 60, // Fixed width for min value to prevent jumpiness
                child: Text(
                  '${prefixText ?? ''}${currentRange.start.round()}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.right, // Align text to right
                ),
              ),
              Expanded(
                child: SliderTheme( // Use SliderTheme to customize thumb and track
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.redAccent,
                    inactiveTrackColor: Colors.redAccent.withOpacity(0.3),
                    thumbColor: Colors.redAccent,
                    overlayColor: Colors.redAccent.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                    trackHeight: 4.0, // Thicker track
                    valueIndicatorColor: Colors.redAccent.shade700,
                    valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
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
                width: 60, // Fixed width for max value
                child: Text(
                  '${prefixText ?? ''}${currentRange.end.round()}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.left, // Align text to left
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
    IconData? icon, // Added icon parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: _buildInputDecoration(labelText, icon: icon),
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
    IconData? icon, // Added icon parameter
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: _buildInputDecoration(labelText, icon: Icons.calendar_today),
          child: Text(
            displayDate.isNotEmpty ? displayDate : 'Select Date',
            style: TextStyle(
              color: displayDate.isNotEmpty ? Colors.black87 : Colors.grey[700],
              fontSize: 16,
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
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
                checkmarkColor: Colors.redAccent.shade700,
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
                elevation: 1, // Add a subtle elevation
                pressElevation: 3, // Elevation when pressed
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}