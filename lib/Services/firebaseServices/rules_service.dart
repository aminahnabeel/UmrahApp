import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_umrah_app/Models/rule_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/approved_users_service.dart';

class RulesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApprovedUsersService _approvedUsersService = ApprovedUsersService();

  /// Collection reference for rules
  CollectionReference get _rulesCollection => _firestore.collection('rules');

  /// Get current user ID (agent ID)
  String? get currentUserId => _auth.currentUser?.uid;

  /// Add a new rule
  Future<String> addRule(RuleModel rule) async {
    try {
      final docRef = await _rulesCollection.add(rule.toFirebase());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add rule: $e');
    }
  }

  /// Update an existing rule
  Future<void> updateRule(String ruleId, RuleModel rule) async {
    try {
      await _rulesCollection
          .doc(ruleId)
          .update(rule.copyWith(updatedAt: DateTime.now()).toFirebase());
    } catch (e) {
      throw Exception('Failed to update rule: $e');
    }
  }

  /// Delete a rule
  Future<void> deleteRule(String ruleId) async {
    try {
      await _rulesCollection.doc(ruleId).delete();
    } catch (e) {
      throw Exception('Failed to delete rule: $e');
    }
  }

  /// Get all rules (for users - read-only)
  Stream<List<RuleModel>> getAllRules() {
    return _rulesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RuleModel.fromFirebase(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  /// Get rules by category
  Stream<List<RuleModel>> getRulesByCategory(String category) {
    return _rulesCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RuleModel.fromFirebase(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  /// Get rules created by specific agent
  Stream<List<RuleModel>> getRulesByAgent(String agentId) {
    return _rulesCollection
        .where('createdBy', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RuleModel.fromFirebase(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  /// Get rules created by current agent
  Stream<List<RuleModel>> getMyRules() {
    final uid = currentUserId;
    if (uid == null) {
      return Stream.value([]);
    }
    return getRulesByAgent(uid);
  }

  /// Check if current user can edit/delete a rule
  bool canModifyRule(RuleModel rule) {
    return rule.createdBy == currentUserId;
  }

  /// Get rules grouped by category
  Stream<Map<String, List<RuleModel>>> getRulesGroupedByCategory() {
    return getAllRules().map((rules) {
      final Map<String, List<RuleModel>> grouped = {};

      for (var rule in rules) {
        if (!grouped.containsKey(rule.category)) {
          grouped[rule.category] = [];
        }
        grouped[rule.category]!.add(rule);
      }

      return grouped;
    });
  }

  /// Get visible rules for a user from a specific agent
  /// Returns rules only when user is approved by that agent.
  Stream<List<RuleModel>> getVisibleRulesForUser({
    required String agentId,
    required String userId,
  }) async* {
    // Check if user is approved
    final isApproved = await _approvedUsersService.isUserApproved(
      agentId: agentId,
      userId: userId,
    );

    if (isApproved) {
      // Approved users can view all rules from this agent.
      yield* getRulesByAgent(agentId);
    } else {
      // Unapproved users cannot view any rules.
      yield* Stream.value([]);
    }
  }

  /// Get visible rules for current user from a specific agent
  Stream<List<RuleModel>> getVisibleRulesForCurrentUser(String agentId) async* {
    final uid = currentUserId;
    if (uid == null) {
      yield* Stream.value([]);
      return;
    }

    yield* getVisibleRulesForUser(agentId: agentId, userId: uid);
  }
}
