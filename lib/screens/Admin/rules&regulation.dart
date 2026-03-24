import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_umrah_app/Controller/AdminControllers/rulesRegulationController.dart';
import 'package:smart_umrah_app/DataLayer/User/Rulesandregulation/rules_regulation.dart';

class UpdateRulesScreen extends StatelessWidget {
  UpdateRulesScreen({super.key});

  final controller = Get.put(RulesController());

  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        title: const Text('Update Rules & Regulations'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => ListView(
            children: [
              const Text(
                'Umrah Rules',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...controller.umrahRules.asMap().entries.map((entry) {
                int idx = entry.key;
                Map<String, dynamic> rule = entry.value;
                return Card(
                  color: cardBackgroundColor,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.checkroom, color: accentColor),
                    title: Text(
                      rule['title'],
                      style: const TextStyle(color: textColorPrimary),
                    ),
                    subtitle: Text(
                      rule['desc'],
                      style: const TextStyle(color: textColorSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            controller.umrahTitleController.text =
                                rule['title'];
                            controller.umrahDescController.text = rule['desc'];
                            Get.defaultDialog(
                              title: 'Edit Umrah Rule',
                              titleStyle: const TextStyle(color: Colors.white),
                              backgroundColor: cardBackgroundColor,
                              content: Column(
                                children: [
                                  TextField(
                                    controller: controller.umrahTitleController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Title',
                                      hintStyle: TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: controller.umrahDescController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: 'Description',
                                      hintStyle: TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              textCancel: 'Cancel',
                              textConfirm: 'Update',
                              onConfirm: () {
                                controller.editUmrahRule(
                                  idx,
                                  controller.umrahTitleController.text,
                                  controller.umrahDescController.text,
                                );
                                Get.back();
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteUmrahRule(idx),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.umrahTitleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'New Umrah Rule Title',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: cardBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller.umrahDescController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Description',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: cardBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: accentColor),
                    onPressed: controller.addUmrahRule,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Travel Rules',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...controller.travelRules.asMap().entries.map((entry) {
                int idx = entry.key;
                String rule = entry.value;
                return Card(
                  color: cardBackgroundColor,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.rule, color: accentColor),
                    title: Text(
                      rule,
                      style: const TextStyle(color: textColorPrimary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            controller.travelController.text = rule;
                            Get.defaultDialog(
                              title: 'Edit Travel Rule',
                              titleStyle: const TextStyle(color: Colors.white),
                              backgroundColor: cardBackgroundColor,
                              content: TextField(
                                controller: controller.travelController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Travel Rule',
                                  hintStyle: TextStyle(color: Colors.white54),
                                ),
                              ),
                              textCancel: 'Cancel',
                              textConfirm: 'Update',
                              onConfirm: () {
                                controller.editTravelRule(
                                  idx,
                                  controller.travelController.text,
                                );
                                Get.back();
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteTravelRule(idx),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.travelController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'New Travel Rule',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: cardBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: accentColor),
                    onPressed: controller.addTravelRule,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
