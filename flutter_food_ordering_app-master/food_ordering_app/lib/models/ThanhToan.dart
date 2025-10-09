import 'package:food_ordering_app/models/DonHang.dart';

class ThanhToan {
  final int maThanhToan;
  final int maDonHang;
  final DateTime? ngayThanhToan;
  final double soTien;
  final String phuongThucThanhToan;
  final String trangThai;
  final DonHang? donHang;

  const ThanhToan({
    required this.maThanhToan,
    required this.maDonHang,
    this.ngayThanhToan,
    required this.soTien,
    required this.phuongThucThanhToan,
    required this.trangThai,
    this.donHang,
  });

  factory ThanhToan.fromJson(Map<String, dynamic> json) {
    try {
      // Xử lý các trường bắt buộc với giá trị mặc định
      final int maThanhToan = json['maThanhToan'] ?? 0;
      final int maDonHang = json['maDonHang'] ?? 0;

      // Xử lý ngày tháng an toàn
      DateTime? ngayThanhToan;
      if (json['ngayThanhToan'] != null) {
        try {
          ngayThanhToan = DateTime.parse(json['ngayThanhToan'].toString());
        } catch (e) {
          // Bỏ qua lỗi
        }
      }

      // Xử lý giá trị số
      double soTien = 0.0;
      if (json['soTien'] != null) {
        if (json['soTien'] is int) {
          soTien = (json['soTien'] as int).toDouble();
        } else if (json['soTien'] is double) {
          soTien = json['soTien'];
        } else {
          soTien = double.tryParse(json['soTien'].toString()) ?? 0.0;
        }
      }

      // Xử lý các giá trị chuỗi với giá trị mặc định
      final String phuongThucThanhToan =
          json['phuongThucThanhToan'] ?? 'Không xác định';
      final String trangThai = json['trangThai'] ?? 'Không xác định';

      // Xử lý đối tượng đơn hàng
      DonHang? donHang;
      if (json['maDonHangNavigation'] != null) {
        try {
          if (json['maDonHangNavigation'] is Map) {
            final Map<String, dynamic> donHangMap = Map<String, dynamic>.from(
              json['maDonHangNavigation'],
            );
            donHang = DonHang.fromJson(donHangMap);
          }
        } catch (e) {
          // Bỏ qua lỗi
        }
      }

      return ThanhToan(
        maThanhToan: maThanhToan,
        maDonHang: maDonHang,
        ngayThanhToan: ngayThanhToan,
        soTien: soTien,
        phuongThucThanhToan: phuongThucThanhToan,
        trangThai: trangThai,
        donHang: donHang,
      );
    } catch (e) {
      // Trả về đối tượng mặc định để tránh bị crash
      return ThanhToan(
        maThanhToan: 0,
        maDonHang: 0,
        soTien: 0.0,
        phuongThucThanhToan: 'Không xác định',
        trangThai: 'Không xác định',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    "maThanhToan": maThanhToan,
    "maDonHang": maDonHang,
    "ngayThanhToan": ngayThanhToan?.toIso8601String(),
    "soTien": soTien,
    "phuongThucThanhToan": phuongThucThanhToan,
    "trangThai": trangThai,
    "maDonHangNavigation": donHang?.toJson(),
  };
}
