import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_donhang.dart';
import 'package:food_ordering_app/api/api_giohang.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/GioHang.dart';
import 'package:food_ordering_app/models/Payment.dart';
import 'package:food_ordering_app/pages/DonHang/chitiet_donhang_page.dart';
import 'package:food_ordering_app/utils/image_util.dart';
import 'package:food_ordering_app/utils/shared_preferences_helper.dart';
import 'package:food_ordering_app/services/notification_service.dart';
import 'package:food_ordering_app/screens/card_payment_screen.dart';
import 'package:food_ordering_app/screens/ewallet_payment_screen.dart';
import 'package:food_ordering_app/screens/qr_banking_payment_screen.dart';
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

  PaymentMethodType _selectedPaymentMethod = PaymentMethodType.cod;
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

    // For COD, process order directly
    if (_selectedPaymentMethod == PaymentMethodType.cod) {
      await _processOrder();
      return;
    }

    // For other payment methods, navigate to payment screens first
    if (!mounted) return;

    // Calculate total including shipping fee
    const shippingFee = 15000.0;
    final total = widget.tongTien + shippingFee;

    // Generate a temporary order ID for payment screens
    final tempOrderId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    switch (_selectedPaymentMethod) {
      case PaymentMethodType.momo:
      case PaymentMethodType.zalopay:
        final result = await Navigator.push<PaymentResult>(
          context,
          MaterialPageRoute(
            builder:
                (context) => EWalletPaymentScreen(
                  walletType: _selectedPaymentMethod,
                  orderId: tempOrderId,
                  amount: total,
                ),
          ),
        );

        if (result != null && result.isSuccess && mounted) {
          await _processOrder(transactionId: result.transactionId);
        }
        break;

      case PaymentMethodType.card:
        final result = await Navigator.push<PaymentResult>(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    CardPaymentScreen(orderId: tempOrderId, amount: total),
          ),
        );

        if (result != null && result.isSuccess && mounted) {
          await _processOrder(transactionId: result.transactionId);
        }
        break;

      case PaymentMethodType.banking:
        final result = await Navigator.push<PaymentResult>(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    QRBankingPaymentScreen(orderId: tempOrderId, amount: total),
          ),
        );

        if (result != null && result.isSuccess && mounted) {
          await _processOrder(transactionId: result.transactionId);
        }
        break;

      case PaymentMethodType.cod:
        // Already handled above
        break;
    }
  }

  Future<void> _processOrder({String? transactionId}) async {
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
        (item) => item.maMonAnNavigation != null,
        orElse:
            () => throw Exception('Không tìm thấy thông tin nhà hàng hợp lệ'),
      );
      final maNhaHang = firstValidItem.maMonAnNavigation!.maNhaHang;

      // Tạo chi tiết đơn hàng
      final chiTietDonHangs =
          widget.gioHangList
              .where(
                (item) => item.maMonAnNavigation != null && item.soLuong > 0,
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
        phuongThucThanhToan:
            _selectedPaymentMethod == PaymentMethodType.cod
                ? 'Offline'
                : 'Online',
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

          // Thêm thông báo vào hệ thống
          final restaurantName =
              firstValidItem
                  .maMonAnNavigation
                  ?.maNhaHangNavigation
                  ?.tenNhaHang ??
              'Nhà hàng';
          await NotificationService.instance.notifyOrderPlaced(
            maDonHang,
            restaurantName,
          );

          // Thông báo thanh toán thành công (chỉ cho payment online)
          if (_selectedPaymentMethod != PaymentMethodType.cod) {
            await NotificationService.instance.notifyPaymentSuccess(
              maDonHang,
              widget.tongTien,
            );
          }
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn phương thức thanh toán',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 16),

            // COD
            _buildPaymentOption(
              type: PaymentMethodType.cod,
              icon: Icons.money,
              iconColor: Colors.green,
              title: 'Tiền mặt (COD)',
              subtitle: 'Thanh toán khi nhận hàng',
            ),

            const Divider(height: 1),

            // MoMo
            _buildPaymentOption(
              type: PaymentMethodType.momo,
              icon: Icons.smartphone,
              iconColor: const Color(0xFFAF206B),
              title: 'Ví MoMo',
              subtitle: 'Thanh toán qua ví điện tử MoMo',
            ),

            const Divider(height: 1),

            // ZaloPay
            _buildPaymentOption(
              type: PaymentMethodType.zalopay,
              icon: Icons.account_balance_wallet,
              iconColor: const Color(0xFF0068FF),
              title: 'ZaloPay',
              subtitle: 'Thanh toán qua ví ZaloPay',
            ),

            const Divider(height: 1),

            // QR Banking
            _buildPaymentOption(
              type: PaymentMethodType.banking,
              icon: Icons.qr_code,
              iconColor: Colors.blue,
              title: 'Chuyển khoản QR',
              subtitle: 'Quét mã QR để chuyển khoản',
            ),

            const Divider(height: 1),

            // Card
            _buildPaymentOption(
              type: PaymentMethodType.card,
              icon: Icons.credit_card,
              iconColor: Colors.indigo,
              title: 'Thẻ tín dụng/Ghi nợ',
              subtitle: 'Visa, Mastercard, JCB',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethodType type,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.orange.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColor.orange : AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Radio<PaymentMethodType>(
              value: type,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              activeColor: AppColor.orange,
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
    return SafeArea(
      child: Container(
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
