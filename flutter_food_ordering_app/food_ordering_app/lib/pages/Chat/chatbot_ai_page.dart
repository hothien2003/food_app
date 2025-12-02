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

  final String _apiKey = 'AIzaSyBg_frsvNCOmPnZB1nMLty6Z22uH539dtM';
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
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

    // tin nhắn chào mừng
    _messages.add(
      ChatMessage(
        message:
            'Xin chào! Tôi là trợ lý AI của ứng dụng đặt đồ ăn. Tôi có thể giúp bạn:\n\n',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _loadCSVData();
    _loadMonAnList();
    _loadGioHangList();
  }
  
  // Load danh sách món ăn
  Future<void> _loadMonAnList() async {
    try {
      final list = await _apiMonAn.getMonAnData();
      setState(() {
        _monAnList = list;
      });
    } catch (e) {
      print('Lỗi khi tải danh sách món ăn: $e');
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
      final response = await http.get(
        Uri.parse('$_baseUrl/api/MonAn/GetCSVData'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _csvData = response.bodyBytes;
          _isDataLoaded = true;
        });
        print('Đã tải dữ liệu CSV thành công');
      } else {
        print('Không thể tải file CSV: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu CSV: $e');
    }
  }

  // Gửi câu hỏi đến Gemini với dữ liệu CSV
  Future<String> _processCSVQuestion(String userMessage) async {
    try {
      if (_csvData == null) {
        return 'Đang tải dữ liệu món ăn. Vui lòng thử lại sau.';
      }

      // Tạo danh sách món ăn dạng text cho AI
      String monAnListText = '';
      if (_monAnList != null && _monAnList!.isNotEmpty) {
        monAnListText = '\n\nDanh sách món ăn hiện có:\n';
        for (var monAn in _monAnList!.take(50)) { // Giới hạn 50 món để không quá dài
          monAnListText += '- ${monAn.maMonAn}: ${monAn.tenMonAn} (${monAn.gia.toStringAsFixed(0)} VNĐ)\n';
        }
      }
      
      // Tạo danh sách giỏ hàng hiện tại
      String gioHangText = '';
      if (_gioHangList != null && _gioHangList!.isNotEmpty) {
        gioHangText = '\n\nGiỏ hàng hiện tại của bạn (Mã món - Tên món - Số lượng):\n';
        for (var item in _gioHangList!) {
          final monAn = _monAnList?.firstWhere(
            (m) => m.maMonAn == item.maMonAn,
            orElse: () => MonAn(
              maMonAn: item.maMonAn,
              maNhaHang: 0,
              tenMonAn: 'Món ăn #${item.maMonAn}',
              gia: 0,
            ),
          ) ?? MonAn(
            maMonAn: item.maMonAn,
            maNhaHang: 0,
            tenMonAn: 'Món ăn #${item.maMonAn}',
            gia: 0,
          );
          gioHangText += '- Mã ${item.maMonAn}: ${monAn.tenMonAn} - ${item.soLuong} phần\n';
        }
      }

      final content = [
        Content.multi([
          DataPart('text/csv', _csvData!),
          TextPart('''
Bạn là trợ lý AI của ứng dụng đặt đồ ăn. Dựa trên dữ liệu món ăn trong file CSV, hãy trả lời câu hỏi sau:

"$userMessage"
$monAnListText
$gioHangText

QUAN TRỌNG - Xử lý yêu cầu đặt món:
1. Nếu người dùng muốn đặt món (ví dụ: "tôi muốn đặt pizza", "cho tôi 2 phần phở", "thêm bánh mì vào giỏ hàng"):
   - Tìm món ăn phù hợp trong danh sách món ăn (so khớp tên món)
   - Nếu tìm thấy và người dùng đã nói số lượng: thêm luôn vào giỏ hàng
   - Nếu tìm thấy nhưng chưa có số lượng: hỏi "Bạn muốn đặt bao nhiêu phần [TÊN MÓN]?"
   - Trong response, thêm dòng đặc biệt: "ACTION:ADD_TO_CART|MA_MON_AN:[số mã món từ danh sách]|TEN_MON:[tên món chính xác]"
   - Nếu người dùng đã nói số lượng, thêm: "ACTION:CONFIRM_ORDER|MA_MON_AN:[số]|SO_LUONG:[số lượng]"
   
2. Nếu người dùng trả lời số lượng (ví dụ: "2 phần", "3", "một phần") và có pending order:
   - Thêm vào giỏ hàng và trả lời: "Đã thêm [số lượng] phần [tên món] vào giỏ hàng của bạn!"
   - Trong response, thêm: "ACTION:CONFIRM_ORDER|MA_MON_AN:[số]|SO_LUONG:[số]"
   
3. Nếu người dùng muốn thay đổi số lượng món trong giỏ hàng (ví dụ: "đổi pizza thành 5 phần", "tăng phở lên 3 phần", "giảm bánh mì xuống 2 phần"):
   - Tìm món ăn trong giỏ hàng hiện tại
   - Trả lời: "Đã cập nhật số lượng [tên món] thành [số lượng] phần!"
   - Trong response, thêm: "ACTION:UPDATE_CART|MA_MON_AN:[số mã món từ giỏ hàng]|SO_LUONG:[số lượng mới]"

4. Nếu người dùng muốn xóa món khỏi giỏ hàng (ví dụ: "xóa pizza", "bỏ thịt heo", "xóa món thịt bò", "xóa cho tôi thịt heo"):
   - Tìm món ăn trong giỏ hàng hiện tại (so khớp tên món với danh sách giỏ hàng ở trên)
   - Lấy MÃ MÓN (maMonAn) từ giỏ hàng hiện tại, KHÔNG phải từ danh sách món ăn
   - Trả lời: "Đã xóa [tên món] khỏi giỏ hàng của bạn!"
   - Trong response, thêm: "ACTION:REMOVE_FROM_CART|MA_MON_AN:[số mã món từ giỏ hàng hiện tại]"
   - QUAN TRỌNG: 
     * Chỉ xóa khi tìm thấy món trong giỏ hàng hiện tại
     * Phải sử dụng MÃ MÓN từ giỏ hàng (ví dụ: nếu giỏ hàng có "Mã 5: thịt heo", thì dùng mã 5)
     * Nếu không tìm thấy thì trả lời: "Không tìm thấy [tên món] trong giỏ hàng của bạn."

5. Nếu người dùng chỉ hỏi thông tin, trả lời bình thường không có ACTION.

Lưu ý:
- Giá tiền: hiển thị theo đơn vị VNĐ.
- Ngày tháng: hiển thị theo định dạng dd/mm/yyyy.
- Trả lời thân thiện, ngắn gọn, rõ ràng.
- Chỉ thêm ACTION khi thực sự cần xử lý giỏ hàng.
'''),
        ]),
      ];

      final result = await _model.generateContent(content); 
      final responseText = result.text ??
          'Xin lỗi, tôi không thể trả lời câu hỏi vào lúc này.';
      
      // Xử lý action từ AI response
      await _handleAIResponse(responseText, userMessage);
      
      // Trả về response không có ACTION tag
      return responseText.split('\n')
          .where((line) => !line.startsWith('ACTION:'))
          .join('\n');
    } catch (e) {
      print('Lỗi khi xử lý câu hỏi với CSV: $e');
      return 'Đã xảy ra lỗi khi xử lý yêu cầu của bạn. Vui lòng thử lại sau.';
    }
  }
  
  // Xử lý response từ AI để thực hiện action
  Future<void> _handleAIResponse(String aiResponse, String userMessage) async {
    try {
      // Tìm ACTION trong response
      final actionLines = aiResponse.split('\n')
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
          final monAn = _monAnList?.firstWhere(
            (m) => m.maMonAn == maMonAn,
            orElse: () => MonAn(
              maMonAn: maMonAn!,
              maNhaHang: 0,
              tenMonAn: tenMon ?? 'Món ăn',
              gia: 0,
            ),
          ) ?? MonAn(
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
        } else if (action == 'CONFIRM_ORDER' && maMonAn != null && soLuong != null) {
          await _addToCart(maMonAn, soLuong);
          setState(() {
            _pendingOrder = null;
          });
        } else if (action == 'UPDATE_CART' && maMonAn != null && soLuong != null) {
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
      'một': 1, 'hai': 2, 'ba': 3, 'bốn': 4, 'năm': 5,
      'sáu': 6, 'bảy': 7, 'tám': 8, 'chín': 9, 'mười': 10,
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
      final existingItem = _gioHangList?.firstWhere(
        (item) => item.maMonAn == maMonAn,
        orElse: () => GioHang(
          maGioHang: 0,
          maNguoiDung: 0,
          maMonAn: 0,
          soLuong: 0,
          ngayThem: DateTime.now(),
        ),
      ) ?? GioHang(
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
        final response = await _apiGioHang.deleteGioHang(existingItem.maGioHang);
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
        actions: [
          // Hiển thị trạng thái kết nối dữ liệu
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isDataLoaded ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isDataLoaded ? 'Đã tải dữ liệu' : 'Đang tải...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                  child: message.isUser
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
                          textStyle: TextStyle(color: Colors.black, fontSize: 16),
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

  PendingOrder({
    required this.maMonAn,
    required this.tenMonAn,
  });
}
