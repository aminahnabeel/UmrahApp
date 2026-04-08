import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/DataLayer/User/UserData/user_features.dart';
import 'package:smart_umrah_app/Services/firebaseServices/AuthServices/logout.dart';
import 'package:smart_umrah_app/screens/User/UserDashboard/chatbot.dart';
import 'package:smart_umrah_app/screens/User/UserDashboard/profile_screen.dart';
import 'package:smart_umrah_app/screens/User/UserDashboard/user_dashboard_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../UserFeatures/umrah_journal_screen.dart';

class UserDashboard extends StatelessWidget {
  UserDashboard({super.key});

  final UserDashboardController controller = Get.put(UserDashboardController());

  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color scaffoldBgColor = Color(0xFFF4F7FA);
  static const Color cardColor = Colors.white;

  void openNusuk(BuildContext context) async {
    final Uri appUri = Uri.parse("nusuk://");
    final Uri playStoreUri = Uri.parse("https://play.google.com/store/apps/details?id=com.moh.nusukapp");

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Nusuk App Required"),
          content: const Text("To apply for Umrah or Hajj, please install the official Nusuk app."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(onPressed: () async => await launchUrl(playStoreUri), child: const Text("Install")),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: scaffoldBgColor,
        // Yahan logic hai: Agar Home (0) hai to AppBar dikhao, warna null (hide)
        appBar: controller.selectedIndex.value == 0 
          ? AppBar(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text("User Dashboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22), 
                  onPressed: () => Get.to(() => ChatbotScreen())
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 22), 
                  onPressed: () async => await logoutUser()
                ),
              ],
            )
          : null, 
        
        body: Stack(
          children: [
            IndexedStack(
              index: controller.selectedIndex.value,
              children: [
                _buildHomeContent(context),
                UmrahJournalScreen(), // Iska apna app bar show hoga
                const ProfileDetailScreen(), 
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildFloatingBottomBar(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFloatingBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded, size: 22), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_stories_rounded, size: 22), label: 'Journal'),
              BottomNavigationBarItem(icon: Icon(Icons.person_pin_rounded, size: 22), label: 'Profile'),
            ],
            currentIndex: controller.selectedIndex.value,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            backgroundColor: Colors.transparent,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 12,
            unselectedFontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final List<Color> iconColors = [
      Colors.orange.shade700, Colors.green.shade600, Colors.redAccent.shade400,
      Colors.purple.shade600, Colors.teal.shade600, Colors.amber.shade800
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                "Assalam u Alaikum, ${controller.currentUser.value?.name ?? 'Guest'}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue),
              )),
          const Text("Ready for your blessed journey?", style: TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 100), 
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 600 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: userFeatures.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildDashboardCard(
                    icon: Icons.travel_explore_rounded,
                    iconColor: Colors.blue.shade800,
                    title: "Nusuk App",
                    description: "Apply for Umrah",
                    onTap: () => openNusuk(context),
                  );
                }
                final feature = userFeatures[index - 1];
                return _buildDashboardCard(
                  icon: feature['icon'],
                  iconColor: iconColors[(index - 1) % iconColors.length],
                  title: feature['title'],
                  description: feature['description'],
                  onTap: () => Get.toNamed(feature['route']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({required IconData icon, required Color iconColor, required String title, required String description, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(description, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: Colors.black45, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}