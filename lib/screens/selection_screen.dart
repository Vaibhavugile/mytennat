// lib/screens/selection_screen.dart
import 'package:flutter/material.dart';
import 'flat_with_flatmate_profile_screen.dart';
import 'flatmate_profile_screen.dart';

class SelectionScreen extends StatefulWidget {
  final String? initialPhoneNumber; //

  const SelectionScreen({super.key, this.initialPhoneNumber}); //

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideUpAnimation;
  late Animation<double> _scaleAnimation;

  final ThemeData customTheme = ThemeData(
    primaryColor: const Color(0xFF1A237E),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: const MaterialColor(
        0xFF1A237E,
        <int, Color>{
          50: Color(0xFFE8EAF6),
          100: Color(0xFFC5CAE9),
          200: Color(0xFF9FA8DA),
          300: Color(0xFF7986CB),
          400: Color(0xFF5C6BC0),
          500: Color(0xFF3F51B5),
          600: Color(0xFF394AAE),
          700: Color(0xFF303F9F),
          800: Color(0xFF283593),
          900: Color(0xFF1A237E),
        },
      ),
      accentColor: const Color(0xFF00BFA5),
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F2F5),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Roboto', fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
      headlineSmall: TextStyle(fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF37474F)),
      titleLarge: TextStyle(fontFamily: 'Roboto', fontSize: 19, color: Color(0xFF455A64)),
      bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 17, color: Color(0xFF546E7A)),
      bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 15, color: Color(0xFF78909C)),
      bodySmall: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: Color(0xFF90A4AE)),
    ),
    cardTheme: CardTheme(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.08),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        elevation: 5,
        shadowColor: const Color(0xFF00BFA5).withOpacity(0.3),
        textStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        minimumSize: const Size(220, 0),
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF1A237E),
      size: 70,
    ),
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: customTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 64.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'What are you looking for today?',
                    style: customTheme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 80),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final card1 = _buildAnimatedCard(
                      context,
                      icon: Icons.apartment_outlined,
                      title: 'Looking for a Flat with Flatmate',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlatWithFlatmateProfileScreen(
                              initialPhoneNumber: widget.initialPhoneNumber, //
                            ),
                          ),
                        );
                      },
                    );

                    final card2 = _buildAnimatedCard(
                      context,
                      icon: Icons.people_outline,
                      title: 'Looking for a Flatmate',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlatmateProfileScreen(
                              initialPhoneNumber: widget.initialPhoneNumber, //
                            ),
                          ),
                        );
                      },
                    );

                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: card1),
                          const SizedBox(width: 32),
                          Expanded(child: card2),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          card1,
                          const SizedBox(height: 32),
                          card2,
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
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
                theme: theme,
                icon: icon,
                title: title,
                onTap: onTap,
              ),
            ),
          ),
        );
      },
    );
  }

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
            : BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          splashColor: theme.primaryColor.withOpacity(0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 48.0),
            child: Column(
              children: [
                Icon(icon, size: theme.iconTheme.size, color: theme.iconTheme.color),
                const SizedBox(height: 32),
                Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: onTap,
                  style: theme.elevatedButtonTheme.style,
                  child: const Text('Get Started'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}