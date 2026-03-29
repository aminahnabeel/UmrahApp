import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDocImageService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadDocImageToSupabase(imageFile) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

      final response = await supabase.storage
          .from('umrahJournals')
          .upload(fileName, imageFile);

      print("PICTURE RESPONSE : ${response}");

      if (response.isNotEmpty) {
        final publicUrl = supabase.storage
            .from('umrahJournals')
            .getPublicUrl(fileName);

        Get.snackbar("IMAGE RESULT", "IMAGE UPLOAD SUCCESSFULLY");
        return publicUrl;
      } else {
        debugPrint('UPLOAD FAILD');
        return null;
      }
    } catch (e) {
      debugPrint('ERROR WHILE UPLOADING THE IMAGE $e');
      return null;
    }
  }

  Future<bool> deleteImageFromSupabase(String fileName) async {
    try {
      final response = await supabase.storage.from('manage-documents').remove([
        fileName,
      ]);

      if (response.isEmpty) {
        // If the response is empty → deletion successful
        Get.snackbar("IMAGE RESULT", "Image deleted successfully");
        return true;
      } else {
        debugPrint('DELETE FAILED: $response');
        return false;
      }
    } catch (e) {
      debugPrint('ERROR WHILE DELETING IMAGE $e');
      return false;
    }
  }
}
