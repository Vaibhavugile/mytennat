import 'package:flutter/material.dart';

class BannerPopupScreen extends StatelessWidget {
  final String message;
  final String? subMessage;
  final String? profileImageUrl;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const BannerPopupScreen({
    super.key,
    required this.message,
    this.subMessage,
    this.profileImageUrl,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double redBackgroundHeight = screenHeight * 0.8;
    final double curveDipHeight = 60.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Red Curved Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: redBackgroundHeight,
            child: ClipPath(
              clipper: BottomConcaveCurveClipper(curveHeight: curveDipHeight),
              child: Container(
                color: Colors.red,
              ),
            ),
          ),

          // 2. All Content (Close Button, Image, Texts, Action Button)
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Close Button (Top Right)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Profile Image (Circular Avatar)
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                      border: Border.all(color: Colors.white, width: 4),
                      image: profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? DecorationImage(
                        image: NetworkImage(profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Main Message Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Optional Sub-Message Text
                if (subMessage != null && subMessage!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 30.0, right: 30.0),
                    child: Text(
                      subMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),

                const Spacer(), // Pushes content above to top, and new text/button to bottom

                // New Text Elements - "Why wait? contact directly on"
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    "Why wait? contact directly on",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87, // Dark text color on white background
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8), // Spacing between the two new text lines

                // New Text Elements - "+91xxxxxxxxx"
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    "+91xxxxxxxxx",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red, // Prominent red color for the number
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Spacing between number and button

                // Bottom Action Button
                if (buttonText != null && buttonText!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                    child: ElevatedButton(
                      onPressed: onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                        minimumSize: const Size.fromHeight(50),
                        elevation: 5,
                      ),
                      child: Text(
                        buttonText!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for creating the smooth, concave (U-shaped) bottom curve of the red background
class BottomConcaveCurveClipper extends CustomClipper<Path> {
  final double curveHeight;

  BottomConcaveCurveClipper({required this.curveHeight});

  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - curveHeight);
    path.quadraticBezierTo(size.width / 2, size.height, 0, size.height - curveHeight);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is BottomConcaveCurveClipper && oldClipper.curveHeight != curveHeight;
  }
}