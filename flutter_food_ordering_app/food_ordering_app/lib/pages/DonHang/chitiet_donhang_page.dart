import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_donhang.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/DonHang.dart';
import 'package:food_ordering_app/utils/image_util.dart';
import 'package:intl/intl.dart';

class ChiTietDonHangPage extends StatefulWidget {
  static const routeName = "/chiTietDonHangPage";
  final int maDonHang;

  const ChiTietDonHangPage({super.key, required this.maDonHang});

  @override
  State<ChiTietDonHangPage> createState() => _ChiTietDonHangPageState();
}

class _ChiTietDonHangPageState extends State<ChiTietDonHangPage> {
  final baseImageUrl = 'http://10.0.2.2:5000/';
  DonHang? donHang;
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    loadDonHang();
  }

  Future<void> loadDonHang() async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiDonHang = ApiDonHang();
      final result = await apiDonHang.getDonHangById(widget.maDonHang);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể tải thông tin đơn hàng #${widget.maDonHang}',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'THỬ LẠI',
              onPressed: loadDonHang,
              textColor: Colors.white,
            ),
          ),
        );
      }

      setState(() {
        donHang = result;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi tải thông tin đơn hàng'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'THỬ LẠI',
            onPressed: loadDonHang,
            textColor: Colors.white,
          ),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateTrangThai(String trangThai) async {
    if (donHang == null) return;

    setState(() {
      isUpdating = true;
    });

    try {
      final apiDonHang = ApiDonHang();
      final response = await apiDonHang.updateTrangThaiDonHang(
        donHang!.maDonHang,
        trangThai,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật trạng thái thành công'),
            backgroundColor: Colors.green,
          ),
        );
        // Tải lại đơn hàng để cập nhật thông tin
        await loadDonHang();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return 'Chờ xác nhận';
      case 'Đang xử lý':
        return 'Đang xử lý';
      case 'Đang giao hàng':
        return 'Đang giao hàng';
      case 'Đã giao hàng':
        return 'Đã giao hàng';
      case 'Đã hủy':
        return 'Đã hủy';
      case 'Hoàn thành':
        return 'Hoàn thành';
      default:
        return 'Không xác định';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Chờ xác nhận':
        return Colors.orange;
      case 'Đang xử lý':
        return Colors.blue;
      case 'Đang giao hàng':
        return Colors.purple;
      case 'Đã giao hàng':
        return Colors.green;
      case 'Đã hủy':
        return Colors.red;
      case 'Hoàn thành':
        return Colors.green.shade700;
      default:
        return Colors.grey;
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
          'Chi tiết đơn hàng',
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColor.primary),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColor.orange),
              )
              : donHang == null
              ? const Center(child: Text('Không tìm thấy thông tin đơn hàng'))
              : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderStatusCard(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Thông tin đơn hàng'),
                        const SizedBox(height: 8),
                        _buildOrderInfoCard(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Chi tiết sản phẩm'),
                        const SizedBox(height: 8),
                        _buildOrderItemsCard(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('Tổng thanh toán'),
                        const SizedBox(height: 8),
                        _buildOrderSummaryCard(),
                        const SizedBox(
                          height: 80,
                        ), // Để tránh button che mất nội dung
                      ],
                    ),
                  ),
                  if (donHang!.trangThai == 'Đang giao hàng')
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildConfirmButton(),
                    ),
                ],
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

  Widget _buildOrderStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trạng thái đơn hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(donHang!.trangThai).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    getStatusText(donHang!.trangThai),
                    style: TextStyle(
                      color: getStatusColor(donHang!.trangThai),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (donHang?.ngayDatHang != null) ...[
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(donHang!.ngayDatHang!)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 18,
                  color: AppColor.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mã đơn hàng: #${donHang!.maDonHang}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.storefront, size: 18, color: AppColor.primary),
                const SizedBox(width: 8),
                Text(
                  'Nhà hàng: ${donHang!.nhaHang?.tenNhaHang ?? 'Không có thông tin'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: AppColor.primary),
                const SizedBox(width: 8),
                Text(
                  'Người đặt: ${donHang!.nguoiDung?.hoTen ?? 'Không có thông tin'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    final chiTietDonHang = donHang?.chiTietDonHangs ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chiTietDonHang.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Không có thông tin chi tiết sản phẩm',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              ...chiTietDonHang.map((item) {
                final monAn = item.maMonAnNavigation;
                if (monAn == null) {
                  return const ListTile(
                    title: Text('Sản phẩm không có sẵn'),
                    subtitle: Text('Không có thông tin chi tiết'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            monAn.urlHinhAnh != null &&
                                    monAn.urlHinhAnh!.isNotEmpty
                                ? Image.network(
                                  getFullImageUrl(
                                    baseImageUrl,
                                    monAn.urlHinhAnh,
                                  ),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 30,
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.fastfood, size: 30),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                                decimalDigits: 0,
                              ).format(item.gia),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColor.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'x${item.soLuong}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: '₫',
                              decimalDigits: 0,
                            ).format(item.gia * item.soLuong),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    if (donHang == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Không có thông tin thanh toán'),
        ),
      );
    }

    // Phí giao hàng (giả định)
    const shippingFee = 15000.0;

    // Tổng cộng
    final total = donHang!.tongTien;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tạm tính', style: TextStyle(color: Colors.grey[600])),
                Text(
                  NumberFormat.currency(
                    locale: 'vi_VN',
                    symbol: '₫',
                    decimalDigits: 0,
                  ).format(total - shippingFee),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Phí giao hàng',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'vi_VN',
                    symbol: '₫',
                    decimalDigits: 0,
                  ).format(shippingFee),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng thanh toán',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'vi_VN',
                    symbol: '₫',
                    decimalDigits: 0,
                  ).format(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColor.orange,
                  ),
                ),
              ],
            ),
            if (donHang?.trangThai == 'Đã hủy') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đơn hàng này đã bị hủy',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
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
            onPressed: isUpdating ? null : () => updateTrangThai('Hoàn thành'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.orange,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                isUpdating
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Xác nhận đã nhận hàng',
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
