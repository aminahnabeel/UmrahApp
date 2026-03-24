import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/authControllers/userauthcontroller/usersignup_controller.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/AgentData/agent_data.dart';
import 'package:smart_umrah_app/getUserId/getUid.dart';
import 'package:smart_umrah_app/screens/TravelAgent/auth_pages/agent_email_verification.dart';
import 'package:smart_umrah_app/validation/auth_validation.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';
import 'package:smart_umrah_app/widgets/customtextfield.dart';

class TravelAgentSignUpScreen extends StatelessWidget {
  TravelAgentSignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final SignupController signupController = Get.put(SignupController());
  final AuthFormValidation authFormValidation = AuthFormValidation();

  // Controllers
  final TextEditingController _agentNameController = TextEditingController();
  final TextEditingController _agencyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();

  // Observables
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;
  final RxString selectedGender = ''.obs;
  final RxBool _isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF263442),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Agent Registration",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: const Color(0xFF263442),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.08,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/umrah_app_logo.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 20),

                  // Agent Name
                  customTextField(
                    "Agent Name",
                    controller: _agentNameController,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Agent Name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Agency Name
                  customTextField(
                    "Agency Name",
                    controller: _agencyNameController,
                    prefixIcon: const Icon(Icons.business),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Agency Name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  customTextField(
                    "Email Address",
                    controller: _emailController,
                    prefixIcon: const Icon(Icons.email),
                    validator: AuthFormValidation.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Obx(
                    () => TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword.value,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              _obscurePassword.value = !_obscurePassword.value,
                        ),
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
                      validator: (value) =>
                          AuthFormValidation.validatePassword(value),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  Obx(
                    () => TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword.value,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => _obscureConfirmPassword.value =
                              !_obscureConfirmPassword.value,
                        ),
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
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Confirm Password is required';
                        if (value != _passwordController.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  customTextField(
                    "Permanent Address",
                    controller: _addressController,
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                  const SizedBox(height: 16),

                  // Passport Number
                  customTextField(
                    "Passport Number",
                    controller: _passportController,
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  Obx(
                    () => CustomButton(
                      text: _isLoading.value ? "Loading..." : "REGISTER",
                      width: MediaQuery.of(context).size.width * 0.5,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _isLoading.value = true;

                          try {
                            await signupController.signUpUser(
                              context,
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              confirmPassword: _confirmPasswordController.text
                                  .trim(),
                            );

                            final agentProfile = TravelAgentProfileModel(
                              id: getID(),
                              name: _agentNameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              isVerified: false,
                              passportNumber: _passportController.text.trim(),
                              permanentAddress: _addressController.text.trim(),
                              gender: selectedGender.value,
                              dateOfBirth: _dateController.text.trim(),
                              agencyName: _agencyNameController.text.trim(),
                            );

                            await AgentProfileDataCollection()
                                .saveAgentProfileData(agentProfile);

                            Get.snackbar(
                              "Success",
                              "${agentProfile.name} Registered Successfully",
                              backgroundColor: Colors.green,
                            );
                            Get.to(
                              () => AgentEmailVerificationScreen(
                                emailAddress: _emailController.text.trim(),
                              ),
                            );
                          } catch (error) {
                            Get.snackbar(
                              "Error",
                              error.toString(),
                              backgroundColor: Colors.red,
                            );
                          } finally {
                            _isLoading.value = false;
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Already have account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to agent login page if exists
                          Get.toNamed('/agent-login');
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
