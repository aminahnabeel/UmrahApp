import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_umrah_app/routes/routes.dart';

enum AccountType { user, agent }

class SigninController extends GetxController {
  Future<bool> loginUser(
    String email,
    String password,
    BuildContext context,
    AccountType type,
  ) async {
    try {
      // 🔍 CHECK: Is user email registered in Users collection?
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email.trim())
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This email is not registered. Please sign up first.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false; // ❌ DO NOT REDIRECT
      }

      // 🔐 Login with FirebaseAuth
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null && user.emailVerified) {
        // 💾 Save Login Session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isEmailVerified', true);
        await prefs.setString('userEmail', user.email ?? '');
        await prefs.setString('userUID', user.uid);

        return true; // ✅ SUCCESS → Allow redirect
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please verify your email before logging in.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false; // ❌ DO NOT REDIRECT
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      if (e.code == 'user-not-found') message = "No user found with this email.";
      if (e.code == 'wrong-password') message = "Incorrect password.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );

      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
