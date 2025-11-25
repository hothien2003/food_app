import 'dart:convert';
import 'dart:io' show Platform;
import 'package:food_ordering_app/models/DanhGium.dart';
import 'package:http/http.dart' as http;

class ApiDanhGia {
  static const String? customBaseUrl = null;

  String get baseUri {
    if (customBaseUrl != null) {
      return "$customBaseUrl/api/DanhGia";
    }

    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000/api/DanhGia";
    } else {
      return "http://localhost:5000/api/DanhGia";
    }
  }

  Future<List<DanhGium>> getDanhGiaData() async {
    List<DanhGium> data = [];
    final uri = Uri.parse(baseUri);

    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        data = jsonData.map((json) => DanhGium.fromJson(json)).toList();
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu đánh giá: $e');
    }

    return data;
  }

  Future<List<DanhGium>> getDanhGiaByNhaHang(int maNhaHang) async {
    List<DanhGium> data = [];
    final uri = Uri.parse("$baseUri/NhaHang/$maNhaHang");

    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        data = jsonData.map((json) => DanhGium.fromJson(json)).toList();
      }
    } catch (e) {
      print('Lỗi khi lấy đánh giá nhà hàng: $e');
    }

    return data;
  }

  Future<http.Response> createDanhGia({required DanhGium danhGia}) async {
    final uri = Uri.parse(baseUri);
    late http.Response response;

    try {
      response = await http.post(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(danhGia.toJson()),
      );
    } catch (e) {
      print('Lỗi khi tạo đánh giá: $e');
    }

    return response;
  }

  Future<http.Response> updateDanhGia({
    required int maDanhGia,
    required DanhGium danhGia,
  }) async {
    final uri = Uri.parse("$baseUri/$maDanhGia");
    late http.Response response;

    try {
      response = await http.put(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(danhGia.toJson()),
      );
    } catch (e) {
      print('Lỗi khi cập nhật đánh giá: $e');
    }

    return response;
  }

  Future<http.Response> deleteDanhGia({required int maDanhGia}) async {
    final uri = Uri.parse("$baseUri/$maDanhGia");
    late http.Response response;

    try {
      response = await http.delete(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
      );
    } catch (e) {
      print('Lỗi khi xóa đánh giá: $e');
    }

    return response;
  }
}
