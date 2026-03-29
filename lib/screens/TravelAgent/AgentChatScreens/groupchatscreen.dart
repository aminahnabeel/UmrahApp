import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List<String> selectedUserIds = [];
  final TextEditingController groupNameController = TextEditingController();
  bool isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group Chat"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed:
                selectedUserIds.isNotEmpty &&
                    groupNameController.text.isNotEmpty
                ? _createGroupChat
                : null,
            icon: const Icon(Icons.check),
            tooltip: "Create Group",
            color:
                selectedUserIds.isNotEmpty &&
                    groupNameController.text.isNotEmpty
                ? Colors.white
                : Colors.grey[400],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: groupNameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Users",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs
                    .where((doc) => doc.id != currentUserId) // exclude self
                    .toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No users available"));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userData = user.data() as Map<String, dynamic>;
                    final userId = user.id;
                    final userName = userData['name'] ?? "Unknown";
                    final userImage = userData['profileImageUrl'];

                    final isSelected = selectedUserIds.contains(userId);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        backgroundImage:
                            userImage != null && userImage.isNotEmpty
                            ? NetworkImage(userImage)
                            : null,
                        child: userImage == null || userImage.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: Text(userName),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedUserIds.add(userId);
                            } else {
                              selectedUserIds.remove(userId);
                            }
                          });
                        },
                        activeColor: Colors.deepPurple,
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedUserIds.remove(userId);
                          } else {
                            selectedUserIds.add(userId);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (isCreating)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> _createGroupChat() async {
    if (selectedUserIds.isEmpty || groupNameController.text.isEmpty) return;

    setState(() {
      isCreating = true;
    });

    try {
      final allParticipants = [currentUserId, ...selectedUserIds];
      final chatDoc = _firestore.collection('chats').doc();

      await chatDoc.set({
        'participants': allParticipants,
        'groupName': groupNameController.text.trim(),
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
        'lastMessageStatus': 'sent',
        'lastSenderId': currentUserId,
      });

      Get.back(); // Close create group screen

      // Get.to(
      //   () => AgentChatScreen(
      //     partnerId: null,
      //     partnerName: groupNameController.text.trim(),
      //     isGroupChat: true,
      //     participants: allParticipants,
      //   ),
      // );

      Get.snackbar(
        "Group Created",
        "Your group chat has been created successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to create group chat: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isCreating = false;
      });
    }
  }
}
