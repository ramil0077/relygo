import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/utils/responsive.dart';

import 'package:relygo/screens/driver_management_screen.dart';
import 'package:relygo/screens/admin_complaints_screen.dart';
import 'package:relygo/screens/feedback_screen.dart';
import 'package:relygo/screens/admin_driver_approval_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/screens/admin_user_details_screen.dart';
import 'package:relygo/screens/admin_driver_chat_screen.dart';
import 'package:relygo/screens/admin_driver_details_screen.dart';
import 'package:relygo/screens/admin_analytics_screen.dart';
import 'package:relygo/services/admin_service.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/screens/admin_landing_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  int _userDriverTabIndex = 0; // 0 for users, 1 for drivers
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time data
  int _totalUsers = 0;
  int _activeDrivers = 0;
  int _pendingApprovals = 0;
  int _openComplaints = 0;
  StreamSubscription? _usersSub;
  StreamSubscription? _approvedDriversSub;
  StreamSubscription? _pendingDriversSub;
  StreamSubscription? _complaintsSub;

  // Booking filters
  String _selectedBookingFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startRealtimeStats();
  }

  void _startRealtimeStats() {
    // Total users
    _usersSub = _firestore.collection('users').snapshots().listen((snap) {
      setState(() => _totalUsers = snap.size);
    }, onError: (_) {});

    // Active (approved) drivers
    _approvedDriversSub = _firestore
        .collection('users')
        .where('userType', whereIn: ['driver', 'Driver'])
        .where('status', whereIn: ['approved', 'Approved'])
        .snapshots()
        .listen((snap) {
          setState(() => _activeDrivers = snap.size);
        }, onError: (_) {});

    // Pending approvals (pending)
    _pendingDriversSub = _firestore
        .collection('users')
        .where('userType', whereIn: ['driver', 'Driver'])
        .where('status', whereIn: ['pending', 'Pending'])
        .snapshots()
        .listen((snap) {
          setState(() => _pendingApprovals = snap.size);
        }, onError: (_) {});

    // Open complaints (optional collection)
    _complaintsSub = _firestore
        .collection('complaints')
        .where('status', whereIn: ['open', 'Open'])
        .snapshots()
        .listen((snap) {
          setState(() => _openComplaints = snap.size);
        }, onError: (_) {});
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _approvedDriversSub?.cancel();
    _pendingDriversSub?.cancel();
    _complaintsSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Mycolors.red, size: 24),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from the admin panel?',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Mycolors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Sign out from Firebase
      await AuthService.signOut();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to sign in screen
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminLandingPage()),
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error during logout: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Mycolors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            // Admin Sidebar Portal Navigation
            _buildSidebar(),
            // Main Content Area
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeTab(),
                  _buildUsersAndDriversTab(),
                  _buildBookingsTab(),
                  const AdminComplaintsScreen(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
          ),
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
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Manage your platform efficiently",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        color: Mycolors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Logout Button
                  GestureDetector(
                    onTap: _showLogoutDialog,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Mycolors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Mycolors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Mycolors.red,
                            size: ResponsiveUtils.getResponsiveIconSize(
                              context,
                              mobile: 18,
                              tablet: 20,
                              desktop: 22,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Logout",
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                tablet: 14,
                                desktop: 16,
                              ),
                              fontWeight: FontWeight.w600,
                              color: Mycolors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Admin Avatar
                  CircleAvatar(
                    radius: ResponsiveUtils.getResponsiveIconSize(
                      context,
                      mobile: 25,
                      tablet: 30,
                      desktop: 35,
                    ),
                    backgroundColor: Mycolors.orange.withOpacity(0.1),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Mycolors.orange,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 30,
                        tablet: 35,
                        desktop: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 30),
          ),

          // Stats Overview
          ResponsiveWidget(
            mobile: Column(
              children: [
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
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 15,
                      ),
                    ),
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
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 15,
                  ),
                ),
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
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 15,
                      ),
                    ),
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
              ],
            ),
            tablet: Column(
              children: [
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
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 15,
                      ),
                    ),
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
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 15,
                  ),
                ),
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
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 15,
                      ),
                    ),
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
              ],
            ),
            desktop: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    _totalUsers.toString(),
                    "Total Users",
                    Icons.people,
                    Mycolors.basecolor,
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 15,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    _activeDrivers.toString(),
                    "Active Drivers",
                    Icons.drive_eta,
                    Mycolors.green,
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 15,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    _pendingApprovals.toString(),
                    "Pending Approvals",
                    Icons.pending,
                    Mycolors.orange,
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 15,
                  ),
                ),
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
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 30),
          ),

          // Quick Actions
          Text(
            "Quick Actions",
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
          ),

          ResponsiveWidget(
            mobile: Column(
              children: [
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
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 15,
                      ),
                    ),
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
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 15,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        "View Analytics",
                        Icons.analytics,
                        Mycolors.green,
                        () {
                          setState(() {
                            _selectedIndex = 4; // Switch to analytics tab
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 15,
                      ),
                    ),
                    Expanded(
                      child: _buildActionCard(
                        "Complaints",
                        Icons.report,
                        Mycolors.red,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminComplaintsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            tablet: Column(
              children: [
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
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 15,
                      ),
                    ),
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
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 15,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        "View Analytics",
                        Icons.analytics,
                        Mycolors.green,
                        () {
                          setState(() {
                            _selectedIndex = 4; // Switch to analytics tab
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 15,
                      ),
                    ),
                    Expanded(
                      child: _buildActionCard(
                        "Complaints",
                        Icons.report,
                        Mycolors.red,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminComplaintsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            desktop: Row(
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
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 15,
                  ),
                ),
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
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 15,
                  ),
                ),
                Expanded(
                  child: _buildActionCard(
                    "View Analytics",
                    Icons.analytics,
                    Mycolors.green,
                    () {
                      setState(() {
                        _selectedIndex = 4; // Switch to analytics tab
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 15,
                  ),
                ),
                Expanded(
                  child: _buildActionCard(
                    "Complaints",
                    Icons.report,
                    Mycolors.red,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminComplaintsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 30),
          ),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Activity",
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2; // Go to bookings tab
                  });
                },
                child: Text(
                  "View All",
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                    color: Mycolors.basecolor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 15),
          ),

          // Real-time activity from multiple collections
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: AdminService.getRecentActivitiesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Mycolors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No recent activity',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Mycolors.gray,
                      ),
                    ),
                  ),
                );
              }

              final activities = snapshot.data ?? [];
              if (activities.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Mycolors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No recent activity',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Mycolors.gray,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: activities.map((data) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildActivityCardFromData(data),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersAndDriversTab() {
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
          ),
          Text(
            "Users & Drivers Management",
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
          ),

          // Tab Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _userDriverTabIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _userDriverTabIndex == 0
                            ? Mycolors.basecolor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Users',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _userDriverTabIndex == 0
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _userDriverTabIndex = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _userDriverTabIndex == 1
                            ? Mycolors.basecolor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Drivers',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _userDriverTabIndex == 1
                              ? Colors.white
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
          ),

          // Content based on selected tab
          Expanded(
            child: _userDriverTabIndex == 0
                ? _buildUsersContent()
                : _buildDriversContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersContent() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: AdminService.getAllAppUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading users',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize:
                  MainAxisSize.min, // Prevents bottom overflow on short screens
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No users found',
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
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserCard(user);
          },
        );
      },
    );
  }

  Widget _buildDriversContent() {
    return Column(
      children: [
        // Quick Actions
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                "Driver Approvals",
                Icons.approval,
                Mycolors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDriverApprovalScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionCard(
                "Manage Drivers",
                Icons.people,
                Mycolors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverManagementScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats
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
                _activeDrivers.toString(),
                "Active Drivers",
                Icons.drive_eta,
                Mycolors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Drivers List
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
                    'Error loading drivers',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              final drivers = snapshot.data ?? [];

              if (drivers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize
                        .min, // Prevents bottom overflow on short screens
                    children: [
                      Icon(Icons.drive_eta, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No drivers found',
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
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  return _buildDriverCard(driver);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsTab() {
    return ListView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      children: [
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
        ),
        Text(
          "Ride Management",
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
        ),

        // Booking Stats
        FutureBuilder<Map<String, dynamic>>(
          future: AdminService.getBookingStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = snapshot.data ?? {};
            return ResponsiveWidget(
              mobile: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          (stats['totalBookings'] ?? 0).toString(),
                          "Total Rides",
                          Icons.local_taxi,
                          Mycolors.basecolor,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 15,
                        ),
                      ),
                      Expanded(
                        child: _buildStatCard(
                          (stats['completedBookings'] ?? 0).toString(),
                          "Completed",
                          Icons.check_circle,
                          Mycolors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 15,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          (stats['ongoingBookings'] ?? 0).toString(),
                          "Ongoing",
                          Icons.directions_car,
                          Mycolors.blue,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 15,
                        ),
                      ),
                      Expanded(
                        child: _buildStatCard(
                          "₹${(stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)}",
                          "Revenue",
                          Icons.attach_money,
                          Mycolors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              tablet: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          (stats['totalBookings'] ?? 0).toString(),
                          "Total Rides",
                          Icons.local_taxi,
                          Mycolors.basecolor,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 15,
                        ),
                      ),
                      Expanded(
                        child: _buildStatCard(
                          (stats['completedBookings'] ?? 0).toString(),
                          "Completed",
                          Icons.check_circle,
                          Mycolors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 15,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          (stats['ongoingBookings'] ?? 0).toString(),
                          "Ongoing",
                          Icons.directions_car,
                          Mycolors.blue,
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 15,
                        ),
                      ),
                      Expanded(
                        child: _buildStatCard(
                          "₹${(stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)}",
                          "Revenue",
                          Icons.attach_money,
                          Mycolors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              desktop: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      (stats['totalBookings'] ?? 0).toString(),
                      "Total Rides",
                      Icons.local_taxi,
                      Mycolors.basecolor,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 15,
                    ),
                  ),
                  Expanded(
                    child: _buildStatCard(
                      (stats['completedBookings'] ?? 0).toString(),
                      "Completed",
                      Icons.check_circle,
                      Mycolors.green,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 15,
                    ),
                  ),
                  Expanded(
                    child: _buildStatCard(
                      (stats['ongoingBookings'] ?? 0).toString(),
                      "Ongoing",
                      Icons.directions_car,
                      Mycolors.blue,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 15,
                    ),
                  ),
                  Expanded(
                    child: _buildStatCard(
                      "₹${(stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)}",
                      "Revenue",
                      Icons.attach_money,
                      Mycolors.orange,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
        ),

        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by user name, driver name, or location...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  prefixIcon: Icon(Icons.search, color: Mycolors.gray),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Mycolors.gray),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Mycolors.basecolor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),

              // Filter Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Completed', 'completed'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Ongoing', 'ongoing'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pending', 'pending'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Cancelled', 'cancelled'),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
        ),

        // Bookings List
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _getFilteredBookingsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading bookings',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              );
            }

            final bookings = snapshot.data ?? [];

            if (bookings.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_taxi_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookings found',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _buildBookingCard(booking);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
          ),
          Text(
            "Analytics & Feedback",
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20),
          ),

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
                  "Service Report",
                  Icons.analytics,
                  Mycolors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminAnalyticsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Feedback Stream
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
                      'Error loading feedback',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                final feedbacks = snapshot.data ?? [];

                if (feedbacks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No feedback yet',
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
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = feedbacks[index];
                    return _buildFeedbackCard(feedback);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 30,
              tablet: 35,
              desktop: 40,
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 10),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
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
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(
                context,
                mobile: 30,
                tablet: 35,
                desktop: 40,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 10),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 16,
                  desktop: 18,
                ),
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

  Widget _buildActivityCardFromData(Map<String, dynamic> data) {
    String title = 'Activity';
    String description = '';
    String time = 'Just now';
    Color color = Mycolors.basecolor;
    IconData icon = Icons.info;

    final activityType = data['activityType'] ?? '';

    switch (activityType) {
      case 'booking':
        final status = data['status'] ?? '';
        final pickup = data['pickupLocation'] ?? 'Unknown';
        final dropoff = data['dropoffLocation'] ?? 'Unknown';
        final fare = data['fare'] ?? 0;

        if (status == 'completed') {
          title = 'Ride Completed';
          description = '$pickup to $dropoff - ₹$fare';
          color = Mycolors.green;
          icon = Icons.check_circle;
        } else if (status == 'cancelled') {
          title = 'Ride Cancelled';
          description = '$pickup to $dropoff';
          color = Mycolors.red;
          icon = Icons.cancel;
        } else if (status == 'ongoing') {
          title = 'Ride in Progress';
          description = '$pickup to $dropoff';
          color = Mycolors.blue;
          icon = Icons.directions_car;
        } else {
          title = 'New Booking';
          description = '$pickup to $dropoff';
          color = Mycolors.orange;
          icon = Icons.book_online;
        }
        break;

      case 'driver_registration':
        title = 'New Driver Registration';
        description = '${data['name'] ?? "Driver"} submitted application';
        color = Mycolors.green;
        icon = Icons.person_add;
        break;

      case 'complaint':
        title = 'New Complaint';
        description = data['subject'] ?? 'User reported an issue';
        color = Mycolors.red;
        icon = Icons.report;
        break;

      case 'feedback':
        title = 'New Feedback';
        final rating = data['rating'] ?? 0;
        description = '${data['userName'] ?? "User"} rated $rating stars';
        color = Mycolors.orange;
        icon = Icons.star;
        break;

      default:
        title = 'System Activity';
        description = 'Platform update';
        color = Mycolors.basecolor;
        icon = Icons.info;
    }

    // Calculate time ago
    if (data['createdAt'] != null) {
      try {
        final Timestamp timestamp = data['createdAt'];
        final DateTime dateTime = timestamp.toDate();
        final Duration difference = DateTime.now().difference(dateTime);

        if (difference.inMinutes < 1) {
          time = 'Just now';
        } else if (difference.inMinutes < 60) {
          time = '${difference.inMinutes} min ago';
        } else if (difference.inHours < 24) {
          time =
              '${difference.inHours} hour${difference.inHours > 1 ? "s" : ""} ago';
        } else {
          time =
              '${difference.inDays} day${difference.inDays > 1 ? "s" : ""} ago';
        }
      } catch (e) {
        time = 'Recently';
      }
    }

    return _buildActivityCard(title, description, time, color, icon);
  }

  Widget _buildActivityCard(
    String title,
    String description,
    String time,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: ResponsiveUtils.getResponsiveElevation(
              context,
              mobile: 5,
              tablet: 6,
              desktop: 8,
            ),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(
                context,
                mobile: 20,
                tablet: 24,
                desktop: 28,
              ),
            ),
          ),
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                    color: Mycolors.gray,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
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

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminUserDetailsScreen(user: user),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Mycolors.basecolor.withOpacity(0.1),
          child: Text(
            (user['name'] ?? 'U')[0].toUpperCase(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Mycolors.basecolor,
            ),
          ),
        ),
        title: Text(
          user['name'] ?? 'Unknown',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          user['email'] ?? '',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Mycolors.gray),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    final status = driver['status'] ?? 'pending';
    final statusColor = status == 'approved' ? Mycolors.green : Mycolors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          // Navigate to driver details screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDriverDetailsScreen(driver: driver),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Mycolors.basecolor.withOpacity(0.1),
          child: Text(
            (driver['name'] ?? 'D')[0].toUpperCase(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Mycolors.basecolor,
            ),
          ),
        ),
        title: Text(
          driver['name'] ?? 'Unknown',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          driver['vehicleNumber'] ?? driver['email'] ?? '',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // Only chat icon navigates to chat screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminDriverChatScreen(driver: driver),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.chat, size: 20, color: Mycolors.basecolor),
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    final rating = (feedback['rating'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Mycolors.orange.withOpacity(0.1),
                child: Text(
                  (feedback['userName'] ?? 'U')[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Mycolors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback['userName'] ?? 'Anonymous',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: Mycolors.orange,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback['feedback'] ?? feedback['comment'] ?? 'No comment',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final fare = booking['fare'] ?? 0;
    final pickupLocation = booking['pickupLocation'] ?? 'Unknown';
    final dropoffLocation = booking['dropoffLocation'] ?? 'Unknown';
    final userDetails = booking['userDetails'] as Map<String, dynamic>?;
    final driverDetails = booking['driverDetails'] as Map<String, dynamic>?;

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Mycolors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'ongoing':
        statusColor = Mycolors.blue;
        statusIcon = Icons.directions_car;
        break;
      case 'cancelled':
        statusColor = Mycolors.red;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
        statusColor = Mycolors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      default:
        statusColor = Mycolors.gray;
        statusIcon = Icons.info;
    }

    // Format date
    String formattedDate = 'Recently';
    if (booking['createdAt'] != null) {
      try {
        final Timestamp timestamp = booking['createdAt'];
        final DateTime dateTime = timestamp.toDate();
        formattedDate =
            '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        formattedDate = 'Recently';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header with status and fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
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
                      status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '₹$fare',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Mycolors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Route information
          Row(
            children: [
              Icon(Icons.location_on, color: Mycolors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pickupLocation,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, color: Mycolors.green, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dropoffLocation,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User and Driver info
          Row(
            children: [
              // User info
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                      child: Text(
                        (userDetails?['name'] ?? 'U')[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Mycolors.basecolor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Mycolors.gray,
                            ),
                          ),
                          Text(
                            userDetails?['name'] ?? 'Unknown',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Driver info
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Mycolors.orange.withOpacity(0.1),
                      child: Text(
                        (driverDetails?['name'] ?? 'D')[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Mycolors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Driver',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Mycolors.gray,
                            ),
                          ),
                          Text(
                            driverDetails?['name'] ?? 'Not Assigned',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date and time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: GoogleFonts.poppins(fontSize: 12, color: Mycolors.gray),
              ),
              if (booking['id'] != null)
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to booking details
                    _showBookingDetails(booking);
                  },
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

  void _showBookingDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.local_taxi, color: Mycolors.basecolor),
            const SizedBox(width: 12),
            Text(
              'Booking Details',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Booking ID', booking['id'] ?? 'N/A'),
              _buildDetailRow('Status', booking['status'] ?? 'N/A'),
              _buildDetailRow('Fare', '₹${booking['fare'] ?? 0}'),
              _buildDetailRow('Pickup', booking['pickupLocation'] ?? 'N/A'),
              _buildDetailRow('Dropoff', booking['dropoffLocation'] ?? 'N/A'),
              _buildDetailRow('User', booking['userDetails']?['name'] ?? 'N/A'),
              _buildDetailRow(
                'Driver',
                booking['driverDetails']?['name'] ?? 'Not Assigned',
              ),
              if (booking['createdAt'] != null)
                _buildDetailRow('Date', _formatTimestamp(booking['createdAt'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: Mycolors.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
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

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final DateTime dateTime = timestamp.toDate();
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedBookingFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBookingFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Mycolors.basecolor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Mycolors.basecolor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _getFilteredBookingsStream() {
    Stream<List<Map<String, dynamic>>> baseStream;

    if (_selectedBookingFilter == 'all') {
      baseStream = AdminService.getAllBookingsStream();
    } else {
      baseStream = AdminService.getBookingsByStatusStream(
        _selectedBookingFilter,
      );
    }

    return baseStream.map((bookings) {
      final searchQuery = _searchController.text.toLowerCase().trim();

      if (searchQuery.isEmpty) {
        return bookings;
      }

      return bookings.where((booking) {
        final userDetails = booking['userDetails'] as Map<String, dynamic>?;
        final driverDetails = booking['driverDetails'] as Map<String, dynamic>?;
        final pickupLocation = (booking['pickupLocation'] ?? '').toLowerCase();
        final dropoffLocation = (booking['dropoffLocation'] ?? '')
            .toLowerCase();
        final userName = (userDetails?['name'] ?? '').toLowerCase();
        final driverName = (driverDetails?['name'] ?? '').toLowerCase();

        return pickupLocation.contains(searchQuery) ||
            dropoffLocation.contains(searchQuery) ||
            userName.contains(searchQuery) ||
            driverName.contains(searchQuery);
      }).toList();
    });
  }

  Widget _buildSidebar() {
    return Container(
      width: 250, // Fixed width for sidebar
      decoration: BoxDecoration(
        color: Colors.white, // Light premium sidebar
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header Logo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Row(
              children: [
                Image.asset(
                  'assets/logooo.png',
                  height: 30,
                  color: Mycolors.basecolor,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.drive_eta, color: Mycolors.basecolor),
                ),
                const SizedBox(width: 10),
                Text(
                  "RelyGO",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 20),
          // Navigation Links
          _buildSidebarItem(Icons.dashboard_rounded, "Dashboard", 0),
          _buildSidebarItem(Icons.people_rounded, "User Management", 1),
          _buildSidebarItem(Icons.local_taxi_rounded, "Ride Monitoring", 2),
          _buildSidebarItem(
            Icons.report_problem_rounded,
            "Issue Resolution",
            3,
          ),
          _buildSidebarItem(Icons.analytics_rounded, "Financial Stats", 4),
          const Spacer(),
          // Logout at the bottom
          Divider(color: Colors.grey.shade300, height: 1),
          InkWell(
            onTap: _showLogoutDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.logout, color: Colors.redAccent, size: 24),
                  const SizedBox(width: 16),
                  Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        color: isSelected
            ? Mycolors.basecolor.withOpacity(0.08)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Mycolors.basecolor : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: isSelected ? Mycolors.basecolor : Colors.black87,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
