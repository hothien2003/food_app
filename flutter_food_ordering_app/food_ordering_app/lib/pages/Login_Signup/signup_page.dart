import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

import 'package:food_ordering_app/api/api_nguoidung.dart';
import 'package:food_ordering_app/models/NguoiDung.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/pages/Login_Signup/login.dart';
import 'package:food_ordering_app/utils/helper.dart';
// ignore: unused_import
import 'package:food_ordering_app/widgets/customTextInput.dart';

class SignUpPage extends StatefulWidget {
  static const routeName = '/SignUpPage';

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiNguoiDung _api = ApiNguoiDung();

  Future<void> registerUser() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại thông tin')),
      );
      return;
    }

    final data = _formKey.currentState!.value;

    final newUser = NguoiDung(
      maNguoiDung: 0,
      tenDangNhap: data['tenDangNhap'],
      matKhau: data['matKhau'],
      hoTen: data['hoTen'],
      email: data['email'],
      soDienThoai: data['soDienThoai'],
      diaChi: data['diaChi'],
      ngayTao: data['ngayTao'],
    );

    try {
      final response = await _api.createNguoiDung(nguoiDung: newUser);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công')));
        // Navigate về màn hình login thay vì pop để tránh màn hình đen
        Navigator.pushReplacementNamed(context, Login.routeName);
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đăng ký thất bại: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FormBuilder(
        key: _formKey,
        initialValue: {'ngayTao': DateTime.now()},
        child: SizedBox(
          width: Helper.getScreenWidth(context),
          height: Helper.getScreenHeight(context),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Column(
                children: [
                  Text(
                    "Đăng Ký",
                    style: Helper.getTheme(context).headlineSmall,
                  ),
                  Spacer(),
                  const Text(""),
                  Spacer(),
                  FormBuilderTextField(
                    name: 'tenDangNhap',
                    validator: FormBuilderValidators.required(),
                    decoration: const InputDecoration(
                      hintText: "Tên đăng nhập",
                    ),
                  ),
                  Spacer(),
                  FormBuilderTextField(
                    name: 'hoTen',
                    validator: FormBuilderValidators.required(),
                    decoration: const InputDecoration(hintText: "Họ và tên"),
                  ),
                  Spacer(),
                  FormBuilderTextField(
                    name: 'email',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: "Email"),
                  ),
                  Spacer(),
                  FormBuilderTextField(
                    name: 'soDienThoai',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.match(
                        RegExp(r'^\+?\d{7,15}$'),
                        errorText: 'Số điện thoại không hợp lệ',
                      ),
                    ]),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "Số điện thoại",
                    ),
                  ),
                  Spacer(),
                  FormBuilderTextField(
                    name: 'diaChi',
                    validator: FormBuilderValidators.required(),
                    decoration: const InputDecoration(hintText: "Địa chỉ"),
                  ),
                  Spacer(),
                  FormBuilderTextField(
                    name: 'matKhau',
                    obscureText: true,
                    validator: FormBuilderValidators.required(),
                    decoration: const InputDecoration(hintText: "Mật khẩu"),
                  ),
                  Spacer(),
                  FormBuilderTextField(
                    name: 'confirmMatKhau',
                    obscureText: true,
                    validator: (val) {
                      if (val !=
                          _formKey.currentState?.fields['matKhau']?.value) {
                        return 'Mật khẩu không khớp';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: "Nhập lại mật khẩu",
                    ),
                  ),
                  Spacer(),
                  FormBuilderDateTimePicker(
                    name: 'ngayTao',
                    decoration: const InputDecoration(labelText: 'Ngày tạo'),
                    inputType: InputType.date,
                    format: DateFormat('dd-MM-yyyy'),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registerUser,
                      child: const Text("Đăng ký"),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(Login.routeName);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Bạn đã có tài khoản? "),
                        Text(
                          "Đăng nhập",
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
