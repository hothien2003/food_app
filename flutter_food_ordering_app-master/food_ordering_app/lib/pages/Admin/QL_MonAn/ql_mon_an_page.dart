import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_monan.dart';
import 'package:food_ordering_app/models/MonAn.dart';
import 'package:food_ordering_app/pages/Admin/QL_MonAn/update_monan_page.dart';
import 'package:food_ordering_app/pages/Admin/QL_MonAn/add_monan_page.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/utils/image_util.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/widgets/searchBar.dart' as Custom;

class QLMonAnPage extends StatefulWidget {
  static const routeName = "/QLMonAnPage";
  const QLMonAnPage({super.key});

  @override
  State<QLMonAnPage> createState() => _QLMonAnPageState();
}

class _QLMonAnPageState extends State<QLMonAnPage> {
  ApiMonAn apiMonAn = ApiMonAn();
  List<MonAn> data = [];
  List<MonAn> filteredData = [];

  void getData() async {
    data = await apiMonAn.getMonAnData();
    filteredData = data;
    setState(() {});
  }

  // Hàm tìm kiếm
  void _filterSearch(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        filteredData = data;
      } else {
        filteredData =
            data.where((monAn) {
              return monAn.tenMonAn.toLowerCase().contains(
                    keyword.toLowerCase(),
                  ) ||
                  monAn.gia.toString().contains(keyword.toLowerCase());
            }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: AppColor.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Danh sách món ăn",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                        ),
                        // Thêm nút thêm món ăn
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddMonAnPage(),
                              ),
                            );
                            if (result == true) {
                              getData();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColor.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Custom.SearchBar(
                    title: "Tìm kiếm món ăn",
                    onChanged: _filterSearch,
                  ),
                  const SizedBox(height: 10),

                  // Danh sách món
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final monAn = filteredData[index];
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => UpdateMonAnPage(monAn: monAn),
                            ),
                          );
                          if (result == true) {
                            getData();
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child:
                                    monAn.urlHinhAnh != null &&
                                            monAn.urlHinhAnh!.isNotEmpty
                                        ? Image.network(
                                          getFullImageUrl(
                                            baseImageUrl,
                                            monAn.urlHinhAnh,
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            print(
                                              'Lỗi tải hình ảnh: ${monAn.urlHinhAnh} - $error',
                                            );
                                            return Image.asset(
                                              Helper.getAssetName(
                                                "icons8-restaurant-48.png",
                                                "virtual",
                                              ),
                                              fit: BoxFit.cover,
                                            );
                                          },
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                color: AppColor.orange,
                                              ),
                                            );
                                          },
                                        )
                                        : Image.asset(
                                          Helper.getAssetName(
                                            "icons8-restaurant-48.png",
                                            "virtual",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),
                            title: Text(
                              monAn.tenMonAn,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(monAn.gia.toString()),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Thêm floating action button để thêm món ăn
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMonAnPage()),
          );
          if (result == true) {
            getData();
          }
        },
        backgroundColor: AppColor.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
