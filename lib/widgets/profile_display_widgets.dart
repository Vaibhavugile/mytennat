// lib/widgets/profile_display_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart'; // Import your SeekingFlatmateProfile
import 'package:mytennat/screens/flatmate_profile_screen.dart'; // Import your FlatListingProfile

// --- Color Palettes for Vibrant Icons ---
// Each entry is a pair: {background_color_light_shade, icon_color_dark_shade}
final List<MapEntry<Color, Color>> _vibrantColorPalettes = [
  MapEntry(Colors.purple.shade100, Colors.purple.shade700),
  MapEntry(Colors.green.shade100, Colors.green.shade700),
  MapEntry(Colors.blue.shade100, Colors.blue.shade700),
  MapEntry(Colors.orange.shade100, Colors.orange.shade700),
  MapEntry(Colors.pink.shade100, Colors.pink.shade700),
  MapEntry(Colors.teal.shade100, Colors.teal.shade700),
  MapEntry(Colors.indigo.shade100, Colors.indigo.shade700),
  MapEntry(Colors.amber.shade100, Colors.amber.shade700),
];

// Helper widget to build consistent sections (Cards)
Widget _buildSection({
  required String title,
  required List<Widget> children,
  EdgeInsetsGeometry? margin,
  EdgeInsetsGeometry? padding,
}) {
  return Card(
    margin: margin ?? const EdgeInsets.symmetric(vertical: 6, horizontal: 12), // Increased margin
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Increased border radius
    elevation: 3.0, // Increased elevation
    child: Padding(
      padding: padding ?? const EdgeInsets.all(12.0), // Increased padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18, // Increased title font
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const Divider(height: 10, thickness: 1.0, color: Colors.grey), // Increased height and thickness
          ...children,
        ],
      ),
    ),
  );
}

// Helper widget to display a single profile field (label: value format) with an optional icon
Widget _buildProfileField(String label, String? value, {IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0), // Increased vertical padding
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.redAccent, size: 18), // Increased icon size
          const SizedBox(width: 8), // Increased spacing
        ],
        SizedBox(
          width: 90, // Increased fixed width for labels
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14, // Increased font
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 10), // Increased spacing
        Expanded(
          child: Text(
            value ?? 'N/A', // Display 'N/A' if value is null
            style: TextStyle(
              fontSize: 14, // Increased font
              color: value != null && value.isNotEmpty ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper for displaying list fields (Amenities, Habits, Qualities, Deal Breakers) with check chips
Widget _buildProfileListField(String label, List<String>? values) {
  if (values == null || values.isEmpty) {
    return _buildSection(
      title: label,
      children: const [
        Text(
          'N/A',
          style: TextStyle(fontSize: 14, color: Colors.grey), // Increased font
        ),
      ],
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Increased padding
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18, // Increased title font
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 10), // Increased spacing
        Wrap(
          spacing: 8.0, // Increased spacing between chips
          runSpacing: 8.0, // Increased run spacing between chip rows
          children: values
              .map(
                (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Increased padding within chips
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18), // Increased border radius for chips
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                item,
                style: const TextStyle(fontSize: 12), // Increased font for chip text
              ),
            ),
          )
              .toList(),
        ),
      ],
    ),
  );
}


