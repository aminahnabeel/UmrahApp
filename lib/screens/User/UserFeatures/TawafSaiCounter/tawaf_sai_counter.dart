import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/userControllers/tawafSaiCounter/tawaf_sai_counter.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/TawafSaiCounter/sai_counter.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart';

class TawafSaiCounter extends StatelessWidget {
  TawafSaiCounter({super.key});

  final CounterController controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. CustomAppBar yahan add kiya hai
      appBar: const CustomAppBar(
        title: "Tawaf Counter",
        showBackButton: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView( // Added scroll view to avoid overflow
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Hero(
                  tag: "appLogo",
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset(
                      "assets/umrah_app_logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Tawaf & Sai Counter",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                
                const SizedBox(height: 40),

                // Counter (tap to increment)
                Obx(
                  () => GestureDetector(
                    onTap: controller.increment,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Card(
                        key: ValueKey(controller.count.value),
                        color: Colors.white.withOpacity(0.15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 35,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            "${controller.count}",
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 6,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Reset Button
                ElevatedButton.icon(
                  onPressed: controller.reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset Counter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                  ),
                ),

                const SizedBox(height: 20),

                // Sai Counter Navigation Button
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => SaiCounter()),
                  icon: const Icon(Icons.directions_run),
                  label: const Text("Go to Sai Counter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}