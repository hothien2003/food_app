import 'package:shared_preferences/shared_preferences.dart';

// Lưu thông tin người dùng khi đăng nhập
Future<void> luuNguoiDungDangNhap(int maNguoiDung) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('maNguoiDung', maNguoiDung);
}

// Lấy thông tin người dùng đăng nhập
Future<int?> layMaNguoiDungDangNhap() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('maNguoiDung'); 
}

// Đăng xuất người dùng
Future<void> dangXuat() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('maNguoiDung');
}
