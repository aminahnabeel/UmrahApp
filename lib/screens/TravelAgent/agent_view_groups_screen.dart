import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Models/approved_user_model.dart';
import 'package:smart_umrah_app/Services/firebaseServices/approved_users_service.dart';

/// Screen for Travel Agents to view their approved members/group
class AgentViewGroupsScreen extends StatelessWidget {
  const AgentViewGroupsScreen({super.key});

  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final String agentId = FirebaseAuth.instance.currentUser!.uid;
    final ApprovedUsersService approvedUsersService = ApprovedUsersService();

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
        title: const Text(
          'My Approved Members',
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
            // Info Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.group, color: accentColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Approved Group',
                          style: TextStyle(
                            color: textColorPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Members who can see your exclusive rules',
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

            // Members List
            Expanded(
              child: StreamBuilder<List<ApprovedUserModel>>(
                stream: approvedUsersService.getApprovedUsersStream(agentId),
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
                            'Error loading members',
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

                  final members = snapshot.data ?? [];

                  if (members.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_off_outlined,
                            size: 80,
                            color: textColorSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Approved Members Yet',
                            style: TextStyle(
                              color: textColorPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'When you approve pilgrim requests, they will appear here',
                              style: TextStyle(
                                color: textColorSecondary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _buildMemberCard(
                        member,
                        approvedUsersService,
                        agentId,
                      );
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

  Widget _buildMemberCard(
    ApprovedUserModel member,
    ApprovedUsersService approvedUsersService,
    String agentId,
  ) {
    return Card(
      color: cardBackgroundColor,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: accentColor.withOpacity(0.2),
              child: Text(
                member.userName.isNotEmpty
                    ? member.userName[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Member Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.userName,
                    style: const TextStyle(
                      color: textColorPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.userEmail,
                    style: TextStyle(color: textColorSecondary, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.verified, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Approved ${_formatDate(member.approvedAt)}',
                        style: TextStyle(color: Colors.green, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove Button
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: Colors.red.withOpacity(0.8),
              ),
              onPressed: () =>
                  _showRemoveDialog(member, approvedUsersService, agentId),
              tooltip: 'Remove from group',
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(
    ApprovedUserModel member,
    ApprovedUsersService approvedUsersService,
    String agentId,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: cardBackgroundColor,
        title: Text('Remove Member', style: TextStyle(color: textColorPrimary)),
        content: Text(
          'Remove ${member.userName} from your approved group? They will no longer see your exclusive rules.',
          style: TextStyle(color: textColorSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await approvedUsersService.removeUserFromApprovedGroup(
                  agentId: agentId,
                  userId: member.userId,
                );

                // Re-enable request flow on user side by resetting previous accepted requests.
                final requestSnapshot = await FirebaseFirestore.instance
                    .collection('Requests')
                    .where('agentId', isEqualTo: agentId)
                    .get();

                final matchingDocs = requestSnapshot.docs.where(
                  (doc) => (doc.data()['pilgrimId'] ?? '').toString() == member.userId,
                );

                final batch = FirebaseFirestore.instance.batch();
                for (final doc in matchingDocs) {
                  final status = (doc.data()['status'] ?? '').toString().toLowerCase();
                  if (status == 'approved' || status == 'accepted' || status == 'pending') {
                    batch.update(doc.reference, {
                      'status': 'declined',
                      'removedFromGroupAt': FieldValue.serverTimestamp(),
                    });
                  }
                }
                await batch.commit();

                Get.snackbar(
                  'Success',
                  '${member.userName} removed from approved group',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to remove member: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
