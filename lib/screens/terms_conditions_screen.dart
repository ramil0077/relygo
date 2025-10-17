import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';


class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator - All steps completed
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Mycolors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                      if (index < 3)
                        Container(width: 30, height: 2, color: Mycolors.green),
                    ],
                  );
                }),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      "You are Ready to Drive",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Truck Image
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Mycolors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_shipping,
                            size: 60,
                            color: Mycolors.basecolor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Your Vehicle",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Mycolors.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Terms and Conditions Overlay
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Mycolors.lightBrown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Mycolors.basecolor.withOpacity(0.3),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Terms and Conditions",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Mycolors.basecolor,
                                ),
                              ),
                              const SizedBox(height: 15),

                              _buildSection("Eligibility", [
                                "You must be at least 18 years old",
                                "You must have a valid driving license",
                                "You must have a clean driving record",
                                "You must pass background verification",
                              ]),

                              _buildSection("Privacy Policy", [
                                "We collect and use your personal information as described in our Privacy Policy",
                                "Your data is protected and will not be shared with third parties without consent",
                                "We may use your location data for service delivery",
                              ]),

                              _buildSection("Data Security", [
                                "We implement industry-standard security measures",
                                "Your payment information is encrypted and secure",
                                "We regularly update our security protocols",
                              ]),

                              _buildSection("User Responsibilities", [
                                "Provide accurate and up-to-date information",
                                "Maintain your vehicle in good condition",
                                "Follow all traffic laws and regulations",
                                "Treat passengers with respect and professionalism",
                              ]),

                              _buildSection("Termination", [
                                "We may terminate your account for violations of terms",
                                "You may terminate your account at any time",
                                "Termination does not affect completed transactions",
                              ]),

                              _buildSection("Governing Law", [
                                "These terms are governed by Indian law",
                                "Any disputes will be resolved in Indian courts",
                              ]),

                              _buildSection("Dispute Resolution", [
                                "We encourage resolving disputes through communication",
                                "Mediation is available for unresolved disputes",
                                "Arbitration may be used as a last resort",
                              ]),

                              _buildSection("Amendments", [
                                "We may update these terms from time to time",
                                "You will be notified of significant changes",
                                "Continued use constitutes acceptance of new terms",
                              ]),

                              _buildSection("Contact Information", [
                                "Email: support@relygo.com",
                                "Phone: +91-800-123-4567",
                                "Address: RelyGO Headquarters, Mumbai, India",
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Accept Terms Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: Mycolors.basecolor,
                        ),
                        Expanded(
                          child: Text(
                            "I accept the Terms and Conditions",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _acceptTerms
                            ? () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         const CallVerificationScreen(),
                                //   ),
                                // );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _acceptTerms
                              ? Mycolors.basecolor
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "Continue",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Mycolors.basecolor,
          ),
        ),
        const SizedBox(height: 8),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Text(
              "• $point",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
