import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/AgentControllers/agent_rules_controller.dart';
import 'package:smart_umrah_app/Models/rule_model.dart';
import 'package:smart_umrah_app/widgets/customButton.dart';
import 'package:smart_umrah_app/widgets/customtextfield.dart';
import 'package:smart_umrah_app/Services/firebaseServices/agent_debug_helper.dart';

class AgentRulesManagementScreen extends StatelessWidget {
  AgentRulesManagementScreen({super.key}) {
    // Debug: Check agent status on screen load
    AgentDebugHelper.checkAgentStatus();
  }

  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  final AgentRulesController controller = Get.put(AgentRulesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
        title: const Text(
          'Manage Rules',
          style: TextStyle(
            color: textColorPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: textColorPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Form Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: cardBackgroundColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.isEditMode.value
                                ? 'Edit Rule'
                                : 'Add New Rule',
                            style: const TextStyle(
                              color: textColorPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Category Dropdown
                        Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedCategory.value,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Category',
                                prefixIcon: Icon(
                                  Icons.category,
                                  color: Colors.black,
                                ),
                              ),
                              items: RuleCategories.all.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Icon(
                                        RuleCategories.getIcon(category),
                                        color: RuleCategories.getColor(
                                          category,
                                        ),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(category),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                controller.selectedCategory.value = value;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rule Text Field
                        customTextField(
                          'Enter rule text',
                          labelText: 'Rule Text',
                          controller: controller.ruleTextController,
                          validator: controller.validateRuleText,
                          prefixIcon: const Icon(Icons.rule),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),

                        // Visibility Toggle
                        Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: controller.isPublic.value
                                    ? Colors.green.withOpacity(0.5)
                                    : accentColor.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  controller.isPublic.value
                                      ? Icons.public
                                      : Icons.lock,
                                  color: controller.isPublic.value
                                      ? Colors.green
                                      : accentColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.isPublic.value
                                            ? 'Public Rule'
                                            : 'Approved Users Only',
                                        style: const TextStyle(
                                          color: textColorPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        controller.isPublic.value
                                            ? 'Visible to everyone'
                                            : 'Only visible to approved users',
                                        style: const TextStyle(
                                          color: textColorSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: controller.isPublic.value,
                                  onChanged: (value) {
                                    controller.isPublic.value = value;
                                  },
                                  activeColor: Colors.green,
                                  inactiveThumbColor: accentColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons
                        Obx(() {
                          if (controller.isEditMode.value) {
                            return Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'Update',
                                    onPressed: controller.updateRule,
                                    backgroundColor: Colors.blue,
                                    isLoading: controller.isLoading.value,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomButton(
                                    text: 'Cancel',
                                    onPressed: controller.cancelEdit,
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return CustomButton(
                              text: 'Add Rule',
                              onPressed: controller.addRule,
                              backgroundColor: accentColor,
                              isLoading: controller.isLoading.value,
                            );
                          }
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Rules List Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Text(
                    'My Rules',
                    style: TextStyle(
                      color: textColorPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Rules Stream List
            Expanded(
              child: StreamBuilder<List<RuleModel>>(
                stream: controller.myRulesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: accentColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final rules = snapshot.data ?? [];

                  if (rules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.rule_outlined,
                            size: 64,
                            color: textColorSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No rules yet',
                            style: TextStyle(
                              color: textColorSecondary,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first rule above',
                            style: TextStyle(
                              color: textColorSecondary,
                              fontSize: 14,
                            ),
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
            // Category Badge
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
                // Visibility Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: rule.isPublic
                        ? Colors.green.withOpacity(0.2)
                        : accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        rule.isPublic ? Icons.public : Icons.lock,
                        size: 14,
                        color: rule.isPublic ? Colors.green : accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rule.isPublic ? 'Public' : 'Approved Only',
                        style: TextStyle(
                          color: rule.isPublic ? Colors.green : accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: accentColor,
                      onPressed: () => controller.startEdit(rule),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      onPressed: () => controller.deleteRule(rule.id!),
                    ),
                  ],
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
