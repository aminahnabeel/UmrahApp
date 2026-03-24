import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/screens/User/auth_pages/email_verification.dart';

class SignupController extends GetxController {
  final RxBool _isLoading = false.obs;
  Future<void> signUpUser(
    BuildContext context, {
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password.trim() != confirmPassword.trim()) {
      _showErrorSnackBar(context, 'Passwords do not match');
      return;
    }

    if (email.trim().isEmpty || password.trim().isEmpty) {
      _showErrorSnackBar(context, 'Email and password cannot be empty');
      return;
    }

    _isLoading.value = true;

    try {
      debugPrint("Attempting to sign up with email: $email");

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      User? user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint("Verification email sent to: ${user.email}");
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EmailVerificationScreen(emailAddress: user?.email ?? email),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.code} - ${e.message}");
      _showErrorSnackBar(context, _getErrorMessage(e));
    } catch (e) {
      debugPrint("Unexpected error during signup: $e");
      _showErrorSnackBar(context, 'Unexpected error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
