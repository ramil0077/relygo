import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:relygo/services/admin_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  Map<String, dynamic>? _reportData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    final data = await AdminService.getServiceReport();
    setState(() {
      _reportData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Service Report",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadReportData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reportData == null
              ? Center(
                  child: Text(
                    'Failed to load report',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      Text(
                        "Overview",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              _reportData!['totalUsers'].toString(),
                              "Total Users",
                              Icons.people,
                              Mycolors.blue,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              _reportData!['activeDrivers'].toString(),
                              "Active Drivers",
                              Icons.drive_eta,
                              Mycolors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Booking Statistics
                      Text(
                        "Booking Statistics",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildAnalyticsCard(
                        "Total Bookings",
                        _reportData!['totalBookings'].toString(),
                        Icons.book_online,
                        Mycolors.basecolor,
                        [
                          _buildDetailRow(
                            'Completed',
                            _reportData!['completedBookings'].toString(),
                          ),
                          _buildDetailRow(
                            'Cancelled',
                            _reportData!['cancelledBookings'].toString(),
                          ),
                          _buildDetailRow(
                            'Success Rate',
                            _reportData!['totalBookings'] > 0
                                ? '${((_reportData!['completedBookings'] / _reportData!['totalBookings']) * 100).toStringAsFixed(1)}%'
                                : '0%',
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Revenue
                      Text(
                        "Revenue",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildAnalyticsCard(
                        "Total Revenue",
                        "₹${_reportData!['totalRevenue'].toStringAsFixed(2)}",
                        Icons.currency_rupee,
                        Mycolors.green,
                        [
                          _buildDetailRow(
                            'From Completed Rides',
                            _reportData!['completedBookings'].toString(),
                          ),
                          _buildDetailRow(
                            'Average per Ride',
                            _reportData!['completedBookings'] > 0
                                ? '₹${(_reportData!['totalRevenue'] / _reportData!['completedBookings']).toStringAsFixed(2)}'
                                : '₹0',
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Feedback & Ratings
                      Text(
                        "Feedback & Ratings",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildAnalyticsCard(
                        "Customer Satisfaction",
                        "${_reportData!['averageRating'].toStringAsFixed(1)} ⭐",
                        Icons.star,
                        Mycolors.orange,
                        [
                          _buildDetailRow(
                            'Total Feedback',
                            _reportData!['totalFeedback'].toString(),
                          ),
                          _buildDetailRow(
                            'Rating',
                            '${_reportData!['averageRating'].toStringAsFixed(1)} / 5.0',
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _loadReportData,
                              icon: const Icon(Icons.refresh),
                              label: Text(
                                'Refresh',
                                style: GoogleFonts.poppins(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Mycolors.basecolor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _exportReport,
                              icon: const Icon(Icons.download),
                              label: Text(
                                'Export',
                                style: GoogleFonts.poppins(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Mycolors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String mainValue,
    IconData icon,
    Color color,
    List<Widget> details,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      mainValue,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 10),
          ...details,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    // In a real app, this would generate a PDF or CSV
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report export feature coming soon!'),
        backgroundColor: Mycolors.orange,
      ),
    );
  }
}
