import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/auth_service.dart';
import 'package:relygo/screens/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// AppSettings are defined in constants.dart

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final String? uid = AuthService.currentUserId;
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
      body: uid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
                    child: Text(
                      'Profile not found',
                      style: GoogleFonts.poppins(color: Mycolors.red),
                    ),
                  );
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final String name = (data['name'] ?? 'User').toString();
                final String email = (data['email'] ?? '').toString();
                final Map<String, dynamic> docs =
                    (data['documents'] is Map<String, dynamic>)
                    ? (data['documents'] as Map<String, dynamic>)
                    : {};
                final bool isDriver =
                    (data['userType']?.toString().toLowerCase() == 'driver') ||
                    docs.isNotEmpty;
                final String vehicleType =
                    (data['vehicleType'] ?? docs['vehicleType'] ?? '')
                        .toString();
                final String vehicleNumber =
                    (data['vehicleNumber'] ?? docs['vehicleNumber'] ?? '')
                        .toString();
                final String licenseNumber =
                    (data['licenseNumber'] ?? docs['licenseNumber'] ?? '')
                        .toString();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Header (dynamic)
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
                              child: Text(
                                name.isNotEmpty ? name[0] : 'U',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
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
                              email,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
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
                                isDriver ? 'Driver' : 'User',
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

                      // Profile Options
                      _buildProfileOption(
                        "Personal Information",
                        "Update your personal details",
                        Icons.person_outline,
                        () {
                          _showPersonalInfoDialog(
                            currentName: name,
                            currentEmail: email,
                            currentPhone: (data['phone'] ?? '').toString(),
                          );
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
                        "Help & Support",
                        "Get help and contact support",
                        Icons.help,
                        () {
                          _showHelpSupportDialog();
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

                      if (isDriver) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Driver Documents",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDocTile(
                          'License',
                          docs['license'] ?? licenseNumber,
                        ),
                        _buildDocTile(
                          'Vehicle Registration',
                          docs['vehicleRegistration'] ?? vehicleNumber,
                        ),
                        _buildDocTile('Insurance', docs['insurance'] ?? ''),
                        if (vehicleType.isNotEmpty || vehicleNumber.isNotEmpty)
                          _buildDocTile(
                            'Vehicle',
                            '$vehicleType - $vehicleNumber',
                          ),
                      ],
                    ],
                  ),
                );
              },
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
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final nameController = TextEditingController(text: currentName);
        final phoneController = TextEditingController(text: currentPhone);
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
                controller: nameController,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: TextEditingController(text: currentEmail),
                readOnly: true,
              ),
              const SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                controller: phoneController,
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
                Navigator.of(context).pop();
                final uid = AuthService.currentUserId;
                if (uid != null) {
                  final res = await AuthService.updateUserProfile(
                    userId: uid,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                  );
                  final ok = res['success'] == true;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Profile updated successfully!'
                            : (res['error'] ?? 'Failed to update profile'),
                      ),
                      backgroundColor: ok ? Mycolors.green : Mycolors.red,
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

  void _showRideHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Ride History",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRideHistoryItem(
                "Airport to Downtown",
                "₹180",
                "2 hours ago",
                "Completed",
              ),
              _buildRideHistoryItem(
                "Mall to Station",
                "₹120",
                "Yesterday",
                "Completed",
              ),
              _buildRideHistoryItem(
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

  Widget _buildRideHistoryItem(
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

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController subjectController = TextEditingController();
        final TextEditingController messageController = TextEditingController();
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Help & Support",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create a support request",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Mycolors.gray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: "Subject",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Describe your issue",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
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
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final uid = AuthService.currentUserId;
                          final subject = subjectController.text.trim();
                          final message = messageController.text.trim();
                          if (uid == null ||
                              subject.isEmpty ||
                              message.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please fill subject and message',
                                ),
                                backgroundColor: Mycolors.red,
                              ),
                            );
                            return;
                          }
                          setState(() => isSubmitting = true);
                          try {
                            await FirebaseFirestore.instance
                                .collection('support_tickets')
                                .add({
                                  'userId': uid,
                                  'subject': subject,
                                  'message': message,
                                  'status': 'open',
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Support request submitted!',
                                  ),
                                  backgroundColor: Mycolors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to submit: $e'),
                                  backgroundColor: Mycolors.red,
                                ),
                              );
                            }
                          } finally {
                            if (context.mounted)
                              setState(() => isSubmitting = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors.basecolor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isSubmitting ? "Submitting..." : "Submit",
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        ThemeMode currentMode = AppSettings.themeMode.value;
        Locale? currentLocale = AppSettings.locale.value;
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
              Row(
                children: [
                  Icon(Icons.dark_mode, color: Mycolors.basecolor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text("Dark Mode", style: GoogleFonts.poppins()),
                  ),
                  Switch(
                    value: currentMode == ThemeMode.dark,
                    onChanged: (val) {
                      AppSettings.themeMode.value = val
                          ? ThemeMode.dark
                          : ThemeMode.light;
                      Navigator.of(context).pop();
                    },
                    activeColor: Mycolors.basecolor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.location_on, color: Mycolors.basecolor),
                title: Text("Location Services", style: GoogleFonts.poppins()),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: Mycolors.basecolor,
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

  Widget _buildDocTile(String label, String value) {
    final String text = (value).toString();
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.description, color: Mycolors.basecolor),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        text.isEmpty ? 'Not available' : text,
        style: GoogleFonts.poppins(fontSize: 12, color: Mycolors.gray),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
