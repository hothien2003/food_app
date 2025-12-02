import 'dart:convert';
import 'package:http/http.dart' as http;

class TheTinDung {
  final int? maThe;
  final int maNguoiDung;
  final String soThe;
  final String tenChuThe;
  final String thangHetHan;
  final String namHetHan;
  final String maBaoMat;
  final String loaiThe;
  final bool choPhepXoa;
  final DateTime? ngayThem;

  TheTinDung({
    this.maThe,
    required this.maNguoiDung,
    required this.soThe,
    required this.tenChuThe,
    required this.thangHetHan,
    required this.namHetHan,
    required this.maBaoMat,
    this.loaiThe = 'visa',
    this.choPhepXoa = true,
    this.ngayThem,
  });

  factory TheTinDung.fromJson(Map<String, dynamic> json) {
    return TheTinDung(
      maThe: json['maThe'],
      maNguoiDung: json['maNguoiDung'],
      soThe: json['soThe'],
      tenChuThe: json['tenChuThe'],
      thangHetHan: json['thangHetHan'],
      namHetHan: json['namHetHan'],
      maBaoMat: json['maBaoMat'] ?? '',
      loaiThe: json['loaiThe'] ?? 'visa',
      choPhepXoa: json['choPhepXoa'] ?? true,
      ngayThem:
          json['ngayThem'] != null ? DateTime.parse(json['ngayThem']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maNguoiDung': maNguoiDung,
      'soThe': soThe,
      'tenChuThe': tenChuThe,
      'thangHetHan': thangHetHan,
      'namHetHan': namHetHan,
      'maBaoMat': maBaoMat,
      'loaiThe': loaiThe,
      'choPhepXoa': choPhepXoa,
    };
  }
}

class ApiTheTinDung {
  final String baseUri = "http://10.0.2.2:5000/api/TheTinDung";

  // Lấy danh sách thẻ của người dùng
  Future<List<TheTinDung>> getTheByUserId(int maNguoiDung) async {
    try {
      final response = await http.get(Uri.parse('$baseUri/User/$maNguoiDung'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => TheTinDung.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi khi tải danh sách thẻ: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading cards: $e');
      return [];
    }
  }

  // Thêm thẻ mới
  Future<Map<String, dynamic>> addCard(TheTinDung card) async {
    try {
      final response = await http.post(
        Uri.parse(baseUri),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(card.toJson()),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Thêm thẻ thành công',
          'data': jsonDecode(response.body),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Lỗi khi thêm thẻ',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Xóa thẻ
  Future<Map<String, dynamic>> deleteCard(int maThe) async {
    try {
      final response = await http.delete(Uri.parse('$baseUri/$maThe'));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã xóa thẻ thành công'};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Lỗi khi xóa thẻ',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
