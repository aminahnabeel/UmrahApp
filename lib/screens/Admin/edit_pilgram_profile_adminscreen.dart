import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_umrah_app/Models/UserProfileDataModel/user_profile_datamodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AdminEditPilgrimProfileScreen extends StatelessWidget {
  final UserProfileDatamodel userProfile;
  final String userId;

  AdminEditPilgrimProfileScreen({
    super.key,
    required this.userProfile,
    required this.userId,
  });

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;

  late final TextEditingController nameController = TextEditingController(
    text: userProfile.name,
  );

  late final TextEditingController emailController = TextEditingController(
    text: userProfile.email,
  );

  late final TextEditingController passportController = TextEditingController(
    text: userProfile.passportNumber,
  );

  late final TextEditingController permanentAddressController =
      TextEditingController(text: userProfile.permanentAddress);

  late final TextEditingController dobController = TextEditingController(
    text: userProfile.dateOfBirth,
  );

  late final TextEditingController genderController = TextEditingController(
    text: userProfile.gender,
  );

  // Image Picker
  Future<void> pickImage() async {
    final pickedImg = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImg != null) {
      selectedImage.value = File(pickedImg.path);
    }
  }

  // Upload Profile Image to Firebase Storage
  Future<String?> uploadImage(String uid) async {
    if (selectedImage.value == null) return null;

    final ref = FirebaseStorage.instance
        .ref()
        .child("PilgrimProfileImages")
        .child("$uid.jpg");

    await ref.putFile(selectedImage.value!);

    return await ref.getDownloadURL();
  }

  // Update Profile in Firestore
  Future<void> updatePilgrimProfile() async {
    isLoading.value = true;

    try {
      String? newImageUrl = await uploadImage(userId);

      final updatedUser = UserProfileDatamodel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: userProfile.password,
        id: userId,
        gender: genderController.text.trim(),
        passportNumber: passportController.text.trim(),
        permanentAddress: permanentAddressController.text.trim(),
        dateOfBirth: dobController.text.trim(),
        // profileImageUrl: newImageUrl ?? userProfile.profileImageUrl,
      );

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .update(updatedUser.toFirebase());

      Get.snackbar(
        "Success",
        "Pilgrim Profile Updated ✔",
        backgroundColor: Colors.green.withOpacity(0.2),
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update profile: $e",
        backgroundColor: Colors.red.withOpacity(0.2),
      );
    }

    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Pilgrim Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// ---------------- PROFILE IMAGE ----------------
              GestureDetector(
                onTap: pickImage,
                // child: Obx(() {
                //   return CircleAvatar(
                //     radius: 55,
                //     backgroundImage: selectedImage.value != null
                //         ? FileImage(selectedImage.value!)
                //         : (userProfile.profileImageUrl != null &&
                //               userProfile.profileImageUrl!.isNotEmpty)
                //         ? NetworkImage(userProfile.profileImageUrl!)
                //         : const AssetImage("assets/profile_placeholder.png")
                //               as ImageProvider,
                //   );
                // }),
              ),

              const SizedBox(height: 25),

              /// ---------------- INPUT FIELDS ----------------
              _buildField("Full Name", nameController),
              const SizedBox(height: 12),

              _buildField("Email", emailController),
              const SizedBox(height: 12),

              _buildField("Passport Number", passportController),
              const SizedBox(height: 12),

              _buildField("Permanent Address", permanentAddressController),
              const SizedBox(height: 12),

              _buildField("Date of Birth (DD/MM/YYYY)", dobController),
              const SizedBox(height: 12),

              _buildField("Gender", genderController),
              const SizedBox(height: 25),

              /// ---------------- SUBMIT BUTTON ----------------
              Obx(() {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      MediaQuery.of(context).size.width * 0.8,
                      50,
                    ),
                  ),
                  onPressed: isLoading.value ? null : updatePilgrimProfile,
                  child: isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Update Profile",
                          style: TextStyle(fontSize: 18),
                        ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextField
  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
