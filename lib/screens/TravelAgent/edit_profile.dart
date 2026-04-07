import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/Services/imgbb_service.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/AgentData/agent_data.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/AgentData/fetch_profile.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';
import 'package:smart_umrah_app/widgets/customtextfield.dart';
import 'dart:typed_data';

class EditAgentProfileScreen extends StatelessWidget {
  final TravelAgentProfileModel userProfile;

  EditAgentProfileScreen({super.key, required this.userProfile});

  final _formKey = GlobalKey<FormState>();
  final Rx<XFile?> _selectedImage = Rx<XFile?>(null);
  final ImgBBService _imgbbService = ImgBBService();

  // Controllers
  late final TextEditingController _nameController = TextEditingController(
    text: userProfile.name,
  );
  late final TextEditingController _agencyNameController =
      TextEditingController(text: userProfile.agencyName);
  late final TextEditingController _permanentAddressController =
      TextEditingController(text: userProfile.permanentAddress);
  late final TextEditingController _passportController = TextEditingController(
    text: userProfile.passportNumber,
  );

  late final TextEditingController _dobController = TextEditingController(
    text: userProfile.dateOfBirth,
  );
  late final RxString _selectedGender = (() {
    final gender = (userProfile.gender ?? '').toLowerCase();
    if (gender == 'male') return 'Male';
    if (gender == 'female') return 'Female';
    if (gender == 'other') return 'Other';
    return '';
  })().obs;

  final RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Edit Profile")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final result = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1920,
                      maxHeight: 1920,
                      imageQuality: 85,
                    );
                    if (result != null) {
                      _selectedImage.value = result;
                      if (kDebugMode) {
                        print('✅ Profile image selected: ${result.name}');
                      }
                    }
                  },
                  child: Obx(
                    () {
                      // Show newly selected image
                      if (_selectedImage.value != null) {
                        if (kIsWeb) {
                          return FutureBuilder<Uint8List>(
                            future: _selectedImage.value!.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return CircleAvatar(
                                  radius: 50,
                                  backgroundImage: MemoryImage(snapshot.data!),
                                );
                              }
                              return const CircleAvatar(
                                radius: 50,
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                        } else {
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(
                              File(_selectedImage.value!.path),
                            ),
                          );
                        }
                      }
                      
                      // Show existing profile image
                      if (userProfile.profileImageUrl != null &&
                          userProfile.profileImageUrl!.isNotEmpty) {
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            userProfile.profileImageUrl!,
                          ),
                        );
                      }
                      
                      // Show placeholder
                      return const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      );
                    },
                  ),
                ),
                const Text(
                  "Tap to change profile picture",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 20),

                customTextField(
                  "Enter your Name",
                  controller: _nameController,
                  labelText: "Enter your new Name",
                ),
                const SizedBox(height: 15),
                customTextField(
                  "Agency Name",
                  controller: _agencyNameController,
                  labelText: "New Agency Name",
                ),
                const SizedBox(height: 15),
                customTextField(
                  "Passport Number",
                  controller: _passportController,
                  labelText: "updated Passport Number",
                ),
                const SizedBox(height: 15),
                customTextField(
                  "Enter your Permanent Address",
                  controller: _permanentAddressController,
                  labelText: "Enter your new Permanent Address",
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: "Enter DOB like in ID card",
                    labelText: "Enter DOB like in ID card",
                    prefixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(now.year - 18, now.month, now.day),
                      firstDate: DateTime(1900),
                      lastDate: now,
                    );

                    if (picked != null) {
                      _dobController.text =
                          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Date of Birth is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: _selectedGender.value.isEmpty
                        ? null
                        : _selectedGender.value,
                    decoration: InputDecoration(
                      hintText: "Select Gender",
                      labelText: "Gender",
                      prefixIcon: const Icon(Icons.wc),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      _selectedGender.value = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Gender is required';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 25),
                Obx(
                  () => CustomButton(
                    isLoading: isLoading.value,
                    text: 'Submit',
                    width: MediaQuery.of(context).size.height * 0.3,
                    height: MediaQuery.of(context).size.height * 0.06,

                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        isLoading.value = true;

                        String? uploadedImageUrl;
                        if (_selectedImage.value != null) {
                          try {
                            if (kDebugMode) {
                              print('📤 Uploading profile image to ImgBB...');
                            }
                            uploadedImageUrl = await _imgbbService.uploadImage(
                              _selectedImage.value!,
                            );
                            if (kDebugMode) {
                              print('✅ Profile image uploaded: $uploadedImageUrl');
                            }
                          } on ImgBBUploadException catch (e) {
                            if (kDebugMode) {
                              print('❌ Upload failed: $e');
                            }
                            Get.snackbar(
                              'Upload Error',
                              e.toString(),
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            isLoading.value = false;
                            return;
                          } catch (e) {
                            if (kDebugMode) {
                              print('❌ Unexpected error: $e');
                            }
                            Get.snackbar(
                              'Error',
                              'Failed to upload image: ${e.toString()}',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            isLoading.value = false;
                            return;
                          }
                        }

                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid == null) {
                          Get.snackbar(
                            "Error",
                            "User not logged in",
                            backgroundColor: Colors.red,
                          );
                          isLoading.value = false;
                          return;
                        }

                        // Fetch old profile
                        final existingProfile = await fetchAgentProfile();

                        // Build updated profile
                        final updatedProfile = TravelAgentProfileModel(
                          name: _nameController.text.trim().isEmpty
                              ? existingProfile?.name
                              : _nameController.text.trim(),

                          email: existingProfile?.email,
                          password: existingProfile?.password,
                          id: uid,
                          agencyName: _agencyNameController.text.trim().isEmpty
                              ? existingProfile?.agencyName
                              : _agencyNameController.text.trim(),

                          passportNumber:
                              _passportController.text.trim().isEmpty
                              ? existingProfile?.passportNumber
                              : _passportController.text.trim(),

                          permanentAddress:
                              _permanentAddressController.text.trim().isEmpty
                              ? existingProfile?.permanentAddress
                              : _permanentAddressController.text.trim(),

                          dateOfBirth: _dobController.text.trim().isEmpty
                              ? existingProfile?.dateOfBirth
                              : _dobController.text.trim(),

                          gender: _selectedGender.value.trim().isEmpty
                              ? existingProfile?.gender
                              : _selectedGender.value.trim(),

                          profileImageUrl:
                              uploadedImageUrl ??
                              existingProfile?.profileImageUrl ??
                              '', // image keeps old one if not updated (fallback to empty string)
                          isVerified: existingProfile?.isVerified ?? false,
                        );

                        try {
                          if (existingProfile == null) {
                            await AgentProfileDataCollection()
                                .saveAgentProfileData(updatedProfile);
                            Get.snackbar(
                              "Success",
                              "Profile Created Successfully",
                              backgroundColor: Colors.green,
                            );
                          } else {
                            await AgentProfileDataCollection()
                                .updateAgentProfileData(updatedProfile);
                            Get.snackbar(
                              "Success",
                              "Profile Updated Successfully",
                              backgroundColor: Colors.green,
                            );
                          }

                          Get.toNamed(AppRoutes.agentdashboard);
                        } catch (error) {
                          Get.snackbar(
                            "Error",
                            "Failed: $error",
                            backgroundColor: Colors.red,
                          );
                        } finally {
                          isLoading.value = false;
                        }
                      }
                    },
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
