import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _selectedPeriod = "Today";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Earnings",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Period Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildPeriodChip("Today", "Today"),
                  const SizedBox(width: 10),
                  _buildPeriodChip("This Week", "Week"),
                  const SizedBox(width: 10),
                  _buildPeriodChip("This Month", "Month"),
                  const SizedBox(width: 10),
                  _buildPeriodChip("All Time", "All"),
                ],
              ),
            ),

            // Earnings Summary
            Container(
              margin: const EdgeInsets.all(20),
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
                  Text(
                    "Total Earnings",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTotalEarnings(),
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEarningsStat(
                          "Rides",
                          _getRideCount(),
                          Icons.directions_car,
                        ),
                      ),
                      Expanded(
                        child: _buildEarningsStat(
                          "Hours",
                          _getHoursWorked(),
                          Icons.access_time,
                        ),
                      ),
                      Expanded(
                        child: _buildEarningsStat("Rating", "4.8", Icons.star),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Earnings Breakdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Earnings Breakdown",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showWithdrawDialog();
                    },
                    child: Text(
                      "Withdraw",
                      style: GoogleFonts.poppins(
                        color: Mycolors.basecolor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Earnings List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildEarningsItem(
                    "Airport to Downtown",
                    "2.5 km",
                    "₹180",
                    "2 hours ago",
                    Mycolors.green,
                  ),
                  _buildEarningsItem(
                    "Mall to Station",
                    "1.8 km",
                    "₹120",
                    "4 hours ago",
                    Mycolors.green,
                  ),
                  _buildEarningsItem(
                    "Hospital Pickup",
                    "3.2 km",
                    "₹200",
                    "6 hours ago",
                    Mycolors.green,
                  ),
                  _buildEarningsItem(
                    "Office to Home",
                    "4.1 km",
                    "₹250",
                    "Yesterday",
                    Mycolors.green,
                  ),
                  _buildEarningsItem(
                    "Station to Airport",
                    "5.2 km",
                    "₹300",
                    "2 days ago",
                    Mycolors.green,
                  ),
                  _buildEarningsItem(
                    "Downtown to Mall",
                    "2.8 km",
                    "₹160",
                    "3 days ago",
                    Mycolors.green,
                  ),
                  _buildEarningsItem(
                    "Bonus - Peak Hours",
                    "Extra",
                    "₹50",
                    "Yesterday",
                    Mycolors.orange,
                  ),
                  _buildEarningsItem(
                    "Referral Bonus",
                    "Extra",
                    "₹100",
                    "1 week ago",
                    Mycolors.orange,
                  ),
                ],
              ),
            ),

            // Bottom Summary
            Container(
              margin: const EdgeInsets.all(20),
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
                        "Available Balance",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        _getTotalEarnings(),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Mycolors.basecolor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pending",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Mycolors.gray,
                        ),
                      ),
                      Text(
                        "₹0",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Mycolors.gray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    bool isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Mycolors.basecolor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Mycolors.basecolor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsItem(
    String title,
    String subtitle,
    String amount,
    String time,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.attach_money, color: color, size: 20),
          ),
          const SizedBox(width: 16),
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
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Mycolors.gray,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Mycolors.gray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getTotalEarnings() {
    switch (_selectedPeriod) {
      case "Today":
        return "₹1,250";
      case "Week":
        return "₹8,750";
      case "Month":
        return "₹35,000";
      case "All":
        return "₹1,25,000";
      default:
        return "₹1,250";
    }
  }

  String _getRideCount() {
    switch (_selectedPeriod) {
      case "Today":
        return "8";
      case "Week":
        return "56";
      case "Month":
        return "224";
      case "All":
        return "1,200";
      default:
        return "8";
    }
  }

  String _getHoursWorked() {
    switch (_selectedPeriod) {
      case "Today":
        return "6.5";
      case "Week":
        return "45.5";
      case "Month":
        return "182";
      case "All":
        return "1,200";
      default:
        return "6.5";
    }
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Withdraw Earnings",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Available Balance: ${_getTotalEarnings()}",
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: "Withdrawal Amount",
                  prefixText: "₹ ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: "Bank Account Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
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
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
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
}
