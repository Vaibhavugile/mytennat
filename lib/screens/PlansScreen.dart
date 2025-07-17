import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  // State variables for PageView and selected plan
  late PageController _pageController;
  int _currentPage = 0;
  int? _selectedIndex; // Tracks the index of the selected plan

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Basic',
      'price': '₹99',
      'contacts': '5 Contacts', // This needs to be parsed to an int
      'features': [
        'Basic features',
        'Limited support',
        'Ad-supported',
      ],
      'isHighlighted': false,
    },
    {
      'title': 'Standard',
      'price': '₹299',
      'contacts': '20 Contacts', // This needs to be parsed to an int
      'features': [
        'All Basic features',
        'Priority support',
        'Ad-free experience',

      ],
      'isHighlighted': false,
    },
    {
      'title': 'Pro',
      'price': '₹499',
      'contacts': '40 Contacts', // This needs to be parsed to an int
      'features': [
        'Priority support',
        'Ad-free experience',
        'Exclusive insights'
      ],
      'isHighlighted': true, // Highlight this plan
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85, // Show 85% of current card, hint at next
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define a breakpoint for mobile vs. web layout
    final bool isMobile = screenWidth < 700; // You can adjust this breakpoint

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows body to extend behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // No shadow
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            color: Colors.white, // Text color for contrast with potential dark background
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Back button color
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)], // Deep Purple to Pink-Red
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Content Scroll View
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 0.0 : 40.0, // No horizontal padding for mobile scrollable area
              vertical: 60.0, // Adjust padding for app bar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header message
                const Text(
                  'Unlock Premium Benefits!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black38,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Explore our flexible plans and supercharge your connections.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),

                // Dynamic layout for plans based on screen size
                isMobile ? _buildMobilePlanLayout(context) : _buildWebPlanLayout(context),

                const SizedBox(height: 40),

                // Additional information or FAQ (Optional)
                Text(
                  'Questions? Contact our support team for assistance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Mobile Layout (Sliding Carousel) ---
  Widget _buildMobilePlanLayout(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400, // Adjusted height for the PageView. You might fine-tune this.
          child: PageView.builder(
            controller: _pageController,
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final plan = _plans[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0), // Padding between cards
                child: _buildPlanCard(
                  context,
                  title: plan['title'],
                  price: plan['price'],
                  contacts: plan['contacts'],
                  features: plan['features'],
                  isHighlighted: plan['isHighlighted'],
                  // Pass selection state
                  isSelected: _selectedIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index; // Update selected index
                    });
                    _showPurchaseConfirmation(
                        context, plan['title'] as String, plan['contacts'] as String);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_plans.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              height: 10,
              width: _currentPage == index ? 25 : 10, // Wider for active dot
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.white : Colors.white54,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }),
        ),
      ],
    );
  }

  // --- Web Layout (Row of Cards) ---
  Widget _buildWebPlanLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the row of cards
      crossAxisAlignment: CrossAxisAlignment.start, // Align cards at the top
      children: List.generate(_plans.length, (index) {
        final plan = _plans[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: index == 1 ? 15.0 : 0.0), // Smaller gap around middle card
            child: _buildPlanCard(
              context,
              title: plan['title'],
              price: plan['price'],
              contacts: plan['contacts'],
              features: plan['features'],
              isHighlighted: plan['isHighlighted'],
              isSelected: _selectedIndex == index,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                _showPurchaseConfirmation(
                    context, plan['title'] as String, plan['contacts'] as String);
              },
            ),
          ),
        );
      }),
    );
  }

  // --- Reusable Plan Card Widget ---
  Widget _buildPlanCard(
      BuildContext context, {
        required String title,
        required String price,
        required String contacts,
        required List<String> features,
        required bool isHighlighted,
        required bool isSelected, // New parameter for selection
        required VoidCallback onTap,
      }) {
    // Determine border color and width based on selection or highlight
    Color borderColor = Colors.transparent;
    double borderWidth = 0;
    List<BoxShadow>? cardShadows;

    if (isSelected || isHighlighted) {
      // Apply highlighted style if selected OR highlighted
      borderColor = Colors.redAccent; // Same border color as Pro plan
      borderWidth = 3; // Same border width as Pro plan
      cardShadows = [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          spreadRadius: 3,
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.redAccent.withOpacity(0.4), // Subtle glow
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
    } else {
      cardShadows = [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ];
    }

    return GestureDetector(
      // Make the entire card tappable
      onTap: onTap,
      child: AnimatedContainer(
        // Use AnimatedContainer for smooth border changes
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: cardShadows, // Apply dynamic shadows
          border: Border.all(color: borderColor, width: borderWidth), // Apply dynamic border
        ),
        child: Stack(
          clipBehavior: Clip.none, // Allows overflow for the ribbon
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isHighlighted ? Colors.red[700] : Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: isHighlighted ? Colors.redAccent : Colors.purple[800],
                    ),
                  ),
                  Text(
                    contacts,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Feature List
                  ...features.map((feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: isHighlighted ? Colors.green : Colors.blueGrey, size: 20),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap, // Button also triggers selection and confirmation
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isHighlighted ? Colors.redAccent : Colors.deepPurple[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: isHighlighted ? 10 : 5,
                        shadowColor:
                        isHighlighted ? Colors.redAccent.withOpacity(0.6) : Colors.deepPurple.withOpacity(0.4),
                      ),
                      child: Text(
                        isHighlighted ? 'GO PRO NOW!' : 'SELECT PLAN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // "Most Popular" Ribbon for highlighted card
            if (isHighlighted)
              Positioned(
                top: -10, // Adjust to position the ribbon
                right: -10,
                child: Transform.rotate(
                  angle: 0.785, // Rotate 45 degrees for a ribbon effect
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber, // Bright color for the ribbon
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseConfirmation(
      BuildContext context, String planName, String contactsString) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $planName Purchase'),
          content: Text('You are about to purchase the $planName. Continue?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // TODO: Implement actual payment gateway logic here (e.g., Stripe, Razorpay)

                // Get current user
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final userId = user.uid;
                  final firestore = FirebaseFirestore.instance;

                  // Parse contacts string to integer (e.g., "5 Contacts" -> 5)
                  final contactsValue =
                  int.tryParse(contactsString.replaceAll(RegExp(r'\D'), ''));

                  if (contactsValue != null) {
                    try {
                      // Save plan details to user's document
                      await firestore.collection('users').doc(userId).set(
                        {
                          'currentPlan': planName,
                          'currentPlanContacts': contactsValue,
                          'remainingContacts': contactsValue, // Initially, remaining equals purchased
                          'planPurchaseDate': FieldValue.serverTimestamp(), // Firestore server timestamp
                          // You can add more fields if needed, like planPrice, transactionId etc.
                        },
                        SetOptions(merge: true), // Merge with existing data, don't overwrite
                      );

                      // Optionally, save a record in a 'purchases' subcollection for history
                      await firestore.collection('users').doc(userId).collection('purchases').add({
                        'planName': planName,
                        'contactsPurchased': contactsValue,
                        'purchaseDate': FieldValue.serverTimestamp(),
                        // Add any other relevant purchase details
                      });

                      Navigator.of(context).pop(); // Dismiss dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$planName purchase confirmed! Details saved.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      Navigator.of(context).pop(); // Dismiss dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save plan details: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    Navigator.of(context).pop(); // Dismiss dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: Could not parse contacts value.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  Navigator.of(context).pop(); // Dismiss dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: User not logged in.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Confirm'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        );
      },
    );
  }
}