import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_umrah_app/Models/rule_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/rules_service.dart';

class AgentRulesController extends GetxController {
  final RulesService _rulesService = RulesService();

  // Form controllers
  final TextEditingController ruleTextController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Selected category
  var selectedCategory = RxnString();

  // Loading state
  var isLoading = false.obs;

  // Edit mode
  var isEditMode = false.obs;
  var editingRuleId = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Set default category
    selectedCategory.value = RuleCategories.all.first;
  }

  @override
  void onClose() {
    ruleTextController.dispose();
    super.onClose();
  }

  /// Get current agent ID
  String? get currentAgentId => FirebaseAuth.instance.currentUser?.uid;

  /// Stream of agent's rules
  Stream<List<RuleModel>> get myRulesStream => _rulesService.getMyRules();

  /// Validate form
  bool validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (ruleTextController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Rule text cannot be empty',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (selectedCategory.value == null || selectedCategory.value!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a category',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  /// Add a new rule
  Future<void> addRule() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      final rule = RuleModel(
        ruleText: ruleTextController.text.trim(),
        category: selectedCategory.value!,
        createdBy: currentAgentId!,
        createdAt: DateTime.now(),
        isPublic: false,
      );

      await _rulesService.addRule(rule);

      Get.snackbar(
        'Success',
        'Rule added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      clearForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add rule: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing rule
  Future<void> updateRule() async {
    if (!validateForm() || editingRuleId.value == null) return;

    try {
      isLoading.value = true;

      final rule = RuleModel(
        ruleText: ruleTextController.text.trim(),
        category: selectedCategory.value!,
        createdBy: currentAgentId!,
        createdAt: DateTime.now(), // This will be ignored in update
        updatedAt: DateTime.now(),
        isPublic: false,
      );

      await _rulesService.updateRule(editingRuleId.value!, rule);

      Get.snackbar(
        'Success',
        'Rule updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      clearForm();
      cancelEdit();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update rule: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a rule
  Future<void> deleteRule(String ruleId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Rule'),
          content: const Text('Are you sure you want to delete this rule?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _rulesService.deleteRule(ruleId);
        Get.snackbar(
          'Success',
          'Rule deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete rule: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Start editing a rule
  void startEdit(RuleModel rule) {
    isEditMode.value = true;
    editingRuleId.value = rule.id;
    ruleTextController.text = rule.ruleText;
    selectedCategory.value = rule.category;
  }

  /// Cancel edit mode
  void cancelEdit() {
    isEditMode.value = false;
    editingRuleId.value = null;
    clearForm();
  }

  /// Clear form
  void clearForm() {
    ruleTextController.clear();
    selectedCategory.value = RuleCategories.all.first;
  }

  /// Validate rule text
  String? validateRuleText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter rule text';
    }
    if (value.trim().length < 10) {
      return 'Rule text must be at least 10 characters';
    }
    return null;
  }
}
