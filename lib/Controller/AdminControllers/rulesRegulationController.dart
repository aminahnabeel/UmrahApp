import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RulesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var umrahRules = <Map<String, dynamic>>[].obs;
  var travelRules = <String>[].obs;

  final umrahTitleController = TextEditingController();
  final umrahDescController = TextEditingController();
  final travelController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeRules();
  }

  Future<void> _initializeRules() async {
    final doc = _firestore.collection('admin').doc('rules');
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({'umrahRules': umrahRules, 'travelRules': travelRules});
      umrahRules.value = List<Map<String, dynamic>>.from(umrahRules);
      travelRules.value = List<String>.from(travelRules);
    } else {
      final data = snapshot.data()!;
      umrahRules.value = List<Map<String, dynamic>>.from(data['umrahRules']);
      travelRules.value = List<String>.from(data['travelRules']);
    }
  }

  Future<void> _updateFirebase() async {
    await _firestore.collection('admin').doc('rules').set({
      'umrahRules': umrahRules,
      'travelRules': travelRules,
    });
  }

  void addUmrahRule() {
    if (umrahTitleController.text.isEmpty || umrahDescController.text.isEmpty)
      return;
    umrahRules.add({
      'title': umrahTitleController.text,
      'desc': umrahDescController.text,
      'icon': 'checkroom',
    });
    umrahTitleController.clear();
    umrahDescController.clear();
    _updateFirebase();
  }

  void editUmrahRule(int index, String title, String desc) {
    umrahRules[index]['title'] = title;
    umrahRules[index]['desc'] = desc;
    _updateFirebase();
  }

  void deleteUmrahRule(int index) {
    umrahRules.removeAt(index);
    _updateFirebase();
  }

  void addTravelRule() {
    if (travelController.text.isEmpty) return;
    travelRules.add(travelController.text);
    travelController.clear();
    _updateFirebase();
  }

  void editTravelRule(int index, String value) {
    travelRules[index] = value;
    _updateFirebase();
  }

  void deleteTravelRule(int index) {
    travelRules.removeAt(index);
    _updateFirebase();
  }
}
