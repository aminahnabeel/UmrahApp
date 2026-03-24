//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/ColorTheme/color_theme.dart';

class UmrahRulesScreen extends StatelessWidget {
  const UmrahRulesScreen({super.key});

  Future<DocumentSnapshot> getRules() async {
    return FirebaseFirestore.instance.collection("admin").doc("rules").get();
  }

  IconData getIconByName(String name) {
    switch (name) {
      case "mosque":
        return Icons.mosque;
      case "book":
        return Icons.menu_book;
      case "flight":
        return Icons.flight;
      case "check":
        return Icons.check_circle;
      default:
        return Icons.info; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Umrah Rules & Regulations",
          style: TextStyle(fontWeight: FontWeight.bold, color:  Colors.white),
        ),
        centerTitle: true,
        backgroundColor: ColorTheme.background,
        elevation: 4,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getRules(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color:Color(0xFF3B82F6)),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          List<dynamic> umrahRules = data["umrahRules"] ?? [];
          List<dynamic> travelRules = data["travelRules"] ?? [];

          return Container(
            color: ColorTheme.background,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Religious Rules",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                ...umrahRules.map((rule) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.teal.shade100,
                        child: Icon(
                          getIconByName(rule["icon"] ?? ""),
                          color: Colors.teal,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        rule["title"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          rule["desc"] ?? "",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                /// ------------------------------
                /// T R A V E L   R U L E S
                /// ------------------------------
                const Text(
                  "Travel & Documentation Rules",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 10),

                ...travelRules.map((item) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.flight_takeoff,
                        color: Colors.teal,
                        size: 28,
                      ),
                      title: Text(
                        item.toString(),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),

      /// BACK BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.back(),
        label: const Text("Back"),
        icon: const Icon(Icons.arrow_back),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
