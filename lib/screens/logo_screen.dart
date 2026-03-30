import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_umrah_app/routes/routes.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.landingscreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // --- THEME COLORS ---
    const Color primaryBlue = Color(0xFF0D47A1);
    const Color softBlueBg = Color(0xFFF8FAFF);

    return Scaffold(
      backgroundColor: softBlueBg,
      body: Stack(
        children: [
          // Background Decorative Blobs
          Positioned(
            top: -100,
            right: -50,
            child: _AccentBlob(color: primaryBlue.withOpacity(0.08), size: 300),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: _AccentBlob(color: primaryBlue.withOpacity(0.05), size: 250),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Card Container
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    width: screenSize.width * 0.75,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.12),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Lottie Animation Container
                        Container(
                          height: screenSize.width * 0.45,
                          width: screenSize.width * 0.45,
                          decoration: BoxDecoration(
                            color: softBlueBg,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Lottie.asset(
                            'assets/Thawaaf.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // App Title
                        const Text(
                          'Smart Umrah',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: primaryBlue,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Guiding your sacred journey',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Modern Loading Indicator
                Column(
                  children: [
                    const SizedBox(
                      width: 40,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Initializing Experience...',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryBlue.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentBlob extends StatelessWidget {
  const _AccentBlob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.0)],
        ),
      ),
    );
  }
}