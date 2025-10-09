import 'package:food_ordering_app/models/DanhGium.dart';
import 'package:food_ordering_app/models/DonHang.dart';

class NguoiDung {
  final int maNguoiDung;
  final String tenDangNhap;
  final String matKhau;
  final String? hoTen;
  final String? email;
  final String? soDienThoai;
  final String? diaChi;
  final DateTime? ngayTao;
  final List<DanhGium>? danhGia;
  final List<DonHang>? donHangs;

  const NguoiDung({
    required this.maNguoiDung,
    required this.tenDangNhap,
    required this.matKhau,
    this.hoTen,
    this.email,
    this.soDienThoai,
    this.diaChi,
    this.ngayTao,
    this.danhGia,
    this.donHangs,
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) {
    try {
      // Xử lý các trường bắt buộc với giá trị mặc định
      final int maNguoiDung = json['maNguoiDung'] ?? 0;
      final String tenDangNhap = json['tenDangNhap'] ?? '';
      final String matKhau = json['matKhau'] ?? '';

      // Xử lý các trường chuỗi tùy chọn
      final String? hoTen = json['hoTen'];
      final String? email = json['email'];
      final String? soDienThoai = json['soDienThoai'];
      final String? diaChi = json['diaChi'];

      // Xử lý ngày tháng an toàn
      DateTime? ngayTao;
      if (json['ngayTao'] != null) {
        try {
          ngayTao = DateTime.parse(json['ngayTao'].toString());
        } catch (e) {
          // Bỏ qua lỗi
        }
      }

      // Xử lý danh sách đánh giá
      List<DanhGium>? danhGia;
      if (json['danhGia'] != null && json['danhGia'] is List) {
        try {
          danhGia = [];
          for (var item in json['danhGia']) {
            if (item != null && item is Map) {
              final Map<String, dynamic> itemMap = Map<String, dynamic>.from(
                item,
              );
              danhGia.add(DanhGium.fromJson(itemMap));
            }
          }
        } catch (e) {
          // Bỏ qua lỗi
        }
      }

      // Xử lý danh sách đơn hàng
      List<DonHang>? donHangs;
      if (json['donHangs'] != null && json['donHangs'] is List) {
        try {
          donHangs = [];
          for (var item in json['donHangs']) {
            if (item != null && item is Map) {
              final Map<String, dynamic> itemMap = Map<String, dynamic>.from(
                item,
              );
              donHangs.add(DonHang.fromJson(itemMap));
            }
          }
        } catch (e) {
          // Bỏ qua lỗi
        }
      }

      return NguoiDung(
        maNguoiDung: maNguoiDung,
        tenDangNhap: tenDangNhap,
        matKhau: matKhau,
        hoTen: hoTen,
        email: email,
        soDienThoai: soDienThoai,
        diaChi: diaChi,
        ngayTao: ngayTao,
        danhGia: danhGia,
        donHangs: donHangs,
      );
    } catch (e) {
      // Trả về đối tượng mặc định để tránh bị crash
      return NguoiDung(maNguoiDung: 0, tenDangNhap: '', matKhau: '');
    }
  }

  Map<String, dynamic> toJson() => {
    "maNguoiDung": maNguoiDung,
    "tenDangNhap": tenDangNhap,
    "matKhau": matKhau,
    "hoTen": hoTen,
    "email": email,
    "soDienThoai": soDienThoai,
    "diaChi": diaChi,
    "ngayTao": ngayTao?.toIso8601String(),
    // "danhGia": danhGia?.map((x) => x.toJson()).toList(),
    // "donHangs": donHangs?.map((x) => x.toJson()).toList(),
  };
}
