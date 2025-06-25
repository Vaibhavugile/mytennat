// lib/widgets/profile_display_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Import your SeekingFlatmateProfile
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // Import your FlatListingProfile

// Helper widget to build consistent sections
Widget _buildSection({
  required String title,
  required List<Widget> children,
  EdgeInsetsGeometry? margin, // Added margin parameter
  EdgeInsetsGeometry? padding, // Added padding parameter
}) {
  return Card(
    margin: margin ?? const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 4,
    child: Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const Divider(height: 20, thickness: 1.5, color: Colors.grey),
          ...children,
        ],
      ),
    ),
  );
}

// Helper widget to display a single profile field with an optional icon
Widget _buildProfileField(String label, String? value, {IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
        ],
        SizedBox(
          width: 100, // Fixed width for labels
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value ?? 'N/A', // Display 'N/A' if value is null
            style: TextStyle(
              fontSize: 16,
              color: value != null && value.isNotEmpty ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper for displaying list fields (Amenities, Habits, Qualities, Deal Breakers) with check icons
Widget _buildProfileListField(String label, List<String>? values) {
  if (values == null || values.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'N/A',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: values
              .map((item) => Chip(
            avatar: const Icon(Icons.check_circle, color: Colors.green),
            label: Text(item),
            backgroundColor: Colors.green.withOpacity(0.1),
            labelStyle: const TextStyle(color: Colors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.green),
            ),
          ))
              .toList(),
        ),
      ],
    ),
  );
}

// Helper for displaying preferences with custom icons in a grid
// A mapping of preference names to their respective icons
final Map<String, IconData> _preferenceIcons = {
  'Night Owl': Icons.nights_stay,
  'Early Bird': Icons.wb_sunny,
  'Studious': Icons.book,
  'Fitness Freak': Icons.fitness_center,
  'Sporty': Icons.sports_baseball,
  'Wanderer': Icons.map,
  'Party Lover': Icons.celebration,
  'Vegan': Icons.eco,
  'Music Lover': Icons.music_note,
  'Artist': Icons.palette,
  'Gamer': Icons.gamepad,
  'Cook': Icons.restaurant,
  // Add more as needed based on your actual preference options
};

