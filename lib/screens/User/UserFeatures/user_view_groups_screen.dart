import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Services/firebaseServices/approved_users_service.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/agent_rules_view_screen.dart';

/// Screen for Users to view which agents have approved them
class UserViewGroupsScreen extends StatelessWidget {
  const UserViewGroupsScreen({super.key});

  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final ApprovedUsersService approvedUsersService = ApprovedUsersService();

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
        title: const Text(
          'My Agent Groups',
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
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Approved Memberships',
                          style: TextStyle(
                            color: textColorPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Agents who have approved you and given access to exclusive content',
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

            // Approved Agents List
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: approvedUsersService.getMyApprovedAgentsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: accentColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                              'Error loading groups',
                              style: TextStyle(
                                color: textColorPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              snapshot.error.toString(),
                              style: TextStyle(
                                color: textColorSecondary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Trigger a refresh
                                (context as Element).markNeedsBuild();
                              },
                              icon: Icon(Icons.refresh),
                              label: Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final agentIds = snapshot.data ?? [];

                  if (agentIds.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_add_outlined,
                            size: 80,
                            color: textColorSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Approved Groups Yet',
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
                              'Send requests to travel agents to get approved and access exclusive content',
                              style: TextStyle(
                                color: textColorSecondary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => Get.back(),
                            icon: Icon(Icons.search),
                            label: Text('Find Travel Agents'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: agentIds.length,
                    itemBuilder: (context, index) {
                      final agentId = agentIds[index];
                      return _buildAgentCard(agentId);
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

  Widget _buildAgentCard(String agentId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('TravelAgents')
          .doc(agentId)
          .snapshots(),
      builder: (context, agentSnapshot) {
        if (!agentSnapshot.hasData) {
          return Card(
            color: cardBackgroundColor,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: accentColor,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        final agentData =
            agentSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final agent = TravelAgentProfileModel.fromFirebase(agentData);

        return Card(
          color: cardBackgroundColor,
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green.withOpacity(0.2),
                  backgroundImage: agent.profileImageUrl != null
                      ? NetworkImage(agent.profileImageUrl!)
                      : null,
                  child: agent.profileImageUrl == null
                      ? Icon(Icons.person, color: Colors.green, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),

                // Agent Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name ?? 'Travel Agent',
                        style: const TextStyle(
                          color: textColorPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agent.agencyName ?? 'Travel Agency',
                        style: TextStyle(
                          color: textColorSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.verified, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Approved Member',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // View Rules Button
                IconButton(
                  icon: Icon(Icons.rule, color: accentColor, size: 28),
                  onPressed: () => Get.to(
                    () => AgentRulesViewScreen(
                      agentId: agentId,
                      agentName: agent.name ?? 'Travel Agent',
                    ),
                  ),
                  tooltip: 'View Rules',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
