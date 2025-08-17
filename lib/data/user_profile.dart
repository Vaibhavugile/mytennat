import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String uid;
  String name;
  int? age;
  String gender;
  String? profilePhotoUrl; // New field for the single profile photo
  String city; // New field for the user's city
  String? phoneNumber; // Keep if you still want to store it later
  String? occupation; // Will be part of "Complete Profile"
  String? religion; // Will be part of "Complete Profile"
  String? bio; // Will be part of "Complete Profile"
  List<String>? imageUrls; // General user profile images - might not be needed if only one profilePhotoUrl

  // Basic Habits (These fields will be moved here from original profile models later)
  String? smokingHabit;
  String? drinkingHabit;
  String? foodPreference;
  String? cleanlinessLevel;
  String? socialPreferences;
  String? petOwnership;
  String? petTolerance;
  String? guestsFrequency;


  UserProfile({
    required this.uid,
    this.name = '',
    this.age,
    this.gender = '',
    this.profilePhotoUrl,
    this.city = '',
    this.phoneNumber,
    this.occupation,
    this.religion,
    this.bio,
    this.imageUrls, // This might become redundant if profilePhotoUrl is enough
    this.smokingHabit,
    this.drinkingHabit,
    this.foodPreference,
    this.cleanlinessLevel,
    this.socialPreferences,
    this.petOwnership,
    this.petTolerance,
    this.guestsFrequency,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    // Extract habits if they exist
    Map<String, dynamic> habitsData = data['habits'] ?? {};

    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? '',
      age: data['age'] is int ? data['age'] : (data['age'] is String ? int.tryParse(data['age']) : null),
      gender: data['gender'] as String? ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      city: data['city'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      occupation: data['occupation'] as String?,
      religion: data['religion'] as String?,
      bio: data['bio'] as String?,
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList(), // Potentially redundant

      // Habits
      smokingHabit: habitsData['smoking'] as String?,
      drinkingHabit: habitsData['drinking'] as String?,
      foodPreference: habitsData['food'] as String?,
      cleanlinessLevel: habitsData['cleanliness'] as String?,
      socialPreferences: habitsData['socialPreferences'] as String?,
      petOwnership: habitsData['petOwnership'] as String?,
      petTolerance: habitsData['petTolerance'] as String?,
      guestsFrequency: habitsData['guestsFrequency'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'profilePhotoUrl': profilePhotoUrl,
      'city': city,
      'phoneNumber': phoneNumber,
      'occupation': occupation,
      'religion': religion,
      'bio': bio,
      'imageUrls': imageUrls, // Potentially redundant
      'habits': { // Nested map for habits
        'smoking': smokingHabit,
        'drinking': drinkingHabit,
        'food': foodPreference,
        'cleanliness': cleanlinessLevel,
        'socialPreferences': socialPreferences,
        'petOwnership': petOwnership,
        'petTolerance': petTolerance,
        'guestsFrequency': guestsFrequency,
      }
    };
  }
}