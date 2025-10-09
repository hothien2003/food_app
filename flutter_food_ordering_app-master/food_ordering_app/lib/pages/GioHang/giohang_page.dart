import 'package:flutter/material.dart';
import 'package:food_ordering_app/models/GioHang.dart';
import 'package:food_ordering_app/api/api_giohang.dart';
import 'package:food_ordering_app/utils/shared_preferences_helper.dart';
import 'package:food_ordering_app/utils/image_util.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:intl/intl.dart';
import 'package:food_ordering_app/pages/ThanhToan/thanhtoan_page.dart';

class GioHangPage extends StatefulWidget {
  static const routeName = "/gioHangPage";
  const GioHangPage({super.key});

  @override
  State<GioHangPage> createState() => _GioHangPageState();
}

class _GioHangPageState extends State<GioHangPage> {
  List<GioHang> gioHangList = [];
  bool isLoading = true;
  final String baseImageUrl = "http://10.0.2.2:5000/";

  @override
  void initState() {
    super.initState();
    dataGioHang();
  }

  // Lấy giỏ hàng theo người dùng đăng nhập
  Future<void> dataGioHang() async {
    final maNguoiDung =
        await layMaNguoiDungDangNhap(); // Lấy mã người dùng từ SharedPreferences
    if (maNguoiDung == null) {
      setState(() {
        isLoading = false;
      });
      print('Chưa đăng nhập');
      return;
    }

    final api = ApiGioHang();
    final data = await api.getGioHangByNguoiDung(
      maNguoiDung,
    ); // Gọi API với mã người dùng
    setState(() {
      gioHangList = data;
      isLoading = false;
    });
  }

  // Hàm tính tổng tiền giỏ hàng
  double tinhTongTien() {
    return gioHangList.fold(
      0,
      (sum, item) => sum + item.soLuong * item.maMonAnNavigation!.gia,
    );
  }

  // Cập nhật số lượng món ăn
  Future<void> updateQuantity(GioHang item, int newQuantity) async {
    if (newQuantity <= 0) {
      // Nếu số lượng = 0, xóa món ăn khỏi giỏ hàng
      await deleteItem(item.maGioHang);
      return;
    }

    final updatedItem = GioHang(
      maGioHang: item.maGioHang,
      maNguoiDung: item.maNguoiDung,
      maMonAn: item.maMonAn,
      soLuong: newQuantity,
      ngayThem: item.ngayThem,
      maMonAnNavigation: item.maMonAnNavigation,
      maNguoiDungNavigation: item.maNguoiDungNavigation,
    );

    try {
      final api = ApiGioHang();
      await api.updateGioHang(item.maGioHang, updatedItem);
      dataGioHang(); // Cập nhật lại dữ liệu
    } catch (e) {
      print('Lỗi khi cập nhật số lượng: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Giỏ hàng của tôi',
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColor.primary),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColor.orange),
              )
              : gioHangList.isEmpty
              ? _buildEmptyCart()
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: gioHangList.length,
                      itemBuilder: (context, index) {
                        final item = gioHangList[index];
                        final monAn = item.maMonAnNavigation;

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Hình ảnh món ăn
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child:
                                      monAn!.urlHinhAnh != null
                                          ? Image.network(
                                            getFullImageUrl(
                                              baseImageUrl,
                                              monAn.urlHinhAnh,
                                            ),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              print('Lỗi tải hình ảnh: $error');
                                              return Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 30,
                                                ),
                                              );
                                            },
                                          )
                                          : Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.fastfood,
                                              size: 30,
                                            ),
                                          ),
                                ),
                                const SizedBox(width: 16),
                                // Thông tin món ăn
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        monAn.tenMonAn,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'vi_VN',
                                          symbol: '₫',
                                          decimalDigits: 0,
                                        ).format(monAn.gia),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.orange,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Nút tăng/giảm số lượng
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey[200],
                                            ),
                                            child: Row(
                                              children: [
                                                InkWell(
                                                  onTap:
                                                      () => updateQuantity(
                                                        item,
                                                        item.soLuong - 1,
                                                      ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: const Icon(
                                                      Icons.remove,
                                                      size: 18,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 4,
                                                      ),
                                                  child: Text(
                                                    '${item.soLuong}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap:
                                                      () => updateQuantity(
                                                        item,
                                                        item.soLuong + 1,
                                                      ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: const Icon(
                                                      Icons.add,
                                                      size: 18,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          // Nút xóa
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () =>
                                                    deleteItem(item.maGioHang),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildCheckoutSection(),
                ],
              ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Giỏ hàng của bạn trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hãy thêm món ăn yêu thích vào giỏ hàng',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.orange,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Tiếp tục mua sắm',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  NumberFormat.currency(
                    locale: 'vi_VN',
                    symbol: '₫',
                    decimalDigits: 0,
                  ).format(tinhTongTien()),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    gioHangList.isEmpty
                        ? null
                        : () {
                          // Chuyển đến trang thanh toán với danh sách giỏ hàng và tổng tiền
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ThanhToanPage(
                                    gioHangList: gioHangList,
                                    tongTien: tinhTongTien(),
                                  ),
                            ),
                          ).then(
                            (_) => dataGioHang(),
                          ); // Tải lại dữ liệu khi trở về
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: const Text(
                  'Thanh toán',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.placeholderBg,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xóa món trong giỏ hàng
  Future<void> deleteItem(int id) async {
    final api = ApiGioHang();
    await api.deleteGioHang(id);
    dataGioHang(); // Cập nhật lại dữ liệu
  }
}
