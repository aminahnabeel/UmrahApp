import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Services/firebaseServices/approved_users_service.dart';

class PilgramRequestsScreen extends StatelessWidget {
  const PilgramRequestsScreen({super.key});

  static const String _pendingStatus = "pending";
  static const String _acceptedStatus = "accepted";
  static const String _declinedStatus = "declined";

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login again."),
        ),
      );
    }

    final String agentId = currentUser.uid;
    final ApprovedUsersService approvedUsersService = ApprovedUsersService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilgrims Request"),
        backgroundColor: Colors.teal,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("Requests")
            .where("agentId", isEqualTo: agentId)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Failed to load requests. ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

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

          final List<QueryDocumentSnapshot<Map<String, dynamic>>> allRequests =
              snapshot.data!.docs
                .where((doc) => doc.data()["deletedForAgent"] != true)
                .toList();

          allRequests.sort((a, b) {
            final dataA = a.data();
            final dataB = b.data();
            final Timestamp t1 = dataA["timestamp"] as Timestamp? ?? Timestamp(0, 0);
            final Timestamp t2 = dataB["timestamp"] as Timestamp? ?? Timestamp(0, 0);
            return t2.compareTo(t1);
          });

          final pendingRequests = allRequests
              .where((doc) {
                final status =
                    (doc.data()["status"] ?? _pendingStatus).toString().toLowerCase();
                return status == _pendingStatus;
              })
              .toList();

          final declinedRequests = allRequests
              .where((doc) {
                final status =
                    (doc.data()["status"] ?? "").toString().toLowerCase();
                return status == _declinedStatus || status == "rejected";
              })
              .toList();

          final acceptedRequests = allRequests
              .where((doc) {
                final status =
                    (doc.data()["status"] ?? "").toString().toLowerCase();
                return status == _acceptedStatus || status == "approved";
              })
              .toList();

          if (pendingRequests.isEmpty && declinedRequests.isEmpty && acceptedRequests.isEmpty) {
            return const Center(
              child: Text(
                "No requests received yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView(
            children: [
              if (pendingRequests.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    "Pending Requests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ...pendingRequests.map((request) {
                return _buildRequestCard(
                  request: request,
                  approvedUsersService: approvedUsersService,
                  agentId: agentId,
                );
              }),
              if (acceptedRequests.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    "Accepted Requests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ...acceptedRequests.map(
                (request) => _buildRequestCard(
                  request: request,
                  approvedUsersService: approvedUsersService,
                  agentId: agentId,
                  showActions: false,
                ),
              ),
              if (declinedRequests.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    "Declined Requests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ...declinedRequests.map(
                (request) => _buildRequestCard(
                  request: request,
                  approvedUsersService: approvedUsersService,
                  agentId: agentId,
                  showActions: false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestCard({
    required QueryDocumentSnapshot<Map<String, dynamic>> request,
    required ApprovedUsersService approvedUsersService,
    required String agentId,
    bool showActions = true,
  }) {
    final data = request.data();
    final pilgrimEmail = (data["pilgrimEmail"] ?? "No Email").toString();

    String pilgrimName =
      (data["name"] ??
          data["fullName"] ??
          data["pilgrimName"] ??
          data["username"] ??
          data["userName"] ??
          "")
            .toString()
            .trim();
    if (pilgrimName.isEmpty || pilgrimName.toLowerCase() == "pilgrim") {
      pilgrimName = pilgrimEmail.contains("@")
          ? pilgrimEmail.split("@").first
          : "Unknown User";
    }

    String status = (data["status"] ?? _pendingStatus).toString().toLowerCase();

    if (status == "rejected") {
      status = _declinedStatus;
    }

    if (status == "approved") {
      status = _acceptedStatus;
    }

    final Color statusColor = status == _pendingStatus
        ? Colors.orange
        : status == _acceptedStatus
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Name: $pilgrimName",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    clearRequestFromThisScreen(request);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Delete from this screen",
                ),
              ],
            ),

            const SizedBox(height: 2),

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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

            if (showActions && status == _pendingStatus)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        updateStatus(
                          request,
                          _acceptedStatus,
                          approvedUsersService,
                          agentId,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        fixedSize: const Size(120, 42),
                      ),
                      child: const Text("Accept"),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        updateStatus(
                          request,
                          _declinedStatus,
                          approvedUsersService,
                          agentId,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        fixedSize: const Size(120, 42),
                      ),
                      child: const Text("Decline"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> clearRequestFromThisScreen(
    QueryDocumentSnapshot<Map<String, dynamic>> requestDoc,
  ) async {
    try {
      await FirebaseFirestore.instance.collection("Requests").doc(requestDoc.id).update({
        "deletedForAgent": true,
        "deletedForAgentAt": FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Deleted",
        "Request removed from this screen.",
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete request: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateStatus(
    QueryDocumentSnapshot<Map<String, dynamic>> requestDoc,
    String newStatus,
    ApprovedUsersService approvedUsersService,
    String agentId,
  ) async {
    final reqRef = FirebaseFirestore.instance
        .collection("Requests")
        .doc(requestDoc.id);

    try {
      final data = requestDoc.data();

      // If approved, add user to approved users group
      if (newStatus == _acceptedStatus) {
        final pilgrimId = (data["pilgrimId"] ?? data["userId"] ?? "")
            .toString()
            .trim();
        final pilgrimName =
          (data["name"] ?? data["fullName"] ?? data["pilgrimName"] ?? "Unknown User")
            .toString();
        final pilgrimEmail = (data["pilgrimEmail"] ?? "No Email").toString();

        if (pilgrimId.isNotEmpty) {
          await approvedUsersService.addUserToApprovedGroup(
            agentId: agentId,
            userId: pilgrimId,
            userName: pilgrimName,
            userEmail: pilgrimEmail,
          );
        }
      }

      // Update status after group operation succeeds.
      await reqRef.update({"status": newStatus});

      Get.snackbar(
        "Success",
        newStatus == _acceptedStatus
            ? "Request accepted. User added to your group and removed from pending list."
            : "Request has been declined.",
        backgroundColor: newStatus == _acceptedStatus
            ? Colors.green
            : Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update request: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
