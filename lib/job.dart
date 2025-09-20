import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

class Job extends StatelessWidget {
  const Job({super.key});

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
        title: Text(
          "Job Dashboard",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Welcome to RelyGO Job Portal",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Find your perfect driving opportunity",
                style: GoogleFonts.poppins(fontSize: 16, color: Mycolors.gray),
              ),
              const SizedBox(height: 40),

              // Job Cards
              Expanded(
                child: ListView(
                  children: [
                    _buildJobCard(
                      "Driver Position",
                      "Full-time driver needed for corporate clients",
                      "₹25,000 - ₹35,000/month",
                      Icons.directions_car,
                    ),
                    const SizedBox(height: 16),
                    _buildJobCard(
                      "Delivery Driver",
                      "Part-time delivery driver for local area",
                      "₹15,000 - ₹20,000/month",
                      Icons.local_shipping,
                    ),
                    const SizedBox(height: 16),
                    _buildJobCard(
                      "Chauffeur",
                      "Professional chauffeur for VIP clients",
                      "₹30,000 - ₹45,000/month",
                      Icons.drive_eta,
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

  Widget _buildJobCard(
    String title,
    String description,
    String salary,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Mycolors.basecolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Mycolors.basecolor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Mycolors.gray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  salary,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Mycolors.green,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Apply for job
            },
            icon: Icon(Icons.arrow_forward_ios, color: Mycolors.basecolor),
          ),
        ],
      ),
    );
  }
}
