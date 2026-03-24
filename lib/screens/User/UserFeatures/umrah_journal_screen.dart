import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/userControllers/JournalController/journal_controller.dart';

class UmrahJournalScreen extends StatelessWidget {
  UmrahJournalScreen({super.key});

  final UmrahJournalController controller = Get.put(UmrahJournalController());

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  void showJournalDialog({Map<String, dynamic>? docData, String? docId}) {
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
      title: docId == null ? 'New Journal Entry' : 'Edit Entry',
      backgroundColor: UmrahJournalController.cardBackgroundColor,
      titleStyle: const TextStyle(color: Colors.white),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: UmrahJournalController.primaryBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: UmrahJournalController.primaryBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.imageFile.value != null) {
                return Image.file(
                  controller.imageFile.value!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                );
              } else if (docData?['photoUrl'] != null) {
                return Image.network(
                  docData!['photoUrl'],
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                );
              } else {
                return const SizedBox();
              }
            }),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: controller.pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Add Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UmrahJournalController.accentColor,
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
                  controller.addOrUpdateJournal(
                    docId: docId,
                    title: title,
                    content: content,
                    oldImageUrl: docData?['photoUrl'],
                  );
                  Get.back();
                },
          child: controller.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(docId == null ? 'Add' : 'Update'),
          style: ElevatedButton.styleFrom(
            backgroundColor: UmrahJournalController.accentColor,
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
      backgroundColor: UmrahJournalController.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: UmrahJournalController.primaryBackgroundColor,
        elevation: 0,
        title: const Text(
          'Umrah Journal',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => showJournalDialog(),
          ),
        ],
      ),
      body: Obx(() {
        final docs = controller.journals;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Your journal is empty.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data();
            final timestamp = data['date'];
            final formattedDate = timestamp != null
                ? (timestamp as dynamic).toDate().toLocal().toString().split(
                    ' ',
                  )[0]
                : 'No date';
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: UmrahJournalController.cardBackgroundColor,
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            onPressed: () => controller.deleteJournal(doc.id),
                          ),
                        ],
                      ),
                      if (data['photoUrl'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            data['photoUrl'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (data['photoUrl'] != null) const SizedBox(height: 12),
                      Text(
                        data['content'] ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((data['content'] ?? '').isNotEmpty)
                        const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.white70.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.white70.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
