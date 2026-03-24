import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:smart_umrah_app/DataLayer/AgentData/features.dart';
import 'package:smart_umrah_app/Services/firebaseServices/AuthServices/logout.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:smart_umrah_app/screens/TravelAgent/show_profile.dart';

class TravelAgentDashboardScreen extends StatelessWidget {
  TravelAgentDashboardScreen({super.key});

  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  void _handleFeatureTap(String route) {
    Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;
    final bool isLargeScreen = size.width >= 1000;

    final int gridColumns = isLargeScreen
        ? 4
        : isTablet
        ? 3
        : 2;
    final double aspectRatio = isLargeScreen
        ? 1.2
        : isTablet
        ? 1.05
        : 0.85;

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await logoutUser();
              Get.offAllNamed(AppRoutes.landingscreen);
            },
          ),
        ],
        elevation: 0,
        title: const Text(
          "Travel Agent Dashboard",
          style: TextStyle(color: textColorPrimary),
        ),
        iconTheme: const IconThemeData(color: textColorPrimary),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Get.toNamed(AppRoutes.agentdashboard);
          } else if (index == 1) {
            Get.to(() => ShowAgentProfile());
          }
        },
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: agentFeatures.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, index) {
              final feature = agentFeatures[index];
              return buildDashboardCard(
                icon: feature['icon'],
                title: feature['title'],
                description: feature['description'],
                onTap: () => _handleFeatureTap(feature['route']),
                isTablet: isTablet,
                isLarge: isLargeScreen,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget drawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = textColorPrimary,
    Color textColor = textColorPrimary,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor, fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget buildDashboardCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required bool isTablet,
    required bool isLarge,
  }) {
    return Material(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(
            isLarge
                ? 24
                : isTablet
                ? 20
                : 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isLarge
                    ? 50
                    : isTablet
                    ? 42
                    : 35,
                color: accentColor,
              ),
              const SizedBox(height: 12),

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColorPrimary,
                  fontSize: isLarge
                      ? 20
                      : isTablet
                      ? 18
                      : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColorSecondary,
                  fontSize: isLarge
                      ? 15
                      : isTablet
                      ? 14
                      : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
