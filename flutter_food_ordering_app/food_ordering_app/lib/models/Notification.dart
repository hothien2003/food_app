class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>? data; // Dữ liệu bổ sung (VD: mã đơn hàng)

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.data,
  });

  // Tạo thông báo từ JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.general,
      ),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  // Chuyển thông báo sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  // Copy với thay đổi
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }

  // Lấy thời gian hiển thị thân thiện
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      final day = timestamp.day.toString().padLeft(2, '0');
      final month = timestamp.month.toString().padLeft(2, '0');
      final year = timestamp.year;
      return '$day Thg $month $year';
    }
  }
}

// Các loại thông báo
enum NotificationType {
  orderPlaced, // Đơn hàng đã đặt
  orderConfirmed, // Đơn hàng đã được xác nhận
  orderPreparing, // Đang chuẩn bị món
  orderPickedUp, // Tài xế đã lấy món
  orderDelivered, // Đã giao hàng
  orderCancelled, // Đơn hàng đã hủy
  paymentSuccess, // Thanh toán thành công
  paymentFailed, // Thanh toán thất bại
  refund, // Hoàn tiền
  review, // Đánh giá
  promotion, // Khuyến mãi
  reward, // Điểm thưởng
  general, // Thông báo chung
}
