// lib/screens/matching_screen.dart (or a separate filter_options.dart file)

class FilterOptions {
  // Location & Price Filters
  String? desiredCity;
  String? areaPreference; // NEW: For area preference
  DateTime? moveInDate; // NEW: For seeker's move-in date
  DateTime? availabilityDate; // NEW: For listing's availability date

  // Common filters (for age, gender that apply to the *other* user)
  int? ageMin;
  int? ageMax;
  String? gender; // Gender of the *other* user you are looking for

  // FlatListing specific filters (when a seeker is searching for a flat)
  int? rentPriceMin;
  int? rentPriceMax;
  String? flatType;
  String? furnishedStatus;
  int? numberOfBedrooms; // NEW: Number of bedrooms
  int? numberOfBathrooms; // NEW: Number of bathrooms
  List<String> amenitiesDesired;
  String? availableFor; // NEW: Who the flat is available for (male, female, couple, family)

  // SeekingFlatmate specific filters (when a lister is searching for a flatmate)
  int? budgetMin;
  int? budgetMax;

  // Lifestyle & Habit Filters (for mutual compatibility)
  // These are more granular and can be selected by the user in the filter screen
  // And then applied to the habits/preferences of the *other* profile.
  String? cleanlinessLevel; // NEW: e.g., 'Very Clean', 'Moderately Clean'
  String? socialHabits; // NEW: e.g., 'Very Social', 'Introvert'
  // String? noiseLevel; // NEW: e.g., 'Quiet', 'Moderate'
  String? smokingHabit; // NEW: e.g., 'Non-Smoker', 'Social Smoker'
  String? drinkingHabit; // NEW: e.g., 'Non-Drinker', 'Social Drinker'
  String? foodPreference; // NEW: e.g., 'Vegetarian', 'Non-Vegetarian'
  String? petOwnership; // NEW: e.g., 'Has Pets', 'No Pets'
  String? petTolerance; // NEW: e.g., 'Pet-Friendly', 'Not Pet-Friendly'
  // String? workSchedule; // NEW: e.g., '9-5', 'Flexible'
  // String? sleepingSchedule; // NEW: e.g., 'Early Riser', 'Night Owl'
  // String? visitorsPolicy; // NEW: e.g., 'Guests Welcome', 'Occasional Guests'
  // String? guestsOvernightPolicy; // NEW: e.g., 'Allowed', 'Not Allowed'
  String? occupation; // NEW: for matching occupation directly

  // Keep these generic lists for other preferences if needed, but for direct Firestore queries,
  // granular fields are often easier to manage.
  List<String> selectedIdealQualities;
  List<String> selectedDealBreakers;


  FilterOptions({
    this.desiredCity,
    this.areaPreference, // NEW
    this.moveInDate,     // NEW
    this.availabilityDate, // NEW
    this.ageMin,
    this.ageMax,
    this.gender,
    this.rentPriceMin,
    this.rentPriceMax,
    this.flatType,
    this.furnishedStatus,
    this.numberOfBedrooms,   // NEW
    this.numberOfBathrooms,  // NEW
    List<String>? amenitiesDesired,
    this.availableFor,       // NEW
    this.budgetMin,
    this.budgetMax,
    this.cleanlinessLevel,   // NEW
    this.socialHabits,       // NEW
          // NEW
    this.smokingHabit,       // NEW
    this.drinkingHabit,      // NEW
    this.foodPreference,     // NEW
    this.petOwnership,       // NEW
    this.petTolerance,       // NEW
          // NEW
       // NEW
     // NEW
    this.occupation,         // NEW
    List<String>? selectedIdealQualities,
    List<String>? selectedDealBreakers,
  })  : amenitiesDesired = amenitiesDesired ?? [],
        selectedIdealQualities = selectedIdealQualities ?? [],
        selectedDealBreakers = selectedDealBreakers ?? [];

  bool hasFilters() {
    return desiredCity != null ||
        areaPreference != null || // NEW
        moveInDate != null ||     // NEW
        availabilityDate != null || // NEW
        ageMin != null ||
        ageMax != null ||
        gender != null ||
        rentPriceMin != null ||
        rentPriceMax != null ||
        flatType != null ||
        furnishedStatus != null ||
        numberOfBedrooms != null || // NEW
        numberOfBathrooms != null || // NEW
        amenitiesDesired.isNotEmpty ||
        availableFor != null ||    // NEW
        budgetMin != null ||
        budgetMax != null ||
        cleanlinessLevel != null || // NEW
        socialHabits != null ||     // NEW
          // NEW
        smokingHabit != null ||     // NEW
        drinkingHabit != null ||    // NEW
        foodPreference != null ||   // NEW
        petOwnership != null ||     // NEW
        petTolerance != null ||     // NEW

        occupation != null ||       // NEW
        selectedIdealQualities.isNotEmpty ||
        selectedDealBreakers.isNotEmpty;
  }

