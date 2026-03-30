import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:smart_umrah_app/routes/routes.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? emailAddress;
  const EmailVerificationScreen({Key? key, required this.emailAddress})
      : super(key: key);

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late Timer _verificationCheckTimer;
  late Timer _resendCooldownTimer;
  int _remainingTime = 60;
  bool _canResend = false;
  bool _isVerifying = false;

  // Theme Colors (Matching your Dashboard/Login)
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF64B5F6);

  @override
  void initState() {
    super.initState();
    sendVerificationEmail();
    startResendCooldown();
    startPeriodicVerificationCheck();
  }

  void startPeriodicVerificationCheck() {
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      await checkEmailVerification();
    });
  }

  void startResendCooldown() {
    setState(() {
      _canResend = false;
      _remainingTime = 60;
    });

    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _resendCooldownTimer.cancel();
      }
    });
  }

  Future<void> sendVerificationEmail() async {
    setState(() {
      _isVerifying = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      if (mounted) {
        Get.snackbar(
          'Email Sent',
          'Verification email sent to ${widget.emailAddress}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to send email: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> checkEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();

      if (user?.emailVerified ?? false) {
        _verificationCheckTimer.cancel();
        _resendCooldownTimer.cancel();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isEmailVerified', true);
        await prefs.setString('userEmail', user?.email ?? '');

        if (mounted) {
          Get.offAllNamed(AppRoutes.usersignin);
        }
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
    }
  }

  @override
  void dispose() {
    _verificationCheckTimer.cancel();
    _resendCooldownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryBlue, secondaryBlue],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie Animation
                  Lottie.asset(
                    'assets/emailverify.json',
                    height: 200,
                    width: 200,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'A verification email has been sent to:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  Text(
                    '${widget.emailAddress}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Circular Progress (Timer)
                  CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 8.0,
                    percent: _remainingTime / 60,
                    center: Text(
                      '$_remainingTime',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: _canResend ? Colors.greenAccent : accentColor,
                    backgroundColor: Colors.white10,
                    animation: true,
                    animateFromLastPercent: true,
                  ),

                  const SizedBox(height: 40),

                  // Resend Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: (_canResend && !_isVerifying)
                          ? () {
                              sendVerificationEmail();
                              startResendCooldown();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white24,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: _isVerifying
                          ? const CircularProgressIndicator(color: primaryBlue)
                          : Text(
                              _canResend
                                  ? 'RESEND EMAIL'
                                  : 'Resend in $_remainingTime s',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _canResend ? primaryBlue : Colors.white38,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Wrong Email / Back to Login
                  TextButton(
                    onPressed: () {
                      _verificationCheckTimer.cancel();
                      _resendCooldownTimer.cancel();
                      Get.offAllNamed(AppRoutes.usersignin);
                    },
                    child: const Text(
                      'Wrong email? Go back to Login',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}