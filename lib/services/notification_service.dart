// services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  Stream<int> get unreadMatchesCountStream {
    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      return Stream.value(0); // No user, no unread matches
    }

    // Listen to matches where current user is a participant and has unread status
    return _firestore
        .collection('matches')
        .where('participants', arrayContains: _currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('readBy') && data['readBy'] is Map) {
          final Map<String, dynamic> readBy = Map<String, dynamic>.from(data['readBy']);
          if (readBy[_currentUser!.uid] == false) {
            unreadCount++;
          }
        }
      }
      return unreadCount;
    });
  }

  // Method to mark a match as read
  Future<void> markMatchAsRead(String matchId) async {
    _currentUser = _auth.currentUser;
    if (_currentUser == null) return;

    // Update the specific user's read status for this match
    await _firestore.collection('matches').doc(matchId).update({
      'readBy.${_currentUser!.uid}': true,
    });
  }
}


// double _calculateMatchPercentage(dynamic userProfile, dynamic otherProfile) {
//   if (userProfile == null || otherProfile == null) return 0.0;
//
//   double score = 0;
//   double maxScore = 0;
//
//   // --- Weights for different categories (adjust as needed) ---
//   const double basicInfoWeight = 0.2;
//   const double habitsWeight = 0.4;
//   const double requirementsPreferencesWeight = 0.4;
//
//   if (userProfile is SeekingFlatmateProfile && otherProfile is FlatListingProfile) {
//     // --- Basic Info Comparison ---
//     // Max score for basic info (5 attributes * 1 point each)
//     maxScore += 5 * basicInfoWeight; // Total for basic info
//
//     // Desired City
//     if (userProfile.desiredCity.toLowerCase() == otherProfile.desiredCity.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//     // Area Preference
//     if (userProfile.areaPreference.toLowerCase() == otherProfile.areaPreference.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//     // Gender
//     if (userProfile.gender.toLowerCase() == otherProfile.ownerGender.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//
//     // Age compatibility (e.g., if other user's age is within preferred range)
//     if (userProfile.preferredFlatmateAge.isNotEmpty && otherProfile.ownerAge != null) {
//       if (userProfile.preferredFlatmateAge.contains('-')) {
//         final parts = userProfile.preferredFlatmateAge.split('-');
//         if (parts.length == 2) {
//           final minAge = int.tryParse(parts[0].trim());
//           final maxAge = int.tryParse(parts[1].trim());
//           if (minAge != null && maxAge != null && otherProfile.ownerAge! >= minAge && otherProfile.ownerAge! <= maxAge) {
//             score += 1 * basicInfoWeight;
//           }
//         }
//       } else if (userProfile.preferredFlatmateAge.toLowerCase() == 'any') {
//         score += 1 * basicInfoWeight; // Considered a match if 'any'
//       }
//     }
//
//     // Occupation Match (simple match for now)
//     if (userProfile.preferredOccupation.toLowerCase() == otherProfile.ownerOccupation.toLowerCase() && userProfile.preferredOccupation.isNotEmpty) {
//       score += 1 * basicInfoWeight;
//     }
//
//     // --- Habits Comparison (more nuanced) ---
//     // NO fixed maxScore for habits here. Each habit adds its max potential.
//
//     // Smoking
//     maxScore += 2 * habitsWeight; // Max score for smoking
//     final userSmokes = userProfile.smokingHabits.toLowerCase();
//     final otherSmokes = otherProfile.smokingHabit.toLowerCase();
//
//     if (
//     (userSmokes == 'never' && otherSmokes == 'never') ||
//         (userSmokes == 'occasionally' && (otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
//         (userSmokes == 'socially' && (otherSmokes == 'socially' || otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
//         (userSmokes == 'regularly' && otherSmokes == 'regularly') ||
//         (userSmokes == 'tolerates' && (otherSmokes == 'occasionally' || otherSmokes == 'socially' || otherSmokes == 'regularly'))
//     ) {
//       score += 2 * habitsWeight;
//     }
//
//     // Drinking
//     maxScore += 2 * habitsWeight; // Max score for drinking
//     final userDrinksPref = userProfile.drinkingHabits.toLowerCase();
//     final otherDrinksActual = otherProfile.drinkingHabit.toLowerCase();
//
//     if (
//     (userDrinksPref == 'never' && otherDrinksActual == 'never') ||
//         (userDrinksPref == 'occasionally' && (otherDrinksActual == 'occasionally' || otherDrinksActual == 'never')) ||
//         (userDrinksPref == 'socially' && (otherDrinksActual == 'socially' || otherDrinksActual == 'occasionally' || otherDrinksActual == 'never')) ||
//         (userDrinksPref == 'regularly' && otherDrinksActual == 'regularly') ||
//         (userDrinksPref == 'tolerates' && (otherDrinksActual == 'occasionally' || otherDrinksActual == 'socially' || otherDrinksActual == 'regularly'))
//     ) {
//       score += 2 * habitsWeight;
//     }
//
//     // Food Preference
//     maxScore += 1 * habitsWeight; // Max score for food preference
//     final userFood = userProfile.foodPreference.toLowerCase();
//     final otherFood = otherProfile.foodPreference.toLowerCase();
//
//     if (userFood == otherFood) {
//       score += 1 * habitsWeight;
//     } else if (
//     (userFood == 'vegan' && (otherFood == 'vegetarian' || otherFood == 'eggetarian' || otherFood == 'jain')) ||
//         (otherFood == 'vegan' && (userFood == 'vegetarian' || userFood == 'eggetarian' || userFood == 'jain'))
//     ) {
//       score += 0.75 * habitsWeight;
//     } else if (
//     (userFood == 'vegetarian' && (otherFood == 'eggetarian' || otherFood == 'jain')) ||
//         (otherFood == 'vegetarian' && (userFood == 'eggetarian' || userFood == 'jain'))
//     ) {
//       score += 0.75 * habitsWeight;
//     } else if (
//     (userFood == 'eggetarian' && (otherFood == 'vegetarian' || otherFood == 'jain')) ||
//         (otherFood == 'eggetarian' && (userFood == 'vegetarian' || userFood == 'jain'))
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userFood == 'jain' && (otherFood == 'vegetarian' || otherFood == 'vegan' || otherFood == 'eggetarian')) ||
//         (otherFood == 'jain' && (userFood == 'vegetarian' || userFood == 'vegan' || userFood == 'eggetarian'))
//     ) {
//       score += 0.75 * habitsWeight;
//     } else if ((userFood == 'other' || otherFood == 'other')) {
//       score += 0.2 * habitsWeight;
//     }
//
//     // Cleanliness
//     maxScore += 2 * habitsWeight; // Max score for cleanliness
//     final userCleanliness = userProfile.cleanliness.toLowerCase();
//     final otherCleanliness = otherProfile.cleanlinessLevel.toLowerCase();
//
//     if (userCleanliness == otherCleanliness) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userCleanliness == 'very tidy' && otherCleanliness == 'moderately tidy') ||
//         (otherCleanliness == 'very tidy' && userCleanliness == 'moderately tidy')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userCleanliness == 'moderately tidy' && otherCleanliness == 'flexible') ||
//         (otherCleanliness == 'moderately tidy' && userCleanliness == 'flexible')
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userCleanliness == 'flexible' && otherCleanliness == 'can be messy at times') ||
//         (otherCleanliness == 'flexible' && userCleanliness == 'can be messy at times')
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userCleanliness == 'very tidy' && (otherCleanliness == 'flexible' || otherCleanliness == 'can be messy at times')) ||
//         (otherCleanliness == 'very tidy' && (userCleanliness == 'flexible' || userCleanliness == 'can be messy at times'))
//     ) {
//       score += 0.2 * habitsWeight;
//     }
//
//     // Noise Level
//     maxScore += 2 * habitsWeight; // Max score for noise level
//     final userNoise = userProfile.noiseLevel.toLowerCase();
//     final otherNoise = otherProfile.noiseLevel.toLowerCase();
//
//     if (userNoise == otherNoise) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userNoise == 'very quiet' && otherNoise == 'moderate noise') ||
//         (otherNoise == 'very quiet' && userNoise == 'moderate noise')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userNoise == 'moderate noise' && (otherNoise == 'very quiet' || otherNoise == 'lively')) ||
//         (otherNoise == 'moderate noise' && (userNoise == 'very quiet' || userNoise == 'lively'))
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userNoise == 'flexible' && (otherNoise == 'very quiet' || otherNoise == 'moderate noise' || otherNoise == 'lively')) ||
//         (otherNoise == 'flexible' && (userNoise == 'very quiet' || userNoise == 'moderate noise' || userNoise == 'lively'))
//     ) {
//       score += 1.8 * habitsWeight;
//     } else if (
//     (userNoise == 'lively' && otherNoise == 'very quiet') ||
//         (otherNoise == 'lively' && userNoise == 'very quiet')
//     ) {
//       // These are generally a bad match unless one is flexible. Score 0 here.
//     }
//
//     // Social Habits
//     maxScore += 1 * habitsWeight; // Max score for social habits
//     final userSocial = userProfile.socialHabits.toLowerCase();
//     final otherSocial = otherProfile.socialPreferences.toLowerCase();
//
//     if (userSocial == otherSocial) {
//       score += 1 * habitsWeight;
//     } else if (
//     (userSocial == 'flexible' && (otherSocial == 'social & outgoing' || otherSocial == 'occasional gatherings' || otherSocial == 'quiet & private')) ||
//         (otherSocial == 'flexible' && (userSocial == 'social & outgoing' || userSocial == 'occasional gatherings' || userSocial == 'quiet & private'))
//     ) {
//       score += 0.9 * habitsWeight;
//     } else if (
//     (userSocial == 'social & outgoing' && otherSocial == 'occasional gatherings') ||
//         (otherSocial == 'social & outgoing' && userSocial == 'occasional gatherings')
//     ) {
//       score += 0.7 * habitsWeight;
//     } else if (
//     (userSocial == 'occasional gatherings' && otherSocial == 'quiet & private') ||
//         (otherSocial == 'occasional gatherings' && userSocial == 'quiet & private')
//     ) {
//       score += 0.6 * habitsWeight;
//     } else if (
//     (userSocial == 'social & outgoing' && otherSocial == 'quiet & private') ||
//         (otherSocial == 'social & outgoing' && userSocial == 'quiet & private')
//     ) {
//       score += 0.2 * habitsWeight;
//     }
//
//     // Pet Ownership/Tolerance
//     maxScore += 2 * habitsWeight; // Max score for pet ownership/tolerance
//     final userOwns = userProfile.petOwnership.toLowerCase();
//     final otherOwns = otherProfile.petOwnership.toLowerCase();
//     final userTolerates = (userProfile.petTolerance ?? '').toLowerCase();
//     final otherTolerates = (otherProfile.petTolerance ?? '').toLowerCase();
//
//     double currentPetScore = 0;
//     if (userOwns == 'no' && otherOwns == 'no') {
//       currentPetScore = 2.0 * habitsWeight;
//     } else if (userOwns == 'yes' && otherOwns == 'yes') {
//       currentPetScore = 2.0 * habitsWeight;
//     } else if ((userOwns == 'yes' && otherTolerates == 'tolerates pets') || (otherOwns == 'yes' && userTolerates == 'tolerates pets')) {
//       currentPetScore = 2.0 * habitsWeight;
//     } else if (userOwns == 'planning to get one' && otherOwns == 'planning to get one') {
//       currentPetScore = 1.8 * habitsWeight;
//     } else if ((userOwns == 'yes' && otherOwns == 'planning to get one') || (otherOwns == 'yes' && userOwns == 'planning to get one')) {
//       currentPetScore = 1.5 * habitsWeight;
//     } else if ((userOwns == 'no' && otherOwns == 'planning to get one' && userTolerates == 'tolerates pets') || (otherOwns == 'no' && userOwns == 'planning to get one' && otherTolerates == 'tolerates pets')) {
//       currentPetScore = 1.0 * habitsWeight;
//     } else if ((userOwns == 'planning to get one' && otherTolerates == 'tolerates pets') || (otherOwns == 'planning to get one' && userTolerates == 'tolerates pets')) {
//       currentPetScore = 1.0 * habitsWeight;
//     }
//     score += currentPetScore;
//
//     // Visitors Policy
//     maxScore += 2 * habitsWeight; // Max score for visitors policy
//     final userVisitors = userProfile.visitorsPolicy.toLowerCase();
//     final otherVisitors = otherProfile.visitorsPolicy.toLowerCase();
//
//     if (userVisitors == otherVisitors) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userVisitors == 'frequent visitors' && otherVisitors == 'occasional visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'occasional visitors')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userVisitors == 'occasional visitors' && otherVisitors == 'rarely have visitors') ||
//         (otherVisitors == 'occasional visitors' && userVisitors == 'rarely have visitors')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userVisitors == 'rarely have visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'rarely have visitors' && userVisitors == 'no visitors')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userVisitors == 'occasional visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'occasional visitors' && userVisitors == 'no visitors')
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userVisitors == 'frequent visitors' && otherVisitors == 'rarely have visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'rarely have visitors')
//     ) {
//       score += 0.2 * habitsWeight;
//     } else if (
//     (userVisitors == 'frequent visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'no visitors')
//     ) {
//       // strong mismatch, 0 points
//     }
//
//     // Sleeping Schedule
//     maxScore += 2 * habitsWeight; // Max score for sleeping schedule
//     final userSchedule = userProfile.sleepingSchedule.toLowerCase();
//     final otherSchedule = otherProfile.sleepingSchedule.toLowerCase();
//
//     if (userSchedule == otherSchedule) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userSchedule == 'flexible' && (otherSchedule == 'early riser' || otherSchedule == 'night owl')) ||
//         (otherSchedule == 'flexible' && (userSchedule == 'early riser' || userSchedule == 'night owl'))
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userSchedule == 'flexible' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'flexible' && userSchedule == 'irregular')
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userSchedule == 'early riser' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'early riser' && userSchedule == 'irregular')
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userSchedule == 'night owl' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'night owl' && userSchedule == 'irregular')
//     ) {
//       score += 0.5 * habitsWeight;
//     }
//
//     // Work/Study Schedule
//     maxScore += 2 * habitsWeight; // Max score for work/study schedule
//     final userWork = userProfile.workSchedule.toLowerCase();
//     final otherWork = otherProfile.workSchedule.toLowerCase();
//
//     if (userWork == otherWork) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userWork == 'mixed' && (otherWork == 'freelance/flexible hours' || otherWork == '9-5 office hours' || otherWork == 'student schedule' || otherWork == 'night shifts')) ||
//         (otherWork == 'mixed' && (userWork == 'freelance/flexible hours' || userWork == '9-5 office hours' || userWork == 'student schedule' || userWork == 'night shifts')) ||
//         (userWork == 'freelance/flexible hours' && (otherWork == '9-5 office hours' || otherWork == 'student schedule')) ||
//         (otherWork == 'freelance/flexible hours' && (userWork == '9-5 office hours' || userWork == 'student schedule'))
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userWork == '9-5 office hours' && otherWork == 'student schedule') ||
//         (otherWork == '9-5 office hours' && userWork == 'student schedule')
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userWork == 'freelance/flexible hours' && otherWork == 'night shifts') ||
//         (otherWork == 'freelance/flexible hours' && userWork == 'night shifts')
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userWork == 'night shifts' && otherWork == 'student schedule') ||
//         (otherWork == 'night shifts' && userWork == 'student schedule')
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userWork == '9-5 office hours' && otherWork == 'night shifts') ||
//         (otherWork == '9-5 office hours' && userWork == 'night shifts')
//     ) {
//       score += 0.2 * habitsWeight;
//     }
//
//     // Sharing Habits (assuming property is `sharingCommonSpaces`)
//     maxScore += 2 * habitsWeight; // Max score for sharing habits
//     final userSharing = userProfile.sharingCommonSpaces.toLowerCase();
//     final otherSharing = otherProfile.sharingCommonSpaces.toLowerCase();
//
//     if (userSharing == otherSharing) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userSharing == 'flexible' && (otherSharing == 'share everything' || otherSharing == 'share some items' || otherSharing == 'prefer separate items')) ||
//         (otherSharing == 'flexible' && (userSharing == 'share everything' || userSharing == 'share some items' || userSharing == 'prefer separate items'))
//     ) {
//       score += 1.8 * habitsWeight;
//     } else if (
//     (userSharing == 'share everything' && otherSharing == 'share some items') ||
//         (otherSharing == 'share everything' && userSharing == 'share some items')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userSharing == 'share some items' && otherSharing == 'prefer separate items') ||
//         (otherSharing == 'share some items' && userSharing == 'prefer separate items')
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userSharing == 'share everything' && otherSharing == 'prefer separate items') ||
//         (otherSharing == 'share everything' && userSharing == 'prefer separate items')
//     ) {
//       score += 0.5 * habitsWeight;
//     }
//
//     // Guests Overnight Policy
//     maxScore += 2 * habitsWeight; // Max score for guests overnight policy
//     final userGuests = userProfile.guestsOvernightPolicy.toLowerCase();
//     final otherGuests = otherProfile.guestsOvernightPolicy.toLowerCase();
//
//     if (userGuests == otherGuests) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userGuests == 'frequently' && otherGuests == 'occasionally') ||
//         (otherGuests == 'frequently' && userGuests == 'occasionally')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userGuests == 'occasionally' && otherGuests == 'rarely') ||
//         (otherGuests == 'occasionally' && userGuests == 'rarely')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userGuests == 'rarely' && otherGuests == 'never') ||
//         (otherGuests == 'rarely' && userGuests == 'never')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userGuests == 'occasionally' && otherGuests == 'never') ||
//         (otherGuests == 'occasionally' && userGuests == 'never')
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userGuests == 'frequently' && otherGuests == 'rarely') ||
//         (otherGuests == 'frequently' && userGuests == 'rarely')
//     ) {
//       score += 0.2 * habitsWeight;
//     } else if (
//     (userGuests == 'frequently' && otherGuests == 'never') ||
//         (otherGuests == 'frequently' && userGuests == 'never')
//     ) {
//       // strong mismatch, 0 points
//     }
//
//     // Personal Space vs. Socialization
//     maxScore += 2 * habitsWeight; // Max score for personal space vs. socialization
//     final userSpaceSocial = userProfile.personalSpaceVsSocialization.toLowerCase();
//     final otherSpaceSocial = otherProfile.personalSpaceVsSocialization.toLowerCase();
//
//     if (userSpaceSocial == otherSpaceSocial) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userSpaceSocial == 'flexible' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'enjoy a balance' || otherSpaceSocial == 'prefer more socialization')) ||
//         (otherSpaceSocial == 'flexible' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'enjoy a balance' || userSpaceSocial == 'prefer more socialization'))
//     ) {
//       score += 1.8 * habitsWeight;
//     } else if (
//     (userSpaceSocial == 'enjoy a balance' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'prefer more socialization')) ||
//         (otherSpaceSocial == 'enjoy a balance' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'prefer more socialization'))
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userSpaceSocial == 'value personal space highly' && otherSpaceSocial == 'prefer more socialization') ||
//         (otherSpaceSocial == 'value personal space highly' && userSpaceSocial == 'prefer more socialization')
//     ) {
//       score += 0.2 * habitsWeight;
//     }
//
//     // --- Requirements/Preferences Comparison ---
//     // NO fixed maxScore for requirements here. Each requirement adds its max potential.
//
//     // Flat Type
//     maxScore += 1 * requirementsPreferencesWeight; // Max score for flat type
//     if (userProfile.preferredFlatType.toLowerCase() == otherProfile.flatType.toLowerCase()) {
//       score += 1 * requirementsPreferencesWeight;
//     }
//
//     // Furnished Status
//     maxScore += 1 * requirementsPreferencesWeight; // Max score for furnished status
//     if (userProfile.preferredFurnishedStatus.toLowerCase() == otherProfile.furnishedStatus.toLowerCase()) {
//       score += 1 * requirementsPreferencesWeight;
//     }
//
//     // Budget (check if otherProfile's rent is within userProfile's budget range)
//     maxScore += 2 * requirementsPreferencesWeight; // Max score for budget
//     if (userProfile.budgetMin != null && userProfile.budgetMax != null && otherProfile.rentPrice != null) {
//       if (otherProfile.rentPrice! >= userProfile.budgetMin! && otherProfile.rentPrice! <= userProfile.budgetMax!) {
//         score += 2 * requirementsPreferencesWeight;
//       }
//     }
//
//     // Amenities Desired (overlap)
//     maxScore += 2 * requirementsPreferencesWeight; // Max score for amenities
//     final amenityIntersection = userProfile.amenitiesDesired.toSet().intersection(otherProfile.amenities.toSet());
//     score += (amenityIntersection.length / (userProfile.amenitiesDesired.length > 0 ? userProfile.amenitiesDesired.length : 1)) * 2 * requirementsPreferencesWeight;
//
//     // Preferred Habits (other user's actual habits matching preferred habits)
//     maxScore += 2 * requirementsPreferencesWeight; // Max score for preferred habits
//     final preferredHabitsIntersection = userProfile.preferredHabits.toSet().intersection([
//       otherProfile.smokingHabit,
//       otherProfile.drinkingHabit,
//       otherProfile.foodPreference,
//       otherProfile.cleanlinessLevel,
//       otherProfile.noiseLevel,
//       otherProfile.socialPreferences,
//       otherProfile.visitorsPolicy,
//       otherProfile.petOwnership,
//       otherProfile.petTolerance,
//       otherProfile.sleepingSchedule,
//       otherProfile.workSchedule,
//       otherProfile.sharingCommonSpaces,
//       otherProfile.guestsOvernightPolicy,
//       otherProfile.personalSpaceVsSocialization,
//     ].map((e) => e.toLowerCase()).toSet());
//     score += (preferredHabitsIntersection.length / (userProfile.preferredHabits.length > 0 ? userProfile.preferredHabits.length : 1)) * 2 * requirementsPreferencesWeight;
//
//     // Ideal Qualities (overlap)
//     maxScore += 2 * requirementsPreferencesWeight; // Max score for ideal qualities
//     final idealQualitiesIntersection = userProfile.idealQualities.toSet().intersection(otherProfile.flatmateIdealQualities.toSet());
//     score += (idealQualitiesIntersection.length / (userProfile.idealQualities.length > 0 ? userProfile.idealQualities.length : 1)) * 2 * requirementsPreferencesWeight;
//
//     // Deal Breakers (penalty for overlap) - No maxScore addition as it's a penalty
//     final dealBreakersIntersection = userProfile.dealBreakers.toSet().intersection(otherProfile.flatmateDealBreakers.toSet());
//     score -= (dealBreakersIntersection.length * 5) * requirementsPreferencesWeight; // Penalize heavily
//
//   } else if (userProfile is FlatListingProfile && otherProfile is SeekingFlatmateProfile) {
//     // --- Basic Info Comparison ---
//     // Max score for basic info (5 attributes * 1 point each)
//     maxScore += 5 * basicInfoWeight; // Total for basic info
//
//     // Desired City
//     if (userProfile.desiredCity.toLowerCase() == otherProfile.desiredCity.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//     // Area Preference
//     if (userProfile.areaPreference.toLowerCase() == otherProfile.areaPreference.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//     // Gender
//     if (userProfile.ownerGender.toLowerCase() == otherProfile.gender.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//
//     // Age compatibility (e.g., if other user's age is within preferred range of the flat lister)
//     if (userProfile.preferredAgeGroup.isNotEmpty && otherProfile.age != null) {
//       if (userProfile.preferredAgeGroup.contains('-')) {
//         final parts = userProfile.preferredAgeGroup.split('-');
//         if (parts.length == 2) {
//           final minAge = int.tryParse(parts[0].trim());
//           final maxAge = int.tryParse(parts[1].trim());
//           if (minAge != null && maxAge != null && otherProfile.age! >= minAge && otherProfile.age! <= maxAge) {
//             score += 1 * basicInfoWeight;
//           }
//         }
//       } else if (userProfile.preferredAgeGroup.toLowerCase() == 'any') {
//         score += 1 * basicInfoWeight;
//       }
//     }
//
//     // Occupation Match
//     if (userProfile.preferredOccupation.toLowerCase() == otherProfile.occupation.toLowerCase() && userProfile.preferredOccupation.isNotEmpty) {
//       score += 1 * basicInfoWeight;
//     }
//
//     // --- Habits Comparison (more nuanced) ---
//     // NO fixed maxScore for habits here. Each habit adds its max potential.
//
//     // Smoking
//     maxScore += 2 * habitsWeight; // Max score for smoking
//     final userSmokes = userProfile.smokingHabit.toLowerCase();
//     final otherSmokes = otherProfile.smokingHabits.toLowerCase();
//
//     if (
//     (userSmokes == 'never' && otherSmokes == 'never') ||
//         (userSmokes == 'occasionally' && (otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
//         (userSmokes == 'socially' && (otherSmokes == 'socially' || otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
//         (userSmokes == 'regularly' && otherSmokes == 'regularly') ||
//         (otherSmokes == 'tolerates' && (userSmokes == 'occasionally' || userSmokes == 'socially' || userSmokes == 'regularly'))
//     ) {
//       score += 2 * habitsWeight;
//     }
//
//     // Drinking
//     maxScore += 2 * habitsWeight; // Max score for drinking
//     final userDrinksActual = userProfile.drinkingHabit.toLowerCase();
//     final otherDrinksPref = otherProfile.drinkingHabits.toLowerCase();
//
//     if (
//     (userDrinksActual == 'never' && otherDrinksPref == 'never') ||
//         (userDrinksActual == 'occasionally' && (otherDrinksPref == 'occasionally' || otherDrinksPref == 'never')) ||
//         (userDrinksActual == 'socially' && (otherDrinksPref == 'socially' || otherDrinksPref == 'occasionally' || otherDrinksPref == 'never')) ||
//         (userDrinksActual == 'regularly' && otherDrinksPref == 'regularly') ||
//         (otherDrinksPref == 'tolerates' && (userDrinksActual == 'occasionally' || userDrinksActual == 'socially' || userDrinksActual == 'regularly'))
//     ) {
//       score += 2 * habitsWeight;
//     }
//
//     // Food Preference
//     maxScore += 1 * habitsWeight; // Max score for food preference
//     final userFood = userProfile.foodPreference.toLowerCase();
//     final otherFood = otherProfile.foodPreference.toLowerCase();
//
//     if (userFood == otherFood) {
//       score += 1 * habitsWeight;
//     } else if (
//     (userFood == 'vegan' && (otherFood == 'vegetarian' || otherFood == 'eggetarian' || otherFood == 'jain')) ||
//         (otherFood == 'vegan' && (userFood == 'vegetarian' || userFood == 'eggetarian' || userFood == 'jain'))
//     ) {
//       score += 0.75 * habitsWeight;
//     } else if (
//     (userFood == 'vegetarian' && (otherFood == 'eggetarian' || otherFood == 'jain')) ||
//         (otherFood == 'vegetarian' && (userFood == 'eggetarian' || userFood == 'jain'))
//     ) {
//       score += 0.75 * habitsWeight;
//     } else if (
//     (userFood == 'eggetarian' && (otherFood == 'vegetarian' || otherFood == 'jain')) ||
//         (otherFood == 'eggetarian' && (userFood == 'vegetarian' || userFood == 'jain'))
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userFood == 'jain' && (otherFood == 'vegetarian' || otherFood == 'vegan' || otherFood == 'eggetarian')) ||
//         (otherFood == 'jain' && (userFood == 'vegetarian' || userFood == 'vegan' || userFood == 'eggetarian'))
//     ) {
//       score += 0.75 * habitsWeight;
//     } else if ((userFood == 'other' || otherFood == 'other')) {
//       score += 0.2 * habitsWeight;
//     }
//
//     // Cleanliness
//     maxScore += 2 * habitsWeight; // Max score for cleanliness
//     final userCleanliness = userProfile.cleanlinessLevel.toLowerCase();
//     final otherCleanliness = otherProfile.cleanliness.toLowerCase();
//
//     if (userCleanliness == otherCleanliness) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userCleanliness == 'very tidy' && otherCleanliness == 'moderately tidy') ||
//         (otherCleanliness == 'very tidy' && userCleanliness == 'moderately tidy')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userCleanliness == 'moderately tidy' && otherCleanliness == 'flexible') ||
//         (otherCleanliness == 'moderately tidy' && userCleanliness == 'flexible')
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userCleanliness == 'flexible' && otherCleanliness == 'can be messy at times') ||
//         (otherCleanliness == 'flexible' && userCleanliness == 'can be messy at times')
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userCleanliness == 'very tidy' && (otherCleanliness == 'flexible' || otherCleanliness == 'can be messy at times')) ||
//         (otherCleanliness == 'very tidy' && (userCleanliness == 'flexible' || userCleanliness == 'can be messy at times'))
//     ) {
//       score += 0.2 * habitsWeight;
//     }
//
//     // Noise Level
//     maxScore += 2 * habitsWeight; // Max score for noise level
//     final userNoise = userProfile.noiseLevel.toLowerCase();
//     final otherNoise = otherProfile.noiseLevel.toLowerCase();
//
//     if (userNoise == otherNoise) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userNoise == 'very quiet' && otherNoise == 'moderate noise') ||
//         (otherNoise == 'very quiet' && userNoise == 'moderate noise')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userNoise == 'moderate noise' && (otherNoise == 'very quiet' || otherNoise == 'lively')) ||
//         (otherNoise == 'moderate noise' && (userNoise == 'very quiet' || userNoise == 'lively'))
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userNoise == 'flexible' && (otherNoise == 'very quiet' || otherNoise == 'moderate noise' || otherNoise == 'lively')) ||
//         (otherNoise == 'flexible' && (userNoise == 'very quiet' || userNoise == 'moderate noise' || userNoise == 'lively'))
//     ) {
//       score += 1.8 * habitsWeight;
//     } else if (
//     (userNoise == 'lively' && otherNoise == 'very quiet') ||
//         (otherNoise == 'lively' && userNoise == 'very quiet')
//     ) {
//       // These are generally a bad match unless one is flexible. Score 0 here.
//     }
//
//     // Social Habits
//     maxScore += 1 * habitsWeight; // Max score for social habits
//     final userSocial = userProfile.socialPreferences.toLowerCase();
//     final otherSocial = otherProfile.socialHabits.toLowerCase();
//
//     if (userSocial == otherSocial) {
//       score += 1 * habitsWeight;
//     } else if (
//     (userSocial == 'flexible' && (otherSocial == 'social & outgoing' || otherSocial == 'occasional gatherings' || otherSocial == 'quiet & private')) ||
//         (otherSocial == 'flexible' && (userSocial == 'social & outgoing' || userSocial == 'occasional gatherings' || userSocial == 'quiet & private'))
//     ) {
//       score += 0.9 * habitsWeight;
//     } else if (
//     (userSocial == 'social & outgoing' && otherSocial == 'occasional gatherings') ||
//         (otherSocial == 'social & outgoing' && userSocial == 'occasional gatherings')
//     ) {
//       score += 0.7 * habitsWeight;
//     } else if (
//     (userSocial == 'occasional gatherings' && otherSocial == 'quiet & private') ||
//         (otherSocial == 'occasional gatherings' && userSocial == 'quiet & private')
//     ) {
//       score += 0.6 * habitsWeight;
//     } else if (
//     (userSocial == 'social & outgoing' && otherSocial == 'quiet & private') ||
//         (otherSocial == 'social & outgoing' && userSocial == 'quiet & private')
//     ) {
//       score += 0.2 * habitsWeight;
//     }
//
//     // Pet Ownership/Tolerance
//     maxScore += 2 * habitsWeight; // Max score for pet ownership/tolerance
//     final userOwns = userProfile.petOwnership.toLowerCase();
//     final otherOwns = otherProfile.petOwnership.toLowerCase();
//     final userTolerates = (userProfile.petTolerance ?? '').toLowerCase();
//     final otherTolerates = (otherProfile.petTolerance ?? '').toLowerCase();
//
//     double currentPetScore = 0;
//     if (userOwns == 'no' && otherOwns == 'no') {
//       currentPetScore = 2.0 * habitsWeight;
//     } else if (userOwns == 'yes' && otherOwns == 'yes') {
//       currentPetScore = 2.0 * habitsWeight;
//     } else if ((userOwns == 'yes' && otherTolerates == 'tolerates pets') || (otherOwns == 'yes' && userTolerates == 'tolerates pets')) {
//       currentPetScore = 2.0 * habitsWeight;
//     } else if (userOwns == 'planning to get one' && otherOwns == 'planning to get one') {
//       currentPetScore = 1.8 * habitsWeight;
//     } else if ((userOwns == 'yes' && otherOwns == 'planning to get one') || (otherOwns == 'yes' && userOwns == 'planning to get one')) {
//       currentPetScore = 1.5 * habitsWeight;
//     } else if ((userOwns == 'no' && otherOwns == 'planning to get one' && userTolerates == 'tolerates pets') || (otherOwns == 'no' && userOwns == 'planning to get one' && otherTolerates == 'tolerates pets')) {
//       currentPetScore = 1.0 * habitsWeight;
//     } else if ((userOwns == 'planning to get one' && otherTolerates == 'tolerates pets') || (otherOwns == 'planning to get one' && userTolerates == 'tolerates pets')) {
//       currentPetScore = 1.0 * habitsWeight;
//     }
//     score += currentPetScore;
//
//     // Visitors Policy
//     maxScore += 2 * habitsWeight; // Max score for visitors policy
//     final userVisitors = userProfile.visitorsPolicy.toLowerCase();
//     final otherVisitors = otherProfile.visitorsPolicy.toLowerCase();
//
//     if (userVisitors == otherVisitors) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userVisitors == 'frequent visitors' && otherVisitors == 'occasional visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'occasional visitors')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userVisitors == 'occasional visitors' && otherVisitors == 'rarely have visitors') ||
//         (otherVisitors == 'occasional visitors' && userVisitors == 'rarely have visitors')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userVisitors == 'rarely have visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'rarely have visitors' && userVisitors == 'no visitors')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userVisitors == 'occasional visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'occasional visitors' && userVisitors == 'no visitors')
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userVisitors == 'frequent visitors' && otherVisitors == 'rarely have visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'rarely have visitors')
//     ) {
//       score += 0.2 * habitsWeight;
//     } else if (
//     (userVisitors == 'frequent visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'no visitors')
//     ) {
//       // strong mismatch, 0 points
//     }
//
//     // Sleeping Schedule
//     maxScore += 2 * habitsWeight; // Max score for sleeping schedule
//     final userSchedule = userProfile.sleepingSchedule.toLowerCase();
//     final otherSchedule = otherProfile.sleepingSchedule.toLowerCase();
//
//     if (userSchedule == otherSchedule) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userSchedule == 'flexible' && (otherSchedule == 'early riser' || otherSchedule == 'night owl')) ||
//         (otherSchedule == 'flexible' && (userSchedule == 'early riser' || userSchedule == 'night owl'))
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userSchedule == 'flexible' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'flexible' && userSchedule == 'irregular')
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userSchedule == 'early riser' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'early riser' && userSchedule == 'irregular')
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userSchedule == 'night owl' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'night owl' && userSchedule == 'irregular')
//     ) {
//       score += 0.5 * habitsWeight;
//     }
//
//     // Work/Study Schedule
//     maxScore += 2 * habitsWeight; // Max score for work/study schedule
//     final userWork = userProfile.workSchedule.toLowerCase();
//     final otherWork = otherProfile.workSchedule.toLowerCase();
//
//     if (userWork == otherWork) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userWork == 'mixed' && (otherWork == 'freelance/flexible hours' || otherWork == '9-5 office hours' || otherWork == 'student schedule' || otherWork == 'night shifts')) ||
//         (otherWork == 'mixed' && (userWork == 'freelance/flexible hours' || userWork == '9-5 office hours' || userWork == 'student schedule' || userWork == 'night shifts')) ||
//         (userWork == 'freelance/flexible hours' && (otherWork == '9-5 office hours' || otherWork == 'student schedule')) ||
//         (otherWork == 'freelance/flexible hours' && (userWork == '9-5 office hours' || userWork == 'student schedule'))
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userWork == '9-5 office hours' && otherWork == 'student schedule') ||
//         (otherWork == '9-5 office hours' && userWork == 'student schedule')
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userWork == 'freelance/flexible hours' && otherWork == 'night shifts') ||
//         (otherWork == 'freelance/flexible hours' && userWork == 'night shifts')
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userWork == 'night shifts' && otherWork == 'student schedule') ||
//         (otherWork == 'night shifts' && userWork == 'student schedule')
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userWork == '9-5 office hours' && otherWork == 'night shifts') ||
//         (otherWork == '9-5 office hours' && userWork == 'night shifts')
//     ) {
//       score += 0.2 * habitsWeight;
//     }
//
//     // Sharing Habits (assuming property is `sharingCommonSpaces`)
//     maxScore += 2 * habitsWeight; // Max score for sharing habits
//     final userSharing = userProfile.sharingCommonSpaces.toLowerCase();
//     final otherSharing = otherProfile.sharingCommonSpaces.toLowerCase();
//
//     if (userSharing == otherSharing) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userSharing == 'flexible' && (otherSharing == 'share everything' || otherSharing == 'share some items' || otherSharing == 'prefer separate items')) ||
//         (otherSharing == 'flexible' && (userSharing == 'share everything' || userSharing == 'share some items' || userSharing == 'prefer separate items'))
//     ) {
//       score += 1.8 * habitsWeight;
//     } else if (
//     (userSharing == 'share everything' && otherSharing == 'share some items') ||
//         (otherSharing == 'share everything' && userSharing == 'share some items')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userSharing == 'share some items' && otherSharing == 'prefer separate items') ||
//         (otherSharing == 'share some items' && userSharing == 'prefer separate items')
//     ) {
//       score += 1.0 * habitsWeight;
//     } else if (
//     (userSharing == 'share everything' && otherSharing == 'prefer separate items') ||
//         (otherSharing == 'share everything' && userSharing == 'prefer separate items')
//     ) {
//       score += 0.5 * habitsWeight;
//     }
//
//     // Guests Overnight Policy
//     maxScore += 2 * habitsWeight; // Max score for guests overnight policy
//     final userGuests = userProfile.guestsOvernightPolicy.toLowerCase();
//     final otherGuests = otherProfile.guestsOvernightPolicy.toLowerCase();
//
//     if (userGuests == otherGuests) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userGuests == 'frequently' && otherGuests == 'occasionally') ||
//         (otherGuests == 'frequently' && userGuests == 'occasionally')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userGuests == 'occasionally' && otherGuests == 'rarely') ||
//         (otherGuests == 'occasionally' && userGuests == 'rarely')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userGuests == 'rarely' && otherGuests == 'never') ||
//         (otherGuests == 'rarely' && userGuests == 'never')
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userGuests == 'occasionally' && otherGuests == 'never') ||
//         (otherGuests == 'occasionally' && userGuests == 'never')
//     ) {
//       score += 0.5 * habitsWeight;
//     } else if (
//     (userGuests == 'frequently' && otherGuests == 'rarely') ||
//         (otherGuests == 'frequently' && userGuests == 'rarely')
//     ) {
//       score += 0.2 * habitsWeight;
//     } else if (
//     (userGuests == 'frequently' && otherGuests == 'never') ||
//         (otherGuests == 'frequently' && userGuests == 'never')
//     ) {
//       // strong mismatch, 0 points
//     }
//
//     // Personal Space vs. Socialization
//     maxScore += 2 * habitsWeight; // Max score for personal space vs. socialization
//     final userSpaceSocial = userProfile.personalSpaceVsSocialization.toLowerCase();
//     final otherSpaceSocial = otherProfile.personalSpaceVsSocialization.toLowerCase();
//
//     if (userSpaceSocial == otherSpaceSocial) {
//       score += 2 * habitsWeight;
//     } else if (
//     (userSpaceSocial == 'flexible' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'enjoy a balance' || otherSpaceSocial == 'prefer more socialization')) ||
//         (otherSpaceSocial == 'flexible' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'enjoy a balance' || userSpaceSocial == 'prefer more socialization'))
//     ) {
//       score += 1.8 * habitsWeight;
//     } else if (
//     (userSpaceSocial == 'enjoy a balance' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'prefer more socialization')) ||
//         (otherSpaceSocial == 'enjoy a balance' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'prefer more socialization'))
//     ) {
//       score += 1.5 * habitsWeight;
//     } else if (
//     (userSpaceSocial == 'value personal space highly' && otherSpaceSocial == 'prefer more socialization') ||
//         (otherSpaceSocial == 'value personal space highly' && userSpaceSocial == 'prefer more socialization')
//     ) {
//       score += 0.2 * habitsWeight;
//     }
//
//     // --- Requirements/Preferences Comparison (from flat lister's perspective) ---
//     // NO fixed maxScore for requirements here. Each requirement adds its max potential.
//
//     // Preferred Flatmate Gender
//     maxScore += 1 * requirementsPreferencesWeight; // Max score for preferred gender
//     if (userProfile.preferredGender.toLowerCase() == otherProfile.gender.toLowerCase() || userProfile.preferredGender.toLowerCase() == 'any') {
//       score += 1 * requirementsPreferencesWeight;
//     }
//
//     // Preferred Habits (overlap with other user's actual habits)
//     maxScore += 2 * requirementsPreferencesWeight; // Max score for preferred habits
//     final preferredHabitsIntersection = userProfile.preferredHabits.toSet().intersection([
//       otherProfile.smokingHabits, // Note: seeking flatmate has 'smokingHabits', lister has 'smokingHabit'
//       otherProfile.drinkingHabits, // Note: seeking flatmate has 'drinkingHabits', lister has 'drinkingHabit'
//       otherProfile.foodPreference,
//       otherProfile.cleanliness,
//       otherProfile.noiseLevel,
//       otherProfile.socialHabits,
//       otherProfile.guestsFrequency, // This variable name might be different from guestsOvernightPolicy
//       otherProfile.visitorsPolicy,
//       otherProfile.petOwnership,
//       otherProfile.petTolerance,
//       otherProfile.sleepingSchedule,
//       otherProfile.workSchedule,
//       otherProfile.sharingCommonSpaces,
//       otherProfile.guestsOvernightPolicy,
//       otherProfile.personalSpaceVsSocialization,
//     ].map((e) => e.toLowerCase()).toSet());
//     score += (preferredHabitsIntersection.length / (userProfile.preferredHabits.length > 0 ? userProfile.preferredHabits.length : 1)) * 2 * requirementsPreferencesWeight;
//
//     // Ideal Qualities (overlap)
//     maxScore += 2 * requirementsPreferencesWeight; // Max score for ideal qualities
//     final idealQualitiesIntersection = userProfile.flatmateIdealQualities.toSet().intersection(otherProfile.idealQualities.toSet());
//     score += (idealQualitiesIntersection.length / (userProfile.flatmateIdealQualities.length > 0 ? userProfile.flatmateIdealQualities.length : 1)) * 2 * requirementsPreferencesWeight;
//
//     // Deal Breakers (penalty for overlap) - No maxScore addition as it's a penalty
//     final dealBreakersIntersection = userProfile.flatmateDealBreakers.toSet().intersection(otherProfile.dealBreakers.toSet());
//     score -= (dealBreakersIntersection.length * 5) * requirementsPreferencesWeight; // Penalize heavily
//
//   } else {
//     return 0.0; // Mismatch in profile types or unexpected scenario
//   }
//
//   // Ensure score doesn't go below zero
//   if (score < 0) score = 0;
//
//   // Calculate percentage, ensuring maxScore is not zero to avoid division by zero
//   double percentage = (maxScore > 0) ? (score / maxScore) * 100 : 0.0;
//   return percentage.clamp(0.0, 100.0); // Ensure it's between 0 and 100
// }
//
// double _calculateMatchPercentage(dynamic userProfile, dynamic otherProfile) {
//   if (userProfile == null || otherProfile == null) return 0.0;
//
//   double score = 0;
//   double maxScore = 0;
//
//   // --- Weights for different categories (adjust as needed) ---
//   const double basicInfoWeight = 0.2;
//   const double habitsWeight = 0.4;
//   const double requirementsPreferencesWeight = 0.4;
//
//   // --- Basic Info Comparison ---
//   // Max score for basic info (e.g., 5 points per attribute)
//   maxScore += 5 * basicInfoWeight;
//
//   if (userProfile is SeekingFlatmateProfile && otherProfile is FlatListingProfile) {
//     // Basic Info
//     if (userProfile.desiredCity.toLowerCase() == otherProfile.desiredCity.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//     if (userProfile.areaPreference.toLowerCase() == otherProfile.areaPreference.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//     if (userProfile.gender.toLowerCase() == otherProfile.ownerGender.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//
//     // Age compatibility (e.g., if other user's age is within preferred range)
//     if (userProfile.preferredFlatmateAge.isNotEmpty && otherProfile.ownerAge != null) {
//       // Simple age range parsing for demonstration, enhance as needed
//       if (userProfile.preferredFlatmateAge.contains('-')) {
//         final parts = userProfile.preferredFlatmateAge.split('-');
//         if (parts.length == 2) {
//           final minAge = int.tryParse(parts[0].trim());
//           final maxAge = int.tryParse(parts[1].trim());
//           if (minAge != null && maxAge != null && otherProfile.ownerAge! >= minAge && otherProfile.ownerAge! <= maxAge) {
//             score += 1 * basicInfoWeight;
//           }
//         }
//       } else if (userProfile.preferredFlatmateAge.toLowerCase() == 'any') {
//         score += 1 * basicInfoWeight; // Considered a match if 'any'
//       }
//     }
//
//     // Occupation Match (simple match for now)
//     if (userProfile.preferredOccupation.toLowerCase() == otherProfile.ownerOccupation.toLowerCase() && userProfile.preferredOccupation.isNotEmpty) {
//       score += 1 * basicInfoWeight;
//     }
//
//     // --- Habits Comparison (more nuanced) ---
//     // Max score for habits (e.g., 10 points per attribute)
//     maxScore += 10 * habitsWeight;
//
//     // Smoking
//     // Assuming userProfile.smokingHabits could be 'Never', 'Occasionally', 'Socially', 'Regularly', or 'Tolerates'
// // Assuming otherProfile.smokingHabit will be 'Never', 'Occasionally', 'Socially', 'Regularly'
//
//     final userSmokes = userProfile.smokingHabits.toLowerCase();
//     final otherSmokes = otherProfile.smokingHabit.toLowerCase();
//
//     if (
//     // Case 1: User is 'Never' (non-smoker), other is 'Never' (non-smoker)
//     (userSmokes == 'never' && otherSmokes == 'never') ||
//
//         // Case 2: User is 'Occasionally', other is 'Occasionally' or 'Never'
//         (userSmokes == 'occasionally' && (otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
//
//         // Case 3: User is 'Socially', other is 'Socially', 'Occasionally' or 'Never'
//         (userSmokes == 'socially' && (otherSmokes == 'socially' || otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
//
//         // Case 4: User is 'Regularly', other is 'Regularly'
//         (userSmokes == 'regularly' && otherSmokes == 'regularly') ||
//
//         // Case 5: User 'Tolerates' (meaning they are okay with occasional or regular smokers)
//         // Note: 'Tolerates' is a preference, not a habit, so it makes sense for the user (seeker/lister) to tolerate the other's habit.
//         (userSmokes == 'tolerates' && (otherSmokes == 'occasionally' || otherSmokes == 'socially' || otherSmokes == 'regularly'))
//     ) {
//       score += 2 * habitsWeight;
//     }
//
//     // Drinking
//     // Inside the if (userProfile is SeekingFlatmateProfile && otherProfile is FlatListingProfile) block
//
//     final userDrinksPref = userProfile.drinkingHabits.toLowerCase(); // Can be 'never', 'occasionally', 'socially', 'regularly', or 'tolerates'
//     final otherDrinksActual = otherProfile.drinkingHabit.toLowerCase(); // Will be 'never', 'occasionally', 'socially', 'regularly'
//
//     if (
//     // User is 'Never' (non-drinker), other is 'Never' (non-drinker)
//     (userDrinksPref == 'never' && otherDrinksActual == 'never') ||
//
//         // User is 'Occasionally', other is 'Occasionally' or 'Never'
//         (userDrinksPref == 'occasionally' && (otherDrinksActual == 'occasionally' || otherDrinksActual == 'never')) ||
//
//         // User is 'Socially', other is 'Socially', 'Occasionally', or 'Never'
//         (userDrinksPref == 'socially' && (otherDrinksActual == 'socially' || otherDrinksActual == 'occasionally' || otherDrinksActual == 'never')) ||
//
//         // User is 'Regularly', other is 'Regularly'
//         (userDrinksPref == 'regularly' && otherDrinksActual == 'regularly') ||
//
//         // User 'Tolerates' (meaning they are okay with occasional, social, or regular drinkers)
//         (userDrinksPref == 'tolerates' && (otherDrinksActual == 'occasionally' || otherDrinksActual == 'socially' || otherDrinksActual == 'regularly'))
//     ) {
//       score += 2 * habitsWeight;
//     }
//
//     // Food Preference
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userFood = userProfile.foodPreference.toLowerCase();
//     final otherFood = otherProfile.foodPreference.toLowerCase();
//
// // Define compatibility rules and assign scores (adjust weights as needed)
// // Max score for food preference remains 1 * habitsWeight, but we can assign fractions.
//
//     if (userFood == otherFood) {
//       // Perfect direct match
//       score += 1 * habitsWeight;
//     } else if (
//     // Vegan is compatible with Vegetarian, Eggetarian, Jain (they don't eat meat, so no conflict)
//     (userFood == 'vegan' && (otherFood == 'vegetarian' || otherFood == 'eggetarian' || otherFood == 'jain')) ||
//         (otherFood == 'vegan' && (userFood == 'vegetarian' || userFood == 'eggetarian' || userFood == 'jain'))
//     ) {
//       // A Vegan living with a Vegetarian/Eggetarian/Jain is usually compatible.
//       score += 0.75 * habitsWeight;
//     } else if (
//     // Vegetarian compatible with Eggetarian and Jain (they generally don't eat meat)
//     (userFood == 'vegetarian' && (otherFood == 'eggetarian' || otherFood == 'jain')) ||
//         (otherFood == 'vegetarian' && (userFood == 'eggetarian' || userFood == 'jain'))
//     ) {
//       // A Vegetarian living with an Eggetarian/Jain is generally compatible.
//       score += 0.75 * habitsWeight;
//     } else if (
//     // Eggetarian compatible with Vegetarian and Jain (they share non-meat principle)
//     (userFood == 'eggetarian' && (otherFood == 'vegetarian' || otherFood == 'jain')) ||
//         (otherFood == 'eggetarian' && (userFood == 'vegetarian' || userFood == 'jain'))
//     ) {
//       // An Eggetarian living with a Vegetarian/Jain is generally compatible.
//       score += 0.5 * habitsWeight; // Slightly lower as eggs might be a concern for strict Vegans/Jains
//     } else if (
//     // Jain compatible with Vegetarian and Vegan (strict non-meat)
//     (userFood == 'jain' && (otherFood == 'vegetarian' || otherFood == 'vegan' || otherFood == 'eggetarian')) ||
//         (otherFood == 'jain' && (userFood == 'vegetarian' || userFood == 'vegan' || userFood == 'eggetarian'))
//     ) {
//       // A Jain living with a Vegetarian/Vegan/Eggetarian is generally compatible, but might have stricter rules for cooking.
//       score += 0.75 * habitsWeight;
//     } else if (
//     // 'Other' is a bit of a wildcard, give a small score for any match if one is 'Other'
//     (userFood == 'other' || otherFood == 'other')
//     ) {
//       // If one person selects 'Other', it suggests flexibility or a niche diet.
//       // This provides a minimal match, encouraging discussion.
//       score += 0.2 * habitsWeight;
//     }
//
//
//     final userCleanliness = userProfile.cleanliness.toLowerCase();
//     final otherCleanliness = otherProfile.cleanlinessLevel.toLowerCase();
//
//
//     if (userCleanliness == otherCleanliness) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // Very Tidy is compatible with Moderately Tidy
//     (userCleanliness == 'very tidy' && otherCleanliness == 'moderately tidy') ||
//         (otherCleanliness == 'very tidy' && userCleanliness == 'moderately tidy')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility, but not perfect
//     } else if (
//     // Moderately Tidy is compatible with Flexible
//     (userCleanliness == 'moderately tidy' && otherCleanliness == 'flexible') ||
//         (otherCleanliness == 'moderately tidy' && userCleanliness == 'flexible')
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility
//     } else if (
//     // Flexible is compatible with Can be messy at times, or any other not perfectly matched
//     (userCleanliness == 'flexible' && otherCleanliness == 'can be messy at times') ||
//         (otherCleanliness == 'flexible' && userCleanliness == 'can be messy at times')
//     ) {
//       score += 0.5 * habitsWeight; // Low compatibility, but some tolerance
//     } else if (
//     // Very Tidy vs Flexible/Messy (less ideal but not zero if 'flexible' is tolerant)
//     (userCleanliness == 'very tidy' && (otherCleanliness == 'flexible' || otherCleanliness == 'can be messy at times')) ||
//         (otherCleanliness == 'very tidy' && (userCleanliness == 'flexible' || userCleanliness == 'can be messy at times'))
//     ) {
//       score += 0.2 * habitsWeight; // Very low compatibility, indicates potential friction
//     }
//
//
//     final userNoise = userProfile.noiseLevel.toLowerCase();
//     final otherNoise = otherProfile.noiseLevel.toLowerCase();
//
// // Max score for noise level remains 2 * habitsWeight.
//
//     if (userNoise == otherNoise) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Very quiet' prefers 'Moderate noise' next best
//     (userNoise == 'very quiet' && otherNoise == 'moderate noise') ||
//         (otherNoise == 'very quiet' && userNoise == 'moderate noise')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Moderate noise' is generally compatible with 'Very quiet' and 'Lively' to some extent
//     (userNoise == 'moderate noise' && (otherNoise == 'very quiet' || otherNoise == 'lively')) ||
//         (otherNoise == 'moderate noise' && (userNoise == 'very quiet' || userNoise == 'lively'))
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility
//     } else if (
//     // 'Flexible' is highly compatible with almost anything (except perhaps a very stark contrast)
//     (userNoise == 'flexible' && (otherNoise == 'very quiet' || otherNoise == 'moderate noise' || otherNoise == 'lively')) ||
//         (otherNoise == 'flexible' && (userNoise == 'very quiet' || userNoise == 'moderate noise' || userNoise == 'lively'))
//     ) {
//       score += 1.8 * habitsWeight; // High score for flexibility, nearly perfect match
//     } else if (
//     // 'Lively' and 'Very quiet' are generally incompatible, but if one is 'Flexible', it's accounted for.
//     // Explicitly handling 'Lively' and 'Very quiet' mismatch if no flexibility.
//     (userNoise == 'lively' && otherNoise == 'very quiet') ||
//         (otherNoise == 'lively' && userNoise == 'very quiet')
//     ) {
//       // These are generally a bad match unless one is flexible. Score 0 here, or a small penalty if desired.
//       // For now, by falling through, it will just add 0 points.
//       // If you want to penalize, add: score -= 1.0 * habitsWeight; (ensure score doesn't go below 0 later)
//     }
// // Any other combinations (e.g., 'Very quiet' with 'Lively' directly, without a 'Flexible' in between)
// // will implicitly get 0 points if not covered by the above positive scoring rules.
//
//     // Social Habits
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userSocial = userProfile.socialHabits.toLowerCase();
//     final otherSocial = otherProfile.socialPreferences.toLowerCase();
//
// // Max score for social habits remains 1 * habitsWeight.
//
//     if (userSocial == otherSocial) {
//       // Perfect direct match (e.g., both 'Social & outgoing')
//       score += 1 * habitsWeight;
//     } else if (
//     // 'Flexible' is highly compatible with almost everything
//     (userSocial == 'flexible' && (otherSocial == 'social & outgoing' || otherSocial == 'occasional gatherings' || otherSocial == 'quiet & private')) ||
//         (otherSocial == 'flexible' && (userSocial == 'social & outgoing' || userSocial == 'occasional gatherings' || userSocial == 'quiet & private'))
//     ) {
//       score += 0.9 * habitsWeight; // Very high compatibility
//     } else if (
//     // 'Social & outgoing' is compatible with 'Occasional gatherings'
//     (userSocial == 'social & outgoing' && otherSocial == 'occasional gatherings') ||
//         (otherSocial == 'social & outgoing' && userSocial == 'occasional gatherings')
//     ) {
//       score += 0.7 * habitsWeight; // Good compatibility
//     } else if (
//     // 'Occasional gatherings' is compatible with 'Quiet & private'
//     // (As long as occasional means not frequent disruption for the quiet person)
//     (userSocial == 'occasional gatherings' && otherSocial == 'quiet & private') ||
//         (otherSocial == 'occasional gatherings' && userSocial == 'quiet & private')
//     ) {
//       score += 0.6 * habitsWeight; // Moderate compatibility
//     } else if (
//     // 'Social & outgoing' and 'Quiet & private' (if not flexible) generally a low match
//     (userSocial == 'social & outgoing' && otherSocial == 'quiet & private') ||
//         (otherSocial == 'social & outgoing' && userSocial == 'quiet & private')
//     ) {
//       // These are generally considered a poor match, assign a minimal score.
//       score += 0.2 * habitsWeight;
//     }
// // For any other combinations, the score for this attribute will implicitly remain 0.
//
//     // Pet Ownership/Tolerance
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userOwns = userProfile.petOwnership.toLowerCase(); // 'yes', 'no', 'planning to get one'
//     final otherOwns = otherProfile.petOwnership.toLowerCase(); // 'yes', 'no', 'planning to get one'
//
// // Assuming petTolerance fields might still exist on both profiles
// // Use null-aware operator '??' and default to empty string to avoid null issues
//     final userTolerates = (userProfile.petTolerance ?? '').toLowerCase(); // e.g., 'tolerates pets' or some other value
//     final otherTolerates = (otherProfile.petTolerance ?? '').toLowerCase(); // e.g., 'tolerates pets' or some other value
//
// // Initialize a sub-score for pet compatibility for this iteration
//     double currentPetScore = 0;
//
// // Case 1: Both have NO pets
//     if (userOwns == 'no' && otherOwns == 'no') {
//       currentPetScore = 2.0 * habitsWeight; // Perfect match
//     }
// // Case 2: Both have pets ('Yes')
//     else if (userOwns == 'yes' && otherOwns == 'yes') {
//       currentPetScore = 2.0 * habitsWeight; // Perfect match, they share the pet-loving lifestyle
//     }
// // Case 3: One has pets ('Yes'), the other tolerates pets
//     else if ((userOwns == 'yes' && otherTolerates == 'tolerates pets') ||
//         (otherOwns == 'yes' && userTolerates == 'tolerates pets')) {
//       currentPetScore = 2.0 * habitsWeight; // High compatibility, tolerance works
//     }
// // Case 4: Both are planning to get pets
//     else if (userOwns == 'planning to get one' && otherOwns == 'planning to get one') {
//       currentPetScore = 1.8 * habitsWeight; // Good match on future intent
//     }
// // Case 5: One has pets ('Yes'), the other is 'Planning to get one'
// // This implies mutual understanding and potential shared pet-related future
//     else if ((userOwns == 'yes' && otherOwns == 'planning to get one') ||
//         (otherOwns == 'yes' && userOwns == 'planning to get one')) {
//       currentPetScore = 1.5 * habitsWeight; // Good compatibility
//     }
// // Case 6: One has 'No' pets, the other is 'Planning to get one' AND the 'No' person tolerates pets
//     else if ((userOwns == 'no' && otherOwns == 'planning to get one' && userTolerates == 'tolerates pets') ||
//         (otherOwns == 'no' && userOwns == 'planning to get one' && otherTolerates == 'tolerates pets')) {
//       currentPetScore = 1.0 * habitsWeight; // Acceptable if the 'No' person is explicitly tolerant
//     }
// // Case 7: One is 'Planning to get one', and the other explicitly 'Tolerates pets'
// // This covers cases where the 'tolerates' person doesn't necessarily have a pet or says 'no pets' but tolerates
//     else if ((userOwns == 'planning to get one' && otherTolerates == 'tolerates pets') ||
//         (otherOwns == 'planning to get one' && userTolerates == 'tolerates pets')) {
//       currentPetScore = 1.0 * habitsWeight; // Positive match based on tolerance
//     }
//
// // Add the calculated score for pet compatibility to the total score
//     score += currentPetScore;
//
//     // Add more habit comparisons...
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userVisitors = userProfile.visitorsPolicy.toLowerCase();
//     final otherVisitors = otherProfile.visitorsPolicy.toLowerCase();
//
// // Max score for visitors policy remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userVisitors == otherVisitors) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Frequent visitors' and 'Occasional visitors' are quite compatible
//     (userVisitors == 'frequent visitors' && otherVisitors == 'occasional visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'occasional visitors')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Occasional visitors' and 'Rarely have visitors' are compatible
//     (userVisitors == 'occasional visitors' && otherVisitors == 'rarely have visitors') ||
//         (otherVisitors == 'occasional visitors' && userVisitors == 'rarely have visitors')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Rarely have visitors' and 'No visitors' are quite compatible
//     (userVisitors == 'rarely have visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'rarely have visitors' && userVisitors == 'no visitors')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Occasional visitors' can sometimes tolerate 'No visitors' (if they rarely have them)
//     (userVisitors == 'occasional visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'occasional visitors' && userVisitors == 'no visitors')
//     ) {
//       score += 0.5 * habitsWeight; // Low compatibility
//     } else if (
//     // 'Frequent visitors' and 'Rarely have visitors' are generally a poor match
//     (userVisitors == 'frequent visitors' && otherVisitors == 'rarely have visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'rarely have visitors')
//     ) {
//       score += 0.2 * habitsWeight; // Very low compatibility, indicates friction
//     } else if (
//     // 'Frequent visitors' and 'No visitors' are highly incompatible
//     (userVisitors == 'frequent visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'no visitors')
//     ) {
//       // Generally a strong mismatch. Assign 0 points or a small penalty if desired.
//       // For now, it will simply not add points here.
//       // If you want to penalize, add: score -= 1.0 * habitsWeight; (ensure score doesn't go below 0 later)
//     }
// // Any other combinations not explicitly covered above will implicitly add 0 points.
// // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userSchedule = userProfile.sleepingSchedule.toLowerCase();
//     final otherSchedule = otherProfile.sleepingSchedule.toLowerCase();
//
// // Max score for sleeping schedule remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userSchedule == otherSchedule) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Flexible' is highly compatible with 'Early riser' or 'Night Owl'
//     (userSchedule == 'flexible' && (otherSchedule == 'early riser' || otherSchedule == 'night owl')) ||
//         (otherSchedule == 'flexible' && (userSchedule == 'early riser' || userSchedule == 'night owl'))
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Flexible' is compatible with 'Irregular' (implies mutual understanding)
//     (userSchedule == 'flexible' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'flexible' && userSchedule == 'irregular')
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility
//     } else if (
//     // 'Early riser' and 'Irregular' might have some overlap/tolerance
//     (userSchedule == 'early riser' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'early riser' && userSchedule == 'irregular')
//     ) {
//       score += 0.5 * habitsWeight; // Some compatibility, potential for slight friction
//     } else if (
//     // 'Night Owl' and 'Irregular' might also have some overlap/tolerance
//     (userSchedule == 'night owl' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'night owl' && userSchedule == 'irregular')
//     ) {
//       score += 0.5 * habitsWeight; // Some compatibility, potential for slight friction
//     }
// // For diametrically opposed cases like 'Early riser' vs 'Night Owl',
// // or 'Early riser'/'Night Owl' vs 'Irregular' without 'Flexible' as a mediator,
// // the score implicitly remains 0 from this section, which is appropriate for a potential mismatch.
// // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userWork = userProfile.workSchedule.toLowerCase();
//     final otherWork = otherProfile.workSchedule.toLowerCase();
//
// // Max score for work/study schedule remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userWork == otherWork) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Mixed' or 'Freelance/Flexible' are often highly compatible
//     (userWork == 'mixed' && (otherWork == 'freelance/flexible hours' || otherWork == '9-5 office hours' || otherWork == 'student schedule' || otherWork == 'night shifts')) ||
//         (otherWork == 'mixed' && (userWork == 'freelance/flexible hours' || userWork == '9-5 office hours' || userWork == 'student schedule' || userWork == 'night shifts')) ||
//         (userWork == 'freelance/flexible hours' && (otherWork == '9-5 office hours' || otherWork == 'student schedule')) ||
//         (otherWork == 'freelance/flexible hours' && (userWork == '9-5 office hours' || userWork == 'student schedule'))
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility for adaptable or daytime schedules
//     } else if (
//     // '9-5 Office hours' and 'Student schedule' often align somewhat
//     (userWork == '9-5 office hours' && otherWork == 'student schedule') ||
//         (otherWork == '9-5 office hours' && userWork == 'student schedule')
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility
//     } else if (
//     // 'Freelance/Flexible hours' and 'Night shifts' might work (one awake while other sleeps)
//     (userWork == 'freelance/flexible hours' && otherWork == 'night shifts') ||
//         (otherWork == 'freelance/flexible hours' && userWork == 'night shifts')
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility due to non-overlapping primary hours
//     } else if (
//     // 'Night shifts' and 'Student schedule' are generally less compatible
//     (userWork == 'night shifts' && otherWork == 'student schedule') ||
//         (otherWork == 'night shifts' && userWork == 'student schedule')
//     ) {
//       score += 0.5 * habitsWeight; // Low compatibility, potential for noise conflicts
//     } else if (
//     // '9-5 Office hours' and 'Night shifts' are generally highly incompatible
//     (userWork == '9-5 office hours' && otherWork == 'night shifts') ||
//         (otherWork == '9-5 office hours' && userWork == 'night shifts')
//     ) {
//       // Very low compatibility due to conflicting sleep/activity times.
//       score += 0.2 * habitsWeight;
//     }
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userSharing = userProfile.sharingCommonSpaces.toLowerCase();
//     final otherSharing = otherProfile.sharingCommonSpaces.toLowerCase();
//
// // Max score for sharing habits remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userSharing == otherSharing) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Flexible' is highly compatible with most options
//     (userSharing == 'flexible' && (otherSharing == 'share everything' || otherSharing == 'share some items' || otherSharing == 'prefer separate items')) ||
//         (otherSharing == 'flexible' && (userSharing == 'share everything' || userSharing == 'share some items' || userSharing == 'prefer separate items'))
//     ) {
//       score += 1.8 * habitsWeight; // Very high compatibility
//     } else if (
//     // 'Share everything' and 'Share some items' are generally compatible
//     (userSharing == 'share everything' && otherSharing == 'share some items') ||
//         (otherSharing == 'share everything' && userSharing == 'share some items')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Share some items' and 'Prefer separate items' can work
//     (userSharing == 'share some items' && otherSharing == 'prefer separate items') ||
//         (otherSharing == 'share some items' && userSharing == 'prefer separate items')
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility
//     } else if (
//     // 'Share everything' and 'Prefer separate items' are less ideal but sometimes negotiable
//     (userSharing == 'share everything' && otherSharing == 'prefer separate items') ||
//         (otherSharing == 'share everything' && userSharing == 'prefer separate items')
//     ) {
//       score += 0.5 * habitsWeight; // Low compatibility, potential for friction
//     }
//
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userGuests = userProfile.guestsOvernightPolicy.toLowerCase();
//     final otherGuests = otherProfile.guestsOvernightPolicy.toLowerCase();
//
// // Max score for guests overnight policy remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userGuests == otherGuests) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Frequently' and 'Occasionally' are quite compatible
//     (userGuests == 'frequently' && otherGuests == 'occasionally') ||
//         (otherGuests == 'frequently' && userGuests == 'occasionally')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Occasionally' and 'Rarely' are compatible
//     (userGuests == 'occasionally' && otherGuests == 'rarely') ||
//         (otherGuests == 'occasionally' && userGuests == 'rarely')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Rarely' and 'Never' are quite compatible
//     (userGuests == 'rarely' && otherGuests == 'never') ||
//         (otherGuests == 'rarely' && userGuests == 'never')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Occasionally' and 'Never' - less ideal but possible if occasional is truly infrequent
//     (userGuests == 'occasionally' && otherGuests == 'never') ||
//         (otherGuests == 'occasionally' && userGuests == 'never')
//     ) {
//       score += 0.5 * habitsWeight; // Low compatibility
//     } else if (
//     // 'Frequently' and 'Rarely' - generally a poor match
//     (userGuests == 'frequently' && otherGuests == 'rarely') ||
//         (otherGuests == 'frequently' && userGuests == 'rarely')
//     ) {
//       score += 0.2 * habitsWeight; // Very low compatibility, indicates friction
//     } else if (
//     // 'Frequently' and 'Never' - highly incompatible
//     (userGuests == 'frequently' && otherGuests == 'never') ||
//         (otherGuests == 'frequently' && userGuests == 'never')
//     ) {
//       // This is a strong mismatch. It will implicitly add 0 points.
//       // If you wish to actively penalize, uncomment the line below.
//       // score -= 1.0 * habitsWeight; // Example penalty
//     }
// // Any other combinations not explicitly covered above will implicitly add 0 points.
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userSpaceSocial = userProfile.personalSpaceVsSocialization.toLowerCase();
//     final otherSpaceSocial = otherProfile.personalSpaceVsSocialization.toLowerCase();
//
// // Max score for personal space vs. socialization remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userSpaceSocial == otherSpaceSocial) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Flexible' is highly compatible with most options
//     (userSpaceSocial == 'flexible' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'enjoy a balance' || otherSpaceSocial == 'prefer more socialization')) ||
//         (otherSpaceSocial == 'flexible' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'enjoy a balance' || userSpaceSocial == 'prefer more socialization'))
//     ) {
//       score += 1.8 * habitsWeight; // Very high compatibility
//     } else if (
//     // 'Enjoy a balance' is compatible with 'Value personal space highly' or 'Prefer more socialization'
//     (userSpaceSocial == 'enjoy a balance' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'prefer more socialization')) ||
//         (otherSpaceSocial == 'enjoy a balance' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'prefer more socialization'))
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Value personal space highly' and 'Prefer more socialization' are generally a poor direct match
//     (userSpaceSocial == 'value personal space highly' && otherSpaceSocial == 'prefer more socialization') ||
//         (otherSpaceSocial == 'value personal space highly' && userSpaceSocial == 'prefer more socialization')
//     ) {
//       // This is a direct conflict. Assign a very low score.
//       score += 0.2 * habitsWeight;
//     }
// // Any other combinations not explicitly covered above will implicitly add 0 points.
// // Any other combinations not explicitly covered above (like 'Share everything' directly with 'Prefer separate items' if not caught above)
// // will implicitly add 0 points, which is appropriate for strong mismatches.
// // Any other combinations not explicitly covered above will implicitly add 0 points.
//
//     // --- Requirements/Preferences Comparison ---
//     // Max score for requirements/preferences (e.g., 5 points per attribute, 10 for lists)
//     maxScore += 5 * requirementsPreferencesWeight;
//
//     // Flat Type
//     if (userProfile.preferredFlatType.toLowerCase() == otherProfile.flatType.toLowerCase()) {
//       score += 1 * requirementsPreferencesWeight;
//     }
//
//     // Furnished Status
//     if (userProfile.preferredFurnishedStatus.toLowerCase() == otherProfile.furnishedStatus.toLowerCase()) {
//       score += 1 * requirementsPreferencesWeight;
//     }
//
//     // Budget (check if otherProfile's rent is within userProfile's budget range)
//     if (userProfile.budgetMin != null && userProfile.budgetMax != null && otherProfile.rentPrice != null) {
//       if (otherProfile.rentPrice! >= userProfile.budgetMin! && otherProfile.rentPrice! <= userProfile.budgetMax!) {
//         score += 2 * requirementsPreferencesWeight;
//       }
//     }
//
//
//     // Amenities Desired (overlap)
//     final amenityIntersection = userProfile.amenitiesDesired.toSet().intersection(otherProfile.amenities.toSet());
//     score += (amenityIntersection.length / (userProfile.amenitiesDesired.length > 0 ? userProfile.amenitiesDesired.length : 1)) * 2 * requirementsPreferencesWeight; // Scale by number of desired amenities
//
//     // Preferred Habits (other user's actual habits matching preferred habits)
//     final preferredHabitsIntersection = userProfile.preferredHabits.toSet().intersection([
//       otherProfile.smokingHabit,
//       otherProfile.drinkingHabit,
//       otherProfile.foodPreference,
//       otherProfile.cleanlinessLevel,
//       otherProfile.noiseLevel,
//       otherProfile.socialPreferences,
//       otherProfile.visitorsPolicy,
//       otherProfile.petOwnership,
//       otherProfile.petTolerance,
//       otherProfile.sleepingSchedule,
//       otherProfile.workSchedule,
//       otherProfile.sharingCommonSpaces,
//       otherProfile.guestsOvernightPolicy,
//       otherProfile.personalSpaceVsSocialization,
//     ].map((e) => e.toLowerCase()).toSet());
//     score += (preferredHabitsIntersection.length / (userProfile.preferredHabits.length > 0 ? userProfile.preferredHabits.length : 1)) * 2 * requirementsPreferencesWeight;
//
//     // Ideal Qualities (overlap)
//     // This part requires you to define how 'ideal qualities' map to actual profile traits.
//     // For now, a simple overlap with 'deal breakers' from the other profile could be a reverse match.
//     // Or you might need to infer ideal qualities from the other profile's general habits/bio.
//     // For a basic match, we can just check for direct overlap if 'idealQualities' are also tags.
//     final idealQualitiesIntersection = userProfile.idealQualities.toSet().intersection(otherProfile.flatmateIdealQualities.toSet());
//     score += (idealQualitiesIntersection.length / (userProfile.idealQualities.length > 0 ? userProfile.idealQualities.length : 1)) * 2 * requirementsPreferencesWeight;
//
//
//     // Deal Breakers (penalty for overlap)
//     final dealBreakersIntersection = userProfile.dealBreakers.toSet().intersection(otherProfile.flatmateDealBreakers.toSet());
//     score -= (dealBreakersIntersection.length * 5) * requirementsPreferencesWeight; // Penalize heavily
//
//   } else if (userProfile is FlatListingProfile && otherProfile is SeekingFlatmateProfile) {
//     // Basic Info
//     if (userProfile.desiredCity.toLowerCase() == otherProfile.desiredCity.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//     if (userProfile.areaPreference.toLowerCase() == otherProfile.areaPreference.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//     if (userProfile.ownerGender.toLowerCase() == otherProfile.gender.toLowerCase()) {
//       score += 1 * basicInfoWeight;
//     }
//
//     // Age compatibility (e.g., if other user's age is within preferred range of the flat lister)
//     if (userProfile.preferredAgeGroup.isNotEmpty && otherProfile.age != null) {
//       if (userProfile.preferredAgeGroup.contains('-')) {
//         final parts = userProfile.preferredAgeGroup.split('-');
//         if (parts.length == 2) {
//           final minAge = int.tryParse(parts[0].trim());
//           final maxAge = int.tryParse(parts[1].trim());
//           if (minAge != null && maxAge != null && otherProfile.age! >= minAge && otherProfile.age! <= maxAge) {
//             score += 1 * basicInfoWeight;
//           }
//         }
//       } else if (userProfile.preferredAgeGroup.toLowerCase() == 'any') {
//         score += 1 * basicInfoWeight;
//       }
//     }
//
//     // Occupation Match
//     if (userProfile.preferredOccupation.toLowerCase() == otherProfile.occupation.toLowerCase() && userProfile.preferredOccupation.isNotEmpty) {
//       score += 1 * basicInfoWeight;
//     }
//
//
//     // --- Habits Comparison (more nuanced) ---
//     maxScore += 10 * habitsWeight;
//
//     // Smoking
//     // Inside the else if (userProfile is FlatListingProfile && otherProfile is SeekingFlatmateProfile) block
//
// // Here, userProfile.smokingHabit will be 'Never', 'Occasionally', 'Socially', 'Regularly'
// // otherProfile.smokingHabits might be 'Never', 'Occasionally', 'Socially', 'Regularly', or 'Tolerates'
//
//     final userSmokes = userProfile.smokingHabit.toLowerCase(); // The flat lister's actual habit
//     final otherSmokes = otherProfile.smokingHabits.toLowerCase(); // The flatmate seeker's habit/preference
//
//     if (
//     // Case 1: User is 'Never' (non-smoker), other is 'Never' (non-smoker)
//     (userSmokes == 'never' && otherSmokes == 'never') ||
//
//         // Case 2: User is 'Occasionally', other is 'Occasionally' or 'Never'
//         (userSmokes == 'occasionally' && (otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
//
//         // Case 3: User is 'Socially', other is 'Socially', 'Occasionally' or 'Never'
//         (userSmokes == 'socially' && (otherSmokes == 'socially' || otherSmokes == 'occasionally' || otherSmokes == 'never')) ||
//
//         // Case 4: User is 'Regularly', other is 'Regularly'
//         (userSmokes == 'regularly' && otherSmokes == 'regularly') ||
//
//         // Case 5: Other 'Tolerates' (meaning they are okay with occasional or regular smokers)
//         (otherSmokes == 'tolerates' && (userSmokes == 'occasionally' || userSmokes == 'socially' || userSmokes == 'regularly'))
//     ) {
//       score += 2 * habitsWeight;
//     }
//
//     // Drinking
//     // Inside the else if (userProfile is FlatListingProfile && otherProfile is SeekingFlatmateProfile) block
//
//     final userDrinksActual = userProfile.drinkingHabit.toLowerCase(); // Will be 'never', 'occasionally', 'socially', 'regularly'
//     final otherDrinksPref = otherProfile.drinkingHabits.toLowerCase(); // Can be 'never', 'occasionally', 'socially', 'regularly', or 'tolerates'
//
//     if (
//     // User is 'Never' (non-drinker), other is 'Never' (non-drinker)
//     (userDrinksActual == 'never' && otherDrinksPref == 'never') ||
//
//         // User is 'Occasionally', other is 'Occasionally' or 'Never'
//         (userDrinksActual == 'occasionally' && (otherDrinksPref == 'occasionally' || otherDrinksPref == 'never')) ||
//
//         // User is 'Socially', other is 'Socially', 'Occasionally', or 'Never'
//         (userDrinksActual == 'socially' && (otherDrinksPref == 'socially' || otherDrinksPref == 'occasionally' || otherDrinksPref == 'never')) ||
//
//         // User is 'Regularly', other is 'Regularly'
//         (userDrinksActual == 'regularly' && otherDrinksPref == 'regularly') ||
//
//         // Other 'Tolerates' (meaning they are okay with occasional, social, or regular drinkers)
//         (otherDrinksPref == 'tolerates' && (userDrinksActual == 'occasionally' || userDrinksActual == 'socially' || userDrinksActual == 'regularly'))
//     ) {
//       score += 2 * habitsWeight;
//     }
//     // Food Preference
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userFood = userProfile.foodPreference.toLowerCase();
//     final otherFood = otherProfile.foodPreference.toLowerCase();
//
// // Define compatibility rules and assign scores (adjust weights as needed)
// // Max score for food preference remains 1 * habitsWeight, but we can assign fractions.
//
//     if (userFood == otherFood) {
//       // Perfect direct match
//       score += 1 * habitsWeight;
//     } else if (
//     // Vegan is compatible with Vegetarian, Eggetarian, Jain (they don't eat meat, so no conflict)
//     (userFood == 'vegan' && (otherFood == 'vegetarian' || otherFood == 'eggetarian' || otherFood == 'jain')) ||
//         (otherFood == 'vegan' && (userFood == 'vegetarian' || userFood == 'eggetarian' || userFood == 'jain'))
//     ) {
//       // A Vegan living with a Vegetarian/Eggetarian/Jain is usually compatible.
//       score += 0.75 * habitsWeight;
//     } else if (
//     // Vegetarian compatible with Eggetarian and Jain (they generally don't eat meat)
//     (userFood == 'vegetarian' && (otherFood == 'eggetarian' || otherFood == 'jain')) ||
//         (otherFood == 'vegetarian' && (userFood == 'eggetarian' || userFood == 'jain'))
//     ) {
//       // A Vegetarian living with an Eggetarian/Jain is generally compatible.
//       score += 0.75 * habitsWeight;
//     } else if (
//     // Eggetarian compatible with Vegetarian and Jain (they share non-meat principle)
//     (userFood == 'eggetarian' && (otherFood == 'vegetarian' || otherFood == 'jain')) ||
//         (otherFood == 'eggetarian' && (userFood == 'vegetarian' || userFood == 'jain'))
//     ) {
//       // An Eggetarian living with a Vegetarian/Jain is generally compatible.
//       score += 0.5 * habitsWeight; // Slightly lower as eggs might be a concern for strict Vegans/Jains
//     } else if (
//     // Jain compatible with Vegetarian and Vegan (strict non-meat)
//     (userFood == 'jain' && (otherFood == 'vegetarian' || otherFood == 'vegan' || otherFood == 'eggetarian')) ||
//         (otherFood == 'jain' && (userFood == 'vegetarian' || userFood == 'vegan' || userFood == 'eggetarian'))
//     ) {
//       // A Jain living with a Vegetarian/Vegan/Eggetarian is generally compatible, but might have stricter rules for cooking.
//       score += 0.75 * habitsWeight;
//     } else if (
//     // 'Other' is a bit of a wildcard, give a small score for any match if one is 'Other'
//     (userFood == 'other' || otherFood == 'other')
//     ) {
//       // If one person selects 'Other', it suggests flexibility or a niche diet.
//       // This provides a minimal match, encouraging discussion.
//       score += 0.2 * habitsWeight;
//     }
// // If none of the above, score remains 0 for food preference.
//
//     // Cleanliness
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userCleanliness = userProfile.cleanlinessLevel.toLowerCase();
//     final otherCleanliness = otherProfile.cleanliness.toLowerCase();
//
// // Define compatibility rules and assign scores (adjust weights as needed)
// // Max score for cleanliness remains 2 * habitsWeight.
//
//     if (userCleanliness == otherCleanliness) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // Very Tidy is compatible with Moderately Tidy
//     (userCleanliness == 'very tidy' && otherCleanliness == 'moderately tidy') ||
//         (otherCleanliness == 'very tidy' && userCleanliness == 'moderately tidy')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility, but not perfect
//     } else if (
//     // Moderately Tidy is compatible with Flexible
//     (userCleanliness == 'moderately tidy' && otherCleanliness == 'flexible') ||
//         (otherCleanliness == 'moderately tidy' && userCleanliness == 'flexible')
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility
//     } else if (
//     // Flexible is compatible with Can be messy at times, or any other not perfectly matched
//     (userCleanliness == 'flexible' && otherCleanliness == 'can be messy at times') ||
//         (otherCleanliness == 'flexible' && userCleanliness == 'can be messy at times')
//     ) {
//       score += 0.5 * habitsWeight; // Low compatibility, but some tolerance
//     } else if (
//     // Very Tidy vs Flexible/Messy (less ideal but not zero if 'flexible' is tolerant)
//     (userCleanliness == 'very tidy' && (otherCleanliness == 'flexible' || otherCleanliness == 'can be messy at times')) ||
//         (otherCleanliness == 'very tidy' && (userCleanliness == 'flexible' || userCleanliness == 'can be messy at times'))
//     ) {
//       score += 0.2 * habitsWeight; // Very low compatibility, indicates potential friction
//     }
// // For 'Can be messy at times' matching 'Very Tidy' or 'Moderately Tidy' from the other side,
// // the score would implicitly be 0 unless specifically handled and given a small penalty or score.
// // The current logic above only gives points, doesn't penalize.
//
//     // Noise Level (e.g., quiet matches quiet, tolerant matches anything)
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userNoise = userProfile.noiseLevel.toLowerCase();
//     final otherNoise = otherProfile.noiseLevel.toLowerCase();
//
// // Max score for noise level remains 2 * habitsWeight.
//
//     if (userNoise == otherNoise) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Very quiet' prefers 'Moderate noise' next best
//     (userNoise == 'very quiet' && otherNoise == 'moderate noise') ||
//         (otherNoise == 'very quiet' && userNoise == 'moderate noise')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Moderate noise' is generally compatible with 'Very quiet' and 'Lively' to some extent
//     (userNoise == 'moderate noise' && (otherNoise == 'very quiet' || otherNoise == 'lively')) ||
//         (otherNoise == 'moderate noise' && (userNoise == 'very quiet' || userNoise == 'lively'))
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility
//     } else if (
//     // 'Flexible' is highly compatible with almost anything (except perhaps a very stark contrast)
//     (userNoise == 'flexible' && (otherNoise == 'very quiet' || otherNoise == 'moderate noise' || otherNoise == 'lively')) ||
//         (otherNoise == 'flexible' && (userNoise == 'very quiet' || userNoise == 'moderate noise' || userNoise == 'lively'))
//     ) {
//       score += 1.8 * habitsWeight; // High score for flexibility, nearly perfect match
//     } else if (
//     // 'Lively' and 'Very quiet' are generally incompatible, but if one is 'Flexible', it's accounted for.
//     // Explicitly handling 'Lively' and 'Very quiet' mismatch if no flexibility.
//     (userNoise == 'lively' && otherNoise == 'very quiet') ||
//         (otherNoise == 'lively' && userNoise == 'very quiet')
//     ) {
//       // These are generally a bad match unless one is flexible. Score 0 here, or a small penalty if desired.
//       // For now, by falling through, it will just add 0 points.
//       // If you want to penalize, add: score -= 1.0 * habitsWeight; (ensure score doesn't go below 0 later)
//     }
// // Any other combinations (e.g., 'Very quiet' with 'Lively' directly, without a 'Flexible' in between)
// // will implicitly get 0 points if not covered by the above positive scoring rules.
//
//     // Social Habits
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userSocial = userProfile.socialPreferences.toLowerCase();
//     final otherSocial = otherProfile.socialHabits.toLowerCase();
//
// // Max score for social habits remains 1 * habitsWeight.
//
//     if (userSocial == otherSocial) {
//       // Perfect direct match (e.g., both 'Social & outgoing')
//       score += 1 * habitsWeight;
//     } else if (
//     // 'Flexible' is highly compatible with almost everything
//     (userSocial == 'flexible' && (otherSocial == 'social & outgoing' || otherSocial == 'occasional gatherings' || otherSocial == 'quiet & private')) ||
//         (otherSocial == 'flexible' && (userSocial == 'social & outgoing' || userSocial == 'occasional gatherings' || userSocial == 'quiet & private'))
//     ) {
//       score += 0.9 * habitsWeight; // Very high compatibility
//     } else if (
//     // 'Social & outgoing' is compatible with 'Occasional gatherings'
//     (userSocial == 'social & outgoing' && otherSocial == 'occasional gatherings') ||
//         (otherSocial == 'social & outgoing' && userSocial == 'occasional gatherings')
//     ) {
//       score += 0.7 * habitsWeight; // Good compatibility
//     } else if (
//     // 'Occasional gatherings' is compatible with 'Quiet & private'
//     // (As long as occasional means not frequent disruption for the quiet person)
//     (userSocial == 'occasional gatherings' && otherSocial == 'quiet & private') ||
//         (otherSocial == 'occasional gatherings' && userSocial == 'quiet & private')
//     ) {
//       score += 0.6 * habitsWeight; // Moderate compatibility
//     } else if (
//     // 'Social & outgoing' and 'Quiet & private' (if not flexible) generally a low match
//     (userSocial == 'social & outgoing' && otherSocial == 'quiet & private') ||
//         (otherSocial == 'social & outgoing' && userSocial == 'quiet & private')
//     ) {
//       // These are generally considered a poor match, assign a minimal score.
//       score += 0.2 * habitsWeight;
//     }
// // For any other combinations, the score for this attribute will implicitly remain 0.
//
//     // Pet Ownership/Tolerance
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userOwns = userProfile.petOwnership.toLowerCase(); // 'yes', 'no', 'planning to get one'
//     final otherOwns = otherProfile.petOwnership.toLowerCase(); // 'yes', 'no', 'planning to get one'
//
// // Assuming petTolerance fields might still exist on both profiles
// // Use null-aware operator '??' and default to empty string to avoid null issues
//     final userTolerates = (userProfile.petTolerance ?? '').toLowerCase(); // e.g., 'tolerates pets' or some other value
//     final otherTolerates = (otherProfile.petTolerance ?? '').toLowerCase(); // e.g., 'tolerates pets' or some other value
//
// // Initialize a sub-score for pet compatibility for this iteration
//     double currentPetScore = 0;
//
// // Case 1: Both have NO pets
//     if (userOwns == 'no' && otherOwns == 'no') {
//       currentPetScore = 2.0 * habitsWeight; // Perfect match
//     }
// // Case 2: Both have pets ('Yes')
//     else if (userOwns == 'yes' && otherOwns == 'yes') {
//       currentPetScore = 2.0 * habitsWeight; // Perfect match, they share the pet-loving lifestyle
//     }
// // Case 3: One has pets ('Yes'), the other tolerates pets
//     else if ((userOwns == 'yes' && otherTolerates == 'tolerates pets') ||
//         (otherOwns == 'yes' && userTolerates == 'tolerates pets')) {
//       currentPetScore = 2.0 * habitsWeight; // High compatibility, tolerance works
//     }
// // Case 4: Both are planning to get pets
//     else if (userOwns == 'planning to get one' && otherOwns == 'planning to get one') {
//       currentPetScore = 1.8 * habitsWeight; // Good match on future intent
//     }
// // Case 5: One has pets ('Yes'), the other is 'Planning to get one'
// // This implies mutual understanding and potential shared pet-related future
//     else if ((userOwns == 'yes' && otherOwns == 'planning to get one') ||
//         (otherOwns == 'yes' && userOwns == 'planning to get one')) {
//       currentPetScore = 1.5 * habitsWeight; // Good compatibility
//     }
// // Case 6: One has 'No' pets, the other is 'Planning to get one' AND the 'No' person tolerates pets
//     else if ((userOwns == 'no' && otherOwns == 'planning to get one' && userTolerates == 'tolerates pets') ||
//         (otherOwns == 'no' && userOwns == 'planning to get one' && otherTolerates == 'tolerates pets')) {
//       currentPetScore = 1.0 * habitsWeight; // Acceptable if the 'No' person is explicitly tolerant
//     }
// // Case 7: One is 'Planning to get one', and the other explicitly 'Tolerates pets'
// // This covers cases where the 'tolerates' person doesn't necessarily have a pet or says 'no pets' but tolerates
//     else if ((userOwns == 'planning to get one' && otherTolerates == 'tolerates pets') ||
//         (otherOwns == 'planning to get one' && userTolerates == 'tolerates pets')) {
//       currentPetScore = 1.0 * habitsWeight; // Positive match based on tolerance
//     }
//
// // Add the calculated score for pet compatibility to the total score
//     score += currentPetScore;
//
//     // Add more habit comparisons...
// // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userVisitors = userProfile.visitorsPolicy.toLowerCase();
//     final otherVisitors = otherProfile.visitorsPolicy.toLowerCase();
//
// // Max score for visitors policy remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userVisitors == otherVisitors) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Frequent visitors' and 'Occasional visitors' are quite compatible
//     (userVisitors == 'frequent visitors' && otherVisitors == 'occasional visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'occasional visitors')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Occasional visitors' and 'Rarely have visitors' are compatible
//     (userVisitors == 'occasional visitors' && otherVisitors == 'rarely have visitors') ||
//         (otherVisitors == 'occasional visitors' && userVisitors == 'rarely have visitors')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Rarely have visitors' and 'No visitors' are quite compatible
//     (userVisitors == 'rarely have visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'rarely have visitors' && userVisitors == 'no visitors')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Occasional visitors' can sometimes tolerate 'No visitors' (if they rarely have them)
//     (userVisitors == 'occasional visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'occasional visitors' && userVisitors == 'no visitors')
//     ) {
//       score += 0.5 * habitsWeight; // Low compatibility
//     } else if (
//     // 'Frequent visitors' and 'Rarely have visitors' are generally a poor match
//     (userVisitors == 'frequent visitors' && otherVisitors == 'rarely have visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'rarely have visitors')
//     ) {
//       score += 0.2 * habitsWeight; // Very low compatibility, indicates friction
//     } else if (
//     // 'Frequent visitors' and 'No visitors' are highly incompatible
//     (userVisitors == 'frequent visitors' && otherVisitors == 'no visitors') ||
//         (otherVisitors == 'frequent visitors' && userVisitors == 'no visitors')
//     ) {
//       // Generally a strong mismatch. Assign 0 points or a small penalty if desired.
//       // For now, it will simply not add points here.
//       // If you want to penalize, add: score -= 1.0 * habitsWeight; (ensure score doesn't go below 0 later)
//     }
// // Any other combinations not explicitly covered above will implicitly add 0 points.
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userSchedule = userProfile.sleepingSchedule.toLowerCase();
//     final otherSchedule = otherProfile.sleepingSchedule.toLowerCase();
//
// // Max score for sleeping schedule remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userSchedule == otherSchedule) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Flexible' is highly compatible with 'Early riser' or 'Night Owl'
//     (userSchedule == 'flexible' && (otherSchedule == 'early riser' || otherSchedule == 'night owl')) ||
//         (otherSchedule == 'flexible' && (userSchedule == 'early riser' || userSchedule == 'night owl'))
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Flexible' is compatible with 'Irregular' (implies mutual understanding)
//     (userSchedule == 'flexible' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'flexible' && userSchedule == 'irregular')
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility
//     } else if (
//     // 'Early riser' and 'Irregular' might have some overlap/tolerance
//     (userSchedule == 'early riser' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'early riser' && userSchedule == 'irregular')
//     ) {
//       score += 0.5 * habitsWeight; // Some compatibility, potential for slight friction
//     } else if (
//     // 'Night Owl' and 'Irregular' might also have some overlap/tolerance
//     (userSchedule == 'night owl' && otherSchedule == 'irregular') ||
//         (otherSchedule == 'night owl' && userSchedule == 'irregular')
//     ) {
//       score += 0.5 * habitsWeight; // Some compatibility, potential for slight friction
//     }
// // For diametrically opposed cases like 'Early riser' vs 'Night Owl',
// // or 'Early riser'/'Night Owl' vs 'Irregular' without 'Flexible' as a mediator,
// // the score implicitly remains 0 from this section, which is appropriate for a potential mismatch.
// // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userWork = userProfile.workSchedule.toLowerCase();
//     final otherWork = otherProfile.workSchedule.toLowerCase();
//
// // Max score for work/study schedule remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userWork == otherWork) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Mixed' or 'Freelance/Flexible' are often highly compatible
//     (userWork == 'mixed' && (otherWork == 'freelance/flexible hours' || otherWork == '9-5 office hours' || otherWork == 'student schedule' || otherWork == 'night shifts')) ||
//         (otherWork == 'mixed' && (userWork == 'freelance/flexible hours' || userWork == '9-5 office hours' || userWork == 'student schedule' || userWork == 'night shifts')) ||
//         (userWork == 'freelance/flexible hours' && (otherWork == '9-5 office hours' || otherWork == 'student schedule')) ||
//         (otherWork == 'freelance/flexible hours' && (userWork == '9-5 office hours' || userWork == 'student schedule'))
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility for adaptable or daytime schedules
//     } else if (
//     // '9-5 Office hours' and 'Student schedule' often align somewhat
//     (userWork == '9-5 office hours' && otherWork == 'student schedule') ||
//         (otherWork == '9-5 office hours' && userWork == 'student schedule')
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility
//     } else if (
//     // 'Freelance/Flexible hours' and 'Night shifts' might work (one awake while other sleeps)
//     (userWork == 'freelance/flexible hours' && otherWork == 'night shifts') ||
//         (otherWork == 'freelance/flexible hours' && userWork == 'night shifts')
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility due to non-overlapping primary hours
//     } else if (
//     // 'Night shifts' and 'Student schedule' are generally less compatible
//     (userWork == 'night shifts' && otherWork == 'student schedule') ||
//         (otherWork == 'night shifts' && userWork == 'student schedule')
//     ) {
//       score += 0.5 * habitsWeight; // Low compatibility, potential for noise conflicts
//     } else if (
//     // '9-5 Office hours' and 'Night shifts' are generally highly incompatible
//     (userWork == '9-5 office hours' && otherWork == 'night shifts') ||
//         (otherWork == '9-5 office hours' && userWork == 'night shifts')
//     ) {
//       // Very low compatibility due to conflicting sleep/activity times.
//       score += 0.2 * habitsWeight;
//     }
//
//
//     final userSharing = userProfile.sharingCommonSpaces.toLowerCase();
//     final otherSharing = otherProfile.sharingCommonSpaces.toLowerCase();
//
// // Max score for sharing habits remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userSharing == otherSharing) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Flexible' is highly compatible with most options
//     (userSharing == 'flexible' && (otherSharing == 'share everything' || otherSharing == 'share some items' || otherSharing == 'prefer separate items')) ||
//         (otherSharing == 'flexible' && (userSharing == 'share everything' || userSharing == 'share some items' || userSharing == 'prefer separate items'))
//     ) {
//       score += 1.8 * habitsWeight; // Very high compatibility
//     } else if (
//     // 'Share everything' and 'Share some items' are generally compatible
//     (userSharing == 'share everything' && otherSharing == 'share some items') ||
//         (otherSharing == 'share everything' && userSharing == 'share some items')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Share some items' and 'Prefer separate items' can work
//     (userSharing == 'share some items' && otherSharing == 'prefer separate items') ||
//         (otherSharing == 'share some items' && userSharing == 'prefer separate items')
//     ) {
//       score += 1.0 * habitsWeight; // Moderate compatibility
//     } else if (
//     // 'Share everything' and 'Prefer separate items' are less ideal but sometimes negotiable
//     (userSharing == 'share everything' && otherSharing == 'prefer separate items') ||
//         (otherSharing == 'share everything' && userSharing == 'prefer separate items')
//     ) {
//       score += 0.5 * habitsWeight; // Low compatibility, potential for friction
//     }
//
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userGuests = userProfile.guestsOvernightPolicy.toLowerCase();
//     final otherGuests = otherProfile.guestsOvernightPolicy.toLowerCase();
//
// // Max score for guests overnight policy remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userGuests == otherGuests) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Frequently' and 'Occasionally' are quite compatible
//     (userGuests == 'frequently' && otherGuests == 'occasionally') ||
//         (otherGuests == 'frequently' && userGuests == 'occasionally')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Occasionally' and 'Rarely' are compatible
//     (userGuests == 'occasionally' && otherGuests == 'rarely') ||
//         (otherGuests == 'occasionally' && userGuests == 'rarely')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Rarely' and 'Never' are quite compatible
//     (userGuests == 'rarely' && otherGuests == 'never') ||
//         (otherGuests == 'rarely' && userGuests == 'never')
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Occasionally' and 'Never' - less ideal but possible if occasional is truly infrequent
//     (userGuests == 'occasionally' && otherGuests == 'never') ||
//         (otherGuests == 'occasionally' && userGuests == 'never')
//     ) {
//       score += 0.5 * habitsWeight; // Low compatibility
//     } else if (
//     // 'Frequently' and 'Rarely' - generally a poor match
//     (userGuests == 'frequently' && otherGuests == 'rarely') ||
//         (otherGuests == 'frequently' && userGuests == 'rarely')
//     ) {
//       score += 0.2 * habitsWeight; // Very low compatibility, indicates friction
//     } else if (
//     // 'Frequently' and 'Never' - highly incompatible
//     (userGuests == 'frequently' && otherGuests == 'never') ||
//         (otherGuests == 'frequently' && userGuests == 'never')
//     ) {
//       // This is a strong mismatch. It will implicitly add 0 points.
//       // If you wish to actively penalize, uncomment the line below.
//       // score -= 1.0 * habitsWeight; // Example penalty
//     }
//
//     // Inside _calculateMatchPercentage function, for both profile type comparisons
// // (You'll need to duplicate this block for both 'SeekingFlatmateProfile' vs 'FlatListingProfile'
// // and 'FlatListingProfile' vs 'SeekingFlatmateProfile' if the variable names differ)
//
//     final userSpaceSocial = userProfile.personalSpaceVsSocialization.toLowerCase();
//     final otherSpaceSocial = otherProfile.personalSpaceVsSocialization.toLowerCase();
//
// // Max score for personal space vs. socialization remains 2 * habitsWeight.
// // (Score will be added to the main 'score' variable)
//
//     if (userSpaceSocial == otherSpaceSocial) {
//       // Perfect direct match
//       score += 2 * habitsWeight;
//     } else if (
//     // 'Flexible' is highly compatible with most options
//     (userSpaceSocial == 'flexible' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'enjoy a balance' || otherSpaceSocial == 'prefer more socialization')) ||
//         (otherSpaceSocial == 'flexible' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'enjoy a balance' || userSpaceSocial == 'prefer more socialization'))
//     ) {
//       score += 1.8 * habitsWeight; // Very high compatibility
//     } else if (
//     // 'Enjoy a balance' is compatible with 'Value personal space highly' or 'Prefer more socialization'
//     (userSpaceSocial == 'enjoy a balance' && (otherSpaceSocial == 'value personal space highly' || otherSpaceSocial == 'prefer more socialization')) ||
//         (otherSpaceSocial == 'enjoy a balance' && (userSpaceSocial == 'value personal space highly' || userSpaceSocial == 'prefer more socialization'))
//     ) {
//       score += 1.5 * habitsWeight; // High compatibility
//     } else if (
//     // 'Value personal space highly' and 'Prefer more socialization' are generally a poor direct match
//     (userSpaceSocial == 'value personal space highly' && otherSpaceSocial == 'prefer more socialization') ||
//         (otherSpaceSocial == 'value personal space highly' && userSpaceSocial == 'prefer more socialization')
//     ) {
//       // This is a direct conflict. Assign a very low score.
//       score += 0.2 * habitsWeight;
//     }
// // Any other combinations not explicitly covered above will implicitly add 0 points.
// // Any other combinations not explicitly covered above will implicitly add 0 points.
// // Any other combinations not explicitly covered above will implicitly add 0 points.
//     // --- Requirements/Preferences Comparison (from flat lister's perspective) ---
//     maxScore += 5 * requirementsPreferencesWeight;
//
//     // Preferred Flatmate Gender
//     if (userProfile.preferredGender.toLowerCase() == otherProfile.gender.toLowerCase() || userProfile.preferredGender.toLowerCase() == 'any') {
//       score += 1 * requirementsPreferencesWeight;
//     }
//
//     // Preferred Flatmate Age Group (already handled with basic info)
//
//     // Preferred Occupation (already handled with basic info)
//
//     // Preferred Habits (overlap with other user's actual habits)
//     final preferredHabitsIntersection = userProfile.preferredHabits.toSet().intersection([
//       otherProfile.smokingHabits,
//       otherProfile.drinkingHabits,
//       otherProfile.foodPreference,
//       otherProfile.cleanliness,
//       otherProfile.noiseLevel,
//       otherProfile.socialHabits,
//       otherProfile.guestsFrequency,
//       otherProfile.visitorsPolicy,
//       otherProfile.petOwnership,
//       otherProfile.petTolerance,
//       otherProfile.sleepingSchedule,
//       otherProfile.workSchedule,
//       otherProfile.sharingCommonSpaces,
//       otherProfile.guestsOvernightPolicy,
//       otherProfile.personalSpaceVsSocialization,
//     ].map((e) => e.toLowerCase()).toSet());
//     score += (preferredHabitsIntersection.length / (userProfile.preferredHabits.length > 0 ? userProfile.preferredHabits.length : 1)) * 2 * requirementsPreferencesWeight;
//
//     // Ideal Qualities (overlap)
//     final idealQualitiesIntersection = userProfile.flatmateIdealQualities.toSet().intersection(otherProfile.idealQualities.toSet());
//     score += (idealQualitiesIntersection.length / (userProfile.flatmateIdealQualities.length > 0 ? userProfile.flatmateIdealQualities.length : 1)) * 2 * requirementsPreferencesWeight;
//
//     // Deal Breakers (penalty for overlap)
//     final dealBreakersIntersection = userProfile.flatmateDealBreakers.toSet().intersection(otherProfile.dealBreakers.toSet());
//     score -= (dealBreakersIntersection.length * 5) * requirementsPreferencesWeight; // Penalize heavily
//
//   } else {
//     return 0.0; // Mismatch in profile types or unexpected scenario
//   }
//
//   // Ensure score doesn't go below zero
//   if (score < 0) score = 0;
//
//   // Calculate percentage, ensuring maxScore is not zero to avoid division by zero
//   double percentage = (maxScore > 0) ? (score / maxScore) * 100 : 0.0;
//   return percentage.clamp(0.0, 100.0); // Ensure it's between 0 and 100
// }
