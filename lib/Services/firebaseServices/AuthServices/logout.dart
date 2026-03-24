import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/routes/routes.dart';

Future<void> logoutUser() async {
  try {
    await FirebaseAuth.instance
        .signOut()
        .then((_) {
          Get.snackbar(
            "AuthMessage",
            "Logout Successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.toNamed(AppRoutes.landingscreen);
        })
        .catchError((e) {
          Get.snackbar(
            "AuthMessage",
            "Error while Logout :$e",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        });
  } catch (e) {
    print("Error while logging out: $e");
  }
}
