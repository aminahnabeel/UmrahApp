import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_umrah_app/Controller/userControllers/ImagePickerController/image_picker.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/Models/UserProfileDataModel/user_profile_datamodel.dart';
import 'package:smart_umrah_app/Services/SupabaseServices/supabaseStorage/agentProfileImage.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/AgentData/agent_data.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/AgentData/fetch_profile.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/UserProfileData/FetchingProfile/fetch_profile.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/UserProfileData/newUser_profile_data_collection.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';
import 'package:smart_umrah_app/widgets/customtextfield.dart';

class EditAgentProfileScreen extends StatelessWidget {
  final TravelAgentProfileModel userProfile;

  EditAgentProfileScreen({super.key, required this.userProfile});

  final _formKey = GlobalKey<FormState>();
  final ImagePickerController _imagePickerController = Get.put(
    ImagePickerController(),
  );

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
                  onTap: () => _imagePickerController.pickImageFromGallery(),
                  child: Obx(
                    () => CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _imagePickerController.selectedImage.value != null
                          ? FileImage(
                              _imagePickerController.selectedImage.value!,
                            )
                          : (userProfile.profileImageUrl != null
                                    ? NetworkImage(userProfile.profileImageUrl!)
                                    : null)
                                as ImageProvider?,
                      child:
                          _imagePickerController.selectedImage.value == null &&
                              userProfile.profileImageUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
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
                customTextField(
                  "Enter DOB like in ID card",
                  controller: _dobController,
                  labelText: "Enter DOB like in ID card",
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
                        if (_imagePickerController.selectedImage.value !=
                            null) {
                          uploadedImageUrl = await SupabaseService()
                              .uploadImageToSupabase(
                                _imagePickerController.selectedImage.value!,
                              );
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

                          gender: existingProfile?.gender, // unchanged

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
