import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/admin_web_dashboard_screen.dart';
import 'package:relygo/utils/platform_utils.dart';
import 'package:relygo/utils/responsive.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Hardcoded admin credentials
  final String _adminEmail = "admin@relygo.com";
  final String _adminPassword = "admin123";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 40, tablet: 50, desktop: 60)),

              // Logo and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 80, tablet: 100, desktop: 120),
                      height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 80, tablet: 100, desktop: 120),
                      decoration: BoxDecoration(
                        color: Mycolors.basecolor,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 20, tablet: 24, desktop: 28),
                        ),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 40, tablet: 50, desktop: 60),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28)),
                    Text(
                      "Admin Login",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 28, tablet: 32, desktop: 36),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                    Text(
                      "RelyGO Administration Panel",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                        color: Mycolors.gray,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 50, tablet: 60, desktop: 70)),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Field
                    Text(
                      "Email Address",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Enter admin email",
                        prefixIcon: Icon(
                          Icons.email,
                          color: Mycolors.basecolor,
                          size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24, tablet: 26, desktop: 28),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
                          ),
                          borderSide: BorderSide(
                            color: Mycolors.basecolor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28)),

                    // Password Field
                    Text(
                      "Password",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Enter password",
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Mycolors.basecolor,
                          size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24, tablet: 26, desktop: 28),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Mycolors.gray,
                            size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24, tablet: 26, desktop: 28),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
                          ),
                          borderSide: BorderSide(
                            color: Mycolors.basecolor,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 30, tablet: 36, desktop: 40)),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 55, tablet: 60, desktop: 65),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Mycolors.basecolor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
                            ),
                          ),
                          elevation: ResponsiveUtils.getResponsiveElevation(context, mobile: 2, tablet: 3, desktop: 4),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 22, desktop: 24),
                                height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 22, desktop: 24),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                                  fontWeight: FontWeight.w600,
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
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check credentials
    if (_emailController.text.trim() == _adminEmail &&
        _passwordController.text == _adminPassword) {
      // Success - redirect to web admin dashboard
      if (mounted) {
        if (PlatformUtils.isWeb) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminWebDashboardScreen(),
            ),
          );
        } else {
          // Should not happen as admin is web-only, but handle gracefully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Admin dashboard is only available on web'),
              backgroundColor: Mycolors.red,
            ),
          );
        }
      }
    } else {
      // Error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid email or password'),
            backgroundColor: Mycolors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }
}
