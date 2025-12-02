// Enum cho các phương thức thanh toán
enum PaymentMethodType {
  cod, // Tiền mặt khi nhận hàng
  momo, // Ví MoMo
  zalopay, // Ví ZaloPay
  card, // Thẻ tín dụng/ghi nợ
  banking, // Chuyển khoản ngân hàng (QR)
}

// Model cho phương thức thanh toán
class PaymentMethod {
  final PaymentMethodType type;
  final String name;
  final String description;
  final String iconPath;
  final bool isAvailable;

  const PaymentMethod({
    required this.type,
    required this.name,
    required this.description,
    required this.iconPath,
    this.isAvailable = true,
  });

  // Danh sách các phương thức thanh toán
  static List<PaymentMethod> getAvailableMethods() {
    return [
      const PaymentMethod(
        type: PaymentMethodType.cod,
        name: 'Tiền mặt (COD)',
        description: 'Thanh toán khi nhận hàng',
        iconPath: 'money',
      ),
      const PaymentMethod(
        type: PaymentMethodType.momo,
        name: 'Ví MoMo',
        description: 'Thanh toán qua ví điện tử MoMo',
        iconPath: 'momo',
      ),
      const PaymentMethod(
        type: PaymentMethodType.zalopay,
        name: 'ZaloPay',
        description: 'Thanh toán qua ví ZaloPay',
        iconPath: 'zalopay',
      ),
      const PaymentMethod(
        type: PaymentMethodType.banking,
        name: 'Chuyển khoản QR',
        description: 'Quét mã QR để chuyển khoản',
        iconPath: 'qr_code',
      ),
      const PaymentMethod(
        type: PaymentMethodType.card,
        name: 'Thẻ tín dụng/Ghi nợ',
        description: 'Visa, Mastercard, JCB',
        iconPath: 'credit_card',
      ),
    ];
  }
}

// Enum cho trạng thái thanh toán
enum PaymentStatus {
  pending, // Đang chờ
  processing, // Đang xử lý
  success, // Thành công
  failed, // Thất bại
  cancelled, // Đã hủy
}

// Model cho kết quả thanh toán
class PaymentResult {
  final String transactionId;
  final PaymentMethodType paymentMethod;
  final PaymentStatus status;
  final double amount;
  final DateTime timestamp;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const PaymentResult({
    required this.transactionId,
    required this.paymentMethod,
    required this.status,
    required this.amount,
    required this.timestamp,
    this.errorMessage,
    this.metadata,
  });

  // Factory constructor từ JSON
  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      transactionId: json['transactionId'] as String,
      paymentMethod: PaymentMethodType.values.firstWhere(
        (e) => e.toString() == 'PaymentMethodType.${json['paymentMethod']}',
        orElse: () => PaymentMethodType.cod,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'status': status.toString().split('.').last,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  // Copy với thay đổi
  PaymentResult copyWith({
    String? transactionId,
    PaymentMethodType? paymentMethod,
    PaymentStatus? status,
    double? amount,
    DateTime? timestamp,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  // Kiểm tra thanh toán thành công
  bool get isSuccess => status == PaymentStatus.success;

  // Kiểm tra thanh toán thất bại
  bool get isFailed => status == PaymentStatus.failed;

  // Kiểm tra đang xử lý
  bool get isProcessing => status == PaymentStatus.processing;
}

// Model cho thông tin thẻ tín dụng
class CardInfo {
  final String cardNumber;
  final String cardholderName;
  final String expiryDate;
  final String cvv;

  const CardInfo({
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.cvv,
  });

  // Validate số thẻ bằng Luhn algorithm
  static bool validateCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\s'), '');
    if (digits.isEmpty || digits.length < 13 || digits.length > 19) {
      return false;
    }

    int sum = 0;
    bool alternate = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return (sum % 10 == 0);
  }

  // Validate ngày hết hạn
  static bool validateExpiryDate(String expiryDate) {
    if (expiryDate.length != 5) return false;

    final parts = expiryDate.split('/');
    if (parts.length != 2) return false;

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    if (year < currentYear) return false;
    if (year == currentYear && month < currentMonth) return false;

    return true;
  }

  // Validate CVV
  static bool validateCVV(String cvv) {
    return cvv.length >= 3 && cvv.length <= 4 && int.tryParse(cvv) != null;
  }

  // Lấy loại thẻ từ số thẻ
  static String getCardType(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\s'), '');

    if (digits.startsWith('4')) {
      return 'Visa';
    } else if (digits.startsWith(RegExp(r'5[1-5]'))) {
      return 'Mastercard';
    } else if (digits.startsWith(RegExp(r'3[47]'))) {
      return 'American Express';
    } else if (digits.startsWith(RegExp(r'35'))) {
      return 'JCB';
    }

    return 'Unknown';
  }

  // Mask số thẻ (hiển thị 4 số cuối)
  String get maskedCardNumber {
    final digits = cardNumber.replaceAll(RegExp(r'\s'), '');
    if (digits.length < 4) return cardNumber;
    return '**** **** **** ${digits.substring(digits.length - 4)}';
  }
}
