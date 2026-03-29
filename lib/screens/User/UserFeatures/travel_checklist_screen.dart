import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart'; 

class TravelChecklistScreen extends StatefulWidget {
  const TravelChecklistScreen({super.key});

  @override
  State<TravelChecklistScreen> createState() => _TravelChecklistScreenState();
}

class _TravelChecklistScreenState extends State<TravelChecklistScreen> {
  // Colors updated for White Cards
  static const Color cardBgColor = Colors.white; // Card color set to White
  static const Color textColorPrimary = Colors.black;
  static const Color textColorSecondary = Colors.black54;
  
  // Custom Blue Color from user
  static const Color customIconBlue = Color(0xFF003D91); 

  // Background Gradient Colors
  static const Color topGradientColor = Color(0xFF0D47A1); 
  static const Color bottomGradientColor = Color(0xFF1976D2); 

  final String _userId = FirebaseAuth.instance.currentUser!.uid;
  late final CollectionReference _checklistCollection;
  final TextEditingController _itemController = TextEditingController();

  final List<String> predefinedItems = const [
    'Passport', 'Visa documents', 'Flight tickets', 'Ihram clothes (2 sets)',
    'Prayer mat', 'Quran or Prayer book', 'Medicine (prescribed)', 'Towel',
    'Toothbrush & Toothpaste', 'Shampoo & Soap', 'Mobile charger', 'Power bank',
    'Slippers/sandals', 'Small backpack', 'Sunscreen', 'Cash (SAR)',
  ];

  @override
  void initState() {
    super.initState();
    _checklistCollection = FirebaseFirestore.instance
        .collection('user_checklists')
        .doc(_userId)
        .collection('items');
    _initializePredefinedItems();
  }

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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('$action Item', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _itemController,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Item Name',
              labelStyle: const TextStyle(color: Colors.black54),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: customIconBlue),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: customIconBlue),
              child: Text(action, style: const TextStyle(color: Colors.white)),
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
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleItemStatus(DocumentSnapshot document, bool isCompleted) async {
    await _checklistCollection.doc(document.id).update({'isCompleted': isCompleted});
  }

  Future<void> _deleteItem(String documentId) async {
    await _checklistCollection.doc(documentId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: "Travel Checklist", showBackButton: true),
      floatingActionButton: FloatingActionButton(
        backgroundColor: customIconBlue, //
        onPressed: () => _addOrUpdateItem(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topGradientColor, bottomGradientColor], //
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: _checklistCollection.orderBy('timestamp').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              final documents = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final isCompleted = data['isCompleted'] as bool? ?? false;

                  return Card(
                    color: cardBgColor, // Set to White
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Checkbox(
                        activeColor: customIconBlue,
                        side: const BorderSide(color: Colors.grey, width: 1.5),
                        value: isCompleted,
                        onChanged: (val) => _toggleItemStatus(doc, val!),
                      ),
                      title: Text(
                        data['name'] ?? '',
                        style: TextStyle(
                          color: isCompleted ? textColorSecondary : textColorPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteItem(doc.id),
                      ),
                      onTap: () => _addOrUpdateItem(doc),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}