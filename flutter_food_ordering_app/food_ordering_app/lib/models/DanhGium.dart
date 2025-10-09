import 'package:food_ordering_app/models/NguoiDung.dart';
import 'package:food_ordering_app/models/NhaHang.dart';

class DanhGium {
  final int maDanhGia;
  final int maNguoiDung;
  final int maNhaHang;
  final int diemDanhGia;
  final String? binhLuan;
  final DateTime? ngayTao;

  final NguoiDung? nguoiDung;
  final NhaHang? nhaHang;

  const DanhGium({
    required this.maDanhGia,
    required this.maNguoiDung,
    required this.maNhaHang,
    required this.diemDanhGia,
    this.binhLuan,
    this.ngayTao,
    this.nguoiDung,
    this.nhaHang,
  });

  factory DanhGium.fromJson(Map<String, dynamic> json) => DanhGium(
    maDanhGia: json['maDanhGia'],
    maNguoiDung: json['maNguoiDung'],
    maNhaHang: json['maNhaHang'],
    diemDanhGia: json['diemDanhGia'],
    binhLuan: json['binhLuan'],
    ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
    nguoiDung:
        json['maNguoiDungNavigation'] != null
            ? NguoiDung.fromJson(json['maNguoiDungNavigation'])
            : null,
    nhaHang:
        json['maNhaHangNavigation'] != null
            ? NhaHang.fromJson(json['maNhaHangNavigation'])
            : null,
  );

  Map<String, dynamic> toJson() => {
    "maDanhGia": maDanhGia,
    "maNguoiDung": maNguoiDung,
    "maNhaHang": maNhaHang,
    "diemDanhGia": diemDanhGia,
    "binhLuan": binhLuan,
    "ngayTao": ngayTao?.toIso8601String(),
    "maNguoiDungNavigation": nguoiDung?.toJson(),
    "maNhaHangNavigation": nhaHang?.toJson(),
  };
}
