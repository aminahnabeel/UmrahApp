import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_umrah_app/screens/TravelAgent/AgentChatScreens/agentchatScreen.dart';

class AgentViewAllChatsScreen extends StatelessWidget {
  AgentViewAllChatsScreen({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Umrah Chats",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastTimestamp', descending: true)
            .snapshots()
            .handleError((error) {
              print("Firestore error: $error");
            }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No chats yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Incoming chats from users will appear here",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final participants = List<String>.from(data['participants'] ?? []);
            return participants.length == 2;
          }).toList();

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No chats yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Incoming chats from users will appear here",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final data = chatDoc.data() as Map<String, dynamic>;

              final participants = List<String>.from(data['participants']);
              final partnerId = participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => "", // For group chats
              );

              final lastMessage = data['lastMessage'] ?? "Tap to chat";
              final lastStatus = data['lastMessageStatus'] ?? "sent";
              final lastSenderId = data['lastSenderId'] ?? "";

              final Timestamp? lastTimestamp = data['lastTimestamp'];
              String formattedTime = "dd/mm/yyyy";
              if (lastTimestamp != null) {
                DateTime dateTime = lastTimestamp.toDate();
                formattedTime = _formatTime(dateTime);
              }

              // Check if it's a group chat
              final isGroupChat = participants.length > 2;

              return FutureBuilder<DocumentSnapshot>(
                future: isGroupChat
                    ? null
                    : _firestore.collection('Users').doc(partnerId).get(),
                builder: (context, userSnapshot) {
                  final userData =
                      userSnapshot.data?.data() as Map<String, dynamic>?;
                  String partnerName = isGroupChat
                      ? data['groupName'] ?? "Group Chat"
                      : (userData?['name'] ?? "Unknown");
                  String? profileImageUrl = isGroupChat
                      ? null
                      : userData?['profileImageUrl'];

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.deepPurple,
                      backgroundImage:
                          profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl == null || profileImageUrl.isEmpty
                          ? Icon(
                              isGroupChat ? Icons.group : Icons.person,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    title: Text(
                      partnerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        if (!isGroupChat && lastSenderId == currentUserId)
                          _buildMessageStatusIcon(lastStatus),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      formattedTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    onTap: () async {
                      final unreadCountKey = 'unreadCount_$currentUserId';
                      try {
                        await _firestore
                            .collection('chats')
                            .doc(chatDoc.id)
                            .update({unreadCountKey: 0});
                      } catch (_) {}

                      Get.to(
                        () => AgentChatScreen(
                          chatId: chatDoc.id,
                          partnerId: partnerId,
                          partnerName: partnerName,
                          partnerImageUrl: profileImageUrl,
                        ),
                      );
                    },
                    onLongPress: () {
                      _showDeleteDialog(context, chatDoc.id);
                    },
                  );
                },
              );
            },
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Get.to(() => CreateGroupChatScreen());
      //   },
      //   backgroundColor: Colors.deepPurple,
      //   child: const Icon(Icons.group_add),
      //   tooltip: "Create Group Chat",
      // ),
    );
  }

  Widget _buildMessageStatusIcon(String status) {
    switch (status) {
      case "sent":
        return const Icon(Icons.check, size: 16, color: Colors.grey);
      case "delivered":
        return const Icon(Icons.done_all, size: 16, color: Colors.grey);
      case "seen":
        return const Icon(Icons.done_all, size: 16, color: Colors.blue);
      default:
        return const SizedBox.shrink();
    }
  }

  void _showDeleteDialog(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Chat"),
        content: const Text("Are you sure you want to delete this chat?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _firestore.collection('chats').doc(chatId).delete();
              Navigator.pop(ctx);
              Get.snackbar(
                "Chat Deleted",
                "The chat has been deleted successfully",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    if (now.day == dateTime.day &&
        now.month == dateTime.month &&
        now.year == dateTime.year) {
      return DateFormat.jm().format(dateTime);
    } else if (now.difference(dateTime).inDays == 1) {
      return "Yesterday";
    } else {
      return DateFormat("dd/MM/yyyy").format(dateTime);
    }
  }
}
