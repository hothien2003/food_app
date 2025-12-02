import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/screens/checkoutScreen.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';

class MyOrderScreen extends StatelessWidget {
  static const routeName = "/myOrderScreen";

  const MyOrderScreen({super.key});
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.arrow_back_ios_rounded),
                      ),
                      Expanded(
                        child: Text(
                          "Đơn hàng của tôi",
                          style: Helper.getTheme(context).headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      height: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: Image.asset(
                                Helper.getAssetName("hamburger.jpg", "real"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                "King Burgers",
                                style: Helper.getTheme(context).displaySmall,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    Helper.getAssetName(
                                      "star_filled.png",
                                      "virtual",
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "4.9",
                                    style: TextStyle(color: AppColor.orange),
                                  ),
                                  Text(" (124 đánh giá)"),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Burger"),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      ".",
                                      style: TextStyle(
                                        color: AppColor.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text("Ẩm thực Âu"),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 15,
                                    child: Image.asset(
                                      Helper.getAssetName("loc.png", "virtual"),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text("Số 03, đường 4, New York"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    color: AppColor.placeholderBg,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          BurgerCard(price: "160.000 đ", name: "Burger bò"),
                          BurgerCard(
                            price: "140.000 đ",
                            name: "Burger cổ điển",
                          ),
                          BurgerCard(
                            price: "170.000 đ",
                            name: "Burger gà phô mai",
                          ),
                          BurgerCard(price: "150.000 đ", name: "Gà giòn sốt"),
                          BurgerCard(
                            price: "60.000 đ",
                            name: "Khoai tây chiên lớn",
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColor.placeholder.withOpacity(0.25),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Hướng dẫn giao hàng",
                                  style: Helper.getTheme(context).displaySmall,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Row(
                                  children: [
                                    Icon(Icons.add, color: AppColor.orange),
                                    Text(
                                      "Thêm ghi chú",
                                      style: TextStyle(color: AppColor.orange),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Tạm tính",
                                style: Helper.getTheme(context).displaySmall,
                              ),
                            ),
                            Text(
                              "680.000 đ",
                              style: Helper.getTheme(
                                context,
                              ).displaySmall!.copyWith(color: AppColor.orange),
                            ),
                          ],
                        ),  
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Phí giao hàng",
                                style: Helper.getTheme(context).displaySmall,
                              ),
                            ),
                            Text(
                              "20.000 đ",
                              style: Helper.getTheme(
                                context,
                              ).displaySmall!.copyWith(color: AppColor.orange),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(
                          color: AppColor.placeholder.withOpacity(0.25),
                          thickness: 1.5,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Tổng cộng",
                                style: Helper.getTheme(context).displaySmall,
                              ),
                            ),
                            Text(
                              "700.000 đ",
                              style: Helper.getTheme(
                                context,
                              ).displaySmall!.copyWith(
                                color: AppColor.orange,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamed(CheckoutScreen.routeName);
                            },
                            child: Text("Thanh toán"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: CustomNavBar()),
        ],
      ),
    );
  }
}

class BurgerCard extends StatelessWidget {
  const BurgerCard({
    super.key,
    required String name,
    required String price,
    bool isLast = false,
  }) : _name = name,
       _price = price,
       _isLast = isLast;

  final String _name;
  final String _price;
  final bool _isLast;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom:
              _isLast
                  ? BorderSide.none
                  : BorderSide(color: AppColor.placeholder.withOpacity(0.25)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$_name x1",
              style: TextStyle(color: AppColor.primary, fontSize: 16),
            ),
          ),
          Text(
            _price,
            style: TextStyle(
              color: AppColor.primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
