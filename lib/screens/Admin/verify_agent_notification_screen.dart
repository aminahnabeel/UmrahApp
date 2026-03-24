import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';

class AdminNotificationsUnverifiedAgents extends StatelessWidget {
  const AdminNotificationsUnverifiedAgents({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Agent Verifications"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("TravelAgents")
            .where("isVerified", isEqualTo: false)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No new verification requests",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final unverifiedAgents = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: unverifiedAgents.length,
            itemBuilder: (context, index) {
              final data =
                  unverifiedAgents[index].data() as Map<String, dynamic>;
              final agentId = unverifiedAgents[index].id;

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
                    agent.name ?? "Unknown Agent",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${agent.email ?? 'N/A'}"),
                      Text("Agency: ${agent.agencyName ?? 'N/A'}"),
                    ],
                  ),

                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Verify"),
                    onPressed: () async {
                      await _verifyAgent(agentId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to verify an agent
  Future<void> _verifyAgent(String agentId) async {
    await FirebaseFirestore.instance
        .collection("TravelAgents")
        .doc(agentId)
        .update({"isVerified": true});

    Get.snackbar(
      "Verified",
      "Agent has been successfully verified",
      backgroundColor: Colors.green.withOpacity(0.2),
    );
  }
}
