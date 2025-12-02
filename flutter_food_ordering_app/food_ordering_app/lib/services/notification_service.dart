import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_ordering_app/models/Notification.dart';

class NotificationService {
  static const String _notificationsKey = 'notifications';
  static NotificationService? _instance;
  List<NotificationModel> _notifications = [];

  // Singleton pattern
  static NotificationService get instance {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  NotificationService._internal();

  // Khởi tạo và tải thông báo từ SharedPreferences
  Future<void> init() async {
    await _loadNotifications();
  }

  // Tải thông báo từ SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson != null) {
        final List<dynamic> decoded = json.decode(notificationsJson);
        _notifications =
            decoded.map((item) => NotificationModel.fromJson(item)).toList();

        // Sắp xếp theo thời gian mới nhất
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      print('Error loading notifications: $e');
      _notifications = [];
    }
  }

  // Lưu thông báo vào SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _notifications.map((notification) => notification.toJson()).toList(),
      );
      await prefs.setString(_notificationsKey, encoded);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  // Thêm thông báo mới
  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      data: data,
    );

    _notifications.insert(0, notification);

    // Giới hạn số lượng thông báo (giữ 100 thông báo gần nhất)
    if (_notifications.length > 100) {
      _notifications = _notifications.sublist(0, 100);
    }

    await _saveNotifications();
  }

  // Lấy tất cả thông báo
  List<NotificationModel> getAllNotifications() {
    return List.unmodifiable(_notifications);
  }

  // Lấy thông báo chưa đọc
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Đếm số thông báo chưa đọc
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  // Đánh dấu thông báo là đã đọc
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  // Đánh dấu tất cả là đã đọc
  Future<void> markAllAsRead() async {
    _notifications =
        _notifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList();
    await _saveNotifications();
  }

  // Xóa thông báo
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
  }

  // Xóa tất cả thông báo
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
  }

  // Các phương thức tiện lợi để tạo thông báo cho các sự kiện cụ thể

  // Thông báo đơn hàng đã đặt thành công
  Future<void> notifyOrderPlaced(int orderId, String restaurantName) async {
    await addNotification(
      title: 'Đơn hàng đã được đặt',
      message: 'Đơn hàng #$orderId từ $restaurantName đã được đặt thành công',
      type: NotificationType.orderPlaced,
      data: {'orderId': orderId, 'restaurantName': restaurantName},
    );
  }

  // Thông báo đơn hàng đã xác nhận
  Future<void> notifyOrderConfirmed(int orderId) async {
    await addNotification(
      title: 'Đơn hàng đã được xác nhận',
      message: 'Đơn hàng #$orderId của bạn đã được nhà hàng xác nhận',
      type: NotificationType.orderConfirmed,
      data: {'orderId': orderId},
    );
  }

  // Thông báo đang chuẩn bị món
  Future<void> notifyOrderPreparing(int orderId) async {
    await addNotification(
      title: 'Đang chuẩn bị món',
      message: 'Nhà hàng đang chuẩn bị món ăn cho đơn hàng #$orderId',
      type: NotificationType.orderPreparing,
      data: {'orderId': orderId},
    );
  }

  // Thông báo tài xế đã lấy món
  Future<void> notifyOrderPickedUp(int orderId) async {
    await addNotification(
      title: 'Đơn hàng của bạn đã được lấy',
      message: 'Tài xế đã lấy đơn hàng #$orderId và đang trên đường giao',
      type: NotificationType.orderPickedUp,
      data: {'orderId': orderId},
    );
  }

  // Thông báo đã giao hàng
  Future<void> notifyOrderDelivered(int orderId) async {
    await addNotification(
      title: 'Đơn hàng đã được giao',
      message:
          'Đơn hàng #$orderId đã được giao thành công. Chúc bạn ngon miệng!',
      type: NotificationType.orderDelivered,
      data: {'orderId': orderId},
    );
  }

  // Thông báo đơn hàng bị hủy
  Future<void> notifyOrderCancelled(int orderId, String reason) async {
    await addNotification(
      title: 'Đơn hàng đã bị hủy',
      message: 'Đơn hàng #$orderId đã bị hủy. Lý do: $reason',
      type: NotificationType.orderCancelled,
      data: {'orderId': orderId, 'reason': reason},
    );
  }

  // Thông báo thanh toán thành công
  Future<void> notifyPaymentSuccess(int orderId, double amount) async {
    await addNotification(
      title: 'Thanh toán thành công',
      message:
          'Bạn đã thanh toán ${amount.toStringAsFixed(0)}₫ cho đơn hàng #$orderId',
      type: NotificationType.paymentSuccess,
      data: {'orderId': orderId, 'amount': amount},
    );
  }

  // Thông báo thanh toán thất bại
  Future<void> notifyPaymentFailed(int orderId) async {
    await addNotification(
      title: 'Thanh toán thất bại',
      message:
          'Thanh toán cho đơn hàng #$orderId không thành công. Vui lòng thử lại',
      type: NotificationType.paymentFailed,
      data: {'orderId': orderId},
    );
  }

  // Thông báo hoàn tiền
  Future<void> notifyRefund(int orderId, double amount) async {
    await addNotification(
      title: 'Đã hoàn tiền',
      message: 'Đã hoàn ${amount.toStringAsFixed(0)}₫ cho đơn hàng #$orderId',
      type: NotificationType.refund,
      data: {'orderId': orderId, 'amount': amount},
    );
  }

  // Thông báo đã đánh giá
  Future<void> notifyReviewSubmitted(String restaurantName) async {
    await addNotification(
      title: 'Đánh giá đã được gửi',
      message: 'Cảm ơn bạn đã đánh giá $restaurantName',
      type: NotificationType.review,
      data: {'restaurantName': restaurantName},
    );
  }

  // Thông báo khuyến mãi
  Future<void> notifyPromotion(String title, String message) async {
    await addNotification(
      title: title,
      message: message,
      type: NotificationType.promotion,
    );
  }

  // Thông báo điểm thưởng
  Future<void> notifyReward(int points) async {
    await addNotification(
      title: 'Điểm thưởng đã được cộng',
      message: 'Bạn đã nhận được $points điểm thưởng',
      type: NotificationType.reward,
      data: {'points': points},
    );
  }
}
