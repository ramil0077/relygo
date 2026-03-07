import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:relygo/screens/user_dashboard_screen.dart';
import 'package:relygo/utils/platform_utils.dart';
import 'package:relygo/utils/responsive.dart';

class PaymentScreen extends StatefulWidget {
  final String requestId;
  final String driverName;
  final String destination;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.requestId,
    required this.driverName,
    required this.destination,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;
<<<<<<< HEAD
  PaymentService? _paymentService;

  static String get _razorpayKey => PaymentConfig.razorpayKey;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      onOpen: () {
        setState(() {
          _isProcessing = true;
        });
      },
      onSuccess: (PaymentSuccessResponse response) async {
        await _markPaid(method: _selectedPaymentMethod);
        if (!mounted) return;
        await _showSuccessDialog();
        setState(() {
          _isProcessing = false;
        });
      },
      onError: (PaymentFailureResponse response) {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed. Please try again.')),
        );
      },
    );
  }

  @override
  void dispose() {
    _paymentService?.dispose();
    super.dispose();
  }
=======
>>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10

  @override
  Widget build(BuildContext context) {
    // Show message on web that payment is not available
    if (PlatformUtils.isWeb) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "Payment",
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment_outlined,
                  size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 80, tablet: 100, desktop: 120),
                  color: Mycolors.basecolor.withOpacity(0.5),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 24, tablet: 28, desktop: 32)),
                Text(
                  'Payment Not Available on Web',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 24, tablet: 26, desktop: 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20)),
                Text(
                  'Payment features are only available on mobile devices. Please use the mobile app to complete your payment.',
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 32, tablet: 36, desktop: 40)),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors.basecolor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveSpacing(context, mobile: 32, tablet: 36, desktop: 40),
                      vertical: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 18, desktop: 20),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
                      ),
                    ),
                  ),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Payment",
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ride Details
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: Mycolors.lightGray,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ride Details",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                    Text(
                      "Driver: ${widget.driverName}",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                      ),
                    ),
                    Text(
                      "Destination: ${widget.destination}",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 24, desktop: 28)),

              // Amount
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context),
                decoration: BoxDecoration(
                  color: Mycolors.basecolor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
                  ),
                  border: Border.all(
                    color: Mycolors.basecolor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "₹${widget.amount.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 24, tablet: 26, desktop: 28),
                        fontWeight: FontWeight.bold,
                        color: Mycolors.basecolor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 30, tablet: 36, desktop: 40)),

              // Payment Methods
              Text(
                "Payment Method",
                style: GoogleFonts.poppins(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 15, tablet: 18, desktop: 20)),

              _buildPaymentMethod(
                'card',
                'Credit/Debit Card',
                Icons.credit_card,
                'Pay with your card',
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 10, tablet: 12, desktop: 14)),
              _buildPaymentMethod(
                'upi',
                'UPI',
                Icons.account_balance_wallet,
                'Pay with UPI',
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 10, tablet: 12, desktop: 14)),
              _buildPaymentMethod(
                'cash',
                'Cash',
                Icons.money,
                'Pay in cash to driver',
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 30, tablet: 36, desktop: 40)),

              // Pay Now Button
              SizedBox(
                width: double.infinity,
                height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 55, tablet: 60, desktop: 65),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors.basecolor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
                      ),
                    ),
                    elevation: ResponsiveUtils.getResponsiveElevation(context, mobile: 2, tablet: 3, desktop: 4),
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 22, desktop: 24),
                          width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 20, tablet: 22, desktop: 24),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Pay ₹${widget.amount.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(
    String value,
    String title,
    IconData icon,
    String subtitle,
  ) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: isSelected
              ? Mycolors.basecolor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, mobile: 12, tablet: 14, desktop: 16),
          ),
=======
          color: isSelected ? Mycolors.basecolor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
>>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10
          border: Border.all(
            color: isSelected ? Mycolors.basecolor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Mycolors.basecolor : Colors.grey,
              size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24, tablet: 26, desktop: 28),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, mobile: 12, tablet: 14, desktop: 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Mycolors.basecolor : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Mycolors.basecolor,
                size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24, tablet: 26, desktop: 28),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

