import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import '../models/MonAn.dart';

class ApiMonAn {
  String get baseUri {
    if (Platform.isAndroid) {
      // Sử dụng 10.0.2.2 cho máy ảo Android
      return "http://10.0.2.2:5000/api/MonAn";
    } else {
      // Sử dụng localhost cho Windows
      return "http://localhost:5000/api/MonAn";
    }
  }

  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // GET tất cả món ăn
  Future<List<MonAn>> getMonAnData() async {
    final uri = Uri.parse(baseUri);
    try {
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        print(response.body);
        return jsonData.map((json) => MonAn.fromJson(json)).toList();
      } else {
        print('Error fetching data: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching list of món ăn: $e');
    }
    return [];
  }

  // GET theo ID
  Future<MonAn?> getMonAnById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUri/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return MonAn.fromJson(json.decode(response.body));
      } else {
        print(
          'Error fetching món ăn by ID: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching món ăn by ID: $e');
    }
    return null;
  }

  // POST: Thêm món ăn mới
  Future<http.Response> createMonAn(MonAn monAn) async {
    try {
      final jsonData = monAn.toPostJson();
      print('Dữ liệu gửi đi: ${json.encode(jsonData)}');

      final response = await http.post(
        Uri.parse(baseUri),
        headers: _headers,
        body: json.encode(jsonData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response;
    } catch (e) {
      print('Error creating món ăn: $e');
      return http.Response('Connection error: $e', 500);
    }
  }

  // PUT: Cập nhật món ăn
  Future<http.Response> updateMonAn({
    required int maMonAn,
    required MonAn monAn,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUri/$maMonAn'),
        headers: _headers,
        body: jsonEncode(monAn.toPostJson()),
      );
      return response;
    } catch (e) {
      return http.Response('Connection error', 500);
    }
  }

  // DELETE: Xoá món ăn
  Future<http.Response> deleteMonAn({required int maMonAn}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUri/$maMonAn'),
        headers: _headers,
      );
      return response;
    } catch (e) {
      print('Error deleting món ăn: $e');
      return http.Response('Connection error', 500);
    }
  }
}
