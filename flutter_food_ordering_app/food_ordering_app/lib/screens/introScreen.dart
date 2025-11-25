import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/screens/homeScreen.dart';
import 'package:food_ordering_app/utils/helper.dart';

class IntroScreen extends StatefulWidget {
  static const routeName = "/introScreen";

  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final PageController _controller;
  int count = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "vector1.png",
      "title": "Tìm món bạn yêu thích",
      "desc":
          "Khám phá hơn 1.000 nhà hàng cùng dịch vụ giao nhanh tận cửa.",
    },
    {
      "image": "vector2.png",
      "title": "Giao hàng nhanh",
      "desc": "Giao món đến nhà hoặc văn phòng dù bạn ở đâu.",
    },
    {
      "image": "vector3.png",
      "title": "Theo dõi trực tiếp",
      "desc":
          "Theo dõi hành trình món ăn ngay trên ứng dụng sau khi đặt.",
    },
  ];

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      body: SizedBox(
        width: Helper.getScreenWidth(context),
        height: Helper.getScreenHeight(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Spacer(),
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (value) {
                      setState(() {
                        count = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.asset(
                        Helper.getAssetName(_pages[index]["image"]!, "virtual"),
                      );
                    },
                    itemCount: _pages.length,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor:
                            count == index
                                ? AppColor.orange
                                : AppColor.placeholder,
                      ),
                    );
                  }),
                ),
                const Spacer(),
                Text(
                  _pages[count]["title"]!,
                  style: theme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _pages[count]["desc"]!,
                  textAlign: TextAlign.center,
                  style: theme.bodyMedium,
                ),
                const Spacer(),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(HomeScreen.routeName);
                    },
                    child: const Text("Tiếp tục"),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
