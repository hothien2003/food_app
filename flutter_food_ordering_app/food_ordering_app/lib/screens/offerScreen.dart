import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';

class OfferScreen extends StatelessWidget {
  static const routeName = "/offerScreen";

  const OfferScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SizedBox(
              height: Helper.getScreenHeight(context),
              width: Helper.getScreenWidth(context),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ưu đãi mới nhất",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                          Image.asset(
                            Helper.getAssetName("cart.png", "virtual"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [Text("Tìm kiếm giảm giá, ưu đãi đặc biệt")],
                      ),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 30,
                            width: Helper.getScreenWidth(context) * 0.4,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text("Xem ưu đãi"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    OfferCard(
                      image: Image.asset(
                        Helper.getAssetName("breakfast.jpg", "real"),
                        fit: BoxFit.cover,
                      ),
                      name: "Cafe de Noires",
                    ),
                    OfferCard(
                      image: Image.asset(
                        Helper.getAssetName("western2.jpg", "real"),
                        fit: BoxFit.cover,
                      ),
                      name: "Isso",
                    ),
                    OfferCard(
                      image: Image.asset(
                        Helper.getAssetName("coffee3.jpg", "real"),
                        fit: BoxFit.cover,
                      ),
                      name: "Cafe Beans",
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomNavBar(offer: true),
          ),
        ],
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required String name, required Image image})
    : _image = image,
      _name = name;

  final String _name;
  final Image _image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(height: 200, width: double.infinity, child: _image),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Text(
                  _name,
                  style: Helper.getTheme(
                    context,
                  ).headlineLarge!.copyWith(color: AppColor.primary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Image.asset(Helper.getAssetName("star_filled.png", "virtual")),
                SizedBox(width: 5),
                Text("4.9", style: TextStyle(color: AppColor.orange)),
                SizedBox(width: 5),
                Text("(124 đánh giá) Cà phê"),
                SizedBox(width: 5),
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
                Text(" Ẩm thực Âu"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
