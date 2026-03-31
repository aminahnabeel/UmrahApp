import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Services/firebaseServices/approved_users_service.dart';
import 'package:smart_umrah_app/Models/TravelAgentProfileData/travelAgent_profile_model.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/agent_rules_view_screen.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart';

class UserViewGroupsScreen extends StatelessWidget {
  const UserViewGroupsScreen({super.key});

  // Aapke Theme Colors
  static const Color customBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color scaffoldBg = Color(0xFFF8FAFF);

  @override
  Widget build(BuildContext context) {
    final ApprovedUsersService approvedUsersService = ApprovedUsersService();

    return Scaffold(
      backgroundColor: scaffoldBg,
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: "My Approved Groups",
        showBackButton: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [customBlue, accentBlue, scaffoldBg],
            stops: [0.0, 0.25, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Info Banner (Premium Style) ---
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Colors.green, size: 28),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Memberships',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Agents who have granted you exclusive access.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- List Section ---
              Expanded(
                child: StreamBuilder<List<String>>(
                  stream: approvedUsersService.getMyApprovedAgentsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    }

                    final agentIds = snapshot.data ?? [];

                    if (agentIds.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: agentIds.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _buildAgentCard(agentIds[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Premium Agent Card ---
  Widget _buildAgentCard(String agentId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('TravelAgents').doc(agentId).snapshots(),
      builder: (context, agentSnapshot) {
        if (!agentSnapshot.hasData) {
          return Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final agentData = agentSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final agent = TravelAgentProfileModel.fromFirebase(agentData);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: customBlue.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Get.to(() => AgentRulesViewScreen(
                  agentId: agentId,
                  agentName: agent.name ?? 'Travel Agent',
                )),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade100, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: agent.profileImageUrl != null ? NetworkImage(agent.profileImageUrl!) : null,
                      child: agent.profileImageUrl == null ? const Icon(Icons.person, color: customBlue) : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent.name ?? 'Travel Agent',
                          style: const TextStyle(
                            color: Color(0xFF1A237E),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          agent.agencyName ?? 'Travel Agency',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'Approved',
                                style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: customBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.chevron_right_rounded, color: customBlue),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Empty State ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No Approved Groups',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          const Text('Connect with agents to see them here.', style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }

  // --- Error State ---
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text('Error: $error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}