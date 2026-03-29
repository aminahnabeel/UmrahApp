import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/firebaseDatabase/AgentData/fetch_profile.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:smart_umrah_app/screens/TravelAgent/edit_profile.dart';

class ShowAgentProfile extends StatelessWidget {
  const ShowAgentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text("My Profile"),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.agentdashboard);
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: FutureBuilder<TravelAgentProfileModel?>(
        future: fetchAgentProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No profile data found."));
          }

          final profile = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // --- Profile Header ---
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        profile.gender!.toLowerCase() == 'male'
                            ? CircleAvatar(
                                radius: 100,
                                backgroundImage: profile.profileImageUrl != null
                                    ? NetworkImage(profile.profileImageUrl!)
                                    : const AssetImage(
                                            'assets/images/talha.jpg',
                                          )
                                          as ImageProvider,
                              )
                            : CircleAvatar(
                                radius: 100,
                                backgroundImage: profile.profileImageUrl != null
                                    ? NetworkImage(profile.profileImageUrl!)
                                    : const AssetImage(
                                            'assets/images/female_test_image.jpeg',
                                          )
                                          as ImageProvider,
                              ),
                        const SizedBox(height: 15),
                        Text(
                          profile.name ?? "Unknown",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Agency: ${profile.agencyName ?? 'N/A'}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.edit, color: Colors.grey),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.to(
                                      () => EditAgentProfileScreen(
                                        userProfile: profile,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Edit",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 5),
                            profile.isVerified
                                ? GestureDetector(
                                    onTap: () {
                                      Get.snackbar(
                                        "Verification",
                                        "Your ID is already verified.",
                                        snackPosition: SnackPosition.TOP,
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.verified_user_sharp,
                                          color: Colors.green,
                                        ),
                                        Text(
                                          "Verified",
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Icon(Icons.verified_user_outlined),
                                      TextButton(
                                        onPressed: () {
                                          // Get.toNamed(AppRoutes.ocrIdCardPage);
                                        },
                                        child: Text(
                                          "UnVerifed",

                                          style: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // --- Personal Information ---
                buildCategoryCard(context, "Personal Information", [
                  buildProfileField("Name", profile.permanentAddress),
                  buildProfileField("DOB", profile.dateOfBirth),
                  buildProfileField("Email", profile.email),
                  buildProfileField("Gender", profile.gender),
                  buildProfileField("Passport Number", profile.passportNumber),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  /// A reusable card for each category
  Widget buildCategoryCard(
    BuildContext context,
    String title,
    List<Widget> fields,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1),
            ...fields,
          ],
        ),
      ),
    );
  }

  /// A single field inside a category
  Widget buildProfileField(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }
}
