import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/authControllers/agentAuthController/agentsignin_controller.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:smart_umrah_app/validation/auth_validation.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';
import 'package:smart_umrah_app/widgets/customtextfield.dart';

class AgentSignInScreen extends StatelessWidget {
  AgentSignInScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _obscureText = true.obs;
  final RxBool _isLoading = false.obs;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AgentSigninController _signincontroller =
      Get.put(AgentSigninController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF263442),
      appBar: AppBar(
        backgroundColor: const Color(0XFF263442),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Agent Login",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Image.asset('assets/umrah_app_logo.png',
                      height: 150, width: 150),
                  const SizedBox(height: 24),
                  customTextField(
                    "Enter Email Address",
                    controller: _emailController,
                    validator: AuthFormValidation.validateEmail,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText.value,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText.value
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            _obscureText.value = !_obscureText.value;
                          },
                        ),
                      ),
                      validator: AuthFormValidation.validatePassword,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.forgotpassword);
                      },
                      child: const Text(
                        "Forgot Password",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => CustomButton(
                      text: 'L O G I N',
                      isLoading: _isLoading.value,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        _isLoading.value = true;

                        // Admin shortcut
                        if (_emailController.text.trim() == "admin@gmail.com" &&
                            _passwordController.text.trim() == "admin123") {
                          _isLoading.value = false;
                          Get.offNamed(AppRoutes.admindashboard);
                          return;
                        }

                        bool success =
                            await _signincontroller.AgentloginUser(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          context,
                        );

                        _isLoading.value = false;

                        if (success) {
                          Get.offNamed(AppRoutes.agentdashboard);
                        }
                        // if not success, the controller already showed Snackbar
                      },
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Don't Have an account ?",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.agentregister);
                    },
                    child: const Text(
                      "REGISTER",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child:
                            Text('OR', style: TextStyle(color: Colors.white)),
                      ),
                      Expanded(child: Divider(color: Colors.white)),
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
}
