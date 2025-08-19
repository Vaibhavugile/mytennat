// profile_switch_animation.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProfileSwitchAnimationScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  final String newProfileType;

  const ProfileSwitchAnimationScreen({
    Key? key,
    required this.onAnimationComplete,
    required this.newProfileType,
  }) : super(key: key);

  @override
  State<ProfileSwitchAnimationScreen> createState() => _ProfileSwitchAnimationScreenState();
}

class _ProfileSwitchAnimationScreenState extends State<ProfileSwitchAnimationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Total animation duration
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward().then((value) {
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String message = widget.newProfileType == 'flat_listing'
        ? 'Switching to Flat Profile'
        : 'Switching to Flatmate Profile';

    const String flatListingImagePath = 'assets/images/flat_listing_animation_image.png';
    const String flatmateImagePath = 'assets/images/flatmate_animation_image.jpg';

    final isFlatListing = widget.newProfileType == 'flat_listing';
    final initialImage = isFlatListing ? flatmateImagePath : flatListingImagePath;
    final finalImage = isFlatListing ? flatListingImagePath : flatmateImagePath;

    return Scaffold(
      backgroundColor: Colors.transparent, // Set to transparent to show the gradient
      body: Container(
        // The gradient background from PlansScreen.dart
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFFAD1457)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // First image: moves into depth, rotates, and fades out
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateX(_animation.value * math.pi) // Rotates upside down
                              ..translate(0.0, 0.0, _animation.value * 200) // Moves into depth
                              ..scale(1.0 - _animation.value * 0.5), // Shrinks
                            child: Opacity(
                              opacity: 1.0 - _animation.value,
                              child: Image.asset(initialImage, fit: BoxFit.contain),
                            ),
                          );
                        },
                      ),
                      // Second image: emerges from depth, rotates, and fades in
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // Perspective
                              ..rotateX((_animation.value - 1) * math.pi) // Rotates into view
                              ..translate(0.0, 0.0, (1.0 - _animation.value) * 200) // Moves out of depth
                              ..scale(0.5 + _animation.value * 0.5), // Grows
                            child: Opacity(
                              opacity: _animation.value,
                              child: Image.asset(finalImage, fit: BoxFit.contain),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Changed text color to white for better contrast
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}