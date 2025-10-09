import 'package:food_ordering_app/models/NguoiDung.dart';
import 'package:food_ordering_app/models/MonAn.dart';

class GioHang {
  final int maGioHang;
  final int maNguoiDung;
  final int maMonAn;
  final int soLuong;
  final DateTime ngayThem;
  final NguoiDung? maNguoiDungNavigation;
  final MonAn? maMonAnNavigation;

  const GioHang({
    required this.maGioHang,
    required this.maNguoiDung,
    required this.maMonAn,
    required this.soLuong,
    required this.ngayThem,
    this.maNguoiDungNavigation,
    this.maMonAnNavigation,
  });

  factory GioHang.fromJson(Map<String, dynamic> json) => GioHang(
    maGioHang: json['maGioHang'],
    maNguoiDung: json['maNguoiDung'],
    maMonAn: json['maMonAn'],
    soLuong: json['soLuong'],
    ngayThem: DateTime.parse(json['ngayThem']),
    maNguoiDungNavigation:
        json['maNguoiDungNavigation'] != null
            ? NguoiDung.fromJson(json['maNguoiDungNavigation'])
            : null,
    maMonAnNavigation:
        json['maMonAnNavigation'] != null
            ? MonAn.fromJson(json['maMonAnNavigation'])
            : null,
  );

  Map<String, dynamic> toJson() => {
    'maGioHang': maGioHang,
    'maNguoiDung': maNguoiDung,
    'maMonAn': maMonAn,
    'soLuong': soLuong,
    'ngayThem': ngayThem.toIso8601String(),
    'maNguoiDungNavigation': maNguoiDungNavigation?.toJson(),
    'maMonAnNavigation': maMonAnNavigation?.toPostJson(),
  };

  Map<String, dynamic> toPostJson() => {
    'maNguoiDung': maNguoiDung,
    'maMonAn': maMonAn,
    'soLuong': soLuong,
    'ngayThem': ngayThem.toIso8601String(),
  };
}
