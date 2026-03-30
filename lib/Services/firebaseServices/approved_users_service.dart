import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_umrah_app/Models/approved_user_model.dart';

/// Service for managing approved users for Travel Agents
class ApprovedUsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Add a user to an agent's approved users group
  Future<void> addUserToApprovedGroup({
    required String agentId,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      final approvedUser = ApprovedUserModel(
        userId: userId,
        agentId: agentId,
        approvedAt: DateTime.now(),
        userName: userName,
        userEmail: userEmail,
      );

      await _firestore
          .collection('agents')
          .doc(agentId)
          .collection('approvedUsers')
          .doc(userId)
          .set(approvedUser.toFirebase());
    } catch (e) {
      throw Exception('Failed to add user to approved group: $e');
    }
  }

  /// Remove a user from an agent's approved users group
  Future<void> removeUserFromApprovedGroup({
    required String agentId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('agents')
          .doc(agentId)
          .collection('approvedUsers')
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove user from approved group: $e');
    }
  }

  /// Check if a user is approved for a specific agent
  Future<bool> isUserApproved({
    required String agentId,
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection('agents')
          .doc(agentId)
          .collection('approvedUsers')
          .doc(userId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Check if current user is approved for a specific agent
  Future<bool> isCurrentUserApproved(String agentId) async {
    final uid = currentUserId;
    if (uid == null) return false;
    return isUserApproved(agentId: agentId, userId: uid);
  }

  /// Get all approved users for an agent (Stream)
  Stream<List<ApprovedUserModel>> getApprovedUsersStream(String agentId) {
    return _firestore
        .collection('agents')
        .doc(agentId)
        .collection('approvedUsers')
        .orderBy('approvedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ApprovedUserModel.fromFirebase(doc.data());
          }).toList();
        });
  }

  /// Get all approved users for an agent (Future)
  Future<List<ApprovedUserModel>> getApprovedUsers(String agentId) async {
    try {
      final snapshot = await _firestore
          .collection('agents')
          .doc(agentId)
          .collection('approvedUsers')
          .orderBy('approvedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return ApprovedUserModel.fromFirebase(doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Failed to get approved users: $e');
    }
  }

  /// Get count of approved users for an agent
  Future<int> getApprovedUsersCount(String agentId) async {
    try {
      final snapshot = await _firestore
          .collection('agents')
          .doc(agentId)
          .collection('approvedUsers')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get all agents that have approved the current user
  Stream<List<String>> getMyApprovedAgentsStream() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collectionGroup('approvedUsers')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final agentIds = <String>{};

          for (final doc in snapshot.docs) {
            final parentAgentId = doc.reference.parent.parent?.id;
            final dataAgentId = doc.data()['agentId'] as String?;
            final resolvedAgentId = parentAgentId ?? dataAgentId;
            if (resolvedAgentId != null && resolvedAgentId.isNotEmpty) {
              agentIds.add(resolvedAgentId);
            }
          }

          return agentIds.toList();
        });
  }
}
