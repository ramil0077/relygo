import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

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
import 'package:relygo/screens/chat_detail_screen.dart';
<<<<<<< HEAD
import 'package:relygo/widgets/driver_ai_assistant.dart';
=======
import 'package:relygo/screens/driver_chatbot_screen.dart';
import 'package:relygo/services/driver_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _selectedIndex = 0;
  bool _isOnline = false;
<<<<<<< HEAD
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    DriverLocationService.stopLocationTracking();
    super.dispose();
  }

  String?
  _currentActiveRideId; // Track current active ride for location tracking
=======
  String _driverName = 'Driver';

  // Today's performance
  int _todayRides = 0;
  double _todayEarnings = 0;
  double _avgRating = 0;

  // Ride and Location tracking
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<QuerySnapshot>? _reminderSubscription;
  String? _activeRideId;
  bool _isTracking = false;
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
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
=======
    _loadDriverInfo();
    _setupReminderListener();
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    _reminderSubscription?.cancel();
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
        _isOnline = (data['isOnline'] ?? false) as bool;
      });

      // Resume tracking if there's a ride already 'started'
      final startedSnapshot = await FirebaseFirestore.instance
          .collection('ride_requests')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'started')
          .limit(1)
          .get();

      if (startedSnapshot.docs.isNotEmpty) {
        final rId = startedSnapshot.docs.first.id;
        if (mounted) {
          setState(() {
            _activeRideId = rId;
          });
          _startLocationUpdates();
        }
      }
    }
  }

  void _setupReminderListener() {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return;

    _reminderSubscription = FirebaseFirestore.instance
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .listen((snapshot) {
      final now = DateTime.now();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final scheduledDate = data['scheduledDate'] as Timestamp?;
        if (scheduledDate == null) continue;

        final diff = scheduledDate.toDate().difference(now).inMinutes;
        // If within 15 mins and hasn't notified yet
        if (diff <= 15 && diff > 0 && data['reminderSent'] != true) {
          _sendReminderNotification(doc.id, data['userName'] ?? 'User');
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
        }
      }
    });
  }

