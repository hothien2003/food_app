import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = "/aboutScreen";

  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Header row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                      ),
                      Expanded(
                        child: Text(
                          "Về chúng tôi",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Image.asset(
                        Helper.getAssetName("cart.png", "virtual"),
                        height: 24,
                        width: 24,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Scrollable content
                  Expanded(
                    child: ListView.separated(
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) => const AboutCard(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom navbar
          const Positioned(
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

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 5, backgroundColor: AppColor.orange),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "Thienmeal kết nối người dùng với hàng nghìn nhà hàng chất lượng, đảm bảo giao hàng nhanh chóng và minh bạch chi phí. "
            "Chúng tôi liên tục mở rộng mạng lưới đối tác, tối ưu trải nghiệm đặt món và chăm sóc khách hàng 24/7.",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColor.primary),
          ),
        ),
      ],
    );
  }
}
