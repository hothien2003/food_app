/// Hàm này sẽ kết hợp [baseImageUrl] với [imagePath] để tạo ra URL đầy đủ của hình ảnh.
///
/// - Nếu [imagePath] là null, hàm sẽ trả về chuỗi rỗng.
/// - Hàm sẽ kiểm tra và loại bỏ dấu "/" ở cuối [baseImageUrl] nếu có,
///   sau đó đảm bảo rằng [imagePath] bắt đầu bằng "/" để trả về URL hợp lệ.
///
/// Ví dụ:
///   baseImageUrl: "http://10.0.2.2:5000/" và imagePath: "Images/heo-sua-quay.png"
///   => Kết quả: "http://10.0.2.2:5000/Images/heo-sua-quay.png"
///
library;
import 'dart:io' show Platform;

// final String baseImageUrl = "http://10.0.2.2:5000/";
String get baseImageUrl {
  if (Platform.isAndroid) {
    // Sử dụng 10.0.2.2 cho máy ảo Android
    return "http://10.0.2.2:5000/";
  } else {
    // Sử dụng localhost cho Windows và các nền tảng khác
    return "http://localhost:5000/";
  }
}

String getFullImageUrl(String baseImageUrl, String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return '$baseImageUrl/Images/default-food.jpg';
  }

  final normalizedBase =
      baseImageUrl.endsWith('/')
          ? baseImageUrl.substring(0, baseImageUrl.length - 1)
          : baseImageUrl;

  final path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
  return normalizedBase + path;
}

/// Hàm này chuyển đổi đường dẫn tuyệt đối của ảnh thành đường dẫn tương đối
String convertToRelativeImagePath(String absolutePath) {
  // Tìm thư mục Images trong đường dẫn
  final imagesIndex = absolutePath.indexOf('Images');
  if (imagesIndex != -1) {
    // Lấy phần đường dẫn từ 'Images' trở đi
    String relativePath = absolutePath.substring(imagesIndex);
    // Chuyển đổi dấu \ thành / nếu có
    relativePath = relativePath.replaceAll('\\', '/');
    return relativePath;
  }

  // Nếu không tìm thấy thư mục Images, trả về đường dẫn mặc định
  return "Images/default-food.jpg";
}
