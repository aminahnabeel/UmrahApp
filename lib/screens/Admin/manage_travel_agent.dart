import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/screens/Admin/edit_agent_profile_adminScreen.dart';

class AdminManageAgentsScreen extends StatelessWidget {
  const AdminManageAgentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Travel Agents"),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Color(0XFF252526),
      ),
      backgroundColor: Color(0XFF252526),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("TravelAgents")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Travel Agents Found"));
          }

          final agents = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final data = agents[index].data() as Map<String, dynamic>;
              final agentId = agents[index].id;

              final agent = TravelAgentProfileModel.fromFirebase(data);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage:
                        agent.profileImageUrl != null &&
                            agent.profileImageUrl!.isNotEmpty
                        ? NetworkImage(agent.profileImageUrl!)
                        : const AssetImage("assets/profile_placeholder.png")
                              as ImageProvider,
                  ),

                  title: Text(
                    agent.name ?? "No Name",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${agent.email ?? 'N/A'}"),
                      Text("Agency: ${agent.agencyName ?? 'N/A'}"),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      // IconButton(
                      //   icon: const Icon(Icons.edit, color: Colors.blue),
                      //   onPressed: () {
                      //     Get.to(
                      //       () => EditAgentProfileAdminScreen(
                      //         agentId: agentId,
                      //         agentData: agent,
                      //       ),
                      //     );
                      //   },
                      // ),

                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(context, agentId);
                        },
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

  // Confirm Delete Dialog
  void _confirmDelete(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Travel Agent"),
          content: const Text(
            "Are you sure you want to permanently delete this agent?",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("TravelAgents")
                    .doc(uid)
                    .delete();

                Get.back();
                Get.snackbar(
                  "Deleted",
                  "Travel Agent removed successfully",
                  backgroundColor: Colors.redAccent.withOpacity(0.2),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