// Comprehensive map for various characteristic values and their icons
final Map<String, IconData> _characteristicIcons = {
  // Common
  'Male': Icons.male,
  'Female': Icons.female,
  'Non-binary': Icons.transgender,
  'Prefer not to say': Icons.do_not_disturb_alt,
  'Yes': Icons.check_circle_outline,
  'No': Icons.cancel_outlined,
  'Any': Icons.all_inclusive,
  'Both': Icons.people_outline, // Changed for clarity
  'Other': Icons.category,

  // Habits & Lifestyle
  'Very Tidy': Icons.cleaning_services,
  'Moderately Tidy': Icons.wc, // Representing general cleanliness
  'Flexible': Icons.shuffle, // Representing adaptability
  'Can be messy at times': Icons.cleaning_services_rounded,
  'Social & outgoing': Icons.sentiment_very_satisfied,
  'Occasional gatherings': Icons.group_add,
  'Quiet & private': Icons.lock_person, // Represents personal space
  '9-5 Office hours': Icons.work,
  'Freelance/Flexible hours': Icons.laptop_chromebook,
  'Night shifts': Icons.nights_stay,
  'Student schedule': Icons.school,
  'Mixed': Icons.calendar_month, // Representing varied schedule
  'Very quiet': Icons.volume_mute,
  'Moderate noise': Icons.volume_down,
  'Lively': Icons.volume_up,
  'Never': Icons.no_drinks, // More specific for habits
  'Occasionally': Icons.local_bar_outlined, // For drinks
  'Socially': Icons.wine_bar,
  'Regularly': Icons.liquor, // Stronger icon for regular drinking
  'Vegetarian': Icons.local_florist, // More appealing vegetarian icon
  'Non-Vegetarian': Icons.fastfood,
  'Vegan': Icons.eco,
  'Eggetarian': Icons.egg,
  'Jain': Icons.self_improvement, // Represents a lifestyle choice
  'Frequently': Icons.group_add, // For guests/overnight policy
  'Rarely': Icons.event_busy, // Less frequent events
  'Frequent visitors': Icons.people_alt,
  'Occasional visitors': Icons.person_add_alt_1,
  'Rarely have visitors': Icons.person_off,
  'No visitors': Icons.do_not_disturb_alt,
  'Planning to get one': Icons.pets_outlined,
  'Comfortable with pets': Icons.pets,
  'Tolerant of pets': Icons.pets_rounded, // Slightly different pet icon
  'Prefer no pets': Icons.no_backpack, // No pets allowed
  'Allergic to pets': Icons.masks, // Represents allergies
  'Early riser': Icons.wb_sunny,
  'Night Owl': Icons.bedtime, // More specific for night owl
  'Irregular': Icons.schedule_send, // Irregular schedule
  'Share everything': Icons.share,
  'Share some items': Icons.apps, // Apps can represent shared items
  'Prefer separate items': Icons.lock,
  'Value personal space highly': Icons.person_off_outlined, // Focus on personal space
  'Enjoy a balance': Icons.balance,
  'Prefer more socialization': Icons.sentiment_satisfied_alt,

  // Flat Details
  'Studio Apartment': Icons.single_bed, // Studio specific
  '1BHK': Icons.home,
  '2BHK': Icons.home_work,
  '3BHK': Icons.villa,
  '4BHK+': Icons.castle, // Larger flat
  'Furnished': Icons.chair,
  'Semi-furnished': Icons.table_restaurant,
  'Unfurnished': Icons.house_siding, // Empty house
  'Boys': Icons.boy,
  'Girls': Icons.girl,
  'Couples': Icons.people_alt,
  'Anyone': Icons.groups_2,
  'Attached Bathroom': Icons.bathtub,
  'Shared Bathroom': Icons.shower,
  'Yes, for Car': Icons.directions_car,
  'Yes, for Two-wheeler': Icons.two_wheeler,
  'Only in living room': Icons.living,
  'Only in bedroom': Icons.bed,
  '18-24': Icons.looks_one,
  '25-30': Icons.looks_two,
  '30-40': Icons.looks_3,
  '40+': Icons.looks_4,
  'No preference': Icons.favorite_border,
  'Student': Icons.school,
  'Working Professional': Icons.business_center,
};

// Helper for displaying a single characteristic with icon and text, formatted as a colorful card
Widget _buildIconValueCard(String label, String? value, {Color? backgroundColor, Color? iconColor}) {
  if (value == null || value.isEmpty || value == 'N/A') return Container();

  final icon = _characteristicIcons[value] ?? Icons.category;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Add the label here
      Text(
        label, // Display the label (e.g., "Smoking Habits")
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87), // Increased font for label
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4), // Increased space
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.grey.shade100,
        ),
        padding: const EdgeInsets.all(10), // Increased padding
        child: Icon(icon, size: 28, color: iconColor ?? Colors.black87), // Increased icon size
      ),
      const SizedBox(height: 6), // Increased spacing
      Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), // Increased font
      ),
    ],
  );
}