<<<<<<< HEAD
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
=======
  Future<void> _sendReminderNotification(String rideId, String userName) async {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return;

    // Check if notification already exists to be safe
    final existing = await FirebaseFirestore.instance
        .collection('notifications')
        .where('driverId', isEqualTo: driverId)
        .where('bookingId', isEqualTo: rideId)
        .where('type', isEqualTo: 'ride_reminder')
        .limit(1)
        .get();

    if (existing.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'driverId': driverId,
        'title': 'Upcoming Ride Reminder',
        'message': 'You have a ride with $userName starting in less than 15 minutes.',
        'type': 'ride_reminder',
        'bookingId': rideId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mark as notified in BOTH collections for consistency
      await FirebaseFirestore.instance.collection('ride_requests').doc(rideId).update({
        'reminderSent': true,
      });
      try {
        await FirebaseFirestore.instance.collection('bookings').doc(rideId).update({
          'reminderSent': true,
        });
      } catch (_) {}
    }
  }

  void _toggleOnlineStatus(bool value) async {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return;

    setState(() => _isOnline = value);
    try {
      await UserService.updateOnlineStatus(driverId, value);
    } catch (e) {
      if (mounted) {
        setState(() => _isOnline = !value);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  Future<void> _handleStartRide({String? specificRideId}) async {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return;

    String? rideId = specificRideId;
    Map<String, dynamic>? rideData;

    if (rideId == null) {
      // Check for any paid (ongoing) ride requests for this driver that haven't started yet
      final snapshot = await FirebaseFirestore.instance
          .collection('ride_requests')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'ongoing')
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        rideId = snapshot.docs.first.id;
        rideData = snapshot.docs.first.data();
      }
    } else {
      final doc = await FirebaseFirestore.instance.collection('ride_requests').doc(rideId).get();
      if (doc.exists) {
        rideData = doc.data();
      }
    }

    if (rideId != null && rideData != null) {
      final String userName = rideData['userName'] ?? 'User';
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Start Ride', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to start the ride for $userName?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final res = await DriverService.startRide(rideId!);
                if (res['success']) {
                  setState(() {
                    _activeRideId = rideId;
                  });
                  _startLocationUpdates();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ride started! Live tracking enabled.'))
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${res['error']}'))
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Mycolors.green),
              child: const Text('Start'),
            ),
          ],
        ),
      );
    } else {
      // Also check for already started rides to resume tracking
      final startedSnapshot = await FirebaseFirestore.instance
          .collection('ride_requests')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: 'started')
          .limit(1)
          .get();

      if (startedSnapshot.docs.isNotEmpty) {
        final rId = startedSnapshot.docs.first.id;
        setState(() {
          _activeRideId = rId;
        });
        _startLocationUpdates();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resuming live tracking for active ride.'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No ongoing paid rides to start. Please wait for user payment.'),
          ),
        );
      }
    }
  }

  Future<void> _startLocationUpdates() async {
    if (_isTracking) return;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    setState(() => _isTracking = true);

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      final driverId = AuthService.currentUserId;
      if (driverId != null) {
        DriverService.updateLocation(driverId, position.latitude, position.longitude);
      }
    });
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    setState(() {
      _isTracking = false;
      _activeRideId = null;
    });
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.report_problem, color: Mycolors.red),
              const SizedBox(width: 8),
              Text(
                'Emergency SOS',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Mycolors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you in danger? Pressing the button below will alert our security team and share your live location.',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: const Text('Call Police (100)'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.medical_services, color: Colors.red),
                title: const Text('Call Ambulance (102)'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('SOS Alert Sent! Help is on the way.'),
                    backgroundColor: Mycolors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('SEND SOS', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              trailing: const Text('English'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              trailing: const Text('1.0.0'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _recentRequestsStream() {
    final driverId = AuthService.currentUserId;
    if (driverId == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // Sort client-side
          docs.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return docs;
        });
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.smart_toy),
        onPressed: () {
          final driverId =
              FirebaseAuth.instance.currentUser?.uid ?? 'demo_driver';
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.6,
              expand: false,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                ),
                child: DriverAIAssistantScreen(driverId: driverId),
              ),
            ),
          );
        },
      ),

      backgroundColor: Colors.white,
=======
>>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10
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
              elevation: 0,
              title: Text(
                'Driver Dashboard',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.smart_toy_outlined,
                  ),
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
                  icon: const Icon(
                    Icons.notifications_none,
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
<<<<<<< HEAD
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
=======
                        Text(
                          "Good Morning, $_driverName!",
                          style: ResponsiveTextStyles.getTitleStyle(context),
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
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
<<<<<<< HEAD
                    onChanged: (value) {
                      setState(() {
                        _isOnline = value;
                      });
                    },
                    activeColor: Mycolors.green,
=======
                    onChanged: _toggleOnlineStatus,
                    activeTrackColor: Mycolors.green,
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                  ),
                ],
              ),
              SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),

              // Upcoming Ride Reminders (Paid rides within 15 minutes)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ride_requests')
                    .where('driverId', isEqualTo: AuthService.currentUserId)
                    .where('status', isEqualTo: 'ongoing') // Paid but not started
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
                    
                    final diff = scheduledDate.toDate().difference(now).inMinutes;
                    return diff <= 15 && diff > -60; // Reminder 15 mins before or within an hour after
                  }).toList();

                  if (reminders.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upcoming Ride Reminders",
                        style: ResponsiveTextStyles.getSubtitleStyle(context).copyWith(
                          color: Mycolors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
                      ...reminders.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Mycolors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Mycolors.red.withOpacity(0.3)),
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
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Pickup: ${data['pickup'] ?? 'Location'}",
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _handleStartRide(specificRideId: doc.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Mycolors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: const Text("Start Now"),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
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
                                final res = await DriverService.completeBooking(_activeRideId!);
                                if (res['success']) {
                                  _stopLocationUpdates();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Ride completed!'))
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
                          mobile: _buildMobileStatsGrid(context, data),
                          tablet: _buildTabletStatsGrid(context, data),
                          desktop: _buildDesktopStatsGrid(context, data),
                        ),
                      ],
                    ),
