import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TravelChecklistScreen extends StatefulWidget {
  const TravelChecklistScreen({super.key});

  @override
  State<TravelChecklistScreen> createState() => _TravelChecklistScreenState();
}

class _TravelChecklistScreenState extends State<TravelChecklistScreen> {
  // Colors
  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  final String _userId = FirebaseAuth.instance.currentUser!.uid;
  late final CollectionReference _checklistCollection;

  final TextEditingController _itemController = TextEditingController();

  // Predefined items
  final List<String> predefinedItems = const [
    'Passport',
    'Visa documents',
    'Flight tickets',
    'Ihram clothes (2 sets)',
    'Prayer mat',
    'Quran or Prayer book',
    'Medicine (prescribed)',
    'Towel',
    'Toothbrush & Toothpaste',
    'Shampoo & Soap',
    'Mobile charger',
    'Power bank',
    'Slippers/sandals',
    'Small backpack',
    'Sunscreen',
    'Cash (SAR)',
  ];

  @override
  void initState() {
    super.initState();
    _checklistCollection = FirebaseFirestore.instance
        .collection('user_checklists')
        .doc(_userId)
        .collection('items');
  }

  // Add predefined items if the checklist is empty
  Future<void> _initializePredefinedItems() async {
    final snapshot = await _checklistCollection.get();
    if (snapshot.docs.isEmpty) {
      for (var item in predefinedItems) {
        await _checklistCollection.add({
          'name': item,
          'isCompleted': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Add or update custom item
  Future<void> _addOrUpdateItem([DocumentSnapshot? documentSnapshot]) async {
    String action = documentSnapshot == null ? 'Add' : 'Update';

    if (documentSnapshot != null) {
      _itemController.text = documentSnapshot['name'] as String;
    } else {
      _itemController.clear();
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            '$action Item',
            style: const TextStyle(color: textColorPrimary),
          ),
          content: TextField(
            controller: _itemController,
            style: const TextStyle(color: textColorPrimary),
            decoration: InputDecoration(
              labelText: 'Item Name',
              labelStyle: const TextStyle(color: textColorSecondary),
              filled: true,
              fillColor: primaryBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: textColorSecondary),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              child: Text(
                action,
                style: const TextStyle(color: textColorPrimary),
              ),
              onPressed: () async {
                if (_itemController.text.isNotEmpty) {
                  if (documentSnapshot == null) {
                    await _checklistCollection.add({
                      'name': _itemController.text,
                      'isCompleted': false,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                  } else {
                    await _checklistCollection.doc(documentSnapshot.id).update({
                      'name': _itemController.text,
                    });
                  }
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Toggle complete status
  Future<void> _toggleItemStatus(
    DocumentSnapshot document,
    bool isCompleted,
  ) async {
    await _checklistCollection.doc(document.id).update({
      'isCompleted': isCompleted,
    });
  }

  // Delete item
  Future<void> _deleteItem(String documentId) async {
    await _checklistCollection.doc(documentId).delete();
  }

  @override
  Widget build(BuildContext context) {
    _initializePredefinedItems();

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
        title: const Text(
          "Travel Checklist",
          style: TextStyle(color: textColorPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColorPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: textColorPrimary),
            onPressed: () => _addOrUpdateItem(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _checklistCollection.orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accentColor),
            );
          }

          final documents = snapshot.data!.docs;
          if (documents.isEmpty) {
            return const Center(
              child: Text(
                "Your checklist is empty",
                style: TextStyle(color: textColorSecondary),
              ),
            );
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              final data = doc.data() as Map<String, dynamic>;
              final isCompleted = data['isCompleted'] as bool? ?? false;

              return Card(
                color: cardBackgroundColor,
                child: CheckboxListTile(
                  title: Text(
                    data['name'] ?? '',
                    style: TextStyle(
                      color: isCompleted
                          ? textColorSecondary
                          : textColorPrimary,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  value: isCompleted,
                  onChanged: (val) => _toggleItemStatus(doc, val!),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteItem(doc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
