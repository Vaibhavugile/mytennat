import 'package:flutter/material.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideUpAnimation;
  late Animation<double> _scaleAnimation; // For a subtle pop effect on cards

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400), // Slightly longer overall animation for smoothness
    );

    // Animation for the main title and description
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut), // Fade in during the first 70%
      ),
    );

    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4), // Start further below for a more pronounced slide
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic), // Slide up after a small delay
      ),
    );

    // Animation for the selection cards
    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate( // Slightly more pronounced scale
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut), // Elastic pop effect
      ),
    );

    _animationController.forward(); // Start all animations
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define a custom theme for this screen to control text and primary colors
    final customTheme = ThemeData(
      // Enhanced Primary and Accent Colors
      primaryColor: const Color(0xFF212121), // A deep, rich charcoal for primary elements
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: MaterialColor(
          0xFF212121, // Main primary color
          <int, Color>{
            50: Color(0xFFECEFF1),
            100: Color(0xFFCFD8DC),
            200: Color(0xFFB0BEC5),
            300: Color(0xFF90A4AE),
            400: Color(0xFF78909C),
            500: Color(0xFF607D8B),
            600: Color(0xFF546E7A),
            700: Color(0xFF455A64),
            800: Color(0xFF37474F),
            900: Color(0xFF263238),
          },
        ),
        accentColor: const Color(0xFF5C6BC0), // A calming indigo/blue accent for highlights
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F8F8), // A slightly brighter off-white background

      // Enhanced Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'Roboto', fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF212121)), // Larger and bolder main question
        headlineSmall: TextStyle(fontFamily: 'Roboto', fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF333333)), // Slightly larger and semi-bold card titles
        titleLarge: TextStyle(fontFamily: 'Roboto', fontSize: 18, color: Color(0xFF424242)),
        bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Color(0xFF616161)),
        bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Color(0xFF757575)),
        bodySmall: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: Color(0xFF9E9E9E)),
      ),

      // Enhanced Card Theme for a "Soft UI" / Neumorphic feel
      cardTheme: CardTheme(
        elevation: 10, // Increased elevation for a floating effect
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // Slightly more rounded corners
        margin: EdgeInsets.zero,
        color: Colors.white, // Card background remains white
        shadowColor: Colors.black.withOpacity(0.1), // Softer, more diffuse shadow
      ),

      // Enhanced Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30), // Slightly more padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Softer rounded corners
          backgroundColor: const Color(0xFF5C6BC0), // Use accent color for buttons
          foregroundColor: Colors.white, // White text on accent button
          elevation: 7, // Pronounced button shadow
          shadowColor: const Color(0xFF5C6BC0).withOpacity(0.3), // Shadow matching button color
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.8), // Slightly larger, more spaced text
          minimumSize: const Size(200, 0), // A bit wider button
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF424242), // Slightly softer icon color
        size: 70, // Keep icon size consistent
      ),
    );

    return Theme(
      data: customTheme,
      child: Scaffold(
        backgroundColor: customTheme.scaffoldBackgroundColor, // Use the new scaffold background color
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 56.0), // Adjusted padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'What are you looking for today?',
                    style: customTheme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 72), // Increased spacing

                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: SlideTransition(
                                    position: _slideUpAnimation,
                                    child: Opacity(
                                      opacity: _fadeAnimation.value,
                                      child: _buildSelectionCard(
                                        context,
                                        theme: customTheme,
                                        icon: Icons.apartment_outlined,
                                        title: 'Looking for a Flat',
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Navigating to Flat Search...')),
                                          );
                                          // TODO: Navigate to the actual "Find a Flat" screen
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 28), // Increased spacing between cards
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: SlideTransition(
                                    position: _slideUpAnimation,
                                    child: Opacity(
                                      opacity: _fadeAnimation.value,
                                      child: _buildSelectionCard(
                                        context,
                                        theme: customTheme,
                                        icon: Icons.people_outline,
                                        title: 'Looking for a Flatmate',
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Navigating to Flatmate Search...')),
                                          );
                                          // TODO: Navigate to the actual "Find a Flatmate" screen
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: SlideTransition(
                                  position: _slideUpAnimation,
                                  child: Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: _buildSelectionCard(
                                      context,
                                      theme: customTheme,
                                      icon: Icons.apartment_outlined,
                                      title: 'Looking for a Flat',
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Navigating to Flat Search...')),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 28), // Increased spacing between cards
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: SlideTransition(
                                  position: _slideUpAnimation,
                                  child: Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: _buildSelectionCard(
                                      context,
                                      theme: customTheme,
                                      icon: Icons.people_outline,
                                      title: 'Looking for a Flatmate',
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Navigating to Flatmate Search...')),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 72), // Increased spacing at bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a consistent selection card
  Widget _buildSelectionCard(
      BuildContext context, {
        required ThemeData theme,
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: theme.cardTheme.elevation!,
      shape: theme.cardTheme.shape!,
      margin: theme.cardTheme.margin!,
      child: ClipRRect(
        borderRadius: theme.cardTheme.shape is RoundedRectangleBorder
            ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius
            : BorderRadius.circular(25), // Ensure fallback matches new radius
        child: InkWell(
          onTap: onTap,
          splashColor: theme.colorScheme.primary.withOpacity(0.08), // Use primary color for ripple
          highlightColor: Colors.transparent, // No highlight color
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0), // Increased padding within card
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: theme.iconTheme.size, // Use theme's icon size
                  color: theme.iconTheme.color, // Use theme's icon color
                ),
                const SizedBox(height: 28), // Increased spacing below icon
                Text(
                  title,
                  style: theme.textTheme.headlineSmall, // Use the defined text style
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36), // Increased spacing before button
                ElevatedButton(
                  onPressed: onTap,
                  style: theme.elevatedButtonTheme.style,
                  child: const Text('Clicks Hards'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}