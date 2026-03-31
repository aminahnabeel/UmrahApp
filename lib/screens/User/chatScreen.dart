import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_umrah_app/Controller/userControllers/ChatController/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String partnerId;
  final String partnerName;
  final String? partnerImageUrl;

  ChatScreen({
    super.key,
    required this.chatId,
    required this.partnerId,
    required this.partnerName,
    this.partnerImageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _messageController;
  late final ChatController chatController;

  // --- Theme Colors ---
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF1976D2);
  static const Color senderBubble = Color(0xFFE3F2FD); // Light Blue for receiver

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    chatController = Get.put(ChatController(), tag: widget.chatId);
    chatController.initChat(widget.chatId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    Get.delete<ChatController>(tag: widget.chatId, force: true);
    super.dispose();
  }

  Widget _buildTick(String status) {
    if (status == "sent") {
      return const Icon(Icons.check, size: 14, color: Colors.white70);
    } else if (status == "delivered") {
      return const Icon(Icons.done_all, size: 14, color: Colors.white70);
    } else if (status == "seen") {
      return const Icon(Icons.done_all, size: 14, color: Colors.cyanAccent);
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 2,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              backgroundImage: widget.partnerImageUrl != null && widget.partnerImageUrl!.isNotEmpty
                  ? NetworkImage(widget.partnerImageUrl!)
                  : null,
              child: widget.partnerImageUrl == null || widget.partnerImageUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.partnerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    "Online", // You can sync this with Firestore status later
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
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
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final messages = chatController.messages;

              if (messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text("No messages yet", style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                );
              }

              // Grouping logic remains same
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
                reverse: false, // Set to true if you want auto-scroll to bottom behavior
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: groupedMessages.entries.map((entry) {
                  DateTime date = DateTime.parse(entry.key);
                  String dateHeader = chatController.formatDateHeader(date);

                  return Column(
                    children: [
                      // Modern Date Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                dateHeader,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                      ),

                      ...entry.value.map((msg) {
                        final data = msg.data() as Map<String, dynamic>;
                        final isMe = data['senderId'] == chatController.currentUserId;
                        final ts = data['timestamp'] as Timestamp?;
                        String timeText = ts != null ? chatController.formatTime(ts.toDate()) : "";
                        final status = data['status'] ?? "sent";

                        return _buildMessageBubble(context, msg, data, isMe, timeText, status);
                      }).toList(),
                    ],
                  );
                }).toList(),
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, dynamic msg, Map<String, dynamic> data, bool isMe, String timeText, String status) {
    return GestureDetector(
      onLongPress: () => _showDeleteOptions(msg, isMe),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? primaryBlue : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                (data['message'] ?? data['text'] ?? '').toString(),
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
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
                      color: isMe ? Colors.white70 : Colors.black45,
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
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (_messageController.text.trim().isNotEmpty) {
                  chatController.sendMessage(
                    widget.partnerId,
                    _messageController.text.trim(),
                  );
                  _messageController.clear();
                }
              },
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: primaryBlue,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteOptions(dynamic msg, bool isMe) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                title: const Text("Delete for Everyone"),
                onTap: () {
                  chatController.deleteForEveryone(msg.id);
                  Get.back();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
              title: const Text("Delete for Me"),
              onTap: () {
                chatController.deleteForMe(msg.id);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}