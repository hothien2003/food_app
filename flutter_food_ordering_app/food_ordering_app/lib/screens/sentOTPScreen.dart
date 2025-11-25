import 'package:flutter/material.dart';

import '../const/colors.dart';
import '../utils/helper.dart';
import './newPwScreen.dart';

class SendOTPScreen extends StatelessWidget {
  static const routeName = "/sendOTP";

  const SendOTPScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Chúng tôi đã gửi mã OTP đến điện thoại của bạn',
                style: Helper.getTheme(context).headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Vui lòng kiểm tra số điện thoại 071*****12 để tiếp tục đặt lại mật khẩu.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [OTPInput(), OTPInput(), OTPInput(), OTPInput()],
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(NewPwScreen.routeName);
                  },
                  child: Text("Tiếp tục"),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Không nhận được? "),
                  Text(
                    "Nhấn vào đây",
                    style: TextStyle(
                      color: AppColor.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OTPInput extends StatelessWidget {
  const OTPInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: ShapeDecoration(
        color: AppColor.placeholderBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18, left: 20),
            child: Text("*", style: TextStyle(fontSize: 45)),
          ),
          TextField(decoration: InputDecoration(border: InputBorder.none)),
        ],
      ),
    );
  }
}
