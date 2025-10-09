import 'package:flutter/material.dart';
import 'package:food_ordering_app/pages/GioHang/giohang_page.dart';
import 'package:food_ordering_app/pages/MonAn/detail_monan_page.dart';
import 'package:intl/intl.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/MonAn.dart';
import 'package:food_ordering_app/api/api_monan.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/utils/image_util.dart';

class MonAnPage extends StatefulWidget {
  static const routeName = "/monAnPage";

  const MonAnPage({super.key});

  @override
  _MonAnPageState createState() => _MonAnPageState();
}

class _MonAnPageState extends State<MonAnPage> {
  final ApiMonAn apiMonAn = ApiMonAn();
  List<MonAn> monAnList = [];
  List<MonAn> filteredMonAnList = [];
  bool isLoading = true;
  final String baseImageUrl = "http://10.0.2.2:5000/";

  // Biến cho tìm kiếm và lọc
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  RangeValues _priceRange = RangeValues(0, 2000000); // Giá từ 0 đến 2 triệu
  double _minRating = 0; // Đánh giá tối thiểu
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    final data = await apiMonAn.getMonAnData();
    setState(() {
      monAnList = data;
      filteredMonAnList = data;
      isLoading = false;
    });
  }

  // Hàm áp dụng bộ lọc
  void applyFilters() {
    setState(() {
      filteredMonAnList =
          monAnList.where((monAn) {
            // Lọc theo tên
            final nameMatch =
                _searchText.isEmpty ||
                monAn.tenMonAn.toLowerCase().contains(
                  _searchText.toLowerCase(),
                );

            // Lọc theo khoảng giá
            final priceMatch =
                monAn.gia >= _priceRange.start && monAn.gia <= _priceRange.end;
            final rating =
                4.0;
            final ratingMatch = rating >= _minRating;

            return nameMatch && priceMatch && ratingMatch;
          }).toList();
    });
  }

  // Hàm xử lý tìm kiếm
  void _handleSearch(String query) {
    setState(() {
      _searchText = query;
      applyFilters();
    });
  }

  // Hàm reset các bộ lọc
  void _resetFilters() {
    setState(() {
      _searchText = "";
      _searchController.clear();
      _priceRange = RangeValues(0, 2000000);
      _minRating = 0;
      filteredMonAnList = monAnList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : monAnList.isEmpty
              ? const Center(child: Text('Không có món ăn nào.'))
              : SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColor.primary,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Món ăn",
                              style: Helper.getTheme(context).headlineMedium
                                  ?.copyWith(color: AppColor.primary),
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed(GioHangPage.routeName);
                            },
                            child: Image.asset(
                              Helper.getAssetName("cart.png", "virtual"),
                              width: 24,
                              height: 24,
                              color: AppColor.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nhà hàng
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const Text(
                        "Nhà hàng",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _RestaurantItem(
                            imagePath: Helper.getAssetName("kfc.jpeg", "real"),
                          ),
                          _RestaurantItem(
                            imagePath: Helper.getAssetName(
                              "pizza_hut.jpg",
                              "real",
                            ),
                          ),
                          _RestaurantItem(
                            imagePath: Helper.getAssetName(
                              "burger_king.jpg",
                              "real",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wallet, color: AppColor.orange),
                          const SizedBox(width: 10),
                          const Text(
                            'Top up your Coins',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward,
                            color: AppColor.orange,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Thanh tìm kiếm
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _handleSearch,
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm món ăn...',
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppColor.primary,
                                ),
                                suffixIcon:
                                    _searchText.isNotEmpty
                                        ? IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            _handleSearch('');
                                          },
                                        )
                                        : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Row với nút lọc
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isFilterVisible = !_isFilterVisible;
                                  });
                                },
                                icon: const Icon(Icons.filter_list, size: 20),
                                label: Text(
                                  'Bộ lọc',
                                  style: TextStyle(
                                    fontWeight:
                                        _isFilterVisible
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      _isFilterVisible
                                          ? AppColor.orange
                                          : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              if (_searchText.isNotEmpty ||
                                  _priceRange.start > 0 ||
                                  _priceRange.end < 2000000 ||
                                  _minRating > 0)
                                TextButton(
                                  onPressed: _resetFilters,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColor.primary,
                                  ),
                                  child: const Text('Xóa bộ lọc'),
                                ),
                            ],
                          ),

                          // Panel bộ lọc mở rộng
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: _isFilterVisible ? 180 : 0,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Lọc theo giá
                                  const Text(
                                    'Khoảng giá:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${NumberFormat.compact(locale: 'vi').format(_priceRange.start)}đ',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Expanded(
                                        child: RangeSlider(
                                          values: _priceRange,
                                          min: 0,
                                          max: 2000000,
                                          divisions: 20,
                                          activeColor: AppColor.orange,
                                          labels: RangeLabels(
                                            '${NumberFormat.compact(locale: 'vi').format(_priceRange.start)}đ',
                                            '${NumberFormat.compact(locale: 'vi').format(_priceRange.end)}đ',
                                          ),
                                          onChanged: (values) {
                                            setState(() {
                                              _priceRange = values;
                                              applyFilters();
                                            });
                                          },
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat.compact(locale: 'vi').format(_priceRange.end)}đ',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Lọc theo đánh giá
                                  const Text(
                                    'Đánh giá tối thiểu:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: List.generate(5, (index) {
                                      final rating = index + 1.0;
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _minRating = rating;
                                            applyFilters();
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                _minRating >= rating
                                                    ? AppColor.orange
                                                    : Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                rating.toString(),
                                                style: TextStyle(
                                                  color:
                                                      _minRating >= rating
                                                          ? Colors.white
                                                          : Colors.black87,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(
                                                Icons.star,
                                                size: 14,
                                                color:
                                                    _minRating >= rating
                                                        ? Colors.white
                                                        : Colors.amber,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Hiển thị số lượng kết quả tìm kiếm
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Danh sách món ăn',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${filteredMonAnList.length} món',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Danh sách món ăn
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredMonAnList.length,
                        itemBuilder: (context, index) {
                          final monAn = filteredMonAnList[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          DetailMonAnPage(monAn: monAn),
                                ),
                              );
                            },
                            child: _MonAnItem(
                              monAn: monAn,
                              baseImageUrl: baseImageUrl,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _RestaurantItem extends StatelessWidget {
  final String imagePath;

  const _RestaurantItem({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(backgroundImage: AssetImage(imagePath), radius: 40),
    );
  }
}

class _MonAnItem extends StatelessWidget {
  final MonAn monAn;
  final String baseImageUrl;

  const _MonAnItem({required this.monAn, required this.baseImageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                getFullImageUrl(baseImageUrl, monAn.urlHinhAnh),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    ),
                  );
                },
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monAn.moTa ?? 'Không có mô tả',
                    style: const TextStyle(fontSize: 14, color: AppColor.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          monAn.maNhaHangNavigation?.diaChi ??
                              'Không có địa chỉ',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColor.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(monAn.gia),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColor.orange,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.local_offer,
                              size: 14,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '20k',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}
