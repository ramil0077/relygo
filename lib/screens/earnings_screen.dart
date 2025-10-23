import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/services/auth_service.dart';

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

            // Earnings Summary (from Firestore)
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getEarningsStream(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                num total = 0;
                for (final d in docs) {
                  final fare = d.data()['fare'];
                  if (fare is num) total += fare;
                }
                final int rideCount = docs.length;
                final String totalText = '₹${total.toStringAsFixed(0)}';
                final String avgText = rideCount > 0
                    ? '₹${(total / rideCount).toStringAsFixed(0)}'
                    : '₹0';

                return Container(
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
                        totalText,
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
                              "Paid Rides",
                              rideCount.toString(),
                              Icons.directions_car,
                            ),
                          ),
                          Expanded(
                            child: _buildEarningsStat(
                              "Avg Fare",
                              avgText,
                              Icons.attach_money,
                            ),
                          ),
                          Expanded(
                            child: _buildEarningsStat(
                              "Status",
                              "Paid",
                              Icons.check_circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
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

            // Earnings List - Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _getEarningsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load earnings',
                        style: GoogleFonts.poppins(color: Mycolors.red),
                      ),
                    );
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No earnings found',
                        style: GoogleFonts.poppins(color: Mycolors.gray),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final pickup = (data['pickup'] ?? '').toString();
                      final destination = (data['destination'] ?? 'Ride')
                          .toString();
                      final fare = data['fare'];
                      final status = (data['status'] ?? '').toString();
                      final paidAt = data['paidAt'] as Timestamp?;
                      final method = (data['paymentMethod'] ?? '').toString();
                      final timeText = paidAt != null
                          ? _formatTimeAgo(paidAt.toDate())
                          : '';
                      final amount = fare != null ? '₹$fare' : '₹0';
                      final color = status == 'paid'
                          ? Mycolors.green
                          : Mycolors.orange;

                      return _buildEarningsItem(
                        '$pickup → $destination',
                        method.isNotEmpty ? 'Paid • $method' : 'Paid',
                        amount,
                        timeText,
                        color,
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Summary (from Firestore)
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getEarningsStream(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                num total = 0;
                for (final d in docs) {
                  final fare = d.data()['fare'];
                  if (fare is num) total += fare;
                }
                return Container(
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
                            '₹${total.toStringAsFixed(0)}',
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
                );
              },
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

  Stream<QuerySnapshot<Map<String, dynamic>>> _getEarningsStream() {
    final driverId = AuthService.currentUserId;
    if (driverId == null) return const Stream.empty();

    DateTime startDate;
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case "Today":
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case "Week":
        startDate = now.subtract(const Duration(days: 7));
        break;
      case "Month":
        startDate = DateTime(now.year, now.month, 1);
        break;
      case "All":
        startDate = DateTime(2020); // Very old date
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    return FirebaseFirestore.instance
        .collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'paid')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String _getTotalEarnings() {
    // This will be calculated from Firestore data
    return "₹0"; // Placeholder - would need to calculate from stream
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
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
}
