import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AgentChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  RxList<QueryDocumentSnapshot> messages = <QueryDocumentSnapshot>[].obs;
  late String chatId;
  RxMap<String, String> participantNames = <String, String>{}.obs;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  StreamSubscription<DocumentSnapshot>? _chatSubscription;

  Future<void> initChat(String existingChatId) async {
    chatId = existingChatId;

    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount_$currentUserId': 0,
      });
    } catch (_) {}

    _messagesSubscription?.cancel();
    _messagesSubscription = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
          messages.value = snapshot.docs;
          _markIncomingAsSeen();
        });

    _chatSubscription?.cancel();
    _chatSubscription = _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .listen((doc) {
          if (doc.exists) {
            final map = doc.data() as Map<String, dynamic>;
            final parts = List<String>.from(map['participants'] ?? []);
            _fetchParticipantNames(parts);
          }
        });
  }

  Future<void> _markIncomingAsSeen() async {
    final sentToMe = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'sent')
        .get();

    for (final doc in sentToMe.docs) {
      await doc.reference.update({'status': 'seen'});
    }
  }

  Future<void> _fetchParticipantNames(List<String> ids) async {
    final missing = ids
        .where((id) => !participantNames.containsKey(id))
        .toList();
    if (missing.isEmpty) return;
    for (final id in missing) {
      try {
        final userDoc = await _firestore.collection('Users').doc(id).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          participantNames[id] = data?['name'] ?? 'User';
          continue;
        }
        final agentDoc = await _firestore
            .collection('TravelAgents')
            .doc(id)
            .get();
        if (agentDoc.exists) {
          final data = agentDoc.data();
          participantNames[id] = data?['name'] ?? 'Agent';
          continue;
        }
        participantNames[id] = 'Unknown';
      } catch (_) {
        participantNames[id] = 'Unknown';
      }
    }
  }

  Future<void> sendMessage(String partnerId, String text) async {
    if (text.trim().isEmpty) return;
    final trimmedText = text.trim();

    final chatRef = _firestore.collection('chats').doc(chatId);

    final messageData = {
      'message': trimmedText,
      'text': trimmedText,
      'senderId': currentUserId,
      'receiverId': partnerId,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent',
      'deletedFor': [],
    };

    await chatRef.collection('messages').add(messageData);

    // Update last message info
    await chatRef.update({
      'lastMessage': trimmedText,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'lastMessageStatus': 'sent',
      'lastSenderId': currentUserId,
    });

    // **Increment unread count for all participants except sender**
    final chatSnapshot = await chatRef.get();
    final participants = List<String>.from(chatSnapshot['participants']);
    for (var participantId in participants) {
      if (participantId == currentUserId) continue;

      final unreadKey = 'unreadCount_$participantId';
      chatRef.update({unreadKey: FieldValue.increment(1)});
    }
  }

  Future<void> deleteForMe(String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'deletedFor': FieldValue.arrayUnion([currentUserId]),
        });
  }

  Future<void> deleteForEveryone(String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    return DateFormat("dd/MM/yyyy").format(date);
  }

  String formatTime(DateTime dateTime) {
    return DateFormat("hh:mm a").format(dateTime);
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    _chatSubscription?.cancel();
    super.onClose();
  }
}
