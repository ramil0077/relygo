import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/services/user_service.dart';
import 'package:relygo/screens/signin_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final String? uid = AuthService.currentUserId;

    if (uid == null) {
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
        stream: UserService.streamUserById(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(color: Mycolors.red),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Mycolors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Driver profile not available',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Mycolors.gray,
                    ),
                  ),
                ],
              ),
            );
          }

          // Data extracted from Firestore
          final name = (data['name'] ?? data['fullName'] ?? 'Driver')
              .toString();
          final email = (data['email'] ?? '').toString();
          final phone = (data['phone'] ?? data['phoneNumber'] ?? '').toString();
          final photoUrl = (data['photoUrl'] ?? '').toString();
          final rating = (data['rating'] ?? 4.8).toString();

          final vehicle = (data['vehicle'] is Map)
              ? Map<String, dynamic>.from(data['vehicle'] as Map)
              : {};
          final docs = (data['documents'] is Map)
              ? Map<String, dynamic>.from(data['documents'] as Map)
              : {};

          final vehicleType =
              (vehicle['type'] ?? docs['vehicleType'] ?? 'Vehicle').toString();
          final vehicleModel = (vehicle['model'] ?? 'Standard').toString();
          final vehicleReg =
              (vehicle['registrationNumber'] ?? docs['vehicleNumber'] ?? '')
                  .toString();

          // Dynamic stats from user data
          final totalRides = (data['totalRides'] ?? '0').toString();
          final totalEarnings = (data['totalEarnings'] ?? '0').toString();
          final hoursToday = (data['hoursToday'] ?? '0').toString();

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
                          Icon(Icons.star, color: Colors.white, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            "$rating Rating",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                          (data['isOnline'] ?? true) ? "Online" : "Offline",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Driver Stats
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
                        "₹$totalEarnings",
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
                          (docs['licenseNumber'] ?? data['licenseNumber'] ?? '')
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
                    _showRideHistoryDialog();
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
                    _showSettingsDialog();
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
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: phoneCtrl,
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
    final uid = AuthService.currentUserId;
    if (uid == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<Map<String, double>>(
          stream: UserService.streamDriverEarningsSummary(uid),
          builder: (context, snapshot) {
            final data =
                snapshot.data ??
                {'today': 0, 'week': 0, 'month': 0, 'total': 0};
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Earnings Summary",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: snapshot.connectionState == ConnectionState.waiting
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildEarningsItem(
                          "Today",
                          "₹${data['today']?.toStringAsFixed(2)}",
                          Mycolors.green,
                        ),
                        _buildEarningsItem(
                          "This Week",
                          "₹${data['week']?.toStringAsFixed(2)}",
                          Mycolors.orange,
                        ),
                        _buildEarningsItem(
                          "This Month",
                          "₹${data['month']?.toStringAsFixed(2)}",
                          Mycolors.basecolor,
                        ),
                        _buildEarningsItem(
                          "Total",
                          "₹${data['total']?.toStringAsFixed(2)}",
                          Mycolors.green,
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
                  onPressed: (data['total'] ?? 0) > 0
                      ? () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Withdrawal request submitted!'),
                              backgroundColor: Mycolors.green,
                            ),
                          );
                        }
                      : null,
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

  void _showRideHistoryDialog() {
    final uid = AuthService.currentUserId;
    if (uid == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Recent Rides",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: UserService.getDriverRideHistoryStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final rides = snapshot.data ?? [];
                if (rides.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No rides found",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Mycolors.gray),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: rides.length > 5 ? 5 : rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    final pickup = ride['pickup'] ?? 'Unknown location';
                    final dropoff = ride['destination'] ?? 'Unknown location';
                    final fare = ride['fare']?.toString() ?? '0';
                    final time = ride['createdAt'] is Timestamp
                        ? DateFormat(
                            'dd MMM, hh:mm a',
                          ).format((ride['createdAt'] as Timestamp).toDate())
                        : 'Unknown time';
                    final status = ride['status'] ?? 'Completed';

                    return _buildRideItem(
                      "$pickup to $dropoff",
                      "₹$fare",
                      time,
                      status,
                    );
                  },
                );
              },
            ),
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

  Widget _buildRideItem(
    String route,
    String price,
    String time,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              Text(
                time,
                style: GoogleFonts.poppins(fontSize: 12, color: Mycolors.gray),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Mycolors.basecolor,
                ),
              ),
              Text(
                status,
                style: GoogleFonts.poppins(fontSize: 12, color: Mycolors.green),
              ),
            ],
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
                activeTrackColor: Mycolors.basecolor,
              ),
              SwitchListTile(
                title: Text("Earnings Updates", style: GoogleFonts.poppins()),
                value: true,
                onChanged: (value) {},
                activeTrackColor: Mycolors.basecolor,
              ),
              SwitchListTile(
                title: Text("Promotional Offers", style: GoogleFonts.poppins()),
                value: false,
                onChanged: (value) {},
                activeTrackColor: Mycolors.basecolor,
              ),
              SwitchListTile(
                title: Text("App Updates", style: GoogleFonts.poppins()),
                value: true,
                onChanged: (value) {},
                activeTrackColor: Mycolors.basecolor,
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  ListTile(
                    leading: Icon(Icons.location_on, color: Mycolors.basecolor),
                    title: Text(
                      "Location Services",
                      style: GoogleFonts.poppins(),
                    ),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeTrackColor: Mycolors.basecolor,
                    ),
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
}
