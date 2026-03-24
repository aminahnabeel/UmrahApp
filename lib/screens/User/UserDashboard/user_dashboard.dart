import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/DataLayer/User/UserData/user_features.dart';
import 'package:smart_umrah_app/Models/UserProfileDataModel/user_profile_datamodel.dart';
import 'package:smart_umrah_app/Services/firebaseServices/AuthServices/logout.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/UserProfileData/FetchingProfile/fetch_profile.dart';
import '../UserFeatures/umrah_journal_screen.dart';

class UserDashboardController extends GetxController {
  var selectedIndex = 0.obs;

  // store the user profile model
  Rxn<UserProfileDatamodel> currentUser = Rxn<UserProfileDatamodel>();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  loadUser() async {
    final user = await fetchProfile();
    currentUser.value = user;
    print("USER DATA LOADED: ${currentUser.value}");
  }
}

class UserDashboard extends StatelessWidget {
  UserDashboard({super.key});

  final UserDashboardController controller = Get.put(UserDashboardController());

  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);
  static const Color navBarColor = Color(0xFF1E2A38);
  static const Color navBarSelectedItemColor = accentColor;
  static const Color navBarUnselectedItemColor = Colors.white54;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "User Dashboard",
          style: TextStyle(
            color: textColorPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: textColorPrimary),
            onPressed: () async => await logoutUser(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Obx(() {
        return IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            _buildHomeContent(context),
            _buildJournalContent(context),
            _buildSettingsContent(context),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          ],
          currentIndex: controller.selectedIndex.value,
          selectedItemColor: navBarSelectedItemColor,
          unselectedItemColor: navBarUnselectedItemColor,
          backgroundColor: navBarColor,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
        );
      }),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (screenWidth > 600) crossAxisCount = 3;
    if (screenWidth > 900) crossAxisCount = 4;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Text(
              "Assalam u Alaikum, ${controller.currentUser.value?.name ?? 'Guest'}",
              style: TextStyle(
                fontSize: screenWidth < 400 ? 20 : 26,
                fontWeight: FontWeight.bold,
                color: textColorPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Ready for your blessed journey?",
            style: TextStyle(
              fontSize: screenWidth < 400 ? 14 : 16,
              color: textColorSecondary,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: screenWidth < 600 ? 0.9 : 1.1,
            ),
            itemCount: userFeatures.length,
            itemBuilder: (context, index) {
              final feature = userFeatures[index];
              return _buildDashboardCard(
                context,
                icon: feature['icon'],
                title: feature['title'],
                description: feature['description'],
                onTap: () {
                  Get.toNamed(feature['route']);
                },
                screenWidth: screenWidth,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJournalContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book,
                size: screenWidth < 400 ? 60 : 80,
                color: accentColor,
              ),
              const SizedBox(height: 20),
              Text(
                "Umrah Journal",
                style: TextStyle(
                  fontSize: screenWidth < 400 ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: textColorPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Document your spiritual journey here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth < 400 ? 14 : 16,
                  color: textColorSecondary,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => UmrahJournalScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: textColorPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("New Entry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                size: screenWidth < 400 ? 60 : 80,
                color: accentColor,
              ),
              const SizedBox(height: 20),
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: screenWidth < 400 ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: textColorPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Manage your preferences and app configurations.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth < 400 ? 14 : 16,
                  color: textColorSecondary,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Opening detailed settings!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: textColorPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Go to Settings"),
              ),
            ],
          ),
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
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardBackgroundColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: screenWidth < 400 ? 40 : 50, color: accentColor),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColorPrimary,
                  fontSize: screenWidth < 400 ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColorSecondary,
                  fontSize: screenWidth < 400 ? 12 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
