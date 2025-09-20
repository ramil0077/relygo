import 'package:flutter/material.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/signin_screen.dart';
import 'package:relygo/screens/user_contact_screen.dart';
import 'package:relygo/screens/admin_dashboard_screen.dart';
import 'package:relygo/utils/responsive.dart';

class Registration extends StatelessWidget {
  const Registration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveLayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: ResponsiveUtils.getResponsiveConstraints(
                    context,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: ResponsiveSpacing.getLargeSpacing(context),
                      ),
                      Text(
                        "Welcome to RelyGO",
                        style: ResponsiveTextStyles.getTitleStyle(context),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: ResponsiveSpacing.getSmallSpacing(context) / 2,
                      ),
                      Text(
                        "What are you looking for today?",
                        style: ResponsiveTextStyles.getSubtitleStyle(context),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: ResponsiveSpacing.getExtraLargeSpacing(context),
                      ),

                      // Service Cards
                      ResponsiveWidget(
                        mobile: _buildMobileLayout(context),
                        tablet: _buildTabletLayout(context),
                        desktop: _buildDesktopLayout(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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
          "Looking for a job?",
          "Join as a driver and start earning",
          Icons.directions_car,
          Mycolors.basecolor,
          [
            "• Flexible working hours",
            "• Competitive earnings",
            "• Driver support 24/7",
          ],
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          },
        ),
        SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),
        _buildServiceCard(
          context,
          "Need Service?",
          "Book rides and services",
          Icons.local_shipping,
          Mycolors.basecolor,
          ["• Hospital Bookings", "• Trip Bookings", "• Grocery Shoppings"],
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserContactScreen(),
              ),
            );
          },
        ),
        SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),
        _buildServiceCard(
          context,
          "Admin Panel",
          "Manage trucks and drivers",
          Icons.admin_panel_settings,
          Mycolors.orange,
          [
            "• Truck Management",
            "• Driver Verification",
            "• System Administration",
          ],
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // Tablet Layout - Two Columns
  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildServiceCard(
                context,
                "Looking for a job?",
                "Join as a driver and start earning",
                Icons.directions_car,
                Mycolors.basecolor,
                [
                  "• Flexible working hours",
                  "• Competitive earnings",
                  "• Driver support 24/7",
                ],
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
            Expanded(
              child: _buildServiceCard(
                context,
                "Need Service?",
                "Book rides and services",
                Icons.local_shipping,
                Mycolors.basecolor,
                [
                  "• Hospital Bookings",
                  "• Trip Bookings",
                  "• Grocery Shoppings",
                ],
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserContactScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.getLargeSpacing(context)),
        _buildServiceCard(
          context,
          "Admin Panel",
          "Manage trucks and drivers",
          Icons.admin_panel_settings,
          Mycolors.orange,
          [
            "• Truck Management",
            "• Driver Verification",
            "• System Administration",
          ],
          () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // Desktop Layout - Three Columns
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildServiceCard(
            context,
            "Looking for a job?",
            "Join as a driver and start earning",
            Icons.directions_car,
            Mycolors.basecolor,
            [
              "• Flexible working hours",
              "• Competitive earnings",
              "• Driver support 24/7",
            ],
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildServiceCard(
            context,
            "Need Service?",
            "Book rides and services",
            Icons.local_shipping,
            Mycolors.basecolor,
            ["• Hospital Bookings", "• Trip Bookings", "• Grocery Shoppings"],
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserContactScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.getMediumSpacing(context)),
        Expanded(
          child: _buildServiceCard(
            context,
            "Admin Panel",
            "Manage trucks and drivers",
            Icons.admin_panel_settings,
            Mycolors.orange,
            [
              "• Truck Management",
              "• Driver Verification",
              "• System Administration",
            ],
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen(),
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
    String subtitle,
    IconData icon,
    Color color,
    List<String> features,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
            ),
          ),
        ),
        elevation: ResponsiveUtils.getResponsiveElevation(
          context,
          mobile: 4,
          tablet: 6,
          desktop: 8,
        ),
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: ResponsiveSpacing.getSmallSpacing(context)),
              // Icon
              CircleAvatar(
                radius: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  mobile: 20,
                  tablet: 24,
                  desktop: 28,
                ),
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(
                    context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
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
}
