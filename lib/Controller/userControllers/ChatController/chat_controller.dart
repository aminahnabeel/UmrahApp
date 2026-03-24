import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  RxList<QueryDocumentSnapshot> messages = <QueryDocumentSnapshot>[].obs;
  late String chatId;
  bool isGroupChat = false;
  RxMap<String, String> participantNames = <String, String>{}.obs;

  void initChat(String partnerId) async {
    // If partnerId is an existing chat doc id, treat as group chat
    final docSnap = await _firestore.collection('chats').doc(partnerId).get();
    if (docSnap.exists) {
      isGroupChat = true;
      chatId = partnerId;
      // Reset unread count for current user when opening a group chat
      try {
        _firestore.collection('chats').doc(chatId).update({
          'unreadCount_$currentUserId': 0,
        });
      } catch (_) {}
    } else {
      isGroupChat = false;
      chatId = _getChatId(currentUserId, partnerId);
      await _createChatIfNotExists(partnerId);
    }

    // Stream messages
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
          messages.value = snapshot.docs;
        });

    // Listen to chat doc changes to keep participant list updated
    _firestore.collection('chats').doc(chatId).snapshots().listen((doc) {
      if (doc.exists) {
        final map = doc.data() as Map<String, dynamic>;
        final parts = List<String>.from(map['participants'] ?? []);
        _fetchParticipantNames(parts);
      }
    });
    // Mark 'sent' messages as seen only for 1:1 chats
    if (!isGroupChat) {
      _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'sent')
          .get()
          .then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.update({'status': 'seen'});
            }
          });
    }
  }

  String _getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  Future<void> _createChatIfNotExists(String partnerId) async {
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUserId, partnerId],
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
    }
    final createdDoc = await _firestore.collection('chats').doc(chatId).get();
    if (createdDoc.exists) {
      final parts = List<String>.from(createdDoc.data()?['participants'] ?? []);
      await _fetchParticipantNames(parts);
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

  Future<void> sendMessage(String partnerId, String messageText) async {
    if (messageText.trim().isEmpty) return;

    final messageData = {
      'senderId': currentUserId,
      'receiverId': isGroupChat ? '' : partnerId,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent',
      'deletedFor': [],
    };

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    await messageRef.add(messageData);

    if (isGroupChat) {
      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': messageText,
        'lastTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // Increment unread counter for every participant except the sender
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (chatDoc.exists) {
        final participants = List<String>.from(
          chatDoc.data()?['participants'] ?? [],
        );
        for (final p in participants) {
          if (p == currentUserId) continue;
          try {
            await _firestore.collection('chats').doc(chatId).update({
              'unreadCount_$p': FieldValue.increment(1),
            });
          } catch (_) {
            // ignore update errors
          }
        }
      }
    } else {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [currentUserId, partnerId],
        'lastMessage': messageText,
        'lastTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      // Increment unread for the other user in a 1:1 chat
      try {
        await _firestore.collection('chats').doc(chatId).update({
          'unreadCount_$partnerId': FieldValue.increment(1),
        });
      } catch (_) {}
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
}
