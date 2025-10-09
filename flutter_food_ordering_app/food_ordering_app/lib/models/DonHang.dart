import 'package:food_ordering_app/models/ChiTietDonHang.dart';
import 'package:food_ordering_app/models/NguoiDung.dart';
import 'package:food_ordering_app/models/NhaHang.dart';
import 'package:food_ordering_app/models/ThanhToan.dart';

class DonHang {
  final int maDonHang;
  final int maNguoiDung;
  final int maNhaHang;
  final DateTime? ngayDatHang;
  final double tongTien;
  final String trangThai;
  final String? diaChiGiaoHang;
  final String? soDienThoai;
  final String? ghiChu;

  final List<ChiTietDonHang>? chiTietDonHangs;
  final NguoiDung? nguoiDung;
  final NhaHang? nhaHang;
  final List<ThanhToan>? thanhToans;

  const DonHang({
    required this.maDonHang,
    required this.maNguoiDung,
    required this.maNhaHang,
    this.ngayDatHang,
    required this.tongTien,
    required this.trangThai,
    this.diaChiGiaoHang,
    this.soDienThoai,
    this.ghiChu,
    this.chiTietDonHangs,
    this.nguoiDung,
    this.nhaHang,
    this.thanhToans,
  });

  factory DonHang.fromJson(Map<String, dynamic> json) {
    try {
      // Kiểm tra và gán giá trị mặc định cho các trường bắt buộc
      final int id = json['maDonHang'] ?? 0;
      final int maNguoiDung = json['maNguoiDung'] ?? 0;
      final int maNhaHang = json['maNhaHang'] ?? 0;

      // Xử lý trường hợp tongTien có thể null hoặc không phải số
      double tongTien = 0.0;
      if (json['tongTien'] != null) {
        try {
          tongTien =
              (json['tongTien'] is int)
                  ? (json['tongTien'] as int).toDouble()
                  : (json['tongTien'] is double)
                  ? json['tongTien']
                  : double.tryParse(json['tongTien'].toString()) ?? 0.0;
        } catch (e) {
          // Bỏ qua lỗi, sử dụng giá trị mặc định
        }
      }

      // Đảm bảo trangThai luôn có giá trị hợp lệ
      String trangThai = json['trangThai'] ?? 'Đang xử lý';
      if (trangThai.isEmpty) {
        trangThai = 'Đang xử lý';
      }

      // Xử lý danh sách chiTietDonHangs
      List<ChiTietDonHang>? chiTietDonHangs;
      if (json['chiTietDonHangs'] != null) {
        try {
          final chiTietList = json['chiTietDonHangs'] as List;
          chiTietDonHangs = [];

          for (var item in chiTietList) {
            if (item != null && item is Map) {
              try {
                // Chuyển đổi sang Map<String, dynamic>
                final Map<String, dynamic> itemMap = Map<String, dynamic>.from(
                  item,
                );
                chiTietDonHangs.add(ChiTietDonHang.fromJson(itemMap));
              } catch (e) {
                // Bỏ qua lỗi, tiếp tục với item tiếp theo
              }
            }
          }
        } catch (e) {
          chiTietDonHangs = [];
        }
      }

      // Xử lý thông tin người dùng
      NguoiDung? nguoiDung;
      if (json['maNguoiDungNavigation'] != null) {
        try {
          if (json['maNguoiDungNavigation'] is Map) {
            final Map<String, dynamic> nguoiDungMap = Map<String, dynamic>.from(
              json['maNguoiDungNavigation'],
            );
            nguoiDung = NguoiDung.fromJson(nguoiDungMap);
          }
        } catch (e) {
          // Bỏ qua lỗi
        }
      }

      // Xử lý thông tin nhà hàng
      NhaHang? nhaHang;
      if (json['maNhaHangNavigation'] != null) {
        try {
          if (json['maNhaHangNavigation'] is Map) {
            final Map<String, dynamic> nhaHangMap = Map<String, dynamic>.from(
              json['maNhaHangNavigation'],
            );
            nhaHang = NhaHang.fromJson(nhaHangMap);
          }
        } catch (e) {
          // Bỏ qua lỗi
        }
      }

      // Xử lý thông tin thanh toán
      List<ThanhToan>? thanhToans;
      if (json['thanhToans'] != null) {
        try {
          final thanhToanList = json['thanhToans'] as List;
          thanhToans = [];

          for (var item in thanhToanList) {
            if (item != null && item is Map) {
              try {
                // Chuyển đổi sang Map<String, dynamic>
                final Map<String, dynamic> itemMap = Map<String, dynamic>.from(
                  item,
                );
                thanhToans.add(ThanhToan.fromJson(itemMap));
              } catch (e) {
                // Bỏ qua lỗi, tiếp tục với item tiếp theo
              }
            }
          }
        } catch (e) {
          thanhToans = [];
        }
      }

      return DonHang(
        maDonHang: id,
        maNguoiDung: maNguoiDung,
        maNhaHang: maNhaHang,
        ngayDatHang:
            json['ngayDatHang'] != null
                ? DateTime.parse(json['ngayDatHang'].toString())
                : null,
        tongTien: tongTien,
        trangThai: trangThai,
        diaChiGiaoHang: json['diaChiGiaoHang'],
        soDienThoai: json['soDienThoai'],
        ghiChu: json['ghiChu'],
        chiTietDonHangs: chiTietDonHangs,
        nguoiDung: nguoiDung,
        nhaHang: nhaHang,
        thanhToans: thanhToans,
      );
    } catch (e) {
      // Trả về đơn hàng mặc định để tránh bị crash
      return DonHang(
        maDonHang: 0,
        maNguoiDung: 0,
        maNhaHang: 0,
        tongTien: 0,
        trangThai: "Không xác định",
      );
    }
  }

  Map<String, dynamic> toJson() => {
    "maDonHang": maDonHang,
    "maNguoiDung": maNguoiDung,
    "maNhaHang": maNhaHang,
    "ngayDatHang": ngayDatHang?.toIso8601String(),
    "tongTien": tongTien,
    "trangThai": trangThai,
    "diaChiGiaoHang": diaChiGiaoHang,
    "soDienThoai": soDienThoai,
    "ghiChu": ghiChu,
    "chiTietDonHangs": chiTietDonHangs?.map((x) => x.toJson()).toList(),
    "maNguoiDungNavigation": nguoiDung?.toJson(),
    "maNhaHangNavigation": nhaHang?.toJson(),
    "thanhToans": thanhToans?.map((x) => x.toJson()).toList(),
  };
}
