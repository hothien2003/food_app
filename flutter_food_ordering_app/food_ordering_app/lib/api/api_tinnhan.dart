import 'dart:convert';
import 'package:http/http.dart' as http;

class TinNhan {
  final int? maTinNhan;
  final int? maNguoiDung;
  final String tieuDe;
  final String noiDung;
  final DateTime ngayGui;
  final bool daDoc;
  final String loaiTinNhan;

  TinNhan({
    this.maTinNhan,
    this.maNguoiDung,
    required this.tieuDe,
    required this.noiDung,
    required this.ngayGui,
    this.daDoc = false,
    this.loaiTinNhan = 'promotion',
  });

  factory TinNhan.fromJson(Map<String, dynamic> json) {
    return TinNhan(
      maTinNhan: json['maTinNhan'],
      maNguoiDung: json['maNguoiDung'],
      tieuDe: json['tieuDe'],
      noiDung: json['noiDung'],
      ngayGui: DateTime.parse(json['ngayGui']),
      daDoc: json['daDoc'] ?? false,
      loaiTinNhan: json['loaiTinNhan'] ?? 'promotion',
    );
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(ngayGui);

    if (difference.inDays > 0) {
      return '${ngayGui.day} Tháng ${ngayGui.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}

class ApiTinNhan {
  final String baseUri = "http://10.0.2.2:5000/api/TinNhan";

  // Lấy tin nhắn của người dùng (bao gồm tin nhắn công khai)
  Future<List<TinNhan>> getTinNhanByUserId(int maNguoiDung) async {
    try {
      final response = await http.get(Uri.parse('$baseUri/User/$maNguoiDung'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => TinNhan.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi khi tải tin nhắn: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading messages: $e');
      return [];
    }
  }

  // Lấy tin nhắn công khai (cho người chưa đăng nhập)
  Future<List<TinNhan>> getPublicMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUri/Public'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => TinNhan.fromJson(e)).toList();
      } else {
        throw Exception('Lỗi khi tải tin nhắn: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading public messages: $e');
      return [];
    }
  }

  // Đánh dấu tin nhắn đã đọc
  Future<bool> markAsRead(int maTinNhan) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUri/MarkAsRead/$maTinNhan'),
      );
      return response.statusCode == 204;
    } catch (e) {
      print('Error marking as read: $e');
      return false;
    }
  }

  // Xóa tin nhắn
  Future<Map<String, dynamic>> deleteMessage(int maTinNhan) async {
    try {
      final response = await http.delete(Uri.parse('$baseUri/$maTinNhan'));

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã xóa tin nhắn'};
      } else {
        return {'success': false, 'message': 'Lỗi khi xóa tin nhắn'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
