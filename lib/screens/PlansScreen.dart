import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  int? _selectedIndex;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Basic',
      'price': '₹99',
      'contacts': '5 Contacts',
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
      'contacts': '20 Contacts',
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
      'contacts': '40 Contacts',
      'features': [
        'Priority support',
        'Ad-free experience',
        'Exclusive insights'
      ],
      'isHighlighted': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85,
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalTopPadding = appBarHeight + statusBarHeight + 20.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 0.0 : 40.0,
              totalTopPadding,
              isMobile ? 0.0 : 40.0,
              20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                isMobile ? _buildMobilePlanLayout(context) : _buildWebPlanLayout(context),

                const SizedBox(height: 40),

                const Text(
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

  Widget _buildMobilePlanLayout(BuildContext context) {
    final double cardHeight = 450;

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final plan = _plans[index];
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                    minHeight: cardHeight * 0.9,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_plans.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              height: 10,
              width: _currentPage == index ? 25 : 10,
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

  Widget _buildWebPlanLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_plans.length, (index) {
        final plan = _plans[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: index == 1 ? 15.0 : 0.0),
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
        required bool isSelected,
        required VoidCallback onTap,
        double? minHeight,
      }) {
    Color borderColor;
    double borderWidth;
    List<BoxShadow>? cardShadows;

    if (isHighlighted) {
      // Pro plan style (highlighted)
      borderColor = Colors.redAccent;
      borderWidth = 3;
      cardShadows = [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          spreadRadius: 3,
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.redAccent.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
    } else if (isSelected) {
      // Style for any plan when selected (e.g., Basic or Standard if tapped)
      borderColor = Colors.deepPurple; // A distinct color for selected state
      borderWidth = 2;
      cardShadows = [
        BoxShadow(
          color: Colors.deepPurple.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ];
    } else {
      // Default style for Basic/Standard when not highlighted or explicitly selected
      borderColor = Colors.deepPurple.withOpacity(0.3); // A subtle purple outline
      borderWidth = 1; // A thin border
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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        constraints: minHeight != null ? BoxConstraints(minHeight: minHeight) : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: cardShadows,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
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
                            textAlign: TextAlign.center,
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
                      onPressed: onTap,
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
                top: 40,
                right: -12,
                child: Transform.rotate(
                  angle: 0.785,
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 7,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
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
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final userId = user.uid;
                  final firestore = FirebaseFirestore.instance;

                  final contactsValue =
                  int.tryParse(contactsString.replaceAll(RegExp(r'\D'), ''));

                  if (contactsValue != null) {
                    try {
                      await firestore.collection('users').doc(userId).set(
                        {
                          'currentPlan': planName,
                          'currentPlanContacts': contactsValue,
                          'remainingContacts': contactsValue,
                          'planPurchaseDate': FieldValue.serverTimestamp(),
                        },
                        SetOptions(merge: true),
                      );

                      await firestore.collection('users').doc(userId).collection('purchases').add({
                        'planName': planName,
                        'contactsPurchased': contactsValue,
                        'purchaseDate': FieldValue.serverTimestamp(),
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$planName purchase confirmed! Details saved.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save plan details: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: Could not parse contacts value.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  Navigator.of(context).pop();
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