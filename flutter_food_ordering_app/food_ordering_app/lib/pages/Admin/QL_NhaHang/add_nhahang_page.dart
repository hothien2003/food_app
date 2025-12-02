import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/NhaHang.dart';
import 'package:food_ordering_app/api/api_nhahang.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/utils/notification_util.dart';
import 'package:food_ordering_app/utils/input_decoration_util.dart';

class AddNhaHangPage extends StatefulWidget {
  const AddNhaHangPage({super.key});

  @override
  State<AddNhaHangPage> createState() => _AddNhaHangPageState();
}

class _AddNhaHangPageState extends State<AddNhaHangPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiNhaHang _api = ApiNhaHang();
  bool _isSubmitting = false;

  // Phương thức thêm nhà hàng mới
  void addData() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại thông tin')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final data = _formKey.currentState!.value;
    final newNhaHang = NhaHang(
      maNhaHang: 0, // Mã sẽ được tạo tự động bởi server
      tenNhaHang: data['tenNhaHang'],
      diaChi: data['diaChi'],
      soDienThoai: data['soDienThoai'],
      moTa: data['moTa'],
      ngayTao:
          data['ngayTao'] is String
              ? DateFormat('dd-MM-yyyy').parse(data['ngayTao'])
              : data['ngayTao'] ?? DateTime.now(),
    );

    try {
      final response = await _api.createNhaHang(nhaHang: newNhaHang);

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        NotificationUtil.showSuccessMessage(
          context,
          'Thêm nhà hàng thành công!',
          onComplete: () {
            if (context.mounted) {
              Navigator.pop(context, true);
            }
          },
        );
      } else {
        NotificationUtil.showErrorMessage(
          context,
          'Thêm nhà hàng thất bại: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      NotificationUtil.showErrorMessage(context, 'Lỗi: ${e.toString()}');
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
                            "Thêm nhà hàng mới",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Form thêm nhà hàng
                  FormBuilder(
                    key: _formKey,
                    initialValue: {'ngayTao': DateTime.now()},
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          name: 'tenNhaHang',
                          decoration: buildInputDecoration('Tên nhà hàng'),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'Vui lòng nhập tên nhà hàng',
                            ),
                            FormBuilderValidators.minLength(
                              3,
                              errorText: 'Tên nhà hàng phải có ít nhất 3 ký tự',
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
                          maxLines: 3,
                          validator: FormBuilderValidators.required(
                            errorText: 'Vui lòng nhập mô tả',
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
                            onPressed: _isSubmitting ? null : addData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child:
                                _isSubmitting
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'Thêm nhà hàng',
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
