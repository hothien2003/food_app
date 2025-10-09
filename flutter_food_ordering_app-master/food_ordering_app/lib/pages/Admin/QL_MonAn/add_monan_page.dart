import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_monan.dart';
import 'package:food_ordering_app/api/api_nhahang.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/MonAn.dart';
import 'package:food_ordering_app/models/NhaHang.dart';
import 'package:food_ordering_app/utils/image_util.dart';
import 'package:food_ordering_app/utils/input_decoration_util.dart';
import 'package:food_ordering_app/utils/notification_util.dart';
import 'package:image_picker/image_picker.dart';

class AddMonAnPage extends StatefulWidget {
  static const routeName = "/addMonAnPage";
  const AddMonAnPage({super.key});

  @override
  State<AddMonAnPage> createState() => _AddMonAnPageState();
}

class _AddMonAnPageState extends State<AddMonAnPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiMonAn _apiMonAn = ApiMonAn();
  final ApiNhaHang _apiNhaHang = ApiNhaHang();

  // Controllers cho các trường thông tin
  final TextEditingController _tenMonAnController = TextEditingController();
  final TextEditingController _giaController = TextEditingController();
  final TextEditingController _moTaController = TextEditingController();
  final TextEditingController _urlHinhAnhController = TextEditingController();

  // Biến lưu trữ ảnh đã chọn
  File? _selectedImage;
  bool _isLoading = false;
  int _selectedNhaHang = 0; // Mặc định chưa chọn nhà hàng nào

  // Danh sách nhà hàng
  List<NhaHang> _danhSachNhaHang = [];

  @override
  void initState() {
    super.initState();
    _loadDanhSachNhaHang();
  }

  // Hàm lấy danh sách nhà hàng từ API
  Future<void> _loadDanhSachNhaHang() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final danhSachNhaHang = await _apiNhaHang.getNhaHangData();
      setState(() {
        _danhSachNhaHang = danhSachNhaHang;
        // Nếu có nhà hàng, chọn nhà hàng đầu tiên làm mặc định
        if (_danhSachNhaHang.isNotEmpty) {
          _selectedNhaHang = _danhSachNhaHang[0].maNhaHang;
        }
      });
    } catch (e) {
      print('Lỗi khi tải danh sách nhà hàng: $e');
      if (mounted) {
        NotificationUtil.showErrorMessage(
          context,
          'Không thể tải danh sách nhà hàng. Vui lòng thử lại sau.',
        );
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
  void dispose() {
    _tenMonAnController.dispose();
    _giaController.dispose();
    _moTaController.dispose();
    _urlHinhAnhController.dispose();
    super.dispose();
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        // Lưu đường dẫn gốc để hiển thị ảnh trong UI
        _urlHinhAnhController.text = image.path;
      });
    }
  }

  // Hàm xử lý khi nhấn nút lưu
  Future<void> _saveMonAn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Tìm đối tượng NhaHang tương ứng với mã nhà hàng đã chọn
        NhaHang selectedNhaHang = _danhSachNhaHang.firstWhere(
          (nh) => nh.maNhaHang == _selectedNhaHang,
          orElse:
              () => NhaHang(
                maNhaHang: _selectedNhaHang,
                tenNhaHang:
                    'Nhà hàng không xác định', // Đảm bảo có tên nhà hàng
                diaChi: '',
                soDienThoai: '',
                moTa: '',
                ngayTao: DateTime.now(),
              ),
        );

        // Xử lý đường dẫn hình ảnh
        String urlHinhAnh = "Images/default-food.jpg"; // Đường dẫn mặc định

        // chọn ảnh từ thiết bị
        if (_urlHinhAnhController.text.isNotEmpty) {
          if (_selectedImage != null) {
            // Chuyển đổi đường dẫn tuyệt đối thành đường dẫn tương đối
            urlHinhAnh = convertToRelativeImagePath(_urlHinhAnhController.text);
          } else if (!_urlHinhAnhController.text.contains('/') &&
              !_urlHinhAnhController.text.contains('\\')) {
            // Nếu người dùng đã nhập đường dẫn tương đối (không chứa dấu / hoặc \)
            urlHinhAnh = _urlHinhAnhController.text;
          }
        }

        // Tạo đối tượng MonAn mới với thông tin nhà hàng
        final monAn = MonAn(
          maMonAn: 0,
          maNhaHang: _selectedNhaHang,
          tenMonAn: _tenMonAnController.text,
          moTa: _moTaController.text,
          gia: double.parse(_giaController.text),
          urlHinhAnh: urlHinhAnh,
          ngayTao: DateTime.now(),
          maNhaHangNavigation: selectedNhaHang,
        );

        // Gọi API để thêm món ăn
        final response = await _apiMonAn.createMonAn(monAn);

        if (!mounted) return;

        if (response.statusCode >= 200 && response.statusCode < 300) {
          NotificationUtil.showSuccessMessage(
            context,
            'Thêm món ăn thành công!',
            onComplete: () {
              if (mounted) Navigator.pop(context, true);
            },
          );
        } else {
          NotificationUtil.showErrorMessage(
            context,
            'Thêm món ăn thất bại: ${response.statusCode} - ${response.body}',
          );
        }
      } catch (e) {
        if (mounted) {
          NotificationUtil.showErrorMessage(
            context,
            'Thêm món ăn thất bại: $e',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColor.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thêm món ăn mới',
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColor.orange),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phần chọn ảnh
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColor.placeholder),
                              image:
                                  _selectedImage != null
                                      ? DecorationImage(
                                        image: FileImage(_selectedImage!),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                            child:
                                _selectedImage == null
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 50,
                                          color: AppColor.orange,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Chọn ảnh',
                                          style: TextStyle(
                                            color: AppColor.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tên món ăn
                      TextFormField(
                        controller: _tenMonAnController,
                        decoration: buildInputDecoration('Tên món ăn'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên món ăn';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Giá
                      TextFormField(
                        controller: _giaController,
                        decoration: buildInputDecoration('Giá (VNĐ)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập giá';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Giá phải là số';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Chọn nhà hàng
                      DropdownButtonFormField<int>(
                        decoration: buildInputDecoration('Nhà hàng'),
                        value: _selectedNhaHang,
                        items:
                            _danhSachNhaHang.map((nhaHang) {
                              return DropdownMenuItem<int>(
                                value: nhaHang.maNhaHang,
                                child: Text(nhaHang.tenNhaHang),
                              );
                            }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedNhaHang =
                                newValue ??
                                (_danhSachNhaHang.isNotEmpty
                                    ? _danhSachNhaHang[0].maNhaHang
                                    : 0);
                          });
                        },
                        validator: (value) {
                          if (value == null || value == 0) {
                            return 'Vui lòng chọn nhà hàng';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // URL hình ảnh (ẩn, được cập nhật tự động khi chọn ảnh)
                      TextFormField(
                        controller: _urlHinhAnhController,
                        decoration: buildInputDecoration('URL hình ảnh'),
                        // readOnly: true,
                        validator: (value) {
                          // if (value == null || value.isEmpty) {
                          //   return 'Vui lòng chọn ảnh cho món ăn';
                          // }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Mô tả
                      TextFormField(
                        controller: _moTaController,
                        decoration: buildInputDecoration('Mô tả'),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mô tả';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Nút lưu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveMonAn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Lưu món ăn',
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
              ),
    );
  }
}
