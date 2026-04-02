import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Services/imgbb_service.dart';
import 'package:image_picker/image_picker.dart';

/// Test screen to verify ImgBB uploads are working correctly
/// Use this to debug image upload issues
class ImgBBTestScreen extends StatefulWidget {
  const ImgBBTestScreen({Key? key}) : super(key: key);

  @override
  State<ImgBBTestScreen> createState() => _ImgBBTestScreenState();
}

class _ImgBBTestScreenState extends State<ImgBBTestScreen> {
  final ImgBBService _imgbbService = ImgBBService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isUploading = false;
  String? _uploadedUrl;
  String? _errorMessage;
  File? _selectedImage;

  Future<void> _testUpload() async {
    try {
      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _isUploading = true;
        _errorMessage = null;
        _uploadedUrl = null;
      });

      // Upload to ImgBB
      final url = await _imgbbService.uploadImage(_selectedImage!);

      setState(() {
        _uploadedUrl = url;
        _isUploading = false;
      });

      Get.snackbar(
        'Success! ✅',
        'Image uploaded successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } on ImgBBUploadException catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isUploading = false;
      });

      Get.snackbar(
        'Upload Failed ❌',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
        _isUploading = false;
      });

      Get.snackbar(
        'Error ❌',
        'Unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImgBB Upload Test'),
        backgroundColor: const Color(0xFF263442),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_upload,
                size: 80,
                color: Color(0xFF263442),
              ),
              const SizedBox(height: 20),
              const Text(
                'ImgBB Upload Test',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'API Key: 794769a56f6f374bbe761ef2b89074bb',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Selected image preview
              if (_selectedImage != null)
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Upload button
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _testUpload,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.upload),
                label: Text(_isUploading ? 'Uploading...' : 'Select & Upload Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF263442),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Upload result
              if (_uploadedUrl != null) ...[
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            'Upload Successful!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Image URL:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      SelectableText(
                        _uploadedUrl!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            'Upload Failed',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
