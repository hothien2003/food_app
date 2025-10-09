import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:csv/csv.dart';
import '../models/MonAn.dart';
import '../models/NhaHang.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;
  late final GenerativeModel model;
  List<MonAn>? _cachedFoods;

  GeminiService({required this.apiKey}) {
    model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  // Lấy tất cả dữ liệu món ăn từ CSV
  Future<List<MonAn>> getAllFoods() async {
    if (_cachedFoods != null) return _cachedFoods!;
  
    final csvData = await readCSVData();
    _cachedFoods = await convertCSVToMonAn(csvData);
    return _cachedFoods!;
  }

  // Đọc dữ liệu từ file CSV
  Future<List<List<dynamic>>> readCSVData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/MonAn/GetCSVData'),
      );
      if (response.statusCode == 200) {
        List<List<dynamic>> listData = const CsvToListConverter().convert(
          response.body,
        );
        return listData;
      } else {
        print('Lỗi khi gọi API: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Lỗi khi đọc file CSV: $e');
      return [];
    }
  }

  // Chuyển đổi dữ liệu CSV thành danh sách MonAn
  Future<List<MonAn>> convertCSVToMonAn(List<List<dynamic>> csvData) async {
    List<MonAn> monAns = [];
    // Bỏ qua dòng đầu tiên (header)
    for (int i = 1; i < csvData.length; i++) {
      try {
        final row = csvData[i];
        if (row.length >= 8) {
          // Đảm bảo đủ cột dữ liệu
          DateTime? ngayTao;
          if (row[6].toString().isNotEmpty) {
            try {
              ngayTao = DateTime.parse(row[6].toString());
            } catch (dateError) {
              print('Định dạng ngày không hợp lệ: ${row[6]}');
            }
          }

          // Tạo đối tượng NhaHang từ dữ liệu CSV
          final tenNhaHang = row[7].toString();
          final nhaHang = NhaHang(
            maNhaHang: int.tryParse(row[1].toString()) ?? 0,
            tenNhaHang: tenNhaHang,
            diaChi: '',
            soDienThoai: '',
            moTa: '',
            ngayTao: DateTime.now(),
          );

          MonAn monAn = MonAn(
            maMonAn: int.tryParse(row[0].toString()) ?? 0,
            maNhaHang: int.tryParse(row[1].toString()) ?? 0,
            tenMonAn: row[2].toString(),
            moTa: row[3].toString(),
            gia: double.tryParse(row[4].toString()) ?? 0,
            urlHinhAnh: row[5].toString(),
            ngayTao: ngayTao,
            maNhaHangNavigation: nhaHang,
          );
          monAns.add(monAn);
        }
      } catch (e) {
        print('Lỗi khi chuyển đổi dòng CSV thành MonAn: $e');
      }
    }
    return monAns;
  }

  //  xử lý câu hỏi của người dùng
  Future<String> processUserQuestion(String userMessage) async {
    try {
      // Lấy tất cả dữ liệu món ăn
      final allFoods = await getAllFoods();

      // Tạo prompt với dữ liệu món ăn
      String prompt = createPromptWithAllData(userMessage, allFoods);

      // Gửi prompt đến Gemini API
      return await getChatResponse(prompt);
    } catch (e) {
      print('Lỗi khi xử lý câu hỏi: $e');
      return 'Đã xảy ra lỗi khi xử lý yêu cầu của bạn. Vui lòng thử lại sau.';
    }
  }

  // Tạo prompt với tất cả dữ liệu món ăn
  String createPromptWithAllData(String userMessage, List<MonAn> allFoods) {
    // Tạo một chuỗi chứa thông tin về tất cả món ăn
    String foodsData = '';
    for (var i = 0; i < allFoods.length; i++) {
      final food = allFoods[i];
      foodsData += '${i + 1}. ${food.tenMonAn} - ${food.gia} đ';
      if (food.moTa != null && food.moTa!.isNotEmpty) {
        foodsData += ' - ${food.moTa}';
      }
      // Thêm thông tin nhà hàng
      if (food.maNhaHangNavigation != null) {
        foodsData += ' - ${food.maNhaHangNavigation!.tenNhaHang}';
      }
      foodsData += '\n';
    }

    // Tạo prompt với hướng dẫn cụ thể cho Gemini
    return '''
Bạn là trợ lý AI . Hãy trả lời câu hỏi sau của khách hàng dựa trên dữ liệu món ăn được cung cấp hoặc các thông tin ngoài lề.

Câu hỏi: $userMessage

Dữ liệu món ăn:
$foodsData

Phân tích câu hỏi và trả lời dựa trên dữ liệu món ăn. Nếu câu hỏi liên quan đến:

Trả lời một cách thân thiện và hữu ích.
''';
  }

  // Gửi prompt đến Gemini API
  Future<String> getChatResponse(String prompt) async {
    try {
      final content = Content.text(prompt);
      final response = await model.generateContent([content]);

      return response.text ??
          'Xin lỗi, tôi không thể trả lời câu hỏi vào lúc này.';
    } catch (e) {
      print('Lỗi khi gọi Gemini API: $e');
      return 'Đã xảy ra lỗi khi xử lý yêu cầu của bạn. Vui lòng thử lại sau.';
    }
  }
}
