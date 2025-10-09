
class NhaHang {
  final int maNhaHang;
  final String tenNhaHang;
  final String? diaChi;
  final String? soDienThoai;
  final String? moTa;
  final DateTime? ngayTao;
  // final List<DanhGium> danhGia;
  // final List<DonHang> donHangs;
  // final List<MonAn> monAns;

  const NhaHang({
    required this.maNhaHang,
    required this.tenNhaHang,
    this.diaChi,
    this.soDienThoai,
    this.moTa,
    this.ngayTao,
    // this.danhGia = const [],
    // this.donHangs = const [],
    // this.monAns = const [],
  });

  factory NhaHang.fromJson(Map<String, dynamic> json) {
    try {
      // Xử lý các trường bắt buộc với giá trị mặc định
      final int maNhaHang = json['maNhaHang'] ?? 0;
      final String tenNhaHang = json['tenNhaHang'] ?? 'Nhà hàng không xác định';

      // Xử lý các trường chuỗi tùy chọn
      final String? diaChi = json['diaChi'];
      final String? soDienThoai = json['soDienThoai'];
      final String? moTa = json['moTa'];

      // Xử lý ngày tháng an toàn
      DateTime? ngayTao;
      if (json['ngayTao'] != null) {
        try {
          ngayTao = DateTime.parse(json['ngayTao'].toString());
        } catch (e) {
          // Bỏ qua lỗi
        }
      }

      return NhaHang(
        maNhaHang: maNhaHang,
        tenNhaHang: tenNhaHang,
        diaChi: diaChi,
        soDienThoai: soDienThoai,
        moTa: moTa,
        ngayTao: ngayTao,
      );
    } catch (e) {
      // Trả về đối tượng mặc định để tránh bị crash
      return NhaHang(maNhaHang: 0, tenNhaHang: 'Lỗi dữ liệu');
    }
  }

  Map<String, dynamic> toJson() => {
    "maNhaHang": maNhaHang,
    "tenNhaHang": tenNhaHang,
    "diaChi": diaChi,
    "soDienThoai": soDienThoai,
    "moTa": moTa,
    "ngayTao": ngayTao?.toIso8601String(),
    // "danhGia": danhGia.map((x) => x.toJson()).toList(),
    // "donHangs": donHangs.map((x) => x.toJson()).toList(),
    // "monAns": monAns.map((x) => x.toJson()).toList(),
  };
}
