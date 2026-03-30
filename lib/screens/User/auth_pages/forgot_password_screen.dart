import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:smart_umrah_app/validation/auth_validation.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';
import 'package:smart_umrah_app/widgets/customtextfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final RxBool _isLoading = false.obs;

  // Theme Colors (Matching your Dashboard/Login)
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF64B5F6);

  Future<void> _sendResetLink(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();

    try {
      _isLoading.value = true;
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _isLoading.value = false;

      Get.snackbar(
        "Success",
        "Password reset link sent! Check your email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _emailController.clear();
    } on FirebaseAuthException catch (e) {
      _isLoading.value = false;
      String errorMessage;

      switch (e.code) {
        case "invalid-email":
          errorMessage = "Invalid email format.";
          break;
        case "user-not-found":
          errorMessage = "No account found with this email.";
          break;
        default:
          errorMessage = e.message ?? "Something went wrong. Try again.";
      }

      Get.snackbar(
        "Error",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar(
        "Error",
        "Unexpected error occurred. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with soft background
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset, size: 80, color: Colors.white),
                  ),
                  
                  const SizedBox(height: 30),

                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Enter your registered email and we'll send you a link to reset your password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 40),

                  // Email Field
                  customTextField(
                    "Enter your Email",
                    controller: _emailController,
                    validator: AuthFormValidation.validateEmail,
                    prefixIcon: const Icon(Icons.email, color: primaryBlue),
                  ),

                  const SizedBox(height: 30),

                  // Action Button
                  Obx(
                    () => CustomButton(
                      isLoading: _isLoading.value,
                      text: "SEND RESET LINK",
                      onPressed: () => _sendResetLink(context),
                      width: double.infinity,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back Button
                  
                // Back Button logic update
                  TextButton(
                  onPressed: () => Get.offNamed(AppRoutes.usersignin), // Direct route use karein
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Back to Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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