// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:smart_umrah_app/screens/TravelAgent/AgentChatScreens/agentchatScreen.dart';

// class PilgramRequestsScreen extends StatelessWidget {
//   const PilgramRequestsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final String agentId = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Pilgrim Requests"),
//         backgroundColor: Colors.teal,
//       ),

//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection("Requests")
//             .where("agentId", isEqualTo: agentId)
//             .snapshots(), // ✔ No orderBy here to avoid flickering

//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No requests received yet.",
//                 style: TextStyle(fontSize: 18),
//               ),
//             );
//           }
//           final List<DocumentSnapshot> requests = snapshot.data!.docs;

//           requests.sort((a, b) {
//             Timestamp t1 = a["timestamp"] ?? Timestamp(0, 0);
//             Timestamp t2 = b["timestamp"] ?? Timestamp(0, 0);
//             return t2.compareTo(t1); // new → old
//           });

//           return ListView.builder(
//             itemCount: requests.length,
//             itemBuilder: (context, index) {
//               final request = requests[index];

//               final pilgrimName = request["pilgrimName"] ?? "Unknown User";
//               final pilgrimEmail = request["pilgrimEmail"] ?? "No Email";
//               final status = request["status"] ?? "pending";

//               Color statusColor;
//               if (status == "pending") {
//                 statusColor = Colors.orange;
//               } else if (status == "approved") {
//                 statusColor = Colors.green;
//               } else {
//                 statusColor = Colors.red;
//               }

//               return Card(
//                 margin: const EdgeInsets.all(12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),

//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Name: $pilgrimName",
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 5),
//                       Text(
//                         "Email: $pilgrimEmail",
//                         style: const TextStyle(fontSize: 16),
//                       ),

//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           const Text(
//                             "Status: ",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           Text(
//                             status.toUpperCase(),
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: statusColor,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 12),

//                       if (status == "pending")
//                         Row(
//                           children: [
//                             ElevatedButton(
//                               onPressed: () {
//                                 updateStatus(request, "approved");
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                               ),
//                               child: const Text("Approve"),
//                             ),
//                             const SizedBox(width: 10),

//                             ElevatedButton(
//                               onPressed: () {
//                                 updateStatus(request, "rejected");
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                               ),
//                               child: const Text("Reject"),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   void updateStatus(DocumentSnapshot requestDoc, String newStatus) async {
//     final requestId = requestDoc.id;
//     final reqRef = FirebaseFirestore.instance
//         .collection("Requests")
//         .doc(requestId);
//     await reqRef.update({"status": newStatus});

//     if (newStatus == "approved") {
//       // Create or update the agent's group chat and add this pilgrim
//       try {
//         final agentId = FirebaseAuth.instance.currentUser!.uid;
//         final pilgrimId = requestDoc["pilgrimId"] as String?;
//         final pilgrimName = requestDoc["pilgrimName"] as String? ?? 'Pilgrim';

//         if (pilgrimId != null && pilgrimId.isNotEmpty) {
//           // Check if a group chat already exists for this agent
//           final groupQuery = await FirebaseFirestore.instance
//               .collection('chats')
//               .where('agentGroup', isEqualTo: agentId)
//               .limit(1)
//               .get();

//           DocumentReference chatRef;
//           String groupName = 'Registered Pilgrims';

//           if (groupQuery.docs.isNotEmpty) {
//             chatRef = groupQuery.docs.first.reference;
//             // Add pilgrim to participants
//             await chatRef.update({
//               'participants': FieldValue.arrayUnion([pilgrimId]),
//             });
//           } else {
//             chatRef = FirebaseFirestore.instance.collection('chats').doc();
//             await chatRef.set({
//               'participants': [agentId, pilgrimId],
//               'groupName': groupName,
//               'agentGroup': agentId,
//               'lastMessage': '',
//               'lastTimestamp': FieldValue.serverTimestamp(),
//             });
//           }

//           // Add a system message indicating the pilgrim joined
//           await chatRef.collection('messages').add({
//             'senderId': agentId,
//             'receiverId': '', // group
//             'text': '$pilgrimName has joined the group',
//             'timestamp': FieldValue.serverTimestamp(),
//             'status': 'sent',
//             'deletedFor': [],
//           });

