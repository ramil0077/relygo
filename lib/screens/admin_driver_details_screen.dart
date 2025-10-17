import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/admin_service.dart';
import 'package:relygo/screens/admin_driver_chat_screen.dart';
import 'package:intl/intl.dart';

class AdminDriverDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> driver;

  const AdminDriverDetailsScreen({super.key, required this.driver});

  @override
  State<AdminDriverDetailsScreen> createState() =>
      _AdminDriverDetailsScreenState();
}

class _AdminDriverDetailsScreenState extends State<AdminDriverDetailsScreen> {
  String _selectedTab = 'details';

  @override
  Widget build(BuildContext context) {
    final status = widget.driver['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);

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
          "Driver Details",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          // Chat icon in app bar
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Mycolors.basecolor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AdminDriverChatScreen(driver: widget.driver),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Driver Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Mycolors.basecolor, Mycolors.darkBrown],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Mycolors.basecolor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    (widget.driver['name'] ?? 'D')[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.driver['name'] ?? 'Unknown Driver',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.driver['email'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.driver['phone'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Mycolors.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTabButton('details', 'Details')),
                Expanded(child: _buildTabButton('documents', 'Documents')),
                Expanded(child: _buildTabButton('history', 'History')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _selectedTab == 'details'
                ? _buildDetailsTab()
                : _selectedTab == 'documents'
                ? _buildDocumentsTab()
                : _buildHistoryTab(),
          ),

          // Action Buttons (if pending)
          if (status.toLowerCase() == 'pending')
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveDriver(),
                      icon: const Icon(Icons.check_circle),
                      label: Text(
                        'Approve',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectDriver(),
                      icon: const Icon(Icons.cancel),
                      label: Text(
                        'Reject',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Mycolors.basecolor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Information'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoRow('Full Name', widget.driver['name'] ?? 'N/A'),
            _buildInfoRow('Email', widget.driver['email'] ?? 'N/A'),
            _buildInfoRow('Phone', widget.driver['phone'] ?? 'N/A'),
            _buildInfoRow(
              'Status',
              (widget.driver['status'] ?? 'pending').toUpperCase(),
            ),
          ]),
          const SizedBox(height: 20),
          _buildSectionTitle('Vehicle Information'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoRow(
              'Vehicle Type',
              widget.driver['vehicleType'] ?? 'N/A',
            ),
            _buildInfoRow(
              'Vehicle Number',
              widget.driver['vehicleNumber'] ?? 'N/A',
            ),
            _buildInfoRow(
              'Vehicle Model',
              widget.driver['vehicleModel'] ?? 'N/A',
            ),
            _buildInfoRow(
              'Vehicle Color',
              widget.driver['vehicleColor'] ?? 'N/A',
            ),
          ]),
          const SizedBox(height: 20),
          _buildSectionTitle('Registration Details'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoRow(
              'Registered On',
              widget.driver['createdAt'] != null
                  ? DateFormat(
                      'MMM dd, yyyy hh:mm a',
                    ).format(widget.driver['createdAt'].toDate())
                  : 'N/A',
            ),
            if (widget.driver['approvedAt'] != null)
              _buildInfoRow(
                'Approved On',
                DateFormat(
                  'MMM dd, yyyy hh:mm a',
                ).format(widget.driver['approvedAt'].toDate()),
              ),
            if (widget.driver['rejectedAt'] != null)
              _buildInfoRow(
                'Rejected On',
                DateFormat(
                  'MMM dd, yyyy hh:mm a',
                ).format(widget.driver['rejectedAt'].toDate()),
              ),
            if (widget.driver['rejectionReason'] != null)
              _buildInfoRow(
                'Rejection Reason',
                widget.driver['rejectionReason'],
              ),
          ]),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    final documents = widget.driver['documents'] as Map<String, dynamic>?;

    if (documents == null || documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No documents uploaded',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (documents['license'] != null)
            _buildDocumentCard(
              'Driver License',
              documents['license'],
              Icons.badge,
              Mycolors.blue,
            ),
          const SizedBox(height: 16),
          if (documents['vehicleRegistration'] != null)
            _buildDocumentCard(
              'Vehicle Registration',
              documents['vehicleRegistration'],
              Icons.directions_car,
              Mycolors.green,
            ),
          const SizedBox(height: 16),
          if (documents['insurance'] != null)
            _buildDocumentCard(
              'Insurance Certificate',
              documents['insurance'],
              Icons.security,
              Mycolors.orange,
            ),
          const SizedBox(height: 16),
          if (documents['profilePhoto'] != null)
            _buildDocumentCard(
              'Profile Photo',
              documents['profilePhoto'],
              Icons.person,
              Mycolors.purple,
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    // This could show ride history, complaints, feedback, etc.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Driver history coming soon',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Will show rides, earnings, ratings',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
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

  Widget _buildDocumentCard(
    String title,
    String imageUrl,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Colors.grey),
                onPressed: () {
                  // Download functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Download feature coming soon'),
                      backgroundColor: Mycolors.orange,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (imageUrl.isNotEmpty)
            GestureDetector(
              onTap: () => _showImageDialog(title, imageUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.grey[400], size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No document uploaded',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Tap to view full size',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
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
        backgroundColor: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
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
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'Failed to load image',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Mycolors.green;
      case 'rejected':
        return Mycolors.red;
      case 'pending':
      default:
        return Mycolors.orange;
    }
  }

  Future<void> _approveDriver() async {
    final result = await AdminService.approveDriver(widget.driver['id']);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? 'Driver approved successfully'
                : result['error'],
          ),
          backgroundColor: result['success'] == true
              ? Mycolors.green
              : Mycolors.red,
        ),
      );

      if (result['success'] == true) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _rejectDriver() async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reject Driver Application',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please provide a reason for rejection:',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Reject', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.trim().isNotEmpty) {
      final result = await AdminService.rejectDriver(
        widget.driver['id'],
        reasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true ? 'Driver rejected' : result['error'],
            ),
            backgroundColor: result['success'] == true
                ? Mycolors.orange
                : Mycolors.red,
          ),
        );

        if (result['success'] == true) {
          Navigator.pop(context);
        }
      }
    }
  }
}
