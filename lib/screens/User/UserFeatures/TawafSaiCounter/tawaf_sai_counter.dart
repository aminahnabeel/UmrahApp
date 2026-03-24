import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/userControllers/tawafSaiCounter/tawaf_sai_counter.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/TawafSaiCounter/sai_counter.dart';

class TawafSaiCounter extends StatelessWidget {
  TawafSaiCounter({super.key});

  final CounterController controller = Get.put(CounterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Hero(
                tag: "appLogo",
                child: SizedBox(
                  height: 120,
                  width: 120,
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
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 50),

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
              const SizedBox(height: 50),

              // Reset Button
              ElevatedButton.icon(
                onPressed: controller.reset,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 45,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Get.to(() => SaiCounter()),
                icon: const Icon(Icons.refresh),
                label: const Text("Sai Counter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 45,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
