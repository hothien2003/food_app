import 'dart:convert';
// ignore: unused_import
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:food_ordering_app/models/DonHang.dart';
// import 'package:food_ordering_app/models/ChiTietDonHang.dart';

class ApiDonHang {
  final String baseUri = "http://10.0.2.2:5000/api/DonHang";

  // Lấy toàn bộ danh sách đơn hàng
  Future<List<DonHang>> getDonHangData() async {
    try {
      final response = await http.get(Uri.parse(baseUri));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => DonHang.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi khi tải đơn hàng: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  // Lấy đơn hàng theo ID
  Future<DonHang?> getDonHangById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUri/$id'));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final jsonData = jsonDecode(responseBody);

        // Đảm bảo các trường navigation có dữ liệu hợp lệ
        if (jsonData is Map) {
          // Chuyển đổi sang Map<String, dynamic> nếu cần
          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(
            jsonData,
          );

          if (jsonMap['maNhaHangNavigation'] == null) {
            jsonMap['maNhaHangNavigation'] = {}; // Thay null bằng object rỗng
          }

          if (jsonMap['maNguoiDungNavigation'] == null) {
            jsonMap['maNguoiDungNavigation'] = {}; // Thay null bằng object rỗng
          }

          if (jsonMap['chiTietDonHangs'] == null) {
            jsonMap['chiTietDonHangs'] = []; // Thay null bằng array rỗng
          } else if (jsonMap['chiTietDonHangs'] is List) {
            // Xử lý từng chi tiết đơn hàng
            List<dynamic> chiTietList = jsonMap['chiTietDonHangs'];
            for (int i = 0; i < chiTietList.length; i++) {
              if (chiTietList[i] != null &&
                  chiTietList[i]['maMonAnNavigation'] == null) {
                chiTietList[i]['maMonAnNavigation'] = {};
              }
            }
          }

          if (jsonMap['thanhToans'] == null) {
            jsonMap['thanhToans'] = []; // Thay null bằng array rỗng
          }

          try {
            final donHang = DonHang.fromJson(jsonMap);
            return donHang;
          } catch (parseError) {
            return null;
          }
        }
      }
    } catch (e) {
      // Xử lý lỗi
    }
    return null;
  }

  // Tạo đơn hàng mới từ giỏ hàng
  Future<http.Response> createDonHangFromGioHang({
    required int maNguoiDung,
    required int maNhaHang,
    required double tongTien,
    required List<Map<String, dynamic>> chiTietDonHang,
    String? diaChiGiaoHang,
    String? soDienThoai,
    String? ghiChu,
    String phuongThucThanhToan = 'Offline',
  }) async {
    try {
      // Xử lý chi tiết đơn hàng để đảm bảo giá trị số chính xác và không có null
      final List<Map<String, dynamic>> processedChiTietDonHang = [];

      for (var item in chiTietDonHang) {
        if (item['maMonAn'] != null && item['soLuong'] != null) {
          processedChiTietDonHang.add({
            'maMonAn': item['maMonAn'],
            'soLuong': item['soLuong'],
            'gia': double.parse((item['gia'] ?? 0).toString()),
          });
        }
      }

      // Tạo dữ liệu đơn hàng
      final donHangData = {
        'maNguoiDung': maNguoiDung,
        'maNhaHang': maNhaHang,
        'ngayDatHang': DateTime.now().toIso8601String(),
        'tongTien': double.parse(tongTien.toString()),
        'trangThai': 'Đang xử lý',
        'diaChiGiaoHang': diaChiGiaoHang,
        'soDienThoai': soDienThoai,
        'ghiChu': ghiChu,
        'phuongThucThanhToan': phuongThucThanhToan,
        'chiTietDonHangs': processedChiTietDonHang,
      };

      final response = await http.post(
        Uri.parse(baseUri),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(donHangData),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật trạng thái đơn hàng - Phương thức cũ
  Future<http.Response> updateTrangThaiDonHang(int id, String trangThai) async {
    try {
      // Lấy đơn hàng hiện tại
      final donHang = await getDonHangById(id);
      if (donHang == null) {
        throw Exception('Không tìm thấy đơn hàng với ID $id');
      }

      // Tạo bản sao mới với trạng thái cập nhật
      final updateData = {
        'maDonHang': donHang.maDonHang,
        'maNguoiDung': donHang.maNguoiDung,
        'maNhaHang': donHang.maNhaHang,
        'ngayDatHang': donHang.ngayDatHang?.toIso8601String(),
        'tongTien': donHang.tongTien,
        'trangThai': trangThai,
        'diaChiGiaoHang': donHang.diaChiGiaoHang,
        'soDienThoai': donHang.soDienThoai,
        'ghiChu': donHang.ghiChu,
      };

      final response = await http.put(
        Uri.parse('$baseUri/$id'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(updateData),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<http.Response> capNhatTrangThaiDonHang(
    int id,
    String trangThai,
  ) async {
    try {
      if (trangThai != "Đang xử lý" &&
          trangThai != "Hoàn thành" &&
          trangThai != "Đã hủy") {
        throw Exception(
          'Trạng thái không hợp lệ. Các trạng thái hợp lệ: "Đang xử lý", "Hoàn thành", "Đã hủy"',
        );
      }

      final response = await http.put(
        Uri.parse('$baseUri/$id/TrangThai/$trangThai'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode != 204) {
        throw Exception(
          'Lỗi khi cập nhật trạng thái đơn hàng: ${response.statusCode}',
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Lấy đơn hàng theo mã người dùng
  Future<List<DonHang>> getDonHangByNguoiDung(int maNguoiDung) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUri/nguoidung/$maNguoiDung'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        List<DonHang> donHangs = [];

        for (var item in jsonData) {
          try {
            // Kiểm tra và xử lý các trường JSON null trước khi tạo đối tượng DonHang
            if (item is Map<String, dynamic>) {
              // Đảm bảo các trường navigation có dữ liệu hợp lệ
              if (item['maNhaHangNavigation'] == null) {
                item['maNhaHangNavigation'] = {}; // Thay null bằng object rỗng
              }

              if (item['maNguoiDungNavigation'] == null) {
                item['maNguoiDungNavigation'] =
                    {}; // Thay null bằng object rỗng
              }

              if (item['chiTietDonHangs'] == null) {
                item['chiTietDonHangs'] = []; // Thay null bằng array rỗng
              } else if (item['chiTietDonHangs'] is List) {
                // Xử lý từng chi tiết đơn hàng
                List<dynamic> chiTietList = item['chiTietDonHangs'];
                for (int i = 0; i < chiTietList.length; i++) {
                  if (chiTietList[i] != null &&
                      chiTietList[i]['maMonAnNavigation'] == null) {
                    chiTietList[i]['maMonAnNavigation'] = {};
                  }
                }
              }

              if (item['thanhToans'] == null) {
                item['thanhToans'] = []; // Thay null bằng array rỗng
              }

              donHangs.add(DonHang.fromJson(item));
            }
          } catch (e) {
            // Bỏ qua đơn hàng lỗi
          }
        }
        return donHangs;
      }
      return [];
    } catch (e) {
      // Xử lý lỗi trong im lặng
      return [];
    }
  }

  // Lấy đơn hàng theo mã người dùng và trạng thái
  Future<List<DonHang>> getDonHangByTrangThai(
    int maNguoiDung,
    String trangThai,
  ) async {
    List<DonHang> donHangs = [];

    try {
      // Kiểm tra trạng thái hợp lệ
      if (trangThai != "Đang xử lý" &&
          trangThai != "Hoàn thành" &&
          trangThai != "Đã hủy") {
        return [];
      }

      final url = '$baseUri/nguoidung/$maNguoiDung/trangthai/$trangThai';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseBody = response.body;

        if (responseBody.isEmpty || responseBody == "[]") {
          return [];
        }

        final List<dynamic> jsonData = jsonDecode(responseBody);

        for (var item in jsonData) {
          try {
            // Kiểm tra và xử lý các trường null trước khi tạo đối tượng DonHang
            if (item is Map) {
              // Đảm bảo các thông tin liên quan có dữ liệu hợp lệ
              if (item['maNhaHangNavigation'] == null) {
                item['maNhaHangNavigation'] = {}; // Thay null bằng object rỗng
              }

              if (item['maNguoiDungNavigation'] == null) {
                item['maNguoiDungNavigation'] =
                    {}; // Thay null bằng object rỗng
              }

              if (item['chiTietDonHangs'] == null) {
                item['chiTietDonHangs'] = []; // Thay null bằng array rỗng
              } else if (item['chiTietDonHangs'] is List) {
                // Xử lý từng chi tiết đơn hàng
                List<dynamic> chiTietList = item['chiTietDonHangs'];
                for (int i = 0; i < chiTietList.length; i++) {
                  if (chiTietList[i] != null &&
                      chiTietList[i]['maMonAnNavigation'] == null) {
                    chiTietList[i]['maMonAnNavigation'] = {};
                  }
                }
              }

              if (item['thanhToans'] == null) {
                item['thanhToans'] = []; // Thay null bằng array rỗng
              }

              // Chuyển đổi sang Map<String, dynamic>
              final Map<String, dynamic> itemMap = Map<String, dynamic>.from(
                item,
              );
              DonHang donHang = DonHang.fromJson(itemMap);
              donHangs.add(donHang);
            }
          } catch (e) {
            // Bỏ qua đơn hàng lỗi
          }
        }
        return donHangs;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
