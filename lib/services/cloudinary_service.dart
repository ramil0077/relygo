import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudinaryService {
  static const String _cloudName = 'dd1snr63e';
  static const String _uploadPreset = 'relygo_images';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload image to Cloudinary and return the public URL
  static Future<String?> uploadImage(File imageFile, String folder) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Add upload preset
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      // Send request
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        return jsonData['secure_url'];
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  /// Upload multiple images and return list of URLs
  static Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
    String folder,
  ) async {
    List<String> uploadedUrls = [];

    for (File imageFile in imageFiles) {
      String? url = await uploadImage(imageFile, folder);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  /// Save document URLs to Firestore
  static Future<bool> saveDocumentUrls(
    String userId,
    String userType,
    Map<String, String> documentUrls,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'userType': userType,
        'documents': documentUrls,
        'uploadedAt': FieldValue.serverTimestamp(),
        'status': userType == 'driver' ? 'pending' : 'approved',
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error saving to Firestore: $e');
      return false;
    }
  }

  /// Validate image file
  static bool isValidImageFile(File file) {
    List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    String extension = file.path.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  /// Check if file size is within limit (5MB)
  static bool isFileSizeValid(File file) {
    return getFileSizeInMB(file) <= 5.0;
  }
}
