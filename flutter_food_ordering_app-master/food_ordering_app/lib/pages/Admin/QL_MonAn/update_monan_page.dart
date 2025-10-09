import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/MonAn.dart';
import 'package:food_ordering_app/models/NhaHang.dart';
import 'package:food_ordering_app/api/api_monan.dart';
import 'package:food_ordering_app/api/api_nhahang.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/utils/notification_util.dart';
import 'package:food_ordering_app/utils/confirmation_dialog.dart';
import 'package:food_ordering_app/utils/input_decoration_util.dart';

class UpdateMonAnPage extends StatefulWidget {
  final MonAn monAn;
  const UpdateMonAnPage({super.key, required this.monAn});

  @override
  State<UpdateMonAnPage> createState() => _UpdateMonAnPageState();
}

class _UpdateMonAnPageState extends State<UpdateMonAnPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ApiMonAn _api = ApiMonAn();
  final ApiNhaHang _apiNhaHang = ApiNhaHang();
  bool _isLoading = false;
  List<NhaHang> _danhSachNhaHang = [];
  bool _isLoadingNhaHang = true;

  @override
  void initState() {
    super.initState();
    _loadDanhSachNhaHang();
  }

  Future<void> _loadDanhSachNhaHang() async {
    try {
      final danhSach = await _apiNhaHang.getNhaHangData();
      setState(() {
        _danhSachNhaHang = danhSach;
        _isLoadingNhaHang = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingNhaHang = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải danh sách nhà hàng: $e')),
        );
      }
    }
  }

  Future<void> updateData() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại thông tin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = _formKey.currentState!.value;

      // Chuyển đổi kiểu dữ liệu
      final int maNhaHang =
          int.tryParse(data['maNhaHang'].toString()) ?? widget.monAn.maNhaHang;
      final double gia =
          double.tryParse(data['gia'].toString()) ?? widget.monAn.gia;

      // Đảm bảo định dạng ngày tháng
      DateTime ngayTao;
      if (data['ngayTao'] is DateTime) {
        ngayTao = data['ngayTao'];
      } else {
        ngayTao = widget.monAn.ngayTao ?? DateTime.now();
      }

      // Tìm thông tin nhà hàng từ danh sách
      final nhaHang = _danhSachNhaHang.firstWhere(
        (nh) => nh.maNhaHang.toString() == data['maNhaHang'].toString(),
        orElse:
            () => NhaHang(
              maNhaHang: maNhaHang,
              tenNhaHang: '',
              diaChi: '',
              soDienThoai: '',
              moTa: '',
              ngayTao: DateTime.now(),
            ),
      );

      // Tạo đối tượng MonAn
      final updated = MonAn(
        maMonAn: widget.monAn.maMonAn,
        maNhaHang: maNhaHang,
        tenMonAn: data['tenMonAn'],
        moTa: data['moTa'] ?? '',
        gia: gia,
        urlHinhAnh: data['urlHinhAnh'] ?? '',
        ngayTao: ngayTao,
        maNhaHangNavigation: nhaHang,
      );
      final response = await _api.updateMonAn(
        maMonAn: widget.monAn.maMonAn,
        monAn: updated,
      );

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        NotificationUtil.showSuccessMessage(
          context,
          'Cập nhật thành công!',
          onComplete: () {
            if (mounted) Navigator.pop(context, true);
          },
        );
      } else {
        NotificationUtil.showErrorMessage(
          context,
          'Cập nhật thất bại: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationUtil.showErrorMessage(context, 'Cập nhật thất bại');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> deleteData() async {
    final confirm = await showConfirmationDialog(context);
    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _api.deleteMonAn(maMonAn: widget.monAn.maMonAn);
      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        NotificationUtil.showSuccessMessage(
          context,
          'Xoá thành công!',
          onComplete: () {
            if (mounted) Navigator.pop(context, true);
          },
        );
      } else {
        NotificationUtil.showErrorMessage(
          context,
          'Xoá thất bại: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationUtil.showErrorMessage(context, 'Xoá thất bại: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cập nhật món ăn',
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                        ),
                        GestureDetector(
                          onTap: deleteData,
                          child: Image.asset(
                            Helper.getAssetName(
                              'icons8-trash-can-24.png',
                              'virtual',
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Form
                  _isLoadingNhaHang
                      ? const Center(child: CircularProgressIndicator())
                      : FormBuilder(
                        key: _formKey,
                        initialValue: {
                          'maNhaHang': widget.monAn.maNhaHang.toString(),
                          'tenMonAn': widget.monAn.tenMonAn,
                          'moTa': widget.monAn.moTa ?? '',
                          'gia': widget.monAn.gia.toString(),
                          'urlHinhAnh': widget.monAn.urlHinhAnh ?? '',
                          'ngayTao': widget.monAn.ngayTao,
                        },
                        child: Column(
                          children: [
                            // Dropdown chọn nhà hàng
                            FormBuilderDropdown<String>(
                              name: 'maNhaHang',
                              decoration: buildInputDecoration('Nhà hàng'),
                              items:
                                  _danhSachNhaHang.map((nhaHang) {
                                    return DropdownMenuItem(
                                      value: nhaHang.maNhaHang.toString(),
                                      child: Text(nhaHang.tenNhaHang),
                                    );
                                  }).toList(),
                              validator: FormBuilderValidators.required(
                                errorText: 'Vui lòng chọn nhà hàng',
                              ),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'tenMonAn',
                              decoration: buildInputDecoration('Tên món ăn'),
                              validator: FormBuilderValidators.required(
                                errorText: 'Vui lòng nhập tên món ăn',
                              ),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'moTa',
                              decoration: buildInputDecoration('Mô tả'),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'gia',
                              decoration: buildInputDecoration('Giá'),
                              keyboardType: TextInputType.number,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                  errorText: 'Vui lòng nhập giá',
                                ),
                                FormBuilderValidators.numeric(
                                  errorText: 'Giá phải là số',
                                ),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'urlHinhAnh',
                              decoration: buildInputDecoration('URL hình ảnh'),
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
                                onPressed: _isLoading ? null : updateData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  disabledBackgroundColor: Colors.grey,
                                ),
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : const Text(
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
