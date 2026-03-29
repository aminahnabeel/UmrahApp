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
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.landingscreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardSize = screenSize.width * 0.78;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -screenSize.width * 0.18,
              right: -screenSize.width * 0.22,
              child: _AccentBlob(
                color: Color(0xFFEAF3FF),
                size: screenSize.width * 0.62,
              ),
            ),
            Positioned(
              bottom: -screenSize.width * 0.2,
              left: -screenSize.width * 0.18,
              child: _AccentBlob(
                color: Color(0xFFF3F6FA),
                size: screenSize.width * 0.58,
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.92, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: cardSize,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFE8EEF5)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 30,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: screenSize.width * 0.52,
                        height: screenSize.width * 0.52,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF8FBFF), Color(0xFFEAF3FF)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFDDE9F6)),
                        ),
                        child: Lottie.asset(
                          'assets/Thawaaf.json',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Smart Umrah',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E2A38),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Guiding your journey with clarity and care',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8FC),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF0D47A1),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Preparing your experience',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
          stops: const [0.15, 1.0],
        ),
      ),
    );
  }
}