//           // Navigate to group chat screen
//           final createdDoc = await chatRef.get();
//           final gName = createdDoc['groupName'] ?? groupName;
//           Get.to(
//             () => AgentChatScreen(partnerId: chatRef.id, partnerName: gName),
//           );
//         }
//       } catch (e) {
//         Get.snackbar(
//           'Error',
//           'Failed to create group chat: $e',
//           backgroundColor: Colors.redAccent,
//         );
//       }
//     }

//     Get.snackbar(
//       "Updated",
//       "Request has been $newStatus",
//       backgroundColor: newStatus == "approved"
//           ? Colors.green
//           : Colors.redAccent,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/screens/TravelAgent/AgentChatScreens/agentchatScreen.dart';

class PilgramRequestsScreen extends StatelessWidget {
  const PilgramRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String agentId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilgrim Requests"),
        backgroundColor: Colors.teal,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Requests")
            .where("agentId", isEqualTo: agentId)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No requests received yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final List<DocumentSnapshot> requests = snapshot.data!.docs;

          requests.sort((a, b) {
            Timestamp t1 = a["timestamp"] ?? Timestamp(0, 0);
            Timestamp t2 = b["timestamp"] ?? Timestamp(0, 0);
            return t2.compareTo(t1);
          });

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              final pilgrimName = request["pilgrimName"] ?? "Unknown User";
              final pilgrimEmail = request["pilgrimEmail"] ?? "No Email";
              final status = request["status"] ?? "pending";

              Color statusColor = status == "pending"
                  ? Colors.orange
                  : status == "approved"
                  ? Colors.green
                  : Colors.red;

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name: $pilgrimName",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Email: $pilgrimEmail",
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Text(
                            "Status: ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (status == "pending")
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                updateStatus(request, "approved");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text("Approve"),
                            ),

                            const SizedBox(width: 10),

                            ElevatedButton(
                              onPressed: () {
                                updateStatus(request, "rejected");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Reject"),
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
      ),
    );
  }

  void updateStatus(DocumentSnapshot requestDoc, String newStatus) async {
    final reqRef = FirebaseFirestore.instance
        .collection("Requests")
        .doc(requestDoc.id);

    await reqRef.update({"status": newStatus});

    if (newStatus == "approved") {
      try {
        final String agentId = FirebaseAuth.instance.currentUser!.uid;
        final String pilgrimId = requestDoc["pilgrimId"];
        final String pilgrimName = requestDoc["pilgrimName"];

        // Find existing group
        final groupQuery = await FirebaseFirestore.instance
            .collection("chats")
            .where("agentGroup", isEqualTo: agentId)
            .limit(1)
            .get();

        DocumentReference chatRef;

        if (groupQuery.docs.isNotEmpty) {
          chatRef = groupQuery.docs.first.reference;
          await chatRef.update({
            "participants": FieldValue.arrayUnion([pilgrimId]),
          });
        } else {
          chatRef = FirebaseFirestore.instance.collection("chats").doc();
          await chatRef.set({
            "agentGroup": agentId, // 🔥 FIXED
            "groupName": "Registered Pilgrims",
            "participants": [agentId, pilgrimId],
            "isGroup": true,
            "lastMessage": "",
            "lastTimestamp": FieldValue.serverTimestamp(),
          });
        }

        await chatRef.collection("messages").add({
          "senderId": agentId,
          "text": "$pilgrimName has joined the group",
          "timestamp": FieldValue.serverTimestamp(),
          "type": "system",
        });

        Get.to(
          () => AgentChatScreen(
            partnerId: chatRef.id,
            partnerName: "Registered Pilgrims",
          ),
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to add pilgrim to group: $e",
          backgroundColor: Colors.red,
        );
      }
    }

    Get.snackbar(
      "Updated",
      "Request has been $newStatus",
      backgroundColor: newStatus == "approved"
          ? Colors.green
          : Colors.redAccent,
    );
  }
}
