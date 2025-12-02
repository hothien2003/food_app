import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> localizedValues = {
    'vi': {
      'my_account': 'Tài khoản của tôi',
      'edit_profile': 'Chỉnh sửa hồ sơ',
      'logout': 'Đăng xuất',
      'user': 'Người dùng',
      'email_not_provided': 'Email chưa cung cấp',
      'orders': 'Đơn hàng',
      'my_orders': 'Đơn hàng của tôi',
      'cart': 'Giỏ hàng',
      'account': 'Tài khoản',
      'personal_info': 'Thông tin cá nhân',
      'saved_addresses': 'Địa chỉ đã lưu',
      'payment_methods': 'Phương thức thanh toán',
      'settings': 'Cài đặt',
      'language': 'Ngôn ngữ',
      'notifications': 'Thông báo',
      'select_language': 'Chọn ngôn ngữ',
      'help_info': 'Hỗ trợ & Thông tin',
      'help_center': 'Trung tâm hỗ trợ',
      'about': 'Giới thiệu',
      'vietnamese': 'Tiếng Việt',
      'english': 'Tiếng Anh',
      // Home & Main screens
      'home': 'Trang chủ',
      'menu': 'Thực đơn',
      'offers': 'Ưu đãi',
      'profile': 'Hồ sơ',
      'more': 'Thêm',
      'search': 'Tìm kiếm',
      'categories': 'Danh mục',
      'popular': 'Phổ biến',
      'restaurants': 'Nhà hàng',
      'foods': 'Món ăn',
      // Notification strings
      'no_notifications': 'Chưa có thông báo',
      'mark_all_read': 'Đánh dấu đã đọc',
      'notification_order_placed': 'Đơn hàng đã được đặt',
      'notification_order_confirmed': 'Đơn hàng đã được xác nhận',
      'notification_order_preparing': 'Đang chuẩn bị món',
      'notification_order_picked_up': 'Đơn hàng của bạn đã được lấy',
      'notification_order_delivered': 'Đơn hàng đã được giao',
      'notification_order_cancelled': 'Đơn hàng đã bị hủy',
      'notification_payment_success': 'Thanh toán thành công',
      'notification_payment_failed': 'Thanh toán thất bại',
      'notification_refund': 'Đã hoàn tiền',
      'notification_review_submitted': 'Đánh giá đã được gửi',
      'notification_promotion': 'Khuyến mãi mới',
      'notification_reward': 'Điểm thưởng đã được cộng',
    },
    'en': {
      'my_account': 'My Account',
      'edit_profile': 'Edit Profile',
      'logout': 'Logout',
      'user': 'User',
      'email_not_provided': 'Email not provided',
      'orders': 'Orders',
      'my_orders': 'My Orders',
      'cart': 'Cart',
      'account': 'Account',
      'personal_info': 'Personal Information',
      'saved_addresses': 'Saved Addresses',
      'payment_methods': 'Payment Methods',
      'settings': 'Settings',
      'language': 'Language',
      'notifications': 'Notifications',
      'select_language': 'Select Language',
      'help_info': 'Help & Information',
      'help_center': 'Help Center',
      'about': 'About',
      'vietnamese': 'Vietnamese',
      'english': 'English',
      // Home & Main screens
      'home': 'Home',
      'menu': 'Menu',
      'offers': 'Offers',
      'profile': 'Profile',
      'more': 'More',
      'search': 'Search',
      'categories': 'Categories',
      'popular': 'Popular',
      'restaurants': 'Restaurants',
      'foods': 'Foods',
      // Notification strings
      'no_notifications': 'No notifications yet',
      'mark_all_read': 'Mark all as read',
      'notification_order_placed': 'Order placed',
      'notification_order_confirmed': 'Order confirmed',
      'notification_order_preparing': 'Preparing your order',
      'notification_order_picked_up': 'Order picked up',
      'notification_order_delivered': 'Order delivered',
      'notification_order_cancelled': 'Order cancelled',
      'notification_payment_success': 'Payment successful',
      'notification_payment_failed': 'Payment failed',
      'notification_refund': 'Refund processed',
      'notification_review_submitted': 'Review submitted',
      'notification_promotion': 'New promotion',
      'notification_reward': 'Reward points added',
    },
  };

  String translate(String key) {
    return localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get myAccount => translate('my_account');
  String get editProfile => translate('edit_profile');
  String get logout => translate('logout');
  String get user => translate('user');
  String get emailNotProvided => translate('email_not_provided');
  String get orders => translate('orders');
  String get myOrders => translate('my_orders');
  String get cart => translate('cart');
  String get account => translate('account');
  String get personalInfo => translate('personal_info');
  String get savedAddresses => translate('saved_addresses');
  String get paymentMethods => translate('payment_methods');
  String get settings => translate('settings');
  String get language => translate('language');
  String get notifications => translate('notifications');
  String get selectLanguage => translate('select_language');
  String get helpInfo => translate('help_info');
  String get helpCenter => translate('help_center');
  String get about => translate('about');
  String get vietnamese => translate('vietnamese');
  String get english => translate('english');
  // Home & Main screens
  String get home => translate('home');
  String get menu => translate('menu');
  String get offers => translate('offers');
  String get profile => translate('profile');
  String get more => translate('more');
  String get search => translate('search');
  String get categories => translate('categories');
  String get popular => translate('popular');
  String get restaurants => translate('restaurants');
  String get foods => translate('foods');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
