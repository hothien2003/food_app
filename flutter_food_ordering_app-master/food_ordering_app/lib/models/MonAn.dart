// import 'package:food_ordering_app/models/ChiTietDonHang.dart';
// import 'package:food_ordering_app/models/NhaHang.dart';

// class MonAn {
//   final int maMonAn;
//   final int maNhaHang;
//   final String tenMonAn;
//   final String? moTa;
//   final double gia;
//   final String? urlHinhAnh;
//   final DateTime? ngayTao;
//   final List<ChiTietDonHang>? chiTietDonHangs;
//   final NhaHang? maNhaHangNavigation;

//   const MonAn({
//     required this.maMonAn,
//     required this.maNhaHang,
//     required this.tenMonAn,
//     this.moTa,
//     required this.gia,
//     this.urlHinhAnh,
//     this.ngayTao,
//     this.chiTietDonHangs,
//     this.maNhaHangNavigation,
//   });

//   factory MonAn.fromJson(Map<String, dynamic> json) {
//     // Xử lý các trường có thể null hoặc thiếu
//     final int id = json['maMonAn'] ?? 0;
//     final int maNhaHang = json['maNhaHang'] ?? 0;
//     final String tenMonAn = json['tenMonAn'] ?? 'Không có tên';

//     // Xử lý trường giá
//     double gia = 0.0;
//     if (json['gia'] != null) {
//       try {
//         gia =
//             json['gia'] is int
//                 ? (json['gia'] as int).toDouble()
//                 : json['gia'] is double
//                 ? json['gia']
//                 : double.tryParse(json['gia'].toString()) ?? 0.0;
//       } catch (e) {
//         print('Lỗi khi xử lý giá: $e');
//       }
//     }

//     // Xử lý chiTietDonHangs một cách an toàn
//     List<ChiTietDonHang>? chiTietDonHangs;
//     if (json['chiTietDonHangs'] != null) {
//       try {
//         chiTietDonHangs =
//             (json['chiTietDonHangs'] as List?)
//                 ?.where((x) => x != null)
//                 .map((x) {
//                   if (x is Map<String, dynamic>) {
//                     return ChiTietDonHang.fromJson(x);
//                   } else {
//                     print('Bỏ qua chi tiết đơn hàng không hợp lệ: $x');
//                     return null;
//                   }
//                 })
//                 .where((x) => x != null)
//                 .cast<ChiTietDonHang>()
//                 .toList();
//       } catch (e) {
//         print('Lỗi khi xử lý danh sách chi tiết đơn hàng: $e');
//         chiTietDonHangs = [];
//       }
//     }

//     return MonAn(
//       maMonAn: id,
//       maNhaHang: maNhaHang,
//       tenMonAn: tenMonAn,
//       moTa: json['moTa'],
//       gia: gia,
//       urlHinhAnh: json['urlHinhAnh'] ?? json['urlhinhAnh'],
//       ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
//       chiTietDonHangs: chiTietDonHangs,
//       maNhaHangNavigation:
//           json['maNhaHangNavigation'] != null &&
//                   json['maNhaHangNavigation'] is Map<String, dynamic>
//               ? NhaHang.fromJson(json['maNhaHangNavigation'])
//               : null,
//     );
//   }

//   Map<String, dynamic> toPostJson() => {
//     "maMonAn": maMonAn,
//     "maNhaHang": maNhaHang,
//     "tenMonAn": tenMonAn,
//     "moTa": moTa,
//     "gia": gia,
//     "urlHinhAnh": urlHinhAnh,
//     "ngayTao": ngayTao?.toIso8601String(),
//     if (chiTietDonHangs != null)
//       "chiTietDonHangs": List<dynamic>.from(
//         chiTietDonHangs!.map((x) => x.toJson()),
//       ),
//     if (maNhaHangNavigation != null)
//       "maNhaHangNavigation": maNhaHangNavigation!.toJson(),
//   };

//   Map<String, dynamic> toJson() => toPostJson();
// }
import 'package:food_ordering_app/models/ChiTietDonHang.dart';
import 'package:food_ordering_app/models/NhaHang.dart';

class MonAn {
  final int maMonAn;
  final int maNhaHang;
  final String tenMonAn;
  final String? moTa;
  final double gia;
  final String? urlHinhAnh;
  final DateTime? ngayTao;
  final List<ChiTietDonHang>? chiTietDonHangs;
  final NhaHang? maNhaHangNavigation;

  const MonAn({
    required this.maMonAn,
    required this.maNhaHang,
    required this.tenMonAn,
    this.moTa,
    required this.gia,
    this.urlHinhAnh,
    this.ngayTao,
    this.chiTietDonHangs,
    this.maNhaHangNavigation,
  });

  factory MonAn.fromJson(Map<String, dynamic> json) {
    // Xử lý các trường có thể null hoặc thiếu
    final int id = json['maMonAn'] ?? 0;
    final int maNhaHang = json['maNhaHang'] ?? 0;
    final String tenMonAn = json['tenMonAn'] ?? 'Không có tên';

    // Xử lý trường giá
    double gia = 0.0;
    if (json['gia'] != null) {
      try {
        gia =
            json['gia'] is int
                ? (json['gia'] as int).toDouble()
                : json['gia'] is double
                ? json['gia']
                : double.tryParse(json['gia'].toString()) ?? 0.0;
      } catch (e) {
        print('Lỗi khi xử lý giá: $e');
      }
    }

    // Xử lý chiTietDonHangs một cách an toàn
    List<ChiTietDonHang>? chiTietDonHangs;
    if (json['chiTietDonHangs'] != null) {
      try {
        chiTietDonHangs =
            (json['chiTietDonHangs'] as List?)
                ?.where((x) => x != null)
                .map((x) {
                  if (x is Map<String, dynamic>) {
                    return ChiTietDonHang.fromJson(x);
                  } else {
                    print('Bỏ qua chi tiết đơn hàng không hợp lệ: $x');
                    return null;
                  }
                })
                .where((x) => x != null)
                .cast<ChiTietDonHang>()
                .toList();
      } catch (e) {
        print('Lỗi khi xử lý danh sách chi tiết đơn hàng: $e');
        chiTietDonHangs = [];
      }
    }

    return MonAn(
      maMonAn: id,
      maNhaHang: maNhaHang,
      tenMonAn: tenMonAn,
      moTa: json['moTa'],
      gia: gia,
      urlHinhAnh: json['urlHinhAnh'] ?? json['urlhinhAnh'],
      ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
      chiTietDonHangs: chiTietDonHangs,
      maNhaHangNavigation:
          json['maNhaHangNavigation'] != null &&
                  json['maNhaHangNavigation'] is Map<String, dynamic>
              ? NhaHang.fromJson(json['maNhaHangNavigation'])
              : null,
    );
  }

  Map<String, dynamic> toPostJson() => {
    "maMonAn": maMonAn,
    "maNhaHang": maNhaHang,
    "tenMonAn": tenMonAn,
    "moTa": moTa,
    "gia": gia,
    "urlHinhAnh": urlHinhAnh,
    "ngayTao": ngayTao?.toIso8601String(),
    "maNhaHangNavigation":
        maNhaHangNavigation?.toJson() ??
        {"maNhaHang": maNhaHang, "tenNhaHang": ""}, // Thêm trường tenNhaHang
    if (chiTietDonHangs != null)
      "chiTietDonHangs": List<dynamic>.from(
        chiTietDonHangs!.map((x) => x.toJson()),
      ),
  };

  Map<String, dynamic> toJson() => toPostJson();
}
