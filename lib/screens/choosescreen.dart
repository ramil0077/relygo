import 'package:flutter/material.dart';
import 'package:relygo/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/screens/signin_screen.dart';
import 'package:relygo/screens/user_contact_screen.dart';
import 'package:relygo/screens/admin_dashboard_screen.dart';
import 'package:relygo/screens/admin_login_screen.dart';
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: ResponsiveSpacing.getLargeSpacing(context),
                    ),
                    // Brand header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/logooo.png", height: 36),
                        const SizedBox(width: 8),
                        Text(
                          "RelyGO",
                          style: ResponsiveTextStyles.getTitleStyle(context),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ResponsiveSpacing.getSmallSpacing(context),
                    ),
                    Text(
                      "Select how you want to proceed",
                      style: ResponsiveTextStyles.getSubtitleStyle(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: ResponsiveSpacing.getExtraLargeSpacing(context),
                    ),

                    // Options styled per palette
                    ResponsiveWidget(
                      mobile: _buildMobileLayout(context),
                      tablet: _buildTabletLayout(context),
                      desktop: _buildDesktopLayout(context),
                    ),

                    SizedBox(
                      height: ResponsiveSpacing.getLargeSpacing(context),
                    ),
                    // Secondary action
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminLoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Go to Admin",
                        style: GoogleFonts.poppins(
                          color: Mycolors.basecolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveSpacing.getLargeSpacing(context),
                    ),
                  ],
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
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
      child: Container(
        width: double.infinity,
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: color,
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
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
}
