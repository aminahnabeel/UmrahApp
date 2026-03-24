import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/screens/User/chatScreen.dart';

class ViewTravelAgent extends StatelessWidget {
  const ViewTravelAgent({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2A38),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A38),
        title: const Text(
          "Travel Agents",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Requests")
            .where("pilgrimId", isEqualTo: userId)
            .snapshots(),
        builder: (context, requestSnap) {
          if (!requestSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reqDocs = requestSnap.data!.docs;

          // Check if an approved agent exists
          final approvedReq = reqDocs.cast<QueryDocumentSnapshot?>().firstWhere(
            (d) => d?["status"] == "approved",
            orElse: () => null,
          );

          if (approvedReq != null) {
            // Show only approved agent + group chat
            final agentId = approvedReq["agentId"];
            return _approvedAgentView(agentId, userId);
          }

          // Show all agents + request system
          return _allAgentsView(reqDocs, userId);
        },
      ),
    );
  }

  // VIEW A → Show all agents until request approved
  Widget _allAgentsView(List<QueryDocumentSnapshot> reqDocs, String userId) {
    final pendingReq = reqDocs.cast<QueryDocumentSnapshot?>().firstWhere(
      (d) => d?["status"] == "pending",
      orElse: () => null,
    );

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("TravelAgents").snapshots(),
      builder: (context, agentSnap) {
        if (!agentSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: agentSnap.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final agent = TravelAgentProfileModel.fromFirebase(data);
            final agentId = doc.id;

            bool requestSent = reqDocs.any((r) => r["agentId"] == agentId);

            return Card(
              color: const Color(0xFF283645),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: agent.profileImageUrl != null
                              ? NetworkImage(agent.profileImageUrl!)
                              : const AssetImage(
                                      'assets/images/agent_placeholder.png',
                                    )
                                    as ImageProvider,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            agent.name ?? "Unknown Agent",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      agent.email ?? "No Email",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      agent.agencyName ?? "No Agency",
                      style: const TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: pendingReq != null || requestSent
                          ? null
                          : () => sendRequest(agentId, agent.name ?? ""),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: requestSent
                            ? Colors.grey
                            : Colors.teal,
                      ),
                      child: Text(
                        requestSent
                            ? "Request Sent"
                            : pendingReq != null
                            ? "Pending..."
                            : "Send Request",
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // ⭐ VIEW B → Show ONLY approved agent + group chat button with unread badge
  // ------------------------------------------------------------------
  Widget _approvedAgentView(String agentId, String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("TravelAgents")
          .doc(agentId)
          .snapshots(),
      builder: (context, agentSnap) {
        if (!agentSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = agentSnap.data!.data() as Map<String, dynamic>;
        final agent = TravelAgentProfileModel.fromFirebase(data);

        // ✅ Listen to the chat document for unread counts
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .where("agentGroup", isEqualTo: agentId)
              .limit(1)
              .snapshots(),
          builder: (context, chatSnap) {
            if (!chatSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            int unreadCount = 0;
            DocumentReference? chatRef;

            if (chatSnap.data!.docs.isNotEmpty) {
              final chatDoc = chatSnap.data!.docs.first;
              chatRef = chatDoc.reference;

              // ✅ Safely check if the unread field exists for this user
              final chatData = chatDoc.data() as Map<String, dynamic>;
              if (chatData.containsKey("unreadCount_$userId")) {
                unreadCount = chatData["unreadCount_$userId"] ?? 0;
              }
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: const Color(0xFF283645),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: agent.profileImageUrl != null
                              ? NetworkImage(agent.profileImageUrl!)
                              : const AssetImage(
                                      'assets/images/agent_placeholder.png',
                                    )
                                    as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            agent.name ?? "Unknown Agent",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.group,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () async {
                                // Reset unread count when opening the chat
                                if (chatRef != null) {
                                  await chatRef.update({
                                    "unreadCount_$userId": 0,
                                  });
                                }

                                openGroupChat(agentId, agent.name ?? "Group");
                              },
                            ),
                            // ✅ Unread badge
                            if (unreadCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
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
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Send request to agent
  Future<void> sendRequest(String agentId, String agentName) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("Requests").add({
      "agentId": agentId,
      "pilgrimId": userId,
      "pilgrimName": FirebaseAuth.instance.currentUser!.displayName ?? "",
      "pilgrimEmail": FirebaseAuth.instance.currentUser!.email ?? "",
      "timestamp": FieldValue.serverTimestamp(),
      "status": "pending",
    });

    Get.snackbar(
      "Request Sent",
      "Your request was sent to $agentName",
      backgroundColor: Colors.green,
    );
  }

  // Open group chat
  Future<void> openGroupChat(String agentId, String agentName) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final groupQuery = await FirebaseFirestore.instance
        .collection("chats")
        .where("agentGroup", isEqualTo: agentId)
        .limit(1)
        .get();

    DocumentReference chatRef;

    if (groupQuery.docs.isNotEmpty) {
      chatRef = groupQuery.docs.first.reference;
      await chatRef.update({
        "participants": FieldValue.arrayUnion([userId]),
        "unreadCount_$userId": 0, // reset unread count for this user
      });
    } else {
      chatRef = FirebaseFirestore.instance.collection("chats").doc();

      await chatRef.set({
        "participants": [agentId, userId],
        "groupName": "$agentName Group",
        "agentGroup": agentId,
        "isGroup": true,
        "lastMessage": "",
        "lastTimestamp": FieldValue.serverTimestamp(),
        "unreadCount_$userId": 0,
      });
    }

    Get.to(
      () => ChatScreen(partnerId: chatRef.id, partnerName: "$agentName Group"),
    );
  }
}
