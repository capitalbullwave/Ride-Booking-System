import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/api_endpoints.dart';
import 'package:wavego_user/core/network/dio_client.dart';
import 'package:wavego_user/models/membership_models.dart';
import 'package:wavego_user/services/base_api_service.dart';
import 'package:wavego_user/services/razorpay/razorpay_checkout.dart';

class WalletTopUpResult {
  const WalletTopUpResult({
    required this.balance,
    required this.message,
    this.transaction,
  });

  final double balance;
  final String message;
  final Map<String, dynamic>? transaction;

  factory WalletTopUpResult.fromJson(Map<String, dynamic> json) {
    final root = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final txn = root['transaction'];
    return WalletTopUpResult(
      balance: (root['balance'] as num?)?.toDouble() ?? 0,
      message: root['message'] as String? ?? 'Money added to wallet',
      transaction: txn is Map ? Map<String, dynamic>.from(txn) : null,
    );
  }
}

class WalletPaymentApiService extends BaseApiService {
  WalletPaymentApiService(super.dio);

  Future<SubscriptionCheckoutSession> createCheckout(double amount) async {
    final data = await post<Map<String, dynamic>>(
      ApiEndpoints.walletCheckout,
      data: {'amount': amount},
      parser: (raw) {
        if (raw is Map<String, dynamic>) return raw;
        if (raw is Map) return Map<String, dynamic>.from(raw);
        return <String, dynamic>{};
      },
    );
    final session = SubscriptionCheckoutSession.fromWalletCheckout(data);
    if (session.orderId.isEmpty || session.keyId.isEmpty) {
      throw StateError('Unable to start payment. Please try again.');
    }
    return session;
  }

  Future<WalletTopUpResult> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        return await post(
          ApiEndpoints.walletVerifyPayment,
          data: {
            'razorpay_order_id': orderId,
            'razorpay_payment_id': paymentId,
            'razorpay_signature': signature,
          },
          parser: (data) {
            if (data is Map<String, dynamic>) {
              return WalletTopUpResult.fromJson(data);
            }
            if (data is Map) {
              return WalletTopUpResult.fromJson(Map<String, dynamic>.from(data));
            }
            return const WalletTopUpResult(balance: 0, message: 'Wallet updated');
          },
        );
      } catch (error) {
        lastError = error;
        if (attempt < 4) {
          await Future<void>.delayed(Duration(milliseconds: 600 * (attempt + 1)));
        }
      }
    }
    Error.throwWithStackTrace(
      lastError ?? StateError('Wallet verification failed'),
      StackTrace.current,
    );
  }
}

class WalletPaymentController {
  WalletPaymentController(this._service);

  final WalletPaymentApiService _service;

  Future<WalletTopUpResult> addMoney(
    double amount, {
    void Function()? onCheckoutOpened,
    void Function(double amount)? onPaymentAuthorized,
  }) async {
    if (amount <= 0) {
      throw StateError('Enter a valid amount');
    }

    final checkout = await _service.createCheckout(amount);

    final payment = await openRazorpayCheckout(
      checkout,
      onOpened: onCheckoutOpened,
      onPaymentSuccess: (_) {
        onPaymentAuthorized?.call(amount);
      },
    );

    return _service.verifyPayment(
      orderId: payment.orderId,
      paymentId: payment.paymentId,
      signature: payment.signature,
    );
  }

  Future<WalletTopUpResult> verifyExistingPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    return _service.verifyPayment(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
    );
  }
}

final walletPaymentApiServiceProvider = Provider<WalletPaymentApiService>((ref) {
  return WalletPaymentApiService(ref.watch(dioClientProvider).dio);
});

final walletPaymentControllerProvider = Provider<WalletPaymentController>((ref) {
  return WalletPaymentController(ref.watch(walletPaymentApiServiceProvider));
});
