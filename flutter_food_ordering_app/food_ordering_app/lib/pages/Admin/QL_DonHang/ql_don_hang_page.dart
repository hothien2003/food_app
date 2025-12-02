import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_donhang.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/DonHang.dart';
import 'package:food_ordering_app/pages/DonHang/chitiet_donhang_page.dart';
import 'package:intl/intl.dart';

class QLDonHangPage extends StatefulWidget {
  static const routeName = "/qlDonHangPage";
  const QLDonHangPage({super.key});

  @override
  State<QLDonHangPage> createState() => _QLDonHangPageState();
}

class _QLDonHangPageState extends State<QLDonHangPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DonHang> donHangList = [];
  List<DonHang> filteredDonHangList = [];
  bool isLoading = false;
  String currentTab = "Tất cả";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadAllDonHang();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }
    _filterDonHangByTab();
  }

  Future<void> _loadAllDonHang() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      ApiDonHang apiDonHang = ApiDonHang();
      final orders = await apiDonHang.getDonHangData();

      if (mounted) {
        setState(() {
          donHangList = orders;
          _filterDonHangByTab();
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
            content: Text('Lỗi khi tải danh sách đơn hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterDonHangByTab() {
    String trangThai;
    switch (_tabController.index) {
      case 0:
        trangThai = "Tất cả";
        break;
      case 1:
        trangThai = "Đang xử lý";
        break;
      case 2:
        trangThai = "Hoàn thành";
        break;
      case 3:
        trangThai = "Đã hủy";
        break;
      default:
        trangThai = "Tất cả";
    }

    setState(() {
      currentTab = trangThai;
      if (trangThai == "Tất cả") {
        filteredDonHangList = List.from(donHangList);
      } else {
        filteredDonHangList =
            donHangList.where((dh) => dh.trangThai == trangThai).toList();
      }
      _applySearch();
    });
  }

  void _applySearch() {
    String searchText = _searchController.text.toLowerCase().trim();
    if (searchText.isEmpty) {
      return;
    }

    setState(() {
      filteredDonHangList =
          filteredDonHangList.where((dh) {
            return dh.maDonHang.toString().contains(searchText) ||
                (dh.nguoiDung?.hoTen?.toLowerCase().contains(searchText) ??
                    false) ||
                (dh.nhaHang?.tenNhaHang.toLowerCase().contains(searchText) ??
                    false);
          }).toList();
    });
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

  int _getTotalOrdersByStatus(String status) {
    if (status == "Tất cả") {
      return donHangList.length;
    }
    return donHangList.where((dh) => dh.trangThai == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Quản lý đơn hàng',
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColor.primary),
            onPressed: _loadAllDonHang,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm đơn hàng...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterDonHangByTab();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    _filterDonHangByTab();
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColor.orange,
                labelColor: AppColor.orange,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                tabs: [
                  Tab(
                    child: Row(
                      children: [
                        const Text('Tất cả'),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_getTotalOrdersByStatus("Tất cả")}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Text('Đang xử lý'),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_getTotalOrdersByStatus("Đang xử lý")}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Text('Hoàn thành'),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_getTotalOrdersByStatus("Hoàn thành")}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Text('Đã hủy'),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_getTotalOrdersByStatus("Đã hủy")}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                    _buildOrderList(filteredDonHangList),
                    _buildOrderList(filteredDonHangList),
                    _buildOrderList(filteredDonHangList),
                    _buildOrderList(filteredDonHangList),
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
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllDonHang,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ChiTietDonHangPage(maDonHang: donHang.maDonHang),
                  ),
                ).then((_) => _loadAllDonHang());
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đơn hàng #${donHang.maDonHang}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (donHang.nguoiDung != null &&
                                  donHang.nguoiDung?.hoTen != null)
                                Text(
                                  'KH: ${donHang.nguoiDung!.hoTen}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
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
                        donHang.nhaHang?.tenNhaHang != null) ...[
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
                    if (donHang.diaChiGiaoHang != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              donHang.diaChiGiaoHang!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (donHang.soDienThoai != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            donHang.soDienThoai!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
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
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              _showCompleteOrderDialog(donHang.maDonHang);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              'Hoàn thành',
                              style: TextStyle(color: Colors.white),
                            ),
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
            content: Text(
              'Bạn có chắc chắn muốn hủy đơn hàng #$maDonHang không?',
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
                  await _updateOrderStatus(maDonHang, "Đã hủy");
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hủy đơn'),
              ),
            ],
          ),
    );
  }

  void _showCompleteOrderDialog(int maDonHang) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hoàn thành đơn hàng'),
            content: Text('Xác nhận đơn hàng #$maDonHang đã hoàn thành?'),
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
                  await _updateOrderStatus(maDonHang, "Hoàn thành");
                },
                style: TextButton.styleFrom(foregroundColor: Colors.green),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
  }

  Future<void> _updateOrderStatus(int maDonHang, String trangThai) async {
    setState(() {
      isLoading = true;
    });

    try {
      final apiDonHang = ApiDonHang();
      await apiDonHang.capNhatTrangThaiDonHang(maDonHang, trangThai);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật trạng thái đơn hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadAllDonHang();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật trạng thái: $e'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
