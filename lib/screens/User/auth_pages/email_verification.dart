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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email sent to ${widget.emailAddress}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification email: $e'),
            backgroundColor: Colors.red,
          ),
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
          Get.offAllNamed(AppRoutes.usersignin); // Use offAll to clear stack
        }
      }
    } catch (e) {
      print('Error checking email verification: $e');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Email Verification'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lottie Animation with fixed size
                  Lottie.asset(
                    'assets/emailverify.json',
                    height: 180,
                    width: 180,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[800],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    'A verification email has been sent to\n${widget.emailAddress}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Circular Countdown Timer
                  CircularPercentIndicator(
                    radius: 55.0,
                    lineWidth: 10.0,
                    animation: true,
                    animateFromLastPercent: true,
                    percent: _remainingTime / 60,
                    center: Text(
                      '$_remainingTime',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: _canResend ? Colors.green : Colors.deepPurple,
                    backgroundColor: Colors.deepPurple.shade100,
                  ),

                  const SizedBox(height: 40),

                  // Resend Email Button
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
                        backgroundColor: Colors.deepPurple,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _canResend
                                  ? 'Resend Verification Email'
                                  : 'Resend in $_remainingTime seconds',
                              style: TextStyle(
                                fontSize: 16,
                                color: _canResend ? Colors.white : Colors.black45,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Wrong Email Option
                  TextButton(
                    onPressed: () {
                      _verificationCheckTimer.cancel();
                      _resendCooldownTimer.cancel();
                      Get.offAllNamed(AppRoutes.usersignin);
                    },
                    child: Text(
                      'Wrong email? Go back to Login',
                      style: TextStyle(
                        color: Colors.deepPurple[700],
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
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