import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/screens/aboutScreen.dart';
import 'package:food_ordering_app/screens/inboxScreen.dart';
import 'package:food_ordering_app/pages/DonHang/donhang_page.dart';
import 'package:food_ordering_app/screens/notificationScreen.dart';
import 'package:food_ordering_app/screens/paymentScreen.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';
import 'package:food_ordering_app/services/notification_service.dart';

class MoreScreen extends StatefulWidget {
  static const routeName = "/moreScreen";

  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final NotificationService _notificationService = NotificationService.instance;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    await _notificationService.init();
    setState(() {
      _unreadCount = _notificationService.getUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Container(
              height: Helper.getScreenHeight(context),
              width: Helper.getScreenWidth(context),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Khác",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Image.asset(Helper.getAssetName("cart.png", "virtual")),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MoreCard(
                      image: Image.asset(
                        Helper.getAssetName("income.png", "virtual"),
                      ),
                      name: "Thông tin thanh toán",
                      handler: () {
                        Navigator.of(
                          context,
                        ).pushNamed(PaymentScreen.routeName);
                      },
                    ),
                    const SizedBox(height: 10),
                    MoreCard(
                      image: Image.asset(
                        Helper.getAssetName("shopping_bag.png", "virtual"),
                      ),
                      name: "Đơn hàng của tôi",
                      handler: () {
                        Navigator.of(context).pushNamed(DonHangPage.routeName);
                      },
                    ),
                    const SizedBox(height: 10),
                    MoreCard(
                      image: Image.asset(
                        Helper.getAssetName("noti.png", "virtual"),
                      ),
                      name: "Thông báo",
                      isNoti: true,
                      unreadCount: _unreadCount,
                      handler: () async {
                        await Navigator.of(
                          context,
                        ).pushNamed(NotificationScreen.routeName);
                        // Cập nhật lại số thông báo chưa đọc sau khi quay lại
                        _loadUnreadCount();
                      },
                    ),
                    const SizedBox(height: 10),
                    MoreCard(
                      image: Image.asset(
                        Helper.getAssetName("mail.png", "virtual"),
                      ),
                      name: "Hộp thư",
                      handler: () {
                        Navigator.of(context).pushNamed(InboxScreen.routeName);
                      },
                    ),
                    const SizedBox(height: 10),
                    MoreCard(
                      image: Image.asset(
                        Helper.getAssetName("info.png", "virtual"),
                      ),
                      name: "Về chúng tôi",
                      handler: () {
                        Navigator.of(context).pushNamed(AboutScreen.routeName);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomNavBar(more: true),
          ),
        ],
      ),
    );
  }
}

class MoreCard extends StatelessWidget {
  const MoreCard({
    super.key,
    required String name,
    required Image image,
    bool isNoti = false,
    int unreadCount = 0,
    required VoidCallback handler,
  }) : _name = name,
       _image = image,
       _isNoti = isNoti,
       _unreadCount = unreadCount,
       _handler = handler;

  final String _name;
  final Image _image;
  final bool _isNoti;
  final int _unreadCount;
  final VoidCallback _handler;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handler,
      child: SizedBox(
        height: 70,
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: AppColor.placeholderBg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const ShapeDecoration(
                      shape: CircleBorder(),
                      color: AppColor.placeholder,
                    ),
                    child: _image,
                  ),
                  const SizedBox(width: 10),
                  Text(_name, style: const TextStyle(color: AppColor.primary)),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 30,
                width: 30,
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  color: AppColor.placeholderBg,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColor.secondary,
                  size: 17,
                ),
              ),
            ),
            if (_isNoti && _unreadCount > 0)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 20,
                  width: 20,
                  margin: const EdgeInsets.only(right: 50),
                  decoration: const ShapeDecoration(
                    shape: CircleBorder(),
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Text(
                      _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
