import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:smart_umrah_app/screens/User/chatScreen.dart';

class AllChatsScreen extends StatelessWidget {
  AllChatsScreen({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // --- Theme Colors ---
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color lightBg = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: const Text(
          "Smart Umrah Chats",
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 20, 
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.offAllNamed(AppRoutes.userdashboard),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, accentBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // Filter to ensure valid chat documents
          final chats = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final participants = List<String>.from(data['participants'] ?? []);
            return participants.length >= 2;
          }).toList();

          if (chats.isEmpty) return _buildEmptyState();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final data = chatDoc.data() as Map<String, dynamic>;
              return _buildChatCard(context, data, chatDoc.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatCard(BuildContext context, Map<String, dynamic> data, String chatId) {
    final participants = List<String>.from(data['participants']);
    final partnerId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');
    final lastMessage = data['lastMessage'] ?? "Tap to start conversation";
    final lastStatus = data['lastMessageStatus'] ?? "sent";
    final lastSenderId = data['lastSenderId'] ?? "";
    final Timestamp? lastTimestamp = data['lastTimestamp'];
    final unreadCount = data['unreadCount_$currentUserId'] ?? 0;
    final isGroupChat = participants.length > 2;

    return FutureBuilder<DocumentSnapshot?>(
      future: isGroupChat 
          ? Future.value(null) 
          : _firestore.collection('TravelAgents').doc(partnerId).get(),
      builder: (context, userSnapshot) {
        final userData = isGroupChat ? null : userSnapshot.data?.data() as Map<String, dynamic>?;
        final partnerName = isGroupChat ? (data['groupName'] ?? "Group Chat") : (userData?['name'] ?? "Travel Agent");
        final profileUrl = isGroupChat ? null : userData?['profileImageUrl'];

        return InkWell(
          onTap: () {
            // Reset unread count when opening
            _firestore.collection('chats').doc(chatId).update({'unreadCount_$currentUserId': 0});
            Get.to(() => ChatScreen(
              chatId: chatId,
              partnerId: partnerId,
              partnerName: partnerName,
              partnerImageUrl: profileUrl,
            ));
          },
          onLongPress: () => _showDeleteDialog(context, chatId),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryBlue.withOpacity(0.1),
                      backgroundImage: (profileUrl != null && profileUrl.isNotEmpty) 
                          ? NetworkImage(profileUrl) 
                          : null,
                      child: (profileUrl == null || profileUrl.isEmpty)
                          ? Icon(isGroupChat ? Icons.groups_rounded : Icons.person_rounded, color: primaryBlue, size: 30)
                          : null,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                          child: Text(
                            unreadCount > 99 ? "99+" : unreadCount.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            partnerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16, 
                              color: primaryBlue
                            ),
                          ),
                          Text(
                            lastTimestamp != null ? _formatTime(lastTimestamp.toDate()) : "",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (lastSenderId == currentUserId) ...[
                            _buildStatusIcon(lastStatus),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
                                fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text(
            "No Chats Yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start a conversation with a travel agent.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.viewtravelagent),
            icon: const Icon(Icons.add),
            label: const Text("Browse Agents"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon = Icons.check;
    Color color = Colors.grey;
    if (status == "delivered") icon = Icons.done_all;
    if (status == "seen") {
      icon = Icons.done_all;
      color = Colors.blue;
    }
    return Icon(icon, size: 14, color: color);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (now.day == dateTime.day && now.month == dateTime.month && now.year == dateTime.year) {
      return DateFormat.jm().format(dateTime);
    } else if (now.difference(dateTime).inDays == 1) {
      return "Yesterday";
    }
    return DateFormat("dd/MM/yy").format(dateTime);
  }

  void _showDeleteDialog(BuildContext context, String chatId) {
    Get.defaultDialog(
      title: "Delete Chat",
      middleText: "Are you sure you want to delete this chat?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        await _firestore.collection('chats').doc(chatId).delete();
        Get.back();
        Get.snackbar(
          "Deleted", 
          "Chat has been removed", 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white
        );
      },
    );
  }
}