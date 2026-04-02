import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentSigninController extends GetxController {
  Future<bool> AgentloginUser(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      // 1) First, try to sign in with Firebase Auth
      UserCredential userCredential;
      try {
        userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } on FirebaseAuthException catch (e) {
        // If Firebase Auth login fails, show specific error
        if (e.code == 'user-not-found') {
          _showError(context, 'No user found for this email.');
        } else if (e.code == 'wrong-password') {
          _showError(context, 'Incorrect password.');
        } else if (e.code == 'invalid-email') {
          _showError(context, 'Invalid email address.');
        } else {
          _showError(context, 'Authentication failed: ${e.message}');
        }
        return false;
      }

      User? user = userCredential.user;

      if (user == null) {
        _showError(context, 'Login failed. User is null.');
        return false;
      }

      // 2) Verify TravelAgent profile exists in Firestore by uid
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('TravelAgents')
          .doc(user.uid)
          .get();

      if (!profileSnapshot.exists) {
        _showError(context,
            'Your Travel Agent profile could not be found. Please contact support.');
        return false;
      }

      // 3) If email not verified in Firebase, allow login and let the
      // verification screen handle any resend request manually.
      if (!user.emailVerified) {
        debugPrint('User is not verified yet: ${user.email}');
      }

      // 4) Save session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isEmailVerified', user.emailVerified);
      await prefs.setString('userEmail', user.email ?? '');
      await prefs.setString('userUID', user.uid);

      return true;
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      _showError(context, 'An unexpected error occurred: $e');
      return false;
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }
}
