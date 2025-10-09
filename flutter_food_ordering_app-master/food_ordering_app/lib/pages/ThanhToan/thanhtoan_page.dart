import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_donhang.dart';
import 'package:food_ordering_app/api/api_giohang.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/GioHang.dart';
import 'package:food_ordering_app/pages/DonHang/chitiet_donhang_page.dart';
import 'package:food_ordering_app/utils/image_util.dart';
import 'package:food_ordering_app/utils/shared_preferences_helper.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ThanhToanPage extends StatefulWidget {
  final List<GioHang> gioHangList;
  final double tongTien;

  const ThanhToanPage({
    super.key,
    required this.gioHangList,
    required this.tongTien,
  });

  @override
  State<ThanhToanPage> createState() => _ThanhToanPageState();
}

class _ThanhToanPageState extends State<ThanhToanPage> {
  final baseImageUrl = 'http://10.0.2.2:5000/';
  final _formKey = GlobalKey<FormState>();

  // Controller cho các trường thông tin
  final TextEditingController _diaChiController = TextEditingController();
  final TextEditingController _sdtController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();

  String _selectedPaymentMethod = 'Offline';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _diaChiController.dispose();
    _sdtController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  // Phương thức gửi đơn hàng
  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Lấy mã người dùng từ SharedPreferences
      final maNguoiDung = await layMaNguoiDungDangNhap();
      if (maNguoiDung == null) {
        throw Exception('Bạn cần đăng nhập để đặt hàng');
      }

      // Lấy mã nhà hàng (giả định tất cả món ăn cùng một nhà hàng)
      final firstValidItem = widget.gioHangList.firstWhere(
        (item) =>
            item.maMonAnNavigation != null,
        orElse:
            () => throw Exception('Không tìm thấy thông tin nhà hàng hợp lệ'),
      );
      final maNhaHang = firstValidItem.maMonAnNavigation!.maNhaHang;

      // Tạo chi tiết đơn hàng
      final chiTietDonHangs =
          widget.gioHangList
              .where(
                (item) =>
                    item.maMonAnNavigation != null &&
                    item.soLuong > 0,
              )
              .map(
                (item) => {
                  'maMonAn': item.maMonAn,
                  'soLuong': item.soLuong,
                  'gia': item.maMonAnNavigation!.gia,
                },
              )
              .toList();

      if (chiTietDonHangs.isEmpty) {
        throw Exception('Không có món ăn hợp lệ trong giỏ hàng');
      }

