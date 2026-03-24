import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GenerateScheduleController extends GetxController {
  // TEXT FIELDS
  final departureCityController = TextEditingController();
  final departureDateController = TextEditingController();
  final returnDateController = TextEditingController();
  final pilgrimsCountController = TextEditingController();
  final hotelController = TextEditingController();

  var isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> saveSchedule() async {
    if (departureCityController.text.isEmpty ||
        departureDateController.text.isEmpty ||
        returnDateController.text.isEmpty ||
        pilgrimsCountController.text.isEmpty ||
        hotelController.text.isEmpty) {
      Get.snackbar(
        "Missing Fields",
        "Please fill all fields",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      await _firestore.collection("Schedules").add({
        "agentId": userId,
        "departureCity": departureCityController.text.trim(),
        "departureDate": departureDateController.text.trim(),
        "returnDate": returnDateController.text.trim(),
        "pilgrimsCount": pilgrimsCountController.text.trim(),
        "hotel": hotelController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Success",
        "Schedule successfully saved!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
      );

      // Clear fields
      departureCityController.clear();
      departureDateController.clear();
      returnDateController.clear();
      pilgrimsCountController.clear();
      hotelController.clear();
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
