// Pick imahes from the gallery or take a new photo using the camera.
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class ImagePickerController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  Rx<File?> selectedImage = Rx<File?>(null);

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
        if (kDebugMode) {
          print('SELECTED IMAGE: ${selectedImage.value?.path}');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo: $e');
    }
  }
}
