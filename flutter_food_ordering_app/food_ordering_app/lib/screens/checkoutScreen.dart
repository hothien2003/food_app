import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/screens/changeAddressScreen.dart';
import 'package:food_ordering_app/screens/homeScreen.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';
import 'package:food_ordering_app/widgets/customTextInput.dart';

class CheckoutScreen extends StatelessWidget {
  static const routeName = "/checkoutScreen";

  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        "Đặt hàng",
                        style: Helper.getTheme(context).headlineMedium,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Địa chỉ giao hàng"),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: Helper.getScreenWidth(context) * 0.4,
                        child: Text(
                          "653 Nostrand Ave., Brooklyn, NY 11216",
                          style: Helper.getTheme(context).displaySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(ChangeAddressScreen.routeName);
                        },
                        child: Text(
                          "Thay đổi",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 10,
                  width: double.infinity,
                  color: AppColor.placeholderBg,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Phương thức thanh toán"),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            isScrollControlled: true,
                            isDismissible: false,
                            context: context,
                            builder: (context) {
                              return SizedBox(
                                height: Helper.getScreenHeight(context) * 0.7,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          icon: Icon(Icons.clear),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Thêm thẻ tín dụng/ghi nợ",
                                            style:
                                                Helper.getTheme(
                                                  context,
                                                ).displaySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: Divider(
                                        color: AppColor.placeholder.withOpacity(
                                          0.5,
                                        ),
                                        thickness: 1.5,
                                        height: 40,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: CustomTextInput(
                                        hintText: "Số thẻ",
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Hạn sử dụng"),
                                          SizedBox(
                                            height: 50,
                                            width: 100,
                                            child: CustomTextInput(
                                              hintText: "MM",
                                              padding: const EdgeInsets.only(
                                                left: 35,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 50,
                                            width: 100,
                                            child: CustomTextInput(
                                              hintText: "YY",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: CustomTextInput(
                                        hintText: "Mã bảo mật",
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: CustomTextInput(hintText: "Tên"),
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: CustomTextInput(hintText: "Họ"),
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width:
                                                Helper.getScreenWidth(context) *
                                                0.4,
                                            child: Text(
                                              "Bạn có thể xóa thẻ này bất cứ lúc nào",
                                            ),
                                          ),
                                          Switch(
                                            value: false,
                                            onChanged: (_) {},
                                            thumbColor: WidgetStateProperty.all(
                                              AppColor.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.add),
                                              SizedBox(width: 40),
                                              Text("Thêm thẻ"),
                                              SizedBox(width: 40),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            Text(
                              "Thêm thẻ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                PaymentCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tiền mặt khi nhận hàng"),
                      Container(
                        width: 15,
                        height: 15,
                        decoration: ShapeDecoration(
                          shape: CircleBorder(
                            side: BorderSide(color: AppColor.orange),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                PaymentCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Image.asset(
                              Helper.getAssetName("visa2.png", "real"),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text("**** **** **** 2187"),
                        ],
                      ),
                      Container(
                        width: 15,
                        height: 15,
                        decoration: ShapeDecoration(
                          shape: CircleBorder(
                            side: BorderSide(color: AppColor.orange),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                PaymentCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 30,
                            child: Image.asset(
                              Helper.getAssetName("paypal.png", "real"),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text("johndoe@email.com"),
                        ],
                      ),
                      Container(
                        width: 15,
                        height: 15,
                        decoration: ShapeDecoration(
                          shape: CircleBorder(
                            side: BorderSide(color: AppColor.orange),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 10,
                  width: double.infinity,
                  color: AppColor.placeholderBg,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tạm tính"),
                          Text(
                            "680.000 đ",
                            style: Helper.getTheme(context).displaySmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Phí giao hàng"),
                          Text(
                            "20.000 đ",
                            style: Helper.getTheme(context).displaySmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Giảm giá"),
                          Text(
                            "-40.000 đ",
                            style: Helper.getTheme(context).displaySmall,
                          ),
                        ],
                      ),
                      Divider(
                        height: 40,
                        color: AppColor.placeholder.withOpacity(0.25),
                        thickness: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tổng cộng"),
                          Text(
                            "660.000 đ",
                            style: Helper.getTheme(context).displaySmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Container(
                  height: 10,
                  width: double.infinity,
                  color: AppColor.placeholderBg,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          isScrollControlled: true,
                          isDismissible: false,
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height: Helper.getScreenHeight(context) * 0.7,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.clear),
                                      ),
                                    ],
                                  ),
                                  Image.asset(
                                    Helper.getAssetName(
                                      "vector4.png",
                                      "virtual",
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Cảm ơn bạn!",
                                    style: TextStyle(
                                      color: AppColor.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 30,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "vì đã đặt hàng",
                                    style: Helper.getTheme(context)
                                        .headlineLarge!
                                        .copyWith(color: AppColor.primary),
                                  ),

                                  SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                    child: Text(
                                      "Đơn hàng của bạn đang được xử lý. Chúng tôi sẽ thông báo khi tài xế nhận món. Bạn có thể theo dõi trạng thái đơn ngay bây giờ.",
                                    ),
                                  ),
                                  SizedBox(height: 60),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        child: Text("Theo dõi đơn hàng"),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pushReplacementNamed(
                                          HomeScreen.routeName,
                                        );
                                      },
                                      child: Text(
                                        "Về trang chủ",
                                        style: TextStyle(
                                          color: AppColor.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text("Gửi đơn hàng"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: CustomNavBar()),
        ],
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 30, right: 20),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: AppColor.placeholder.withOpacity(0.25)),
          ),
          color: AppColor.placeholderBg,
        ),
        child: child,
      ),
    );
  }
}
