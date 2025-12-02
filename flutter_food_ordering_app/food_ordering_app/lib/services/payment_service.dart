import 'dart:async';
import 'dart:math';
import 'package:food_ordering_app/models/Payment.dart';
import 'package:food_ordering_app/services/notification_service.dart';

class PaymentService {
  static PaymentService? _instance;
  final Random _random = Random();

  // Singleton pattern
  static PaymentService get instance {
    _instance ??= PaymentService._internal();
    return _instance!;
  }

  PaymentService._internal();

  // Generate transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = _random.nextInt(9999);
    return 'TXN${timestamp}_$randomNum';
  }

  // Xử lý thanh toán COD
  Future<PaymentResult> processCODPayment({
    required int orderId,
    required double amount,
  }) async {
    // COD luôn thành công ngay lập tức
    final result = PaymentResult(
      transactionId: _generateTransactionId(),
      paymentMethod: PaymentMethodType.cod,
      status: PaymentStatus.success,
      amount: amount,
      timestamp: DateTime.now(),
      metadata: {'orderId': orderId},
    );

    // Thông báo
    await NotificationService.instance.notifyPaymentSuccess(orderId, amount);

    return result;
  }

  // Xử lý thanh toán MoMo (Mock)
  Future<PaymentResult> processMoMoPayment({
    required int orderId,
    required double amount,
  }) async {
    // Giả lập delay xử lý
    await Future.delayed(const Duration(seconds: 3));

    // 85% success rate
    final isSuccess = _random.nextDouble() < 0.85;

    final result = PaymentResult(
      transactionId: _generateTransactionId(),
      paymentMethod: PaymentMethodType.momo,
      status: isSuccess ? PaymentStatus.success : PaymentStatus.failed,
      amount: amount,
      timestamp: DateTime.now(),
      errorMessage: isSuccess ? null : 'Số dư tài khoản không đủ',
      metadata: {'orderId': orderId, 'walletType': 'MoMo'},
    );

    // Thông báo
    if (isSuccess) {
      await NotificationService.instance.notifyPaymentSuccess(orderId, amount);
    } else {
      await NotificationService.instance.notifyPaymentFailed(orderId);
    }

    return result;
  }

  // Xử lý thanh toán ZaloPay (Mock)
  Future<PaymentResult> processZaloPayPayment({
    required int orderId,
    required double amount,
  }) async {
    // Giả lập delay xử lý
    await Future.delayed(const Duration(seconds: 3));

    // 85% success rate
    final isSuccess = _random.nextDouble() < 0.85;

    final result = PaymentResult(
      transactionId: _generateTransactionId(),
      paymentMethod: PaymentMethodType.zalopay,
      status: isSuccess ? PaymentStatus.success : PaymentStatus.failed,
      amount: amount,
      timestamp: DateTime.now(),
      errorMessage: isSuccess ? null : 'Giao dịch bị từ chối',
      metadata: {'orderId': orderId, 'walletType': 'ZaloPay'},
    );

    // Thông báo
    if (isSuccess) {
      await NotificationService.instance.notifyPaymentSuccess(orderId, amount);
    } else {
      await NotificationService.instance.notifyPaymentFailed(orderId);
    }

    return result;
  }

  // Xử lý thanh toán thẻ (Mock)
  Future<PaymentResult> processCardPayment({
    required int orderId,
    required double amount,
    required CardInfo cardInfo,
  }) async {
    // Validate thông tin thẻ
    if (!CardInfo.validateCardNumber(cardInfo.cardNumber)) {
      return PaymentResult(
        transactionId: _generateTransactionId(),
        paymentMethod: PaymentMethodType.card,
        status: PaymentStatus.failed,
        amount: amount,
        timestamp: DateTime.now(),
        errorMessage: 'Số thẻ không hợp lệ',
        metadata: {'orderId': orderId},
      );
    }

    if (!CardInfo.validateExpiryDate(cardInfo.expiryDate)) {
      return PaymentResult(
        transactionId: _generateTransactionId(),
        paymentMethod: PaymentMethodType.card,
        status: PaymentStatus.failed,
        amount: amount,
        timestamp: DateTime.now(),
        errorMessage: 'Ngày hết hạn không hợp lệ',
        metadata: {'orderId': orderId},
      );
    }

    if (!CardInfo.validateCVV(cardInfo.cvv)) {
      return PaymentResult(
        transactionId: _generateTransactionId(),
        paymentMethod: PaymentMethodType.card,
        status: PaymentStatus.failed,
        amount: amount,
        timestamp: DateTime.now(),
        errorMessage: 'CVV không hợp lệ',
        metadata: {'orderId': orderId},
      );
    }

    // Giả lập delay xử lý
    await Future.delayed(const Duration(seconds: 4));

    // Test cards
    final cardNumber = cardInfo.cardNumber.replaceAll(RegExp(r'\s'), '');
    bool isSuccess;

    if (cardNumber == '4242424242424242') {
      // Test card success
      isSuccess = true;
    } else if (cardNumber == '4000000000000002') {
      // Test card decline
      isSuccess = false;
    } else {
      // Random success (80%)
      isSuccess = _random.nextDouble() < 0.80;
    }

    final result = PaymentResult(
      transactionId: _generateTransactionId(),
      paymentMethod: PaymentMethodType.card,
      status: isSuccess ? PaymentStatus.success : PaymentStatus.failed,
      amount: amount,
      timestamp: DateTime.now(),
      errorMessage: isSuccess ? null : 'Thẻ bị từ chối hoặc hết hạn mức',
      metadata: {
        'orderId': orderId,
        'cardType': CardInfo.getCardType(cardNumber),
        'lastFourDigits': cardNumber.substring(cardNumber.length - 4),
      },
    );

    // Thông báo
    if (isSuccess) {
      await NotificationService.instance.notifyPaymentSuccess(orderId, amount);
    } else {
      await NotificationService.instance.notifyPaymentFailed(orderId);
    }

    return result;
  }

  // Xử lý thanh toán QR Banking (Mock)
  Future<PaymentResult> processBankingPayment({
    required int orderId,
    required double amount,
  }) async {
    // Giả lập delay chờ người dùng chuyển khoản
    await Future.delayed(const Duration(seconds: 5));

    // 90% success rate (vì người dùng đã chuyển khoản)
    final isSuccess = _random.nextDouble() < 0.90;

    final result = PaymentResult(
      transactionId: _generateTransactionId(),
      paymentMethod: PaymentMethodType.banking,
      status: isSuccess ? PaymentStatus.success : PaymentStatus.failed,
      amount: amount,
      timestamp: DateTime.now(),
      errorMessage: isSuccess ? null : 'Không tìm thấy giao dịch chuyển khoản',
      metadata: {
        'orderId': orderId,
        'bankName': 'MB Bank',
        'accountNumber': '0123456789',
      },
    );

    // Thông báo
    if (isSuccess) {
      await NotificationService.instance.notifyPaymentSuccess(orderId, amount);
    } else {
      await NotificationService.instance.notifyPaymentFailed(orderId);
    }

    return result;
  }

  // Xử lý thanh toán chung (router)
  Future<PaymentResult> processPayment({
    required PaymentMethodType method,
    required int orderId,
    required double amount,
    CardInfo? cardInfo,
  }) async {
    switch (method) {
      case PaymentMethodType.cod:
        return await processCODPayment(orderId: orderId, amount: amount);

      case PaymentMethodType.momo:
        return await processMoMoPayment(orderId: orderId, amount: amount);

      case PaymentMethodType.zalopay:
        return await processZaloPayPayment(orderId: orderId, amount: amount);

      case PaymentMethodType.card:
        if (cardInfo == null) {
          return PaymentResult(
            transactionId: _generateTransactionId(),
            paymentMethod: PaymentMethodType.card,
            status: PaymentStatus.failed,
            amount: amount,
            timestamp: DateTime.now(),
            errorMessage: 'Thiếu thông tin thẻ',
            metadata: {'orderId': orderId},
          );
        }
        return await processCardPayment(
          orderId: orderId,
          amount: amount,
          cardInfo: cardInfo,
        );

      case PaymentMethodType.banking:
        return await processBankingPayment(orderId: orderId, amount: amount);
    }
  }

  // Generate QR code data cho VietQR
  String generateVietQRData({
    required int orderId,
    required double amount,
    String bankCode = 'MB', // MB Bank
    String accountNumber = '0123456789',
  }) {
    // Format theo chuẩn VietQR
    // Bank Code|Account Number|Amount|Description
    final description = 'FD$orderId';
    final amountStr = amount.toStringAsFixed(0);

    return '$bankCode|$accountNumber|$amountStr|$description';
  }

  // Format số thẻ với khoảng trắng
  String formatCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\s'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  // Format expiry date
  String formatExpiryDate(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length >= 2) {
      return '${digits.substring(0, 2)}/${digits.substring(2)}';
    }

    return digits;
  }
}
