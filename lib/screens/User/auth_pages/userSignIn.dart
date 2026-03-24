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

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SigninController _signincontroller = Get.put(SigninController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF263442),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/umrah_app_logo.png',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  customTextField(
                    "Enter Email Address",
                    controller: _emailController,
                    validator: AuthFormValidation.validateEmail,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 16),

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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Align(
                    alignment: AlignmentGeometry.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.forgotpassword);
                      },
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Obx(
                    () => CustomButton(
                      text: 'L O G I N',
                      isLoading: _isLoading.value,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _isLoading.value = true;

                          // 🔥 Admin login (as you already had)
                          if (_emailController.text.trim() ==
                                  "admin@gmail.com" &&
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

                          if (success) {
                            Get.offNamed(
                              AppRoutes.userdashboard,
                            ); // ✅ Redirect only when success
                          }
                        }
                      },
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  const Text(
                    "Don't Have an account ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(AppRoutes.userregister);
                    },
                    child: const Text(
                      "REGISTER",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    children: const [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'OR',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  // LoginWithGoogle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
