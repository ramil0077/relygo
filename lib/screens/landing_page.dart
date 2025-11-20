import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/admin_login_screen.dart';
import 'package:relygo/utils/responsive.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    GlobalKey? targetKey;
    switch (section) {
      case 'about':
        targetKey = _aboutKey;
        break;
      case 'services':
        targetKey = _servicesKey;
        break;
      case 'contact':
        targetKey = _contactKey;
        break;
    }

    if (targetKey != null && targetKey.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1, // Scroll to show section near top
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: isMobile ? _buildMobileDrawer() : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar / Navigation
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 6,
                    tablet: 8,
                    desktop: 8,
                  )),
                  decoration: BoxDecoration(
                    color: Mycolors.basecolor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_taxi,
                    color: Colors.white,
                    size: ResponsiveUtils.getResponsiveIconSize(
                      context,
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                )),
                Text(
                  'RelyGo',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 24,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Mycolors.basecolor,
                  ),
                ),
              ],
            ),
            actions: isMobile
                ? [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ]
                : [
                    TextButton(
                      onPressed: () => _scrollToSection('about'),
                      child: Text(
                        'About',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _scrollToSection('services'),
                      child: Text(
                        'Services',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _scrollToSection('contact'),
                      child: Text(
                        'Contact',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 15,
                            desktop: 16,
                          ),
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 8,
                      tablet: 12,
                      desktop: 16,
                    )),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Mycolors.basecolor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            mobile: 16,
                            tablet: 20,
                            desktop: 24,
                          ),
                          vertical: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            mobile: 8,
                            tablet: 10,
                            desktop: 12,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Login',
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
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      mobile: 12,
                      tablet: 16,
                      desktop: 24,
                    )),
                  ],
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                mobile: 400,
                tablet: 500,
                desktop: 600,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Mycolors.basecolor.withOpacity(0.1),
                    Mycolors.basecolor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        decoration: BoxDecoration(
                          color: Mycolors.basecolor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.local_taxi,
                          size: ResponsiveUtils.getResponsiveIconSize(
                            context,
                            mobile: 60,
                            tablet: 70,
                            desktop: 80,
                          ),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 24,
                        tablet: 28,
                        desktop: 32,
                      )),
                      Text(
                        'Welcome to RelyGo',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 32,
                            tablet: 40,
                            desktop: 48,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      )),
                      Text(
                        'Your trusted ride-sharing and delivery platform',
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        mobile: 24,
                        tablet: 28,
                        desktop: 32,
                      )),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminLoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors.basecolor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              mobile: 32,
                              tablet: 40,
                              desktop: 48,
                            ),
                            vertical: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Admin Login',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              mobile: 16,
                              tablet: 17,
                              desktop: 18,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // About Section
          SliverToBoxAdapter(
            child: Container(
              key: _aboutKey,
              padding: ResponsiveUtils.getResponsivePadding(context),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Us',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 28,
                        tablet: 32,
                        desktop: 36,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  )),
                  Text(
                    'RelyGo is a comprehensive ride-sharing and delivery platform designed to connect users with reliable drivers. Our mission is to provide safe, convenient, and affordable transportation and delivery services.',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  )),
                  ResponsiveWidget(
                    mobile: Column(
                      children: [
                        _buildFeatureCard(
                          Icons.safety_check,
                          'Safe & Secure',
                          'Your safety is our top priority',
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        _buildFeatureCard(
                          Icons.speed,
                          'Fast & Reliable',
                          'Quick response times and reliable service',
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        _buildFeatureCard(
                          Icons.people,
                          'Trusted Drivers',
                          'Verified and professional drivers',
                        ),
                      ],
                    ),
                    tablet: Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            Icons.safety_check,
                            'Safe & Secure',
                            'Your safety is our top priority',
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        Expanded(
                          child: _buildFeatureCard(
                            Icons.speed,
                            'Fast & Reliable',
                            'Quick response times and reliable service',
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        Expanded(
                          child: _buildFeatureCard(
                            Icons.people,
                            'Trusted Drivers',
                            'Verified and professional drivers',
                          ),
                        ),
                      ],
                    ),
                    desktop: Row(
                      children: [
                        _buildFeatureCard(
                          Icons.safety_check,
                          'Safe & Secure',
                          'Your safety is our top priority',
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        _buildFeatureCard(
                          Icons.speed,
                          'Fast & Reliable',
                          'Quick response times and reliable service',
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        _buildFeatureCard(
                          Icons.people,
                          'Trusted Drivers',
                          'Verified and professional drivers',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Services Section
          SliverToBoxAdapter(
            child: Container(
              key: _servicesKey,
              padding: ResponsiveUtils.getResponsivePadding(context),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Services',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 28,
                        tablet: 32,
                        desktop: 36,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 32,
                    tablet: 40,
                    desktop: 48,
                  )),
                  ResponsiveWidget(
                    mobile: Column(
                      children: [
                        _buildServiceCard(
                          Icons.directions_car,
                          'Ride Sharing',
                          'Book rides for your daily commute',
                          Mycolors.basecolor,
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        _buildServiceCard(
                          Icons.local_shipping,
                          'Delivery',
                          'Fast and secure delivery services',
                          Mycolors.green,
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        _buildServiceCard(
                          Icons.business_center,
                          'Business Solutions',
                          'Corporate transportation solutions',
                          Mycolors.orange,
                        ),
                      ],
                    ),
                    tablet: Row(
                      children: [
                        Expanded(
                          child: _buildServiceCard(
                            Icons.directions_car,
                            'Ride Sharing',
                            'Book rides for your daily commute',
                            Mycolors.basecolor,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        Expanded(
                          child: _buildServiceCard(
                            Icons.local_shipping,
                            'Delivery',
                            'Fast and secure delivery services',
                            Mycolors.green,
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        Expanded(
                          child: _buildServiceCard(
                            Icons.business_center,
                            'Business Solutions',
                            'Corporate transportation solutions',
                            Mycolors.orange,
                          ),
                        ),
                      ],
                    ),
                    desktop: Row(
                      children: [
                        _buildServiceCard(
                          Icons.directions_car,
                          'Ride Sharing',
                          'Book rides for your daily commute',
                          Mycolors.basecolor,
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        _buildServiceCard(
                          Icons.local_shipping,
                          'Delivery',
                          'Fast and secure delivery services',
                          Mycolors.green,
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        _buildServiceCard(
                          Icons.business_center,
                          'Business Solutions',
                          'Corporate transportation solutions',
                          Mycolors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contact Section
          SliverToBoxAdapter(
            child: Container(
              key: _contactKey,
              padding: ResponsiveUtils.getResponsivePadding(context),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Us',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 28,
                        tablet: 32,
                        desktop: 36,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 32,
                    tablet: 40,
                    desktop: 48,
                  )),
                  ResponsiveWidget(
                    mobile: Column(
                      children: [
                        _buildContactCard(
                          Icons.email,
                          'Email',
                          'support@relygo.com',
                          'info@relygo.com',
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        _buildContactCard(
                          Icons.phone,
                          'Phone',
                          '+91 123 456 7890',
                          '+91 987 654 3210',
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        _buildContactCard(
                          Icons.location_on,
                          'Address',
                          '123 Main Street',
                          'City, State, ZIP',
                        ),
                      ],
                    ),
                    tablet: Row(
                      children: [
                        Expanded(
                          child: _buildContactCard(
                            Icons.email,
                            'Email',
                            'support@relygo.com',
                            'info@relygo.com',
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        Expanded(
                          child: _buildContactCard(
                            Icons.phone,
                            'Phone',
                            '+91 123 456 7890',
                            '+91 987 654 3210',
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        Expanded(
                          child: _buildContactCard(
                            Icons.location_on,
                            'Address',
                            '123 Main Street',
                            'City, State, ZIP',
                          ),
                        ),
                      ],
                    ),
                    desktop: Row(
                      children: [
                        Expanded(
                          child: _buildContactCard(
                            Icons.email,
                            'Email',
                            'support@relygo.com',
                            'info@relygo.com',
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        Expanded(
                          child: _buildContactCard(
                            Icons.phone,
                            'Phone',
                            '+91 123 456 7890',
                            '+91 987 654 3210',
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        Expanded(
                          child: _buildContactCard(
                            Icons.location_on,
                            'Address',
                            '123 Main Street',
                            'City, State, ZIP',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: ResponsiveUtils.getResponsivePadding(context),
              color: Colors.black87,
              child: Column(
                children: [
                  Text(
                    '© 2024 RelyGo. All rights reserved.',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        mobile: 12,
                        tablet: 13,
                        desktop: 14,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  )),
                  ResponsiveWidget(
                    mobile: Column(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Privacy Policy',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                tablet: 13,
                                desktop: 14,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Terms of Service',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
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
                    tablet: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Privacy Policy',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                tablet: 13,
                                desktop: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Terms of Service',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
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
                    desktop: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Privacy Policy',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                tablet: 13,
                                desktop: 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        )),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Terms of Service',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(
        context,
        mobile: 16,
        tablet: 20,
        desktop: 24,
      )),
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
          Icon(
            icon,
            size: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 32,
              tablet: 36,
              desktop: 40,
            ),
            color: Mycolors.basecolor,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          )),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 18,
                tablet: 19,
                desktop: 20,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 6,
            tablet: 7,
            desktop: 8,
          )),
          Text(
            description,
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
    );
  }

  Widget _buildServiceCard(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(
        context,
        mobile: 24,
        tablet: 28,
        desktop: 32,
      )),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 48,
              tablet: 54,
              desktop: 60,
            ),
            color: color,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          )),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 8,
            tablet: 10,
            desktop: 12,
          )),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String title,
    String line1,
    String line2,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(
        context,
        mobile: 16,
        tablet: 20,
        desktop: 24,
      )),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.getResponsiveIconSize(
              context,
              mobile: 28,
              tablet: 30,
              desktop: 32,
            ),
            color: Mycolors.basecolor,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          )),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 17,
                desktop: 18,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(
            context,
            mobile: 6,
            tablet: 7,
            desktop: 8,
          )),
          Text(
            line1,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 13,
                desktop: 14,
              ),
              color: Colors.grey[700],
            ),
          ),
          Text(
            line2,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 13,
                desktop: 14,
              ),
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Mycolors.basecolor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_taxi,
                    color: Mycolors.basecolor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'RelyGo',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('About', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              _scrollToSection('about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: Text('Services', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              _scrollToSection('services');
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail_outlined),
            title: Text('Contact', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              _scrollToSection('contact');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.login),
            title: Text('Admin Login', style: GoogleFonts.poppins()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminLoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

