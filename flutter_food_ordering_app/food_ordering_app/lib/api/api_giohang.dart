import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/GioHang.dart';

class ApiGioHang {
  final String baseUri = "http://10.0.2.2:5000/api/GioHang";

  // Lấy toàn bộ danh sách giỏ hàng
  Future<List<GioHang>> getGioHangData() async {
    try {
      final response = await http.get(Uri.parse(baseUri));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => GioHang.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi khi tải giỏ hàng: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi: $e');
      return [];
    }
  }

  // Lấy giỏ hàng theo ID
  Future<GioHang?> getGioHangById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUri/$id'));
      if (response.statusCode == 200) {
        return GioHang.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Lỗi khi lấy giỏ hàng ID $id: $e');
    }
    return null;
  }

  // Thêm giỏ hàng mới
  Future<http.Response> createGioHang(GioHang gioHang) async {
    try {
      print('DEBUG: URL gọi API: $baseUri');
      print('DEBUG: Dữ liệu gửi đi: ${jsonEncode(gioHang.toPostJson())}');

      final response = await http.post(
        Uri.parse(baseUri),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(gioHang.toPostJson()),
      );

      print(
        'DEBUG: Kết quả từ server: ${response.statusCode} - ${response.body}',
      );
      return response;
    } catch (e) {
      print('ERROR: Lỗi khi thêm giỏ hàng: $e');
      rethrow;
    }
  }

  // Cập nhật giỏ hàng
  Future<http.Response> updateGioHang(int id, GioHang gioHang) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUri/$id'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(gioHang.toJson()),
      );
      return response;
    } catch (e) {
      print('Lỗi khi cập nhật giỏ hàng: $e');
      rethrow;
    }
  }

  // Xoá giỏ hàng
  Future<http.Response> deleteGioHang(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUri/$id'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
      return response;
    } catch (e) {
      print('Lỗi khi xoá giỏ hàng: $e');
      rethrow;
    }
  }

  // Lấy giỏ hàng theo mã người dùng
  Future<List<GioHang>> getGioHangByNguoiDung(int maNguoiDung) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUri/nguoidung/$maNguoiDung'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => GioHang.fromJson(e)).toList();
      } else {
        throw Exception(
          'Lỗi khi tải giỏ hàng người dùng: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Lỗi: $e');
      return [];
    }
  }
}
