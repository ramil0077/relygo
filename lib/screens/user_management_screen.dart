import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedFilter = "All";
  String _searchQuery = "";

  // Mock data for users
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'John Smith',
      'email': 'john@example.com',
      'phone': '+1234567890',
      'type': 'User',
      'status': 'Active',
      'joinDate': '2024-01-15',
      'totalRides': 25,
      'rating': 4.8,
    },
    {
      'id': '2',
      'name': 'Sarah Johnson',
      'email': 'sarah@example.com',
      'phone': '+1234567891',
      'type': 'User',
      'status': 'Active',
      'joinDate': '2024-01-20',
      'totalRides': 18,
      'rating': 4.9,
    },
    {
      'id': '3',
      'name': 'Mike Wilson',
      'email': 'mike@example.com',
      'phone': '+1234567892',
      'type': 'User',
      'status': 'Suspended',
      'joinDate': '2024-01-10',
      'totalRides': 5,
      'rating': 3.2,
    },
    {
      'id': '4',
      'name': 'Emma Davis',
      'email': 'emma@example.com',
      'phone': '+1234567893',
      'type': 'User',
      'status': 'Active',
      'joinDate': '2024-02-01',
      'totalRides': 32,
      'rating': 4.7,
    },
  ];

  // Mock data for drivers
  final List<Map<String, dynamic>> _drivers = [
    {
      'id': '1',
      'name': 'David Lee',
      'email': 'david@example.com',
      'phone': '+1234567894',
      'type': 'Driver',
      'status': 'Approved',
      'joinDate': '2024-01-05',
      'totalRides': 150,
      'rating': 4.9,
      'licenseNumber': 'DL123456789',
      'vehicleNumber': 'ABC123',
      'vehicleType': 'Sedan',
    },
    {
      'id': '2',
      'name': 'Lisa Brown',
      'email': 'lisa@example.com',
      'phone': '+1234567895',
      'type': 'Driver',
      'status': 'Pending',
      'joinDate': '2024-02-10',
      'totalRides': 0,
      'rating': 0.0,
      'licenseNumber': 'DL987654321',
      'vehicleNumber': 'XYZ789',
      'vehicleType': 'SUV',
    },
    {
      'id': '3',
      'name': 'Robert Taylor',
      'email': 'robert@example.com',
      'phone': '+1234567896',
      'type': 'Driver',
      'status': 'Rejected',
      'joinDate': '2024-01-25',
      'totalRides': 0,
      'rating': 0.0,
      'licenseNumber': 'DL456789123',
      'vehicleNumber': 'DEF456',
      'vehicleType': 'Hatchback',
    },
    {
      'id': '4',
      'name': 'Maria Garcia',
      'email': 'maria@example.com',
      'phone': '+1234567897',
      'type': 'Driver',
      'status': 'Approved',
      'joinDate': '2024-01-12',
      'totalRides': 200,
      'rating': 4.8,
      'licenseNumber': 'DL789123456',
      'vehicleNumber': 'GHI789',
      'vehicleType': 'Sedan',
    },
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    List<Map<String, dynamic>> allUsers = [..._users, ..._drivers];

    if (_searchQuery.isNotEmpty) {
      allUsers = allUsers
          .where(
            (user) =>
                user['name'].toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                user['email'].toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    if (_selectedFilter == "Users") {
      allUsers = allUsers.where((user) => user['type'] == 'User').toList();
    } else if (_selectedFilter == "Drivers") {
      allUsers = allUsers.where((user) => user['type'] == 'Driver').toList();
    } else if (_selectedFilter == "Pending") {
      allUsers = allUsers.where((user) => user['status'] == 'Pending').toList();
    } else if (_selectedFilter == "Approved") {
      allUsers = allUsers
          .where((user) => user['status'] == 'Approved')
          .toList();
    } else if (_selectedFilter == "Suspended") {
      allUsers = allUsers
          .where((user) => user['status'] == 'Suspended')
          .toList();
    }

    return allUsers;
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

          // Users List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return _buildUserCard(user);
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          user['status'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleUserAction(value, user),
                    itemBuilder: (context) => _buildUserMenuItems(user),
                    child: Icon(Icons.more_vert, color: Mycolors.gray),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // User details
          Row(
            children: [
              Icon(Icons.phone, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                user['phone'],
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(width: 20),
              Icon(Icons.calendar_today, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                user['joinDate'],
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),

          if (user['type'] == 'Driver') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.directions_car, color: Mycolors.gray, size: 16),
                const SizedBox(width: 8),
                Text(
                  "${user['vehicleType']} - ${user['vehicleNumber']}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 20),
                Icon(Icons.badge, color: Mycolors.gray, size: 16),
                const SizedBox(width: 8),
                Text(
                  user['licenseNumber'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Rides", "${user['totalRides']}"),
              _buildStatItem("Rating", "${user['rating']} ⭐"),
              if (user['type'] == 'Driver')
                _buildStatItem("Type", user['type']),
            ],
          ),
        ],
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
      case 'contact':
        _showContactDialog(user);
        break;
    }
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
          content: Text(
            approve
                ? "Are you sure you want to approve ${user['name']} as a driver?"
                : "Are you sure you want to reject ${user['name']}'s driver application?",
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
                  user['status'] = approve ? 'Approved' : 'Rejected';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      approve
                          ? 'Driver approved successfully!'
                          : 'Driver rejected',
                    ),
                    backgroundColor: approve ? Mycolors.green : Mycolors.red,
                  ),
                );
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
