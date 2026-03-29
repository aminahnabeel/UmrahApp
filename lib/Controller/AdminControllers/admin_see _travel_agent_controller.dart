import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class TravelAgentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Map<String, dynamic>> agents = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAgents();
  }

  void fetchAgents() {
    _firestore.collection('TravelAgents').snapshots().listen((snapshot) {
      agents.value = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    });
  }

  Future<void> deleteAgent(String id) async {
    await _firestore.collection('TravelAgents').doc(id).delete();
  }

  Future<void> updateAgent(String id, Map<String, dynamic> updatedData) async {
    await _firestore.collection('TravelAgents').doc(id).update(updatedData);
  }
}
