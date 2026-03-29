import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // kIsWeb check ke liye
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_umrah_app/Services/SupabaseServices/supabaseStorage/umrahJournalsImg.dart';

class UmrahJournalController extends GetxController {
  // Theme colors from your UI
  static const Color primaryBackgroundColor = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF1976D2);

  final SupabaseJournalImgService _supabaseService = SupabaseJournalImgService();

  RxList<QueryDocumentSnapshot<Map<String, dynamic>>> journals =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  RxBool isLoading = false.obs;
  
  // FIX: XFile use karein taake Web par error na aaye
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile.value = pickedFile; // Android aur Web dono ke liye fit hai
    }
  }

  Future<String?> uploadImage() async {
    if (imageFile.value == null) return null;
    try {
      // Supabase upload ke liye hum path bhejenge (Android ke liye)
      // Note: Agar web par upload nahi ho raha toh aapko service file mein check lagana hoga
      final url = await _supabaseService.uploadJournalImageToSupabase(
        File(imageFile.value!.path), 
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
        Get.snackbar('Success', 'Journal added successfully'); //
      } else {
        await journalCollection?.doc(docId).update(data);
        Get.snackbar('Updated', 'Journal updated successfully'); //
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
    } catch (e) {
      Get.snackbar('Error', 'Delete failed');
    }
  }
}