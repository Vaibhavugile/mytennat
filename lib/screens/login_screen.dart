// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'selection_screen.dart';
import 'home_page.dart';
import 'package:flutter/foundation.dart';

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
  int _resendOtpTimer = 60;
  bool _canResendOtp = false;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<Offset> _slideUpAnimation;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _canResendOtp = false;
    _resendOtpTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendOtpTimer < 1) {
          timer.cancel();
          _canResendOtp = true;
        } else {
          _resendOtpTimer--;
        }
      });
    });
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _loading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${_phoneController.text}', // Assuming Indian numbers
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('Phone verification completed automatically.');
          await FirebaseAuth.instance.signInWithCredential(credential);
          _navigateToNextScreen();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _loading = false;
          });
          String errorMessage = 'Verification failed. Please try again.';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'The provided phone number is not valid.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later.';
          }
          debugPrint('Phone verification failed: ${e.code} - ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _loading = false;
          });
          _startResendTimer();
          debugPrint('OTP code sent to phone number. Verification ID: $verificationId');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent to your phone!')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _loading = false;
          });
          debugPrint('OTP auto-retrieval timed out. Verification ID: $verificationId');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });
      debugPrint('Error verifying phone number: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _verifyOtpAndSignIn() async {
    setState(() {
      _loading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('OTP verification successful. User signed in.');
      _navigateToNextScreen();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
      });
      String errorMessage = 'Invalid OTP. Please try again.';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'The entered OTP is incorrect.';
      } else if (e.code == 'session-expired') {
        errorMessage = 'OTP session expired. Please resend OTP.';
      }
      debugPrint('OTP verification failed: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      setState(() {
        _loading = false;
      });
      debugPrint('Error verifying OTP and signing in: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _navigateToNextScreen() async {
    setState(() {
      _loading = false;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Get the phone number from the authenticated user
      final String? userPhoneNumber = user.phoneNumber;
      debugPrint('Authenticated user phone number: $userPhoneNumber');

      final flatListingsSnapshot = await userDocRef.collection('flatListings').limit(1).get();
      final bool hasFlatListingProfile = flatListingsSnapshot.docs.isNotEmpty;

      final seekingFlatmateProfilesSnapshot = await userDocRef.collection('seekingFlatmateProfiles').limit(1).get();
      final bool hasSeekingFlatmateProfile = seekingFlatmateProfilesSnapshot.docs.isNotEmpty;

      if (hasFlatListingProfile || hasSeekingFlatmateProfile) {
        debugPrint('User has an existing profile (flat listing or seeking flatmate). Navigating to HomePage.');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
              (Route<dynamic> route) => false,
        );
      } else {
        debugPrint('New user. No existing profiles found. Navigating to profile creation (SelectionScreen).');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SelectionScreen(initialPhoneNumber: userPhoneNumber)),
              (Route<dynamic> route) => false,
        );
      }
    } else {
      debugPrint('Authentication failed: No current user after sign-in attempt.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed. Please try again.')),
      );
    }
  }

  Widget _buildMobileLoginUi(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideUpAnimation,
                  child: Column(
                    children: [
                      const Icon(Icons.home_work_rounded, color: Colors.redAccent, size: 100),
                      const SizedBox(height: 32),
                      Text(
                        'Find Your Perfect Flatmate & Home',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Connect with compatible flatmates and discover your ideal living space effortlessly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideUpAnimation,
                  child: Column(
                    children: [
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter Phone Number',
                          prefixIcon: const Icon(Icons.phone, color: Colors.redAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isOtpSent)
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter OTP',
                            prefixIcon: const Icon(Icons.lock, color: Colors.redAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading
                              ? null
                              : (_isOtpSent ? _verifyOtpAndSignIn : _verifyPhoneNumber),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            _isOtpSent ? 'Verify OTP' : 'Get OTP',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isOtpSent)
                        TextButton(
                          onPressed: _canResendOtp ? _verifyPhoneNumber : null,
                          child: Text(
                            _canResendOtp
                                ? 'Resend OTP'
                                : 'Resend in $_resendOtpTimer seconds',
                            style: TextStyle(
                              color: _canResendOtp ? Colors.redAccent : Colors.grey,
                              fontSize: 15,
                            ),
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

  Widget _buildWebLoginUi(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(40.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.home_work_rounded, color: Colors.redAccent, size: 120),
                    const SizedBox(height: 30),
                    Text(
                      'Welcome to Flatmate Finder',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your ultimate solution to finding the perfect flatmate and ideal living space. Experience seamless connections and a harmonious home environment.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent[700],
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number (e.g., +919876543210)',
                          prefixIcon: const Icon(Icons.phone, color: Colors.redAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_isOtpSent)
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'OTP',
                            prefixIcon: const Icon(Icons.lock, color: Colors.redAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading
                              ? null
                              : (_isOtpSent ? _verifyOtpAndSignIn : _verifyPhoneNumber),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            _isOtpSent ? 'Verify OTP' : 'Get OTP',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isOtpSent)
                        TextButton(
                          onPressed: _canResendOtp ? _verifyPhoneNumber : null,
                          child: Text(
                            _canResendOtp
                                ? 'Resend OTP'
                                : 'Resend in $_resendOtpTimer seconds',
                            style: TextStyle(
                              color: _canResendOtp ? Colors.redAccent : Colors.grey,
                              fontSize: 15,
                            ),
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