  void clear() {
    desiredCity = null;
    areaPreference = null; // NEW
    moveInDate = null;     // NEW
    availabilityDate = null; // NEW
    ageMin = null;
    ageMax = null;
    gender = null;
    rentPriceMin = null;
    rentPriceMax = null;
    flatType = null;
    furnishedStatus = null;
    numberOfBedrooms = null;   // NEW
    numberOfBathrooms = null;  // NEW
    amenitiesDesired.clear();
    availableFor = null;       // NEW
    budgetMin = null;
    budgetMax = null;
    cleanlinessLevel = null;   // NEW
    socialHabits = null;       // NEW
          // NEW
    smokingHabit = null;       // NEW
    drinkingHabit = null;      // NEW
    foodPreference = null;     // NEW
    petOwnership = null;       // NEW
    petTolerance = null;       // NEW

    occupation = null;         // NEW
    selectedIdealQualities.clear();
    selectedDealBreakers.clear();
  }

  FilterOptions copyWith({
    String? desiredCity,
    String? areaPreference, // NEW
    DateTime? moveInDate,     // NEW
    DateTime? availabilityDate, // NEW
    int? ageMin,
    int? ageMax,
    String? gender,
    List<String>? selectedHabits, // REMOVED from specific fields, keep if you plan to use a generic list
    List<String>? selectedIdealQualities,
    List<String>? selectedDealBreakers,
    int? rentPriceMin,
    int? rentPriceMax,
    String? flatType,
    String? furnishedStatus,
    int? numberOfBedrooms,   // NEW
    int? numberOfBathrooms,  // NEW
    List<String>? amenitiesDesired,
    String? availableFor,       // NEW
    int? budgetMin,
    int? budgetMax,
    String? preferredFlatmateGender, // REMOVED (will use gender directly now)
    String? preferredFlatmateAge,    // REMOVED (will use ageMin/Max)
    String? preferredOccupation,     // REMOVED (will use occupation directly now)
    String? cleanlinessLevel,   // NEW
    String? socialHabits,       // NEW
    String? noiseLevel,         // NEW
    String? smokingHabit,       // NEW
    String? drinkingHabit,      // NEW
    String? foodPreference,     // NEW
    String? petOwnership,       // NEW
    String? petTolerance,       // NEW
    String? workSchedule,       // NEW
    String? sleepingSchedule,   // NEW
    String? visitorsPolicy,     // NEW
    String? guestsOvernightPolicy, // NEW
    String? occupation,         // NEW
  }) {
    return FilterOptions(
      desiredCity: desiredCity ?? this.desiredCity,
      areaPreference: areaPreference ?? this.areaPreference, // NEW
      moveInDate: moveInDate ?? this.moveInDate,           // NEW
      availabilityDate: availabilityDate ?? this.availabilityDate, // NEW
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      gender: gender ?? this.gender,
      selectedIdealQualities: selectedIdealQualities ?? List.from(this.selectedIdealQualities),
      selectedDealBreakers: selectedDealBreakers ?? List.from(this.selectedDealBreakers),
      rentPriceMin: rentPriceMin ?? this.rentPriceMin,
      rentPriceMax: rentPriceMax ?? this.rentPriceMax,
      flatType: flatType ?? this.flatType,
      furnishedStatus: furnishedStatus ?? this.furnishedStatus,
      numberOfBedrooms: numberOfBedrooms ?? this.numberOfBedrooms,   // NEW
      numberOfBathrooms: numberOfBathrooms ?? this.numberOfBathrooms,  // NEW
      amenitiesDesired: amenitiesDesired ?? List.from(this.amenitiesDesired),
      availableFor: availableFor ?? this.availableFor,       // NEW
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      cleanlinessLevel: cleanlinessLevel ?? this.cleanlinessLevel,   // NEW
      socialHabits: socialHabits ?? this.socialHabits,       // NEW

      smokingHabit: smokingHabit ?? this.smokingHabit,       // NEW
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,      // NEW
      foodPreference: foodPreference ?? this.foodPreference,     // NEW
      petOwnership: petOwnership ?? this.petOwnership,       // NEW
      petTolerance: petTolerance ?? this.petTolerance,       // NEW
      occupation: occupation ?? this.occupation,         // NEW
    );
  }
}