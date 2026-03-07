import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:relygo/screens/signin_screen.dart';
import 'package:relygo/screens/responsive_user_dashboard_screen.dart';
import 'package:relygo/screens/responsive_driver_dashboard_screen.dart';
import 'package:relygo/screens/admin_web_dashboard_screen.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/utils/platform_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // Log for debugging
        print(
          'AuthWrapper: connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}, error=${snapshot.error}',
        );

        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show error if stream encounters an error
        if (snapshot.hasError) {
          print('AuthWrapper error: ${snapshot.error}');
          return Scaffold(
            appBar: AppBar(title: const Text('Connection Error')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // Check if Firebase user is logged in
        final firebaseUser = snapshot.data;

        // If no Firebase user, check for admin login
        if (firebaseUser == null) {
          return FutureBuilder<bool>(
            future: AuthService.isAdminLoggedIn,
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // If admin is logged in, show admin dashboard
              if (adminSnapshot.data == true) {
                if (PlatformUtils.isWeb) {
                  return const AdminWebDashboardScreen();
                } else {
                  return _buildAdminMobileRestrictionScreen(context);
                }
              }

              // No user logged in, show sign in screen
              return const SignInScreen();
            },
          );
        }

        // If Firebase user is logged in, determine their role and show appropriate dashboard
        return FutureBuilder<Map<String, dynamic>?>(
          future: AuthService.getUserData(firebaseUser.uid).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('AuthWrapper: getUserData timeout');
              return null;
            },
          ),
          builder: (context, userSnapshot) {
            print(
              'AuthWrapper FutureBuilder: connectionState=${userSnapshot.connectionState}, hasData=${userSnapshot.hasData}',
            );

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasError) {
              print('AuthWrapper FutureBuilder error: ${userSnapshot.error}');
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Error: ${userSnapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            final userData = userSnapshot.data;
            final userTypeStr = (userData?['userType'] ?? 'user')
                .toString()
                .toLowerCase();
            final status = userData?['status'] ?? 'approved';

            // Enforce platform restrictions
            if (userTypeStr == 'admin' && !kIsWeb) {
              return _buildPlatformRestrictionScreen(
                context,
                'Admin access is only available on the web application. Please log in using a web browser.',
                Icons.web,
              );
            }

            if ((userTypeStr == 'user' || userTypeStr == 'driver') && kIsWeb) {
              return _buildPlatformRestrictionScreen(
                context,
                'User and Driver dashboards are only available on the mobile app. Please use your smartphone.',
                Icons.phone_android,
              );
            }

            // Show appropriate dashboard based on user type and status
            switch (userTypeStr) {
              case 'user':
                return const UserDashboardScreen();
              case 'driver':
                if (status == 'pending') {
                  return _buildPendingApprovalScreen(context, 'Driver');
                } else if (status == 'rejected') {
                  return _buildRejectedScreen(context, 'Driver');
                } else if (status == 'approved') {
                  return const DriverDashboardScreen();
                } else {
                  return _buildPendingApprovalScreen(context, 'Driver');
                }
              case 'admin':
                // Admin dashboard is web-only
                if (PlatformUtils.isWeb) {
                  return const AdminWebDashboardScreen();
                } else {
                  return _buildAdminMobileRestrictionScreen(context);
                }
              default:
                return const UserDashboardScreen();
            }
          },
        );
      },
    );
  }

  Widget _buildPendingApprovalScreen(BuildContext context, String userType) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 60,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Application Under Review',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your $userType application is being reviewed by our admin team. You will be notified once it\'s approved.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRejectedScreen(BuildContext context, String userType) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(Icons.cancel, size: 60, color: Colors.red),
              ),
              const SizedBox(height: 32),
              Text(
                'Application Rejected',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your $userType application has been rejected. Please contact support for more information or submit a new application.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await AuthService.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await AuthService.signOut();
                        // Navigate to registration screen
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/signup');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Reapply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminMobileRestrictionScreen(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Mycolors.basecolor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.computer,
                  size: 60,
                  color: Mycolors.basecolor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Admin Dashboard Available on Web Only',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The admin dashboard is designed for web browsers only. Please access it from a desktop or laptop computer.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.basecolor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}