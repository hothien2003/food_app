import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/NguoiDung.dart';
import 'package:food_ordering_app/api/api_nguoidung.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/utils/notification_util.dart';
import 'package:food_ordering_app/utils/confirmation_dialog.dart';
import 'package:food_ordering_app/utils/input_decoration_util.dart';

class UpdateTaiKhoanPage extends StatefulWidget {
  final NguoiDung nguoiDung;
  const UpdateTaiKhoanPage({super.key, required this.nguoiDung});

  @override
  State<UpdateTaiKhoanPage> createState() => _UpdateTaiKhoanPageState();
}

class _UpdateTaiKhoanPageState extends State<UpdateTaiKhoanPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiNguoiDung _api = ApiNguoiDung();

  // Phương thức update
  void updateData() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại thông tin')),
      );
      return;
    }

    final data = _formKey.currentState!.value;
    final updated = NguoiDung(
      maNguoiDung: widget.nguoiDung.maNguoiDung,
      tenDangNhap: data['tenDangNhap'],
      matKhau: data['matKhau'],
      hoTen: data['hoTen'],
      email: data['email'],
      soDienThoai: data['soDienThoai'],
      diaChi: data['diaChi'],
      ngayTao:
          data['ngayTao'] is String
              ? DateFormat('dd-MM-yyyy').parse(data['ngayTao'])
              : data['ngayTao'],
    );

    try {
      final response = await _api.updateNguoiDung(
        maNguoiDung: widget.nguoiDung.maNguoiDung,
        nguoiDung: updated,
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        NotificationUtil.showSuccessMessage(
          context,
          'Thành công!',
          onComplete: () {
            if (context.mounted) {
              Navigator.pop(context, true);
            }
          },
        );
      }
    } catch (e) {
      NotificationUtil.showErrorMessage(
        context,
        'Thất bại!',
        onComplete: () {
          if (context.mounted) {
            Navigator.pop(context, true);
          }
        },
      );
    }
  }

  // Phương thức delete
  void deleteData() async {
    final confirm = await showConfirmationDialog(context);

    if (confirm == true) {
      try {
        final response = await _api.deleteNguoiDung(
          maNguoiDung: widget.nguoiDung.maNguoiDung,
        );

        if (!mounted) return;

        if (response.statusCode >= 200 && response.statusCode < 300) {
          NotificationUtil.showSuccessMessage(
            context,
            'Xoá thành công!',
            onComplete: () {
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
          );
        } else {
          NotificationUtil.showErrorMessage(
            context,
            'Xoá thất bại: ${response.statusCode}',
          );
        }
      } catch (e) {
        NotificationUtil.showErrorMessage(context, 'Xoá thất bại!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Cập nhật người dùng",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                        ),
                        GestureDetector(
                          onTap: deleteData,
                          child: Image.asset(
                            Helper.getAssetName(
                              "icons8-trash-can-24.png",
                              "virtual",
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Form cập nhật thông tin người dùng
                  FormBuilder(
                    key: _formKey,
                    initialValue: {
                      'tenDangNhap': widget.nguoiDung.tenDangNhap,
                      'matKhau': widget.nguoiDung.matKhau,
                      'hoTen': widget.nguoiDung.hoTen,
                      'email': widget.nguoiDung.email,
                      'soDienThoai': widget.nguoiDung.soDienThoai,
                      'diaChi': widget.nguoiDung.diaChi,
                      'ngayTao': widget.nguoiDung.ngayTao,
                    },
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'tenDangNhap',
                          decoration: buildInputDecoration('Tên đăng nhập'),
                          validator: FormBuilderValidators.required(
                            errorText: 'Vui lòng nhập tên đăng nhập',
                          ),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'matKhau',
                          decoration: buildInputDecoration('Mật khẩu'),
                          obscureText: true,
                          validator: FormBuilderValidators.required(
                            errorText: 'Vui lòng nhập mật khẩu',
                          ),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'hoTen',
                          decoration: buildInputDecoration('Họ và tên'),
                          validator: FormBuilderValidators.required(
                            errorText: 'Vui lòng nhập họ và tên',
                          ),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'email',
                          decoration: buildInputDecoration('Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'Vui lòng nhập email',
                            ),
                            FormBuilderValidators.email(
                              errorText: 'Email không hợp lệ',
                            ),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'soDienThoai',
                          decoration: buildInputDecoration('Số điện thoại'),
                          keyboardType: TextInputType.phone,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'Vui lòng nhập số điện thoại',
                            ),
                            FormBuilderValidators.match(
                              RegExp(r'^\+?\d{7,15}$'),
                              errorText: 'Số điện thoại không hợp lệ',
                            ),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderTextField(
                          name: 'diaChi',
                          decoration: buildInputDecoration('Địa chỉ'),
                          validator: FormBuilderValidators.required(
                            errorText: 'Vui lòng nhập địa chỉ',
                          ),
                        ),
                        const SizedBox(height: 16),
                        FormBuilderDateTimePicker(
                          name: 'ngayTao',
                          decoration: buildInputDecoration('Ngày tạo'),
                          inputType: InputType.date,
                          format: DateFormat('dd-MM-yyyy'),
                          validator: FormBuilderValidators.required(
                            errorText: 'Vui lòng chọn ngày',
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: updateData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Cập nhật',
                              style: TextStyle(
                                color: AppColor.placeholderBg,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