<<<<<<< HEAD
                    _buildLiveStatsGrid(context),
                  ],
                ),
=======
                  );
                },
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
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
<<<<<<< HEAD
                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) {
=======
                  final docs = snapshot.data ?? [];
                  if (docs.isEmpty) {
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                    return Center(
                      child: Text(
                        'No recent requests',
                        style: GoogleFonts.poppins(color: Mycolors.gray),
                      ),
                    );
                  }
                  return Column(
<<<<<<< HEAD
                    children: bookings.take(3).map((d) {
=======
                    children: docs.take(3).map((d) {
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                      final title =
                          (d['destination'] ??
                                  d['dropoffLocation'] ??
                                  'Ride Request')
                              .toString();
<<<<<<< HEAD
                      final price = (d['price'] ?? d['fare']) != null
                          ? '₹${(d['price'] ?? d['fare']).toString()}'
                          : '';
=======
                      final price = d['fare'] != null
                          ? '₹${d['fare']}'
                          : (d['price'] != null ? '₹${d['price']}' : '');
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
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

  Widget _buildChatTab() {
    final driverId = AuthService.currentUserId;
    return Scaffold(
      body: driverId == null
          ? const Center(child: Text('Please log in to chat.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('driverId', isEqualTo: driverId)
                  .where(
                    'status',
                    whereIn: ['accepted', 'ongoing', 'completed'],
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final bookings = snapshot.data!.docs;
                if (bookings.isEmpty) {
                  return const Center(child: Text('No current user chats.'));
                }
<<<<<<< HEAD
                return ListView(
                  children: bookings.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(data['userName'] ?? 'User'),
                      subtitle: Text("Booking: ${doc.id}"),
                      trailing: const Icon(Icons.chat),
=======
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
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              peerName: data['userName'] ?? 'User',
                              peerId: data['userId'] ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
    );
  }

  Widget _buildReviewsTab() {
    return const DriverReviewsScreen();
  }

  Widget _buildProfileTab() {
    return const DriverProfileScreen();
  }

<<<<<<< HEAD
  // Live Stats Wrapper
  Widget _buildLiveStatsGrid(BuildContext context) {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return const SizedBox.shrink();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([
        DriverService.getDriverEarnings(driverId),
        DriverService.getDriverRating(driverId),
      ]),
      builder: (context, snapshot) {
        String ridesCount = "0";
        String earningsAmount = "₹0";
        String ratingValue = "0.0";

        if (snapshot.hasData) {
          final earningsData = snapshot.data![0];
          final ratingData = snapshot.data![1];

          ridesCount = (earningsData['todayRides'] ?? 0).toString();
          earningsAmount =
              "₹${(earningsData['todayEarnings'] ?? 0.0).toStringAsFixed(0)}";
          ratingValue = (ratingData['averageRating'] ?? 0.0).toStringAsFixed(1);
        }

        return ResponsiveWidget(
          mobile: _buildMobileStatsGrid(
            context,
            ridesCount,
            earningsAmount,
            ratingValue,
          ),
          tablet: _buildTabletStatsGrid(
            context,
            ridesCount,
            earningsAmount,
            ratingValue,
          ),
          desktop: _buildDesktopStatsGrid(
            context,
            ridesCount,
            earningsAmount,
            ratingValue,
          ),
        );
      },
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
=======
  // Mobile Stats Grid - 3 columns
  Widget _buildMobileStatsGrid(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '${data['rides']}',
            'Rides',
            Icons.directions_car,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
            '₹${(data['earnings'] as num).toStringAsFixed(0)}',
            'Earnings',
            Icons.attach_money,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
            data['averageRating'] == 0
                ? 'New'
                : (data['averageRating'] as num).toStringAsFixed(1),
            'Rating',
            Icons.star,
          ),
        ),
      ],
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
    );
  }

  // Tablet Stats Grid - 3 columns with more spacing
  Widget _buildTabletStatsGrid(
    BuildContext context,
<<<<<<< HEAD
    String rides,
    String earnings,
    String rating,
=======
    Map<String, dynamic> data,
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
<<<<<<< HEAD
            rides,
            "Rides Today",
=======
            '${data['rides']}',
            'Rides',
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
            Icons.directions_car,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
<<<<<<< HEAD
            earnings,
            "Earned Today",
=======
            '₹${(data['earnings'] as num).toStringAsFixed(0)}',
            'Earnings',
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
            Icons.attach_money,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
<<<<<<< HEAD
        Expanded(child: _buildStatCard(context, rating, "Rating", Icons.star)),
=======
        Expanded(
          child: _buildStatCard(
            context,
            data['averageRating'] == 0
                ? 'New'
                : (data['averageRating'] as num).toStringAsFixed(1),
            'Rating',
            Icons.star,
          ),
        ),
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
      ],
    );
  }

  // Desktop Stats Grid - 3 columns with maximum spacing
  Widget _buildDesktopStatsGrid(
    BuildContext context,
<<<<<<< HEAD
    String rides,
    String earnings,
    String rating,
=======
    Map<String, dynamic> data,
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
<<<<<<< HEAD
            rides,
            "Rides Today",
=======
            '${data['rides']}',
            'Rides',
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
            Icons.directions_car,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getLargeSpacing(context)),
        Expanded(
          child: _buildStatCard(
            context,
<<<<<<< HEAD
            earnings,
            "Earned Today",
=======
            '₹${(data['earnings'] as num).toStringAsFixed(0)}',
            'Earnings',
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
            Icons.attach_money,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getLargeSpacing(context)),
<<<<<<< HEAD
        Expanded(child: _buildStatCard(context, rating, "Rating", Icons.star)),
=======
        Expanded(
          child: _buildStatCard(
            context,
            data['averageRating'] == 0
                ? 'New'
                : (data['averageRating'] as num).toStringAsFixed(1),
            'Rating',
            Icons.star,
          ),
        ),
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
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
<<<<<<< HEAD
                () {
                  // Scroll to active rides section
                  _scrollController.animateTo(
                    800, // Approximate position of active rides
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
=======
                _handleStartRide,
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
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
<<<<<<< HEAD
                  setState(() {
                    _selectedIndex = 4; // Profile tab
                  });
=======
                  setState(() => _selectedIndex = 2);
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
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
                _handleStartRide,
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
<<<<<<< HEAD
                  setState(() {
                    _selectedIndex = 4; // Profile tab
                  });
=======
                  setState(() => _selectedIndex = 2);
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
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
<<<<<<< HEAD
            () {
              // Scroll to active rides section
              _scrollController.animateTo(
                800,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
=======
            _handleStartRide,
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
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
<<<<<<< HEAD
              setState(() {
                _selectedIndex = 4; // Profile tab
              });
=======
              setState(() => _selectedIndex = 2);
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
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
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
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
<<<<<<< HEAD
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
=======
                    fontWeight: FontWeight.w600,
                  ),
>>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10
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
<<<<<<< HEAD
=======
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
                ),
              ),
>>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10
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
<<<<<<< HEAD
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
=======
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
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveSpacing.getSmallSpacing(context),
      ),
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
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
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
              name.isNotEmpty ? name[0] : '?',
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
                  ),
                ),
                Text(
                  message,
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
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
      ),
    );
  }
}
