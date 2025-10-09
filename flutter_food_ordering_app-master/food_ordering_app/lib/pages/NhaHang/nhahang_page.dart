import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_nhahang.dart';
import 'package:food_ordering_app/models/NhaHang.dart';
import 'package:food_ordering_app/pages/NhaHang/update_nhahang_page.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/widgets/searchBar.dart' as Custom;

class NhaHangPage extends StatefulWidget {
  static const routeName = "/nhaHangPage";
  const NhaHangPage({super.key});

  @override
  State<NhaHangPage> createState() => _NhaHangPageState();
}

class _NhaHangPageState extends State<NhaHangPage> {
  ApiNhaHang apiNhaHang = ApiNhaHang();
  List<NhaHang> data = [];
  List<NhaHang> filteredData = [];

  void getData() async {
    data = await apiNhaHang.getNhaHangData();
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
            data.where((nhaHang) {
              return nhaHang.tenNhaHang.toLowerCase().contains(
                    keyword.toLowerCase(),
                  ) ||
                  nhaHang.diaChi!.toLowerCase().contains(keyword.toLowerCase());
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
                            "Danh sách nhà hàng",
                            style: Helper.getTheme(context).headlineMedium,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Custom.SearchBar(
                    title: "Tìm kiếm nhà hàng",
                    onChanged: _filterSearch,
                  ),
                  const SizedBox(height: 10),

                  // Danh sách người dùng
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final nhaHang = filteredData[index];
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      UpdateNhaHangPage(nhaHang: nhaHang),
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
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(
                                Helper.getAssetName(
                                  "icons8-restaurant-48.png",
                                  "virtual",
                                ),
                              ),
                            ),
                            title: Text(
                              nhaHang.tenNhaHang,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(nhaHang.diaChi!),
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
      bottomNavigationBar: const CustomNavBar(home: true),
    );
  }
}
