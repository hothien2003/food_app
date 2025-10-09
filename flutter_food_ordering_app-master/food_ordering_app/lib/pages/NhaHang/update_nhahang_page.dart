import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';
import 'package:food_ordering_app/models/NhaHang.dart';
import 'package:food_ordering_app/api/api_nhahang.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/utils/notification_util.dart';
import 'package:food_ordering_app/utils/confirmation_dialog.dart';
import 'package:food_ordering_app/utils/input_decoration_util.dart';

class UpdateNhaHangPage extends StatefulWidget {
  final NhaHang nhaHang;
  const UpdateNhaHangPage({super.key, required this.nhaHang});

  @override
  State<UpdateNhaHangPage> createState() => _UpdateNhaHangPageState();
}

class _UpdateNhaHangPageState extends State<UpdateNhaHangPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiNhaHang _api = ApiNhaHang();

  // Phương thức update
  void updateData() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại thông tin')),
      );
      return;
    }

    final data = _formKey.currentState!.value;
    final updated = NhaHang(
      maNhaHang: widget.nhaHang.maNhaHang,
      tenNhaHang: data['tenNhaHang'],
      diaChi: data['diaChi'],
      soDienThoai: data['soDienThoai'],
      moTa: data['moTa'],
      ngayTao:
          data['ngayTao'] is String
              ? DateFormat('dd-MM-yyyy').parse(data['ngayTao'])
              : data['ngayTao'],
    );

    try {
      final response = await _api.updateNhaHang(
        maNhaHang: widget.nhaHang.maNhaHang,
        nhaHang: updated,
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
        final response = await _api.deleteNhaHang(
          maNhaHang: widget.nhaHang.maNhaHang,
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
                            "Cập nhật nhà hàng",
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
                  // Form cập nhật thông tin nhà hàng
                  FormBuilder(
                    key: _formKey,
                    initialValue: {
                      'tenNhaHang': widget.nhaHang.tenNhaHang,
                      'diaChi': widget.nhaHang.diaChi,
                      'soDienThoai': widget.nhaHang.soDienThoai,
                      'moTa': widget.nhaHang.moTa,
                      'ngayTao': widget.nhaHang.ngayTao,
                    },
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'tenNhaHang',
                          decoration: buildInputDecoration('Tên nhà hàng'),
                          validator: FormBuilderValidators.required(
                            errorText: 'Vui lòng nhập tên nhà hàng',
                          ),
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
                          name: 'moTa',
                          decoration: buildInputDecoration('Mô tả'),
                          keyboardType: TextInputType.emailAddress,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'Vui lòng nhập mô tả',
                            ),
                          ]),
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
      bottomNavigationBar: const CustomNavBar(home: true),
    );
  }
}
