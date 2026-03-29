import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  ChatService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String buildUserAgentChatId(String userId, String agentId) {
    return userId.compareTo(agentId) <= 0
        ? '${userId}_$agentId'
        : '${agentId}_$userId';
  }

  static Future<String> createOrGetUserAgentChat({
    required String userId,
    required String agentId,
  }) async {
    final chatId = buildUserAgentChatId(userId, agentId);
    final chatRef = _firestore.collection('chats').doc(chatId);

    await chatRef.set({
      'participants': [userId, agentId],
      'userId': userId,
      'agentId': agentId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastTimestamp': FieldValue.serverTimestamp(),
      'lastMessageStatus': 'sent',
      'lastSenderId': userId,
    }, SetOptions(merge: true));

    return chatId;
  }
}
