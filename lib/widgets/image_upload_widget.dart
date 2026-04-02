import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Services/imgbb_service.dart';
import 'package:smart_umrah_app/Services/image_picker_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';

/// A reusable widget for uploading images to ImgBB
/// Provides UI for selecting images from camera/gallery,
/// displays loading state during upload, and shows the uploaded image
class ImageUploadWidget extends StatefulWidget {
  /// Callback when image is successfully uploaded
  final Function(String imageUrl) onImageUploaded;
  
  /// Initial image URL to display (optional)
  final String? initialImageUrl;
  
  /// Size of the image preview
  final double size;
  
  /// Border radius of the image preview
  final double borderRadius;

  const ImageUploadWidget({
    Key? key,
    required this.onImageUploaded,
    this.initialImageUrl,
    this.size = 120,
    this.borderRadius = 60,
  }) : super(key: key);

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ImgBBService _imgbbService = ImgBBService();
  
  XFile? _selectedImageFile;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _uploadedImageUrl = widget.initialImageUrl;
  }

  /// Handle image selection and upload
  Future<void> _selectAndUploadImage() async {
    try {
      // Show image source dialog (camera or gallery)
      final XFile? imageFile = await _imagePickerService.showImageSourceDialog(context);
      
      if (imageFile == null) {
        // User cancelled selection
        if (kDebugMode) {
          print('❌ User cancelled image selection');
        }
        return;
      }

      if (kDebugMode) {
        print('✅ Image selected: ${imageFile.path}');
        print('📏 Image name: ${imageFile.name}');
      }

      setState(() {
        _selectedImageFile = imageFile;
        _isUploading = true;
      });

      if (kDebugMode) {
        print('🔄 Starting upload...');
      }

      // Upload to ImgBB (accepts XFile)
      final imageUrl = await _imgbbService.uploadImage(imageFile);

      if (kDebugMode) {
        print('✅ Upload successful!');
        print('🔗 Image URL: $imageUrl');
      }

      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploading = false;
      });

      // Notify parent widget
      widget.onImageUploaded(imageUrl);

      // Show success message
      Get.snackbar(
        'Success',
        'Image uploaded successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } on ImgBBUploadException catch (e) {
      setState(() {
        _isUploading = false;
      });
      
      if (kDebugMode) {
        print('❌ Upload failed: ${e.toString()}');
      }
      
      Get.snackbar(
        'Upload Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      
      if (kDebugMode) {
        print('❌ Unexpected error: $e');
      }
      
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image preview with upload button
        GestureDetector(
          onTap: _isUploading ? null : _selectAndUploadImage,
          child: Stack(
            children: [
              // Image container
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius - 3),
                  child: _buildImageWidget(),
                ),
              ),
              
              // Loading indicator or camera icon
              if (_isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF263442),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Upload hint text
        if (!_isUploading && _uploadedImageUrl == null)
          const Text(
            'Tap to upload profile picture',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  /// Build the appropriate image widget based on current state
  Widget _buildImageWidget() {
    // Priority 1: Show uploaded image from ImgBB URL
    if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
      return Image.network(
        _uploadedImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            print('Error loading uploaded image: $error');
          }
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
      );
    }
    
    // Priority 2: Show selected image (before upload)
    if (_selectedImageFile != null) {
      if (kIsWeb) {
        // Web: Use FutureBuilder to load XFile bytes
        return FutureBuilder<Uint8List>(
          future: _selectedImageFile!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                );
              } else {
                return _buildPlaceholder();
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }
          },
        );
      } else {
        // Mobile: Use Image.file
        return Image.file(
          File(_selectedImageFile!.path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              print('Error loading selected image: $error');
            }
            return _buildPlaceholder();
          },
        );
      }
    }
    
    // Priority 3: Show placeholder
    return _buildPlaceholder();
  }

  /// Build placeholder icon when no image is available
  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.person,
        size: 60,
        color: Colors.grey,
      ),
    );
  }
}
