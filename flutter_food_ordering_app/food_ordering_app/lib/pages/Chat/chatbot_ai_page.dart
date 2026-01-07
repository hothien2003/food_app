import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../../const/colors.dart';
import '../../api/api_giohang.dart';
import '../../api/api_monan.dart';
import '../../models/GioHang.dart';
import '../../models/MonAn.dart';
import '../../utils/shared_preferences_helper.dart';

class ChatbotAIPage extends StatefulWidget {
  static const routeName = '/chatbot-ai';

  const ChatbotAIPage({super.key});

  @override
  State<ChatbotAIPage> createState() => _ChatbotAIPageState();
}

class _ChatbotAIPageState extends State<ChatbotAIPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String _apiKey = 'AIzaSyCT2JFWIO2UF5NkfCfuCctizt4wb6Wl6M8';
  late final GenerativeModel _model;

  bool _isLoading = false;
  final bool _geminiError = false;
  final List<ChatMessage> _messages = [];
  bool _isDataLoaded = false;
  Uint8List? _csvData;

  // State cho đặt món
  PendingOrder? _pendingOrder;
  final ApiGioHang _apiGioHang = ApiGioHang();
  final ApiMonAn _apiMonAn = ApiMonAn();
  List<MonAn>? _monAnList;
  List<GioHang>? _gioHangList;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-2.0-flash-latest', apiKey: _apiKey);

    // tin nhắn chào mừng
    _messages.add(
      ChatMessage(
        message:
            '👋 Xin chào! Tôi là AI Assistant của Food Ordering App!\n\n'
            '🎯 Tôi có thể giúp bạn:\n\n'
            '🍕 Xem menu & tư vấn món ăn\n'
            '🛒 Đặt món và quản lý giỏ hàng\n'
            '💰 Thông tin giá, khuyến mãi\n'
            '🚚 Hỗ trợ giao hàng & thanh toán\n\n'
            '💬 Hãy hỏi tôi bất cứ điều gì!\n'
            'Ví dụ: "Có món gì ngon?", "Đặt 2 pizza", "Xem giỏ hàng"',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _loadMonAnList();
    _loadGioHangList();

    // Đánh dấu đã tải dữ liệu (không còn cần CSV)
    setState(() {
      _isDataLoaded = true;
    });
  }

  // Load danh sách món ăn
  Future<void> _loadMonAnList() async {
    try {
      print('📡 Đang gọi API để tải danh sách món ăn...');
      final list = await _apiMonAn.getMonAnData();
      setState(() {
        _monAnList = list;
      });
      print('✅ Đã tải ${list?.length ?? 0} món ăn từ API');
    } catch (e) {
      print('❌ Lỗi khi tải danh sách món ăn: $e');
    }
  }

  // Load danh sách giỏ hàng
  Future<void> _loadGioHangList() async {
    try {
      final maNguoiDung = await layMaNguoiDungDangNhap();
      if (maNguoiDung != null) {
        final list = await _apiGioHang.getGioHangByNguoiDung(maNguoiDung);
        setState(() {
          _gioHangList = list;
        });
      }
    } catch (e) {
      print('Lỗi khi tải giỏ hàng: $e');
    }
  }

  // Lấy base URL dựa trên platform
  String get _baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000";
    } else {
      return "http://localhost:5000";
    }
  }

  // Cung cấp dữ liệu CSV cho AI
  Future<void> _loadCSVData() async {
    try {
      print('Đang tải dữ liệu CSV từ: $_baseUrl/api/MonAn/GetCSVData');

      final response = await http
          .get(Uri.parse('$_baseUrl/api/MonAn/GetCSVData'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _csvData = response.bodyBytes;
          _isDataLoaded = true;
        });
        print(
          'Đã tải dữ liệu CSV thành công (${response.bodyBytes.length} bytes)',
        );
      } else {
        print('Không thể tải file CSV: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _isDataLoaded = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu CSV: $e');
      setState(() {
        _isDataLoaded = false;
      });
    }
  }

  // Gửi câu hỏi đến Gemini với dữ liệu món ăn
  Future<String> _processCSVQuestion(String userMessage) async {
    print('🎯 _processCSVQuestion được gọi với: "$userMessage"');
    try {
      // Kiểm tra dữ liệu món ăn
      print('🔍 Kiểm tra _monAnList: ${_monAnList?.length ?? 0} món');
      if (_monAnList == null || _monAnList!.isEmpty) {
        print('⚠️ Danh sách món ăn trống, đang tải...');
        await _loadMonAnList();
        if (_monAnList == null || _monAnList!.isEmpty) {
          print('❌ Không thể tải dữ liệu món ăn!');
          return 'Không thể tải dữ liệu món ăn. Vui lòng thử lại sau.';
        }
        print('✅ Đã tải ${_monAnList!.length} món ăn');
      }

      // Tạo danh sách món ăn dạng text cho AI (giới hạn 30 món)
      String monAnListText = 'Món ăn:\n';
      for (var monAn in _monAnList!.take(30)) {
        monAnListText +=
            '${monAn.maMonAn}: ${monAn.tenMonAn} (${monAn.gia.toStringAsFixed(0)}đ)\n';
      }
      print('📋 Danh sách món ăn gửi cho AI:\n$monAnListText');

      // Tạo danh sách giỏ hàng hiện tại
      String gioHangText = '';
      if (_gioHangList != null && _gioHangList!.isNotEmpty) {
        gioHangText = '\nGiỏ hàng:\n';
        for (var item in _gioHangList!) {
          final monAn = _monAnList?.firstWhere(
            (m) => m.maMonAn == item.maMonAn,
            orElse:
                () => MonAn(
                  maMonAn: item.maMonAn,
                  maNhaHang: 0,
                  tenMonAn: 'Món #${item.maMonAn}',
                  gia: 0,
                ),
          );
          gioHangText +=
              '${item.maMonAn}: ${monAn?.tenMonAn ?? "Món"} x${item.soLuong}\n';
        }
      }

      // Gửi request đến Gemini với prompt đơn giản hơn
      final content = [
        Content.text('''
Bạn là trợ lý AI của ứng dụng đặt món ăn. Hãy trả lời thân thiện, ngắn gọn.

QUAN TRỌNG: Khách có thể gõ tiếng Việt không dấu (VD: "dat pizza", "co mon gi") - bạn phải hiểu!

DANH SÁCH MÓN ĂN:
$monAnListText

GIỎ HÀNG HIỆN TẠI:
${gioHangText.isEmpty ? "Giỏ hàng trống" : gioHangText}

GIỎ HÀNG HIỆN TẠI:
${gioHangText.isEmpty ? "Giỏ hàng trống" : gioHangText}

CÂU HỎI: "$userMessage"

HƯỚNG DẪN TRẢ LỜI:

1. Chào hỏi ("xin chao", "hi") → Chào + giới thiệu có thể giúp gì
2. Hỏi món ("co mon gi", "có món gì") → Liệt kê 5-8 món với giá, emoji 🍕🍜🍔
3. Đặt món ("dat pizza", "cho 2 pho") → 
   - Nếu có số lượng: "Đã thêm X [món] vào giỏ! Giá: Y đ 🛒\nACTION:CONFIRM_ORDER|MA_MON_AN:[mã]|SO_LUONG:[số]"
   - Nếu chưa có số lượng: "Bạn muốn bao nhiêu phần [món]? (Giá: X đ)"
4. Xóa món ("xoa pizza", "bo pho") → "Đã xóa [món] khỏi giỏ! ✅\nACTION:REMOVE_FROM_CART|MA_MON_AN:[mã]"
5. Xem giỏ ("gio hang", "giỏ hàng") → Liệt kê món + tổng tiền
6. Hỏi giá → Trả lời giá chính xác từ danh sách
7. Thanh toán/giao hàng → "Hỗ trợ: COD, MoMo, ZaloPay, QR. Ship 30-45 phút, miễn phí >100k"

LƯU Ý:
- Hiểu cả có dấu và không dấu (pizza = pizza, pho = phở)
- Dùng emoji cho thân thiện
- ACTION: ở dòng riêng, không giải thích
- Nếu không tìm thấy món → gợi ý món tương tự

TRẢ LỜI NGAY:
'''),
      ];

      // Retry logic
      GenerateContentResponse? result;
      int retries = 0;
      const maxRetries = 2;

      while (retries <= maxRetries) {
        try {
          print(
            '🔄 Đang gọi Gemini API... (Lần thử ${retries + 1}/${maxRetries + 1})',
          );
          result = await _model
              .generateContent(content)
              .timeout(Duration(seconds: 15));
          print('✅ Gemini API trả về thành công!');
          break;
        } catch (e) {
          retries++;
          print('❌ Lỗi Gemini (lần $retries): $e');
          if (retries > maxRetries) {
            print('⛔ Đã thử $maxRetries lần, chuyển sang fallback');
            rethrow;
          }
          await Future.delayed(Duration(seconds: 2 * retries));
        }
      }

      if (result == null) {
        print('❌ Gemini không trả về kết quả');
        return _smartFallbackResponse(userMessage);
      }

      final responseText =
          result.text ?? 'Xin lỗi, tôi không thể trả lời câu hỏi vào lúc này.';

      print(
        '✅ AI trả lời: ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...',
      );

      // Xử lý action từ AI response
      await _handleAIResponse(responseText, userMessage);

      // Trả về response không có ACTION tag
      return responseText
          .split('\n')
          .where((line) => !line.startsWith('ACTION:'))
          .join('\n');
    } catch (e) {
      print('❌❌❌ LỖI NGHIÊM TRỌNG: $e');
      print('📍 Chi tiết lỗi: ${e.toString()}');
      // Fallback khi API lỗi
      return _smartFallbackResponse(userMessage);
    }
  }

  // Smart fallback response với logic thông minh
  Future<String> _smartFallbackResponse(String userMessage) async {
    final lowerMsg = userMessage.toLowerCase();

    // Load dữ liệu nếu chưa có
    if (_monAnList == null || _monAnList!.isEmpty) {
      await _loadMonAnList();
    }

    // 1. Xử lý câu chào
    if (lowerMsg.contains('xin chào') ||
        lowerMsg.contains('chào') ||
        lowerMsg.contains('hi') ||
        lowerMsg.contains('hello')) {
      return 'Xin chào! Tôi có thể giúp bạn:\n• Xem danh sách món ăn\n• Đặt món vào giỏ hàng\n• Kiểm tra giỏ hàng\n\nBạn muốn làm gì?';
    }

    // 2. Xử lý xem danh sách món
    if (lowerMsg.contains('món') &&
        (lowerMsg.contains('có') ||
            lowerMsg.contains('gì') ||
            lowerMsg.contains('nào') ||
            lowerMsg.contains('danh sách'))) {
      if (_monAnList != null && _monAnList!.isNotEmpty) {
        String response =
            '📋 Danh sách món ăn (${_monAnList!.length} món):\n\n';
        int count = _monAnList!.length > 10 ? 10 : _monAnList!.length;
        for (var i = 0; i < count; i++) {
          response +=
              '${i + 1}. ${_monAnList![i].tenMonAn} - ${_monAnList![i].gia.toStringAsFixed(0)}đ\n';
        }
        if (_monAnList!.length > 10) {
          response += '\n...và ${_monAnList!.length - 10} món khác';
        }
        return response;
      }
    }

    // 3. Xử lý xem giỏ hàng
    if (lowerMsg.contains('giỏ') ||
        lowerMsg.contains('gio') ||
        lowerMsg.contains('đã đặt')) {
      if (_gioHangList != null && _gioHangList!.isNotEmpty) {
        String response = '🛒 Giỏ hàng của bạn:\n\n';
        double total = 0;
        for (var item in _gioHangList!) {
          final monAn = _monAnList?.firstWhere(
            (m) => m.maMonAn == item.maMonAn,
            orElse:
                () => MonAn(
                  maMonAn: item.maMonAn,
                  maNhaHang: 0,
                  tenMonAn: 'Món #${item.maMonAn}',
                  gia: 0,
                ),
          );
          double itemTotal = (monAn?.gia ?? 0) * item.soLuong;
          total += itemTotal;
          response +=
              '• ${monAn?.tenMonAn ?? "Món"} x${item.soLuong} = ${itemTotal.toStringAsFixed(0)}đ\n';
        }
        response += '\n💰 Tổng cộng: ${total.toStringAsFixed(0)}đ';
        return response;
      } else {
        return '🛒 Giỏ hàng của bạn đang trống.\n\nBạn muốn đặt món nào không?';
      }
    }

    // 4. Xử lý đặt món (tìm món trong danh sách)
    if (lowerMsg.contains('đặt') ||
        lowerMsg.contains('thêm') ||
        lowerMsg.contains('mua')) {
      if (_monAnList != null && _monAnList!.isNotEmpty) {
        // Tìm món ăn phù hợp
        MonAn? foundMon;
        for (var mon in _monAnList!) {
          if (lowerMsg.contains(mon.tenMonAn.toLowerCase())) {
            foundMon = mon;
            break;
          }
        }

        if (foundMon != null) {
          // Tìm số lượng trong câu
          int? soLuong = _extractQuantity(userMessage);
          if (soLuong != null) {
            // Có số lượng rồi, thêm luôn
            await _addToCart(foundMon.maMonAn, soLuong);
            return '✅ Đã thêm ${soLuong} phần ${foundMon.tenMonAn} vào giỏ hàng!\n\nTổng: ${(foundMon.gia * soLuong).toStringAsFixed(0)}đ';
          } else {
            // Hỏi số lượng
            setState(() {
              _pendingOrder = PendingOrder(
                maMonAn: foundMon!.maMonAn,
                tenMonAn: foundMon.tenMonAn,
              );
            });
            return '🍽️ ${foundMon.tenMonAn} - ${foundMon.gia.toStringAsFixed(0)}đ\n\nBạn muốn đặt bao nhiêu phần?';
          }
        } else {
          return 'Xin lỗi, tôi không tìm thấy món bạn yêu cầu. Bạn có thể xem danh sách món bằng cách hỏi "Có món gì?"';
        }
      }
    }

    // 5. Xử lý trả lời số lượng cho pending order
    if (_pendingOrder != null) {
      int? soLuong = _extractQuantity(userMessage);
      if (soLuong != null) {
        final monAn = _monAnList?.firstWhere(
          (m) => m.maMonAn == _pendingOrder!.maMonAn,
          orElse:
              () => MonAn(
                maMonAn: _pendingOrder!.maMonAn,
                maNhaHang: 0,
                tenMonAn: _pendingOrder!.tenMonAn,
                gia: 0,
              ),
        );
        await _addToCart(_pendingOrder!.maMonAn, soLuong);
        final tenMon = _pendingOrder!.tenMonAn;
        setState(() {
          _pendingOrder = null;
        });
        return '✅ Đã thêm $soLuong phần $tenMon vào giỏ hàng!\n\nTổng: ${((monAn?.gia ?? 0) * soLuong).toStringAsFixed(0)}đ';
      }
    }

    // Default response
    return 'Tôi có thể giúp bạn:\n\n• "Có món gì?" - Xem danh sách món\n• "Đặt [tên món]" - Đặt món ăn\n• "Giỏ hàng" - Xem giỏ hàng\n\nBạn muốn làm gì?';
  }

  // Fallback response cũ (giữ lại backup)
  String _fallbackResponse(String userMessage) {
    final lowerMsg = userMessage.toLowerCase();

    // Xử lý câu chào
    if (lowerMsg.contains('xin chào') ||
        lowerMsg.contains('chào') ||
        lowerMsg.contains('hi') ||
        lowerMsg.contains('hello')) {
      return 'Xin chào! Tôi có thể giúp bạn tìm món ăn, thêm vào giỏ hàng. Bạn muốn gì?';
    }

    // Xử lý hỏi về món ăn
    if (lowerMsg.contains('món') ||
        lowerMsg.contains('ăn') ||
        lowerMsg.contains('có gì')) {
      if (_monAnList != null && _monAnList!.isNotEmpty) {
        String response =
            'Chúng tôi có ${_monAnList!.length} món ăn. Một số món:\n\n';
        for (
          var i = 0;
          i < (_monAnList!.length > 5 ? 5 : _monAnList!.length);
          i++
        ) {
          response +=
              '• ${_monAnList![i].tenMonAn} - ${_monAnList![i].gia.toStringAsFixed(0)}đ\n';
        }
        return response;
      }
    }

    // Xử lý giỏ hàng
    if (lowerMsg.contains('giỏ') || lowerMsg.contains('gio')) {
      if (_gioHangList != null && _gioHangList!.isNotEmpty) {
        String response =
            'Giỏ hàng của bạn có ${_gioHangList!.length} món:\n\n';
        for (var item in _gioHangList!) {
          final monAn = _monAnList?.firstWhere(
            (m) => m.maMonAn == item.maMonAn,
            orElse:
                () => MonAn(
                  maMonAn: item.maMonAn,
                  maNhaHang: 0,
                  tenMonAn: 'Món #${item.maMonAn}',
                  gia: 0,
                ),
          );
          response += '• ${monAn?.tenMonAn ?? "Món"} x${item.soLuong}\n';
        }
        return response;
      } else {
        return 'Giỏ hàng của bạn đang trống.';
      }
    }

    return 'Xin lỗi, tôi đang gặp sự cố kỹ thuật tạm thời. Bạn có thể hỏi về:\n• Danh sách món ăn\n• Giỏ hàng của bạn\n• Đặt món ăn';
  }

  // Xử lý response từ AI để thực hiện action
  Future<void> _handleAIResponse(String aiResponse, String userMessage) async {
    try {
      // Tìm ACTION trong response
      final actionLines =
          aiResponse
              .split('\n')
              .where((line) => line.startsWith('ACTION:'))
              .toList();

      for (var actionLine in actionLines) {
        final parts = actionLine.replaceFirst('ACTION:', '').split('|');
        final action = parts[0];

        int? maMonAn;
        int? soLuong;
        String? tenMon;

        for (var part in parts) {
          if (part.startsWith('MA_MON_AN:')) {
            maMonAn = int.tryParse(part.replaceFirst('MA_MON_AN:', ''));
          } else if (part.startsWith('SO_LUONG:')) {
            soLuong = int.tryParse(part.replaceFirst('SO_LUONG:', ''));
          } else if (part.startsWith('TEN_MON:')) {
            tenMon = part.replaceFirst('TEN_MON:', '');
          }
        }

        if (action == 'ADD_TO_CART' && maMonAn != null) {
          // Tìm món ăn trong danh sách
          final monAn =
              _monAnList?.firstWhere(
                (m) => m.maMonAn == maMonAn,
                orElse:
                    () => MonAn(
                      maMonAn: maMonAn!,
                      maNhaHang: 0,
                      tenMonAn: tenMon ?? 'Món ăn',
                      gia: 0,
                    ),
              ) ??
              MonAn(
                maMonAn: maMonAn,
                maNhaHang: 0,
                tenMonAn: tenMon ?? 'Món ăn',
                gia: 0,
              );

          setState(() {
            _pendingOrder = PendingOrder(
              maMonAn: maMonAn!,
              tenMonAn: monAn.tenMonAn,
            );
          });
        } else if (action == 'CONFIRM_ORDER' &&
            maMonAn != null &&
            soLuong != null) {
          await _addToCart(maMonAn, soLuong);
          setState(() {
            _pendingOrder = null;
          });
        } else if (action == 'UPDATE_CART' &&
            maMonAn != null &&
            soLuong != null) {
          await _updateCart(maMonAn, soLuong);
        } else if (action == 'REMOVE_FROM_CART' && maMonAn != null) {
          await _removeFromCart(maMonAn);
        }
      }

      // Nếu có pending order và user message có vẻ là số lượng
      if (_pendingOrder != null) {
        final soLuong = _extractQuantity(userMessage);
        if (soLuong != null) {
          await _addToCart(_pendingOrder!.maMonAn, soLuong);
          setState(() {
            _pendingOrder = null;
          });
        }
      }
    } catch (e) {
      print('Lỗi khi xử lý action: $e');
    }
  }

  // Trích xuất số lượng từ message
  int? _extractQuantity(String message) {
    final numbers = RegExp(r'\d+').allMatches(message);
    if (numbers.isNotEmpty) {
      return int.tryParse(numbers.first.group(0)!);
    }

    // Xử lý số bằng chữ
    final vietnameseNumbers = {
      'một': 1,
      'hai': 2,
      'ba': 3,
      'bốn': 4,
      'năm': 5,
      'sáu': 6,
      'bảy': 7,
      'tám': 8,
      'chín': 9,
      'mười': 10,
    };

    final lowerMessage = message.toLowerCase();
    for (var entry in vietnameseNumbers.entries) {
      if (lowerMessage.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  // Thêm món vào giỏ hàng
  Future<void> _addToCart(int maMonAn, int soLuong) async {
    try {
      final maNguoiDung = await layMaNguoiDungDangNhap();
      if (maNguoiDung == null) {
        print('Người dùng chưa đăng nhập');
        return;
      }

      // Kiểm tra xem món đã có trong giỏ hàng chưa
      final existingItem =
          _gioHangList?.firstWhere(
            (item) => item.maMonAn == maMonAn,
            orElse:
                () => GioHang(
                  maGioHang: 0,
                  maNguoiDung: 0,
                  maMonAn: 0,
                  soLuong: 0,
                  ngayThem: DateTime.now(),
                ),
          ) ??
          GioHang(
            maGioHang: 0,
            maNguoiDung: 0,
            maMonAn: 0,
            soLuong: 0,
            ngayThem: DateTime.now(),
          );

      if (existingItem.maGioHang > 0) {
        // Cập nhật số lượng
        final updatedGioHang = GioHang(
          maGioHang: existingItem.maGioHang,
          maNguoiDung: maNguoiDung,
          maMonAn: maMonAn,
          soLuong: existingItem.soLuong + soLuong,
          ngayThem: existingItem.ngayThem,
        );
        await _apiGioHang.updateGioHang(existingItem.maGioHang, updatedGioHang);
      } else {
        // Thêm mới
        final newGioHang = GioHang(
          maGioHang: 0,
          maNguoiDung: maNguoiDung,
          maMonAn: maMonAn,
          soLuong: soLuong,
          ngayThem: DateTime.now(),
        );
        await _apiGioHang.createGioHang(newGioHang);
      }

      // Reload giỏ hàng
      await _loadGioHangList();
    } catch (e) {
      print('Lỗi khi thêm vào giỏ hàng: $e');
    }
  }

  // Cập nhật số lượng món trong giỏ hàng
  Future<void> _updateCart(int maMonAn, int soLuong) async {
    try {
      final existingItem = _gioHangList?.firstWhere(
        (item) => item.maMonAn == maMonAn,
      );

      if (existingItem != null && existingItem.maGioHang > 0) {
        final maNguoiDung = await layMaNguoiDungDangNhap();
        if (maNguoiDung == null) return;

        final updatedGioHang = GioHang(
          maGioHang: existingItem.maGioHang,
          maNguoiDung: maNguoiDung,
          maMonAn: maMonAn,
          soLuong: soLuong,
          ngayThem: existingItem.ngayThem,
        );
        await _apiGioHang.updateGioHang(existingItem.maGioHang, updatedGioHang);

        // Reload giỏ hàng
        await _loadGioHangList();
      }
    } catch (e) {
      print('Lỗi khi cập nhật giỏ hàng: $e');
    }
  }

  // Xóa món khỏi giỏ hàng
  Future<void> _removeFromCart(int maMonAn) async {
    try {
      final existingItem = _gioHangList?.firstWhere(
        (item) => item.maMonAn == maMonAn,
      );

      if (existingItem != null && existingItem.maGioHang > 0) {
        final response = await _apiGioHang.deleteGioHang(
          existingItem.maGioHang,
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          // Reload giỏ hàng
          await _loadGioHangList();
          print('Đã xóa món khỏi giỏ hàng thành công');
        } else {
          print('Lỗi khi xóa món khỏi giỏ hàng: ${response.statusCode}');
        }
      } else {
        print('Không tìm thấy món trong giỏ hàng để xóa');
      }
    } catch (e) {
      print('Lỗi khi xóa món khỏi giỏ hàng: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  //Nhận câu hỏi và chuyển cho AI để nhận câu trả lời
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          message: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    String response = '';
    try {
      response = await _processCSVQuestion(userMessage);
    } catch (e) {
      print('Lỗi khi xử lý tin nhắn: $e');
      response = 'Xin lỗi, tôi đang gặp sự cố kỹ thuật. Vui lòng thử lại sau.';
    }

    setState(() {
      _messages.add(
        ChatMessage(
          message: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat với AI Trợ lý'),
        backgroundColor: AppColor.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  // Hiển thị loading indicator
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: SpinKitThreeBounce(
                        color: AppColor.orange,
                        size: 24,
                      ),
                    ),
                  );
                }

                final message = _messages[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child:
                      message.isUser
                          ? BubbleSpecialThree(
                            text: message.message,
                            color: AppColor.orange,
                            tail: true,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            isSender: true,
                          )
                          : BubbleSpecialThree(
                            text: message.message,
                            color: const Color(0xFFE8E8EE),
                            tail: true,
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            isSender: false,
                          ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom + 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Nhập câu hỏi hoặc yêu cầu của bạn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: MaterialButton(
                      onPressed: _sendMessage,
                      color: AppColor.orange,
                      textColor: Colors.white,
                      minWidth: 0,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.send_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}

class PendingOrder {
  final int maMonAn;
  final String tenMonAn;

  PendingOrder({required this.maMonAn, required this.tenMonAn});
}