// Helper for displaying a grid of characteristics, like "Habits & Lifestyle"
Widget _buildCharacteristicGrid(String title, List<MapEntry<String, String?>> characteristics) {
  final validItems = characteristics.where((e) => e.value != null && e.value!.isNotEmpty && e.value != 'N/A').toList();

  if (validItems.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Increased padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)), // Increased title
          const SizedBox(height: 8), // Increased spacing
          const Text('No details specified.', style: TextStyle(fontSize: 14, color: Colors.grey)), // Increased font
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Increased padding
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)), // Increased title
        const SizedBox(height: 10), // Increased spacing
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent( // Changed to MaxCrossAxisExtent
            maxCrossAxisExtent: 180.0, // Increased max width for each item
            crossAxisSpacing: 10, // Increased spacing
            mainAxisSpacing: 10, // Increased spacing
            childAspectRatio: 1.1, // Adjusted to give more height for larger content
          ),
          itemCount: validItems.length,
          itemBuilder: (context, index) {
            final entry = validItems[index];
            final palette = _vibrantColorPalettes[index % _vibrantColorPalettes.length];
            return _buildIconValueCard(entry.key, entry.value, backgroundColor: palette.key, iconColor: palette.value);
          },
        ),
      ],
    ),
  );
}


// Helper for displaying preferences with custom icons in a grid (e.g., Night Owl, Early Bird)
// This map's icons are used directly, but now they'll get vibrant colors
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
      children: const [
        Text(
          'No preferences listed.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Increased padding
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 10), // Increased spacing
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent( // Changed to MaxCrossAxisExtent
            maxCrossAxisExtent: 140.0, // Increased max width for each item
            crossAxisSpacing: 10, // Increased spacing
            mainAxisSpacing: 10, // Increased spacing
            childAspectRatio: 1.0, // Adjusted to give more height for larger content
          ),
          itemCount: preferences.length,
          itemBuilder: (context, index) {
            final preference = preferences[index];
            final icon = _preferenceIcons[preference] ?? Icons.category;
            final palette = _vibrantColorPalettes[index % _vibrantColorPalettes.length];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.key,
                  ),
                  padding: const EdgeInsets.all(10), // Increased padding
                  child: Icon(icon, color: palette.value, size: 28), // Increased icon size
                ),
                const SizedBox(height: 6), // Increased spacing
                Text(
                  preference,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), // Increased font
                ),
              ],
            );
          },
        ),
      ],
    ),
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
            padding: const EdgeInsets.all(10.0), // Increased padding
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50, // Increased avatar size
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profile.imageUrls != null && profile.imageUrls!.isNotEmpty
                      ? NetworkImage(profile.imageUrls![0])
                      : null,
                  child: profile.imageUrls == null || profile.imageUrls!.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.grey[600]) // Increased icon size
                      : null,
                ),
                const SizedBox(height: 8), // Increased spacing
                Text(
                  profile.name ?? 'N/A',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Increased font
                ),
                Text(
                  '${profile.age?.toString() ?? 'N/A'} years old, ${profile.occupation ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]), // Increased font
                ),
                const SizedBox(height: 4), // Increased spacing
                Text(
                  'Looking in ${profile.desiredCity ?? 'N/A'}, ${profile.areaPreference ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]), // Increased font
                ),
                const SizedBox(height: 8), // Increased spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () { /* Handle chat */ },
                      icon: const Icon(Icons.chat, size: 20), // Increased icon size
                      label: const Text('Chat', style: TextStyle(fontSize: 14)), // Increased font
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Increased border radius
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Increased padding
                      ),
                    ),
                    const SizedBox(width: 8), // Increased spacing
                    ElevatedButton.icon(
                      onPressed: () { /* Handle call */ },
                      icon: const Icon(Icons.call, size: 20), // Increased icon size
                      label: const Text('Call', style: TextStyle(fontSize: 14)), // Increased font
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Increased border radius
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Increased padding
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Increased bottom spacing
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
          _buildCharacteristicGrid(
            'Habits & Lifestyle',
            [
              MapEntry('Cleanliness', profile.cleanliness),
              MapEntry('Social Habits', profile.socialHabits),
              MapEntry('Work Schedule', profile.workSchedule),
              MapEntry('Noise Level', profile.noiseLevel),
              MapEntry('Smoking Habits', profile.smokingHabits),
              MapEntry('Drinking Habits', profile.drinkingHabits),
              MapEntry('Food Preference', profile.foodPreference),
              MapEntry('Guests Freq.', profile.guestsFrequency),
              MapEntry('Visitors Policy', profile.visitorsPolicy),
              MapEntry('Pet Ownership', profile.petOwnership),
              MapEntry('Pet Tolerance', profile.petTolerance),
              MapEntry('Sleeping Schedule', profile.sleepingSchedule),
              MapEntry('Sharing Spaces', profile.sharingCommonSpaces),
              MapEntry('Guests Overnight Policy', profile.guestsOvernightPolicy),
              MapEntry('Personal Space vs. Socialization', profile.personalSpaceVsSocialization),
            ],
          ),

          // Preferences (using the new grid widget if there's a corresponding field)
          // Assuming 'preferences' is a list of strings in your SeekingFlatmateProfile
          // If you have a field like `profile.lifestylePreferences` that returns a List<String>
          // you would use it here. For demonstration, I'll use a placeholder or modify an existing one.
          // For now, I'll just put a dummy list for demonstration.
          // You will need to map your specific profile fields to these categories.
          _buildPreferenceGrid(
            'Lifestyle Preferences',
            // Replace with your actual profile field that holds lifestyle preferences
            // For example: profile.lifestylePreferences ?? []
            ['Night Owl', 'Early Bird', 'Studious', 'Fitness Freak', 'Sporty', 'Wanderer', 'Party Lover', 'Vegan', 'Music Lover'],
          ),

          // Flat Requirements
          _buildCharacteristicGrid(
            'Flat Requirements',
            [
              MapEntry('Preferred Flat Type', profile.preferredFlatType),
              MapEntry('Furnished Status', profile.preferredFurnishedStatus),
            ],
          ),
          _buildProfileListField('Amenities Desired', profile.amenitiesDesired),


          // Flatmate Preferences
          _buildCharacteristicGrid(
            'Flatmate Preferences',
            [
              MapEntry('Preferred Gender', profile.preferredFlatmateGender),
              MapEntry('Preferred Age', profile.preferredFlatmateAge),
              MapEntry('Preferred Occupation', profile.preferredOccupation),
            ],
          ),
          _buildProfileListField('Preferred Habits', profile.preferredHabits),
          _buildProfileListField('Ideal Qualities', profile.idealQualities),
          _buildProfileListField('Deal Breakers', profile.dealBreakers),

          // Profile Images (using the existing implementation)
          if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty)
            _buildSection(
              title: 'Profile Images',
              children: [
                SizedBox(
                  height: 150, // Increased height for image list
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: profile.imageUrls!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0), // Increased padding
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Increased border radius
                          child: Image.network(
                            profile.imageUrls![index],
                            width: 150, // Increased width
                            height: 150, // Increased height
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 40), // Increased icon size
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20), // Increased bottom padding
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
            padding: const EdgeInsets.all(10.0), // Increased padding
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50, // Increased avatar size
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profile.imageUrls != null && profile.imageUrls!.isNotEmpty
                      ? NetworkImage(profile.imageUrls![0])
                      : null,
                  child: profile.imageUrls == null || profile.imageUrls!.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.grey[600]) // Increased icon size
                      : null,
                ),
                const SizedBox(height: 8), // Increased spacing
                Text(
                  profile.ownerName ?? 'N/A',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Increased font
                ),
                Text(
                  '${profile.ownerAge?.toString() ?? 'N/A'} years old, ${profile.ownerOccupation ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]), // Increased font
                ),
                const SizedBox(height: 4), // Increased spacing
                Text(
                  'Flat in ${profile.desiredCity ?? 'N/A'}, ${profile.areaPreference ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]), // Increased font
                ),
                const SizedBox(height: 8), // Increased spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () { /* Handle chat */ },
                      icon: const Icon(Icons.chat, size: 20), // Increased icon size
                      label: const Text('Chat', style: TextStyle(fontSize: 14)), // Increased font
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Increased border radius
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Increased padding
                      ),
                    ),
                    const SizedBox(width: 8), // Increased spacing
                    ElevatedButton.icon(
                      onPressed: () { /* Handle call */ },
                      icon: const Icon(Icons.call, size: 20), // Increased icon size
                      label: const Text('Call', style: TextStyle(fontSize: 14)), // Increased font
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Increased border radius
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Increased padding
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Increased bottom spacing
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
          _buildCharacteristicGrid(
            'Owner\'s Habits & Lifestyle',
            [
              MapEntry('Smoking Habits', profile.smokingHabit),
              MapEntry('Drinking Habits', profile.drinkingHabit),
              MapEntry('Food Preference', profile.foodPreference),
              MapEntry('Cleanliness', profile.cleanlinessLevel),
              MapEntry('Noise Level', profile.noiseLevel),
              MapEntry('Social Preferences', profile.socialPreferences),
              MapEntry('Visitors Policy', profile.visitorsPolicy),
              MapEntry('Pet Ownership', profile.petOwnership),
              MapEntry('Pet Tolerance', profile.petTolerance),
              MapEntry('Sleeping Schedule', profile.sleepingSchedule),
              MapEntry('Work Schedule', profile.workSchedule),
              MapEntry('Sharing Spaces', profile.sharingCommonSpaces),
              MapEntry('Guests Overnight Policy', profile.guestsOvernightPolicy),
              MapEntry('Personal Space vs. Socialization', profile.personalSpaceVsSocialization),
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
              _buildCharacteristicGrid(
                '', // No specific title here as it's part of Flat Details
                [
                  MapEntry('Flat Type', profile.flatType),
                  MapEntry('Furnished Status', profile.furnishedStatus),
                  MapEntry('Available For', profile.availableFor),
                ],
              ),
              _buildProfileField('Availability Date', profile.availabilityDate != null
                  ? DateFormat('dd/MM/yyyy').format(profile.availabilityDate!)
                  : null, icon: Icons.calendar_today),
              _buildProfileField('Rent Price', '₹${profile.rentPrice ?? 'N/A'}', icon: Icons.currency_rupee),
              _buildProfileField('Deposit Amt.', '₹${profile.depositAmount ?? 'N/A'}', icon: Icons.money),
              _buildCharacteristicGrid(
                '', // No specific title here as it's part of Flat Details
                [
                  MapEntry('Bathroom Type', profile.bathroomType),
                  MapEntry('Balcony', profile.balconyAvailability),
                  MapEntry('Parking', profile.parkingAvailability),
                ],
              ),
              _buildProfileListField('Amenities', profile.amenities),
            ],
          ),

          // Flatmate Preferences
          _buildCharacteristicGrid(
            'Flatmate Preferences',
            [
              MapEntry('Preferred Gender', profile.preferredGender),
              MapEntry('Preferred Age', profile.preferredAgeGroup),
              MapEntry('Preferred Occupation', profile.preferredOccupation),
            ],
          ),
          _buildProfileListField('Preferred Habits', profile.preferredHabits),
          _buildProfileListField('Ideal Qualities', profile.flatmateIdealQualities),
          _buildProfileListField('Deal Breakers', profile.flatmateDealBreakers),

          // Flat Images (using the existing implementation)
          if (profile.imageUrls != null && profile.imageUrls!.isNotEmpty)
            _buildSection(
              title: 'Flat Images',
              children: [
                SizedBox(
                  height: 150, // Increased height for image list
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: profile.imageUrls!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0), // Increased padding
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Increased border radius
                          child: Image.network(
                            profile.imageUrls![index],
                            width: 150, // Increased width
                            height: 150, // Increased height
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 40), // Increased icon size
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20), // Increased bottom padding
        ],
      ),
    );
  }
}