import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/screens/signin_screen.dart';
import 'package:relygo/screens/user_contact_screen.dart';
import 'package:relygo/screens/admin_dashboard_screen.dart';

class Registration extends StatelessWidget {
  const Registration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  "Welcome to RelyGO",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "What are you looking for today?",
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 15),
                ),
                const SizedBox(height: 35),

                // Driver card
                SizedBox(
                  width: 350,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                    child: Card(
                      color: Mycolors.basecolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),

                            // Icon
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Image.asset(
                                "assets/car.png",
                                height: 20,
                                width: 20,
                              ),
                            ),

                            const SizedBox(height: 15),
                            const Text(
                              "Looking for a job?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            const Text(
                              "Join as a driver and start earning",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 15),

                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(text: "• Flexible working hours\n"),
                                  TextSpan(text: "• Competitive earnings\n"),
                                  TextSpan(text: "• Driver support 24/7\n"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // Service card
                SizedBox(
                  width: 350,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserContactScreen(),
                        ),
                      );
                    },
                    child: Card(
                      color: Mycolors.basecolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Image.asset(
                                "assets/service.png",
                                height: 30,
                                width: 30,
                              ),
                            ),
                            const Text(
                              "Need Service?",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Book rides and services",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 15),

                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(text: "• Hospital Bookings\n"),
                                  TextSpan(text: "• Trip Bookings\n"),
                                  TextSpan(text: "• Grocery Shoppings\n"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // Admin card
                SizedBox(
                  width: 350,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboardScreen(),
                        ),
                      );
                    },
                    child: Card(
                      color: Mycolors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: const Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const Text(
                              "Admin Panel",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Manage trucks and drivers",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 15),

                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(text: "• Truck Management\n"),
                                  TextSpan(text: "• Driver Verification\n"),
                                  TextSpan(text: "• System Administration\n"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
