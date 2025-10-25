import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/admin_service.dart';

class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  String _selectedFilter = "All";
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Driver Management",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showAddDriverDialog();
            },
            icon: Icon(Icons.person_add, color: Mycolors.basecolor),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
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
                    hintText: "Search drivers...",
                    prefixIcon: Icon(Icons.search, color: Mycolors.basecolor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 15),

                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip("All", "All"),
                    const SizedBox(width: 10),
                    _buildFilterChip("Online", "Online"),
                    const SizedBox(width: 10),
                    _buildFilterChip("Offline", "Offline"),
                    const SizedBox(width: 10),
                    _buildFilterChip("Pending", "Pending"),
                  ],
                ),
              ],
            ),
          ),

          // Drivers List (real-time)
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: AdminService.getAllDriversStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load drivers',
                      style: GoogleFonts.poppins(color: Mycolors.red),
                    ),
                  );
                }
                List<Map<String, dynamic>> drivers = (snapshot.data ?? []).map((
                  d,
                ) {
                  return {
                    ...d,
                    'name': d['name'] ?? d['fullName'] ?? 'Unknown',
                    'email': d['email'] ?? '',
                    'phone': d['phone'] ?? d['phoneNumber'] ?? '',
                    'status': _statusString(d['status']),
                    'rating': (d['rating'] is num)
                        ? (d['rating'] as num).toDouble()
                        : 0.0,
                    'vehicleType': d['vehicleType'] ?? '',
                  };
                }).toList();

                // Text search
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  drivers = drivers.where((u) {
                    return (u['name'] ?? '').toString().toLowerCase().contains(
                          q,
                        ) ||
                        (u['email'] ?? '').toString().toLowerCase().contains(q);
                  }).toList();
                }

                // Status filter
                if (_selectedFilter != 'All') {
                  drivers = drivers
                      .where((u) => u['status'] == _selectedFilter)
                      .toList();
                }

                if (drivers.isEmpty) {
                  return Center(
                    child: Text(
                      'No drivers found',
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final d = drivers[index];
                    final statusColor = _statusColor(d['status']);
                    return _buildDriverCard(
                      d['name'] ?? '',
                      d['email'] ?? '',
                      d['phone'] ?? '',
                      d['status'] ?? 'Pending',
                      statusColor,
                      (d['rating'] ?? 0.0).toString(),
                      d['vehicleType'] ?? '',
                      '',
                      '',
                      d['id'] ?? '',
                    );
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

  Widget _buildDriverCard(
    String name,
    String email,
    String phone,
    String status,
    Color statusColor,
    String rating,
    String vehicleType,
    String lastActive,
    String earnings,
    String driverId,
  ) {
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
                      name[0],
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
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
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
                    child: Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      _handleDriverAction(value, name, driverId);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "view",
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Mycolors.basecolor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text("View Details", style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: "edit",
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Mycolors.orange, size: 18),
                            const SizedBox(width: 8),
                            Text("Edit", style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                      if (status == "Pending")
                        PopupMenuItem(
                          value: "approve",
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Mycolors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text("Approve", style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                      if (status == "Online")
                        PopupMenuItem(
                          value: "suspend",
                          child: Row(
                            children: [
                              Icon(
                                Icons.pause_circle,
                                color: Mycolors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text("Suspend", style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Mycolors.red, size: 18),
                            const SizedBox(width: 8),
                            Text("Delete", style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(Icons.more_vert, color: Mycolors.gray),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Driver Details
          Row(
            children: [
              Icon(Icons.phone, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                phone,
                style: GoogleFonts.poppins(fontSize: 14, color: Mycolors.gray),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.star, color: Mycolors.orange, size: 16),
              const SizedBox(width: 8),
              Text(
                "Rating: $rating ⭐",
                style: GoogleFonts.poppins(fontSize: 14, color: Mycolors.gray),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.directions_car, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                "Vehicle: $vehicleType",
                style: GoogleFonts.poppins(fontSize: 14, color: Mycolors.gray),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.access_time, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                "Last active: $lastActive",
                style: GoogleFonts.poppins(fontSize: 14, color: Mycolors.gray),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money, color: Mycolors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Earnings: $earnings",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Mycolors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Online':
        return Mycolors.green;
      case 'Offline':
        return Mycolors.orange;
      case 'Pending':
        return Mycolors.red;
      case 'Approved':
        return Mycolors.green;
      default:
        return Mycolors.gray;
    }
  }

  String _statusString(dynamic raw) {
    final v = (raw ?? '').toString().toLowerCase();
    if (v == 'approved' || v == 'active') return 'Approved';
    if (v == 'pending') return 'Pending';
    if (v == 'online') return 'Online';
    if (v == 'offline') return 'Offline';
    if (v == 'suspended') return 'Pending';
    return 'Pending';
  }

  void _handleDriverAction(String action, String driverName, String driverId) {
    switch (action) {
      case "view":
        _showDriverDetailsDialog(driverName);
        break;
      case "edit":
        _showEditDriverDialog(driverName);
        break;
      case "approve":
        _approveDriver(driverId, driverName);
        break;
      case "suspend":
        _suspendDriver(driverId, driverName);
        break;
      case "delete":
        _deleteDriver(driverId, driverName);
        break;
    }
  }

  void _showDriverDetailsDialog(String driverName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Driver Details",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: $driverName", style: GoogleFonts.poppins()),
              Text(
                "Email: $driverName.toLowerCase().replaceAll(' ', '.')@email.com",
                style: GoogleFonts.poppins(),
              ),
              Text("Phone: +91 98765 43210", style: GoogleFonts.poppins()),
              Text("Status: Online", style: GoogleFonts.poppins()),
              Text("Vehicle: Car", style: GoogleFonts.poppins()),
              Text("License: DL123456789", style: GoogleFonts.poppins()),
              Text("Rating: 4.8 ⭐", style: GoogleFonts.poppins()),
              Text("Total Rides: 150", style: GoogleFonts.poppins()),
              Text("Total Earnings: ₹45,000", style: GoogleFonts.poppins()),
              Text("Joined: January 2024", style: GoogleFonts.poppins()),
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

  void _showEditDriverDialog(String driverName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Edit Driver",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: TextEditingController(text: driverName),
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: TextEditingController(
                  text:
                      "$driverName.toLowerCase().replaceAll(' ', '.')@email.com",
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: TextEditingController(text: "+91 98765 43210"),
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
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$driverName updated successfully!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Save", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _approveDriver(String driverId, String driverName) async {
    final result = await AdminService.approveDriver(driverId);

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
    }
  }

  Future<void> _suspendDriver(String driverId, String driverName) async {
    final result = await AdminService.suspendDriver(driverId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? 'Driver suspended successfully'
                : result['error'],
          ),
          backgroundColor: result['success'] == true
              ? Mycolors.orange
              : Mycolors.red,
        ),
      );
    }
  }

  Future<void> _deleteDriver(String driverId, String driverName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Delete Driver",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to permanently delete $driverName? This action cannot be undone.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors.red,
              foregroundColor: Colors.white,
            ),
            child: Text("Delete", style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await AdminService.deleteDriver(driverId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true
                  ? 'Driver deleted successfully'
                  : result['error'],
            ),
            backgroundColor: result['success'] == true
                ? Mycolors.red
                : Mycolors.red,
          ),
        );
      }
    }
  }

  void _showAddDriverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Add New Driver",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Vehicle Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ["Car", "Bike", "Auto"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
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
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('New driver added successfully!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Add Driver", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}