<<<<<<< HEAD
    // Card/UPI: open Razorpay test checkout
    final int amountPaise = (widget.amount * 100).toInt();
    _paymentService?.openCheckout(
      key: _razorpayKey,
      amountInPaise: amountPaise,
      name: 'RelyGo Ride',
      description: 'Payment for ${widget.destination}',
      prefillEmail: 'test@example.com',
      prefillContact: '9999999999',
      notes: {'requestId': widget.requestId, 'driverName': widget.driverName},
    );
  }

  Future<void> _markPaid({required String method}) async {
<<<<<<< HEAD
    // Update ride_requests collection
=======
    try {
      // Simulated payment processing (works reliably on all devices)
      await Future.delayed(const Duration(seconds: 2));

      await _markPaid(method: _selectedPaymentMethod);
      if (!mounted) return;
      await _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _markPaid({required String method}) async {
>>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10
    await FirebaseFirestore.instance
        .collection('ride_requests')
        .doc(widget.requestId)
        .update({
<<<<<<< HEAD
          'status': 'ongoing',
          'isPaid': true,
=======
      final batch = FirebaseFirestore.instance.batch();
      
      // Update ride_requests
      final rideRequestRef = FirebaseFirestore.instance.collection('ride_requests').doc(widget.requestId);
      batch.update(rideRequestRef, {
        'status': 'ongoing',
        'paymentMethod': method,
        'paidAt': FieldValue.serverTimestamp(),
        'isPaid': true,
      });

      // Update bookings if it exists
      final bookingRef = FirebaseFirestore.instance.collection('bookings').doc(widget.requestId);
      batch.update(bookingRef, {
        'status': 'ongoing',
        'paymentMethod': method,
        'paidAt': FieldValue.serverTimestamp(),
        'isPaid': true,
      });

      await batch.commit().catchError((e) {
        // If bookings doesn't exist, the batch might fail if we don't handle it.
        // But since they use same ID, it's safer to do individual updates or check existence.
        // Let's do individual to avoid batch failure on non-existent doc.
      });
      
      final rideRequestDoc = await rideRequestRef.get();
      final driverId = rideRequestDoc.data()?['driverId'];
      
      // To be safe, just do individual updates
      await rideRequestRef.update({
        'status': 'ongoing',
        'paymentMethod': method,
        'paidAt': FieldValue.serverTimestamp(),
        'isPaid': true,
      });
      
      try {
        await bookingRef.update({
          'status': 'ongoing',
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
          'paymentMethod': method,
          'paidAt': FieldValue.serverTimestamp(),
          'isPaid': true,
        });
<<<<<<< HEAD
    
    // Also update bookings collection if it exists
    try {
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.requestId)
          .get();
      if (bookingDoc.exists) {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.requestId)
            .update({
              'status': 'ongoing',
              'isPaid': true,
              'paymentMethod': method,
              'paymentDate': Timestamp.now(),
            });
      }
    } catch (e) {
      // Ignore if bookings collection doesn't have this document
      print('Bookings collection update skipped: $e');
    }
=======
      } catch (_) {}

      // Notify driver about payment
      if (driverId != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'driverId': driverId,
          'title': 'Payment Received',
          'message': 'Payment has been received for ride with ${rideRequestDoc.data()?['userName'] ?? 'User'}.',
          'type': 'payment_received',
          'bookingId': widget.requestId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
>>>>>>> b07d4e920cd2ae6666412320823f957957d9089c
=======
      'status': 'paid',
      'paymentMethod': method,
      'paidAt': Timestamp.now(),
    });
>>>>>>> 19c60511df77cf71534b179d6daa8ec8cebe0b10
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Mycolors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Mycolors.green,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                // Success Title
                Text(
                  'Payment Successful!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Success Message
                Text(
                  'Your payment of ₹${widget.amount.toStringAsFixed(0)} has been processed successfully.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'Driver will be notified about your payment.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const UserDashboardScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Mycolors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Continue to Home',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
