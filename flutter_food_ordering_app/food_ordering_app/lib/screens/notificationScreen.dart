import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';

class NotificationScreen extends StatelessWidget {
  static const routeName = "/notiScreen";

  const NotificationScreen({super.key});
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
                        Image.asset(Helper.getAssetName("cart.png", "virtual")),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  NotiCard(
                    title: "Đơn hàng của bạn đã được lấy",
                    time: "Vừa xong",
                  ),
                  NotiCard(
                    title: "Đơn hàng của bạn đã được giao",
                    time: "1 giờ trước",
                    color: AppColor.placeholderBg,
                  ),
                  NotiCard(
                    title: "Tài xế đang chờ bạn ở sảnh",
                    time: "3 giờ trước",
                  ),
                  NotiCard(
                    title: "Mã giảm giá mới vừa được thêm",
                    time: "5 giờ trước",
                  ),
                  NotiCard(
                    title: "Bạn đã đánh giá nhà hàng LaVilla",
                    time: "05 Thg 9 2020",
                    color: AppColor.placeholderBg,
                  ),
                  NotiCard(
                    title: "Điểm thưởng tháng 8 đã được cộng",
                    time: "12 Thg 8 2020",
                    color: AppColor.placeholderBg,
                  ),
                  NotiCard(
                    title: "Đã hoàn tiền đơn #FD1245",
                    time: "20 Thg 7 2020",
                  ),
                  NotiCard(
                    title: "Cập nhật chính sách giao hàng",
                    time: "12 Thg 7 2020",
                  ),
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
    required String time,
    required String title,
    Color color = Colors.white,
  }) : _time = time,
       _title = title,
       _color = color;

  final String _time;
  final String _title;
  final Color _color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        color: _color,
        border: Border(
          bottom: BorderSide(color: AppColor.placeholder, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: AppColor.orange, radius: 5),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_title, style: TextStyle(color: AppColor.primary)),
              Text(_time),
            ],
          ),
        ],
      ),
    );
  }
}
