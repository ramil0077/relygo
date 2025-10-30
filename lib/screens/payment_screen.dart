import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relygo/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:relygo/services/payment_service.dart';
import 'package:relygo/screens/user_dashboard_screen.dart';

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
  PaymentService? _paymentService;

  // NOTE: Use your Razorpay Test Key here for dummy/test payments
  static const String _razorpayTestKey = 'rzp_test_1DP5mmOlF5G5ag';

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

  @override
  Widget build(BuildContext context) {
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ride Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Mycolors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ride Details",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Driver: ${widget.driverName}",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    Text(
                      "Destination: ${widget.destination}",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Amount
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Mycolors.basecolor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "₹${widget.amount.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Mycolors.basecolor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Payment Methods
              Text(
                "Payment Method",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),

              _buildPaymentMethod(
                'card',
                'Credit/Debit Card',
                Icons.credit_card,
                'Pay with your card',
              ),
              const SizedBox(height: 10),
              _buildPaymentMethod(
                'upi',
                'UPI',
                Icons.account_balance_wallet,
                'Pay with UPI',
              ),
              const SizedBox(height: 10),
              _buildPaymentMethod(
                'cash',
                'Cash',
                Icons.money,
                'Pay in cash to driver',
              ),
              const SizedBox(height: 30),

              // Pay Now Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Mycolors.basecolor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Pay ₹${widget.amount.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Mycolors.basecolor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Mycolors.basecolor : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Mycolors.basecolor, size: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    // Cash: directly mark paid without Razorpay flow
    if (_selectedPaymentMethod == 'cash') {
      setState(() {
        _isProcessing = true;
      });
      try {
        await _markPaid(method: 'cash');
        if (!mounted) return;
        await _showSuccessDialog();
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
      return;
    }

    // Card/UPI: open Razorpay test checkout
    final int amountPaise = (widget.amount * 100).toInt();
    _paymentService?.openCheckout(
      key: _razorpayTestKey,
      amountInPaise: amountPaise,
      name: 'RelyGo Ride',
      description: 'Payment for ${widget.destination}',
      prefillEmail: 'test@example.com',
      prefillContact: '9999999999',
      notes: {'requestId': widget.requestId, 'driverName': widget.driverName},
    );
  }

  Future<void> _markPaid({required String method}) async {
    await FirebaseFirestore.instance
        .collection('ride_requests')
        .doc(widget.requestId)
        .update({
          'status': 'paid',
          'paymentMethod': method,
          'paidAt': Timestamp.now(),
        });
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
                      // Navigate to user dashboard screen
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
