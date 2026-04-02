import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/userControllers/DocumentController/docs_controller.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart';
import 'dart:typed_data';

class ManageDocScreen extends StatelessWidget {
  ManageDocScreen({super.key});

  final ManageDocController controller = Get.put(ManageDocController());
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  static const Color customIconBlue = Color(0xFF003D91); //
  static const Color topGradientColor = Color(0xFF0D47A1); 
  static const Color bottomGradientColor = Color(0xFF1976D2); 

  void showDocumentDialog(BuildContext context, {Map<String, dynamic>? docData, String? docId}) {
    titleController.text = docData?['title'] ?? '';
    contentController.text = docData?['content'] ?? '';
    controller.imageFile.value = null;

    Get.defaultDialog(
      title: docId == null ? 'Add Document' : 'Edit Document',
      backgroundColor: Colors.white,
      barrierDismissible: false,
      titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              maxLines: 3,
              decoration: InputDecoration(labelText: 'Content', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 10),
            Obx(() {
              // Show selected image
              if (controller.imageFile.value != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? FutureBuilder<Uint8List>(
                          future: controller.imageFile.value!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              );
                            }
                            return const SizedBox(
                              height: 100,
                              width: 100,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                        )
                      : Image.file(
                          File(controller.imageFile.value!.path),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                );
              }
              // Show existing image from URL
              else if (docData != null && docData['photoUrl'] != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    docData['photoUrl'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 100,
                        width: 100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 100,
                        width: 100,
                        child: Icon(Icons.error),
                      );
                    },
                  ),
                );
              }
              // No image
              return const Text("No image selected", style: TextStyle(fontSize: 12));
            }),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => controller.showImageSourceDialog(),
              icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
              label: const Text('Pick Image', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: customIconBlue),
            ),
          ],
        ),
      ),
      confirm: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : () async {
          if (titleController.text.trim().isEmpty) {
            Get.closeAllSnackbars();
            Get.snackbar('Required', 'Please enter a title');
            return;
          }
          
          await controller.addOrUpdateDocument(
            docId: docId,
            title: titleController.text.trim(),
            content: contentController.text.trim(),
            oldImageUrl: docData?['photoUrl'],
          );

          if (Get.isDialogOpen!) {
             Navigator.of(context, rootNavigator: true).pop();
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: customIconBlue),
        child: controller.isLoading.value 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(docId == null ? 'Add' : 'Update', style: const TextStyle(color: Colors.white)),
      )),
      cancel: TextButton(
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: 'Important Documents', showBackButton: true), //
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [topGradientColor, bottomGradientColor],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.documents.isEmpty) {
              return const Center(child: Text('No documents yet', style: TextStyle(color: Colors.white70)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.documents.length,
              itemBuilder: (context, index) {
                final doc = controller.documents[index];
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () => showDocumentDialog(context, docData: data, docId: doc.id),
                    title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['content'] ?? '', style: const TextStyle(color: Colors.black87)),
                        if (data['photoUrl'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(data['photoUrl'], height: 120, width: double.infinity, fit: BoxFit.cover),
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => controller.deleteDocument(doc.id),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: customIconBlue,
        onPressed: () => showDocumentDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}