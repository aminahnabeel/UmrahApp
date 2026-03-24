import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_umrah_app/Services/SupabaseServices/supabaseStorage/manage_docImgs.dart';

class ManageDocController extends GetxController {
  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color accentColor = Color(0xFF3B82F6);

  RxList<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  RxBool isLoading = false.obs;
  Rx<File?> imageFile = Rx<File?>(null);

  final SupabaseDocImageService _supabaseService = SupabaseDocImageService();
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) imageFile.value = File(pickedFile.path);
  }

  Future<String?> uploadImage() async {
    if (imageFile.value == null) return null;
    try {
      final url = await _supabaseService.uploadDocImageToSupabase(
        imageFile.value!,
      );
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteDocument(String docId) async {
    try {
      await documentCollection?.doc(docId).delete();
      Get.snackbar('Deleted', 'Document removed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }

  Future<void> addOrUpdateDocument({
    String? docId,
    required String title,
    required String content,
    String? oldImageUrl,
  }) async {
    isLoading.value = true;
    final uploadedUrl = await uploadImage() ?? oldImageUrl;

    final data = {
      'title': title,
      'content': content,
      'date': FieldValue.serverTimestamp(),
      'photoUrl': uploadedUrl,
    };

    try {
      if (docId == null) {
        await documentCollection?.add(data);
        Get.back();
        Get.snackbar('Success', 'Document added successfully');
      } else {
        await documentCollection?.doc(docId).update(data);
        Get.back();
        Get.snackbar('Success', 'Document updated successfully');
      }
      imageFile.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save document: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
