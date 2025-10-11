import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/cloudinary_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String folder;
  final Function(String) onImageUploaded;
  final String? initialImageUrl;

  const ImageUploadWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.folder,
    required this.onImageUploaded,
    this.initialImageUrl,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _uploadedUrl;

  @override
  void initState() {
    super.initState();
    _uploadedUrl = widget.initialImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Mycolors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload_file, color: Mycolors.basecolor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Mycolors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isUploading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Mycolors.basecolor,
                    ),
                  ),
                )
              else if (_uploadedUrl != null)
                Icon(Icons.check_circle, color: Mycolors.green, size: 20)
              else
                ElevatedButton(
                  onPressed: _selectImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors.basecolor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    "Upload",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
            ],
          ),
          if (_selectedImage != null && _uploadedUrl == null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _uploadImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Confirm Upload",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _removeImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Remove",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_uploadedUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Mycolors.green),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _uploadedUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.basecolor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Change Image",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _removeImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Remove",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        File imageFile = File(image.path);

        // Validate file
        if (!CloudinaryService.isValidImageFile(imageFile)) {
          _showErrorSnackBar(
            'Please select a valid image file (JPG, PNG, GIF, WebP)',
          );
          return;
        }

        if (!CloudinaryService.isFileSizeValid(imageFile)) {
          _showErrorSnackBar('Image size must be less than 5MB');
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String? uploadedUrl = await CloudinaryService.uploadImage(
        _selectedImage!,
        widget.folder,
      );

      if (uploadedUrl != null) {
        setState(() {
          _uploadedUrl = uploadedUrl;
          _selectedImage = null;
        });

        widget.onImageUploaded(uploadedUrl);
        _showSuccessSnackBar('Image uploaded successfully!');
      } else {
        _showErrorSnackBar('Failed to upload image. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error uploading image: $e');
    }

    setState(() {
      _isUploading = false;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _uploadedUrl = null;
    });
    widget.onImageUploaded('');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Mycolors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Mycolors.green),
    );
  }
}
