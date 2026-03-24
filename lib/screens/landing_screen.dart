import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/routes/routes.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);
  static const Color titleTextColor = Color(0xFFBBBBBB);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'assets/umrah_app_logo.png',
                height: screenHeight * 0.18,
                width: screenHeight * 0.18,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenHeight * 0.04),

              // App Title
              Text(
                "Smart Umrah Application",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight * 0.035,
                  fontWeight: FontWeight.bold,
                  color: titleTextColor,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              // Subtitle
              Text(
                "Your companion for a blessed journey.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight * 0.02,
                  color: textColorSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: screenHeight * 0.08),

              // User Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.usersignin),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black26,
                  ),
                  child: Text(
                    "User Login",
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.bold,
                      color: textColorPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(AppRoutes.agentsignin);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black26,
                  ),
                  child: Text(
                    "Travel Agent",
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.bold,
                      color: textColorPrimary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.025),
            ],
          ),
        ),
      ),
    );
  }
}
