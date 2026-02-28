import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/service_booking_screen.dart';
import 'package:relygo/screens/user_profile_screen.dart';
import 'package:relygo/screens/ride_history_screen.dart';
import 'package:relygo/screens/chat_detail_screen.dart';
import 'package:relygo/screens/payment_screen.dart';
import 'package:relygo/widgets/animated_bottom_nav_bar.dart';
import 'package:relygo/utils/responsive.dart';
import 'package:relygo/utils/animation_utils.dart';
import 'package:relygo/services/user_service.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResponsiveUserDashboardScreen extends StatefulWidget {
  const ResponsiveUserDashboardScreen({super.key});

  @override
  State<ResponsiveUserDashboardScreen> createState() =>
      _ResponsiveUserDashboardScreenState();
}

class _ResponsiveUserDashboardScreenState
    extends State<ResponsiveUserDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<NavBarItem> _navItems = [
    const NavBarItem(icon: Icons.home, label: 'Home'),
    const NavBarItem(icon: Icons.history, label: 'History'),
    const NavBarItem(icon: Icons.chat, label: 'Chat'),
    const NavBarItem(icon: Icons.person, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
    _checkForAcceptedRequests();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkForAcceptedRequests() {
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Mycolors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Mycolors.green,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ride Accepted!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your driver has accepted your ride request.',
                  style: GoogleFonts.poppins(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Mycolors.basecolor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Driver: ${requestData['driverName'] ?? 'Driver'}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Mycolors.basecolor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Destination: ${requestData['destination'] ?? 'Destination'}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                requestId: requestId,
                                driverName:
                                    requestData['driverName'] ?? 'Driver',
                                destination:
                                    requestData['destination'] ?? 'Destination',
                                amount: (requestData['fare'] ?? 0).toDouble(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Pay Now',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingQuickActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  AnimationUtils.createSlideRoute(const ServiceBookingScreen()),
                );
              },
              icon: Icons.add,
              tooltip: 'Book a Ride',
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildHistoryTab();
      case 2:
        return _buildChatTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 24),
          ),

          // Quick Actions
          _buildQuickActions(),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 24),
          ),

          // Available Drivers
          _buildAvailableDrivers(),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 24),
          ),

          // Recent Bookings
          _buildRecentBookings(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        final userName = snapshot.data?['name'] ?? 'User';
        final userType = snapshot.data?['userType'] ?? 'user';

        return AnimatedCard(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 25,
                    ),
                    backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Mycolors.basecolor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 16,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 14,
                            ),
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 20,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Mycolors.basecolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userType.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 12,
                        ),
                        fontWeight: FontWeight.w600,
                        color: Mycolors.basecolor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Book Ride',
        'subtitle': 'Find a driver',
        'icon': Icons.directions_car,
        'color': Mycolors.basecolor,
        'onTap': () => Navigator.push(
          context,
          AnimationUtils.createSlideRoute(const ServiceBookingScreen()),
        ),
      },
      {
        'title': 'Ride History',
        'subtitle': 'View past rides',
        'icon': Icons.history,
        'color': Mycolors.green,
        'onTap': () => Navigator.push(
          context,
          AnimationUtils.createSlideRoute(const RideHistoryScreen()),
        ),
      },
      {
        'title': 'Chat',
        'subtitle': 'Message drivers',
        'icon': Icons.chat,
        'color': Mycolors.orange,
        'onTap': () => Navigator.push(
          context,
          AnimationUtils.createSlideRoute(
            const ChatDetailScreen(peerName: 'Support'),
          ),
        ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              mobile: 18,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16),
        ),
        ResponsiveWidget(
          mobile: Column(
            children: actions.map((action) {
              return AnimatedListItem(
                index: actions.indexOf(action),
                child: AnimatedCard(
                  onTap: action['onTap'] as VoidCallback,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: ResponsiveUtils.getResponsiveIconSize(
                            context,
                            mobile: 24,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  mobile: 16,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              action['subtitle'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  mobile: 14,
                                ),
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: ResponsiveUtils.getResponsiveIconSize(
                          context,
                          mobile: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          tablet: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return AnimatedListItem(
                index: index,
                child: AnimatedCard(
                  onTap: action['onTap'] as VoidCallback,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: ResponsiveUtils.getResponsiveIconSize(
                            context,
                            mobile: 28,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 12,
                        ),
                      ),
                      Text(
                        action['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 16,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        action['subtitle'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 12,
                          ),
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableDrivers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Drivers',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 18,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  AnimationUtils.createSlideRoute(const ServiceBookingScreen()),
                );
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  color: Mycolors.basecolor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: UserService.getAvailableDriversStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingAnimation());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return AnimatedCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 48,
                      ),
                      color: Colors.grey[400],
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 16,
                      ),
                    ),
                    Text(
                      'No drivers available',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 16,
                        ),
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Check back later or try booking a ride',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                        ),
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            final drivers = snapshot.data!.take(3).toList();
            return Column(
              children: drivers.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> driver = entry.value;

                return AnimatedListItem(
                  index: index,
                  child: AnimatedCard(
                    onTap: () => _showDriverDetailsSheet(driver),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            mobile: 25,
                          ),
                          backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                          child: Text(
                            (driver['name'] ?? 'D')[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 18,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Mycolors.basecolor,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            mobile: 16,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver['name'] ?? 'Driver',
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                        context,
                                        mobile: 16,
                                      ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                driver['vehicleType'] ?? 'Vehicle',
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                        context,
                                        mobile: 14,
                                      ),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Mycolors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Available',
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 12,
                              ),
                              color: Mycolors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Bookings',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  mobile: 18,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  color: Mycolors.basecolor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16),
        ),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: UserService.getUserBookingHistoryStream(
            AuthService.currentUserId ?? '',
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingAnimation());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return AnimatedCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 48,
                      ),
                      color: Colors.grey[400],
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 16,
                      ),
                    ),
                    Text(
                      'No bookings yet',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 16,
                        ),
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Book your first ride to see it here',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          mobile: 14,
                        ),
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            final bookings = snapshot.data!.take(3).toList();
            return Column(
              children: bookings.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> booking = entry.value;

                return AnimatedListItem(
                  index: index,
                  child: AnimatedCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              booking['status'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getStatusIcon(booking['status']),
                            color: _getStatusColor(booking['status']),
                            size: ResponsiveUtils.getResponsiveIconSize(
                              context,
                              mobile: 20,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            mobile: 16,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['destination'] ??
                                    booking['dropoffLocation'] ??
                                    'Destination',
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                        context,
                                        mobile: 16,
                                      ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatDate(booking['createdAt']),
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                        context,
                                        mobile: 14,
                                      ),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              booking['status'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(booking['status']),
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 12,
                              ),
                              color: _getStatusColor(booking['status']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return const RideHistoryScreen();
  }

  Widget _buildChatTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ChatService.getUserConversationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingAnimation());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: ResponsiveUtils.getResponsiveIconSize(
                    context,
                    mobile: 64,
                  ),
                  color: Colors.grey[400],
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 16,
                  ),
                ),
                Text(
                  'No conversations yet',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 18,
                    ),
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Start chatting with drivers after booking a ride',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 14,
                    ),
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: ResponsiveUtils.getResponsivePadding(context),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final conversation = snapshot.data![index];
            return AnimatedListItem(
              index: index,
              child: AnimatedCard(
                onTap: () {
                  Navigator.push(
                    context,
                    AnimationUtils.createSlideRoute(
                      ChatDetailScreen(
                        peerName: conversation['peerName'] ?? 'Driver',
                        conversationId: conversation['id'],
                        peerId: conversation['peerId'],
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                    child: Text(
                      (conversation['peerName'] ?? 'D')[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Mycolors.basecolor,
                      ),
                    ),
                  ),
                  title: Text(
                    conversation['peerName'] ?? 'Driver',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    conversation['lastMessage'] ?? 'No messages yet',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: conversation['unreadCount'] > 0
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Mycolors.basecolor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conversation['unreadCount'].toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return const UserProfileScreen();
  }

  void _showDriverDetailsSheet(Map<String, dynamic> driver) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                          child: Text(
                            (driver['name'] ?? 'D')[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Mycolors.basecolor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver['name'] ?? 'Driver',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                driver['vehicleType'] ?? 'Vehicle',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Mycolors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Available',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Mycolors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            AnimationUtils.createSlideRoute(
                              const ServiceBookingScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions_car),
                        label: Text(
                          'Book This Driver',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors.basecolor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            AnimationUtils.createSlideRoute(
                              ChatDetailScreen(
                                peerName: driver['name'] ?? 'Driver',
                                peerId: driver['id']?.toString() ?? '',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: Text(
                          'Contact Driver',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Mycolors.basecolor,
                          side: BorderSide(color: Mycolors.basecolor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Mycolors.green;
      case 'cancelled':
        return Mycolors.red;
      case 'pending':
        return Mycolors.orange;
      case 'accepted':
        return Mycolors.basecolor;
      case 'ongoing':
        return Mycolors.basecolor;
      case 'paid':
        return Mycolors.green;
      default:
        return Mycolors.gray;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.directions_car;
      case 'ongoing':
        return Icons.directions_car;
      case 'paid':
        return Icons.payment;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'ongoing':
        return 'Ongoing';
      case 'paid':
        return 'Paid';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(dynamic createdAt) {
    try {
      if (createdAt is Timestamp) {
        final dt = createdAt.toDate();
        return "${dt.day}/${dt.month}/${dt.year}";
      }
      return createdAt?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}
