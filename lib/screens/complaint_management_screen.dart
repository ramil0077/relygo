import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

class ComplaintManagementScreen extends StatefulWidget {
  const ComplaintManagementScreen({super.key});

  @override
  State<ComplaintManagementScreen> createState() =>
      _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState extends State<ComplaintManagementScreen> {
  String _selectedFilter = "All";
  String _searchQuery = "";

  // Mock data for complaints
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': '1',
      'title': 'Driver was rude and unprofessional',
      'description':
          'The driver was very rude and used inappropriate language during the ride. He also took a longer route to increase the fare.',
      'userName': 'Sarah Johnson',
      'userEmail': 'sarah@example.com',
      'driverName': 'Mike Wilson',
      'driverEmail': 'mike@example.com',
      'rideId': 'RIDE001',
      'status': 'Open',
      'priority': 'High',
      'category': 'Driver Behavior',
      'date': '2024-02-15',
      'time': '14:30',
      'response': '',
      'adminResponse': '',
    },
    {
      'id': '2',
      'title': 'Vehicle was not clean',
      'description':
          'The car was dirty and had a bad smell. The seats were stained and uncomfortable.',
      'userName': 'John Smith',
      'userEmail': 'john@example.com',
      'driverName': 'David Lee',
      'driverEmail': 'david@example.com',
      'rideId': 'RIDE002',
      'status': 'In Progress',
      'priority': 'Medium',
      'category': 'Vehicle Condition',
      'date': '2024-02-14',
      'time': '09:15',
      'response':
          'We apologize for the inconvenience. We will investigate this matter.',
      'adminResponse': 'Contacted driver for vehicle inspection.',
    },
    {
      'id': '3',
      'title': 'App crashed during booking',
      'description':
          'The app keeps crashing when I try to book a ride. This has happened multiple times.',
      'userName': 'Emma Davis',
      'userEmail': 'emma@example.com',
      'driverName': '',
      'driverEmail': '',
      'rideId': '',
      'status': 'Resolved',
      'priority': 'High',
      'category': 'Technical Issue',
      'date': '2024-02-13',
      'time': '16:45',
      'response':
          'We have identified and fixed the issue. Please update your app to the latest version.',
      'adminResponse': 'Issue resolved in app update v2.1.3',
    },
    {
      'id': '4',
      'title': 'Driver took wrong route',
      'description':
          'The driver ignored my request to take the highway and took a longer route through city traffic.',
      'userName': 'Lisa Brown',
      'userEmail': 'lisa@example.com',
      'driverName': 'Robert Taylor',
      'driverEmail': 'robert@example.com',
      'rideId': 'RIDE003',
      'status': 'Open',
      'priority': 'Medium',
      'category': 'Route Issue',
      'date': '2024-02-12',
      'time': '11:20',
      'response': '',
      'adminResponse': '',
    },
    {
      'id': '5',
      'title': 'Payment issue - charged twice',
      'description':
          'I was charged twice for the same ride. The first payment was successful but the app charged me again.',
      'userName': 'Maria Garcia',
      'userEmail': 'maria@example.com',
      'driverName': 'Alex Johnson',
      'driverEmail': 'alex@example.com',
      'rideId': 'RIDE004',
      'status': 'Resolved',
      'priority': 'High',
      'category': 'Payment Issue',
      'date': '2024-02-11',
      'time': '13:10',
      'response':
          'We have processed a refund for the duplicate charge. The amount will be credited to your account within 3-5 business days.',
      'adminResponse': 'Refund processed - Transaction ID: REF123456',
    },
  ];

  List<Map<String, dynamic>> get _filteredComplaints {
    List<Map<String, dynamic>> complaints = [..._complaints];

    if (_searchQuery.isNotEmpty) {
      complaints = complaints
          .where(
            (complaint) =>
                complaint['title'].toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                complaint['userName'].toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                complaint['category'].toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    if (_selectedFilter == "Open") {
      complaints = complaints
          .where((complaint) => complaint['status'] == 'Open')
          .toList();
    } else if (_selectedFilter == "In Progress") {
      complaints = complaints
          .where((complaint) => complaint['status'] == 'In Progress')
          .toList();
    } else if (_selectedFilter == "Resolved") {
      complaints = complaints
          .where((complaint) => complaint['status'] == 'Resolved')
          .toList();
    } else if (_selectedFilter == "High Priority") {
      complaints = complaints
          .where((complaint) => complaint['priority'] == 'High')
          .toList();
    }

    return complaints;
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
          "Complaint Management",
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
                    hintText: "Search complaints...",
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
                      _buildFilterChip("Open", "Open"),
                      const SizedBox(width: 10),
                      _buildFilterChip("In Progress", "In Progress"),
                      const SizedBox(width: 10),
                      _buildFilterChip("Resolved", "Resolved"),
                      const SizedBox(width: 10),
                      _buildFilterChip("High Priority", "High Priority"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Complaints List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredComplaints.length,
              itemBuilder: (context, index) {
                final complaint = _filteredComplaints[index];
                return _buildComplaintCard(complaint);
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

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    Color statusColor = _getStatusColor(complaint['status']);
    Color priorityColor = _getPriorityColor(complaint['priority']);

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
          // Header with status and priority
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  complaint['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      complaint['status'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      complaint['priority'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            complaint['description'],
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // User and Driver info
          Row(
            children: [
              Icon(Icons.person, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                "User: ${complaint['userName']}",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
              if (complaint['driverName'].isNotEmpty) ...[
                const SizedBox(width: 16),
                Icon(Icons.drive_eta, color: Mycolors.gray, size: 16),
                const SizedBox(width: 8),
                Text(
                  "Driver: ${complaint['driverName']}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Date and category
          Row(
            children: [
              Icon(Icons.calendar_today, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                "${complaint['date']} ${complaint['time']}",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Icon(Icons.category, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                complaint['category'],
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
                  onPressed: () => _showComplaintDetails(complaint),
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
              if (complaint['status'] != 'Resolved')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showResponseDialog(complaint),
                    icon: const Icon(Icons.reply, size: 16),
                    label: Text(
                      "Respond",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.green,
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

  void _showComplaintDetails(Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Complaint Details",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow("Title", complaint['title']),
                _buildDetailRow("Description", complaint['description']),
                _buildDetailRow("User", complaint['userName']),
                _buildDetailRow("User Email", complaint['userEmail']),
                if (complaint['driverName'].isNotEmpty) ...[
                  _buildDetailRow("Driver", complaint['driverName']),
                  _buildDetailRow("Driver Email", complaint['driverEmail']),
                ],
                if (complaint['rideId'].isNotEmpty)
                  _buildDetailRow("Ride ID", complaint['rideId']),
                _buildDetailRow("Category", complaint['category']),
                _buildDetailRow("Priority", complaint['priority']),
                _buildDetailRow("Status", complaint['status']),
                _buildDetailRow(
                  "Date",
                  "${complaint['date']} ${complaint['time']}",
                ),
                if (complaint['response'].isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Response:",
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
                      complaint['response'],
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                ],
                if (complaint['adminResponse'].isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Admin Notes:",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Mycolors.basecolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      complaint['adminResponse'],
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                ],
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
            if (complaint['status'] != 'Resolved')
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showResponseDialog(complaint);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text("Respond", style: GoogleFonts.poppins()),
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

  void _showResponseDialog(Map<String, dynamic> complaint) {
    final responseController = TextEditingController();
    final adminNotesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Respond to Complaint",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: responseController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Response to User",
                  hintText: "Enter your response to the user...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: adminNotesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Admin Notes (Internal)",
                  hintText: "Internal notes for admin reference...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
            ElevatedButton(
              onPressed: () {
                setState(() {
                  complaint['response'] = responseController.text;
                  complaint['adminResponse'] = adminNotesController.text;
                  if (responseController.text.isNotEmpty) {
                    complaint['status'] = 'In Progress';
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Response sent successfully!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.green,
                foregroundColor: Colors.white,
              ),
              child: Text("Send Response", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Mycolors.red;
      case 'In Progress':
        return Mycolors.orange;
      case 'Resolved':
        return Mycolors.green;
      default:
        return Mycolors.gray;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Mycolors.red;
      case 'Medium':
        return Mycolors.orange;
      case 'Low':
        return Mycolors.green;
      default:
        return Mycolors.gray;
    }
  }
}
