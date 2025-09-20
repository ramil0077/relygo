import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/verification_status_screen.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() =>
      _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState
    extends State<DocumentVerificationScreen> {
  int _currentStep = 0;

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
        child: Column(
          children: [
            // Progress Indicator
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
                          color: index <= _currentStep
                              ? Mycolors.basecolor
                              : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (index < 3)
                        Container(
                          width: 30,
                          height: 2,
                          color: index < _currentStep
                              ? Mycolors.basecolor
                              : Colors.grey.shade300,
                        ),
                    ],
                  );
                }),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildVerifyDriverLicense();
      case 1:
        return _buildUploadDriverLicense();
      case 2:
        return _buildUploadAadhaarCard();
      case 3:
        return _buildSubmitAadhaarCard();
      default:
        return _buildVerifyDriverLicense();
    }
  }

  Widget _buildVerifyDriverLicense() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's Verify your driver license",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Please choose a picture of your driver license to verify.",
          style: GoogleFonts.poppins(fontSize: 16, color: Mycolors.gray),
        ),
        const SizedBox(height: 40),

        // Camera/Upload Icon
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Mycolors.lightGray,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: Mycolors.basecolor, width: 2),
            ),
            child: Icon(Icons.camera_alt, size: 50, color: Mycolors.basecolor),
          ),
        ),
        const SizedBox(height: 40),

        // Choose or Capture Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
            icon: Icon(Icons.upload, color: Mycolors.basecolor),
            label: Text(
              "Choose or Capture image",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Mycolors.basecolor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Mycolors.basecolor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const Spacer(),

        // Next Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors.basecolor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Next",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadDriverLicense() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's Upload your driver license",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),

        // Uploaded Image Preview
        Center(
          child: Container(
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
                Icon(Icons.credit_card, size: 50, color: Mycolors.gray),
                const SizedBox(height: 10),
                Text(
                  "Driver License Uploaded",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Mycolors.gray,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Retake Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _currentStep = 0;
              });
            },
            icon: Icon(Icons.refresh, color: Mycolors.basecolor),
            label: Text(
              "Retake",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Mycolors.basecolor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Mycolors.basecolor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const Spacer(),

        // Next Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 2;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors.basecolor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Next",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadAadhaarCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's upload your Aadhaar Card",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),

        // Uploaded Image Preview
        Center(
          child: Container(
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
                Icon(Icons.contact_page, size: 50, color: Mycolors.gray),
                const SizedBox(height: 10),
                Text(
                  "Aadhaar Card Uploaded",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Mycolors.gray,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Retake Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              // Retake functionality
            },
            icon: Icon(Icons.refresh, color: Mycolors.basecolor),
            label: Text(
              "Retake",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Mycolors.basecolor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Mycolors.basecolor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const Spacer(),

        // Next Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 3;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors.basecolor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Next",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitAadhaarCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's upload your Aadhaar Card",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),

        // Uploaded Image Preview
        Center(
          child: Container(
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
                Icon(Icons.contact_page, size: 50, color: Mycolors.gray),
                const SizedBox(height: 10),
                Text(
                  "Aadhaar Card Ready to Submit",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Mycolors.gray,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // Retake Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _currentStep = 2;
              });
            },
            icon: Icon(Icons.refresh, color: Mycolors.basecolor),
            label: Text(
              "Retake",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Mycolors.basecolor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Mycolors.basecolor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const Spacer(),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerificationStatusScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolors.basecolor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Submit",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
