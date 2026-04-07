import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_umrah_app/Models/rule_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/approved_users_service.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart'; // Assuming path for your CustomAppBar

class UmrahRulesScreen extends StatelessWidget {
  UmrahRulesScreen({super.key});

  // Modern Theme Colors
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color scaffoldBg = Color(0xFFF8FAFF);
  static const Color textDark = Color(0xFF1E2A38);
  static const Color textLight = Color(0xFF64748B);

  final ApprovedUsersService _approvedUsersService = ApprovedUsersService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      // Using your CustomAppBar
      appBar: CustomAppBar(
        title: "Umrah Rules",
        showBackButton: true,
      ),
      body: StreamBuilder<List<String>>(
        stream: _approvedUsersService.getMyApprovedAgentsStream(),
        builder: (context, approvedSnap) {
          if (approvedSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          if (approvedSnap.hasError) {
            return _buildErrorState();
          }

          final approvedAgentIds = approvedSnap.data ?? [];
          if (approvedAgentIds.isEmpty) {
            return _buildEmptyState(
              message: "You are not approved by any travel agent yet.",
            );
          }

          final queryAgentIds = approvedAgentIds.length > 10
              ? approvedAgentIds.take(10).toList()
              : approvedAgentIds;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('rules')
                .where('createdBy', whereIn: queryAgentIds)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, rulesSnap) {
              if (rulesSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryBlue),
                );
              }

              if (rulesSnap.hasError) {
                return _buildErrorState();
              }

              final rules = rulesSnap.data?.docs
                      .map((doc) => RuleModel.fromFirebase(doc.data(), doc.id))
                      .toList() ??
                  [];

              final Map<String, List<RuleModel>> groupedRules = {
                for (final category in RuleCategories.all) category: <RuleModel>[],
              };

              for (final rule in rules) {
                groupedRules.putIfAbsent(rule.category, () => <RuleModel>[]);
                groupedRules[rule.category]!.add(rule);
              }

              final hasAnyRules = groupedRules.values.any((list) => list.isNotEmpty);
              if (!hasAnyRules) {
                return _buildEmptyState(
                  message: "No rules found for your approved agents.",
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                physics: const BouncingScrollPhysics(),
                children: [
                  const Text(
                    "Official Guidelines",
                    style: TextStyle(
                      color: textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Visible only for approved members",
                    style: TextStyle(color: textLight, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  ...RuleCategories.all.map((category) {
                    final categoryRules = groupedRules[category] ?? [];
                    if (categoryRules.isEmpty) return const SizedBox.shrink();

                    return _buildCategorySection(category, categoryRules);
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(String category, List<RuleModel> rules) {
    final color = RuleCategories.getColor(category);
    final icon = RuleCategories.getIcon(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              category,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textDark.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...rules.map((rule) => _buildModernRuleTile(rule, color)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildModernRuleTile(RuleModel rule, Color categoryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEF5)),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: categoryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              rule.ruleText,
              style: const TextStyle(
                color: textDark,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 70, color: primaryBlue.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text("No Rules Yet", style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            message ?? "Guidelines will appear here once you are approved.",
            style: const TextStyle(color: textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text("Error loading rules. Please try again.", style: TextStyle(color: Colors.red)),
    );
  }
}