import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/screens/User/chatScreen.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart'; //

class ViewTravelAgent extends StatelessWidget {
  const ViewTravelAgent({super.key});

  // Theme Colors - Matching your app design
  static const Color customBlue = Color(0xFF0D47A1);
  static const Color darkBg = Color(0xFF1E2A38);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      extendBodyBehindAppBar: true, // For smooth gradient flow
      appBar: const CustomAppBar(
        title: "Travel Agents",
        showBackButton: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)], // Aapki dashboard theme
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
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              final reqDocs = requestSnap.data!.docs;

              // Approved agent check
              final approvedReq = reqDocs.cast<QueryDocumentSnapshot?>().firstWhere(
                    (d) => d?["status"] == "approved",
                    orElse: () => null,
                  );

              if (approvedReq != null) {
                final agentId = approvedReq["agentId"];
                return _approvedAgentView(agentId, userId);
              }

              return _allAgentsView(reqDocs, userId);
            },
          ),
        ),
      ),
    );
  }

  // --- View A: All Agents ---
  Widget _allAgentsView(List<QueryDocumentSnapshot> reqDocs, String userId) {
    final pendingReq = reqDocs.cast<QueryDocumentSnapshot?>().firstWhere(
          (d) => d?["status"] == "pending",
          orElse: () => null,
        );

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("TravelAgents").snapshots(),
      builder: (context, agentSnap) {
        if (!agentSnap.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: agentSnap.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = agentSnap.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final agent = TravelAgentProfileModel.fromFirebase(data);
            final agentId = doc.id;

            bool requestSent = reqDocs.any((r) => r["agentId"] == agentId);

            return Card(
              color: Colors.white, // Standard white cards on blue background
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                title: Text(agent.name ?? "Unknown Agent",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent.agencyName ?? "No Agency", style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: pendingReq != null || requestSent
                          ? null
                          : () => sendRequest(agentId, agent.name ?? ""),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: requestSent ? Colors.grey : customBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(requestSent ? "Sent" : (pendingReq != null ? "Wait..." : "Request")),
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

  // --- View B: Approved Agent (Group Chat) ---
  Widget _approvedAgentView(String agentId, String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("TravelAgents").doc(agentId).snapshots(),
      builder: (context, agentSnap) {
        if (!agentSnap.hasData) return const SizedBox();

        final data = agentSnap.data!.data() as Map<String, dynamic>;
        final agent = TravelAgentProfileModel.fromFirebase(data);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .where("agentGroup", isEqualTo: agentId)
              .limit(1)
              .snapshots(),
          builder: (context, chatSnap) {
            int unreadCount = 0;
            DocumentReference? chatRef;

            if (chatSnap.hasData && chatSnap.data!.docs.isNotEmpty) {
              final chatDoc = chatSnap.data!.docs.first;
              chatRef = chatDoc.reference;
              final chatData = chatDoc.data() as Map<String, dynamic>;
              unreadCount = chatData["unreadCount_$userId"] ?? 0;
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Your Approved Agent",
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: agent.profileImageUrl != null
                          ? NetworkImage(agent.profileImageUrl!)
                          : null,
                      child: agent.profileImageUrl == null
                          ? const Icon(Icons.person, size: 50, color: customBlue)
                          : null,
                    ),
                    const SizedBox(height: 15),
                    Text(agent.name ?? "",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    
                    // Chat Button with Badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => openGroupChat(agentId, agent.name ?? "Group"),
                          icon: const Icon(Icons.group, color: customBlue),
                          label: const Text("Join Group Chat", 
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: customBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: -5,
                            top: -5,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Text(unreadCount.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12)),
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

  // --- Functions (Unchanged Logic, added snackbar styling) ---
  Future<void> sendRequest(String agentId, String agentName) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection("Requests").add({
      "agentId": agentId,
      "pilgrimId": user!.uid,
      "pilgrimName": user.displayName ?? "Pilgrim",
      "pilgrimEmail": user.email ?? "",
      "timestamp": FieldValue.serverTimestamp(),
      "status": "pending",
    });
    Get.snackbar("Request Sent", "Waiting for $agentName's approval",
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white, colorText: customBlue);
  }

  Future<void> openGroupChat(String agentId, String agentName) async {
    // ... logic same as yours ...
    // Just navigate after resetting count
    Get.to(() => ChatScreen(partnerId: agentId, partnerName: "$agentName Group"));
  }
}