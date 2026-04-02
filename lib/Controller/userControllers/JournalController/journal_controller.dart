import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_umrah_app/Services/imgbb_service.dart';

class UmrahJournalController extends GetxController {
  static const Color primaryBackgroundColor = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF1976D2);

  final ImgBBService _imgbbService = ImgBBService();

  RxList<QueryDocumentSnapshot<Map<String, dynamic>>> journals =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  RxBool isLoading = false.obs;
  
  Rx<XFile?> imageFile = Rx<XFile?>(null);

  CollectionReference<Map<String, dynamic>>? journalCollection;
  String? userId;

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      journalCollection = FirebaseFirestore.instance
          .collection('user_journals')
          .doc(userId)
          .collection('entries');
      fetchJournals();
    }
  }

  void fetchJournals() {
    if (journalCollection == null) return;
    journalCollection!.orderBy('date', descending: true).snapshots().listen((snapshot) {
      journals.value = snapshot.docs;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      imageFile.value = pickedFile;
    }
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      imageFile.value = pickedFile;
    }
  }

  Future<void> showImageSourceDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0D47A1)),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF0D47A1)),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> uploadImage() async {
    if (imageFile.value == null) return null;
    try {
      // Upload XFile directly - works on both web and mobile
      final url = await _imgbbService.uploadImage(imageFile.value!);
      return url;
    } on ImgBBUploadException catch (e) {
      Get.snackbar(
        'Upload Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<void> addOrUpdateJournal({
    String? docId,
    required String title,
    required String content,
    String? oldImageUrl,
  }) async {
    if (title.isEmpty || content.isEmpty) {
      Get.snackbar('Error', 'Title and content are required');
      return;
    }

    isLoading.value = true;
    try {
      final uploadedUrl = await uploadImage() ?? oldImageUrl;
      final data = {
        'title': title,
        'content': content,
        'date': FieldValue.serverTimestamp(),
        'photoUrl': uploadedUrl,
      };

      if (docId == null) {
        await journalCollection?.add(data);
        Get.snackbar(
          'Success',
          'Journal added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await journalCollection?.doc(docId).update(data);
        Get.snackbar(
          'Updated',
          'Journal updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      imageFile.value = null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteJournal(String docId) async {
    try {
      await journalCollection?.doc(docId).delete();
    } catch (e) {
      Get.snackbar('Error', 'Delete failed');
    }
  }
}