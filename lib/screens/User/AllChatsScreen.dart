import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_umrah_app/screens/User/chatScreen.dart';

class AllChatsScreen extends StatelessWidget {
  AllChatsScreen({super.key});

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
            return const Center(child: Text("No chats yet"));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final data = chatDoc.data() as Map<String, dynamic>;

              final participants = List<String>.from(data['participants']);
              final partnerId = participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              final lastMessage = data['lastMessage'] ?? "Tap to chat";
              final lastStatus = data.containsKey('lastMessageStatus')
                  ? data['lastMessageStatus']
                  : "sent";
              final lastSenderId = data.containsKey('lastSenderId')
                  ? data['lastSenderId']
                  : "";

              final Timestamp? lastTimestamp = data['lastTimestamp'];
              String formattedTime = "dd/mm/yyyy";

              if (lastTimestamp != null) {
                DateTime dateTime = lastTimestamp.toDate();
                formattedTime = _formatTime(dateTime);
              }

              final isGroupChat = participants.length > 2;

              // Unread message count
              final unreadCountKey = 'unreadCount_$currentUserId';
              final unreadCount = data.containsKey(unreadCountKey)
                  ? (data[unreadCountKey] as int?) ?? 0
                  : 0;

              return FutureBuilder<DocumentSnapshot?>(
                future: isGroupChat
                    ? Future.value(null)
                    : _firestore
                          .collection('TravelAgents')
                          .doc(partnerId)
                          .get(),
                builder: (context, userSnapshot) {
                  if (!isGroupChat && !userSnapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text("Loading..."),
                      subtitle: Text(""),
                    );
                  }

                  final userData = isGroupChat
                      ? null
                      : userSnapshot.data!.data() as Map<String, dynamic>?;
                  final partnerName = isGroupChat
                      ? (data['groupName'] ?? "Group Chat")
                      : (userData?['name'] ?? "Unknown");
                  final profileImageUrl = isGroupChat
                      ? null
                      : userData?['profileImageUrl'];

                  return ListTile(
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Avatar
                        isGroupChat
                            ? CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: const Icon(
                                  Icons.group,
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                backgroundImage:
                                    profileImageUrl != null &&
                                        profileImageUrl.isNotEmpty
                                    ? NetworkImage(profileImageUrl)
                                    : null,
                                child:
                                    profileImageUrl == null ||
                                        profileImageUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),

                        // 🔴 UNREAD BADGE
                        if (unreadCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                unreadCount > 99
                                    ? "99+"
                                    : unreadCount.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    title: Text(partnerName),
                    subtitle: Row(
                      children: [
                        if (lastSenderId == currentUserId)
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
                      final chatId = isGroupChat
                          ? chatDoc.id
                          : getChatId(currentUserId, partnerId);

                      final chatRef = _firestore
                          .collection('chats')
                          .doc(chatId);

                      final chatSnapshot = await chatRef.get();
                      if (!chatSnapshot.exists) {
                        await chatRef.set({
                          'participants': [currentUserId, partnerId],
                          'lastMessage': '',
                          'lastTimestamp': FieldValue.serverTimestamp(),
                          'lastMessageStatus': 'sent',
                          'lastSenderId': currentUserId,
                        });
                      }

                      // Reset unread count
                      try {
                        await chatRef.update({unreadCountKey: 0});
                      } catch (_) {}

                      Get.to(
                        () => ChatScreen(
                          partnerId: isGroupChat ? chatDoc.id : partnerId,
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
    );
  }

  /// WhatsApp-like message ticks
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

  /// Delete chat dialog
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

  String getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
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
