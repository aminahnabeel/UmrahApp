import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/authControllers/userauthcontroller/usersignin_controller.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:smart_umrah_app/validation/auth_validation.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';
import 'package:smart_umrah_app/widgets/customtextfield.dart';

class UserSignInScreen extends StatelessWidget {
  UserSignInScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _obscureText = true.obs;
  final RxBool _isLoading = false.obs;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SigninController _signincontroller = Get.put(SigninController());

  // Theme Colors (Dashboard se matching)
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF64B5F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient Background for a premium look
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryBlue, secondaryBlue], // Blue Theme
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Image.asset(
                      'assets/umrah_app_logo.png',
                      height: 140,
                      width: 140,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Sign in to continue your journey",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    customTextField(
                      "Enter Email Address",
                      controller: _emailController,
                      validator: AuthFormValidation.validateEmail,
                      prefixIcon: const Icon(Icons.email, color: primaryBlue),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    Obx(
                      () => TextFormField(
                        obscureText: _obscureText.value,
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.lock, color: primaryBlue),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText.value ? Icons.visibility_off : Icons.visibility,
                              color: primaryBlue,
                            ),
                            onPressed: () => _obscureText.value = !_obscureText.value,
                          ),
                        ),
                        validator: (value) => AuthFormValidation.validatePassword(value),
                      ),
                    ),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.forgotpassword),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Button
                    Obx(
                      () => CustomButton(
                        text: 'L O G I N',
                        isLoading: _isLoading.value,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _isLoading.value = true;
                            
                            // Admin Check
                            if (_emailController.text.trim() == "admin@gmail.com" &&
                                _passwordController.text.trim() == "admin123") {
                              _isLoading.value = false;
                              Get.toNamed(AppRoutes.admindashboard);
                              return;
                            }

                            bool success = await _signincontroller.loginUser(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              context,
                              AccountType.user,
                            );

                            _isLoading.value = false;
                            if (success) Get.offNamed(AppRoutes.userdashboard);
                          }
                        },
                        // Button color matching the accent
                        width: double.infinity, 
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(color: Colors.white)),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.userregister),
                          child: const Text(
                            "REGISTER",
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white38, thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("OR", style: TextStyle(color: Colors.white38)),
                        ),
                        Expanded(child: Divider(color: Colors.white38, thickness: 1)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}