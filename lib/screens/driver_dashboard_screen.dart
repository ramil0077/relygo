import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

import 'package:relygo/screens/driver_earnings_screen.dart';
import 'package:relygo/screens/driver_profile_screen.dart';
import 'package:relygo/screens/driver_ride_history_screen.dart';
import 'package:relygo/screens/driver_reviews_screen.dart';

import 'package:relygo/utils/responsive.dart';
import 'package:relygo/widgets/animated_bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/screens/driver_notifications_screen.dart';
import 'package:relygo/services/chat_service.dart';
import 'package:relygo/screens/chat_detail_screen.dart';
import 'dart:async';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _selectedIndex = 0;
  bool _isOnline = false;
  String _driverName = 'Driver';

  // Today's performance
  int _todayRides = 0;
  double _todayEarnings = 0;
  double _avgRating = 0;

  @override
  void initState() {
    super.initState();
    _loadDriverInfo();
    _loadTodayStats();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDriverInfo() async {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(driverId)
        .get();
    if (mounted && doc.exists) {
      final data = doc.data()!;
      setState(() {
        _driverName = (data['name'] ?? data['fullName'] ?? 'Driver').toString();
      });
    }
  }

  Future<void> _loadTodayStats() async {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      // Today's ride_requests for this driver
      final ridesSnap = await FirebaseFirestore.instance
          .collection('ride_requests')
          .where('driverId', isEqualTo: driverId)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .get();

      int rides = ridesSnap.docs.length;
      double earnings = 0;
      for (final d in ridesSnap.docs) {
        final f = d.data()['fare'];
        if (f is num) earnings += f.toDouble();
      }

      // Average rating from reviews
      final reviewsSnap = await FirebaseFirestore.instance
          .collection('reviews')
          .where('driverId', isEqualTo: driverId)
          .get();
      double rating = 0;
      if (reviewsSnap.docs.isNotEmpty) {
        final total = reviewsSnap.docs.fold<double>(
          0,
          (sum, d) => sum + ((d.data()['rating'] ?? 0) as num).toDouble(),
        );
        rating = total / reviewsSnap.docs.length;
      }

      if (mounted) {
        setState(() {
          _todayRides = rides;
          _todayEarnings = earnings;
          _avgRating = rating;
        });
      }
    } catch (_) {}
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _recentRequestsStream() {
    final driverId = AuthService.currentUserId;
    if (driverId == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(), // index 0
            _buildEarningsTab(), // index 1
            _buildChatTab(), // index 2
            _buildReviewsTab(), // index 3
            _buildProfileTab(), // index 4
          ],
        ),
      ),
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'Driver Dashboard',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverNotificationsScreen(),
                      ),
                    );
                  },
                  tooltip: 'Ride Requests',
                ),
              ],
            )
          : null,
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          NavBarItem(icon: Icons.home, label: 'Home'),
          NavBarItem(icon: Icons.attach_money, label: 'Earnings'),
          NavBarItem(icon: Icons.chat, label: 'Chat'),
          NavBarItem(icon: Icons.star, label: 'Reviews'),
          NavBarItem(icon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: ResponsiveLayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
              // Header with Online/Offline Toggle
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Morning, $_driverName!",
                          style: ResponsiveTextStyles.getTitleStyle(context),
                        ),
                        Text(
                          _isOnline
                              ? "You're online and ready to drive"
                              : "You're offline",
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            color: _isOnline ? Mycolors.green : Mycolors.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isOnline,
                    onChanged: (value) {
                      setState(() {
                        _isOnline = value;
                      });
                    },
                    activeTrackColor: Mycolors.green,
                  ),
                ],
              ),
              SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),

              // Today's Stats
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: Mycolors.basecolor,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Today's Performance",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveSpacing.getMediumSpacing(context),
                    ),
                    ResponsiveWidget(
                      mobile: _buildMobileStatsGrid(context),
                      tablet: _buildTabletStatsGrid(context),
                      desktop: _buildDesktopStatsGrid(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),

              // Quick Actions
              Text(
                "Quick Actions",
                style: ResponsiveTextStyles.getTitleStyle(context),
              ),
              SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

              ResponsiveWidget(
                mobile: _buildMobileActionGrid(context),
                tablet: _buildTabletActionGrid(context),
                desktop: _buildDesktopActionGrid(context),
              ),

              SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),

              // Recent Rides
              Text(
                "Recent Rides",
                style: ResponsiveTextStyles.getTitleStyle(context),
              ),
              SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _recentRequestsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load recent requests',
                        style: GoogleFonts.poppins(color: Mycolors.red),
                      ),
                    );
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No recent requests',
                        style: GoogleFonts.poppins(color: Mycolors.gray),
                      ),
                    );
                  }
                  return Column(
                    children: docs.take(3).map((doc) {
                      final d = doc.data();
                      final title = (d['destination'] ?? 'Ride Request')
                          .toString();
                      final price = d['price'] != null ? '₹${d['price']}' : '';
                      final status = (d['status'] ?? 'pending').toString();
                      final statusColor = status == 'pending'
                          ? Mycolors.orange
                          : (status == 'accepted'
                                ? Mycolors.green
                                : Mycolors.red);
                      final createdAt = d['createdAt'] is Timestamp
                          ? (d['createdAt'] as Timestamp).toDate()
                          : null;
                      final time = createdAt != null
                          ? '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
                          : '';
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: ResponsiveSpacing.getSmallSpacing(context),
                        ),
                        child: _buildRecentRideCard(
                          context,
                          title,
                          '',
                          price,
                          status,
                          statusColor,
                          time,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget _buildRidesTab() {
  //   return const RideManagementScreen();
  // }

  Widget _buildEarningsTab() {
    return const DriverEarningsScreen();
  }

  Widget _buildChatTab() {
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
          Text("Messages", style: ResponsiveTextStyles.getTitleStyle(context)),
          SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

          // Conversations from Firestore
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ChatService.getUserConversationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load messages',
                      style: GoogleFonts.poppins(color: Mycolors.red),
                    ),
                  );
                }
                final conversations = snapshot.data ?? [];
                if (conversations.isEmpty) {
                  return Center(
                    child: Text(
                      'No conversations yet',
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final c = conversations[index];
                    final String conversationId = (c['id'] ?? '').toString();
                    final String lastMessage = (c['lastMessage'] ?? '')
                        .toString();
                    final Timestamp? updatedAt = c['updatedAt'] as Timestamp?;
                    final String timeText = updatedAt != null
                        ? _formatDate(updatedAt)
                        : '';
                    // Use enriched peerName from ChatService stream
                    final String peerId = (c['peerId'] ?? '').toString();
                    final String title =
                        (c['peerName'] != null &&
                            (c['peerName'] as String).isNotEmpty)
                        ? c['peerName'] as String
                        : (peerId.isNotEmpty ? 'User' : 'Conversation');

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              peerName: title,
                              conversationId: conversationId,
                              peerId: peerId,
                            ),
                          ),
                        );
                      },
                      child: _buildChatCard(
                        context,
                        title,
                        lastMessage.isEmpty ? 'Say hi' : lastMessage,
                        timeText,
                        '',
                      ),
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

  Widget _buildReviewsTab() {
    return const DriverReviewsScreen();
  }

  Widget _buildProfileTab() {
    return const DriverProfileScreen();
  }

  // Mobile Stats Grid - 3 columns
  Widget _buildMobileStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '$_todayRides',
            'Rides',
            Icons.directions_car,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
            '₹${_todayEarnings.toStringAsFixed(0)}',
            'Earnings',
            Icons.attach_money,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
            _avgRating == 0 ? 'New' : _avgRating.toStringAsFixed(1),
            'Rating',
            Icons.star,
          ),
        ),
      ],
    );
  }

  // Tablet Stats Grid - 3 columns with more spacing
  Widget _buildTabletStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '$_todayRides',
            'Rides',
            Icons.directions_car,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
            '₹${_todayEarnings.toStringAsFixed(0)}',
            'Earnings',
            Icons.attach_money,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
            _avgRating == 0 ? 'New' : _avgRating.toStringAsFixed(1),
            'Rating',
            Icons.star,
          ),
        ),
      ],
    );
  }

  // Desktop Stats Grid - 3 columns with maximum spacing
  Widget _buildDesktopStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '$_todayRides',
            'Rides',
            Icons.directions_car,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getLargeSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
            '₹${_todayEarnings.toStringAsFixed(0)}',
            'Earnings',
            Icons.attach_money,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getLargeSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
            _avgRating == 0 ? 'New' : _avgRating.toStringAsFixed(1),
            'Rating',
            Icons.star,
          ),
        ),
      ],
    );
  }

  // Mobile Action Grid - 2x2
  Widget _buildMobileActionGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                "Start Ride",
                Icons.play_arrow,
                Mycolors.green,
                () {
                  // Start ride functionality
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
            Expanded(
              child: _buildActionCard(
                context,
                "View Earnings",
                Icons.attach_money,
                Mycolors.orange,
                () {
                  setState(() {
                    _selectedIndex = 1; // Switch to earnings tab
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                "Ride History",
                Icons.history,
                Mycolors.basecolor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverRideHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
            Expanded(
              child: _buildActionCard(
                context,
                "Settings",
                Icons.settings,
                Mycolors.gray,
                () {
                  // Settings functionality
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tablet Action Grid - 2x2 with more spacing
  Widget _buildTabletActionGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                "Start Ride",
                Icons.play_arrow,
                Mycolors.green,
                () {
                  // Start ride functionality
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
            Expanded(
              child: _buildActionCard(
                context,
                "View Earnings",
                Icons.attach_money,
                Mycolors.orange,
                () {
                  setState(() {
                    _selectedIndex = 1; // Switch to earnings tab
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                "Ride History",
                Icons.history,
                Mycolors.basecolor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverRideHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
            Expanded(
              child: _buildActionCard(
                context,
                "Settings",
                Icons.settings,
                Mycolors.gray,
                () {
                  // Settings functionality
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Desktop Action Grid - 4 columns
  Widget _buildDesktopActionGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            "Start Ride",
            Icons.play_arrow,
            Mycolors.green,
            () {
              // Start ride functionality
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildActionCard(
            context,
            "View Earnings",
            Icons.attach_money,
            Mycolors.orange,
            () {
              setState(() {
                _selectedIndex = 1; // Switch to earnings tab
              });
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildActionCard(
            context,
            "Ride History",
            Icons.history,
            Mycolors.basecolor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriverRideHistoryScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildActionCard(
            context,
            "Settings",
            Icons.settings,
            Mycolors.gray,
            () {
              // Settings functionality
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 24,
              tablet: 26,
              desktop: 28,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 13,
                desktop: 14,
              ),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
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
            SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
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

  Widget _buildRecentRideCard(
    BuildContext context,
    String title,
    String distance,
    String price,
    String status,
    Color statusColor,
    String time,
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
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
            decoration: BoxDecoration(
              color: Mycolors.basecolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
            child: Image.asset(
              'assets/logooo.png',
              width: ResponsiveUtils.getResponsiveIconSize(
                context,
                mobile: 24,
                tablet: 26,
                desktop: 28,
              ),
              height: ResponsiveUtils.getResponsiveIconSize(
                context,
                mobile: 24,
                tablet: 26,
                desktop: 28,
              ),
            ),
          ),
          SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
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
                  distance,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
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
                      tablet: 13,
                      desktop: 14,
                    ),
                    color: Mycolors.gray,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: ResponsiveSpacing.getSmallSpacing(context) / 2,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 8,
                    tablet: 10,
                    desktop: 12,
                  ),
                  vertical: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 4,
                    tablet: 5,
                    desktop: 6,
                  ),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                    color: statusColor,
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

  Widget _buildChatCard(
    BuildContext context,
    String name,
    String message,
    String time,
    String unreadCount,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ChatDetailScreen(peerName: name),
        //   ),
        // );
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveSpacing.getSmallSpacing(context),
        ),
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
            CircleAvatar(
              radius: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ),
              backgroundColor: Mycolors.basecolor.withOpacity(0.1),
              child: Text(
                name[0],
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Mycolors.basecolor,
                ),
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
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
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                      color: Mycolors.gray,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                    color: Mycolors.gray,
                  ),
                ),
                if (unreadCount.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(
                      top: ResponsiveSpacing.getSmallSpacing(context) / 2,
                    ),
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 6,
                        tablet: 7,
                        desktop: 8,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Mycolors.basecolor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount,
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 10,
                          tablet: 11,
                          desktop: 12,
                        ),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
