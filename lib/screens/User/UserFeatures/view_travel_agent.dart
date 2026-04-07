import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/chat_service.dart';
import 'package:smart_umrah_app/screens/User/chatScreen.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/agent_rules_view_screen.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart';

class ViewTravelAgent extends StatelessWidget {
  const ViewTravelAgent({super.key});

  // Theme Colors - Matching your app design
  static const Color customBlue = Color(0xFF0D47A1);
  static const Color darkBg = Color(0xFF1E2A38);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: "Travel Agents", showBackButton: true),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1976D2),
            ], // Aapki dashboard theme
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Requests")
                .where("pilgrimId", isEqualTo: userId)
                .snapshots(),
            builder: (context, requestSnap) {
              if (!requestSnap.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final reqDocs = requestSnap.data!.docs;
              return _allAgentsView(reqDocs, userId);
            },
          ),
        ),
      ),
    );
  }

  // --- View A: All Agents ---
  Widget _allAgentsView(List<QueryDocumentSnapshot> reqDocs, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("TravelAgents").snapshots(),
      builder: (context, agentSnap) {
        if (!agentSnap.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: agentSnap.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = agentSnap.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final agent = TravelAgentProfileModel.fromFirebase(data);
            final agentId = doc.id;

            final agentRequests = reqDocs.where((r) => r["agentId"] == agentId);
            final hasPendingRequest = agentRequests.any(
              (r) => (r["status"] ?? "").toString().toLowerCase() == "pending",
            );
            final hasApprovedRequest = agentRequests.any(
              (r) {
                final status = (r["status"] ?? "").toString().toLowerCase();
                return status == "approved" || status == "accepted";
              },
            );

            // Treat declined/rejected as re-requestable; only pending/approved lock the button.
            final requestSent = hasPendingRequest || hasApprovedRequest;

            return Card(
              color: Colors.white, // Standard white cards on blue background
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: customBlue.withOpacity(0.1),
                  backgroundImage: agent.profileImageUrl != null
                      ? NetworkImage(agent.profileImageUrl!)
                      : null,
                  child: agent.profileImageUrl == null
                      ? const Icon(Icons.person, color: customBlue, size: 30)
                      : null,
                ),
                title: Text(
                  agent.name ?? "Unknown Agent",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.agencyName ?? "No Agency",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: hasPendingRequest || requestSent
                              ? null
                              : () => sendRequest(agentId, agent.name ?? ""),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: requestSent
                                ? Colors.grey
                                : customBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            requestSent
                                ? "Sent"
                                : "Request",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _startChatWithAgent(
                            userId: userId,
                            agentId: agentId,
                            agentName: agent.name ?? "Travel Agent",
                            profileImageUrl: agent.profileImageUrl,
                          ),
                          icon: const Icon(Icons.chat_bubble_outline, size: 14),
                          label: const Text(
                            "Chat",
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: customBlue,
                            side: const BorderSide(color: customBlue),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Get.to(
                            () => AgentRulesViewScreen(
                              agentId: agentId,
                              agentName: agent.name ?? "Travel Agent",
                            ),
                          ),
                          icon: const Icon(Icons.rule, size: 14),
                          label: const Text(
                            "Rules",
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- View B: Approved Agent ---
  Widget _approvedAgentView(String agentId, String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("TravelAgents")
          .doc(agentId)
          .snapshots(),
      builder: (context, agentSnap) {
        if (!agentSnap.hasData) return const SizedBox();

        final data = agentSnap.data!.data() as Map<String, dynamic>;
        final agent = TravelAgentProfileModel.fromFirebase(data);
        final chatId = ChatService.buildUserAgentChatId(userId, agentId);

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .doc(chatId)
              .snapshots(),
          builder: (context, chatSnap) {
            final chatData = chatSnap.data?.data() as Map<String, dynamic>?;
            final unreadCount = chatData?["unreadCount_$userId"] ?? 0;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Your Approved Agent",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: agent.profileImageUrl != null
                          ? NetworkImage(agent.profileImageUrl!)
                          : null,
                      child: agent.profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: customBlue,
                            )
                          : null,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      agent.name ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _startChatWithAgent(
                                userId: userId,
                                agentId: agentId,
                                agentName: agent.name ?? "Travel Agent",
                                profileImageUrl: agent.profileImageUrl,
                              ),
                              icon: const Icon(
                                Icons.chat_bubble,
                                color: customBlue,
                              ),
                              label: const Text(
                                "Start Chat",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: customBlue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: -5,
                                top: -5,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadCount > 99
                                        ? "99+"
                                        : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Get.to(
                            () => AgentRulesViewScreen(
                              agentId: agentId,
                              agentName: agent.name ?? "Travel Agent",
                            ),
                          ),
                          icon: const Icon(Icons.rule, color: Colors.green),
                          label: const Text(
                            "View Rules",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> sendRequest(String agentId, String agentName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
      .collection("Users")
      .doc(user.uid)
      .get();
    final userData = userDoc.data() ?? <String, dynamic>{};

    final String fullNameFromProfile =
      (userData["name"] ?? userData["fullName"] ?? "").toString().trim();
    final String displayName = (user.displayName ?? "").trim();
    final String email = user.email ?? "";
    final String fallbackName = email.contains("@")
        ? email.split("@").first
        : "Pilgrim";
    final String pilgrimName = fullNameFromProfile.isNotEmpty
      ? fullNameFromProfile
      : (displayName.isNotEmpty ? displayName : fallbackName);

    await FirebaseFirestore.instance.collection("Requests").add({
      "agentId": agentId,
      "pilgrimId": user.uid,
      "pilgrimName": pilgrimName,
      "username": pilgrimName,
      "name": pilgrimName,
      "fullName": pilgrimName,
      "pilgrimEmail": email,
      "timestamp": FieldValue.serverTimestamp(),
      "status": "pending",
    });
    Get.snackbar(
      "Request Sent",
      "Waiting for $agentName's approval",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: customBlue,
    );
  }

  Future<void> _startChatWithAgent({
    required String userId,
    required String agentId,
    required String agentName,
    String? profileImageUrl,
  }) async {
    try {
      final chatId = await ChatService.createOrGetUserAgentChat(
        userId: userId,
        agentId: agentId,
      );

      Get.to(
        () => ChatScreen(
          chatId: chatId,
          partnerId: agentId,
          partnerName: agentName,
          partnerImageUrl: profileImageUrl,
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Chat Error",
        "Unable to start chat right now: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
