import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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

    Get.snackbar(
      "Updated",
      "Request has been $newStatus",
      backgroundColor: newStatus == "approved"
          ? Colors.green
          : Colors.redAccent,
    );
  }
}
