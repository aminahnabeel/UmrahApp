import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Debug helper to check if current user is a valid Travel Agent
class AgentDebugHelper {
  static Future<void> checkAgentStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      print('❌ No user logged in');
      return;
    }
    
    print('✅ User logged in: ${currentUser.uid}');
    print('   Email: ${currentUser.email}');
    
    // Check if user exists in TravelAgents collection
    try {
      final agentDoc = await FirebaseFirestore.instance
          .collection('TravelAgents')
          .doc(currentUser.uid)
          .get();
      
      if (agentDoc.exists) {
        print('✅ Agent document exists in TravelAgents collection');
        print('   Data: ${agentDoc.data()}');
      } else {
        print('❌ Agent document NOT found in TravelAgents collection');
        print('   This is why you\'re getting permission denied!');
        print('   Solution: Create an agent profile first');
      }
    } catch (e) {
      print('❌ Error checking agent status: $e');
    }
  }
}
