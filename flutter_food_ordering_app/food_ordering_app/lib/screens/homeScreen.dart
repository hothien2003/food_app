import 'package:flutter/material.dart';

import '../const/colors.dart';
import '../utils/helper.dart';
import '../widgets/customNavBar.dart';
import '../screens/individualItem.dart';
import 'package:food_ordering_app/widgets/searchBar.dart' as Custom;
import 'package:food_ordering_app/pages/Chat/chatbot_ai_page.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = "/homeScreen";

  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "Xin chào !!!",
                              style: Helper.getTheme(context).headlineMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed(ChatbotAIPage.routeName);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.orange,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.chat,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          "AI Trợ lý",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset(
                                  Helper.getAssetName("cart.png", "virtual"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Giao đến"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButtonHideUnderline(
                        child: SizedBox(
                          width: 250,
                          child: DropdownButton(
                            value: "vi_tri_hien_tai",
                            items: [
                              DropdownMenuItem(
                                value: "vi_tri_hien_tai",
                                child: Text("Vị trí hiện tại"),
                              ),
                            ],
                            icon: SizedBox(
                              width: 24,
                              height: 24,
                              child: Image.asset(
                                Helper.getAssetName(
                                  "dropdown_filled.png",
                                  "virtual",
                                ),
                              ),
                            ),
                            style: Helper.getTheme(context).headlineLarge,
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Custom.SearchBar(title: "Tìm món ăn"),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            CategoryCard(
                              image: Image.asset(
                                Helper.getAssetName("hamburger2.jpg", "real"),
                                fit: BoxFit.cover,
                              ),
                              name: "Khuyến mãi",
                            ),
                            SizedBox(width: 10),
                            CategoryCard(
                              image: Image.asset(
                                Helper.getAssetName("rice2.jpg", "real"),
                                fit: BoxFit.cover,
                              ),
                              name: "Món Sri Lanka",
                            ),
                            SizedBox(width: 10),
                            CategoryCard(
                              image: Image.asset(
                                Helper.getAssetName("fruit.jpg", "real"),
                                fit: BoxFit.cover,
                              ),
                              name: "Món Ý",
                            ),
                            SizedBox(width: 10),
                            CategoryCard(
                              image: Image.asset(
                                Helper.getAssetName("rice.jpg", "real"),
                                fit: BoxFit.cover,
                              ),
                              name: "Món Ấn Độ",
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nhà hàng nổi bật",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("Xem tất cả"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    RestaurantCard(
                      image: Image.asset(
                        Helper.getAssetName("pizza2.jpg", "real"),
                        fit: BoxFit.cover,
                      ),
                      name: "Quán Tuk Tuk",
                    ),
                    RestaurantCard(
                      image: Image.asset(
                        Helper.getAssetName("breakfast.jpg", "real"),
                        fit: BoxFit.cover,
                      ),
                      name: "Cà phê de Noir",
                    ),
                    RestaurantCard(
                      image: Image.asset(
                        Helper.getAssetName("bakery.jpg", "real"),
                        fit: BoxFit.cover,
                      ),
                      name: "Bánh ngọt Tella",
                    ),
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Phổ biến nhất",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("Xem tất cả"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 270,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            MostPopularCard(
                              image: Image.asset(
                                Helper.getAssetName("pizza4.jpg", "real"),
                                fit: BoxFit.cover,
                              ),
                              name: "Cafe De Bambaa",
                            ),
                            SizedBox(width: 30),
                            MostPopularCard(
                              name: "Burger của Bella",
                              image: Image.asset(
                                Helper.getAssetName("dessert3.jpg", "real"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Món vừa xem",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("Xem tất cả"),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed(IndividualItem.routeName);
                            },
                            child: RecentItemCard(
                              image: Image.asset(
                                Helper.getAssetName("pizza3.jpg", "real"),
                                fit: BoxFit.cover,
                              ),
                              name: "Pizza Mulberry của Josh",
                            ),
                          ),
                          RecentItemCard(
                            image: Image.asset(
                              Helper.getAssetName("coffee.jpg", "real"),
                              fit: BoxFit.cover,
                            ),
                            name: "Barita",
                          ),
                          RecentItemCard(
                            image: Image.asset(
                              Helper.getAssetName("pizza.jpg", "real"),
                              fit: BoxFit.cover,
                            ),
                            name: "Pizza Rush Hour",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                width: double.infinity,
                child: CustomNavBar(home: true),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColor.orange,
          child: Icon(Icons.smart_toy, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed(ChatbotAIPage.routeName);
          },
        ),
      );
    } catch (e) {
      // Nếu có lỗi khi build, hiển thị màn hình lỗi
      print('Lỗi khi build HomeScreen: $e');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Có lỗi xảy ra khi tải trang chủ',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                e.toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}

class RecentItemCard extends StatelessWidget {
  const RecentItemCard({super.key, required String name, required Image image})
    : _name = name,
      _image = image;

  final String _name;
  final Image _image;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: 80, height: 80, child: _image),
        ),
        SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: Helper.getTheme(
                    context,
                  ).headlineLarge!.copyWith(color: AppColor.primary),
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text("Cà phê", overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        ".",
                        style: TextStyle(
                          color: AppColor.orange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        "Ẩm thực Âu",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.asset(
                        Helper.getAssetName("star_filled.png", "virtual"),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text("4.9", style: TextStyle(color: AppColor.orange)),
                    SizedBox(width: 10),
                    Text('(124) đánh giá'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MostPopularCard extends StatelessWidget {
  const MostPopularCard({super.key, required String name, required Image image})
    : _name = name,
      _image = image;

  final String _name;
  final Image _image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(width: 300, height: 200, child: _image),
          ),
          SizedBox(height: 10),
          Text(
            _name,
            style: Helper.getTheme(
              context,
            ).headlineLarge!.copyWith(color: AppColor.primary),
          ),
          Row(
            children: [
              Flexible(child: Text("Cà phê", overflow: TextOverflow.ellipsis)),
              SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  ".",
                  style: TextStyle(
                    color: AppColor.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: 5),
              Flexible(
                child: Text("Ẩm thực Âu", overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(
                  Helper.getAssetName("star_filled.png", "virtual"),
                ),
              ),
              SizedBox(width: 5),
              Text("4.9", style: TextStyle(color: AppColor.orange)),
            ],
          ),
        ],
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required String name, required Image image})
    : _image = image,
      _name = name;

  final String _name;
  final Image _image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      width: double.infinity,
      child: Column(
        children: [
          ClipRRect(
            child: SizedBox(height: 200, width: double.infinity, child: _image),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(_name, style: Helper.getTheme(context).displaySmall),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.asset(
                        Helper.getAssetName("star_filled.png", "virtual"),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text("4.9", style: TextStyle(color: AppColor.orange)),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        "(124 đánh giá)",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text("Cà phê", overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        ".",
                        style: TextStyle(
                          color: AppColor.orange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        "Ẩm thực Âu",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required Image image, required String name})
    : _image = image,
      _name = name;

  final String _name;
  final Image _image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: 100, height: 100, child: _image),
        ),
        SizedBox(height: 5),
        Text(
          _name,
          style: Helper.getTheme(
            context,
          ).headlineLarge!.copyWith(color: AppColor.primary, fontSize: 16),
        ),
      ],
    );
  }
}