      // Gọi API tạo đơn hàng
      final apiDonHang = ApiDonHang();
      final response = await apiDonHang.createDonHangFromGioHang(
        maNguoiDung: maNguoiDung,
        maNhaHang: maNhaHang,
        tongTien: widget.tongTien,
        chiTietDonHang: chiTietDonHangs,
        diaChiGiaoHang: _diaChiController.text,
        soDienThoai: _sdtController.text,
        ghiChu:
            _ghiChuController.text.isNotEmpty ? _ghiChuController.text : null,
        phuongThucThanhToan: _selectedPaymentMethod,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Lấy ID đơn hàng từ response
        Map<String, dynamic> responseData = {};
        try {
          if (response.body.isNotEmpty) {
            responseData = jsonDecode(response.body) as Map<String, dynamic>;
          }
        } catch (e) {
          print('Lỗi khi phân tích dữ liệu phản hồi: $e');
        }

        final int? maDonHang = responseData['maDonHang'];

        // Chỉ xóa giỏ hàng sau khi đặt hàng thành công và lấy được ID đơn hàng
        if (maDonHang != null) {
          await _clearCart();
        }

        if (!mounted) return;

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Chuyển sang trang chi tiết đơn hàng nếu có ID
        if (maDonHang != null) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChiTietDonHangPage(maDonHang: maDonHang),
            ),
          );
        } else {
          // Nếu không có ID, quay về trang chủ
          if (!mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đặt hàng: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Xóa giỏ hàng sau khi đặt hàng thành công
  Future<void> _clearCart() async {
    final apiGioHang = ApiGioHang();
    for (final item in widget.gioHangList) {
      await apiGioHang.deleteGioHang(item.maGioHang);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColor.primary),
      ),
      body:
          _isSubmitting
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColor.orange),
                    SizedBox(height: 16),
                    Text('Đang xử lý đơn hàng...'),
                  ],
                ),
              )
              : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Sản phẩm đã chọn'),
                            const SizedBox(height: 8),
                            _buildOrderItems(),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Thông tin giao hàng'),
                            const SizedBox(height: 8),
                            _buildAddressForm(),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Phương thức thanh toán'),
                            const SizedBox(height: 8),
                            _buildPaymentMethods(),
                            const SizedBox(height: 24),

                            _buildSectionTitle('Tổng cộng'),
                            const SizedBox(height: 8),
                            _buildOrderSummary(),
                          ],
                        ),
                      ),
                    ),
                    _buildCheckoutButton(),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColor.primary,
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children:
              widget.gioHangList.map((item) {
                final monAn = item.maMonAnNavigation!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child:
                            monAn.urlHinhAnh != null
                                ? Image.network(
                                  getFullImageUrl(
                                    baseImageUrl,
                                    monAn.urlHinhAnh,
                                  ),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 20,
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.fastfood, size: 20),
                                ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monAn.tenMonAn,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${item.soLuong} x ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(monAn.gia)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'vi_VN',
                          symbol: '₫',
                          decimalDigits: 0,
                        ).format(monAn.gia * item.soLuong),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _diaChiController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ giao hàng',
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập địa chỉ giao hàng';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sdtController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ghiChuController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            RadioListTile<String>(
              title: const Row(
                children: [
                  Icon(Icons.money, color: Colors.green),
                  SizedBox(width: 12),
                  Flexible(child: Text('Thanh toán khi nhận hàng (COD)')),
                ],
              ),
              subtitle: const Text('Thanh toán bằng tiền mặt khi nhận hàng'),
              value: 'Offline',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              activeColor: AppColor.orange,
            ),
            const Divider(height: 1),
            RadioListTile<String>(
              title: const Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.blue),
                  SizedBox(width: 12),
                  Text('Thanh toán trực tuyến'),
                ],
              ),
              subtitle: const Text('Thanh toán qua ví điện tử hoặc thẻ'),
              value: 'Online',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              activeColor: AppColor.orange,
            ),
            if (_selectedPaymentMethod == 'Online')
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(
                  top: 8,
                  left: 12,
                  right: 12,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn phương thức thanh toán:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/momo.png',
                        width: 36,
                        height: 36,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.smartphone,
                              size: 36,
                              color: Colors.pink,
                            ),
                      ),
                      title: const Text('Ví MoMo'),
                      dense: true,
                      onTap: () {
                        // Xử lý chọn thanh toán MoMo
                      },
                    ),
                    ListTile(
                      leading: Image.asset(
                        'assets/icons/zalopay.png',
                        width: 36,
                        height: 36,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.account_balance_wallet,
                              size: 36,
                              color: Colors.blue,
                            ),
                      ),
                      title: const Text('ZaloPay'),
                      dense: true,
                      onTap: () {
                        // Xử lý chọn thanh toán ZaloPay
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.credit_card,
                        size: 36,
                        color: Colors.indigo,
                      ),
                      title: const Text('Thẻ tín dụng/ghi nợ'),
                      dense: true,
                      onTap: () {
                        // Xử lý chọn thanh toán thẻ
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    // Giá tạm tính
    final subtotal = widget.tongTien;

    // Phí giao hàng (ví dụ: cố định 15,000đ)
    const shippingFee = 15000.0;

    // Khuyến mãi (nếu có)
    const discount = 0.0;

    // Tổng cộng
    final total = subtotal + shippingFee - discount;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow('Tạm tính', subtotal),
            const SizedBox(height: 8),
            _buildSummaryRow('Phí giao hàng', shippingFee),
            const SizedBox(height: 8),
            _buildSummaryRow('Khuyến mãi', -discount),
            const Divider(height: 24),
            _buildSummaryRow(
              'Tổng cộng',
              total,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.orange,
              ),
              valueStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value, {
    TextStyle? textStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textStyle ?? TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        Text(
          NumberFormat.currency(
            locale: 'vi_VN',
            symbol: '₫',
            decimalDigits: 0,
          ).format(value),
          style:
              valueStyle ??
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.orange,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Đặt hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
