import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/userControllers/DocumentController/docs_controller.dart';

class ManageDocScreen extends StatelessWidget {
  ManageDocScreen({super.key});

  final ManageDocController controller = Get.put(ManageDocController());

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void showDocumentDialog({Map<String, dynamic>? docData, String? docId}) {
    if (docData != null) {
      titleController.text = docData['title'] ?? '';
      contentController.text = docData['content'] ?? '';
      controller.imageFile.value = null;
    } else {
      titleController.clear();
      contentController.clear();
      controller.imageFile.value = null;
    }

    Get.defaultDialog(
      title: docId == null ? 'Add Document' : 'Edit Document',
      backgroundColor: ManageDocController.cardBackgroundColor,
      titleStyle: const TextStyle(color: Colors.white),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF1E2A38),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF1E2A38),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.imageFile.value != null) {
                return Image.file(
                  controller.imageFile.value!,
                  height: 120,
                  width: 120,
                );
              } else if (docData?['photoUrl'] != null) {
                return Image.network(
                  docData!['photoUrl'],
                  height: 120,
                  width: 120,
                );
              } else {
                return const SizedBox();
              }
            }),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: controller.pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ManageDocController.accentColor,
              ),
            ),
          ],
        ),
      ),
      confirm: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();
                  if (title.isEmpty || content.isEmpty) {
                    Get.snackbar('Error', 'Title and content are required');
                    return;
                  }
                  controller.addOrUpdateDocument(
                    docId: docId,
                    title: title,
                    content: content,
                    oldImageUrl: docData?['photoUrl'],
                  );

                  Future.delayed(const Duration(seconds: 1), () {
                    titleController.clear();
                    contentController.clear();
                    Get.back();
                  });
                },
          child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(docId == null ? 'Add' : 'Update'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ManageDocController.accentColor,
          ),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ManageDocController.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: ManageDocController.primaryBackgroundColor,
        foregroundColor: Colors.white,
        title: const Text('Important Documents'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.documents.isEmpty) {
          return const Center(
            child: Text(
              'No documents yet',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.documents.length,
          itemBuilder: (context, index) {
            final doc = controller.documents[index];
            final data = doc.data();
            final photoUrl = data['photoUrl'];
            final timestamp = data['date'];
            final formattedDate = timestamp != null
                ? (timestamp as dynamic).toDate().toLocal().toString().split(
                    ' ',
                  )[0]
                : 'No date';
            return Card(
              color: ManageDocController.cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => showDocumentDialog(docData: data, docId: doc.id),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.deleteDocument(doc.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      if (photoUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            photoUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        data['content'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ManageDocController.accentColor,
        onPressed: () => showDocumentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
