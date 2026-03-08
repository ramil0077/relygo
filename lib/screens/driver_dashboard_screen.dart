

import 'package:relygo/screens/driver_earnings_screen.dart';
import 'package:relygo/screens/driver_profile_screen.dart';
import 'package:relygo/screens/driver_ride_history_screen.dart';
import 'package:relygo/screens/driver_reviews_screen.dart';
import 'package:relygo/services/user_service.dart';

import 'package:relygo/utils/responsive.dart';
import 'package:relygo/widgets/animated_bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/services/driver_service.dart';
import 'package:relygo/services/driver_location_service.dart';
import 'package:relygo/screens/driver_notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _selectedIndex = 0;
  bool _isOnline = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    DriverLocationService.stopLocationTracking();
    super.dispose();
  }

  String?
  _currentActiveRideId; // Track current active ride for location tracking
  int _todayRides = 0;
  double _todayEarnings = 0.0;
  double _avgRating = 0.0;
  String? get _activeRideId => _currentActiveRideId;

  @override
  void initState() {
    super.initState();
    _setupActiveRideListener();
  }

  /// Listen to active paid rides and start location tracking automatically
  void _setupActiveRideListener() {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return;

    _getActiveRidesStream().listen((activeRides) {
      if (activeRides.isNotEmpty) {
        final activeRide = activeRides.first;
        final rideId = activeRide['id'] ?? activeRide['bookingId'] ?? '';

        // Only start tracking if it's a new ride
        if (rideId.isNotEmpty && rideId != _currentActiveRideId) {
          _currentActiveRideId = rideId;
          // Start location tracking for this ride
          DriverLocationService.startLocationTracking(driverId);
          print('Started location tracking for ride: $rideId');
        }
      } else {
        // No active rides, stop tracking
        if (_currentActiveRideId != null) {
          DriverLocationService.stopLocationTracking();
          _currentActiveRideId = null;
          print('Stopped location tracking - no active rides');
        }
      }
    });
  }

  Stream<List<Map<String, dynamic>>> _recentRequestsStream() {
    final driverId = AuthService.currentUserId;
    if (driverId == null) {
      // No authenticated driver; return an empty stream
      return const Stream<List<Map<String, dynamic>>>.empty();
    }
    // Use unified stream and limit to 5 most recent
    return DriverService.getUnifiedDriverBookingsStream(
      driverId,
    ).map((bookings) => bookings.take(5).toList());
  }

  Stream<List<Map<String, dynamic>>> _getActiveRidesStream() {
    final driverId = AuthService.currentUserId;
    if (driverId == null) {
      return const Stream<List<Map<String, dynamic>>>.empty();
    }
    // Get active rides: paid and status is ongoing or accepted
    return DriverService.getUnifiedDriverBookingsStream(driverId).map(
      (bookings) => bookings.where((booking) {
        final isPaid = booking['isPaid'] ?? false;
        final status = (booking['status'] ?? '').toString().toLowerCase();
        return isPaid &&
            (status == 'ongoing' || status == 'accepted' || status == 'paid');
      }).toList(),
    );
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

            _buildReviewsTab(), // index 2
            _buildProfileTab(), // index 3
          ],
        ),
      ),
      appBar: _selectedIndex == 0
          ? AppBar(
              elevation: 0,
              title: Text(
                'Driver Dashboard',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.smart_toy_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverChatbotScreen(),
                      ),
                    );
                  },
                  tooltip: 'Chatbot Assistant',
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
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

          NavBarItem(icon: Icons.star, label: 'Reviews'),
          NavBarItem(icon: Icons.person, label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      controller: _scrollController,
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
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(AuthService.currentUserId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final doc = snapshot.data;
                            final Map<String, dynamic>? docData = doc != null
                                ? (doc.data() as Map<String, dynamic>?)
                                : null;
                            final userName =
                                docData?['name']?.toString() ?? 'Driver';
                            return Text(
                              "Good Morning, ${userName}",
                              style: ResponsiveTextStyles.getTitleStyle(
                                context,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
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
                    activeColor: Mycolors.green,
                  ),
                ],
              ),
              SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),

              // Upcoming Ride Reminders (Paid rides within 15 minutes)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ride_requests')
                    .where('driverId', isEqualTo: AuthService.currentUserId)
                    .where(
                      'status',
                      isEqualTo: 'ongoing',
                    ) // Paid but not started
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final now = DateTime.now();
                  final reminders = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final scheduledDate = data['scheduledDate'] as Timestamp?;
                    if (scheduledDate == null) return false;

                    final diff = scheduledDate
                        .toDate()
                        .difference(now)
                        .inMinutes;
                    return diff <= 15 &&
                        diff >
                            -60; // Reminder 15 mins before or within an hour after
                  }).toList();

                  if (reminders.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upcoming Ride Reminders",
                        style: ResponsiveTextStyles.getSubtitleStyle(context)
                            .copyWith(
                              color: Mycolors.red,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(
                        height: ResponsiveSpacing.getSmallSpacing(context),
                      ),
                      ...reminders.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Mycolors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Mycolors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.alarm, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Ride with ${data['userName'] ?? 'User'}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Pickup: ${data['pickup'] ?? 'Location'}",
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    _handleStartRide(context, doc.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Mycolors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                child: const Text("Start Now"),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(
                        height: ResponsiveSpacing.getMediumSpacing(context),
                      ),
                    ],
                  );
                },
              ),

              // Active Ride Status
              if (_activeRideId != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Mycolors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Mycolors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_taxi, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Ride in Progress - Tracking active",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final res = await DriverService.completeBooking(
                                  _activeRideId!,
                                );
                                if (res['success']) {
                                  _stopLocationUpdates();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ride completed!'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Mycolors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Complete Ride"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),
              ],

              // Today's Stats
              StreamBuilder<Map<String, dynamic>>(
                stream: UserService.streamDriverTodayStats(
                  AuthService.currentUserId!,
                ),
                builder: (context, snapshot) {
                  final data =
                      snapshot.data ??
                      {
                        'rides': _todayRides,
                        'earnings': _todayEarnings,
                        'averageRating': _avgRating,
                      };
                  final rides = (data['rides'] ?? 0).toString();
                  final earnings =
                      '₹${(data['earnings'] ?? 0.0).toStringAsFixed(0)}';
                  final rating = (data['averageRating'] ?? 0.0).toStringAsFixed(
                    1,
                  );
                  return Container(
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
                          mobile: _buildMobileStatsGrid(
                            context,
                            rides,
                            earnings,
                            rating,
                          ),
                          tablet: _buildTabletStatsGrid(
                            context,
                            rides,
                            earnings,
                            rating,
                          ),
                          desktop: _buildDesktopStatsGrid(
                            context,
                            rides,
                            earnings,
                            rating,
                          ),
                        ),
                      ],
                    ),
                  );
                },
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

              // Active Rides Section
              Text(
                "Active Rides",
                style: ResponsiveTextStyles.getTitleStyle(context),
              ),
              SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getActiveRidesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load active rides',
                        style: GoogleFonts.poppins(color: Mycolors.red),
                      ),
                    );
                  }
                  final activeRides = snapshot.data ?? [];
                  if (activeRides.isEmpty) {
                    return Container(
                      padding: ResponsiveUtils.getResponsivePadding(context),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No active rides',
                        style: GoogleFonts.poppins(color: Mycolors.gray),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Column(
                    children: activeRides.map((ride) {
                      return _buildActiveRideCard(context, ride);
                    }).toList(),
                  );
                },
              ),

              SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),

              // Recent Rides
              Text(
                "Recent Rides",
                style: ResponsiveTextStyles.getTitleStyle(context),
              ),
              SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

              StreamBuilder<List<Map<String, dynamic>>>(
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
                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) {
                    return Center(
                      child: Text(
                        'No recent requests',
                        style: GoogleFonts.poppins(color: Mycolors.gray),
                      ),
                    );
                  }
                  return Column(
                    children: bookings.take(3).map((d) {
                      final title =
                          (d['destination'] ??
                                  d['dropoffLocation'] ??
                                  'Ride Request')
                              .toString();
                      final price = (d['price'] ?? d['fare']) != null
                          ? '₹${(d['price'] ?? d['fare']).toString()}'
                          : '';
                      final status = (d['status'] ?? 'pending').toString();
                      final statusColor = status == 'pending'
                          ? Mycolors.orange
                          : (status == 'accepted' || status == 'completed'
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



  Widget _buildReviewsTab() {
    return const DriverReviewsScreen();
  }

  Widget _buildProfileTab() {
    return const DriverProfileScreen();
  }

  void _stopLocationUpdates() {
    DriverLocationService.stopLocationTracking();
    if (mounted) {
      setState(() {
        _currentActiveRideId = null;
      });
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings functionality coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: const Text(
          'Calling emergency services and notifying authorities...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement emergency call logic
              Navigator.pop(context);
            },
            child: const Text(
              'Confirm SOS',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile Stats Grid - adaptive for very narrow screens
  Widget _buildMobileStatsGrid(
    BuildContext context,
    String rides,
    String earnings,
    String rating,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVeryNarrow = constraints.maxWidth < 360;
        if (!isVeryNarrow) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  rides,
                  "Rides Today",
                  Icons.directions_car,
                ),
              ),
              SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
              Expanded(
                child: _buildStatCard(
                  context,
                  earnings,
                  "Earned Today",
                  Icons.attach_money,
                ),
              ),
              SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
              Expanded(
                child: _buildStatCard(context, rating, "Rating", Icons.star),
              ),
            ],
          );
        }
        // On very narrow screens, arrange as 2 columns using Wrap
        final spacing = ResponsiveSpacing.getSmallSpacing(context);
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: _buildStatCard(
                context,
                rides,
                "Rides Today",
                Icons.directions_car,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildStatCard(
                context,
                earnings,
                "Earned Today",
                Icons.attach_money,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildStatCard(context, rating, "Rating", Icons.star),
            ),
          ],
        );
      },
    );
  }

  // Tablet Stats Grid - 3 columns with more spacing
  Widget _buildTabletStatsGrid(
    BuildContext context,
    String rides,
    String earnings,
    String rating,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            rides,
            "Rides Today",
            Icons.directions_car,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
            earnings,
            "Earned Today",
            Icons.attach_money,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(child: _buildStatCard(context, rating, "Rating", Icons.star)),
      ],
    );
  }

  // Desktop Stats Grid - 3 columns with maximum spacing
  Widget _buildDesktopStatsGrid(
    BuildContext context,
    String rides,
    String earnings,
    String rating,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            rides,
            "Rides Today",
            Icons.directions_car,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getLargeSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
            earnings,
            "Earned Today",
            Icons.attach_money,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getLargeSpacing(context)),
        Expanded(child: _buildStatCard(context, rating, "Rating", Icons.star)),
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
                  // Scroll to active rides section
                  _scrollController.animateTo(
                    800, // Approximate position of active rides
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
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
                    _selectedIndex = 1;
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
                _showSettingsDialog,
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
                "Emergency",
                Icons.emergency,
                Mycolors.red,
                _showEmergencyDialog,
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
            Expanded(
              child: _buildActionCard(
                context,
                "Support",
                Icons.support_agent,
                Colors.blue,
                () {
                  setState(() {
                    _selectedIndex = 4; // Profile tab
                  });
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
                () => _scrollController.animateTo(
                  800,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
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
                _showSettingsDialog,
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
                "Emergency",
                Icons.emergency,
                Mycolors.red,
                _showEmergencyDialog,
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
            Expanded(
              child: _buildActionCard(
                context,
                "Support",
                Icons.support_agent,
                Colors.blue,
                () {
                  setState(() {
                    _selectedIndex = 4; // Profile tab
                  });
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
              // Scroll to active rides section
              _scrollController.animateTo(
                800,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
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
            _showSettingsDialog,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildActionCard(
            context,
            "Emergency",
            Icons.emergency,
            Mycolors.red,
            _showEmergencyDialog,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildActionCard(
            context,
            "Support",
            Icons.support_agent,
            Colors.blue,
            () {
              setState(() {
                _selectedIndex = 4; // Profile tab
              });
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

  Widget _buildActiveRideCard(BuildContext context, Map<String, dynamic> ride) {
    final bookingId = ride['id'] ?? '';
    final destination =
        ride['dropoffLocation'] ?? ride['destination'] ?? 'Unknown Destination';
    final pickup = ride['pickupLocation'] ?? ride['pickup'] ?? 'Unknown Pickup';
    final fare = ride['fare'] ?? ride['price'] ?? 0;
    final userName = ride['userName'] ?? 'User';
    final status = (ride['status'] ?? '').toString().toLowerCase();
    final isPaid = ride['isPaid'] ?? false;

    return Container(
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
        border: Border.all(color: Mycolors.green.withOpacity(0.3)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To: $destination',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From: $pickup',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passenger: $userName • Fare: ₹$fare',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                    vertical: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 6,
                      tablet: 7,
                      desktop: 8,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Mycolors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Mycolors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        isPaid ? 'Paid' : 'Unpaid',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 12,
                            tablet: 13,
                            desktop: 14,
                          ),
                          color: Mycolors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: (status == 'accepted' || status == 'paid')
                    ? ElevatedButton.icon(
                        onPressed: () => _handleStartRide(context, bookingId),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: Text(
                          'Start Ride',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors.basecolor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              mobile: 10,
                              tablet: 12,
                              desktop: 14,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: isPaid && status == 'ongoing'
                            ? () => _toggleRideCompletion(context, bookingId)
                            : null,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(
                          'Mark Completed',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 15,
                              desktop: 16,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              mobile: 10,
                              tablet: 12,
                              desktop: 14,
                            ),
                          ),
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

  Future<void> _toggleRideCompletion(
    BuildContext context,
    String bookingId,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Complete Ride?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to mark this ride as completed?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Complete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Completing ride...', style: GoogleFonts.poppins()),
              ],
            ),
            backgroundColor: Mycolors.basecolor,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final result = await DriverService.completeBooking(bookingId);

      // Stop location tracking when ride is completed
      if (result['success'] == true) {
        DriverLocationService.stopLocationTracking();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true
                  ? 'Ride completed successfully!'
                  : result['error'] ?? 'Failed to complete ride',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: result['success'] == true
                ? Mycolors.green
                : Mycolors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleStartRide(BuildContext context, String bookingId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Start Ride?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to start this ride?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors.basecolor,
              foregroundColor: Colors.white,
            ),
            child: Text('Start', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting ride...', style: GoogleFonts.poppins()),
            backgroundColor: Mycolors.basecolor,
          ),
        );
      }

      final result = await DriverService.startRide(bookingId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] == true
                  ? 'Ride started! Good luck.'
                  : result['error'] ?? 'Failed to start ride',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: result['success'] == true
                ? Mycolors.green
                : Mycolors.red,
          ),
        );
      }
    }
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
        border: Border.all(color: Theme.of(context).dividerColor),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isVeryNarrow = constraints.maxWidth < 360;
          if (isVeryNarrow) {
            // Stack information vertically to avoid overflows on very narrow screens
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        ],
                      ),
                    ),
                    SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
                    Text(
                      price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  ],
                ),
                SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
                Row(
                  children: [
                    Container(
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
                    SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
                    Text(
                      time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              ],
            );
          }
          return Row(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          );
        },
      ),
    );
  }
}
