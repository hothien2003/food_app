import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_ordering_app/configs/DevHttpsOveride.dart';
import 'package:food_ordering_app/pages/Admin/QL_MonAn/ql_mon_an_page.dart';
import 'package:food_ordering_app/pages/Admin/QL_NhaHang/ql_nha_hang_page.dart';
import 'package:food_ordering_app/pages/Admin/QL_TaiKhoan/ql_tai_khoan_page.dart';
import 'package:food_ordering_app/pages/Admin/admin_page.dart';
import 'package:food_ordering_app/pages/MonAn/monan_page.dart';
import 'package:food_ordering_app/pages/GioHang/giohang_page.dart';
import 'package:food_ordering_app/pages/NguoiDung/nguoidung_page.dart';
import 'package:food_ordering_app/pages/NhaHang/nhahang_page.dart';
import 'package:food_ordering_app/pages/DonHang/donhang_page.dart';
import 'package:food_ordering_app/pages/profile/profile_page.dart';
import 'package:food_ordering_app/screens/changeAddressScreen.dart';
import 'package:food_ordering_app/pages/Chat/chatbot_ai_page.dart';

import './screens/spashScreen.dart';
import 'package:food_ordering_app/pages/Welcome/Welcome_Page.dart';
import 'package:food_ordering_app/pages/Login_Signup/login.dart';
import 'package:food_ordering_app/pages/Login_Signup/signup_page.dart';
import './screens/forgetPwScreen.dart';
import './screens/sentOTPScreen.dart';
import './screens/newPwScreen.dart';
import './screens/introScreen.dart';
import './screens/homeScreen.dart';
import './screens/menuScreen.dart';
import './screens/moreScreen.dart';
import './screens/offerScreen.dart';
import './screens/profileScreen.dart';
import './screens/dessertScreen.dart';
import './screens/individualItem.dart';
import './screens/paymentScreen.dart';
import './screens/notificationScreen.dart';
import './screens/aboutScreen.dart';
import './screens/inboxScreen.dart';
import './screens/myOrderScreen.dart';
import './screens/checkoutScreen.dart';
import './const/colors.dart';

void main() {
  HttpOverrides.global = DevHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "Metropolis",
        primarySwatch: Colors.red,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppColor.orange),
            shape: WidgetStateProperty.all(StadiumBorder()),
            elevation: WidgetStateProperty.all(0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(AppColor.orange),
          ),
        ),
        textTheme: TextTheme(
          displaySmall: TextStyle(
            color: AppColor.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: TextStyle(
            color: AppColor.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          headlineMedium: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.normal,
            fontSize: 25,
          ),
          headlineSmall: TextStyle(color: AppColor.primary, fontSize: 25),
          bodyMedium: TextStyle(color: AppColor.secondary),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        WelcomePage.routeName: (context) => WelcomePage(),
        Login.routeName: (context) => Login(),
        SignUpPage.routeName: (context) => SignUpPage(),
        ForgetPwScreen.routeName: (context) => ForgetPwScreen(),
        SendOTPScreen.routeName: (context) => SendOTPScreen(),
        NewPwScreen.routeName: (context) => NewPwScreen(),
        IntroScreen.routeName: (context) => IntroScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        MenuScreen.routeName: (context) => MenuScreen(),
        OfferScreen.routeName: (context) => OfferScreen(),
        ProfileScreen.routeName: (context) => ProfileScreen(),
        MoreScreen.routeName: (context) => MoreScreen(),
        DessertScreen.routeName: (context) => DessertScreen(),
        IndividualItem.routeName: (context) => IndividualItem(),
        PaymentScreen.routeName: (context) => PaymentScreen(),
        NotificationScreen.routeName: (context) => NotificationScreen(),
        AboutScreen.routeName: (context) => AboutScreen(),
        InboxScreen.routeName: (context) => InboxScreen(),
        MyOrderScreen.routeName: (context) => MyOrderScreen(),
        CheckoutScreen.routeName: (context) => CheckoutScreen(),
        ChangeAddressScreen.routeName: (context) => ChangeAddressScreen(),
        NguoiDungPage.routeName: (context) => NguoiDungPage(),
        NhaHangPage.routeName: (context) => NhaHangPage(),
        MonAnPage.routeName: (context) => MonAnPage(),
        GioHangPage.routeName: (context) => GioHangPage(),
        DonHangPage.routeName: (context) => DonHangPage(),
        ProfilePage.routeName: (context) => ProfilePage(),
        ChatbotAIPage.routeName: (context) => ChatbotAIPage(),
        AdminPage.routeName: (context) => AdminPage(),
        QLTaiKhoanPage.routeName: (context) => QLTaiKhoanPage(),
        QLNhaHangPage.routeName: (context) => QLNhaHangPage(),
        QLMonAnPage.routeName: (context) => QLMonAnPage(),
      },
    );
  }
}
