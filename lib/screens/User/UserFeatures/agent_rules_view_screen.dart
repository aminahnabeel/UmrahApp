import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // <--- DateFormat ka error solve karne ke liye
import 'package:smart_umrah_app/Models/rule_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/rules_service.dart';
import 'package:smart_umrah_app/Services/firebaseServices/approved_users_service.dart';

class AgentRulesViewScreen extends StatefulWidget {
  final String agentId;
  final String agentName;

  const AgentRulesViewScreen({
    super.key,
    required this.agentId,
    required this.agentName,
  });

  @override
  State<AgentRulesViewScreen> createState() => _AgentRulesViewScreenState();
}

class _AgentRulesViewScreenState extends State<AgentRulesViewScreen> {
  // --- Smart Umrah Theme Colors ---
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color lightBg = Color(0xFFF5F7FB);

  final RulesService _rulesService = RulesService();
  final ApprovedUsersService _approvedUsersService = ApprovedUsersService();

  bool isApproved = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkApprovalStatus();
  }

  Future<void> _checkApprovalStatus() async {
    final approved = await _approvedUsersService.isCurrentUserApproved(
      widget.agentId,
    );
    if (mounted) {
      setState(() {
        isApproved = approved;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            // Navigation Fix: Pehle check karega ke peeche screen hai ya nahi
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              // Agar direct link se aaye hain to dashboard par bhej dega
              Get.offAllNamed('/user-dashboard'); 
            }
          },
        ),
        title: Column(
          children: [
            Text(
              widget.agentName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            const Text(
              'Rules & Guidelines',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, accentBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!isLoading) _buildStatusBanner(),
            Expanded(
              child: StreamBuilder<List<RuleModel>>(
                stream: _rulesService.getVisibleRulesForCurrentUser(
                  widget.agentId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    );
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }
                  final rules = snapshot.data ?? [];
                  if (rules.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: rules.length,
                    itemBuilder: (context, index) {
                      return _buildRuleCard(rules[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final bannerColor = isApproved ? Colors.green : Colors.orange;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerColor.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: bannerColor.withOpacity(0.1),
            child: Icon(
              isApproved ? Icons.verified_user_rounded : Icons.info_outline_rounded,
              color: bannerColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isApproved ? 'Approved Member' : 'Public Viewer',
                  style: TextStyle(
                    color: bannerColor.withAlpha(200),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isApproved
                      ? 'Accessing all exclusive agent rules.'
                      : 'Showing public rules only. Contact agent for full access.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(RuleModel rule) {
    // Note: RuleCategories helper class assume ki gayi hai aapke project structure ke mutabiq
    // Agar error aaye to rule.category ko directly use kar lein.
    final categoryColor = primaryBlue; 
    final categoryIcon = Icons.rule;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 5, color: categoryColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(categoryIcon, size: 16, color: categoryColor),
                              const SizedBox(width: 6),
                              Text(
                                rule.category.toUpperCase(),
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          if (isApproved && !rule.isPublic)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.lock_open_rounded, size: 10, color: primaryBlue),
                                  SizedBox(width: 4),
                                  Text("EXCLUSIVE", style: TextStyle(color: primaryBlue, fontSize: 9, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        rule.ruleText,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            rule.updatedAt != null
                                ? 'Updated ${_formatDate(rule.updatedAt!)}'
                                : 'Created ${_formatDate(rule.createdAt)}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rule_folder_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No Rules Found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            isApproved ? "Agent hasn't posted any rules yet." : "No public guidelines available.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 50, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text("Oops! Something went wrong", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return DateFormat("MMM dd, yyyy").format(date);
  }
}