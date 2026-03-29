import 'dart:io';
import 'package:flutter/foundation.dart'; // Isse yellow line khatam ho jayegi aur kIsWeb chalega
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/userControllers/JournalController/journal_controller.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart';

class UmrahJournalScreen extends StatelessWidget {
  UmrahJournalScreen({super.key});

  final UmrahJournalController controller = Get.put(UmrahJournalController());
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // Aapki Theme ke Colors
  static const Color topGradientColor = Color(0xFF0D47A1); 
  static const Color bottomGradientColor = Color(0xFF1976D2); 
  static const Color customIconBlue = Color(0xFF003D91); 

  void showJournalDialog(BuildContext context, {Map<String, dynamic>? docData, String? docId}) {
    if (docData != null) {
      titleController.text = docData['title'] ?? '';
      contentController.text = docData['content'] ?? '';
    } else {
      titleController.clear();
      contentController.clear();
    }
    controller.imageFile.value = null;

    Get.defaultDialog(
      title: docId == null ? 'Add Document' : 'Edit Document', //
      backgroundColor: Colors.white,
      titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            
            // Image Preview Logic: Mobile aur Web dono ke liye
            Obx(() {
              if (controller.imageFile.value != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb 
                    ? Image.network(controller.imageFile.value!.path, height: 100, width: 100, fit: BoxFit.cover)
                    : Image.file(File(controller.imageFile.value!.path), height: 100, width: 100, fit: BoxFit.cover),
                );
              } else if (docData?['photoUrl'] != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(docData!['photoUrl'], height: 100, width: 100, fit: BoxFit.cover),
                );
              }
              return const Text("No image selected", style: TextStyle(fontSize: 12, color: Colors.grey));
            }),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => controller.pickImage(),
              icon: const Icon(Icons.photo_library, color: Colors.white, size: 20),
              label: const Text('Pick Image', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: customIconBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
      confirm: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : () async {
          await controller.addOrUpdateJournal(
            docId: docId,
            title: titleController.text.trim(),
            content: contentController.text.trim(),
            oldImageUrl: docData?['photoUrl'],
          );
          if (context.mounted) Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(backgroundColor: customIconBlue),
        child: controller.isLoading.value 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(docId == null ? 'Add' : 'Update', style: const TextStyle(color: Colors.white)),
      )),
      cancel: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Umrah Journal',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => showJournalDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topGradientColor, bottomGradientColor],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final docs = controller.journals;
            if (docs.isEmpty) {
              return const Center(child: Text('Your journal is empty.', style: TextStyle(color: Colors.white70)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final data = docs[i].data();
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: data['photoUrl'] != null 
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(data['photoUrl'], width: 50, height: 50, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.book, color: Colors.grey),
                    title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(data['content'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => controller.deleteJournal(docs[i].id),
                    ),
                    onTap: () => showJournalDialog(context, docData: data, docId: docs[i].id),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}