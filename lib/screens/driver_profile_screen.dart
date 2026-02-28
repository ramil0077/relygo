import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<User?>(
        stream: AuthService.authStateChanges,
        builder: (context, authSnapshot) {
          final String? userId =
              authSnapshot.data?.uid ?? AuthService.currentUserId;
          if (userId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Mycolors.gray),
                  const SizedBox(height: 16),
                  Text(
                    'Please log in to view your profile',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Mycolors.gray,
                    ),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<Map<String, dynamic>?>(
            stream: UserService.streamUserById(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
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
                      Icon(Icons.error_outline, size: 64, color: Mycolors.gray),
                      const SizedBox(height: 16),
                      Text(
                        "Driver profile not available",
                        style: GoogleFonts.poppins(
                          color: Mycolors.gray,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "ID: $userId",
                        style: GoogleFonts.poppins(
                          color: Mycolors.gray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final name = (data['name'] ?? data['fullName'] ?? 'Driver')
                  .toString();
              final email = (data['email'] ?? '').toString();
              final phone = (data['phone'] ?? '').toString();
              final photoUrl = (data['photoUrl'] ?? '').toString();
              final rating = (data['rating'] ?? 4.8).toString();

              // Robust vehicle info fetching
              final vehicle = (data['vehicle'] ?? {}) as Map<String, dynamic>;
              final docs = (data['documents'] ?? {}) as Map<String, dynamic>;

              final vehicleType =
                  (vehicle['type'] ?? docs['vehicleType'] ?? 'Vehicle')
                      .toString();
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
                          currentLicense: (data['licenseNumber'] ?? '')
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
                          currentYear: (vehicle['year'] ?? '').toString(),
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
            }, // closes inner StreamBuilder builder
          ); // closes inner StreamBuilder widget
        }, // closes outer authStateChanges builder
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
        tileColor: Colors.white,
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
    required String currentYear,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final typeCtrl = TextEditingController(text: currentType);
        final modelCtrl = TextEditingController(text: currentModel);
        final regCtrl = TextEditingController(text: currentReg);
        final yearCtrl = TextEditingController(text: currentYear);
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
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Year of Manufacture",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: yearCtrl,
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
                    yearOfManufacture: yearCtrl.text.trim(),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEarningsItem("Today", "₹1,250", Mycolors.green),
              _buildEarningsItem("This Week", "₹8,750", Mycolors.orange),
              _buildEarningsItem("This Month", "₹35,000", Mycolors.basecolor),
              _buildEarningsItem("Total", "₹1,25,000", Mycolors.green),
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

  void _showRideHistoryDialog() {
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRideItem(
                "Airport to Downtown",
                "₹180",
                "2 hours ago",
                "Completed",
              ),
              _buildRideItem(
                "Mall to Station",
                "₹120",
                "Yesterday",
                "Completed",
              ),
              _buildRideItem(
                "Hospital Pickup",
                "₹200",
                "2 days ago",
                "Completed",
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
        color: Colors.grey.shade100,
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
              _buildSupportOption("Live Chat", Icons.chat),
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
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $title...'),
            backgroundColor: Mycolors.basecolor,
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              ListTile(
                leading: Icon(Icons.language, color: Mycolors.basecolor),
                title: Text("Language", style: GoogleFonts.poppins()),
                trailing: Text(
                  "English",
                  style: GoogleFonts.poppins(color: Mycolors.gray),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.dark_mode, color: Mycolors.basecolor),
                title: Text("Theme", style: GoogleFonts.poppins()),
                trailing: Text(
                  "Light",
                  style: GoogleFonts.poppins(color: Mycolors.gray),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Mycolors.basecolor),
                title: Text("Location Services", style: GoogleFonts.poppins()),
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
