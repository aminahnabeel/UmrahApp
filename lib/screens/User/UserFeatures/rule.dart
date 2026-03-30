import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/ColorTheme/color_theme.dart';
import 'package:smart_umrah_app/Models/rule_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/rules_service.dart';

class UmrahRulesScreen extends StatelessWidget {
  UmrahRulesScreen({super.key});

  // Use the new rules service
  final RulesService _rulesService = RulesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Umrah Rules & Regulations",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: ColorTheme.background,
        elevation: 4,
      ),
      body: StreamBuilder<Map<String, List<RuleModel>>>(
        stream: _rulesService.getRulesGroupedByCategory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading rules',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          final groupedRules = snapshot.data ?? {};

          if (groupedRules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.rule_outlined, size: 64, color: Colors.white70),
                  SizedBox(height: 16),
                  Text(
                    'No rules available',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rules will appear here once added by travel agents',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Container(
            color: ColorTheme.background,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Display rules by category
                ...RuleCategories.all.map((category) {
                  final categoryRules = groupedRules[category] ?? [];
                  
                  if (categoryRules.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Header
                      Row(
                        children: [
                          Icon(
                            RuleCategories.getIcon(category),
                            color: RuleCategories.getColor(category),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: RuleCategories.getColor(category),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category Rules
                      ...categoryRules.map((rule) {
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: RuleCategories.getColor(category).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor:
                                  RuleCategories.getColor(category).withOpacity(0.2),
                              child: Icon(
                                RuleCategories.getIcon(category),
                                color: RuleCategories.getColor(category),
                                size: 28,
                              ),
                            ),
                            title: Text(
                              rule.ruleText,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                    ],
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
