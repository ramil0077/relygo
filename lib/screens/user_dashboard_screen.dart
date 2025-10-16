import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/service_booking_screen.dart';
import 'package:relygo/screens/user_profile_screen.dart';
import 'package:relygo/screens/chat_detail_screen.dart';
import 'package:relygo/screens/payment_screen.dart';
import 'package:relygo/utils/responsive.dart';
import 'package:relygo/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/admin_service.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/services/chat_service.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;
  String _driverSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _checkForAcceptedRequests();
  }

  void _checkForAcceptedRequests() {
    // Check for accepted requests that need payment
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('ride_requests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data['status'] == 'accepted' && data['paymentMethod'] == null) {
              _showPaymentDialog(doc.id, data);
            }
          }
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
              const SizedBox(height: 12),
              Text(
                'Driver: ${requestData['driverName'] ?? 'Driver'}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              Text(
                'Destination: ${requestData['destination'] ?? 'Destination'}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Please proceed to payment to confirm your ride.',
                style: GoogleFonts.poppins(fontSize: 14, color: Mycolors.gray),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHomeTab(),
            _buildSearchTab(),
            // removed booking tab per requirements
            _buildChatTab(),
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
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.search, "Search", 1),
            _buildNavItem(Icons.chat, "Chat", 2),
            _buildNavItem(Icons.person, "Profile", 3),
          ],
        ),
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
                      setState(() {
                        _selectedIndex = 1; // Switch to search tab
                      });
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
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
          // Search Bar
          TextField(
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(
                    context,
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  ),
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: ResponsiveUtils.getResponsivePadding(context),
            ),
          ),
          SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),

          // Search Results - Firestore drivers
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: UserService.getDriversStream(),
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
                List<Map<String, dynamic>> drivers = snapshot.data ?? [];

                // Filter by search query (name, email, vehicleType)
                if (_driverSearchQuery.isNotEmpty) {
                  final q = _driverSearchQuery.toLowerCase();
                  drivers = drivers.where((d) {
                    final name = (d['name'] ?? d['fullName'] ?? '')
                        .toString()
                        .toLowerCase();
                    final email = (d['email'] ?? '').toString().toLowerCase();
                    final vehicleType = (d['vehicleType'] ?? '')
                        .toString()
                        .toLowerCase();
                    return name.contains(q) ||
                        email.contains(q) ||
                        vehicleType.contains(q);
                  }).toList();
                }

                if (drivers.isEmpty) {
                  return Center(
                    child: Text(
                      'No drivers available',
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    ),
                  );
                }
                return ListView.builder(
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
                        _showContactOptions(name, phone);
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

  void _showContactOptions(String name, String phone) {
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
              ListTile(
                leading: Icon(Icons.chat, color: Mycolors.basecolor),
                title: Text('Chat', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(peerName: name),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Book ride',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How would you like to book?', style: GoogleFonts.poppins()),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person, color: Mycolors.basecolor),
                title: Text('This driver', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.of(context).pop();
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
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.directions_car, color: Mycolors.orange),
                title: Text('By vehicle only', style: GoogleFonts.poppins()),
                subtitle: vehicleType != null && vehicleType.isNotEmpty
                    ? Text(
                        vehicleType,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Mycolors.gray,
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServiceBookingScreen(),
                      settings: RouteSettings(
                        arguments: {
                          if (vehicleType != null && vehicleType.isNotEmpty)
                            'vehicle': vehicleType,
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  // booking tab removed per requirements

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
                final String? myId = AuthService.currentUserId;
                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final c = conversations[index];
                    final List participants = (c['participants'] is List)
                        ? (c['participants'] as List)
                        : [];
                    final String conversationId = (c['id'] ?? '').toString();
                    final String lastMessage = (c['lastMessage'] ?? '')
                        .toString();
                    final Timestamp? updatedAt = c['updatedAt'] as Timestamp?;
                    final String timeText = updatedAt != null
                        ? _formatDate(updatedAt)
                        : '';
                    // pick a peerId (the other participant)
                    String peerId = '';
                    if (myId != null && participants.isNotEmpty) {
                      for (final p in participants) {
                        if (p != myId) {
                          peerId = p.toString();
                          break;
                        }
                      }
                    }
                    final String title = peerId.isNotEmpty
                        ? 'Chat with $peerId'
                        : 'Conversation';

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
                "Book a Ride",
                Icons.directions_car,
                Mycolors.basecolor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServiceBookingScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
            Expanded(
              child: _buildServiceCard(
                context,
                "Schedule Ride",
                Icons.schedule,
                Mycolors.orange,
                () {
                  // Navigate to schedule ride
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
                  // Navigate to emergency
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getSmallSpacing(context)),
            Expanded(
              child: _buildServiceCard(
                context,
                "Package Delivery",
                Icons.local_shipping,
                Mycolors.green,
                () {
                  // Navigate to package delivery
                },
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
                "Book a Ride",
                Icons.directions_car,
                Mycolors.basecolor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServiceBookingScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
            Expanded(
              child: _buildServiceCard(
                context,
                "Schedule Ride",
                Icons.schedule,
                Mycolors.orange,
                () {
                  // Navigate to schedule ride
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
                  // Navigate to emergency
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
            Expanded(
              child: _buildServiceCard(
                context,
                "Package Delivery",
                Icons.local_shipping,
                Mycolors.green,
                () {
                  // Navigate to package delivery
                },
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
            "Book a Ride",
            Icons.directions_car,
            Mycolors.basecolor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServiceBookingScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildServiceCard(
            context,
            "Schedule Ride",
            Icons.schedule,
            Mycolors.orange,
            () {
              // Navigate to schedule ride
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
              // Navigate to emergency
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildServiceCard(
            context,
            "Package Delivery",
            Icons.local_shipping,
            Mycolors.green,
            () {
              // Navigate to package delivery
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
                    color: Colors.black,
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
                  color: Colors.black,
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
                    color: Colors.black,
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

  Widget _buildChatCard(
    BuildContext context,
    String name,
    String message,
    String time,
    String unreadCount,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(peerName: name),
          ),
        );
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
            color: isSelected ? Mycolors.basecolor : Colors.grey,
            size: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 24,
              tablet: 26,
              desktop: 28,
            ),
          ),
          SizedBox(height: ResponsiveSpacing.getSmallSpacing(context) / 2),
          Text(
            label,
            style: ResponsiveTextStyles.getNavLabelStyle(context, isSelected),
          ),
        ],
      ),
    );
  }
}
