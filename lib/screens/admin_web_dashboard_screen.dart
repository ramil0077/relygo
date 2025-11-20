import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/admin_complaints_screen.dart';
import 'package:relygo/screens/admin_user_details_screen.dart';
import 'package:relygo/screens/admin_driver_details_screen.dart';
import 'package:relygo/screens/admin_booking_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/admin_service.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/screens/signin_screen.dart';

class AdminWebDashboardScreen extends StatefulWidget {
  const AdminWebDashboardScreen({super.key});

  @override
  State<AdminWebDashboardScreen> createState() =>
      _AdminWebDashboardScreenState();
}

class _AdminWebDashboardScreenState extends State<AdminWebDashboardScreen> {
  int _selectedIndex = 0;
  int _userDriverTabIndex = 0; // 0 for users, 1 for drivers
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _sidebarExpanded = true;

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
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Logout', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(),
                // Content
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: _sidebarExpanded ? 260 : 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_sidebarExpanded)
                  Expanded(
                    child: Text(
                      'RelyGo Admin',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Mycolors.basecolor,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Mycolors.basecolor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_taxi, color: Colors.white),
                  ),
                IconButton(
                  icon: Icon(
                    _sidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                  ),
                  onPressed: () {
                    setState(() {
                      _sidebarExpanded = !_sidebarExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  index: 0,
                ),
                _buildSidebarItem(
                  icon: Icons.people_rounded,
                  label: 'Users & Drivers',
                  index: 1,
                ),
                _buildSidebarItem(
                  icon: Icons.local_taxi_rounded,
                  label: 'Bookings',
                  index: 2,
                ),
                _buildSidebarItem(
                  icon: Icons.report_problem_rounded,
                  label: 'Complaints',
                  index: 3,
                  badge: _openComplaints > 0
                      ? _openComplaints.toString()
                      : null,
                ),
                _buildSidebarItem(
                  icon: Icons.analytics_rounded,
                  label: 'Analytics',
                  index: 4,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildSidebarItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              index: -1,
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
    String? badge,
    bool isLogout = false,
  }) {
    final isSelected = _selectedIndex == index;
    final color = isLogout
        ? Mycolors.red
        : (isSelected ? Mycolors.basecolor : Colors.grey[700]!);

    return InkWell(
      onTap: () {
        if (isLogout) {
          _showLogoutDialog();
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Mycolors.basecolor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Mycolors.basecolor.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: color,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Mycolors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // User Info
          FutureBuilder<Map<String, dynamic>?>(
            future: AuthService.getUserData(AuthService.currentUserId ?? ''),
            builder: (context, snapshot) {
              final userData = snapshot.data;
              final userName = userData?['name'] ?? 'Admin';
              final userEmail = userData?['email'] ?? '';
              return Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                      style: GoogleFonts.poppins(
                        color: Mycolors.basecolor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Users & Drivers';
      case 2:
        return 'Bookings';
      case 3:
        return 'Complaints';
      case 4:
        return 'Analytics';
      default:
        return 'Admin Panel';
    }
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(24),
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
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  _totalUsers.toString(),
                  'Total Users',
                  Icons.people,
                  Mycolors.basecolor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  _activeDrivers.toString(),
                  'Active Drivers',
                  Icons.drive_eta,
                  Mycolors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  _pendingApprovals.toString(),
                  'Pending Approvals',
                  Icons.pending_actions,
                  Mycolors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  _openComplaints.toString(),
                  'Open Complaints',
                  Icons.report_problem,
                  Mycolors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Activity Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRecentBookingsCard()),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: _buildQuickActionsCard()),
            ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Bookings',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('ride_requests').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No bookings yet',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                );
              }
              // Sort bookings by createdAt (newest first) and limit to 10
              final sortedDocs = List.from(snapshot.data!.docs);
              sortedDocs.sort((a, b) {
                final aTime =
                    a.data()['createdAt'] ??
                    a.data()['updatedAt'] ??
                    a.data()['paidAt'];
                final bTime =
                    b.data()['createdAt'] ??
                    b.data()['updatedAt'] ??
                    b.data()['paidAt'];
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                if (aTime is Timestamp && bTime is Timestamp) {
                  return bTime.compareTo(aTime); // descending
                }
                return 0;
              });

              final recentBookings = sortedDocs.take(10).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentBookings.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final doc = recentBookings[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'unknown';
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminBookingDetailsScreen(
                            booking: data,
                            bookingId: doc.id,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(
                          status,
                        ).withOpacity(0.1),
                        child: Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _getPickupLocation(data),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'To: ${_getDropoffLocation(data)}',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      trailing: Chip(
                        label: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.poppins(fontSize: 10),
                        ),
                        backgroundColor: _getStatusColor(
                          status,
                        ).withOpacity(0.1),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionItem(
            'Approve Drivers',
            Icons.check_circle,
            Mycolors.green,
            () {
              setState(() {
                _selectedIndex = 1;
                _userDriverTabIndex = 1;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildQuickActionItem(
            'View Complaints',
            Icons.report_problem,
            Mycolors.red,
            () {
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildQuickActionItem(
            'View Analytics',
            Icons.analytics,
            Mycolors.basecolor,
            () {
              setState(() {
                _selectedIndex = 4;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to normalize booking data fields
  String _getPickupLocation(Map<String, dynamic> data) {
    return data['pickupLocation'] ??
        data['pickup'] ??
        data['from'] ??
        'Unknown';
  }

  String _getDropoffLocation(Map<String, dynamic> data) {
    return data['dropoffLocation'] ??
        data['destination'] ??
        data['to'] ??
        data['dropoff'] ??
        'Unknown';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Mycolors.green;
      case 'accepted':
      case 'ongoing':
        return Mycolors.basecolor;
      case 'cancelled':
        return Mycolors.red;
      case 'paid':
        return Mycolors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return Icons.check_circle;
      case 'accepted':
      case 'ongoing':
        return Icons.local_taxi;
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  Widget _buildUsersAndDriversTab() {
    return Column(
      children: [
        // Tab Selector
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
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
                        color: _userDriverTabIndex == 0
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
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
                        color: _userDriverTabIndex == 1
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Content
        Expanded(
          child: IndexedStack(
            index: _userDriverTabIndex,
            children: [_buildUsersList(), _buildDriversList()],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where('userType', isEqualTo: 'user')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            // Ensure id field exists
            data['id'] = doc.id;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                  child: Text(
                    ((data['name'] ?? data['fullName'] ?? 'U').toString())[0]
                        .toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: Mycolors.basecolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  (data['name'] ?? data['fullName'] ?? 'Unknown').toString(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  (data['email'] ?? '').toString(),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminUserDetailsScreen(user: data),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDriversList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where('userType', whereIn: ['driver', 'Driver'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No drivers found',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            // Ensure id field exists
            data['id'] = doc.id;
            final status = data['status'] ?? 'pending';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(status).withOpacity(0.1),
                  child: Icon(Icons.person, color: _getStatusColor(status)),
                ),
                title: Text(
                  (data['name'] ?? data['fullName'] ?? 'Unknown').toString(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  (data['email'] ?? '').toString(),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.poppins(fontSize: 10),
                      ),
                      backgroundColor: _getStatusColor(status).withOpacity(0.1),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AdminDriverDetailsScreen(driver: data),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filters
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search bookings...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _selectedBookingFilter,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedBookingFilter = value!;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Bookings List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _selectedBookingFilter == 'all'
                ? _firestore.collection('ride_requests').snapshots()
                : _firestore
                      .collection('ride_requests')
                      .where('status', isEqualTo: _selectedBookingFilter)
                      .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No bookings found',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                );
              }
              // Sort bookings by createdAt (newest first) in memory
              final sortedDocs = List.from(snapshot.data!.docs);
              sortedDocs.sort((a, b) {
                final aTime =
                    a.data()['createdAt'] ??
                    a.data()['updatedAt'] ??
                    a.data()['paidAt'];
                final bTime =
                    b.data()['createdAt'] ??
                    b.data()['updatedAt'] ??
                    b.data()['paidAt'];
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                if (aTime is Timestamp && bTime is Timestamp) {
                  return bTime.compareTo(aTime); // descending
                }
                return 0;
              });

              return ListView.builder(
                itemCount: sortedDocs.length,
                itemBuilder: (context, index) {
                  final doc = sortedDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminBookingDetailsScreen(
                              booking: data,
                              bookingId: doc.id,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(
                            data['status'] ?? 'unknown',
                          ).withOpacity(0.1),
                          child: Icon(
                            _getStatusIcon(data['status'] ?? 'unknown'),
                            color: _getStatusColor(data['status'] ?? 'unknown'),
                          ),
                        ),
                        title: Text(
                          _getPickupLocation(data),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'To: ${_getDropoffLocation(data)}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        trailing: Chip(
                          label: Text(
                            (data['status'] ?? 'unknown')
                                .toString()
                                .toUpperCase(),
                            style: GoogleFonts.poppins(fontSize: 10),
                          ),
                          backgroundColor: _getStatusColor(
                            data['status'] ?? 'unknown',
                          ).withOpacity(0.1),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: AdminService.getBookingStatsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = snapshot.data ?? {};
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      (stats['totalBookings'] ?? 0).toString(),
                      'Total Rides',
                      Icons.local_taxi,
                      Mycolors.basecolor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      (stats['completedBookings'] ?? 0).toString(),
                      'Completed',
                      Icons.check_circle,
                      Mycolors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      (stats['cancelledBookings'] ?? 0).toString(),
                      'Cancelled',
                      Icons.cancel,
                      Mycolors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics Overview',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Detailed analytics and reports will be displayed here.',
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
