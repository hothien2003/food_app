import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageHelper {
  static const String _languageCodeKey = 'language_code';
  static const String defaultLanguageCode = 'vi';

  // Lưu ngôn ngữ đã chọn
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }

  // Lấy ngôn ngữ đã lưu
  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey) ?? defaultLanguageCode;
  }

  // Lấy Locale từ language code
  static Locale getLocale(String languageCode) {
    switch (languageCode) {
      case 'vi':
        return const Locale('vi', 'VN');
      case 'en':
        return const Locale('en', 'US');
      default:
        return const Locale('vi', 'VN');
    }
  }

  // Danh sách các ngôn ngữ hỗ trợ
  static List<LanguageModel> getSupportedLanguages() {
    return [
      LanguageModel(code: 'vi', name: 'Tiếng Việt', flagIcon: '🇻🇳'),
      LanguageModel(code: 'en', name: 'English', flagIcon: '🇺🇸'),
    ];
  }
}

class LanguageModel {
  final String code;
  final String name;
  final String flagIcon;

  LanguageModel({
    required this.code,
    required this.name,
    required this.flagIcon,
  });
}
