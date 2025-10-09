import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/MonAn.dart';

class ApiChatbot {
  final String baseUri = "http://10.0.2.2:5000/api";
  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // Lấy món ăn bán chạy nhất (theo số lượng đơn hàng)
  Future<List<MonAn>> getBestSellingFoods() async {
    final uri = Uri.parse('$baseUri/MonAn/bestselling');
    try {
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => MonAn.fromJson(json)).toList();
      } else {
        print(
          'Error fetching best selling: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching best selling foods: $e');
    }
    return [];
  }

  // Lấy món ăn đắt nhất
  Future<List<MonAn>> getMostExpensiveFoods() async {
    final uri = Uri.parse('$baseUri/MonAn/mostexpensive');
    try {
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => MonAn.fromJson(json)).toList();
      } else {
        print(
          'Error fetching expensive foods: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching expensive foods: $e');
    }
    return [];
  }

  // Lấy món ăn rẻ nhất
  Future<List<MonAn>> getCheapestFoods() async {
    final uri = Uri.parse('$baseUri/MonAn/cheapest');
    try {
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => MonAn.fromJson(json)).toList();
      } else {
        print(
          'Error fetching cheapest foods: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching cheapest foods: $e');
    }
    return [];
  }

  // Tìm kiếm món ăn theo từ khóa
  Future<List<MonAn>> searchFoodsByKeyword(String keyword) async {
    final uri = Uri.parse('$baseUri/MonAn/search?keyword=$keyword');
    try {
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => MonAn.fromJson(json)).toList();
      } else {
        print('Error searching foods: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error searching foods: $e');
    }
    return [];
  }

  // Lưu lịch sử chat
  Future<bool> saveChatHistory(
    int userId,
    String message,
    String botResponse,
  ) async {
    final uri = Uri.parse('$baseUri/ChatHistory');
    try {
      final body = {
        'userId': userId,
        'userMessage': message,
        'botResponse': botResponse,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final httpResponse = await http.post(
        uri,
        headers: _headers,
        body: json.encode(body),
      );

      return httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299;
    } catch (e) {
      print('Error saving chat history: $e');
      return false;
    }
  }
}
