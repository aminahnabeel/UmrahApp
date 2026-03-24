import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseJournalImgService {
  final supabase = Supabase.instance.client;

  Future<String?> uploadJournalImageToSupabase(imageFile) async {
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
}
