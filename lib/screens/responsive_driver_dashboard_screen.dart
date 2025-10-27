import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/driver_earnings_screen.dart';
import 'package:relygo/screens/driver_reviews_screen.dart';
import 'package:relygo/screens/driver_ride_history_screen.dart';
import 'package:relygo/screens/driver_profile_screen.dart';
import 'package:relygo/widgets/animated_bottom_nav_bar.dart';
import 'package:relygo/utils/responsive.dart';
import 'package:relygo/utils/animation_utils.dart';
import 'package:relygo/services/driver_service.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResponsiveDriverDashboardScreen extends StatefulWidget {
  const ResponsiveDriverDashboardScreen({super.key});

  @override
  State<ResponsiveDriverDashboardScreen> createState() => _ResponsiveDriverDashboardScreenState();
}

class _ResponsiveDriverDashboardScreenState extends State<ResponsiveDriverDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<NavBarItem> _navItems = [
    const NavBarItem(icon: Icons.dashboard, label: 'Dashboard'),
    const NavBarItem(icon: Icons.account_balance_wallet, label: 'Earnings'),
    const NavBarItem(icon: Icons.star, label: 'Reviews'),
    const NavBarItem(icon: Icons.person, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return const DriverEarningsScreen();
      case 2:
        return const DriverReviewsScreen();
      case 3:
        return const DriverProfileScreen();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildWelcomeHeader(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 24)),
          
          // Stats Cards
          _buildStatsCards(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 24)),
          
          // Quick Actions
          _buildQuickActions(),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 24)),
          
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
        final userName = snapshot.data?['name'] ?? 'Driver';
        final status = snapshot.data?['status'] ?? 'pending';
        
        return AnimatedCard(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: ResponsiveUtils.getResponsiveSpacing(context, mobile: 25),
                    backgroundColor: Mycolors.basecolor.withOpacity(0.1),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'D',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 20),
                        fontWeight: FontWeight.bold,
                        color: Mycolors.basecolor,
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14),
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 12),
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
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

  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Stats',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16)),
        ResponsiveWidget(
          mobile: Column(
            children: [
              _buildStatCard('Total Rides', '12', Icons.directions_car, Mycolors.basecolor),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12)),
              _buildStatCard('Earnings', '₹850', Icons.account_balance_wallet, Mycolors.green),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12)),
              _buildStatCard('Rating', '4.8', Icons.star, Mycolors.orange),
            ],
          ),
          tablet: Row(
            children: [
              Expanded(child: _buildStatCard('Total Rides', '12', Icons.directions_car, Mycolors.basecolor)),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12)),
              Expanded(child: _buildStatCard('Earnings', '₹850', Icons.account_balance_wallet, Mycolors.green)),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12)),
              Expanded(child: _buildStatCard('Rating', '4.8', Icons.star, Mycolors.orange)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return AnimatedCard(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 20),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'View Earnings',
        'subtitle': 'Check your income',
        'icon': Icons.account_balance_wallet,
        'color': Mycolors.green,
        'onTap': () => setState(() => _selectedIndex = 1),
      },
      {
        'title': 'Reviews',
        'subtitle': 'See feedback',
        'icon': Icons.star,
        'color': Mycolors.orange,
        'onTap': () => setState(() => _selectedIndex = 2),
      },
      {
        'title': 'Ride History',
        'subtitle': 'Past trips',
        'icon': Icons.history,
        'color': Mycolors.basecolor,
        'onTap': () => Navigator.push(
          context,
          AnimationUtils.createSlideRoute(const DriverRideHistoryScreen()),
        ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16)),
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
                          size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              action['subtitle'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14),
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 16),
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
              crossAxisCount: 3,
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
                          size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 28),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12)),
                      Text(
                        action['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        action['subtitle'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 12),
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
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  AnimationUtils.createSlideRoute(const DriverRideHistoryScreen()),
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
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16)),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: DriverService.getDriverBookingsStream(AuthService.currentUserId ?? ''),
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
                      size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 48),
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16)),
                    Text(
                      'No bookings yet',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16),
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'You\'ll see ride requests here',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14),
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
                            color: _getStatusColor(booking['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getStatusIcon(booking['status']),
                            color: _getStatusColor(booking['status']),
                            size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['dropoffLocation'] ?? 'Destination',
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${booking['userName'] ?? 'User'} • ${_formatDate(booking['createdAt'])}',
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(booking['status']),
                            style: GoogleFonts.poppins(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 12),
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
