import 'dart:convert';
import 'package:food_ordering_app/models/NguoiDung.dart';
import 'package:http/http.dart' as http;

class ApiNguoiDung {
  final String baseUri = "http://10.0.2.2:5000/api/NguoiDung";
  // final String baseUri = 'http://localhost:5000/api/NguoiDung';

  Future<List<NguoiDung>> getNguoiDungData() async {
    List<NguoiDung> data = [];

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
        data = jsonData.map((json) => NguoiDung.fromJson(json)).toList();
      }
    } catch (e) {
      return data;
    }
    return data;
  }

  // Lấy thông tin người dùng theo ID
  Future<NguoiDung?> getNguoiDungById(int maNguoiDung) async {
    final uri = Uri.parse("$baseUri/$maNguoiDung");
    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final dynamic jsonData = json.decode(response.body);
        return NguoiDung.fromJson(jsonData);
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
    return null;
  }

  Future<http.Response> updateNguoiDung({
    required int maNguoiDung,
    required NguoiDung nguoiDung,
  }) async {
    final uri = Uri.parse("$baseUri/$maNguoiDung");
    late http.Response response;

    try {
      response = await http.put(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(nguoiDung.toJson()),
      );
    } catch (e) {
      return response;
    }

    return response;
  }

  // Phương thức đăng ký người dùng mới
  Future<http.Response> createNguoiDung({required NguoiDung nguoiDung}) async {
    final uri = Uri.parse(baseUri);
    late http.Response response;
    try {
      response = await http.post(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body: json.encode(nguoiDung.toJson()),
      );
    } catch (e) {
      return response;
    }
    return response;
  }

  // Delete
  Future<http.Response> deleteNguoiDung({required int maNguoiDung}) async {
    final uri = Uri.parse("$baseUri/$maNguoiDung");
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
