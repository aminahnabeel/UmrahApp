import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_umrah_app/Services/imgbb_service.dart';

class ManageDocController extends GetxController {
  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color accentColor = Color(0xFF3B82F6);

  RxList<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  RxBool isLoading = false.obs;
  Rx<XFile?> imageFile = Rx<XFile?>(null);

  final ImgBBService _imgbbService = ImgBBService();
  CollectionReference<Map<String, dynamic>>? documentCollection;

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      documentCollection = FirebaseFirestore.instance
          .collection('manage-documents')
          .doc(user.uid)
          .collection('entries');
      fetchDocuments();
    }
  }

  void fetchDocuments() {
    if (documentCollection == null) return;
    documentCollection!.orderBy('date', descending: true).snapshots().listen((
      snapshot,
    ) {
      documents.value = snapshot.docs;
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
      
      if (kDebugMode) {
        print('✅ Document image selected: ${pickedFile.name}');
      }
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
      
      if (kDebugMode) {
        print('✅ Document image captured: ${pickedFile.name}');
      }
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
      if (kDebugMode) {
        print('📤 Uploading document image to ImgBB...');
      }
      
      final url = await _imgbbService.uploadImage(imageFile.value!);
      
      if (kDebugMode) {
        print('✅ Document image uploaded: $url');
      }
      
      return url;
    } on ImgBBUploadException catch (e) {
      if (kDebugMode) {
        print('❌ Upload failed: $e');
      }
      Get.snackbar(
        'Upload Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to upload image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<void> deleteDocument(String docId) async {
    try {
      await documentCollection?.doc(docId).delete();
      Get.snackbar(
        'Deleted',
        'Document removed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> addOrUpdateDocument({
    String? docId,
    required String title,
    required String content,
    String? oldImageUrl,
  }) async {
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
        await documentCollection?.add(data);
        Get.snackbar(
          'Success',
          'Document added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await documentCollection?.doc(docId).update(data);
        Get.snackbar(
          'Success',
          'Document updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      imageFile.value = null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving document: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to save document: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
