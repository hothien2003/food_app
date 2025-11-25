import 'package:flutter/material.dart';
import '../utils/helper.dart';
import '../widgets/customTextInput.dart';
import './introScreen.dart';

class NewPwScreen extends StatelessWidget {
  static const routeName = "/newPw";

  const NewPwScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: Helper.getScreenWidth(context),
        height: Helper.getScreenHeight(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Mật khẩu mới",
                  style: Helper.getTheme(context).headlineSmall,
                ),
                SizedBox(height: 20),
                Text(
                  "Vui lòng nhập email để nhận liên kết đặt lại mật khẩu.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                CustomTextInput(hintText: "Mật khẩu mới"),
                SizedBox(height: 20),
                CustomTextInput(hintText: "Xác nhận mật khẩu"),
                SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(IntroScreen.routeName);
                    },
                    child: Text("Tiếp tục"),
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
