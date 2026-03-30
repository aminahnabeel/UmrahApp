import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/routes/routes.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  // --- MODERN THEME COLORS ---
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color scaffoldBgColor = Color(0xFFF4F7FA); // Light Greyish-White
  static const Color textColorPrimary = Color(0xFF1E2A38); // Dark Blue-Grey
  static const Color textColorSecondary = Colors.black54;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- APP LOGO WITH SOFT GLOW ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/umrah_app_logo.png',
                  height: screenHeight * 0.16,
                  width: screenHeight * 0.16,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),

              // --- APP TITLE (Modern & Bold) ---
              Text(
                "Smart Umrah",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight * 0.04,
                  fontWeight: FontWeight.w900,
                  color: primaryBlue,
                  letterSpacing: 0.5,
                ),
              ),
              const Text(
                "Application",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: textColorPrimary,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),

              // --- SUBTITLE ---
              Text(
                "Your premium companion for a\nblessed and sacred journey.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenHeight * 0.018,
                  color: textColorSecondary,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: screenHeight * 0.08),

              // --- USER LOGIN BUTTON (Solid Blue) ---
              _buildModernButton(
                label: "User Login",
                icon: Icons.person_rounded,
                isPrimary: true,
                onPressed: () => Get.toNamed(AppRoutes.usersignin),
              ),
              
              SizedBox(height: screenHeight * 0.02),

              // --- TRAVEL AGENT BUTTON (Outline Blue) ---
              _buildModernButton(
                label: "Travel Agent",
                icon: Icons.business_center_rounded,
                isPrimary: false,
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.agentsignin);
                },
              ),
              
              SizedBox(height: screenHeight * 0.05),
              
              // --- VERSION OR FOOTER ---
              const Text(
                "v1.0.0",
                style: TextStyle(color: Colors.black26, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE MODERN BUTTON HELPER ---
  Widget _buildModernButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: isPrimary ? Colors.white : primaryBlue, size: 20),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPrimary ? Colors.white : primaryBlue,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? primaryBlue : Colors.white,
          elevation: isPrimary ? 4 : 0,
          shadowColor: primaryBlue.withOpacity(0.3),
          side: isPrimary ? BorderSide.none : const BorderSide(color: primaryBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}