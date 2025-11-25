import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';

class InboxScreen extends StatelessWidget {
  static const routeName = "/inboxScreen";

  const InboxScreen({super.key});
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
                            "Hộp thư",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                        ),
                        Image.asset(Helper.getAssetName("cart.png", "virtual")),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  MailCard(
                    title: "Ưu đãi Thienmeal",
                    description:
                        "Nhận ngay mã giảm 30% cho đơn hàng đầu tiên trong tuần này.",
                    time: "6 Tháng 7",
                  ),
                  MailCard(
                    title: "Ưu đãi Thienmeal",
                    description:
                        "Freeship cho đơn từ 200.000 đ tại mọi quận nội thành.",
                    time: "6 Tháng 7",
                    color: AppColor.placeholderBg,
                  ),
                  MailCard(
                    title: "Ưu đãi Thienmeal",
                    description:
                        "Nhà hàng mới vừa mở bán, đặt bàn ngay để nhận quà tặng.",
                    time: "6 Tháng 7",
                  ),
                  MailCard(
                    title: "Ưu đãi Thienmeal",
                    description:
                        "Tích lũy thêm 50 điểm thưởng khi thanh toán qua ví điện tử.",
                    time: "6 Tháng 7",
                    color: AppColor.placeholderBg,
                  ),
                  MailCard(
                    title: "Ưu đãi Thienmeal",
                    description:
                        "Combo trưa chỉ 69.000 đ áp dụng trong khung giờ 11h-14h.",
                    time: "6 Tháng 7",
                  ),
                  MailCard(
                    title: "Ưu đãi Thienmeal",
                    description:
                        "Giới thiệu bạn bè để nhận thêm 2 mã giảm giá độc quyền.",
                    time: "6 Tháng 7",
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

class MailCard extends StatelessWidget {
  const MailCard({
    super.key,
    required String time,
    required String title,
    required String description,
    Color color = Colors.white,
  }) : _time = time,
       _title = title,
       _description = description,
       _color = color;

  final String _time;
  final String _title;
  final String _description;
  final Color _color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 80),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title, style: TextStyle(color: AppColor.primary)),
                SizedBox(height: 5),
                Text(_description),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_time, style: TextStyle(fontSize: 10)),
              Image.asset(Helper.getAssetName("star.png", "virtual")),
            ],
          ),
        ],
      ),
    );
  }
}
