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
      // 1) Check TravelAgents collection for email
      QuerySnapshot agentQuery = await FirebaseFirestore.instance
          .collection('TravelAgents')
          .where('email', isEqualTo: email.trim())
          .get();

      if (agentQuery.docs.isEmpty) {
        _showError(context, 'This email is not registered as a Travel Agent.');
        return false;
      }

      // 2) Sign in with Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      // 3) Check email verification
      if (user == null) {
        _showError(context, 'Login failed. User is null.');
        return false;
      }

      if (!user.emailVerified) {
        _showError(context, 'Please verify your email before logging in.');
        return false;
      }

      // 4) Save session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isEmailVerified', true);
      await prefs.setString('userEmail', user.email ?? '');
      await prefs.setString('userUID', user.uid);

      // 5) Ensure TravelAgent profile exists by uid
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('TravelAgents')
          .doc(user.uid)
          .get();

      if (!profileSnapshot.exists) {
        _showError(context, 'Your Travel Agent profile could not be found.');
        return false;
      }

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError(context, 'No user found for this email.');
      } else if (e.code == 'wrong-password') {
        _showError(context, 'Incorrect password.');
      } else {
        _showError(context, 'Authentication error: ${e.message}');
      }
      return false;
    } catch (e) {
      _showError(context, 'Error: $e');
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
