import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_nguoidung.dart';
import 'package:food_ordering_app/models/NguoiDung.dart';
import 'package:food_ordering_app/screens/forgetPwScreen.dart';
import 'package:food_ordering_app/screens/signUpScreen.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/utils/notification_util.dart';
import 'package:food_ordering_app/utils/shared_preferences_helper.dart';
import 'package:food_ordering_app/widgets/customTextInput.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/screens/homeScreen.dart';
import 'package:food_ordering_app/pages/Admin/admin_page.dart';

class Login extends StatefulWidget {
  static const routeName = "/login";

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiNguoiDung _apiNguoiDung = ApiNguoiDung();

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      try {
        if (username == "Admin" && password == "123") {
          // Đăng nhập Admin
          if (!mounted) return;

          NotificationUtil.showSuccessMessage(context, 'Đăng nhập thành công!');

          // Delay ngắn để thông báo hiển thị
          await Future.delayed(Duration(milliseconds: 500));

          if (!mounted) return;

          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AdminPage.routeName, (route) => false);
          return;
        }

        final List<NguoiDung> users = await _apiNguoiDung.getNguoiDungData();

        // Kiểm tra nếu danh sách người dùng rỗng
        if (users.isEmpty) {
          throw Exception(
            'Không tìm thấy dữ liệu người dùng. Vui lòng kiểm tra kết nối server.',
          );
        }

        // Tìm người dùng khớp với tên đăng nhập và mật khẩu
        final NguoiDung matchedUser = users.firstWhere(
          (user) =>
              user.tenDangNhap.trim() == username &&
              user.matKhau.trim() == password,
          orElse: () => throw Exception("Tài khoản hoặc mật khẩu không đúng"),
        );

        // Kiểm tra nếu mã người dùng không hợp lệ
        if (matchedUser.maNguoiDung == 0) {
          throw Exception("Tài khoản hoặc mật khẩu không đúng");
        }

        // Lưu mã người dùng vào SharedPreferences
        await luuNguoiDungDangNhap(matchedUser.maNguoiDung);

        if (!mounted) return;

        // Hiển thị thông báo thành công
        NotificationUtil.showSuccessMessage(context, 'Đăng nhập thành công!');

        // Delay ngắn để thông báo hiển thị
        await Future.delayed(Duration(milliseconds: 500));

        if (!mounted) return;

        // Navigate đến HomeScreen
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
      } catch (e) {
        // Hiển thị thông báo lỗi chi tiết hơn
        String errorMessage = 'Đăng nhập thất bại! vui lòng kiểm tra lại';
        if (e.toString().contains('Không thể kết nối') ||
            e.toString().contains('kết nối đến server') ||
            e.toString().contains('Lỗi kết nối API')) {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        } else if (e.toString().contains('Tài khoản hoặc mật khẩu')) {
          errorMessage = 'Tài khoản hoặc mật khẩu không đúng';
        }

        print('Lỗi đăng nhập: $e'); // Log để debug

        NotificationUtil.showErrorMessage(context, errorMessage);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: Helper.getScreenHeight(context),
        width: Helper.getScreenWidth(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Đăng nhập",
                    style: Helper.getTheme(context).headlineSmall,
                  ),
                  const Spacer(),
                  const Text(''),
                  const Spacer(),
                  CustomTextInput(
                    hintText: "Tên đăng nhập",
                    controller: _usernameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Vui lòng nhập tên đăng nhập";
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  CustomTextInput(
                    hintText: "Mật khẩu",
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Vui lòng nhập mật khẩu";
                      }
                      return null;
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text("Đăng nhập"),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(ForgetPwScreen.routeName);
                    },
                    child: const Text("Bạn quên mật khẩu?"),
                  ),
                  const Spacer(flex: 2),
                  const Text("hoặc Đăng nhập với"),
                  const Spacer(),
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
                          const SizedBox(width: 30),
                          const Text("Đăng nhập với Facebook"),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
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
                          const SizedBox(width: 30),
                          const Text("Đăng nhập với Google"),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(SignUpPage.routeName);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Không có tài khoản?"),
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
      ),
    );
  }
}
