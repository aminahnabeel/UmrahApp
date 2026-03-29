import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/authControllers/userauthcontroller/usersignup_controller.dart';
import 'package:smart_umrah_app/DataLayer/User/UserData/userSignup_data.dart';
import 'package:smart_umrah_app/Models/UserProfileDataModel/user_profile_datamodel.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/UserProfileData/newUser_profile_data_collection.dart';
import 'package:smart_umrah_app/getUserId/getUid.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:smart_umrah_app/screens/User/auth_pages/email_verification.dart';
import 'package:smart_umrah_app/validation/auth_validation.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';

import 'package:smart_umrah_app/widgets/customtextfield.dart';

class UserSignUpScreen extends StatelessWidget {
  UserSignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  AuthFormValidation authFormValidation = AuthFormValidation();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passportnumberController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final RxBool _obscureText = true.obs;
  final RxBool _obscureText1 = true.obs;
  RxString selectedGender = ''.obs;
  final RxBool _isLoading = false.obs;

  final SignupController signupController = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(color: Color(0XFF263442)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1,
            ),
            child: Center(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/umrah_app_logo.png',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      customTextField(
                        "Enter your Full name",
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      customTextField(
                        "Enter Email Address",
                        controller: _emailController,
                        validator: AuthFormValidation.validateEmail,
                        prefixIcon: const Icon(Icons.email),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Obx(
                        () => TextFormField(
                          obscureText: _obscureText.value,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: Icon(Icons.lock, color: Colors.black),

                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                _obscureText.value = !_obscureText.value;
                              },
                            ),
                          ),
                          validator: (value) =>
                              AuthFormValidation.validatePassword(value),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Obx(
                        () => TextFormField(
                          obscureText: _obscureText1.value,
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
                            prefixIcon: Icon(Icons.lock, color: Colors.black),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText1.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                _obscureText1.value = !_obscureText1.value;
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Confirm Password is required";
                            } else if (value != _passwordController.text) {
                              return "Passwords do not match!!!";
                            }
                            return null; // Validation passed
                          },
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      Obx(
                        () => DropdownButtonFormField<String>(
                          value: selectedGender?.value.isEmpty == true
                              ? null
                              : selectedGender!.value,
                          items: UserSignUpData.genders.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            selectedGender?.value = value!;
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Your Gender',
                            prefixIcon: Icon(
                              Icons.favorite,
                              color: Colors.black,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your marital status';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select Date of Birth',
                          labelText: 'Select Date of Birth',
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.black,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onTap: () async {
                          FocusScope.of(
                            context,
                          ).requestFocus(FocusNode()); // prevent keyboard

                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(
                              Duration(days: 365 * 18),
                            ), // e.g. 18 years ago
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            String formattedDate =
                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                            _dateController.text = formattedDate;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your date of birth';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      customTextField(
                        "Permanant Address",
                        prefixIcon: Icon(Icons.location_city),
                        controller: _addressController,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      customTextField(
                        "Passport Number",
                        prefixIcon: Icon(Icons.location_city),
                        controller: _passportnumberController,
                        keyboardType: TextInputType.numberWithOptions(),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),

                      Obx(
                        () => CustomButton(
                          text: _isLoading.value
                              ? "Loading..."
                              : "R E G I S T E R",
                          width: MediaQuery.of(context).size.width * 0.5,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _isLoading.value = true;

                              try {
                                // Step 1: Sign up user
                                await signupController.signUpUser(
                                  context,
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  confirmPassword: _confirmPasswordController
                                      .text
                                      .trim(),
                                );

                                // Step 2: Build profile model
                                final userProfile = UserProfileDatamodel(
                                  id: getID(),
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  isUser: true,
                                  passportNumber: _passportnumberController.text
                                      .trim(),
                                  permanentAddress: _addressController.text
                                      .trim(),
                                  gender: selectedGender.value,
                                  dateOfBirth: _dateController.text.trim(),
                                );

                                print(
                                  'USER WANT TO SAVE MAP: ${userProfile.toFirebase()}',
                                );

                                // Step 3: Save to Firestore
                                await NewProfileDataCollection()
                                    .saveUserProfileData(userProfile);

                                // Step 4: Show success and navigate
                                Get.snackbar(
                                  "Success",
                                  "${userProfile.name} Registered Successfully",
                                  backgroundColor: Colors.green,
                                );

                                Get.to(
                                  () => EmailVerificationScreen(
                                    emailAddress: _emailController.text.trim(),
                                  ),
                                );
                              } catch (error) {
                                print('ERROR: $error');
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

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      const Text(
                        "Already have an\naccount ?",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Get.toNamed(AppRoutes.usersignin);
                        },
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
