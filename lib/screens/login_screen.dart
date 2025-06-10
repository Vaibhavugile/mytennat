import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Added for Timer functionality
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb for platform detection
// import 'package:lottie/lottie.dart'; // Uncomment if you plan to use Lottie animations
import 'selection_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _verificationId = '';
  bool _isOtpSent = false;
  bool _loading = false;
  int _resendOtpTimer = 60; // Initial timer value in seconds
  bool _canResendOtp = false;
  Timer? _timer; // Declare a Timer variable

  late AnimationController _animationController;
  late Animation<Offset> _slideUpAnimation; // For general elements sliding in from bottom
  late Animation<double> _fadeInAnimation; // For general elements fading in

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Increased overall animation duration for smoother feel
    );

    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.6), // Start further below for a more pronounced slide
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward(); // Start initial animations
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel(); // Cancel the timer if it's active to prevent memory leaks
    super.dispose();
  }

  // Starts the resend OTP timer
  void _startResendOtpTimer() {
    _resendOtpTimer = 60; // Reset timer
    _canResendOtp = false;
    _timer?.cancel(); // Cancel any existing timer before starting a new one

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendOtpTimer--;
        if (_resendOtpTimer <= 0) {
          timer.cancel(); // Stop the timer when it reaches 0
          _canResendOtp = true;
        }
      });
    });
  }

  void sendOtp() async {
    // Basic validation
    if (_phoneController.text.trim().isEmpty || _phoneController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 10-digit phone number.")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${_phoneController.text.trim()}', // Prefill country code
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Auto-verification successful! Welcome to MyTenant."),
              backgroundColor: Colors.green,
            ));
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectionScreen()));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            String errorMessage = "Verification failed. Please try again.";
            if (e.code == 'invalid-phone-number') {
              errorMessage = "The phone number is invalid.";
            } else if (e.code == 'too-many-requests') {
              errorMessage = "Too many attempts. Please try again later.";
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
          });
          _animationController.forward(from: 0.5); // Animate in OTP field
          _startResendOtpTimer(); // Start the resend timer
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("OTP sent to your phone!"),
              backgroundColor: Colors.blueAccent,
            ));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("An error occurred while sending OTP. Please check your network."),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void verifyOtp() async {
    // Basic validation
    if (_otpController.text.trim().isEmpty || _otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 6-digit OTP.")),
      );
      return;
    }

    setState(() => _loading = true);
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _otpController.text.trim(),
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Login Successful! Welcome to MyTenant."),
          backgroundColor: Colors.green,
        ));
        // Navigate to the selection screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SelectionScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Invalid OTP. Please try again."),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  // --- Mobile Optimized UI ---
  Widget _buildMobileLoginUi(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // Ensures content can scroll to prevent overflow
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Animated App Logo / Title
              FadeTransition(
                opacity: _fadeInAnimation,
                child: Text(
                  'MyTenant®',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).primaryColor,
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 2),
                        blurRadius: 4.0,
                        color: Colors.black.withOpacity(0.15),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 56),

              // Animated Login/Register Header & Description
              SlideTransition(
                position: _slideUpAnimation,
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login / Register',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We will send a 6-digit verification code to this number.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Animated Phone Number Input
              SlideTransition(
                position: _slideUpAnimation,
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Enter mobile number",
                        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
                        prefixText: "+91 ",
                        prefixStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.5),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: "e.g., 9876543210",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Conditional Widgets based on _isOtpSent
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _isOtpSent
                    ? Column(
                  key: const ValueKey('otp_section_mobile'), // Key for AnimatedSwitcher
                  children: [
                    // OTP Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        decoration: InputDecoration(
                          labelText: "Enter OTP",
                          labelStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
                          hintText: "● ● ● ● ● ●",
                          hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 3.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.5),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
                          counterText: "",
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Resend OTP button/timer
                    _canResendOtp
                        ? TextButton(
                      onPressed: _loading ? null : sendOtp,
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    )
                        : Text(
                      "Resend OTP in $_resendOtpTimer seconds",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14.0),
                    ),
                    const SizedBox(height: 40), // Spacing before the "Verify" button
                    _loading
                        ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        strokeWidth: 3.0,
                      ),
                    )
                        : ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: verifyOtp, // Always verify when this button is shown
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 12,
                          shadowColor: Theme.of(context).primaryColor.withOpacity(0.6),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                        ),
                        child: const Text("Verify & Enter MyTenant"),
                      ),
                    ),
                  ],
                )
                    : Column( // This column holds the "Get OTP" button when _isOtpSent is false
                  key: const ValueKey('get_otp_section_mobile'), // Key for AnimatedSwitcher
                  children: [
                    _loading
                        ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        strokeWidth: 3.0,
                      ),
                    )
                        : ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.05).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: sendOtp, // Always send OTP when this button is shown
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 12,
                          shadowColor: Theme.of(context).primaryColor.withOpacity(0.6),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                        ),
                        child: const Text("Get OTP"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28), // Spacing after the dynamic button section

              // Terms & Privacy Text (Animated)
              FadeTransition(
                opacity: _fadeInAnimation,
                child: Text(
                  'By proceeding, you agree to our Terms of Service and Privacy Policy.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Web Optimized UI ---
  Widget _buildWebLoginUi(BuildContext context) {
    // Get screen width to determine layout
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 992; // Adjusted breakpoint for larger web screens

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Light blue-ish background
      body: Center(
        child: Container(
          width: isLargeScreen ? 1100 : double.infinity, // Wider container for web
          height: isLargeScreen ? 680 : double.infinity, // Fixed height for large screen web
          margin: isLargeScreen ? const EdgeInsets.all(32) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 0), // More rounded corners
            boxShadow: isLargeScreen ? [BoxShadow(
              color: Colors.grey.withOpacity(0.15), // Stronger shadow
              spreadRadius: 10,
              blurRadius: 40,
              offset: const Offset(0, 15),
            )] : null,
          ),
          child: Flex(
            direction: isLargeScreen ? Axis.horizontal : Axis.vertical,
            children: [
              // Left Section: Illustration (Animated entry)
              if (isLargeScreen)
                Expanded(
                  flex: 1,
                  child: AnimatedContainer( // Animated container for subtle background changes
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7ED), // Slightly darker blue-ish
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isLargeScreen ? 24 : 0),
                        bottomLeft: Radius.circular(isLargeScreen ? 24 : 0),
                      ),
                      // Optional: Add a subtle linear gradient
                      // gradient: LinearGradient(
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      //   colors: [
                      //     Color(0xFFE0E7ED),
                      //     Color(0xFFCCDAE6),
                      //   ],
                      // ),
                    ),
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero).animate(
                        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
                      ),
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Image.network(
                          'https://placehold.co/500x500/D0DDE7/4A6792?text=MyTenant+Community', // Larger placeholder
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.apartment_rounded, size: 300, color: Color(0xFF4A6792)),
                        ),
                        // Replace with Lottie.asset if you have Lottie set up:
                        // Lottie.asset(
                        //   'assets/web_illustration.json',
                        //   height: 400,
                        //   repeat: true,
                        //   animate: true,
                        // ),
                      ),
                    ),
                  ),
                ),

              // Right Section: Login Form
              Expanded(
                flex: 1,
                child: SingleChildScrollView( // Added SingleChildScrollView here for web UI
                  padding: const EdgeInsets.all(48.0), // More padding for spacious feel
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Ensures children stretch horizontally
                    children: [
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Text(
                          'MyTenant®',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith( // Larger font size
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SlideTransition(
                        position: _slideUpAnimation,
                        child: FadeTransition(
                          opacity: _fadeInAnimation,
                          child: Text(
                            'Find Your Perfect Home & Flatmate – Seamlessly.', // Enhanced tagline
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 56),

                      SlideTransition(
                        position: _slideUpAnimation,
                        child: FadeTransition(
                          opacity: _fadeInAnimation,
                          child: Text(
                            _isOtpSent ? 'Enter Verification Code' : 'Enter Your Mobile Number', // Clearer text
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _slideUpAnimation,
                        child: FadeTransition(
                          opacity: _fadeInAnimation,
                          child: Text(
                            _isOtpSent
                                ? 'A 6-digit code has been sent to your registered number.'
                                : 'We will send a 6-digit verification code to this number for secure login.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Phone Number Input
                      SlideTransition(
                        position: _slideUpAnimation,
                        child: FadeTransition(
                          opacity: _fadeInAnimation,
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixText: '+91 ',
                              prefixStyle: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
                              hintText: '99999 00000',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0), // Larger padding
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // OTP Input (Animated visibility) & Buttons
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 700),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                        child: _isOtpSent
                            ? Column(
                          key: const ValueKey('otp_section_web'),
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure children stretch
                          children: [
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                letterSpacing: 4.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                              decoration: InputDecoration(
                                hintText: '● ● ● ● ● ●',
                                hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 4.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                                counterText: "",
                              ),
                            ),
                            const SizedBox(height: 20),
                            _canResendOtp
                                ? TextButton(
                              onPressed: _loading ? null : sendOtp,
                              child: Text(
                                "Resend OTP",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            )
                                : Text(
                              "Resend OTP in $_resendOtpTimer seconds",
                              style: TextStyle(color: Colors.grey[600], fontSize: 14.5),
                            ),
                            const SizedBox(height: 40),
                            _loading
                                ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                strokeWidth: 3.0,
                              ),
                            )
                                : ScaleTransition(
                              scale: Tween<double>(begin: 1.0, end: 1.03).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: verifyOtp,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 10,
                                  shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                  animationDuration: const Duration(milliseconds: 300),
                                ),
                                child: const Text("Verify & Enter MyTenant"),
                              ),
                            ),
                          ],
                        )
                            : Column( // This column holds the "Get OTP >" button when _isOtpSent is false
                          key: const ValueKey('get_otp_section_web'),
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure children stretch
                          children: [
                            _loading
                                ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                strokeWidth: 3.0,
                              ),
                            )
                                : ScaleTransition(
                              scale: Tween<double>(begin: 1.0, end: 1.03).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: sendOtp,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 10,
                                  shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                  animationDuration: const Duration(milliseconds: 300),
                                ),
                                child: const Text("Get OTP >"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening feedback form...')),
                          );
                        },
                        child: Text(
                          'Having trouble? Give Feedback',
                          style: TextStyle(color: Colors.grey[600], fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebLoginUi(context);
    } else {
      return _buildMobileLoginUi(context);
    }
  }
}
