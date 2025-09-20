import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/document_checklist_screen.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  String? _selectedService;

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
              // Title
              Text(
                "Choose how you want to work with RelyGO",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              // Service Options
              Expanded(
                child: Column(
                  children: [
                    // Car Option
                    _buildServiceOption(
                      "Car",
                      "Earn money with your car",
                      Icons.directions_car,
                      "Car",
                      true,
                    ),
                    const SizedBox(height: 20),

                    // Scooter/Bike Option
                    _buildServiceOption(
                      "Scooter/Bike",
                      "Earn money with your scooter or bike",
                      Icons.two_wheeler,
                      "Scooter/Bike",
                      false,
                    ),
                    const SizedBox(height: 20),

                    // Auto Rickshaw Option
                    _buildServiceOption(
                      "Auto rickshaw",
                      "Earn money with your auto rickshaw",
                      Icons.local_taxi,
                      "Auto rickshaw",
                      false,
                    ),
                    const SizedBox(height: 20),

                    // Driver Only Option
                    _buildServiceOption(
                      "Driver",
                      "I don't have a vehicle, I want to drive for someone else",
                      Icons.person,
                      "Driver",
                      false,
                    ),
                  ],
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _selectedService != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DocumentChecklistScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedService != null
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
    );
  }

  Widget _buildServiceOption(
    String title,
    String subtitle,
    IconData icon,
    String value,
    bool isHighlighted,
  ) {
    bool isSelected = _selectedService == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedService = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Mycolors.basecolor
              : isHighlighted
              ? Mycolors.lightBrown.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Mycolors.basecolor
                : isHighlighted
                ? Mycolors.basecolor.withOpacity(0.3)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Mycolors.basecolor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Mycolors.basecolor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Mycolors.basecolor : Mycolors.basecolor,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : Mycolors.gray,
                    ),
                  ),
                ],
              ),
            ),

            // Selection Indicator
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
