import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/UserProfileDataModel/user_profile_datamodel.dart';
import 'package:smart_umrah_app/screens/Admin/edit_pilgram_profile_adminscreen.dart';

class AdminManagePilgrimsScreen extends StatelessWidget {
  const AdminManagePilgrimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Pilgrims"), centerTitle: true),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Pilgrims Found", style: TextStyle(fontSize: 16)),
            );
          }

          final pilgrims = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: pilgrims.length,
            itemBuilder: (context, index) {
              final data = pilgrims[index].data() as Map<String, dynamic>;
              final pilgrimId = pilgrims[index].id;

              final pilgrim = UserProfileDatamodel.fromFirebase(data);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  // leading: CircleAvatar(
                  //   radius: 28,
                  //   backgroundImage: pilgrim.profileImageUrl != null &&
                  //           pilgrim.profileImageUrl!.isNotEmpty
                  //       ? NetworkImage(pilgrim.profileImageUrl!)
                  //       : const AssetImage("assets/profile_placeholder.png")
                  //           as ImageProvider,
                  // ),
                  title: Text(
                    pilgrim.name ?? "Unknown User",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${pilgrim.email ?? 'N/A'}"),
                      Text("Passport: ${pilgrim.passportNumber ?? 'N/A'}"),
                      Text("Gender: ${pilgrim.gender ?? 'N/A'}"),
                      Text("DOB: ${pilgrim.dateOfBirth ?? 'N/A'}"),
                    ],
                  ),

                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == "edit") {
                        _navigateToEditPage(context, pilgrim);
                      } else if (value == "delete") {
                        _deletePilgrim(pilgrimId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 10),
                            Text("Delete"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 👉 Delete pilgrim function
  Future<void> _deletePilgrim(String uid) async {
    await FirebaseFirestore.instance.collection("Users").doc(uid).delete();
    Get.snackbar(
      "Deleted",
      "Pilgrim removed successfully",
      backgroundColor: Colors.red.withOpacity(0.2),
    );
  }

  // 👉 Navigate to update screen
  void _navigateToEditPage(BuildContext context, UserProfileDatamodel user) {
    Get.to(
      () => AdminEditPilgrimProfileScreen(
        userProfile: user,
        userId: user.id ?? "",
      ),
    );
  }
}
