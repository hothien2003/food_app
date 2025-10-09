import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_giohang.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/MonAn.dart';
import 'package:food_ordering_app/models/GioHang.dart';
import 'package:food_ordering_app/pages/GioHang/giohang_page.dart';
import 'package:food_ordering_app/utils/image_util.dart';
import 'package:food_ordering_app/utils/shared_preferences_helper.dart';
import 'package:intl/intl.dart';

class ChiTietMonAnPage extends StatefulWidget {
  final MonAn monAn;

  const ChiTietMonAnPage({super.key, required this.monAn});

  @override
  State<ChiTietMonAnPage> createState() => _ChiTietMonAnPageState();
}

class _ChiTietMonAnPageState extends State<ChiTietMonAnPage> {
  int soLuong = 1;
  bool isAddingToCart = false;
  final String baseImageUrl = "http://10.0.2.2:5000/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductInfo(),
                      const SizedBox(height: 16),
                      _buildQuantitySelector(),
                      const SizedBox(height: 24),
                      _buildDescription(),
                      const SizedBox(height: 80), // Để tránh che button
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(),
          if (isAddingToCart)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColor.orange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColor.orange,
      flexibleSpace: FlexibleSpaceBar(
        background:
            widget.monAn.urlHinhAnh != null
                ? Image.network(
                  getFullImageUrl(baseImageUrl, widget.monAn.urlHinhAnh),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                )
                : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.fastfood, size: 50),
                ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(Icons.shopping_cart, color: AppColor.orange),
            onPressed: () {
              Navigator.pushNamed(context, GioHangPage.routeName);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.monAn.tenMonAn,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          NumberFormat.currency(
            locale: 'vi_VN',
            symbol: '₫',
            decimalDigits: 0,
          ).format(widget.monAn.gia),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColor.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text(
          'Số lượng:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed:
                    soLuong > 1
                        ? () {
                          setState(() {
                            soLuong--;
                          });
                        }
                        : null,
                color: AppColor.primary,
              ),
              Text(
                '$soLuong',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    soLuong++;
                  });
                },
                color: AppColor.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mô tả',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.monAn.moTa ?? 'Không có mô tả cho sản phẩm này.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tổng tiền:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: '₫',
                        decimalDigits: 0,
                      ).format(widget.monAn.gia * soLuong),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.orange,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: isAddingToCart ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    // Kiểm tra đăng nhập
    final maNguoiDung = await layMaNguoiDungDangNhap();
    if (maNguoiDung == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isAddingToCart = true;
    });

    try {
      // Tạo đối tượng giỏ hàng mới
      final apiGioHang = ApiGioHang();

      // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
      final danhSachGioHang = await apiGioHang.getGioHangByNguoiDung(
        maNguoiDung,
      );

      final productInCart = danhSachGioHang.firstWhere(
        (item) => item.maMonAn == widget.monAn.maMonAn,
        orElse:
            () => GioHang(
              maGioHang: 0,
              maNguoiDung: maNguoiDung,
              maMonAn: widget.monAn.maMonAn,
              soLuong: 0,
              ngayThem: DateTime.now(),
              maMonAnNavigation: null,
              maNguoiDungNavigation: null,
            ),
      );

      if (productInCart.maGioHang > 0) {
        // Cập nhật số lượng nếu sản phẩm đã có trong giỏ hàng
        final updatedItem = GioHang(
          maGioHang: productInCart.maGioHang,
          maNguoiDung: maNguoiDung,
          maMonAn: widget.monAn.maMonAn,
          soLuong: productInCart.soLuong + soLuong,
          ngayThem: DateTime.now(),
          maMonAnNavigation: productInCart.maMonAnNavigation,
          maNguoiDungNavigation: productInCart.maNguoiDungNavigation,
        );

        await apiGioHang.updateGioHang(productInCart.maGioHang, updatedItem);
      } else {
        // Thêm mới nếu chưa có
        final newItem = GioHang(
          maGioHang: 0, // Giá trị sẽ được tạo tự động bởi API
          maNguoiDung: maNguoiDung,
          maMonAn: widget.monAn.maMonAn,
          soLuong: soLuong,
          ngayThem: DateTime.now(),
          maMonAnNavigation: null,
          maNguoiDungNavigation: null,
        );

        await apiGioHang.createGioHang(newItem);
      }

      if (!mounted) return;

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm ${widget.monAn.tenMonAn} vào giỏ hàng'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'XEM GIỎ HÀNG',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, GioHangPage.routeName);
            },
          ),
        ),
      );

      // Reset số lượng
      setState(() {
        soLuong = 1;
      });
    } catch (e) {
      // Hiển thị thông báo lỗi
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      // Kết thúc trạng thái loading
      setState(() {
        isAddingToCart = false;
      });
    }
  }
}
