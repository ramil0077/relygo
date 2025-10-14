import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
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
          onPressed: () async {
            await Navigator.maybePop(context);
          },
        ),
        title: Text(
          "User Management",
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
                    hintText: "Search users or drivers...",
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
                      _buildFilterChip("Users", "Users"),
                      const SizedBox(width: 10),
                      _buildFilterChip("Drivers", "Drivers"),
                      const SizedBox(width: 10),
                      _buildFilterChip("Pending", "Pending"),
                      const SizedBox(width: 10),
                      _buildFilterChip("Approved", "Approved"),
                      const SizedBox(width: 10),
                      _buildFilterChip("Suspended", "Suspended"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Users List (real-time)
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: AdminService.getAllUsersAndDriversStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load users',
                      style: GoogleFonts.poppins(color: Mycolors.red),
                    ),
                  );
                }

                List<Map<String, dynamic>> allUsers = snapshot.data ?? [];

                // Normalize keys expected by UI and flatten driver fields
                allUsers = allUsers.map((u) {
                  final Map<String, dynamic> docs =
                      (u['documents'] is Map<String, dynamic>)
                      ? (u['documents'] as Map<String, dynamic>)
                      : {};
                  return {
                    ...u,
                    'name': u['name'] ?? u['fullName'] ?? 'Unknown',
                    'email': u['email'] ?? '',
                    'phone': u['phone'] ?? u['phoneNumber'] ?? '',
                    'type':
                        (u['userType'] ?? '').toString().toLowerCase() ==
                            'driver'
                        ? 'Driver'
                        : 'User',
                    'status': _statusString(u['status']),
                    'joinDate': _formatDate(u['createdAt']),
                    'totalRides': u['totalRides'] ?? 0,
                    'rating': (u['rating'] is num)
                        ? (u['rating'] as num).toDouble()
                        : 0.0,
                    'vehicleType':
                        u['vehicleType'] ?? docs['vehicleType'] ?? '',
                    'vehicleNumber':
                        u['vehicleNumber'] ?? docs['vehicleNumber'] ?? '',
                    'licenseNumber':
                        u['licenseNumber'] ?? docs['licenseNumber'] ?? '',
                  };
                }).toList();

                // Search filter
                if (_searchQuery.isNotEmpty) {
                  allUsers = allUsers.where((user) {
                    final name = (user['name'] ?? '').toString().toLowerCase();
                    final email = (user['email'] ?? '')
                        .toString()
                        .toLowerCase();
                    final q = _searchQuery.toLowerCase();
                    return name.contains(q) || email.contains(q);
                  }).toList();
                }

                // Chip filters
                if (_selectedFilter == "Users") {
                  allUsers = allUsers
                      .where((user) => user['type'] == 'User')
                      .toList();
                } else if (_selectedFilter == "Drivers") {
                  allUsers = allUsers
                      .where((user) => user['type'] == 'Driver')
                      .toList();
                } else if (_selectedFilter == "Pending") {
                  allUsers = allUsers
                      .where((user) => user['status'] == 'Pending')
                      .toList();
                } else if (_selectedFilter == "Approved") {
                  allUsers = allUsers
                      .where(
                        (user) =>
                            user['status'] == 'Approved' ||
                            user['status'] == 'Active',
                      )
                      .toList();
                } else if (_selectedFilter == "Suspended") {
                  allUsers = allUsers
                      .where((user) => user['status'] == 'Suspended')
                      .toList();
                }

                if (allUsers.isEmpty) {
                  return Center(
                    child: Text(
                      'No records found',
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: allUsers.length,
                  itemBuilder: (context, index) {
                    final user = allUsers[index];
                    return _buildUserCard(user);
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

  Widget _buildUserCard(Map<String, dynamic> user) {
    Color statusColor = _getStatusColor(user['status']);
    IconData statusIcon = _getStatusIcon(user['status']);

    return GestureDetector(
      onTap: () => _showUserBottomSheet(user),
      child: Container(
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
            // Header with status and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                      child: Text(
                        user['name'][0],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Mycolors.basecolor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          user['email'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Mycolors.gray,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                      child: Icon(statusIcon, color: statusColor, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Minimal: other details moved to bottom sheet on tap
            // (phone, dates, vehicle, license, stats removed from inline view)
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Mycolors.basecolor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Mycolors.gray),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildUserMenuItems(Map<String, dynamic> user) {
    List<PopupMenuEntry<String>> items = [];

    if (user['type'] == 'Driver' && user['status'] == 'Pending') {
      items.addAll([
        PopupMenuItem(
          value: 'approve',
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Mycolors.green, size: 20),
              const SizedBox(width: 8),
              Text('Approve', style: GoogleFonts.poppins()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reject',
          child: Row(
            children: [
              Icon(Icons.cancel, color: Mycolors.red, size: 20),
              const SizedBox(width: 8),
              Text('Reject', style: GoogleFonts.poppins()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'view_docs',
          child: Row(
            children: [
              Icon(Icons.description, color: Mycolors.basecolor, size: 20),
              const SizedBox(width: 8),
              Text('View Documents', style: GoogleFonts.poppins()),
            ],
          ),
        ),
      ]);
    }

    if (user['status'] == 'Active' || user['status'] == 'Approved') {
      items.add(
        PopupMenuItem(
          value: 'suspend',
          child: Row(
            children: [
              Icon(Icons.pause_circle, color: Mycolors.orange, size: 20),
              const SizedBox(width: 8),
              Text('Suspend', style: GoogleFonts.poppins()),
            ],
          ),
        ),
      );
    }

    if (user['status'] == 'Suspended') {
      items.add(
        PopupMenuItem(
          value: 'activate',
          child: Row(
            children: [
              Icon(Icons.play_circle, color: Mycolors.green, size: 20),
              const SizedBox(width: 8),
              Text('Activate', style: GoogleFonts.poppins()),
            ],
          ),
        ),
      );
    }

    items.addAll([
      PopupMenuItem(
        value: 'view_details',
        child: Row(
          children: [
            Icon(Icons.info, color: Mycolors.basecolor, size: 20),
            const SizedBox(width: 8),
            Text('View Details', style: GoogleFonts.poppins()),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'view_reviews',
        child: Row(
          children: [
            Icon(Icons.reviews, color: Mycolors.orange, size: 20),
            const SizedBox(width: 8),
            Text('View Reviews', style: GoogleFonts.poppins()),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'contact',
        child: Row(
          children: [
            Icon(Icons.phone, color: Mycolors.basecolor, size: 20),
            const SizedBox(width: 8),
            Text('Contact', style: GoogleFonts.poppins()),
          ],
        ),
      ),
    ]);

    return items;
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'approve':
        _showApprovalDialog(user, true);
        break;
      case 'reject':
        _showApprovalDialog(user, false);
        break;
      case 'view_docs':
        _showDocumentViewer(user);
        break;
      case 'suspend':
        _showSuspendDialog(user);
        break;
      case 'activate':
        _showActivateDialog(user);
        break;
      case 'view_details':
        _showUserDetails(user);
        break;
      case 'view_reviews':
        _showReviews(user);
        break;
      case 'contact':
        _showContactDialog(user);
        break;
    }
  }

  String _statusString(dynamic raw) {
    final value = (raw ?? '').toString().toLowerCase();
    if (value == 'approved' || value == 'active') return 'Approved';
    if (value == 'pending') return 'Pending';
    if (value == 'rejected') return 'Rejected';
    if (value == 'suspended') return 'Suspended';
    return 'Active';
  }

  String _formatDate(dynamic ts) {
    try {
      if (ts is Timestamp) {
        final dt = ts.toDate();
        return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      }
      return ts?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  void _showReviews(Map<String, dynamic> user) {
    final isDriver = user['type'] == 'Driver';
    final id = user['id'] ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviews for ${user['name']}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: AdminService.getFeedbackStream(
                        userId: isDriver ? null : id,
                        driverId: isDriver ? id : null,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Failed to load reviews',
                              style: GoogleFonts.poppins(color: Mycolors.red),
                            ),
                          );
                        }
                        final items = snapshot.data ?? [];
                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              'No reviews yet',
                              style: GoogleFonts.poppins(color: Mycolors.gray),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final r = items[index];
                            final rating = (r['rating'] is num)
                                ? (r['rating'] as num).toDouble()
                                : 0.0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Mycolors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  r['comment'] ?? '',
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showApprovalDialog(Map<String, dynamic> user, bool approve) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            approve ? "Approve Driver" : "Reject Driver",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: approve
              ? Text(
                  "Are you sure you want to approve ${user['name']} as a driver?",
                  style: GoogleFonts.poppins(),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Provide a reason (optional):",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const ValueKey('reject_reason_field'),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Reason for rejection',
                      ),
                      onChanged: (v) {
                        // Temp store on user map for ease
                        user['__rejectReason'] = v;
                      },
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
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  if (approve) {
                    final res = await AdminService.approveDriver(user['id']);
                    if (res['success'] == true) {
                      setState(() {
                        user['status'] = 'Approved';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Driver approved successfully!'),
                          backgroundColor: Mycolors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res['error'] ?? 'Failed to approve'),
                          backgroundColor: Mycolors.red,
                        ),
                      );
                    }
                  } else {
                    final reason = (user['__rejectReason'] ?? 'Not specified')
                        .toString();
                    final res = await AdminService.rejectDriver(
                      user['id'],
                      reason,
                    );
                    if (res['success'] == true) {
                      setState(() {
                        user['status'] = 'Rejected';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Driver rejected'),
                          backgroundColor: Mycolors.red,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res['error'] ?? 'Failed to reject'),
                          backgroundColor: Mycolors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Action failed: $e'),
                      backgroundColor: Mycolors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: approve ? Mycolors.green : Mycolors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                approve ? "Approve" : "Reject",
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDocumentViewer(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Driver Documents",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Driver: ${user['name']}",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildDocumentItem("Driver License", "DL123456789", Icons.badge),
              _buildDocumentItem(
                "Vehicle Registration",
                "ABC123",
                Icons.directions_car,
              ),
              _buildDocumentItem(
                "Insurance Certificate",
                "INS789456",
                Icons.security,
              ),
              _buildDocumentItem(
                "Vehicle Type",
                user['vehicleType'],
                Icons.category,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Mycolors.basecolor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Mycolors.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Suspend User",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to suspend ${user['name']}?",
            style: GoogleFonts.poppins(),
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
                Navigator.of(context).pop();
                setState(() {
                  user['status'] = 'Suspended';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User suspended successfully!'),
                    backgroundColor: Mycolors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text("Suspend", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showActivateDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Activate User",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to activate ${user['name']}?",
            style: GoogleFonts.poppins(),
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
                Navigator.of(context).pop();
                setState(() {
                  user['status'] = user['type'] == 'Driver'
                      ? 'Approved'
                      : 'Active';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User activated successfully!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.green,
                foregroundColor: Colors.white,
              ),
              child: Text("Activate", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "User Details",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Name", user['name']),
              _buildDetailRow("Email", user['email']),
              _buildDetailRow("Phone", user['phone']),
              _buildDetailRow("Type", user['type']),
              _buildDetailRow("Status", user['status']),
              _buildDetailRow("Join Date", user['joinDate']),
              _buildDetailRow("Total Rides", "${user['totalRides']}"),
              _buildDetailRow("Rating", "${user['rating']} ⭐"),
              if (user['type'] == 'Driver') ...[
                _buildDetailRow("License", user['licenseNumber']),
                _buildDetailRow(
                  "Vehicle",
                  "${user['vehicleType']} - ${user['vehicleNumber']}",
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUserBottomSheet(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final docs = (user['documents'] is Map<String, dynamic>)
            ? (user['documents'] as Map<String, dynamic>)
            : {};
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                        child: Text(
                          (user['name'] ?? 'U')[0],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Mycolors.basecolor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? 'Unknown',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              user['email'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Mycolors.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            user['status'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user['status'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(user['status']),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow("Phone", user['phone'] ?? ''),
                  _buildDetailRow("Join Date", user['joinDate'] ?? ''),
                  _buildDetailRow("Type", user['type'] ?? ''),
                  if (user['type'] == 'Driver') ...[
                    _buildDetailRow(
                      "License",
                      (user['licenseNumber'] ?? '').toString(),
                    ),
                    _buildDetailRow(
                      "Vehicle",
                      "${user['vehicleType'] ?? ''} - ${user['vehicleNumber'] ?? ''}",
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Documents',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _buildDocTile('License', docs['license']),
                    _buildDocTile(
                      'Vehicle Registration',
                      docs['vehicleRegistration'],
                    ),
                    _buildDocTile('Insurance', docs['insurance']),
                  ],
                  const SizedBox(height: 16),
                  if (user['type'] == 'Driver' && user['status'] == 'Pending')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleUserAction('approve', user),
                            icon: const Icon(Icons.check_circle),
                            label: Text(
                              'Approve',
                              style: GoogleFonts.poppins(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Mycolors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleUserAction('reject', user),
                            icon: const Icon(Icons.cancel),
                            label: Text('Reject', style: GoogleFonts.poppins()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Mycolors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDocTile(String label, dynamic url) {
    final String value = (url ?? '').toString();
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.description, color: Mycolors.basecolor),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value.isEmpty ? 'Not uploaded' : value,
        style: GoogleFonts.poppins(fontSize: 12, color: Mycolors.gray),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: value.isEmpty ? null : () {},
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

  void _showContactDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Contact ${user['name']}",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone, color: Mycolors.green),
                title: Text("Call", style: GoogleFonts.poppins()),
                subtitle: Text(
                  user['phone'],
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${user['phone']}...'),
                      backgroundColor: Mycolors.green,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.email, color: Mycolors.basecolor),
                title: Text("Email", style: GoogleFonts.poppins()),
                subtitle: Text(
                  user['email'],
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening email client...'),
                      backgroundColor: Mycolors.basecolor,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
      case 'Approved':
        return Mycolors.green;
      case 'Pending':
        return Mycolors.orange;
      case 'Suspended':
        return Mycolors.red;
      case 'Rejected':
        return Mycolors.red;
      default:
        return Mycolors.gray;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Active':
      case 'Approved':
        return Icons.check_circle;
      case 'Pending':
        return Icons.pending;
      case 'Suspended':
        return Icons.pause_circle;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
