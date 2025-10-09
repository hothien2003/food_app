import 'dart:convert';
import 'package:food_ordering_app/models/NhaHang.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class ApiNhaHang {
  String get baseUri {
    if (Platform.isAndroid) {
      // Sử dụng 10.0.2.2 cho máy ảo Android
      return "http://10.0.2.2:5000/api/NhaHang";
    } else {
      // Sử dụng localhost cho Windows
      return "http://localhost:5000/api/NhaHang";
    }
  }

  Future<List<NhaHang>> getNhaHangData() async {
    List<NhaHang> data = [];

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
        data = jsonData.map((json) => NhaHang.fromJson(json)).toList();
      }
    } catch (e) {
      return data;
    }
    return data;
  }

  Future<http.Response> updateNhaHang({
    required int maNhaHang,
    required NhaHang nhaHang,
  }) async {
    final uri = Uri.parse("$baseUri/$maNhaHang");
    late http.Response response;

    try {
      response = await http.put(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(nhaHang.toJson()),
      );
    } catch (e) {
      return response;
    }

    return response;
  }

  // Phương thức thêm nhà hàng
  Future<http.Response> createNhaHang({required NhaHang nhaHang}) async {
    final uri = Uri.parse(baseUri);
    late http.Response response;
    try {
      response = await http.post(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(nhaHang.toJson()),
      );
    } catch (e) {
      return response;
    }
    return response;
  }

  // Delete
  Future<http.Response> deleteNhaHang({required int maNhaHang}) async {
    final uri = Uri.parse("$baseUri/$maNhaHang");
    late http.Response response;
    try {
      response = await http.delete(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
      );
    } catch (e) {
      return response;
    }
    return response;
  }
}
