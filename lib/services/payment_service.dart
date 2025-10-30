import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();

  VoidCallback? _onOpen;
  void Function(PaymentSuccessResponse response)? _onSuccess;
  void Function(PaymentFailureResponse response)? _onError;
  void Function(ExternalWalletResponse response)? _onExternalWallet;

  PaymentService({
    VoidCallback? onOpen,
    void Function(PaymentSuccessResponse response)? onSuccess,
    void Function(PaymentFailureResponse response)? onError,
    void Function(ExternalWalletResponse response)? onExternalWallet,
  }) {
    _onOpen = onOpen;
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  }

  void openCheckout({
    required String key,
    required int amountInPaise,
    required String name,
    required String description,
    required String prefillEmail,
    required String prefillContact,
    Map<String, Object?>? notes,
  }) {
    final options = {
      'key': key,
      'amount': amountInPaise, // in paise
      'name': name,
      'description': description,
      'prefill': {'contact': prefillContact, 'email': prefillEmail},
      'theme': {'color': '#0F6FC6'},
      if (notes != null) 'notes': notes,
    };

    _onOpen?.call();
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _onExternalWallet?.call(response);
  }

  void dispose() {
    _razorpay.clear();
  }
}
