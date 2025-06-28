// lib/widgets/profile_display_widgets.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytennat/screens/flat_with_flatmate_profile_screen.dart';
import 'package:mytennat/screens/flatmate_profile_screen.dart';
import 'package:lottie/lottie.dart'; // Import Lottie

// --- Color Palettes for Vibrant Icons ---
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
    margin: margin ?? const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3.0,
    child: Padding(
      padding: padding ?? const EdgeInsets.all(12.0),
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
          const Divider(height: 10, thickness: 1.0, color: Colors.grey),
          ...children,
        ],
      ),
    ),
  );
}

// Helper widget to display a single profile field (label: value format) with an optional icon - (kept for non-grid sections)
Widget _buildProfileField(String label, String? value, {IconData? icon, int iconColorIndex = 0}) {
  final palette = _vibrantColorPalettes[iconColorIndex % _vibrantColorPalettes.length];

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.key,
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(icon, color: palette.value, size: 18),
          ),
          const SizedBox(width: 10),
        ],
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize: 14,
              color: value != null && value.isNotEmpty ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper for displaying list fields (used for sections that remain as text chips, if any)
Widget _buildProfileListField(String label, List<String>? values) {
  if (values == null || values.isEmpty) {
    return _buildSection(
      title: label,
      children: const [
        Text(
          'N/A',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: values
              .map(
                (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                item,
                style: const TextStyle(fontSize: 12),
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
// This map will now store either IconData or a String path to a Lottie animation
final Map<String, dynamic> _characteristicIcons = {
  // Common
  'Male': 'assets/lottie/male.json', // Lottie path for Male
  'Female': 'assets/lottie/female.json', // Lottie path for Female
  'Non-binary': 'assets/lottie/non_binary.json', // Example Lottie
  'Prefer not to say': 'assets/lottie/do_not_disturb_alt.json',
  'Yes': 'assets/lottie/check.json', // Example Lottie
  'No': 'assets/lottie/cross.json', // Example Lottie
  'Any': Icons.all_inclusive,
  'Both': Icons.people_outline,
  'Other': Icons.category,

  // Basic Information Specific
  'Gender': 'assets/lottie/person.json', // Example Lottie
  'Age': 'assets/lottie/cake.json', // Example Lottie
  'Occupation': 'assets/lottie/occupation.json', // Example Lottie
  'Current Location': 'assets/lottie/current_location.json', // Example Lottie
  'Desired City': 'assets/lottie/location_city.json', // Example Lottie
  'Area Pref.': 'assets/lottie/current_location.json', // Example Lottie
  'Move-in Date': 'assets/lottie/calendar.json', // Example Lottie
  'Budget Range': 'assets/lottie/currency_rupee.json', // Example Lottie
  'Bio': 'assets/lottie/info.json', // Example Lottie
  'Name': Icons.person_outline,
  'Availability Date': 'assets/lottie/calendar.json', // Example Lottie
  'Rent Price': 'assets/lottie/currency_rupee.json', // Example Lottie
  'Deposit Amt.': 'assets/lottie/currency_rupee.json', // Example Lottie
  'Address': 'assets/lottie/address.json', // Example Lottie
  'Landmark': 'assets/lottie/current_location.json', // Example Lottie
  'Description': 'assets/lottie/info.json', // Example Lottie

  // Habits & Lifestyle
  'Very Tidy': 'assets/lottie/cleanliness.json', // Example Lottie
  'Moderately Tidy': 'assets/lottie/cleanliness.json', // Example Lottie
  'Flexible': 'assets/lottie/cleanliness.json', // Example Lottie
  'Can be messy at times': 'assets/lottie/cleanliness.json', // Example Lottie
  'Social & outgoing': 'assets/lottie/socialhabits.json', // Example Lottie
  'Occasional gatherings': 'assets/lottie/socialhabits.json', // Example Lottie
  'Quiet & private': 'assets/lottie/socialhabits.json', // Example Lottie
  '9-5 Office hours': 'assets/lottie/freelancer.json', // Example Lottie
  'Freelance/Flexible hours': 'assets/lottie/freelancer.json', // Example Lottie
  'Night shifts': 'assets/lottie/nightshift.json', // Example Lottie
  'Student schedule': 'assets/lottie/student.json', // Example Lottie
  'Mixed': 'assets/lottie/mixed_schedule.json', // Example Lottie
  'Very quiet': 'assets/lottie/noise level.json', // Example Lottie
  'Moderate noise': 'assets/lottie/noise level.json', // Example Lottie
  'Lively': 'assets/lottie/noise level.json', // Example Lottie
  'Never': 'assets/lottie/nosmoking.json', // Example Lottie
  'Occasionally': 'assets/lottie/smoking.json', // Example Lottie
  'Socially': 'assets/lottie/smoking.json', // Example Lottie
  'Regularly': 'assets/lottie/smoking.json', // Example Lottie
  'Vegetarian': 'assets/lottie/food.json', // Example Lottie
  'Non-Vegetarian': 'assets/lottie/food.json', // Example Lottie
  'Vegan': 'assets/lottie/food.json', // Example Lottie
  'Eggetarian': 'assets/lottie/food.json', // Example Lottie
  'Jain': 'assets/lottie/food.json', // Example Lottie
  'Frequently': 'assets/lottie/frequent_guests.json', // Example Lottie //
  'Rarely': 'assets/lottie/rare_guests.json', // Example Lottie//
  'Frequent visitors': 'assets/lottie/frequent_visitors.json', // Example Lottie //
  'Occasional visitors': 'assets/lottie/occasional_visitors.json', // Example Lottie //
  'Rarely have visitors': 'assets/lottie/rare_visitors.json', // Example Lottie//
  'No visitors': 'assets/lottie/no_visitors.json', // Example Lottie //
  'Planning to get one': 'assets/lottie/pets.json', // Example Lottie
  'Comfortable with pets': 'assets/lottie/pets.json', // Example Lottie
  'Tolerant of pets': 'assets/lottie/pets.json', // Example Lottie
  'Prefer no pets': 'assets/lottie/nopets.json', // Example Lottie
  'Allergic to pets': 'assets/lottie/nopets.json', // Example Lottie
  'Early riser': 'assets/lottie/earlyriserrr.json', // Example Lottie
  'Night Owl': 'assets/lottie/nightowl.json', // Lottie specific to Night Owl in _preferenceIcons too.
  'Irregular': 'assets/lottie/earlyriserrr.json', // Example Lottie
  'Share everything': 'assets/lottie/sharing.json', // Example Lottie
  'Share some items': 'assets/lottie/sharing.json', // Example Lottie
  'Prefer separate items': 'assets/lottie/sharing.json', // Example Lottie//
  'Value personal space highly': 'assets/lottie/socialization.json', // Example Lottie
  'Enjoy a balance': 'assets/lottie/socialization.json', // Example Lottie
  'Prefer more socialization': 'assets/lottie/socialization.json', // Example Lottie

  // Flat Details
  'Studio Apartment': 'assets/lottie/address.json', // Example Lottie
  '1BHK': 'assets/lottie/address.json', // Example Lottie
  '2BHK': 'assets/lottie/address.json', // Example Lottie
  '3BHK': 'assets/lottie/address.json', // Example Lottie
  '4BHK+': 'assets/lottie/address.json', // Example Lottie
  'Furnished': 'assets/lottie/furnished.json', // Example Lottie
  'Semi-furnished': 'assets/lottie/furnished.json', // Example Lottie//
  'Unfurnished': 'assets/lottie/furnished.json', // Example Lottie//
  'Boys': 'assets/lottie/male.json', // Example Lottie
  'Girls': 'assets/lottie/female.json', // Example Lottie//
  'Couples': 'assets/lottie/person.json', // Example Lottie'//
  'Anyone': 'assets/lottie/person.json', // Example Lottie//
  'Attached Bathroom': 'assets/lottie/attached_bathroom.json', // Example Lottie//
  'Shared Bathroom': 'assets/lottie/shared_bathroom.json', // Example Lottie//
  'Yes, for Car': 'assets/lottie/car_parking.json', // Example Lottie//
  'Yes, for Two-wheeler': 'assets/lottie/two_wheeler_parking.json', // Example Lottie//
  'Only in living room': 'assets/lottie/living_room.json', // Example Lottie//
  'Only in bedroom': 'assets/lottie/bedroom.json', // Example Lottie//
  '18-24': 'assets/lottie/cake.json', // Example Lottie
  '25-30': 'assets/lottie/cake.json', // Example Lottie
  '30-40': 'assets/lottie/cake.json', // Example Lottie
  '40+': 'assets/lottie/cake.json', // Example Lottie
  'No preference': Icons.favorite_border,
  'Student': 'assets/lottie/student.json', // Example Lottie
  'Working Professional': 'assets/lottie/freelancer.json', // Example Lottie
  'Bathroom Type': Icons.bathtub, // Keeping as IconData
  'Balcony': Icons.balcony, // Keeping as IconData
  'Parking': Icons.local_parking, // Keeping as IconData

  // Amenities Specific Icons
  'Wi-Fi': 'assets/lottie/wifi.json', // Example Lottie
  'AC': 'assets/lottie/ac.json', // Example Lottie
  'Geyser': 'assets/lottie/gyser.json', // Example Lottie
  'Washing Machine': 'assets/lottie/washingmachine.json', // Example Lottie
  'Refrigerator': 'assets/lottie/refrigerator.json', // Example Lottie
  'Microwave': 'assets/lottie/microwave.json', // Example Lottie
  'Maid Service': 'assets/lottie/cleaning.json', // Example Lottie
  'Cook': 'assets/lottie/cook.json', // Example Lottie
  'Gym': 'assets/lottie/gym.json', // Example Lottie
  'Swimming Pool': 'assets/lottie/swimming.json', // Example Lottie
  'Power Backup': 'assets/lottie/powerbackup.json', // Example Lottie
  'Security': 'assets/lottie/security.json', // Example Lottie

  // Preferred Habits
  'Non-smoker': 'assets/lottie/non_smoker.json', // Example Lottie
  'Non-drinker': 'assets/lottie/no_alcohol.json', // Reusing
  'Tidy': 'assets/lottie/cleaning_tidy.json', // Reusing
  'Quiet': 'assets/lottie/very_quiet.json', // Reusing
  'Social': 'assets/lottie/social_outgoing.json', // Reusing
  'Respectful': 'assets/lottie/respectful.json', // Example Lottie
  'Financially responsible': 'assets/lottie/financial_responsible.json', // Example Lottie
  'Pet-friendly': 'assets/lottie/comfortable_pets.json', // Reusing

  // Ideal Qualities
  'Communicative': 'assets/lottie/communicative.json', // Example Lottie
  'Friendly': 'assets/lottie/friendly.json', // Example Lottie
  'Responsible': 'assets/lottie/responsible.json', // Example Lottie
  'Social': 'assets/lottie/social_group.json', // Example Lottie
  'Independent': 'assets/lottie/independent.json', // Example Lottie
  'Shares chores': 'assets/lottie/chores.json', // Example Lottie
  'Financially stable': 'assets/lottie/financially_stable.json', // Example Lottie

  // Deal Breakers
  'Excessive Noise': 'assets/lottie/excessive_noise.json', // Example Lottie
  'Untidiness': 'assets/lottie/untidiness.json', // Example Lottie
  'Frequent Parties': 'assets/lottie/frequent_parties.json', // Example Lottie
  'Smoking Indoors': 'assets/lottie/smoking_indoors.json', // Example Lottie
  'Unpaid Bills': 'assets/lottie/unpaid_bills.json', // Example Lottie
  'Lack of Communication': 'assets/lottie/no_communication.json', // Example Lottie
  'Pets (if not allowed)': 'assets/lottie/no_pets_allowed.json', // Example Lottie
  'Late Night Guests': 'assets/lottie/late_guests.json', // Example Lottie
  'Drugs': 'assets/lottie/drugs.json', // Example Lottie
  'Disrespectful behavior': 'assets/lottie/disrespectful.json', // Example Lottie
};

// Helper for displaying a single characteristic with icon and text, formatted as a card-like structure (without a container)
Widget _buildIconValueCard(String label, String? value, {Color? backgroundColor, Color? iconColor}) {
  if (value == null || value.isEmpty || value == 'N/A') return const SizedBox.shrink(); // Use SizedBox.shrink for empty items

  dynamic iconData = _characteristicIcons[label] ?? _characteristicIcons[value];
  Widget iconWidget;

  // Determine the icon widget and its size
  if (iconData is IconData) {
    iconWidget = Icon(iconData, size: 60, color: Colors.black87); // Increased IconData size
  } else if (iconData is String && iconData.endsWith('.json')) {
    iconWidget = Lottie.asset(
      iconData,
      width: 90, // Increased Lottie width
      height: 90, // Increased Lottie height
      fit: BoxFit.contain,
      repeat: true,
    );
  } else {
    iconWidget = Icon(Icons.category, size: 60, color: Colors.black87); // Default if not found, Increased size
  }

  return Column( // Directly use Column instead of Container
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87), // Label text black as per image
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 8), // Spacing
      iconWidget, // Directly place the icon widget
      const SizedBox(height: 8), // Spacing
      Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87), // Value text black as per image
      ),
    ],
  );
}

// Helper for displaying a grid of characteristics, like "Habits & Lifestyle"
Widget _buildCharacteristicGrid(String title, List<MapEntry<String, String?>> characteristics) {
  final validItems = characteristics.where((e) => e.value != null && e.value!.isNotEmpty && e.value != 'N/A').toList();

  if (validItems.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          const SizedBox(height: 8),
          const Text('No details specified.', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180.0, // Reverted max width for each item
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0, // Reverted aspect ratio
          ),
          itemCount: validItems.length,
          itemBuilder: (context, index) {
            final entry = validItems[index];
            return _buildIconValueCard(entry.key, entry.value, backgroundColor: Colors.white, iconColor: Colors.black87);
          },
        ),
      ],
    ),
  );
}

