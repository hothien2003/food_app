import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';
import 'package:food_ordering_app/widgets/customTextInput.dart';

class PaymentScreen extends StatelessWidget {
  static const routeName = "/paymentScreen";

  const PaymentScreen({super.key});
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                        Expanded(
                          child: Text(
                            "Thông tin thanh toán",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                        ),
                        Image.asset(Helper.getAssetName("cart.png", "virtual")),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Text(
                          "Tùy chỉnh phương thức thanh toán",
                          style: Helper.getTheme(context).displaySmall,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(
                      color: AppColor.placeholder,
                      thickness: 1.5,
                      height: 30,
                    ),
                  ),
                  Container(
                    width: Helper.getScreenWidth(context),
                    constraints: BoxConstraints(minHeight: 190),
                    decoration: BoxDecoration(
                      color: AppColor.placeholderBg,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.placeholder.withOpacity(0.5),
                          offset: Offset(0, 20),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tiền mặt/thẻ khi nhận hàng",
                                style: TextStyle(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.check, color: AppColor.orange),
                            ],
                          ),
                          Divider(
                            color: AppColor.placeholder,
                            thickness: 1,
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 40,
                                child: Image.asset(
                                  Helper.getAssetName("visa.png", "real"),
                                ),
                              ),
                              Text("**** ****"),
                              Text("2187"),
                              OutlinedButton(
                                style: ButtonStyle(
                                  side: WidgetStateProperty.all(
                                    BorderSide(color: AppColor.orange),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    StadiumBorder(),
                                  ),
                                  foregroundColor: WidgetStateProperty.all(
                                    AppColor.orange,
                                  ),
                                ),
                                onPressed: () {},
                                child: Text("Xóa thẻ"),
                              ),
                            ],
                          ),
                          Divider(
                            color: AppColor.placeholder,
                            thickness: 1,
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                "Phương thức khác",
                                style: TextStyle(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    height: 50,
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
                                    child: CustomTextInput(hintText: "Số thẻ"),
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
                                        Text("Cho phép xóa thẻ này"),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          Text("Thêm thẻ tín dụng/ghi nợ khác"),
                        ],
                      ),
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
