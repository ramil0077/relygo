import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/services/user_service.dart';
import 'package:relygo/widgets/image_upload_widget.dart';
import 'package:relygo/screens/signin_screen.dart';
import 'package:relygo/services/driver_service.dart';
import 'package:relygo/utils/phone_validation.dart';
import 'package:relygo/screens/driver_ride_history_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  final String? initialSection;
  const DriverProfileScreen({super.key, this.initialSection});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _didOpenInitialSection = false;
  @override
  Widget build(BuildContext context) {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Mycolors.gray),
              const SizedBox(height: 16),
              Text(
                'Please log in to view your profile',
                style: GoogleFonts.poppins(fontSize: 16, color: Mycolors.gray),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Mycolors.basecolor,
                  foregroundColor: Colors.white,
                ),
                child: Text("Sign In", style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text("Profile"),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: UserService.streamUserById(userId),
        builder: (context, snapshot) {
          final raw = snapshot.data;
          Map<String, dynamic>? data;
          if (raw != null) {
            try {
              data = Map<String, dynamic>.from(raw);
            } catch (e) {
              data = null;
            }
          }
          final name = (data?['name'] ?? 'Driver').toString();
          final email = (data?['email'] ?? '').toString();
          final phone = (data?['phone'] ?? '').toString();
          // Support both possible keys used across the app: 'photoUrl' and 'profileImage'
          final photoUrl = (data?['photoUrl'] ?? data?['profileImage'] ?? '')
              .toString();
          final rating = (data?['rating'] ?? 4.8).toString();
          // Safely extract vehicle data, handling LinkedHashMap and null cases
          final vehicleData = data?['vehicle'];
          Map<String, dynamic> vehicle = {};
          if (vehicleData != null) {
            try {
              vehicle = vehicleData is Map<String, dynamic>
                  ? vehicleData
                  : Map<String, dynamic>.from(vehicleData as Map);
            } catch (e) {
              vehicle = {};
            }
          }
          final vehicleType = (vehicle['type'] ?? 'Vehicle').toString();

          // If caller requested an initial section (like 'settings'), open it once after build
          if (!_didOpenInitialSection && widget.initialSection != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (widget.initialSection == 'settings') {
                _showSettingsDialog(data?['isLocationEnabled'] ?? true);
              } else if (widget.initialSection == 'earnings') {
                _showEarningsDialog();
              }
            });
            _didOpenInitialSection = true;
          }

          final vehicleModel = (vehicle['model'] ?? '').toString();
          final vehicleReg = (vehicle['registrationNumber'] ?? '').toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Mycolors.basecolor,
                        Mycolors.basecolor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Mycolors.basecolor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl.isEmpty
                                ? Image.asset(
                                    'assets/logooo.png',
                                    width: 50,
                                    height: 50,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  _openImageUploadDialog(userId, photoUrl),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Mycolors.basecolor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        email.isNotEmpty ? email : phone,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            "$rating Rating",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (data?['isOnline'] ?? true)
                                  ? "Online"
                                  : "Offline",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Driver Stats
                FutureBuilder<Map<String, dynamic>>(
                  future: DriverService.getDriverEarnings(userId),
                  builder: (context, snapshot) {
                    final stats = snapshot.data ?? {};
                    final totalRides = stats['totalRides']?.toString() ?? '0';
                    final totalEarnings = stats['totalEarnings'] != null
                        ? '₹${stats['totalEarnings'].toStringAsFixed(0)}'
                        : '₹0';
                    final hoursToday =
                        stats['hoursToday']?.toStringAsFixed(1) ?? '0.0';

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                totalRides,
                                "Total Rides",
                                Icons.directions_car,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildStatCard(
                                totalEarnings,
                                "Total Earnings",
                                Icons.attach_money,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                hoursToday,
                                "Hours Today",
                                Icons.access_time,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildStatCard(
                                vehicleType,
                                "Vehicle",
                                Icons.directions_car,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Profile Options
                _buildProfileOption(
                  "Personal Information",
                  "Update your personal details",
                  Icons.person_outline,
                  () {
                    _showPersonalInfoDialog(
                      currentName: name,
                      currentEmail: email,
                      currentPhone: phone,
                      currentLicense:
                          (data?['licenseNumber'] ??
                                  (data?['documents'] is Map
                                      ? data!['documents']['licenseNumber']
                                      : null) ??
                                  '')
                              .toString(),
                    );
                  },
                ),
                _buildProfileOption(
                  "Vehicle Information",
                  "Manage your vehicle details",
                  Icons.directions_car,
                  () {
                    _showVehicleInfoDialog(
                      currentType: vehicleType,
                      currentModel: vehicleModel,
                      currentReg: vehicleReg,
                    );
                  },
                ),
                _buildProfileOption(
                  "Documents",
                  "Upload and manage documents",
                  Icons.description,
                  () {
                    _showDocumentsDialog();
                  },
                ),
                _buildProfileOption(
                  "Earnings",
                  "View your earnings history",
                  Icons.attach_money,
                  () {
                    _showEarningsDialog();
                  },
                ),
                _buildProfileOption(
                  "Ride History",
                  "View your ride history",
                  Icons.history,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriverRideHistoryScreen(),
                      ),
                    );
                  },
                ),
                _buildProfileOption(
                  "Bank Details",
                  "Manage your bank account",
                  Icons.account_balance,
                  () {
                    _showBankDetailsDialog();
                  },
                ),
                _buildProfileOption(
                  "Notifications",
                  "Manage notification preferences",
                  Icons.notifications,
                  () {
                    _showNotificationsDialog();
                  },
                ),
                _buildProfileOption(
                  "Help & Support",
                  "Get help and contact support",
                  Icons.help,
                  () {
                    _showHelpSupportDialog();
                  },
                ),
                _buildProfileOption(
                  "Settings",
                  "App settings and preferences",
                  Icons.settings,
                  () {
                    _showSettingsDialog(data?['isLocationEnabled'] ?? true);
                  },
                ),
                _buildProfileOption(
                  "Change Password",
                  "Update your account password",
                  Icons.lock_outline,
                  () {
                    _showChangePasswordDialog();
                  },
                ),
                const SizedBox(height: 20),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog();
                    },
                    icon: Icon(Icons.logout, color: Mycolors.red),
                    label: Text(
                      "Logout",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Mycolors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Mycolors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Mycolors.lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, color: Mycolors.basecolor, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Mycolors.basecolor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Mycolors.gray,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Mycolors.basecolor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Mycolors.basecolor, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 14, color: Mycolors.gray),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Mycolors.gray, size: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showPersonalInfoDialog({
    required String currentName,
    required String currentEmail,
    required String currentPhone,
    required String currentLicense,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final nameCtrl = TextEditingController(text: currentName);
        final emailCtrl = TextEditingController(text: currentEmail);
        final phoneCtrl = TextEditingController(text: currentPhone);
        final licenseCtrl = TextEditingController(text: currentLicense);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Personal Information",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: nameCtrl,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: emailCtrl,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Phone",
                  helperText: "Numbers only (10-13 digits)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  PhoneNumberInputFormatter(), // Only allows digits
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "License Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: licenseCtrl,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = AuthService.currentUserId;
                if (uid != null) {
                  await UserService.updatePersonalInfo(
                    userId: uid,
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    licenseNumber: licenseCtrl.text.trim(),
                  );
                }
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Mycolors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Save", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showVehicleInfoDialog({
    required String currentType,
    required String currentModel,
    required String currentReg,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final typeCtrl = TextEditingController(text: currentType);
        final modelCtrl = TextEditingController(text: currentModel);
        final regCtrl = TextEditingController(text: currentReg);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Vehicle Information",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Vehicle Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: typeCtrl,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Vehicle Model",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: modelCtrl,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Registration Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: regCtrl,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = AuthService.currentUserId;
                if (uid != null) {
                  await UserService.updateVehicleInfo(
                    userId: uid,
                    vehicleType: typeCtrl.text.trim(),
                    vehicleModel: modelCtrl.text.trim(),
                    registrationNumber: regCtrl.text.trim(),
                  );
                }
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Vehicle information updated!'),
                      backgroundColor: Mycolors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Save", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showDocumentsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Documents",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDocumentItem(
                "Driving License",
                "Verified",
                Mycolors.green,
                Icons.check_circle,
              ),
              _buildDocumentItem(
                "RC Book",
                "Verified",
                Mycolors.green,
                Icons.check_circle,
              ),
              _buildDocumentItem(
                "Insurance",
                "Pending",
                Mycolors.orange,
                Icons.pending,
              ),
              _buildDocumentItem(
                "Aadhaar Card",
                "Verified",
                Mycolors.green,
                Icons.check_circle,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Document uploaded!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Upload New", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentItem(
    String title,
    String status,
    Color statusColor,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEarningsDialog() {
    final userId = AuthService.currentUserId;
    if (userId == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Earnings Summary",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: FutureBuilder<Map<String, dynamic>>(
            future: DriverService.getDriverEarnings(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final data = snapshot.data ?? {};
              final todayEarnings = (data['todayEarnings'] ?? 0.0) as num;
              final totalEarnings = (data['totalEarnings'] ?? 0.0) as num;
              final todayRides = (data['todayRides'] ?? 0) as int;
              final totalRides = (data['totalRides'] ?? 0) as int;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEarningsItem(
                    "Today",
                    "₹${todayEarnings.toStringAsFixed(0)} ($todayRides rides)",
                    Mycolors.green,
                  ),
                  _buildEarningsItem(
                    "Total",
                    "₹${totalEarnings.toStringAsFixed(0)} ($totalRides rides)",
                    Mycolors.basecolor,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Withdrawal request submitted!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Withdraw", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEarningsItem(String period, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(period, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showBankDetailsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final bankCtrl = TextEditingController(text: "HDFC Bank");
        final accCtrl = TextEditingController(text: "1234567890");
        final ifscCtrl = TextEditingController(text: "HDFC0001234");
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Bank Details",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Bank Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: bankCtrl,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Account Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: accCtrl,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "IFSC Code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: ifscCtrl,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = AuthService.currentUserId;
                if (uid != null) {
                  await UserService.updateBankDetails(
                    userId: uid,
                    bankName: bankCtrl.text.trim(),
                    accountNumber: accCtrl.text.trim(),
                    ifsc: ifscCtrl.text.trim(),
                  );
                }
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bank details updated!'),
                      backgroundColor: Mycolors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
                foregroundColor: Colors.white,
              ),
              child: Text("Save", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Notification Settings",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text("Ride Requests", style: GoogleFonts.poppins()),
                value: true,
                onChanged: (value) {},
                activeColor: Mycolors.basecolor,
              ),
              SwitchListTile(
                title: Text("Earnings Updates", style: GoogleFonts.poppins()),
                value: true,
                onChanged: (value) {},
                activeColor: Mycolors.basecolor,
              ),
              SwitchListTile(
                title: Text("Promotional Offers", style: GoogleFonts.poppins()),
                value: false,
                onChanged: (value) {},
                activeColor: Mycolors.basecolor,
              ),
              SwitchListTile(
                title: Text("App Updates", style: GoogleFonts.poppins()),
                value: true,
                onChanged: (value) {},
                activeColor: Mycolors.basecolor,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Help & Support",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSupportOption("FAQ", Icons.help_outline),
              _buildSupportOption("Contact Support", Icons.phone),
              _buildSupportOption("Report Issue", Icons.report),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Close",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSupportOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Mycolors.basecolor),
      title: Text(title, style: GoogleFonts.poppins()),
      onTap: () async {
        if (title == "Contact Support") {
          final Uri telLaunchUri = Uri(
            scheme: 'tel',
            path: '+919876543210', // Example support number
          );
          if (await canLaunchUrl(telLaunchUri)) {
            await launchUrl(telLaunchUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not launch dialer')),
            );
          }
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $title...'),
              backgroundColor: Mycolors.basecolor,
            ),
          );
        }
      },
    );
  }

  void _showSettingsDialog(bool currentLocationStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLocationEnabled = currentLocationStatus;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = AppSettings.themeMode.value == ThemeMode.dark;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Settings",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dark Mode toggle
                  SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: Mycolors.basecolor,
                    ),
                    title: Text("Dark Mode", style: GoogleFonts.poppins()),
                    subtitle: Text(
                      isDark ? "Dark theme enabled" : "Light theme enabled",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Mycolors.gray,
                      ),
                    ),
                    value: isDark,
                    activeTrackColor: Mycolors.basecolor,
                    onChanged: (value) {
                      setDialogState(() {
                        AppSettings.themeMode.value = value
                            ? ThemeMode.dark
                            : ThemeMode.light;
                      });
                    },
                  ),
                  // Location Services toggle
                  SwitchListTile(
                    secondary: Icon(
                      Icons.location_on,
                      color: Mycolors.basecolor,
                    ),
                    title: Text(
                      "Location Services",
                      style: GoogleFonts.poppins(),
                    ),
                    subtitle: Text(
                      isLocationEnabled ? "Enabled" : "Disabled",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Mycolors.gray,
                      ),
                    ),
                    value: isLocationEnabled,
                    activeTrackColor: Mycolors.basecolor,
                    onChanged: (value) async {
                      final uid = AuthService.currentUserId;
                      if (uid != null) {
                        setDialogState(() {
                          isLocationEnabled = value;
                          currentLocationStatus = value;
                        });
                        await UserService.updateUserFields(uid, {
                          'isLocationEnabled': value,
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Close",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Logout",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Logout", style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _openImageUploadDialog(String userId, String currentUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Change Profile Image',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: ImageUploadWidget(
            title: 'Profile Image',
            subtitle: 'Upload a clear photo for your profile',
            folder: 'profiles/$userId',
            initialImageUrl: currentUrl.isNotEmpty ? currentUrl : null,
            onImageUploaded: (url) async {
              if (url.isNotEmpty) {
                await UserService.updatePersonalInfo(
                  userId: userId,
                  photoUrl: url,
                );
                if (mounted) Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile image updated!'),
                    backgroundColor: Mycolors.green,
                  ),
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Change Password',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                final current = currentCtrl.text.trim();
                final nw = newCtrl.text.trim();
                final cf = confirmCtrl.text.trim();
                if (nw.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'New password must be at least 6 characters',
                      ),
                      backgroundColor: Mycolors.red,
                    ),
                  );
                  return;
                }
                if (nw != cf) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Mycolors.red,
                    ),
                  );
                  return;
                }
                final user = FirebaseAuth.instance.currentUser;
                final email = user?.email;
                if (user == null || email == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unable to change password: not signed in'),
                      backgroundColor: Mycolors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Reauthenticate
                  final cred = EmailAuthProvider.credential(
                    email: email,
                    password: current,
                  );
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(nw);
                  if (mounted) Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password changed successfully'),
                      backgroundColor: Mycolors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to change password: $e'),
                      backgroundColor: Mycolors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Mycolors.basecolor,
              ),
              child: Text('Change', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}
