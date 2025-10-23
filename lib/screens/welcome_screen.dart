import 'package:flutter/material.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/user_dashboard_screen.dart';
import 'package:relygo/screens/driver_dashboard_screen.dart';
import 'package:relygo/utils/responsive.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveLayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                children: [
                  SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),
                  // Welcome Text
                  Text(
                    "Welcome to RelyGO",
                    style: ResponsiveTextStyles.getTitleStyle(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
                  Text(
                    "What are you looking for today?",
                    style: ResponsiveTextStyles.getSubtitleStyle(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveSpacing.getExtraLargeSpacing(context),
                  ),

                  // Service Cards Container
                  ResponsiveWidget(
                    mobile: _buildMobileLayout(context),
                    tablet: _buildTabletLayout(context),
                    desktop: _buildDesktopLayout(context),
                  ),

                  const Spacer(),

                  // Bottom Navigation Bar
                  _buildBottomNavigationBar(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Mobile Layout - Single Column
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildServiceCard(
          context,
          "Chauffeur job",
          "Earn money with your car",
          'assets/logooo.png',
          [
            "• Flexible working hours",
            "• Competitive earnings",
            "• Driver support 24/7",
          ],
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DriverDashboardScreen(),
              ),
            );
          },
        ),
        SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
        _buildServiceCard(
          context,
          "Find Driver's",
          "Book rides and services",
          Icons.person,
          ["• Hospital Bookings", "• Trip Bookings", "• Grocery Shoppings"],
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const UserDashboardScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // Tablet Layout - Two Columns
  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildServiceCard(
            context,
            "Chauffeur job",
            "Earn money with your car",
            'assets/logooo.png',
            [
              "• Flexible working hours",
              "• Competitive earnings",
              "• Driver support 24/7",
            ],
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriverDashboardScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildServiceCard(
            context,
            "Find Driver's",
            "Book rides and services",
            Icons.person,
            ["• Hospital Bookings", "• Trip Bookings", "• Grocery Shoppings"],
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserDashboardScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Desktop Layout - Centered with max width
  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: ResponsiveUtils.getResponsiveConstraints(context),
        child: Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                context,
                "Chauffeur job",
                "Earn money with your car",
                'assets/logooo.png',
                [
                  "• Flexible working hours",
                  "• Competitive earnings",
                  "• Driver support 24/7",
                ],
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverDashboardScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getLargeSpacing(context)),
            Expanded(
              child: _buildServiceCard(
                context,
                "Find Driver's",
                "Book rides and services",
                Icons.person,
                [
                  "• Hospital Bookings",
                  "• Trip Bookings",
                  "• Grocery Shoppings",
                ],
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserDashboardScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String subtitle,
    dynamic icon,
    List<String> features,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
          boxShadow: [
            BoxShadow(
              color: Mycolors.basecolor.withOpacity(0.3),
              blurRadius: ResponsiveUtils.getResponsiveElevation(
                context,
                mobile: 10,
                tablet: 12,
                desktop: 15,
              ),
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
            // Icon
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 15,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: icon is String
                  ? Image.asset(
                      icon,
                      width: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 30,
                        tablet: 35,
                        desktop: 40,
                      ),
                      height: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 30,
                        tablet: 35,
                        desktop: 40,
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveIconSize(
                        context,
                        mobile: 30,
                        tablet: 35,
                        desktop: 40,
                      ),
                    ),
            ),
            SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
            Text(
              title,
              style: ResponsiveTextStyles.getCardTitleStyle(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveSpacing.getSmallSpacing(context) / 2),
            Text(
              subtitle,
              style: ResponsiveTextStyles.getCardSubtitleStyle(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveSpacing.getMediumSpacing(context)),
            // Features
            Column(
              children: features
                  .map((feature) => _buildFeatureItem(context, feature))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveSpacing.getSmallSpacing(context) / 4,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: ResponsiveTextStyles.getFeatureTextStyle(context),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsiveVerticalPadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: ResponsiveUtils.getResponsiveElevation(
              context,
              mobile: 10,
              tablet: 12,
              desktop: 15,
            ),
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, "Home", true),
          _buildNavItem(context, Icons.search, "Search", false),
          _buildNavItem(context, Icons.add, "Plus", false),
          _buildNavItem(context, Icons.chat, "Chat", false),
          _buildNavItem(context, Icons.person, "Profile", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? Mycolors.basecolor : Colors.grey,
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
          style: ResponsiveTextStyles.getNavLabelStyle(context, isActive),
        ),
      ],
    );
  }
}
