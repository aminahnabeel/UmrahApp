import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/authControllers/userauthcontroller/usersignup_controller.dart';
import 'package:smart_umrah_app/Models/UserProfileDataModel/user_profile_datamodel.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/UserProfileData/newUser_profile_data_collection.dart';
import 'package:smart_umrah_app/getUserId/getUid.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:smart_umrah_app/screens/User/auth_pages/email_verification.dart';
import 'package:smart_umrah_app/validation/auth_validation.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';
import 'package:smart_umrah_app/DataLayer/User/UserData/userSignup_data.dart';
import 'package:smart_umrah_app/widgets/image_upload_widget.dart';

class UserSignUpScreen extends StatelessWidget {
  UserSignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passportnumberController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final RxBool _obscureText = true.obs;
  final RxBool _obscureText1 = true.obs;
  final RxString selectedGender = ''.obs;
  final RxBool _isLoading = false.obs;
  final RxString _profileImageUrl = ''.obs;

  final SignupController signupController = Get.put(SignupController());

  // Theme Colors
  static const Color primaryBlue = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Image Upload Widget
                  ImageUploadWidget(
                    onImageUploaded: (imageUrl) {
                      _profileImageUrl.value = imageUrl;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input Fields
                  _buildTextField(_nameController, "Full Name", Icons.person),
                  const SizedBox(height: 15),
                  _buildTextField(_emailController, "Email Address", Icons.email, 
                      validator: AuthFormValidation.validateEmail),
                  const SizedBox(height: 15),
                  
                  // Password Field
                  Obx(() => _buildPasswordField(_passwordController, "Password", _obscureText)),
                  const SizedBox(height: 15),
                  
                  // Confirm Password
                  Obx(() => _buildPasswordField(_confirmPasswordController, "Confirm Password", _obscureText1, isConfirm: true)),
                  const SizedBox(height: 15),

                  // Gender Dropdown
                  Obx(() => _buildDropdown()),
                  const SizedBox(height: 15),

                  // Date of Birth
                  _buildDatePicker(context),
                  const SizedBox(height: 15),

                  _buildTextField(_addressController, "Permanent Address", Icons.location_on),
                  const SizedBox(height: 15),
                  _buildTextField(_passportnumberController, "Passport Number", Icons.badge, 
                      keyboardType: TextInputType.number),

                  const SizedBox(height: 30),

                  // Register Button
                  Obx(() => CustomButton(
                    text: _isLoading.value ? "PLEASE WAIT..." : "R E G I S T E R",
                    onPressed: () => _handleSignUp(context),
                  )),

                  const SizedBox(height: 20),
                  
                  // Login Redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.usersignin),
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods for UI Consistency
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, 
      {String? Function(String?)? validator, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      validator: validator ?? (value) => value!.isEmpty ? "$hint is required" : null,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryBlue),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint, RxBool obscure, {bool isConfirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure.value,
      validator: (value) {
        if (isConfirm && value != _passwordController.text) return "Passwords do not match";
        return AuthFormValidation.validatePassword(value);
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock, color: primaryBlue),
        suffixIcon: IconButton(
          icon: Icon(obscure.value ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () => obscure.value = !obscure.value,
        ),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGender.value.isEmpty ? null : selectedGender.value,
      items: UserSignUpData.genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (val) => selectedGender.value = val!,
      decoration: InputDecoration(
        hintText: "Select Gender",
        prefixIcon: const Icon(Icons.wc, color: primaryBlue),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) _dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      },
      decoration: InputDecoration(
        hintText: "Date of Birth",
        prefixIcon: const Icon(Icons.calendar_today, color: primaryBlue),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Future<void> _handleSignUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;
      
      if (kDebugMode) {
        print('🔍 DEBUG: Profile Image URL: "${_profileImageUrl.value}"');
        print('🔍 DEBUG: Is empty: ${_profileImageUrl.value.isEmpty}');
      }
      
      try {
        await signupController.signUpUser(
          context,
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          confirmPassword: _confirmPasswordController.text.trim(),
        );

        final userProfile = UserProfileDatamodel(
          id: getID(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          isUser: true,
          passportNumber: _passportnumberController.text.trim(),
          permanentAddress: _addressController.text.trim(),
          gender: selectedGender.value,
          dateOfBirth: _dateController.text.trim(),
          profileImageUrl: _profileImageUrl.value.trim(),
        );
        
        if (kDebugMode) {
          print('🔍 DEBUG: Saving profile with imageUrl: "${userProfile.profileImageUrl}"');
        }

        await NewProfileDataCollection().saveUserProfileData(userProfile);
        Get.to(() => EmailVerificationScreen(emailAddress: _emailController.text.trim()));
      } catch (e) {
        Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        _isLoading.value = false;
      }
    }
  }
}