// Helper for displaying preferences with custom icons in a grid (e.g., Night Owl, Early Bird)
final Map<String, dynamic> _preferenceIcons = { // Changed to dynamic to hold IconData or Lottie paths
  'Night Owl': 'assets/lottie/nightowl.json', // Assuming you have this Lottie file
  'Early Bird': 'assets/lottie/earlyriserrr.json', // Reusing early_riser Lottie file
  'Studious': 'assets/lottie/studious.json', // Example Lottie
  'Fitness Freak': 'assets/lottie/fitness_freak.json', // Example Lottie
  'Sporty': 'assets/lottie/sporty.json', // Example Lottie
  'Wanderer': 'assets/lottie/wanderer.json', // Example Lottie
  'Party Lover': 'assets/lottie/party_lover.json', // Example Lottie
  'Vegan': 'assets/lottie/vegan.json', // Reusing
  'Music Lover': 'assets/lottie/music_lover.json', // Example Lottie
  'Artist': 'assets/lottie/artist.json', // Example Lottie
  'Gamer': 'assets/lottie/gamer.json', // Example Lottie
  'Cook': 'assets/lottie/cook.json', // Reusing
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
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 140.0, // Reverted max width for each item
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9, // Reverted aspect ratio
          ),
          itemCount: preferences.length,
          itemBuilder: (context, index) {
            final preference = preferences[index];
            dynamic iconData = _preferenceIcons[preference]; // Get icon data (IconData or String)

            Widget iconWidget;
            if (iconData is IconData) {
              iconWidget = Icon(iconData, color: Colors.black87, size: 50); // Increased IconData size
            } else if (iconData is String && iconData.endsWith('.json')) {
              iconWidget = Lottie.asset(
                iconData,
                width: 80, // Increased Lottie width
                height: 80, // Increased Lottie height
                fit: BoxFit.contain,
                repeat: true,
              );
            } else {
              iconWidget = Icon(Icons.category, color: Colors.black87, size: 50); // Default, Increased size
            }

            return Column( // Directly use Column instead of Container
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget, // Icon widget
                const SizedBox(height: 8), // Spacing
                Text(
                  preference,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87), // Text color black as per image
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

// Helper to convert List<String> to List<MapEntry<String, String?>> for grid display
List<MapEntry<String, String?>> _convertStringListToCharacteristicEntries(List<String>? list) {
  if (list == null) {
    return [];
  }
  return list.map((item) => MapEntry(item, item)).toList();
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
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profile.imageUrls != null && profile.imageUrls!.isNotEmpty
                      ? NetworkImage(profile.imageUrls![0])
                      : null,
                  child: profile.imageUrls == null || profile.imageUrls!.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  profile.name ?? 'N/A',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${profile.age?.toString() ?? 'N/A'} years old, ${profile.occupation ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Looking in ${profile.desiredCity ?? 'N/A'}, ${profile.areaPreference ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () { /* Handle chat */ },
                      icon: const Icon(Icons.chat, size: 20),
                      label: const Text('Chat', style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () { /* Handle call */ },
                      icon: const Icon(Icons.call, size: 20),
                      label: const Text('Call', style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),


          // Basic Info - NOW AS A GRID
          _buildCharacteristicGrid(
            'Basic Information',
            [
              MapEntry('Gender', profile.gender),
              MapEntry('Age', profile.age?.toString()),
              MapEntry('Occupation', profile.occupation),
              MapEntry('Current Location', profile.currentLocation),
              MapEntry('Desired City', profile.desiredCity),
              MapEntry('Area Pref.', profile.areaPreference),
              MapEntry('Move-in Date', profile.moveInDate != null
                  ? DateFormat('dd/MM/yyyy').format(profile.moveInDate!)
                  : null),
              MapEntry('Budget Range', '₹${profile.budgetMin ?? 'N/A'} - ₹${profile.budgetMax ?? 'N/A'}'),
              MapEntry('Bio', profile.bio),
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
          // Amenities Desired - NOW AS A GRID
          _buildCharacteristicGrid('Amenities Desired', _convertStringListToCharacteristicEntries(profile.amenitiesDesired)),


          // Flatmate Preferences
          _buildCharacteristicGrid(
            'Flatmate Preferences',
            [
              MapEntry('Preferred Gender', profile.preferredFlatmateGender),
              MapEntry('Preferred Age', profile.preferredFlatmateAge),
              MapEntry('Preferred Occupation', profile.preferredOccupation),
            ],
          ),
          // Preferred Habits - NOW AS A GRID
          _buildCharacteristicGrid('Preferred Habits', _convertStringListToCharacteristicEntries(profile.preferredHabits)),
          // Ideal Qualities - NOW AS A GRID
          _buildCharacteristicGrid('Ideal Qualities', _convertStringListToCharacteristicEntries(profile.idealQualities)),
          // Deal Breakers - NOW AS A GRID
          _buildCharacteristicGrid('Deal Breakers', _convertStringListToCharacteristicEntries(profile.dealBreakers)),

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
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
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
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profile.imageUrls != null && profile.imageUrls!.isNotEmpty
                      ? NetworkImage(profile.imageUrls![0])
                      : null,
                  child: profile.imageUrls == null || profile.imageUrls!.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  profile.ownerName ?? 'N/A',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${profile.ownerAge?.toString() ?? 'N/A'} years old, ${profile.ownerOccupation ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Flat in ${profile.desiredCity ?? 'N/A'}, ${profile.areaPreference ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () { /* Handle chat */ },
                      icon: const Icon(Icons.chat, size: 20),
                      label: const Text('Chat', style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () { /* Handle call */ },
                      icon: const Icon(Icons.call, size: 20),
                      label: const Text('Call', style: TextStyle(fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Basic Info (Owner's Info) - NOW AS A GRID
          _buildCharacteristicGrid(
            'About The Owner / Current Flatmate',
            [
              MapEntry('Name', profile.ownerName),
              MapEntry('Age', profile.ownerAge?.toString()),
              MapEntry('Gender', profile.ownerGender),
              MapEntry('Occupation', profile.ownerOccupation),
              MapEntry('Bio', profile.ownerBio),
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

          // Flat Details - NOW CONTAINS GRID FOR SOME FIELDS
          _buildCharacteristicGrid(
            'Flat Details',
            [
              MapEntry('City', profile.desiredCity),
              MapEntry('Area', profile.areaPreference),
              MapEntry('Address', profile.address),
              MapEntry('Landmark', profile.landmark),
              MapEntry('Description', profile.flatDescription),
              MapEntry('Flat Type', profile.flatType),
              MapEntry('Furnished Status', profile.furnishedStatus),
              MapEntry('Available For', profile.availableFor),
              MapEntry('Availability Date', profile.availabilityDate != null
                  ? DateFormat('dd/MM/yyyy').format(profile.availabilityDate!)
                  : null),
              MapEntry('Rent Price', '₹${profile.rentPrice ?? 'N/A'}'),
              MapEntry('Deposit Amt.', '₹${profile.depositAmount ?? 'N/A'}'),
              MapEntry('Bathroom Type', profile.bathroomType),
              MapEntry('Balcony', profile.balconyAvailability),
              MapEntry('Parking', profile.parkingAvailability),
            ],
          ),
          // Amenities - NOW AS A GRID
          _buildCharacteristicGrid('Amenities', _convertStringListToCharacteristicEntries(profile.amenities)),


          // Flatmate Preferences
          _buildCharacteristicGrid(
            'Flatmate Preferences',
            [
              MapEntry('Preferred Gender', profile.preferredGender),
              MapEntry('Preferred Age', profile.preferredAgeGroup),
              MapEntry('Preferred Occupation', profile.preferredOccupation),
            ],
          ),
          // Preferred Habits - NOW AS A GRID
          _buildCharacteristicGrid('Preferred Habits', _convertStringListToCharacteristicEntries(profile.preferredHabits)),
          // Ideal Qualities - NOW AS A GRID
          _buildCharacteristicGrid('Ideal Qualities', _convertStringListToCharacteristicEntries(profile.flatmateIdealQualities)),
          // Deal Breakers - NOW AS A GRID
          _buildCharacteristicGrid('Deal Breakers', _convertStringListToCharacteristicEntries(profile.flatmateDealBreakers)),

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
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}