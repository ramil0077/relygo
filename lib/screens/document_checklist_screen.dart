import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/license_entry_screen.dart';

class DocumentChecklistScreen extends StatefulWidget {
  const DocumentChecklistScreen({super.key});

  @override
  State<DocumentChecklistScreen> createState() =>
      _DocumentChecklistScreenState();
}

class _DocumentChecklistScreenState extends State<DocumentChecklistScreen> {
  final String userName = "Naseem"; // This would typically come from user data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Welcome Text
              Text(
                "Welcome, $userName",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Complete your profile to start driving",
                style: GoogleFonts.poppins(fontSize: 16, color: Mycolors.gray),
              ),
              const SizedBox(height: 40),

              // Document Checklist
              Expanded(
                child: Column(
                  children: [
                    _buildDocumentItem(
                      "Driving license",
                      "Upload your valid driving license",
                      Icons.credit_card,
                      true, // Completed
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LicenseEntryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildDocumentItem(
                      "Profile photo",
                      "Add a clear profile picture",
                      Icons.camera_alt,
                      false, // Pending
                      () {
                        // Navigate to profile photo screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profile photo upload coming soon'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildDocumentItem(
                      "Aadhaar card",
                      "Upload your Aadhaar card for verification",
                      Icons.contact_page,
                      false, // Pending
                      () {
                        // Navigate to Aadhaar upload screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Aadhaar card upload coming soon'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildDocumentItem(
                      "Registration Certificate (RC)",
                      "Upload your vehicle RC",
                      Icons.description,
                      false, // Pending
                      () {
                        // Navigate to RC upload screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('RC upload coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildDocumentItem(
                      "Vehicle Insurance",
                      "Upload your vehicle insurance document",
                      Icons.security,
                      false, // Pending
                      () {
                        // Navigate to insurance upload screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Insurance upload coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Progress Indicator
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Mycolors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Profile Completion",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "1/5",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Mycolors.basecolor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: 0.2, // 1 out of 5 documents completed
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Mycolors.basecolor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(
    String title,
    String subtitle,
    IconData icon,
    bool isCompleted,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? Mycolors.green : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Mycolors.green.withOpacity(0.1)
                    : Mycolors.basecolor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isCompleted ? Mycolors.green : Mycolors.basecolor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Mycolors.gray,
                    ),
                  ),
                ],
              ),
            ),

            // Status Indicator
            if (isCompleted)
              Icon(Icons.check_circle, color: Mycolors.green, size: 24)
            else
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
