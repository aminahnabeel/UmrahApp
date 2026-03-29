import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAllSchedules extends StatelessWidget {
  const ViewAllSchedules({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Umrah Schedules"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Schedules")
            .where("agentId", isEqualTo: userId)
            // Make sure to order by 'createdAt' safely
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Safely get docs
          final docs = snapshot.data?.docs ?? [];

          // Error handling
          if (snapshot.hasError) {
            debugPrint('Firestore error: ${snapshot.error}');
            if (docs.isEmpty) {
              return Center(
                child: Text(
                  "Something went wrong!\n${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }
          }

          // Show loader only if waiting AND no cached data
          if (snapshot.connectionState == ConnectionState.waiting &&
              docs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // No schedules found
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No schedules found",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          // Display list of schedules
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // Handle missing fields
              final departureCity = data['departureCity'] ?? "Unknown city";
              final hotel = data['hotel'] ?? "Unknown hotel";
              final departureDate = data['departureDate'] ?? "Unknown";
              final returnDate = data['returnDate'] ?? "Unknown";
              final pilgrimsCount = data['pilgrimsCount']?.toString() ?? "N/A";

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_month,
                    color: Colors.deepPurple,
                    size: 30,
                  ),
                  title: Text(
                    "$departureCity → Hotel: $hotel",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      "From: $departureDate\n"
                      "To: $returnDate\n"
                      "Pilgrims: $pilgrimsCount",
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
