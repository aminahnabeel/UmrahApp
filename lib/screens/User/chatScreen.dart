import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_umrah_app/Controller/userControllers/ChatController/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  final String partnerId;
  final String partnerName;
  final String? partnerImageUrl;

  final TextEditingController _messageController = TextEditingController();
  final ChatController chatController = Get.put(ChatController());

  ChatScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
    this.partnerImageUrl,
  }) {
    chatController.initChat(partnerId);
  }

  Widget _buildTick(String status) {
    if (status == "sent") {
      return const Icon(Icons.check, size: 16, color: Colors.grey);
    } else if (status == "delivered") {
      return const Icon(Icons.done_all, size: 16, color: Colors.grey);
    } else if (status == "seen") {
      return const Icon(Icons.done_all, size: 16, color: Colors.blue);
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: partnerImageUrl != null
                  ? NetworkImage(partnerImageUrl!)
                  : null,
              child: partnerImageUrl == null || partnerImageUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
              backgroundColor: Colors.deepPurple,
            ),
            const SizedBox(width: 10),
            Text(
              partnerName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = chatController.messages;
              final participantNames = chatController.participantNames;

              if (messages.isEmpty) {
                return const Center(child: Text("No messages yet"));
              }

              // Group by date
              Map<String, List<QueryDocumentSnapshot>> groupedMessages = {};
              for (var msg in messages) {
                final data = msg.data() as Map<String, dynamic>;
                final ts = data['timestamp'] as Timestamp?;
                if (ts == null) continue;

                final List deletedFor = data['deletedFor'] ?? [];
                if (deletedFor.contains(chatController.currentUserId)) continue;

                DateTime date = ts.toDate();
                String dateKey = DateFormat("yyyy-MM-dd").format(date);
                groupedMessages.putIfAbsent(dateKey, () => []).add(msg);
              }

              return ListView(
                padding: const EdgeInsets.all(8),
                children: groupedMessages.entries.map((entry) {
                  DateTime date = DateTime.parse(entry.key);
                  String dateHeader = chatController.formatDateHeader(date);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Date header
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dateHeader,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Messages
                      ...entry.value.map((msg) {
                        final data = msg.data() as Map<String, dynamic>;
                        final isMe =
                            data['senderId'] == chatController.currentUserId;
                        final senderId = data['senderId'] as String? ?? '';
                        final senderName =
                            participantNames[senderId] ??
                            (isMe ? 'You' : 'Unknown');
                        final ts = data['timestamp'] as Timestamp?;
                        String timeText = ts != null
                            ? chatController.formatTime(ts.toDate())
                            : "";
                        final status = data['status'] ?? "sent";

                        return GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Delete Message"),
                                content: const Text(
                                  "Do you want to delete this message?",
                                ),
                                actions: [
                                  if (isMe)
                                    TextButton(
                                      onPressed: () {
                                        chatController.deleteForEveryone(
                                          msg.id,
                                        );
                                      },
                                      child: const Text(
                                        "Delete for Everyone",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      chatController.deleteForMe(msg.id);
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text("Delete for Me"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text("Cancel"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (chatController.isGroupChat && !isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      bottom: 4,
                                    ),
                                    child: Text(
                                      senderName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.deepPurple
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['text'],
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            timeText,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isMe
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            _buildTick(status),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    chatController.sendMessage(
                      partnerId,
                      _messageController.text,
                    );
                    _messageController.clear();
                  },
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
