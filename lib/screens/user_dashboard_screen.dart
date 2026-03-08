import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/service_booking_screen.dart';
import 'package:relygo/screens/user_profile_screen.dart';
import 'package:relygo/screens/driver_tracking_screen.dart';
import 'package:relygo/screens/payment_screen.dart';
import 'package:relygo/screens/ride_history_screen.dart';
import 'package:relygo/utils/responsive.dart';
import 'package:relygo/widgets/animated_bottom_nav_bar.dart';
import 'package:relygo/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:relygo/services/admin_service.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/screens/driver_chatbot_screen.dart';

import 'package:geolocator/geolocator.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;
  String _driverSearchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  String? _selectedServiceType; // e.g., Auto, Sedan, SUV, Delivery

  @override
  void initState() {
    super.initState();
    _checkForAcceptedRequests();
    _checkForPaidRidesForTracking();
  }

  final Set<String> _shownPaymentDialogs = {};

  void _checkForAcceptedRequests() {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('ride_requests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            // Only show if: Status is accepted, NOT paid, and we haven't shown a dialog for this ID yet
            if (data['status'] == 'accepted' &&
                data['paymentMethod'] == null &&
                !_shownPaymentDialogs.contains(doc.id)) {
              _shownPaymentDialogs.add(doc.id);
              _showPaymentDialog(doc.id, data);
            }
          }
        });
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Mycolors.basecolor),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontSize: 13, color: Mycolors.gray),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _checkForPaidRidesForTracking() {
    // Check for paid rides and show tracking screen automatically
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('ride_requests')
        .where('userId', isEqualTo: userId)
        .where('isPaid', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final status = (data['status'] ?? '').toString().toLowerCase();
            // Show tracking if ride is paid and ongoing (not yet completed)
            if (data['isPaid'] == true && status != 'completed') {
              _showTrackingScreen(doc.id, data);
            }
          }
        });
  }

  void _showTrackingScreen(String requestId, Map<String, dynamic> requestData) {
    // Navigate to tracking screen
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => DriverTrackingScreen(
              bookingId: requestId,
              initialBookingData: requestData,
            ),
          ),
        )
        .then((_) {
          // After tracking screen closes, check if ride is completed
          // If not, show tracking again
          _checkForPaidRidesForTracking();
        });
  }

  void _showPaymentDialog(String requestId, Map<String, dynamic> requestData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Ride Accepted!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your driver has accepted your ride request.',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.person,
                'Driver',
                requestData['driverName'] ?? 'Driver',
              ),
              _buildDetailRow(
                Icons.place,
                'To',
                requestData['destination'] ?? 'Destination',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Mycolors.basecolor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Mycolors.basecolor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Agreed Fare:',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '₹${requestData['fare'] ?? '150'}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Mycolors.basecolor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please proceed to payment to confirm your ride.',
                style: GoogleFonts.poppins(fontSize: 12, color: Mycolors.gray),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      requestId: requestId,
                      driverName: requestData['driverName'] ?? 'Driver',
                      destination: requestData['destination'] ?? 'Destination',
                      amount: (requestData['fare'] is num)
                          ? (requestData['fare'] as num).toDouble()
                          : 150.0,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text('Pay Now', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
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
                onTap: () {
                  _launchCaller('100');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.medical_services, color: Colors.red),
                title: const Text('Call Ambulance (102)'),
                onTap: () {
                  _launchCaller('102');
                  Navigator.pop(context);
                },
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
              onPressed: () async {
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                nav.pop();

                // Show loading
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Sending SOS... Please wait.'),
                    duration: Duration(seconds: 2),
                  ),
                );

                try {
                  // Get current position
                  Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );

                  final userId = AuthService.currentUserId;
                  if (userId == null) return;

                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get();
                  final userData = userDoc.data() ?? {};

                  // Get active booking if any
                  final bookingSnap = await FirebaseFirestore.instance
                      .collection('ride_requests')
                      .where('userId', isEqualTo: userId)
                      .where(
                        'status',
                        whereIn: ['ongoing', 'started', 'accepted'],
                      )
                      .limit(1)
                      .get();

                  String? bookingId;
                  if (bookingSnap.docs.isNotEmpty) {
                    bookingId = bookingSnap.docs.first.id;
                  }

                  final result = await UserService.sendSOS(
                    userId: userId,
                    userName: userData['name'] ?? 'User',
                    userPhone: userData['phone'] ?? 'N/A',
                    latitude: position.latitude,
                    longitude: position.longitude,
                    bookingId: bookingId,
                  );

                  if (result['success']) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: const Text(
                          'SOS Alert Sent! Help is on the way.',
                        ),
                        backgroundColor: Mycolors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Failed to send SOS: ${result['error']}'),
                        backgroundColor: Mycolors.red,
                      ),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error getting location: $e'),
                      backgroundColor: Mycolors.red,
                    ),
                  );
                }
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

  void _launchCaller(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverChatbotScreen(),
            ),
          );
        },
        backgroundColor: Mycolors.basecolor,
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildSearchTab(),
            _buildHistoryTab(),

            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          NavBarItem(icon: Icons.home, label: 'Home'),
          NavBarItem(icon: Icons.search, label: 'Search'),
          NavBarItem(icon: Icons.history, label: 'History'),

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
              // Welcome Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back!",
                          style: ResponsiveTextStyles.getTitleStyle(context),
                        ),
                        Text(
                          "How can we help you today?",
                          style: ResponsiveTextStyles.getSubtitleStyle(context),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 25,
                      tablet: 30,
                      desktop: 35,
                    ),
                    backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: Mycolors.basecolor,
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
              SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),

              // Quick Actions
              Text(
                "Quick Actions",
                style: ResponsiveTextStyles.getTitleStyle(context),
              ),
              SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

              // Service Cards - Responsive Grid
              ResponsiveWidget(
                mobile: _buildMobileServiceGrid(context),
                tablet: _buildTabletServiceGrid(context),
                desktop: _buildDesktopServiceGrid(context),
              ),

              SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),

              // Recent Rides
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Rides",
                    style: ResponsiveTextStyles.getTitleStyle(context),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RideHistoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "View All",
                      style: GoogleFonts.poppins(
                        color: Mycolors.basecolor,
                        fontWeight: FontWeight.w600,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

              // Recent Rides - Firestore
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: UserService.getCurrentUserRidesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Failed to load rides',
                      style: GoogleFonts.poppins(color: Mycolors.red),
                    );
                  }
                  final rides = snapshot.data ?? [];
                  if (rides.isEmpty) {
                    return Text(
                      'No recent rides',
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    );
                  }
                  return Column(
                    children: rides.take(3).map((r) {
                      final status = _statusString(r['status']);
                      final statusColor = _statusColor(status);
                      final price = r['fare'] != null ? '₹${r['fare']}' : '';
                      final createdAt = _formatDate(r['createdAt']);
                      final title = r['destination'] ?? r['to'] ?? 'Ride';
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: ResponsiveSpacing.getSmallSpacing(context),
                        ),
                        child: _buildRecentRideCard(
                          context,
                          title,
                          createdAt,
                          price,
                          status,
                          statusColor,
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

  Widget _buildSearchTab() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _driverSearchQuery = value.trim();
              });
            },
            decoration: InputDecoration(
              hintText: "Search drivers, locations...",
              prefixIcon: Icon(
                Icons.search,
                color: Mycolors.basecolor,
                size: ResponsiveUtils.getResponsiveIconSize(
                  context,
                  mobile: 24,
                  tablet: 26,
                  desktop: 28,
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

          // Active filters (service type)
          if (_selectedServiceType != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    label: Text(
                      'Vehicle: ${_selectedServiceType!}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedServiceType = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          if (_selectedServiceType != null)
            SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),

          // Search Results - Firestore drivers
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: UserService.getDriversStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              List<Map<String, dynamic>> drivers = snapshot.data ?? [];

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Error loading drivers: ${snapshot.error}',
                      style: GoogleFonts.poppins(color: Mycolors.red),
                    ),
                  ),
                );
              }

              // Filter by selected service type (vehicle type) strictly
              if (_selectedServiceType != null &&
                  _selectedServiceType!.isNotEmpty) {
                final vt = _selectedServiceType!.toLowerCase();
                drivers = drivers.where((d) {
                  final vehicleType =
                      (d['vehicleType'] ?? d['documents']?['vehicleType'] ?? '')
                          .toString()
                          .toLowerCase();
                  return vehicleType == vt;
                }).toList();
              }

              // Filter by search query (name, email, vehicleType)
              if (_driverSearchQuery.isNotEmpty) {
                final q = _driverSearchQuery.toLowerCase();
                drivers = drivers.where((d) {
                  final name = (d['name'] ?? d['fullName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final email = (d['email'] ?? '').toString().toLowerCase();
                  final vehicleType =
                      (d['vehicleType'] ?? d['documents']?['vehicleType'] ?? '')
                          .toString()
                          .toLowerCase();
                  return name.contains(q) ||
                      email.contains(q) ||
                      vehicleType.contains(q);
                }).toList();
              }

              // IF NO QUERY AND NO DRIVERS (or just starting), show the placeholder
              if (_driverSearchQuery.isEmpty &&
                  _selectedServiceType == null &&
                  drivers.isEmpty) {
                return Column(
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Mycolors.basecolor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.map_outlined,
                        size: 64,
                        color: Mycolors.basecolor.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Explore more with RelyGO",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      "Enter a destination to find available drivers",
                      style: GoogleFonts.poppins(
                        color: Mycolors.gray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }

              if (drivers.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No drivers found for "$_driverSearchQuery"',
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final d = drivers[index];
                  final name = d['name'] ?? d['fullName'] ?? 'Driver';
                  final rating = (d['rating'] is num)
                      ? (d['rating'] as num).toDouble()
                      : 0.0;
                  final displayRating = rating == 0
                      ? 'New'
                      : '${rating.toStringAsFixed(1)} ⭐';
                  final rawStatus = (d['status'] ?? '')
                      .toString()
                      .toLowerCase();
                  final isAvailable =
                      rawStatus == 'approved' ||
                      rawStatus == 'active' ||
                      (d['availability'] ?? 'available') == 'available';
                  final status = isAvailable ? 'Available' : 'Busy';
                  final statusColor = isAvailable
                      ? Mycolors.green
                      : Mycolors.orange;
                  final distance = d['distanceText'] ?? '';
                  final price = d['baseFare'] != null
                      ? '₹${d['baseFare']}'
                      : '₹150'; // Default price
                  return GestureDetector(
                    onTap: () => _showDriverDetailsSheet(d),
                    child: _buildDriverCard(
                      context,
                      name,
                      displayRating,
                      distance,
                      status,
                      statusColor,
                      price,
                      d,
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

  void _showDriverDetailsSheet(Map<String, dynamic> driver) {
    final String driverId = (driver['id'] ?? '').toString();
    final String name = (driver['name'] ?? driver['fullName'] ?? 'Driver')
        .toString();
    final String email = (driver['email'] ?? '').toString();
    final String phone = (driver['phone'] ?? driver['phoneNumber'] ?? '')
        .toString();
    final double rating = (driver['rating'] is num)
        ? (driver['rating'] as num).toDouble()
        : 0.0;
    final String vehicleType =
        (driver['vehicleType'] ?? driver['documents']?['vehicleType'] ?? '')
            .toString();
    final String vehicleNumber =
        (driver['vehicleNumber'] ?? driver['documents']?['vehicleNumber'] ?? '')
            .toString();
    final String rawStatus = (driver['status'] ?? '').toString().toLowerCase();
    final bool isAvailable =
        rawStatus == 'approved' ||
        rawStatus == 'active' ||
        (driver['availability'] ?? 'available') == 'available';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                        child: Text(
                          name.isNotEmpty ? name[0] : 'D',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Mycolors.basecolor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (email.isNotEmpty)
                              Text(
                                email,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Mycolors.gray,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, color: Mycolors.orange, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        rating == 0 ? 'New' : rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (vehicleType.isNotEmpty || vehicleNumber.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Mycolors.gray,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            vehicleNumber.isNotEmpty
                                ? "$vehicleType  •  $vehicleNumber"
                                : vehicleType,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isAvailable ? Mycolors.green : Mycolors.orange)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                (isAvailable ? Mycolors.green : Mycolors.orange)
                                    .withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAvailable
                                  ? Icons.check_circle
                                  : Icons.pause_circle,
                              color: isAvailable
                                  ? Mycolors.green
                                  : Mycolors.orange,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAvailable ? 'Available' : 'Busy',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isAvailable
                                    ? Mycolors.green
                                    : Mycolors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (phone.isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.phone, color: Mycolors.green),
                      title: Text(phone, style: GoogleFonts.poppins()),
                      onTap: () {
                        _showContactOptions(name, phone, driverId);
                      },
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Feedback',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 240,
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: AdminService.getFeedbackStream(
                        driverId: driverId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final items = snapshot.data ?? [];
                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              'No feedback yet',
                              style: GoogleFonts.poppins(color: Mycolors.gray),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 12),
                          itemBuilder: (context, index) {
                            final f = items[index];
                            final fr = (f['rating'] is num)
                                ? (f['rating'] as num).toDouble()
                                : 0.0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Mycolors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      fr.toStringAsFixed(1),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (f['comment'] ?? '').toString(),
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showContactOptions(String name, String phone, String driverId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Contact $name',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone, color: Mycolors.green),
                title: Text('Call', style: GoogleFonts.poppins()),
                subtitle: Text(phone, style: GoogleFonts.poppins(fontSize: 12)),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling $phone...'),
                      backgroundColor: Mycolors.green,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _promptBookingMode({
    required String driverId,
    required String driverName,
    String? vehicleType,
  }) {
    // Directly book with this driver - no dialog needed
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ServiceBookingScreen(),
        settings: RouteSettings(
          arguments: {
            'driverId': driverId,
            'driverName': driverName,
            if (vehicleType != null && vehicleType.isNotEmpty)
              'vehicle': vehicleType,
          },
        ),
      ),
    );
  }

  Future<void> _handleTrackDriver() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;
    final ride = await UserService.getActiveBookingOnce(userId);
    if (!mounted) return;
    if (ride != null && ride['driverId'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverTrackingScreen(
            bookingId: ride['id'] ?? '',
            initialBookingData: ride,
          ),
        ),
      );
    } else if (ride != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No driver assigned yet'),
          backgroundColor: Mycolors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No active rides found'),
          backgroundColor: Mycolors.orange,
        ),
      );
    }
  }

  void _promptHomeBooking() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How would you like to book?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.person_search, color: Mycolors.basecolor),
                  title: Text('Choose Driver', style: GoogleFonts.poppins()),
                  subtitle: Text(
                    'Browse and select a driver',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Mycolors.gray,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedIndex = 1; // switch to Search tab
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Use the Search tab to pick a driver'),
                        backgroundColor: Mycolors.basecolor,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.local_taxi, color: Mycolors.orange),
                  title: Text(
                    'Choose Service Type',
                    style: GoogleFonts.poppins(),
                  ),
                  subtitle: Text(
                    'Auto, Sedan, SUV, Delivery, etc.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Mycolors.gray,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showServiceTypePicker();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showServiceTypePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final types = <Map<String, dynamic>>[
          {'label': 'Auto', 'icon': Icons.two_wheeler},
          {'label': 'Sedan', 'icon': Icons.directions_car},
          {'label': 'SUV', 'icon': Icons.airport_shuttle},
          {'label': 'Delivery', 'icon': Icons.local_shipping},
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Service Type',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...types.map(
                  (t) => ListTile(
                    leading: Icon(
                      t['icon'] as IconData,
                      color: Mycolors.basecolor,
                    ),
                    title: Text(
                      t['label'] as String,
                      style: GoogleFonts.poppins(),
                    ),
                    onTap: () {
                      final vehicle = (t['label'] as String);
                      Navigator.of(context).pop();
                      setState(() {
                        _selectedIndex = 1; // go to Search tab
                        _driverSearchQuery = vehicle.toLowerCase();
                        _searchController.text = vehicle;
                        _selectedServiceType =
                            vehicle; // apply strict vehicle filter
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Filtering drivers by $vehicle'),
                          backgroundColor: Mycolors.basecolor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEmergencySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.emergency, color: Mycolors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Emergency Contacts',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(Icons.local_police, color: Mycolors.basecolor),
                  title: Text('Police Station', style: GoogleFonts.poppins()),
                  subtitle: Text(
                    '100',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Mycolors.gray,
                    ),
                  ),
                  trailing: Icon(Icons.call, color: Mycolors.basecolor),
                  onTap: () => _callNumber('100'),
                ),
                ListTile(
                  leading: Icon(Icons.local_hospital, color: Mycolors.green),
                  title: Text('Ambulance', style: GoogleFonts.poppins()),
                  subtitle: Text(
                    '102',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Mycolors.gray,
                    ),
                  ),
                  trailing: Icon(Icons.call, color: Mycolors.basecolor),
                  onTap: () => _callNumber('102'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.local_fire_department,
                    color: Mycolors.orange,
                  ),
                  title: Text('Fire Force', style: GoogleFonts.poppins()),
                  subtitle: Text(
                    '101',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Mycolors.gray,
                    ),
                  ),
                  trailing: Icon(Icons.call, color: Mycolors.basecolor),
                  onTap: () => _callNumber('101'),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to start call to $number'),
            backgroundColor: Mycolors.red,
          ),
        );
      }
    }
  }

  Widget _buildHistoryTab() {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      return const Center(child: Text('Please log in to view history'));
    }

    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
          Text(
            'Booking History',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

          // Active Booking Tracking
          StreamBuilder<Map<String, dynamic>?>(
            stream: UserService.getActiveBookingStream(userId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final activeBooking = snapshot.data!;
                final status =
                    activeBooking['status']?.toString().toLowerCase() ??
                    'unknown';
                final isStarted = status == 'started';

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isStarted
                        ? Mycolors.green.withOpacity(0.1)
                        : Mycolors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isStarted
                          ? Mycolors.green.withOpacity(0.3)
                          : Mycolors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isStarted ? Icons.local_taxi : Icons.schedule,
                            color: isStarted ? Mycolors.green : Mycolors.orange,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isStarted ? 'Ride in Progress' : 'Upcoming Ride',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isStarted
                                  ? Mycolors.green
                                  : Mycolors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Status: ${status.toUpperCase()}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      if (activeBooking['driverDetails'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Driver: ${activeBooking['driverDetails']['name'] ?? 'Unknown'}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                      if (!isStarted && status == 'accepted') ...[
                        const SizedBox(height: 8),
                        Text(
                          'Please pay to confirm and enable tracking.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Mycolors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (isStarted) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriverTrackingScreen(
                                    bookingId: activeBooking['id'] ?? '',
                                    initialBookingData: activeBooking,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.location_searching),
                            label: const Text('Track Driver Live'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Mycolors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Booking History List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: UserService.getUserBookingHistoryStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading history',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                final bookings = snapshot.data ?? [];

                if (bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No booking history',
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
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _buildBookingHistoryCard(booking);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHistoryCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'unknown';
    final driverDetails = booking['driverDetails'] as Map<String, dynamic>?;

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Mycolors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Mycolors.red;
        statusIcon = Icons.cancel;
        break;
      case 'ongoing':
        statusColor = Mycolors.orange;
        statusIcon = Icons.local_taxi;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    String formattedDate = 'Recently';
    try {
      if (booking['createdAt'] != null) {
        final Timestamp timestamp = booking['createdAt'];
        final DateTime dateTime = timestamp.toDate();
        formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      formattedDate = 'Recently';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Date
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Route
          Row(
            children: [
              Icon(Icons.location_on, color: Mycolors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking['pickupLocation'] ?? 'Unknown pickup',
                  style: GoogleFonts.poppins(fontSize: 14),
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
                  booking['dropoffLocation'] ?? 'Unknown dropoff',
                  style: GoogleFonts.poppins(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Driver and Fare
          Row(
            children: [
              Icon(Icons.person, color: Theme.of(context).hintColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  driverDetails?['name'] ?? 'Driver not assigned',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
              if (booking['fare'] != null) ...[
                Text(
                  '₹${booking['fare']}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Mycolors.basecolor,
                  ),
                ),
              ],
            ],
          ),

          // Action buttons for active or completed rides
          if (driverDetails != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (status.toLowerCase() == 'completed') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showFeedbackDialog(booking),
                      icon: const Icon(Icons.star, size: 16),
                      label: const Text('Rate & Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showComplaintDialog(booking),
                      icon: const Icon(Icons.report_problem, size: 16),
                      label: const Text('Complain'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Mycolors.red,
                        side: BorderSide(color: Mycolors.red),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ] else if (status.toLowerCase() == 'ongoing' ||
                    status.toLowerCase() == 'started') ...[
                  if (status.toLowerCase() == 'started') ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverTrackingScreen(
                                bookingId: booking['id'],
                                initialBookingData: booking,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map, size: 16),
                        label: const Text('Track Driver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return const UserProfileScreen();
  }

  // Mobile Service Grid - 2x2
  Widget _buildMobileServiceGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                context,
                "Search Drivers",
                Icons.search,
                Mycolors.basecolor,
                () {
                  _promptHomeBooking();
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
            Expanded(
              child: _buildServiceCard(
                context,
                "Ride History",
                Icons.history,
                Mycolors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                context,
                "Emergency",
                Icons.emergency,
                Mycolors.red,
                () {
                  _showEmergencySheet();
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
            Expanded(
              child: _buildServiceCard(
                context,
                "Track Driver",
                Icons.my_location,
                Mycolors.green,
                () => _handleTrackDriver(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Tablet Service Grid - 2x2 with larger spacing
  Widget _buildTabletServiceGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                context,
                "Search Drivers",
                Icons.search,
                Mycolors.basecolor,
                () {
                  _promptHomeBooking();
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
            Expanded(
              child: _buildServiceCard(
                context,
                "Ride History",
                Icons.history,
                Mycolors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                context,
                "Emergency",
                Icons.emergency,
                Mycolors.red,
                () {
                  _showEmergencySheet();
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
            Expanded(
              child: _buildServiceCard(
                context,
                "Track Driver",
                Icons.my_location,
                Mycolors.green,
                () => _handleTrackDriver(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Desktop Service Grid - 4 columns
  Widget _buildDesktopServiceGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildServiceCard(
            context,
            "Search Drivers",
            Icons.search,
            Mycolors.basecolor,
            () {
              setState(() => _selectedIndex = 1);
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildServiceCard(
            context,
            "Ride History",
            Icons.history,
            Mycolors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RideHistoryScreen()),
              );
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildServiceCard(
            context,
            "Emergency",
            Icons.emergency,
            Mycolors.red,
            () {
              _showEmergencySheet();
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildServiceCard(
            context,
            "Track Driver",
            Icons.my_location,
            Mycolors.green,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Live driver tracking coming soon'),
                  backgroundColor: Mycolors.basecolor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
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
    String time,
    String price,
    String status,
    Color statusColor,
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
            child: Icon(
              Icons.directions_car,
              color: Mycolors.basecolor,
              size: ResponsiveUtils.getResponsiveIconSize(
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
                  ),
                ),
                Text(
                  time,
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
              Text(
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
            ],
          ),
        ],
      ),
    );
  }

  String _statusString(dynamic raw) {
    final v = (raw ?? '').toString().toLowerCase();
    if (v == 'completed') return 'Completed';
    if (v == 'cancelled') return 'Cancelled';
    if (v == 'scheduled') return 'Scheduled';
    return 'Completed';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Mycolors.green;
      case 'Cancelled':
        return Mycolors.red;
      case 'Scheduled':
        return Mycolors.basecolor;
      default:
        return Mycolors.gray;
    }
  }

  String _formatDate(dynamic createdAt) {
    try {
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      }
      return createdAt?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Widget _buildDriverCard(
    BuildContext context,
    String name,
    String rating,
    String distance,
    String status,
    Color statusColor,
    String price,
    Map<String, dynamic> driverData,
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
      child: Row(
        children: [
          CircleAvatar(
            radius: ResponsiveUtils.getResponsiveSpacing(
              context,
              mobile: 25,
              tablet: 28,
              desktop: 32,
            ),
            backgroundColor: Mycolors.basecolor.withOpacity(0.1),
            child: Text(
              name[0],
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
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
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  rating,
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
              ],
            ),
          ),
          Column(
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
                  color: Mycolors.basecolor,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
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
              SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
              ElevatedButton(
                onPressed: () {
                  _promptBookingMode(
                    driverId: driverData['id']?.toString() ?? '',
                    driverName: name,
                    vehicleType: driverData['vehicleType']?.toString(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.basecolor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(
                        context,
                        mobile: 8,
                        tablet: 10,
                        desktop: 12,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    vertical: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 8,
                      tablet: 10,
                      desktop: 12,
                    ),
                  ),
                ),
                child: Text(
                  "Book",
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
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

  void _showFeedbackDialog(Map<String, dynamic> booking) {
    final driverDetails = booking['driverDetails'] as Map<String, dynamic>?;
    if (driverDetails == null) return;

    int selectedRating = 5;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.star, color: Mycolors.orange, size: 24),
              const SizedBox(width: 12),
              Text(
                'Rate & Review',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver: ${driverDetails['name'] ?? 'Unknown'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rate your experience:',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                    child: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Mycolors.orange,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text('Write a review:', style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
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
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reviewController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please write a review'),
                      backgroundColor: Mycolors.red,
                    ),
                  );
                  return;
                }

                final userId = AuthService.currentUserId;
                if (userId == null) return;

                final result = await UserService.submitFeedback(
                  userId: userId,
                  driverId: driverDetails['id'] ?? '',
                  bookingId: booking['id'] ?? '',
                  rating: selectedRating,
                  review: reviewController.text.trim(),
                );

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] ? result['message'] : result['error'],
                    ),
                    backgroundColor: result['success']
                        ? Mycolors.green
                        : Mycolors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showComplaintDialog(Map<String, dynamic> booking) {
    final driverDetails = booking['driverDetails'] as Map<String, dynamic>?;
    if (driverDetails == null) return;

    final TextEditingController subjectController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCategory = 'general';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.report_problem, color: Mycolors.red, size: 24),
              const SizedBox(width: 12),
              Text(
                'Submit Complaint',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver: ${driverDetails['name'] ?? 'Unknown'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text('Category:', style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'general', child: Text('General')),
                  DropdownMenuItem(
                    value: 'behavior',
                    child: Text('Driver Behavior'),
                  ),
                  DropdownMenuItem(
                    value: 'vehicle',
                    child: Text('Vehicle Condition'),
                  ),
                  DropdownMenuItem(value: 'route', child: Text('Route Issues')),
                  DropdownMenuItem(
                    value: 'payment',
                    child: Text('Payment Issues'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value ?? 'general';
                  });
                },
              ),
              const SizedBox(height: 16),
              Text('Subject:', style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  hintText: 'Brief description of the issue',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Description:', style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Detailed description of the complaint...',
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
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (subjectController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Mycolors.red,
                    ),
                  );
                  return;
                }

                final userId = AuthService.currentUserId;
                if (userId == null) return;

                final result = await UserService.submitComplaint(
                  userId: userId,
                  driverId: driverDetails['id'] ?? '',
                  bookingId: booking['id'] ?? '',
                  subject: subjectController.text.trim(),
                  description: descriptionController.text.trim(),
                );

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] ? result['message'] : result['error'],
                    ),
                    backgroundColor: result['success']
                        ? Mycolors.green
                        : Mycolors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedCard(String title, IconData icon) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Mycolors.basecolor, size: 30),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
