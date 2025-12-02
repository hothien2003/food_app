import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';
import 'package:food_ordering_app/services/notification_service.dart';
import 'package:food_ordering_app/models/Notification.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = "/notiScreen";

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService.instance;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await _notificationService.init();
    setState(() {
      _notifications = _notificationService.getAllNotifications();
    });
  }

  Future<void> _markAllAsRead() async {
    await _notificationService.markAllAsRead();
    setState(() {
      _notifications = _notificationService.getAllNotifications();
    });
  }

  Future<void> _deleteNotification(String id) async {
    await _notificationService.deleteNotification(id);
    setState(() {
      _notifications = _notificationService.getAllNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back_ios_rounded),
                        ),
                        Expanded(
                          child: Text(
                            "Thông báo",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                        ),
                        if (_notificationService.getUnreadCount() > 0)
                          TextButton(
                            onPressed: _markAllAsRead,
                            child: Text(
                              'Đánh dấu đã đọc',
                              style: TextStyle(color: AppColor.orange),
                            ),
                          ),
                        Image.asset(Helper.getAssetName("cart.png", "virtual")),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_notifications.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 80,
                            color: AppColor.placeholder,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Chưa có thông báo',
                            style: TextStyle(
                              color: AppColor.placeholder,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._notifications.map((notification) {
                      return Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteNotification(notification.id);
                        },
                        child: NotiCard(
                          notification: notification,
                          onTap: () async {
                            if (!notification.isRead) {
                              await _notificationService.markAsRead(
                                notification.id,
                              );
                              setState(() {
                                _notifications =
                                    _notificationService.getAllNotifications();
                              });
                            }
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomNavBar(menu: true),
          ),
        ],
      ),
    );
  }
}

class NotiCard extends StatelessWidget {
  const NotiCard({
    super.key,
    required NotificationModel notification,
    VoidCallback? onTap,
  }) : _notification = notification,
       _onTap = onTap;

  final NotificationModel _notification;
  final VoidCallback? _onTap;

  Color _getNotificationColor() {
    if (_notification.isRead) {
      return AppColor.placeholderBg;
    }
    return Colors.white;
  }

  IconData _getNotificationIcon() {
    switch (_notification.type) {
      case NotificationType.orderPlaced:
      case NotificationType.orderConfirmed:
      case NotificationType.orderPreparing:
        return Icons.receipt_long;
      case NotificationType.orderPickedUp:
        return Icons.delivery_dining;
      case NotificationType.orderDelivered:
        return Icons.check_circle;
      case NotificationType.orderCancelled:
        return Icons.cancel;
      case NotificationType.paymentSuccess:
        return Icons.payment;
      case NotificationType.paymentFailed:
        return Icons.error_outline;
      case NotificationType.refund:
        return Icons.account_balance_wallet;
      case NotificationType.review:
        return Icons.star;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.reward:
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          color: _getNotificationColor(),
          border: Border(
            bottom: BorderSide(color: AppColor.placeholder, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    _notification.isRead
                        ? AppColor.placeholder
                        : AppColor.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(),
                color: _notification.isRead ? Colors.grey : AppColor.orange,
                size: 20,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _notification.title,
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight:
                          _notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _notification.message,
                    style: TextStyle(color: AppColor.secondary, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    _notification.getTimeAgo(),
                    style: TextStyle(color: AppColor.placeholder, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!_notification.isRead)
              CircleAvatar(backgroundColor: AppColor.orange, radius: 5),
          ],
        ),
      ),
    );
  }
}
