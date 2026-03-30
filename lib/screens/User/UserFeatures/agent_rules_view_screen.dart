import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/rule_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/rules_service.dart';
import 'package:smart_umrah_app/Services/firebaseServices/approved_users_service.dart';

/// Screen for users to view rules from a specific agent
/// Rules are filtered based on user's approval status with that agent
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
  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

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
    setState(() {
      isApproved = approved;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.agentName,
              style: const TextStyle(
                color: textColorPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Rules & Guidelines',
              style: const TextStyle(color: textColorSecondary, fontSize: 12),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: textColorPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Approval Status Banner
            if (!isLoading)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isApproved
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isApproved
                        ? Colors.green.withOpacity(0.5)
                        : Colors.orange.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.verified : Icons.info_outline,
                      color: isApproved ? Colors.green : Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isApproved ? 'Approved Member' : 'Public Viewer',
                            style: TextStyle(
                              color: textColorPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isApproved
                                ? 'You have access to all rules including exclusive ones'
                                : 'You can see public rules only. Request approval for exclusive content.',
                            style: TextStyle(
                              color: textColorSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Rules List
            Expanded(
              child: StreamBuilder<List<RuleModel>>(
                stream: _rulesService.getVisibleRulesForCurrentUser(
                  widget.agentId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: accentColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading rules',
                            style: TextStyle(
                              color: textColorPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(
                              color: textColorSecondary,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final rules = snapshot.data ?? [];

                  if (rules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rule_outlined,
                            size: 64,
                            color: textColorSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No rules available',
                            style: TextStyle(
                              color: textColorPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isApproved
                                ? 'This agent hasn\'t created any rules yet'
                                : 'No public rules available. Request approval for exclusive content.',
                            style: TextStyle(
                              color: textColorSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: rules.length,
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      return _buildRuleCard(rule);
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

  Widget _buildRuleCard(RuleModel rule) {
    final categoryColor = RuleCategories.getColor(rule.category);
    final categoryIcon = RuleCategories.getIcon(rule.category);

    return Card(
      color: cardBackgroundColor,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: categoryColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and Visibility Badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(categoryIcon, size: 16, color: categoryColor),
                      const SizedBox(width: 6),
                      Text(
                        rule.category,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Show visibility badge only for approved users
                if (isApproved && !rule.isPublic)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, size: 14, color: accentColor),
                        const SizedBox(width: 4),
                        Text(
                          'Exclusive',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Rule Text
            Text(
              rule.ruleText,
              style: const TextStyle(
                color: textColorPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),

            // Timestamp
            Text(
              rule.updatedAt != null
                  ? 'Updated: ${_formatDate(rule.updatedAt!)}'
                  : 'Created: ${_formatDate(rule.createdAt)}',
              style: const TextStyle(color: textColorSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
