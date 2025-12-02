import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_donhang.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/DonHang.dart';
import 'package:food_ordering_app/pages/DonHang/chitiet_donhang_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonHangPage extends StatefulWidget {
  static const routeName = "/donHangPage";
  const DonHangPage({super.key});

  @override
  State<DonHangPage> createState() => _DonHangPageState();
}

class _DonHangPageState extends State<DonHangPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DonHang> donHangList = [];
  bool isLoading = false;
  int? maNguoiDung;
  String currentTab = "Đang xử lý";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadUserInfo();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return; // Tránh gọi API nhiều lần trong quá trình chuyển tab
    }
    fetchDonHangByTrangThai();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserID = prefs.getInt('maNguoiDung');

    if (storedUserID != null) {
      if (mounted) {
        setState(() {
          maNguoiDung = storedUserID;
        });
        // Sau khi có ID người dùng, tải đơn hàng
        fetchDonHangByTrangThai();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để xem đơn hàng'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> fetchDonHangByTrangThai() async {
    if (maNguoiDung == null) {
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
        donHangList = [];
      });
    }

    try {
      // Xác định trạng thái hiện tại theo tab
      String trangThai;
      switch (_tabController.index) {
        case 0:
          trangThai = "Đang xử lý";
          break;
        case 1:
          trangThai = "Hoàn thành";
          break;
        case 2:
          trangThai = "Đã hủy";
          break;
        default:
          trangThai = "Đang xử lý";
      }

      ApiDonHang apiDonHang = ApiDonHang();
      final orders = await apiDonHang.getDonHangByTrangThai(
        maNguoiDung!,
        trangThai,
      );

      if (mounted) {
        setState(() {
          donHangList = orders;
          currentTab = trangThai;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải danh sách đơn hàng'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Đang xử lý':
        return Colors.blue;
      case 'Hoàn thành':
        return Colors.green.shade700;
      case 'Đã hủy':
        return Colors.red;
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
          'Đơn hàng của tôi',
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColor.orange,
          labelColor: AppColor.orange,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Hoàn thành'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: SafeArea(
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColor.orange),
                )
                : TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab cho "Đang xử lý"
                    _buildOrderList(donHangList),
                    // Tab cho "Hoàn thành"
                    _buildOrderList(donHangList),
                    // Tab cho "Đã hủy"
                    _buildOrderList(donHangList),
                  ],
                ),
      ),
    );
  }

  Widget _buildOrderList(List<DonHang> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có đơn hàng nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchDonHangByTrangThai,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Tải lại',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchDonHangByTrangThai,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final donHang = orders[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // Chuyển sang trang chi tiết đơn hàng
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ChiTietDonHangPage(maDonHang: donHang.maDonHang),
                  ),
                ).then((_) => fetchDonHangByTrangThai());
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đơn hàng #${donHang.maDonHang}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(
                              donHang.trangThai,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            donHang.trangThai,
                            style: TextStyle(
                              color: getStatusColor(donHang.trangThai),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (donHang.nhaHang != null &&
                        donHang.nhaHang?.tenNhaHang != null &&
                        donHang.nhaHang!.tenNhaHang.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.store, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              donHang.nhaHang!.tenNhaHang,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          donHang.ngayDatHang != null
                              ? DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(donHang.ngayDatHang!)
                              : 'Không có thông tin',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${donHang.chiTietDonHangs?.length ?? 0} món',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền:',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: '₫',
                            decimalDigits: 0,
                          ).format(donHang.tongTien),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColor.orange,
                          ),
                        ),
                      ],
                    ),
                    if (donHang.trangThai == "Đang xử lý") ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              _showCancelOrderDialog(donHang.maDonHang);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Hủy đơn'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCancelOrderDialog(int maDonHang) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hủy đơn hàng'),
            content: const Text(
              'Bạn có chắc chắn muốn hủy đơn hàng này không?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Không'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _cancelOrder(maDonHang);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hủy đơn'),
              ),
            ],
          ),
    );
  }

  Future<void> _cancelOrder(int maDonHang) async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiDonHang = ApiDonHang();
      await apiDonHang.capNhatTrangThaiDonHang(maDonHang, "Đã hủy");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy đơn hàng thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Tải lại danh sách đơn hàng
      fetchDonHangByTrangThai();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi hủy đơn hàng'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }
}
