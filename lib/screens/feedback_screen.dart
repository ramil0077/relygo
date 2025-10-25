import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/admin_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _selectedFilter = "All";
  String _searchQuery = "";

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
          "Feedback & Reviews",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Mycolors.basecolor),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search feedback...",
                    prefixIcon: Icon(Icons.search, color: Mycolors.basecolor),
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
                ),
                const SizedBox(height: 15),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("All", "All"),
                      const SizedBox(width: 10),
                      _buildFilterChip("High Rating", "High Rating"),
                      const SizedBox(width: 10),
                      _buildFilterChip("Low Rating", "Low Rating"),
                      const SizedBox(width: 10),
                      _buildFilterChip("Under Review", "Under Review"),
                      const SizedBox(width: 10),
                      _buildFilterChip("Hidden", "Hidden"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Feedback List (real-time)
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: AdminService.getFeedbackStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load feedback',
                      style: GoogleFonts.poppins(color: Mycolors.red),
                    ),
                  );
                }
                List<Map<String, dynamic>> feedback = (snapshot.data ?? []).map(
                  (f) {
                    return {
                      ...f,
                      'userName': f['userName'] ?? f['userDisplayName'] ?? '',
                      'driverName':
                          f['driverName'] ?? f['driverDisplayName'] ?? '',
                      'rating': (f['rating'] is num)
                          ? (f['rating'] as num).toDouble()
                          : 0.0,
                      'comment': f['comment'] ?? '',
                      'status': (f['status'] ?? 'Published'),
                      'date': f['createdAt'],
                    };
                  },
                ).toList();

                // Search filter
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  feedback = feedback.where((item) {
                    return (item['userName'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(q) ||
                        (item['driverName'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(q) ||
                        (item['comment'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(q);
                  }).toList();
                }

                // Chip filters
                if (_selectedFilter == "High Rating") {
                  feedback = feedback
                      .where((item) => (item['rating'] ?? 0.0) >= 4.0)
                      .toList();
                } else if (_selectedFilter == "Low Rating") {
                  feedback = feedback
                      .where((item) => (item['rating'] ?? 0.0) < 3.0)
                      .toList();
                } else if (_selectedFilter == "Under Review") {
                  feedback = feedback
                      .where((item) => item['status'] == 'Under Review')
                      .toList();
                } else if (_selectedFilter == "Hidden") {
                  feedback = feedback
                      .where((item) => item['status'] == 'Hidden')
                      .toList();
                }

                if (feedback.isEmpty) {
                  return Center(
                    child: Text(
                      'No feedback found',
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: feedback.length,
                  itemBuilder: (context, index) {
                    final item = feedback[index];
                    return _buildFeedbackCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Mycolors.basecolor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Mycolors.basecolor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    Color ratingColor = _getRatingColor(feedback['rating']);
    Color statusColor = _getStatusColor(feedback['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with rating and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: ratingColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "${feedback['rating']}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ratingColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: index < feedback['rating']
                          ? Colors.orange
                          : Colors.grey.shade300,
                      size: 16,
                    );
                  }),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  feedback['status'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Comment
          Text(
            feedback['comment'],
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),

          const SizedBox(height: 12),

          // User and Driver info
          Row(
            children: [
              Icon(Icons.person, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                "User: ${feedback['userName']}",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Icon(Icons.drive_eta, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                "Driver: ${feedback['driverName']}",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Date and category
          Row(
            children: [
              Icon(Icons.calendar_today, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                _formatDate(feedback['date']),
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Icon(Icons.category, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              // category may be absent in firestore; show rating instead
              Text(
                "Rating",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showFeedbackDetails(feedback),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: Text(
                    "View Details",
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Mycolors.basecolor,
                    side: BorderSide(color: Mycolors.basecolor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (feedback['status'] == 'Under Review')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showModerationDialog(feedback),
                    icon: const Icon(Icons.admin_panel_settings, size: 16),
                    label: Text(
                      "Moderate",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFeedbackDetails(Map<String, dynamic> feedback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Feedback Details",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rating
                Row(
                  children: [
                    Text(
                      "Rating: ",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        color: index < feedback['rating']
                            ? Colors.orange
                            : Colors.grey.shade300,
                        size: 20,
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      "${feedback['rating']}/5",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Comment
                Text(
                  "Comment:",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Mycolors.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    feedback['comment'],
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),

                _buildDetailRow("User", feedback['userName']),
                _buildDetailRow("User Email", feedback['userEmail']),
                _buildDetailRow("Driver", feedback['driverName']),
                _buildDetailRow("Driver Email", feedback['driverEmail']),
                _buildDetailRow("Ride ID", feedback['rideId']),
                _buildDetailRow("Category", feedback['category']),
                _buildDetailRow("Status", feedback['status']),
                _buildDetailRow(
                  "Date",
                  "${feedback['date']} ${feedback['time']}",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            if (feedback['status'] == 'Under Review')
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showModerationDialog(feedback);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text("Moderate", style: GoogleFonts.poppins()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  void _showModerationDialog(Map<String, dynamic> feedback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Moderate Feedback",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "How would you like to handle this feedback?",
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _moderateFeedback(feedback['id'], 'Published'),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text("Publish", style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _moderateFeedback(feedback['id'], 'Hidden'),
                      icon: const Icon(Icons.visibility_off, size: 18),
                      label: Text("Hide", style: GoogleFonts.poppins()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _moderateFeedback(String feedbackId, String status) async {
    Navigator.of(context).pop();

    final result = await AdminService.updateFeedbackStatus(feedbackId, status);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? 'Feedback status updated successfully'
                : result['error'],
          ),
          backgroundColor: result['success'] == true
              ? Mycolors.green
              : Mycolors.red,
        ),
      );
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Mycolors.green;
    if (rating >= 3.0) return Mycolors.orange;
    return Mycolors.red;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Published':
        return Mycolors.green;
      case 'Under Review':
        return Mycolors.orange;
      case 'Hidden':
        return Mycolors.red;
      default:
        return Mycolors.gray;
    }
  }

  String _formatDate(dynamic createdAt) {
    try {
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      }
      return createdAt?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}
