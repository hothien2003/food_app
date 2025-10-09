import 'package:food_ordering_app/models/DonHang.dart';
import 'package:food_ordering_app/models/MonAn.dart';

class ChiTietDonHang {
  final int maChiTietDonHang;
  final int maDonHang;
  final int maMonAn;
  final int soLuong;
  final double gia;
  final DonHang? maDonHangNavigation;
  final MonAn? maMonAnNavigation;

  const ChiTietDonHang({
    required this.maChiTietDonHang,
    required this.maDonHang,
    required this.maMonAn,
    required this.soLuong,
    required this.gia,
    this.maDonHangNavigation,
    this.maMonAnNavigation,
  });

  factory ChiTietDonHang.fromJson(Map<String, dynamic> json) {
    try {
      // Xử lý giá trị mặc định cho các trường bắt buộc nếu không tồn tại
      final int id = json['maChiTietDonHang'] ?? 0;
      final int maDonHang = json['maDonHang'] ?? 0;
      final int maMonAn = json['maMonAn'] ?? 0;
      final int soLuong = json['soLuong'] ?? 1;

      // Xử lý giá có thể là int hoặc double
      double gia = 0.0;
      if (json['gia'] != null) {
        if (json['gia'] is int) {
          gia = (json['gia'] as int).toDouble();
        } else if (json['gia'] is double) {
          gia = json['gia'];
        } else {
          // Nếu là kiểu khác, cố gắng chuyển đổi
          gia = double.tryParse(json['gia'].toString()) ?? 0.0;
        }
      }

      // Xử lý thông tin đơn hàng nếu có
      DonHang? donHangNav;
      if (json['maDonHangNavigation'] != null) {
        if (json['maDonHangNavigation'] is Map) {
          // Chuyển đổi dữ liệu từ Map sang Map<String, dynamic>
          final Map<String, dynamic> donHangMap = Map<String, dynamic>.from(
            json['maDonHangNavigation'],
          );
          donHangNav = DonHang.fromJson(donHangMap);
        }
      }

      // Xử lý thông tin món ăn nếu có
      MonAn? monAnNav;
      if (json['maMonAnNavigation'] != null) {
        if (json['maMonAnNavigation'] is Map) {
          // Chuyển đổi dữ liệu từ Map sang Map<String, dynamic>
          final Map<String, dynamic> monAnMap = Map<String, dynamic>.from(
            json['maMonAnNavigation'],
          );
          monAnNav = MonAn.fromJson(monAnMap);
        }
      }

      return ChiTietDonHang(
        maChiTietDonHang: id,
        maDonHang: maDonHang,
        maMonAn: maMonAn,
        soLuong: soLuong,
        gia: gia,
        maDonHangNavigation: donHangNav,
        maMonAnNavigation: monAnNav,
      );
    } catch (e) {
      // Trả về đối tượng mặc định để tránh bị crash
      return ChiTietDonHang(
        maChiTietDonHang: 0,
        maDonHang: 0,
        maMonAn: 0,
        soLuong: 0,
        gia: 0,
        maDonHangNavigation: null,
        maMonAnNavigation: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'maChiTietDonHang': maChiTietDonHang,
      'maDonHang': maDonHang,
      'maMonAn': maMonAn,
      'soLuong': soLuong,
      'gia': gia,
      'maDonHangNavigation': maDonHangNavigation?.toJson(),
      'maMonAnNavigation': maMonAnNavigation?.toPostJson(),
    };
  }
}
