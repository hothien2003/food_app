import 'dart:convert';
import 'dart:io' show Platform;
import 'package:food_ordering_app/models/NguoiDung.dart';
import 'package:http/http.dart' as http;

class ApiNguoiDung {
  // Để chạy trên thiết bị thật Android, thay 10.0.2.2 bằng IP máy tính của bạn
  // Ví dụ: "http://192.168.1.100:5000"
  // Để tìm IP máy tính: chạy lệnh "ipconfig" trên Windows và tìm IPv4 Address
  static const String? customBaseUrl = null; // Thay null bằng base URL nếu cần (ví dụ: "http://192.168.1.100:5000")
  
  String get baseUri {
    // Nếu có custom URL, sử dụng nó
    if (customBaseUrl != null) {
      return "$customBaseUrl/api/NguoiDung";
    }
    
    if (Platform.isAndroid) {
      // Sử dụng 10.0.2.2 cho máy ảo Android (emulator)
      // Nếu chạy trên thiết bị thật, đặt customBaseUrl ở trên
      return "http://10.0.2.2:5000/api/NguoiDung";
    } else {
      // Sử dụng localhost cho Windows và các nền tảng khác
      return "http://localhost:5000/api/NguoiDung";
    }
  }

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
      } else {
        // Nếu status code không thành công, throw exception
        throw Exception('Lỗi kết nối API: ${response.statusCode}');
      }
    } catch (e) {
      // Log lỗi để debug
      print('Lỗi khi lấy dữ liệu người dùng: $e');
      // Throw exception thay vì trả về list rỗng
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và đảm bảo server đang chạy.');
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
