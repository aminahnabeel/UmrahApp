import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Service for uploading images to ImgBB API
/// Works on both mobile (Android/iOS) and web platforms
class ImgBBService {
  // ImgBB API configuration - Updated API Key
  static const String _apiKey = '794769a56f6f374bbe761ef2b89074bb';
  static const String _uploadEndpoint = 'https://api.imgbb.com/1/upload';

  /// Upload an image file to ImgBB and return the image URL
  /// Works with File (mobile) or XFile (web/mobile)
  /// 
  /// Throws [ImgBBUploadException] if upload fails
  /// Throws [SocketException] if there's no internet connection
  Future<String> uploadImage(dynamic imageFile) async {
    try {
      Uint8List bytes;
      int fileSize;

      // Handle different input types for web and mobile
      if (imageFile is XFile) {
        // XFile works on both web and mobile
        bytes = await imageFile.readAsBytes();
        fileSize = bytes.length;
        
        if (kDebugMode) {
          print('📱 Using XFile (Web/Mobile compatible)');
        }
      } else if (imageFile is File) {
        // File only works on mobile
        if (kIsWeb) {
          throw ImgBBUploadException('File type not supported on web. Use XFile instead.');
        }
        
        if (!await imageFile.exists()) {
          throw ImgBBUploadException('Image file does not exist');
        }
        
        bytes = await imageFile.readAsBytes();
        fileSize = bytes.length;
        
        if (kDebugMode) {
          print('📱 Using File (Mobile)');
        }
      } else {
        throw ImgBBUploadException('Unsupported image type. Use File or XFile.');
      }

      // Check file size (ImgBB free tier has 32MB limit)
      if (fileSize > 32 * 1024 * 1024) {
        throw ImgBBUploadException('Image size exceeds 32MB limit');
      }

      if (kDebugMode) {
        print('📤 ImgBB Upload Starting...');
        print('Platform: ${kIsWeb ? "Web" : "Mobile"}');
        print('File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      }

      // Convert image to base64
      final base64Image = base64Encode(bytes);

      if (kDebugMode) {
        print('✅ Image converted to Base64');
        print('Base64 length: ${base64Image.length}');
      }

      // Create request with proper URL encoding
      final uri = Uri.parse(_uploadEndpoint).replace(
        queryParameters: {'key': _apiKey},
      );

      final request = http.MultipartRequest('POST', uri);
      
      // Add image as form field (not file)
      request.fields['image'] = base64Image;

      if (kDebugMode) {
        print('🌐 Sending request to ImgBB...');
      }

      // Send request with extended timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw ImgBBUploadException('Upload timeout after 60 seconds. Please try again.');
        },
      );

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📥 Response Status Code: ${response.statusCode}');
        print('📥 Response Body: ${response.body}');
      }

      // Check if request was successful
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Check if upload was successful
        if (jsonResponse['success'] == true) {
          final imageUrl = jsonResponse['data']['url'] as String;
          final displayUrl = jsonResponse['data']['display_url'] as String?;
          
          if (kDebugMode) {
            print('✅ Upload Success!');
            print('Image URL: $imageUrl');
            print('Display URL: $displayUrl');
          }
          
          return imageUrl;
        } else {
          final errorMsg = jsonResponse['error']?['message'] ?? 
                          jsonResponse['error']?.toString() ?? 
                          'Unknown error from ImgBB';
          if (kDebugMode) {
            print('❌ ImgBB API Error: $errorMsg');
          }
          throw ImgBBUploadException('Upload failed: $errorMsg');
        }
      } else {
        // Handle HTTP error codes with detailed messages
        String errorMessage;
        try {
          final errorJson = json.decode(response.body);
          errorMessage = errorJson['error']?['message'] ?? 
                        errorJson['error']?.toString() ?? 
                        'HTTP ${response.statusCode}';
        } catch (_) {
          errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        }

        if (kDebugMode) {
          print('❌ HTTP Error: $errorMessage');
        }

        if (response.statusCode == 400) {
          throw ImgBBUploadException('Invalid request: $errorMessage');
        } else if (response.statusCode == 403) {
          throw ImgBBUploadException('Authentication failed: Check API key');
        } else {
          throw ImgBBUploadException('Upload failed: $errorMessage');
        }
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('❌ Socket Exception: $e');
      }
      throw ImgBBUploadException(
        'No internet connection. Please check your network and try again.',
      );
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('❌ Client Exception: $e');
      }
      throw ImgBBUploadException(
        'Network error occurred. Please try again.',
      );
    } catch (e) {
      if (e is ImgBBUploadException) {
        rethrow;
      }
      if (kDebugMode) {
        print('❌ Unexpected error: $e');
      }
      throw ImgBBUploadException('Unexpected error: ${e.toString()}');
    }
  }

  /// Upload an image with progress tracking (optional enhancement)
  /// Can be used to show upload progress in UI
  Future<String> uploadImageWithProgress(
    File imageFile, {
    Function(double)? onProgress,
  }) async {
    // Implementation would require additional packages for progress tracking
    // For now, falls back to regular upload
    return uploadImage(imageFile);
  }
}

/// Custom exception for ImgBB upload errors
class ImgBBUploadException implements Exception {
  final String message;

  ImgBBUploadException(this.message);

  @override
  String toString() => message;
}
