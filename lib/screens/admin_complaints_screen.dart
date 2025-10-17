import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/admin_service.dart';
import 'package:intl/intl.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Complaints Management',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Mycolors.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildFilterTab('all', 'All')),
                Expanded(child: _buildFilterTab('open', 'Open')),
                Expanded(child: _buildFilterTab('resolved', 'Resolved')),
              ],
            ),
          ),
          // Complaints List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: AdminService.getComplaintsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading complaints: ${snapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                final allComplaints = snapshot.data ?? [];
                final complaints = _selectedFilter == 'all'
                    ? allComplaints
                    : allComplaints
                          .where(
                            (c) =>
                                (c['status'] ?? 'open')
                                    .toString()
                                    .toLowerCase() ==
                                _selectedFilter,
                          )
                          .toList();

                if (complaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No complaints found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    return _buildComplaintCard(complaint);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
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

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final status = complaint['status'] ?? 'open';
    final createdAt = complaint['createdAt'];
    final dateStr = createdAt != null
        ? DateFormat('MMM dd, yyyy hh:mm a').format(createdAt.toDate())
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                child: Text(
                  (complaint['userName'] ?? complaint['userId'] ?? 'U')[0]
                      .toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Mycolors.basecolor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint['userName'] ?? complaint['userId'] ?? 'Unknown',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complaint['subject'] ?? 'No subject',
                      style: GoogleFonts.poppins(
                        color: Mycolors.gray,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _chip(status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            complaint['description'] ?? 'No description',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: GoogleFonts.poppins(fontSize: 12, color: Mycolors.gray),
              ),
              TextButton(
                onPressed: () => _showComplaintDetails(complaint),
                child: Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Mycolors.basecolor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String status) {
    Color color;
    final statusLower = status.toLowerCase();
    switch (statusLower) {
      case 'open':
        color = Mycolors.red;
        break;
      case 'in progress':
        color = Mycolors.orange;
        break;
      case 'resolved':
        color = Mycolors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showComplaintDetails(Map<String, dynamic> complaint) {
    final responseController = TextEditingController(
      text: complaint['adminResponse'] ?? '',
    );
    final status = complaint['status'] ?? 'open';
    final createdAt = complaint['createdAt'];
    final dateStr = createdAt != null
        ? DateFormat('MMM dd, yyyy hh:mm a').format(createdAt.toDate())
        : 'N/A';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Complaint Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('User', complaint['userName'] ?? 'Unknown'),
                const SizedBox(height: 12),
                _buildDetailRow('Subject', complaint['subject'] ?? 'N/A'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Description',
                  complaint['description'] ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Date', dateStr),
                const SizedBox(height: 12),
                _buildDetailRow('Status', status.toUpperCase()),
                const SizedBox(height: 16),
                Text(
                  'Admin Response',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: responseController,
                  decoration: InputDecoration(
                    hintText: 'Enter your response...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 4,
                  enabled: status.toLowerCase() != 'resolved',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            if (status.toLowerCase() != 'resolved')
              ElevatedButton(
                onPressed: () async {
                  if (responseController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a response'),
                        backgroundColor: Mycolors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);

                  final result = await AdminService.updateComplaintStatus(
                    complaint['id'],
                    'Resolved',
                    responseController.text.trim(),
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['success'] == true
                              ? 'Response sent successfully'
                              : result['error'],
                        ),
                        backgroundColor: result['success'] == true
                            ? Mycolors.green
                            : Mycolors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.basecolor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Send Response', style: GoogleFonts.poppins()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}
