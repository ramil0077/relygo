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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            onPressed: () {
              _showAddUserDialog();
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
                    hintText: "Search users...",
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
                    _buildFilterChip("Active", "Active"),
                    const SizedBox(width: 10),
                    _buildFilterChip("Inactive", "Inactive"),
                    const SizedBox(width: 10),
                    _buildFilterChip("Blocked", "Blocked"),
                  ],
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildUserCard(
                  "Sarah Johnson",
                  "sarah.johnson@email.com",
                  "+91 98765 43210",
                  "Active",
                  Mycolors.green,
                  "2 days ago",
                  "Premium",
                ),
                _buildUserCard(
                  "Mike Wilson",
                  "mike.wilson@email.com",
                  "+91 87654 32109",
                  "Active",
                  Mycolors.green,
                  "1 week ago",
                  "Standard",
                ),
                _buildUserCard(
                  "Emma Davis",
                  "emma.davis@email.com",
                  "+91 76543 21098",
                  "Inactive",
                  Mycolors.orange,
                  "2 weeks ago",
                  "Standard",
                ),
                _buildUserCard(
                  "John Smith",
                  "john.smith@email.com",
                  "+91 65432 10987",
                  "Blocked",
                  Mycolors.red,
                  "1 month ago",
                  "Premium",
                ),
                _buildUserCard(
                  "Lisa Brown",
                  "lisa.brown@email.com",
                  "+91 54321 09876",
                  "Active",
                  Mycolors.green,
                  "3 days ago",
                  "Standard",
                ),
                _buildUserCard(
                  "David Lee",
                  "david.lee@email.com",
                  "+91 43210 98765",
                  "Active",
                  Mycolors.green,
                  "5 days ago",
                  "Premium",
                ),
                _buildUserCard(
                  "Anna Taylor",
                  "anna.taylor@email.com",
                  "+91 32109 87654",
                  "Inactive",
                  Mycolors.orange,
                  "1 week ago",
                  "Standard",
                ),
                _buildUserCard(
                  "Chris Anderson",
                  "chris.anderson@email.com",
                  "+91 21098 76543",
                  "Active",
                  Mycolors.green,
                  "1 day ago",
                  "Standard",
                ),
              ],
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

  Widget _buildUserCard(
    String name,
    String email,
    String phone,
    String status,
    Color statusColor,
    String lastActive,
    String membership,
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
                      _handleUserAction(value, name);
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
                      PopupMenuItem(
                        value: status == "Blocked" ? "unblock" : "block",
                        child: Row(
                          children: [
                            Icon(
                              status == "Blocked"
                                  ? Icons.check_circle
                                  : Icons.block,
                              color: status == "Blocked"
                                  ? Mycolors.green
                                  : Mycolors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status == "Blocked" ? "Unblock" : "Block",
                              style: GoogleFonts.poppins(),
                            ),
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

          // User Details
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
            children: [
              Icon(Icons.card_membership, color: Mycolors.gray, size: 16),
              const SizedBox(width: 8),
              Text(
                "Membership: $membership",
                style: GoogleFonts.poppins(fontSize: 14, color: Mycolors.gray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleUserAction(String action, String userName) {
    switch (action) {
      case "view":
        _showUserDetailsDialog(userName);
        break;
      case "edit":
        _showEditUserDialog(userName);
        break;
      case "block":
        _showBlockUserDialog(userName);
        break;
      case "unblock":
        _showUnblockUserDialog(userName);
        break;
      case "delete":
        _showDeleteUserDialog(userName);
        break;
    }
  }

  void _showUserDetailsDialog(String userName) {
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
              Text("Name: $userName", style: GoogleFonts.poppins()),
              Text(
                "Email: $userName.toLowerCase().replaceAll(' ', '.')@email.com",
                style: GoogleFonts.poppins(),
              ),
              Text("Phone: +91 98765 43210", style: GoogleFonts.poppins()),
              Text("Status: Active", style: GoogleFonts.poppins()),
              Text("Member Since: January 2024", style: GoogleFonts.poppins()),
              Text("Total Rides: 25", style: GoogleFonts.poppins()),
              Text("Rating: 4.8 ⭐", style: GoogleFonts.poppins()),
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

  void _showEditUserDialog(String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Edit User",
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
                controller: TextEditingController(text: userName),
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
                      "$userName.toLowerCase().replaceAll(' ', '.')@email.com",
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
                    content: Text('$userName updated successfully!'),
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

  void _showBlockUserDialog(String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Block User",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to block $userName?",
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$userName has been blocked'),
                    backgroundColor: Mycolors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Block", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showUnblockUserDialog(String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Unblock User",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to unblock $userName?",
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$userName has been unblocked'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.green,
                foregroundColor: Colors.white,
              ),
              child: Text("Unblock", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteUserDialog(String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete User",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to permanently delete $userName? This action cannot be undone.",
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$userName has been deleted'),
                    backgroundColor: Mycolors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Delete", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Add New User",
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
                    content: Text('New user added successfully!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Add User", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}
