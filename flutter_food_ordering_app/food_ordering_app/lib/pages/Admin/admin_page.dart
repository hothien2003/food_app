import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/pages/Admin/QL_MonAn/ql_mon_an_page.dart';
import 'package:food_ordering_app/pages/Admin/QL_NhaHang/ql_nha_hang_page.dart';
import 'package:food_ordering_app/pages/Admin/QL_TaiKhoan/ql_tai_khoan_page.dart';
import 'package:food_ordering_app/screens/aboutScreen.dart';
import 'package:food_ordering_app/screens/myOrderScreen.dart';
import 'package:food_ordering_app/utils/helper.dart';

class AdminPage extends StatelessWidget {
  static const routeName = "/AdminPage";

  const AdminPage({super.key});

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
                          "Admin",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Image.asset(Helper.getAssetName("cart.png", "virtual")),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MoreCard(
                      image: Image.asset(
                        Helper.getAssetName("icon_qlaccount.png", "virtual"),
                      ),
                      name: "Quản lý tài khoản",
                      handler: () {
                        Navigator.of(
                          context,
                        ).pushNamed(QLTaiKhoanPage.routeName);
                      },
                    ),
                    const SizedBox(height: 10),
                    MoreCard(
                      image: Image.asset(
                        Helper.getAssetName("icon_qlorder.png", "virtual"),
                      ),
                      name: "Quản lý đơn hàng",
                      handler: () {
                        Navigator.of(
                          context,
                        ).pushNamed(MyOrderScreen.routeName);
                      },
                    ),
                    const SizedBox(height: 10),
                    MoreCard(
                      image: Image.asset(
                        Helper.getAssetName("icon_qlrestaurant.png", "virtual"),
                      ),
                      name: "Quản lý nhà hàng",
                      isNoti: true,
                      handler: () {
                        Navigator.of(
                          context,
                        ).pushNamed(QLNhaHangPage.routeName);
                      },
                    ),
                    const SizedBox(height: 10),
                    MoreCard(
                      image: Image.asset(
                        Helper.getAssetName("icon_qlfood.png", "virtual"),
                      ),
                      name: "Quản lý món ăn",
                      handler: () {
                        Navigator.of(context).pushNamed(QLMonAnPage.routeName);
                      },
                    ),
                    const SizedBox(height: 10),
                    MoreCard(
                      image: Image.asset(
                        Helper.getAssetName("info.png", "virtual"),
                      ),
                      name: "",
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
    required VoidCallback handler,
  }) : _name = name,
       _image = image,
       _isNoti = isNoti,
       _handler = handler;

  final String _name;
  final Image _image;
  final bool _isNoti;
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
            if (_isNoti)
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
                  child: const Center(
                    child: Text(
                      "15",
                      style: TextStyle(color: Colors.white, fontSize: 12),
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
