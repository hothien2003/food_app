import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../../const/colors.dart';

class ChatbotAIPage extends StatefulWidget {
  static const routeName = '/chatbot-ai';

  const ChatbotAIPage({super.key});

  @override
  State<ChatbotAIPage> createState() => _ChatbotAIPageState();
}

class _ChatbotAIPageState extends State<ChatbotAIPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String _apiKey = 'AIzaSyAbXpAtR4CNcqu04YGcl8B0KgtTFKpLLxE';
  late final GenerativeModel _model;

  bool _isLoading = false;
  final bool _geminiError = false;
  final List<ChatMessage> _messages = [];
  bool _isDataLoaded = false;
  Uint8List? _csvData;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey);

    // tin nhắn chào mừng
    _messages.add(
      ChatMessage(
        message:
            'Xin chào! Tôi là trợ lý AI của ứng dụng đặt đồ ăn. Tôi có thể giúp bạn tìm món ăn, đề xuất món phù hợp, cho bạn biết món ăn bán chạy nhất, đắt nhất, rẻ nhất, hoặc trả lời câu hỏi của bạn về ẩm thực.\n\nBạn cần giúp gì?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    _loadCSVData();
  }

  // Cung cấp dữ liệu CSV cho AI
  Future<void> _loadCSVData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/MonAn/GetCSVData'),
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

      final content = [
        Content.multi([
          DataPart('text/csv', _csvData!),
          TextPart('''
Bạn là trợ lý AI của ứng dụng đặt đồ ăn. Dựa trên dữ liệu món ăn trong file CSV, hãy trả lời câu hỏi sau:

"$userMessage"

Lưu ý:
1. Giá tiền: thì hiển thị giá tiền theo đơn vị tiền tệ Việt Nam (VNĐ).
2. Ngày tháng năm: thì hiển thị ngày tháng năm theo định dạng Việt Nam (dd/mm/yyyy).

Trả lời thân thiện, ngắn gọn, rõ ràng, dễ hiểu.
'''),
        ]),
      ];

      final result = await _model.generateContent(content); 
      return result.text ??
          'Xin lỗi, tôi không thể trả lời câu hỏi vào lúc này.';
    } catch (e) {
      print('Lỗi khi xử lý câu hỏi với CSV: $e');
      return 'Đã xảy ra lỗi khi xử lý yêu cầu của bạn. Vui lòng thử lại sau.';
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
              padding: const EdgeInsets.all(16),
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

                return message.isUser
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
                    );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
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
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                MaterialButton(
                  onPressed: _sendMessage,
                  color: AppColor.orange,
                  textColor: Colors.white,
                  minWidth: 0,
                  shape: const CircleBorder(),
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.send_rounded),
                ),
              ],
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
