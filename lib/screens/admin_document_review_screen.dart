import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDocumentReviewScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const AdminDocumentReviewScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<AdminDocumentReviewScreen> createState() =>
      _AdminDocumentReviewScreenState();
}

class _AdminDocumentReviewScreenState extends State<AdminDocumentReviewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String>? _documents;
  bool _isLoading = true;
  String _reviewStatus = 'pending';
  String _adminNotes = '';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(widget.userId)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _documents = Map<String, String>.from(data['documents'] ?? {});
          _reviewStatus = data['status'] ?? 'pending';
          _adminNotes = data['adminNotes'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading documents: $e'),
          backgroundColor: Mycolors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Document Review",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          if (_reviewStatus == 'pending')
            PopupMenuButton<String>(
              onSelected: _handleStatusChange,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'approved', child: Text('Approve')),
                const PopupMenuItem(value: 'rejected', child: Text('Reject')),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Mycolors.basecolor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Review",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Mycolors.lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Driver Information",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow("Name", widget.userName),
                        _buildInfoRow("Email", widget.userEmail),
                        _buildInfoRow("Status", _getStatusText(_reviewStatus)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Documents Section
                  Text(
                    "Uploaded Documents",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (_documents != null) ...[
                    _buildDocumentCard(
                      "Driver License",
                      _documents!['license'] ?? '',
                      Icons.badge,
                    ),
                    const SizedBox(height: 15),
                    _buildDocumentCard(
                      "Vehicle Registration",
                      _documents!['vehicleRegistration'] ?? '',
                      Icons.directions_car,
                    ),
                    const SizedBox(height: 15),
                    _buildDocumentCard(
                      "Insurance Certificate",
                      _documents!['insurance'] ?? '',
                      Icons.security,
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Mycolors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "No documents uploaded",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Mycolors.gray,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Admin Notes
                  Text(
                    "Admin Notes",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Add notes about this review...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Mycolors.basecolor,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      _adminNotes = value;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  if (_reviewStatus == 'pending') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus('approved'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Mycolors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Approve",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus('rejected'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Mycolors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Reject",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String title, String imageUrl, IconData icon) {
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
              Icon(icon, color: Mycolors.basecolor, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (imageUrl.isNotEmpty)
            GestureDetector(
              onTap: () => _showImageDialog(title, imageUrl),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Failed to load image",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey.shade400,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "No image uploaded",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showImageDialog(String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title),
              backgroundColor: Mycolors.basecolor,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Failed to load image'));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending Review';
      default:
        return 'Unknown';
    }
  }

  void _handleStatusChange(String status) {
    _updateStatus(status);
  }

  Future<void> _updateStatus(String status) async {
    try {
      await _firestore.collection('users').doc(widget.userId).update({
        'status': status,
        'adminNotes': _adminNotes,
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _reviewStatus = status;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Driver $status successfully'),
          backgroundColor: status == 'approved' ? Mycolors.green : Mycolors.red,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Mycolors.red,
        ),
      );
    }
  }
}
