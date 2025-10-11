import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/user_management_screen.dart';
import 'package:relygo/screens/driver_management_screen.dart';
import 'package:relygo/screens/admin_profile_screen.dart';
import 'package:relygo/screens/complaint_management_screen.dart';
import 'package:relygo/screens/feedback_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time data
  int _totalUsers = 0;
  int _activeDrivers = 0;
  int _pendingApprovals = 0;
  int _openComplaints = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Get total users
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      int totalUsers = usersSnapshot.docs.length;

      // Get active drivers (approved)
      QuerySnapshot driversSnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'driver')
          .where('status', isEqualTo: 'approved')
          .get();
      int activeDrivers = driversSnapshot.docs.length;

      // Get pending approvals
      QuerySnapshot pendingSnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'driver')
          .where('status', isEqualTo: 'pending')
          .get();
      int pendingApprovals = pendingSnapshot.docs.length;

      // Get open complaints (if you have a complaints collection)
      QuerySnapshot complaintsSnapshot = await _firestore
          .collection('complaints')
          .where('status', isEqualTo: 'open')
          .get();
      int openComplaints = complaintsSnapshot.docs.length;

      setState(() {
        _totalUsers = totalUsers;
        _activeDrivers = activeDrivers;
        _pendingApprovals = pendingApprovals;
        _openComplaints = openComplaints;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildUsersTab(),
            _buildDriversTab(),
            _buildAnalyticsTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.dashboard, "Dashboard", 0),
            _buildNavItem(Icons.people, "Users", 1),
            _buildNavItem(Icons.drive_eta, "Drivers", 2),
            _buildNavItem(Icons.analytics, "Analytics", 3),
            _buildNavItem(Icons.person, "Profile", 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Dashboard",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Manage your platform efficiently",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Mycolors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: Mycolors.orange.withOpacity(0.1),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Mycolors.orange,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Stats Overview
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  _totalUsers.toString(),
                  "Total Users",
                  Icons.people,
                  Mycolors.basecolor,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  _activeDrivers.toString(),
                  "Active Drivers",
                  Icons.drive_eta,
                  Mycolors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  _pendingApprovals.toString(),
                  "Pending Approvals",
                  Icons.pending,
                  Mycolors.orange,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  _openComplaints.toString(),
                  "Open Complaints",
                  Icons.report,
                  Mycolors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Quick Actions
          Text(
            "Quick Actions",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  "Manage Users",
                  Icons.people,
                  Mycolors.basecolor,
                  () {
                    setState(() {
                      _selectedIndex = 1; // Switch to users tab
                    });
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionCard(
                  "Manage Drivers",
                  Icons.drive_eta,
                  Mycolors.orange,
                  () {
                    setState(() {
                      _selectedIndex = 2; // Switch to drivers tab
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  "View Analytics",
                  Icons.analytics,
                  Mycolors.green,
                  () {
                    setState(() {
                      _selectedIndex = 3; // Switch to analytics tab
                    });
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionCard(
                  "Complaints",
                  Icons.report,
                  Mycolors.red,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ComplaintManagementScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Recent Activity
          Text(
            "Recent Activity",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),

          _buildActivityCard(
            "New Driver Registration",
            "John Smith completed registration",
            "2 minutes ago",
            Mycolors.green,
            Icons.person_add,
          ),
          const SizedBox(height: 10),
          _buildActivityCard(
            "Ride Completed",
            "Airport to Downtown - ₹180",
            "5 minutes ago",
            Mycolors.basecolor,
            Icons.check_circle,
          ),
          const SizedBox(height: 10),
          _buildActivityCard(
            "User Complaint",
            "Sarah Johnson reported an issue",
            "15 minutes ago",
            Mycolors.red,
            Icons.report,
          ),
          const SizedBox(height: 10),
          _buildActivityCard(
            "Payment Processed",
            "Driver withdrawal - ₹2,500",
            "1 hour ago",
            Mycolors.orange,
            Icons.payment,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return const UserManagementScreen();
  }

  Widget _buildDriversTab() {
    return const DriverManagementScreen();
  }

  Widget _buildAnalyticsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Analytics & Feedback",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  "View Feedback",
                  Icons.star,
                  Mycolors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbackScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionCard(
                  "View Analytics",
                  Icons.analytics,
                  Mycolors.green,
                  () {
                    // Show analytics cards
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Analytics Cards
          Expanded(
            child: ListView(
              children: [
                _buildAnalyticsCard(
                  "Ride Statistics",
                  "Total Rides: 2,850\nCompleted: 2,750\nCancelled: 100",
                  Icons.directions_car,
                  Mycolors.basecolor,
                ),
                const SizedBox(height: 15),
                _buildAnalyticsCard(
                  "Revenue Analysis",
                  "Today: ₹15,000\nThis Week: ₹1,05,000\nThis Month: ₹4,20,000",
                  Icons.attach_money,
                  Mycolors.green,
                ),
                const SizedBox(height: 15),
                _buildAnalyticsCard(
                  "User Growth",
                  "New Users Today: 25\nActive Users: 1,200\nTotal Users: 1,250",
                  Icons.people,
                  Mycolors.orange,
                ),
                const SizedBox(height: 15),
                _buildAnalyticsCard(
                  "Driver Performance",
                  "Average Rating: 4.6\nActive Drivers: 450\nOnline Now: 120",
                  Icons.star,
                  Mycolors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return const AdminProfileScreen();
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String description,
    String time,
    Color color,
    IconData icon,
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
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Mycolors.gray,
                  ),
                ),
                Text(
                  time,
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

  Widget _buildAnalyticsCard(
    String title,
    String data,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            data,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Mycolors.gray,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Mycolors.orange : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isSelected ? Mycolors.orange : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
