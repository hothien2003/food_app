import 'package:flutter/material.dart';
import 'package:food_ordering_app/services/notification_service.dart';
import 'package:food_ordering_app/const/colors.dart';

/// Màn hình demo để test hệ thống thông báo
/// Sử dụng để kiểm tra các loại thông báo khác nhau
class NotificationDemoScreen extends StatelessWidget {
  static const routeName = "/notificationDemo";

  const NotificationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Thông báo'),
        backgroundColor: AppColor.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Nhấn vào các nút bên dưới để tạo thông báo demo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          _buildDemoButton(
            context,
            'Đặt hàng thành công',
            Icons.receipt_long,
            Colors.green,
            () async {
              await NotificationService.instance.notifyOrderPlaced(
                12345,
                'Nhà hàng Phở Việt',
              );
              _showSnackbar(context, 'Đã tạo thông báo đặt hàng');
            },
          ),

          _buildDemoButton(
            context,
            'Thanh toán thành công',
            Icons.payment,
            Colors.blue,
            () async {
              await NotificationService.instance.notifyPaymentSuccess(
                12345,
                150000,
              );
              _showSnackbar(context, 'Đã tạo thông báo thanh toán');
            },
          ),

          _buildDemoButton(
            context,
            'Đơn hàng đã được xác nhận',
            Icons.check_circle,
            Colors.teal,
            () async {
              await NotificationService.instance.notifyOrderConfirmed(12345);
              _showSnackbar(context, 'Đã tạo thông báo xác nhận');
            },
          ),

          _buildDemoButton(
            context,
            'Đang chuẩn bị món',
            Icons.restaurant,
            Colors.orange,
            () async {
              await NotificationService.instance.notifyOrderPreparing(12345);
              _showSnackbar(context, 'Đã tạo thông báo chuẩn bị');
            },
          ),

          _buildDemoButton(
            context,
            'Tài xế đã lấy món',
            Icons.delivery_dining,
            Colors.purple,
            () async {
              await NotificationService.instance.notifyOrderPickedUp(12345);
              _showSnackbar(context, 'Đã tạo thông báo lấy món');
            },
          ),

          _buildDemoButton(
            context,
            'Đã giao hàng',
            Icons.done_all,
            Colors.green,
            () async {
              await NotificationService.instance.notifyOrderDelivered(12345);
              _showSnackbar(context, 'Đã tạo thông báo giao hàng');
            },
          ),

          _buildDemoButton(
            context,
            'Đơn hàng bị hủy',
            Icons.cancel,
            Colors.red,
            () async {
              await NotificationService.instance.notifyOrderCancelled(
                12345,
                'Nhà hàng đã đóng cửa',
              );
              _showSnackbar(context, 'Đã tạo thông báo hủy đơn');
            },
          ),

          _buildDemoButton(
            context,
            'Đánh giá đã gửi',
            Icons.star,
            Colors.amber,
            () async {
              await NotificationService.instance.notifyReviewSubmitted(
                'Nhà hàng Phở Việt',
              );
              _showSnackbar(context, 'Đã tạo thông báo đánh giá');
            },
          ),

          _buildDemoButton(
            context,
            'Khuyến mãi mới',
            Icons.local_offer,
            Colors.pink,
            () async {
              await NotificationService.instance.notifyPromotion(
                'Giảm giá 50% hôm nay!',
                'Áp dụng cho tất cả các món ăn. Nhanh tay đặt hàng ngay!',
              );
              _showSnackbar(context, 'Đã tạo thông báo khuyến mãi');
            },
          ),

          _buildDemoButton(
            context,
            'Điểm thưởng',
            Icons.card_giftcard,
            Colors.indigo,
            () async {
              await NotificationService.instance.notifyReward(100);
              _showSnackbar(context, 'Đã tạo thông báo điểm thưởng');
            },
          ),

          _buildDemoButton(
            context,
            'Hoàn tiền',
            Icons.account_balance_wallet,
            Colors.cyan,
            () async {
              await NotificationService.instance.notifyRefund(12345, 75000);
              _showSnackbar(context, 'Đã tạo thông báo hoàn tiền');
            },
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          _buildDemoButton(
            context,
            'Tạo 5 thông báo ngẫu nhiên',
            Icons.shuffle,
            Colors.deepPurple,
            () async {
              await _createRandomNotifications();
              _showSnackbar(context, 'Đã tạo 5 thông báo ngẫu nhiên');
            },
          ),

          _buildDemoButton(
            context,
            'Xóa tất cả thông báo',
            Icons.delete_sweep,
            Colors.grey,
            () async {
              await NotificationService.instance.clearAllNotifications();
              _showSnackbar(context, 'Đã xóa tất cả thông báo');
            },
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              final count = NotificationService.instance.getUnreadCount();
              _showSnackbar(context, 'Có $count thông báo chưa đọc');
            },
            icon: const Icon(Icons.info_outline),
            label: const Text('Kiểm tra số thông báo chưa đọc'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _createRandomNotifications() async {
    final notifications = [
      () => NotificationService.instance.notifyOrderPlaced(
        (DateTime.now().millisecondsSinceEpoch % 100000),
        'Nhà hàng ${['Phở Việt', 'Bún Bò Huế', 'Cơm Tấm', 'Bánh Mì'][DateTime.now().second % 4]}',
      ),
      () => NotificationService.instance.notifyPaymentSuccess(
        (DateTime.now().millisecondsSinceEpoch % 100000),
        [50000, 75000, 100000, 150000][DateTime.now().second % 4].toDouble(),
      ),
      () => NotificationService.instance.notifyOrderConfirmed(
        (DateTime.now().millisecondsSinceEpoch % 100000),
      ),
      () => NotificationService.instance.notifyOrderPreparing(
        (DateTime.now().millisecondsSinceEpoch % 100000),
      ),
      () => NotificationService.instance.notifyOrderPickedUp(
        (DateTime.now().millisecondsSinceEpoch % 100000),
      ),
      () => NotificationService.instance.notifyOrderDelivered(
        (DateTime.now().millisecondsSinceEpoch % 100000),
      ),
      () => NotificationService.instance.notifyReviewSubmitted(
        'Nhà hàng ${['Phở Việt', 'Bún Bò Huế', 'Cơm Tấm'][DateTime.now().second % 3]}',
      ),
      () => NotificationService.instance.notifyPromotion(
        'Khuyến mãi đặc biệt!',
        'Giảm giá ${[20, 30, 40, 50][DateTime.now().second % 4]}% cho đơn hàng hôm nay',
      ),
      () => NotificationService.instance.notifyReward(
        [50, 100, 150, 200][DateTime.now().second % 4],
      ),
    ];

    // Tạo 5 thông báo ngẫu nhiên
    for (int i = 0; i < 5; i++) {
      final randomIndex =
          (DateTime.now().millisecondsSinceEpoch + i) % notifications.length;
      await notifications[randomIndex]();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