Widget _buildPreferenceGrid(String title, List<String>? preferences) {
  if (preferences == null || preferences.isEmpty) {
    return _buildSection(
      title: title,
      children: [
        Text(
          'No preferences listed.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  return _buildSection(
    title: title,
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    padding: const EdgeInsets.all(16.0),
    children: [
      GridView.builder(
        shrinkWrap: true, // Important to make GridView work inside ListView
        physics: const NeverScrollableScrollPhysics(), // Disable GridView scrolling
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 icons per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1, // Make items square
        ),
        itemCount: preferences.length,
        itemBuilder: (context, index) {
          final preference = preferences[index];
          final icon = _preferenceIcons[preference] ?? Icons.category; // Default icon if not found
          return Container(
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.redAccent),
                const SizedBox(height: 8),
                Text(
                  preference,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}


// --- Main Display Widgets ---

class SeekingFlatmateProfileDisplay extends StatelessWidget {
  final SeekingFlatmateProfile profile;

  const SeekingFlatmateProfileDisplay({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seeking Flatmate Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          // Profile Header (similar to the image)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profile.imageUrls != null && profile.imageUrls!.isNotEmpty
                      ? NetworkImage(profile.imageUrls![0])
                      : null,
                  child: profile.imageUrls == null || profile.imageUrls!.isEmpty
                      ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  profile.name ?? 'N/A',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${profile.age?.toString() ?? 'N/A'} years old, ${profile.occupation ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 5),
                Text(
                  'Looking in ${profile.desiredCity ?? 'N/A'}, ${profile.areaPreference ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                // Add chat/call buttons if this is for another user's profile
                // You would need to pass in currentUserId and otherUser.uid to enable this logic
                // For now, these are illustrative and assume you'll add logic to determine if this is 'my' profile or someone else's
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () { /* Handle chat */ },
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () { /* Handle call */ },
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),


          // Basic Info
          _buildSection(
            title: 'Basic Information',
            children: [
              _buildProfileField('Gender', profile.gender, icon: Icons.person),
              _buildProfileField('Age', profile.age?.toString(), icon: Icons.cake),
              _buildProfileField('Occupation', profile.occupation, icon: Icons.work),
              _buildProfileField('Current Location', profile.currentLocation, icon: Icons.location_on),
              _buildProfileField('Desired City', profile.desiredCity, icon: Icons.location_city),
              _buildProfileField('Area Pref.', profile.areaPreference, icon: Icons.map),
              _buildProfileField('Move-in Date', profile.moveInDate != null
                  ? DateFormat('dd/MM/yyyy').format(profile.moveInDate!)
                  : null, icon: Icons.calendar_today),
              _buildProfileField('Budget Range',
                  '₹${profile.budgetMin ?? 'N/A'} - ₹${profile.budgetMax ?? 'N/A'}', icon: Icons.currency_rupee),
              _buildProfileField('Bio', profile.bio, icon: Icons.info),
            ],
          ),

          // Habits
          _buildSection(
            title: 'Habits & Lifestyle',
            children: [
              _buildProfileField('Cleanliness', profile.cleanliness, icon: Icons.cleaning_services),
              _buildProfileField('Social Habits', profile.socialHabits, icon: Icons.people_alt),
              _buildProfileField('Work Schedule', profile.workSchedule, icon: Icons.schedule),
              _buildProfileField('Noise Level', profile.noiseLevel, icon: Icons.volume_up),
              _buildProfileField('Smoking Habits', profile.smokingHabits, icon: Icons.smoking_rooms),
              _buildProfileField('Drinking Habits', profile.drinkingHabits, icon: Icons.local_bar),
              _buildProfileField('Food Preference', profile.foodPreference, icon: Icons.restaurant_menu),
              _buildProfileField('Guests Freq.', profile.guestsFrequency, icon: Icons.group),
              _buildProfileField('Visitors Policy', profile.visitorsPolicy, icon: Icons.policy),
              _buildProfileField('Pet Ownership', profile.petOwnership, icon: Icons.pets),
              _buildProfileField('Pet Tolerance', profile.petTolerance, icon: Icons.pets_outlined),
              _buildProfileField('Sleeping Sched.', profile.sleepingSchedule, icon: Icons.king_bed),
              _buildProfileField('Sharing Spaces', profile.sharingCommonSpaces, icon: Icons.chair),
              _buildProfileField('Guests Overnight', profile.guestsOvernightPolicy, icon: Icons.hotel),
              _buildProfileField('Personal Space', profile.personalSpaceVsSocialization, icon: Icons.space_bar),
            ],
          ),

          // Preferences (using the new grid widget if there's a corresponding field)
          // Assuming 'preferences' is a list of strings in your SeekingFlatmateProfile
          // If you have a field like `profile.lifestylePreferences` that returns a List<String>
          // you would use it here. For demonstration, I'll use a placeholder or modify an existing one.
          // Let's assume you have a `profile.lifestylePreferences` or similar field
          // For now, I'll just put a dummy list for demonstration.
          // You will need to map your specific profile fields to these categories.
          _buildPreferenceGrid(
            'Lifestyle Preferences',
            // Replace with your actual profile field that holds lifestyle preferences
            // For example: profile.lifestylePreferences ?? []
            ['Night Owl', 'Early Bird', 'Studious', 'Fitness Freak', 'Sporty', 'Wanderer', 'Party Lover', 'Vegan', 'Music Lover'],
          ),

          // Flat Requirements
          _buildSection(
            title: 'Flat Requirements',
            children: [
              _buildProfileField('Preferred Flat Type', profile.preferredFlatType, icon: Icons.home),
              _buildProfileField('Furnished Status', profile.preferredFurnishedStatus, icon: Icons.chair),
              _buildProfileListField('Amenities Desired', profile.amenitiesDesired),
            ],
          ),

          // Flatmate Preferences
          _buildSection(
            title: 'Flatmate Preferences',
            children: [
              _buildProfileField('Preferred Gender', profile.preferredFlatmateGender, icon: Icons.wc),
              _buildProfileField('Preferred Age', profile.preferredFlatmateAge, icon: Icons.group),
              _buildProfileField('Preferred Occupation', profile.preferredOccupation, icon: Icons.work_outline),
              _buildProfileListField('Preferred Habits', profile.preferredHabits),
              _buildProfileListField('Ideal Qualities', profile.idealQualities),
              _buildProfileListField('Deal Breakers', profile.dealBreakers),
            ],
          ),
          // Profile Images (using the existing implementation)
          if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty)
            _buildSection(
              title: 'Profile Images',
              children: [
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: profile.imageUrls!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            profile.imageUrls![index],
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }
}

class FlatListingProfileDisplay extends StatelessWidget {
  final FlatListingProfile profile;

  const FlatListingProfileDisplay({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flat Listing Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          // Profile Header (Owner Info)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profile.imageUrls != null && profile.imageUrls!.isNotEmpty
                      ? NetworkImage(profile.imageUrls![0])
                      : null,
                  child: profile.imageUrls == null || profile.imageUrls!.isEmpty
                      ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  profile.ownerName ?? 'N/A',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${profile.ownerAge?.toString() ?? 'N/A'} years old, ${profile.ownerOccupation ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 5),
                Text(
                  'Flat in ${profile.desiredCity ?? 'N/A'}, ${profile.areaPreference ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                // Add chat/call buttons if this is for another user's profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () { /* Handle chat */ },
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () { /* Handle call */ },
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Basic Info (Owner's Info)
          _buildSection(
            title: 'About The Owner / Current Flatmate',
            children: [
              _buildProfileField('Name', profile.ownerName, icon: Icons.person),
              _buildProfileField('Age', profile.ownerAge?.toString(), icon: Icons.cake),
              _buildProfileField('Gender', profile.ownerGender, icon: Icons.wc),
              _buildProfileField('Occupation', profile.ownerOccupation, icon: Icons.work),
              _buildProfileField('Bio', profile.ownerBio, icon: Icons.info),
            ],
          ),

          // Habits (Owner's Habits)
          _buildSection(
            title: 'Owner\'s Habits & Lifestyle',
            children: [
              _buildProfileField('Smoking Habits', profile.smokingHabit, icon: Icons.smoking_rooms),
              _buildProfileField('Drinking Habits', profile.drinkingHabit, icon: Icons.local_bar),
              _buildProfileField('Food Preference', profile.foodPreference, icon: Icons.restaurant_menu),
              _buildProfileField('Cleanliness', profile.cleanlinessLevel, icon: Icons.cleaning_services),
              _buildProfileField('Noise Level', profile.noiseLevel, icon: Icons.volume_up),
              _buildProfileField('Social Preferences', profile.socialPreferences, icon: Icons.people_alt),
              _buildProfileField('Visitors Policy', profile.visitorsPolicy, icon: Icons.policy),
              _buildProfileField('Pet Ownership', profile.petOwnership, icon: Icons.pets),
              _buildProfileField('Pet Tolerance', profile.petTolerance, icon: Icons.pets_outlined),
              _buildProfileField('Sleeping Sched.', profile.sleepingSchedule, icon: Icons.king_bed),
              _buildProfileField('Work Schedule', profile.workSchedule, icon: Icons.schedule),
              _buildProfileField('Sharing Spaces', profile.sharingCommonSpaces, icon: Icons.chair),
              _buildProfileField('Guests Overnight', profile.guestsOvernightPolicy, icon: Icons.hotel),
              _buildProfileField('Personal Space', profile.personalSpaceVsSocialization, icon: Icons.space_bar),
            ],
          ),

          // Flat Details
          _buildSection(
            title: 'Flat Details',
            children: [
              _buildProfileField('City', profile.desiredCity, icon: Icons.location_city),
              _buildProfileField('Area', profile.areaPreference, icon: Icons.map),
              _buildProfileField('Address', profile.address, icon: Icons.home),
              _buildProfileField('Landmark', profile.landmark, icon: Icons.push_pin),
              _buildProfileField('Description', profile.flatDescription, icon: Icons.description),
              _buildProfileField('Flat Type', profile.flatType, icon: Icons.apartment),
              _buildProfileField('Furnished Status', profile.furnishedStatus, icon: Icons.bed),
              _buildProfileField('Available For', profile.availableFor, icon: Icons.group),
              _buildProfileField('Availability Date', profile.availabilityDate != null
                  ? DateFormat('dd/MM/yyyy').format(profile.availabilityDate!)
                  : null, icon: Icons.calendar_today),
              _buildProfileField('Rent Price', '₹${profile.rentPrice ?? 'N/A'}', icon: Icons.currency_rupee),
              _buildProfileField('Deposit Amt.', '₹${profile.depositAmount ?? 'N/A'}', icon: Icons.money),
              _buildProfileField('Bathroom Type', profile.bathroomType, icon: Icons.bathtub),
              _buildProfileField('Balcony', profile.balconyAvailability, icon: Icons.balcony),
              _buildProfileField('Parking', profile.parkingAvailability, icon: Icons.local_parking),
              _buildProfileListField('Amenities', profile.amenities),
            ],
          ),

          // Flatmate Preferences
          _buildSection(
            title: 'Flatmate Preferences',
            children: [
              _buildProfileField('Preferred Gender', profile.preferredGender, icon: Icons.wc),
              _buildProfileField('Preferred Age', profile.preferredAgeGroup, icon: Icons.timelapse),
              _buildProfileField('Preferred Occupation', profile.preferredOccupation, icon: Icons.work_outline),
              _buildProfileListField('Preferred Habits', profile.preferredHabits),
              _buildProfileListField('Ideal Qualities', profile.flatmateIdealQualities),
              _buildProfileListField('Deal Breakers', profile.flatmateDealBreakers),
            ],
          ),
          // Flat Images (using the existing implementation)
          if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty)
            _buildSection(
              title: 'Flat Images',
              children: [
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: profile.imageUrls!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            profile.imageUrls![index],
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }
}
