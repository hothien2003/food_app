import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_danhgia.dart';
import 'package:food_ordering_app/models/DanhGium.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/utils/shared_preferences_helper.dart';

class DanhGiaPage extends StatefulWidget {
  static const routeName = "/danhgiaPage";
  final int maNhaHang;
  final String tenNhaHang;

  const DanhGiaPage({
    super.key,
    required this.maNhaHang,
    required this.tenNhaHang,
  });

  @override
  State<DanhGiaPage> createState() => _DanhGiaPageState();
}

class _DanhGiaPageState extends State<DanhGiaPage> {
  final ApiDanhGia _apiDanhGia = ApiDanhGia();
  final TextEditingController _binhLuanController = TextEditingController();
  int _diemDanhGia = 5;
  bool _isLoading = false;

  Future<void> _submitDanhGia() async {
    final maNguoiDung = await layMaNguoiDungDangNhap();

    if (maNguoiDung == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá')),
      );
      return;
    }

    if (_binhLuanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập bình luận')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final danhGia = DanhGium(
      maDanhGia: 0,
      maNguoiDung: maNguoiDung,
      maNhaHang: widget.maNhaHang,
      diemDanhGia: _diemDanhGia,
      binhLuan: _binhLuanController.text.trim(),
      ngayTao: DateTime.now(),
    );

    try {
      final response = await _apiDanhGia.createDanhGia(danhGia: danhGia);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá thất bại. Vui lòng thử lại!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _binhLuanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá nhà hàng'),
        backgroundColor: AppColor.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tenNhaHang,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text(
              'Chọn số sao:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 40,
                  icon: Icon(
                    index < _diemDanhGia ? Icons.star : Icons.star_border,
                    color: AppColor.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _diemDanhGia = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              'Đánh giá: $_diemDanhGia/5 sao',
              style: TextStyle(
                fontSize: 16,
                color: AppColor.orange,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Text(
              'Bình luận:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _binhLuanController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Nhập bình luận của bạn về nhà hàng...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColor.orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitDanhGia,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppColor.orange),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Gửi đánh giá',
                          style: TextStyle(fontSize: 18),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
