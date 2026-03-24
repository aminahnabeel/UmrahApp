import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_umrah_app/Services/SupabaseServices/supabaseStorage/umrahJournalsImg.dart';

class UmrahJournalController extends GetxController {
  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color accentColor = Color(0xFF3B82F6);

  final SupabaseJournalImgService _supabaseService =
      SupabaseJournalImgService();

  RxList<QueryDocumentSnapshot<Map<String, dynamic>>> journals =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  RxBool isLoading = false.obs;
  Rx<File?> imageFile = Rx<File?>(null);

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
    journalCollection!.orderBy('date', descending: true).snapshots().listen((
      snapshot,
    ) {
      journals.value = snapshot.docs;
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
      final url = await _supabaseService.uploadJournalImageToSupabase(
        imageFile.value!,
      );
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<void> addOrUpdateJournal({
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
        await journalCollection?.add(data);
      } else {
        await journalCollection?.doc(docId).update(data);
      }
      imageFile.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteJournal(String docId) async {
    try {
      await journalCollection?.doc(docId).delete();
      Get.snackbar('Deleted', 'Journal entry removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }
}
