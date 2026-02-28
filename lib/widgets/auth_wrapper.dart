import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:relygo/screens/signin_screen.dart';
import 'package:relygo/screens/responsive_user_dashboard_screen.dart';
import 'package:relygo/screens/responsive_driver_dashboard_screen.dart';
import 'package:relygo/screens/admin_dashboard_screen.dart';
import 'package:relygo/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is not logged in, show sign in screen
        if (snapshot.data == null) {
          return const SignInScreen();
        }

        // If user is logged in, determine their role and show appropriate dashboard
        return FutureBuilder<Map<String, dynamic>?>(
          future: AuthService.getUserData(snapshot.data!.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
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
                return const ResponsiveUserDashboardScreen();
              case 'driver':
                if (status == 'pending') {
                  return _buildPendingApprovalScreen(context, 'Driver');
                } else if (status == 'rejected') {
                  return _buildRejectedScreen(context, 'Driver');
                } else if (status == 'approved') {
                  return const ResponsiveDriverDashboardScreen();
                } else {
                  return _buildPendingApprovalScreen(context, 'Driver');
                }
              case 'admin':
                return const AdminDashboardScreen();
              default:
                return const ResponsiveUserDashboardScreen();
            }
          },
        );
      },
    );
  }

  Widget _buildPendingApprovalScreen(BuildContext context, String userType) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  color: Colors.black,
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
      backgroundColor: Colors.white,
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
                  color: Colors.black,
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

  Widget _buildPlatformRestrictionScreen(
    BuildContext context,
    String message,
    IconData icon,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                child: Icon(icon, size: 60, color: Colors.blue),
              ),
              const SizedBox(height: 32),
              Text(
                'Platform Restricted',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
