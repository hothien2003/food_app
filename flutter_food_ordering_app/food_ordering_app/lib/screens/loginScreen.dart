import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/forgetPwScreen.dart';

import '../const/colors.dart';
import '../screens/signUpScreen.dart';
import '../utils/helper.dart';
import '../widgets/customTextInput.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = "/loginScreen";

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: Helper.getScreenHeight(context),
        width: Helper.getScreenWidth(context),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              children: [
                Text("Đăng nhập", style: Helper.getTheme(context).headlineSmall),
                Spacer(),
                Text('Nhập thông tin để đăng nhập'),
                Spacer(),
                CustomTextInput(hintText: "Email của bạn"),
                Spacer(),
                CustomTextInput(hintText: "Mật khẩu"),
                Spacer(),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child:
                      ElevatedButton(onPressed: () {}, child: Text("Đăng nhập")),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(ForgetPwScreen.routeName);
                  },
                  child: Text("Bạn quên mật khẩu?"),
                ),
                Spacer(flex: 2),
                Text("hoặc đăng nhập với"),
                Spacer(),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Color(0xFF367FC0),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(Helper.getAssetName("fb.png", "virtual")),
                        SizedBox(width: 30),
                        Text("Đăng nhập với Facebook"),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Color(0xFFDD4B39),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          Helper.getAssetName("google.png", "virtual"),
                        ),
                        SizedBox(width: 30),
                        Text("Đăng nhập với Google"),
                      ],
                    ),
                  ),
                ),
                Spacer(flex: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(SignUpPage.routeName);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Chưa có tài khoản?"),
                      Text(
                        "Đăng ký",
                        style: TextStyle(
                          color: AppColor.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
