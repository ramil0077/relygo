import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

import 'package:relygo/screens/driver_management_screen.dart';
import 'package:intl/intl.dart';
import 'package:relygo/screens/admin_complaints_screen.dart';
import 'package:relygo/screens/feedback_screen.dart';
import 'package:relygo/screens/admin_driver_approval_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/screens/admin_user_details_screen.dart';
import 'package:relygo/screens/admin_driver_chat_screen.dart';
import 'package:relygo/screens/admin_analytics_screen.dart';
import 'package:relygo/services/admin_service.dart';

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
  StreamSubscription? _usersSub;
  StreamSubscription? _approvedDriversSub;
  StreamSubscription? _pendingDriversSub;
  StreamSubscription? _complaintsSub;

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
    super.dispose();
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
                        builder: (context) => const AdminComplaintsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Activity",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1; // Go to users/activity tab
                  });
                },
                child: Text(
                  "View All",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Mycolors.basecolor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

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

  Widget _buildUsersTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "User Management",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
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
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Driver Management",
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
                      children: [
                        Icon(
                          Icons.drive_eta,
                          size: 64,
                          color: Colors.grey[400],
                        ),
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
      ),
    );
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDriverChatScreen(driver: driver),
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
            Icon(Icons.chat, size: 20, color: Mycolors.basecolor),
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
