import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/utils/app_localizations.dart';
import 'package:food_ordering_app/utils/language_helper.dart';
import 'package:food_ordering_app/main.dart';

class LanguagePage extends StatefulWidget {
  static const routeName = "/languagePage";

  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String? _selectedLanguage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final currentLanguage = await LanguageHelper.getSavedLanguage();
    setState(() {
      _selectedLanguage = currentLanguage;
      _isLoading = false;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });

    await LanguageHelper.saveLanguage(languageCode);

    // Cập nhật locale của app
    if (mounted) {
      final myAppState = MyApp.of(context);
      myAppState?.setLocale(LanguageHelper.getLocale(languageCode));

      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageCode == 'vi'
                ? 'Đã chuyển sang Tiếng Việt'
                : 'Changed to English',
          ),
          backgroundColor: AppColor.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languages = LanguageHelper.getSupportedLanguages();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.selectLanguage,
          style: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColor.orange),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children:
                              languages.map((language) {
                                final isSelected =
                                    _selectedLanguage == language.code;
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap:
                                          () => _changeLanguage(language.code),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? AppColor.orange.withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              language.flagIcon,
                                              style: const TextStyle(
                                                fontSize: 32,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                language.name,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                  color:
                                                      isSelected
                                                          ? AppColor.orange
                                                          : AppColor.primary,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_circle,
                                                color: AppColor.orange,
                                                size: 28,
                                              )
                                            else
                                              Icon(
                                                Icons.circle_outlined,
                                                color: Colors.grey[400],
                                                size: 28,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (language != languages.last)
                                      Divider(
                                        height: 1,
                                        color: Colors.grey[300],
                                      ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _selectedLanguage == 'vi'
                            ? 'Thay đổi ngôn ngữ sẽ được áp dụng ngay lập tức cho toàn bộ ứng dụng.'
                            : 'Language changes will be applied immediately throughout the app.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
