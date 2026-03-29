import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/DataLayer/AdminData/Features/features.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  void _handleFeatureTap(BuildContext context, String route) {
    if (route.isEmpty) return;
    Get.toNamed(route);
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/admin-login');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out as Admin')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: textColorPrimary),
        ),
        iconTheme: const IconThemeData(color: textColorPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: textColorPrimary),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine the number of columns based on screen width
            int crossAxisCount = 2;
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 3;
            }

            double childAspectRatio =
                constraints.maxWidth / constraints.maxHeight * 1.2;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: adminFeatures.length,
                itemBuilder: (context, index) {
                  final feature = adminFeatures[index];
                  return _buildDashboardCard(
                    context,
                    icon: feature['icon'],
                    title: feature['title'],
                    description: feature['description'],
                    onTap: () => _handleFeatureTap(context, feature['route']),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardBackgroundColor,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: accentColor),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textColorPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textColorSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
