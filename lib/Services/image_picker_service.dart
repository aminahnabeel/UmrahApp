import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Service for picking images from camera or gallery
/// Returns XFile for web compatibility
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from the specified source
  /// Returns XFile which works on both web and mobile
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85, // Compress to reduce file size
      );

      return pickedFile;
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: ${e.toString()}');
      return null;
    }
  }

  /// Show a dialog to let user choose between camera and gallery
  /// Returns XFile for web/mobile compatibility
  Future<XFile?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<XFile>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF263442)),
                  title: const Text('Camera'),
                  onTap: () async {
                    final pickedFile = await pickImage(ImageSource.camera);
                    if (context.mounted) {
                      Navigator.pop(context, pickedFile);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF263442)),
                  title: const Text('Gallery'),
                  onTap: () async {
                    final pickedFile = await pickImage(ImageSource.gallery);
                    if (context.mounted) {
                      Navigator.pop(context, pickedFile);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pick image from camera
  /// Returns XFile for web/mobile compatibility
  Future<XFile?> pickImageFromCamera() async {
    return pickImage(ImageSource.camera);
  }

  /// Pick image from gallery
  /// Returns XFile for web/mobile compatibility
  Future<XFile?> pickImageFromGallery() async {
    return pickImage(ImageSource.gallery);
  }

  /// Show error message using GetX snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
