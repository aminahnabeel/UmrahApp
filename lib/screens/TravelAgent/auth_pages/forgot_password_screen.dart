import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/validation/auth_validation.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';
import 'package:smart_umrah_app/widgets/customtextfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final RxBool _isLoading = false.obs;

  Future<void> _sendResetLink(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();

    try {
      _isLoading.value = true;

      // ----------- FIXED VERSION (works on all Firebase versions) ------------
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      _isLoading.value = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset link sent! Check your email."),
          backgroundColor: Colors.green,
        ),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      _isLoading.value = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unexpected error occurred. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.lock_reset, size: 100, color: Colors.blue),
                const SizedBox(height: 20),

                Text(
                  "Forgot Password?",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Enter your registered email and we'll send you a link to reset your password.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 30),

                customTextField(
                  "Enter your Email",
                  controller: _emailController,
                  validator: AuthFormValidation.validateEmail,
                ),

                const SizedBox(height: 30),

                Obx(
                  () => CustomButton(
                    isLoading: _isLoading.value,
                    text: "Send Reset Link",
                    onPressed: () => _sendResetLink(context),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    "← Back to Login",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
