import 'package:flutter/material.dart';
import 'package:food_ordering_app/api/api_nguoidung.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/NguoiDung.dart';
import 'package:food_ordering_app/pages/DonHang/donhang_page.dart';
import 'package:food_ordering_app/pages/GioHang/giohang_page.dart';
import 'package:food_ordering_app/pages/Login_Signup/login.dart';
import 'package:food_ordering_app/pages/profile/edit_profile_page.dart';
import 'package:food_ordering_app/screens/homeScreen.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/utils/shared_preferences_helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = "/profilePage";

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  NguoiDung? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final maNguoiDung = await layMaNguoiDungDangNhap();
      if (maNguoiDung != null) {
        final api = ApiNguoiDung();
        final user = await api.getNguoiDungById(maNguoiDung);
        setState(() {
          userData = user;
        });
      }
    } catch (e) {
      print('Lỗi khi tải thông tin người dùng: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await dangXuat();
    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Login.routeName, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tài khoản của tôi',
          style: TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: AppColor.primary),
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColor.orange),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile info section
                    _buildProfileSection(),
                    const SizedBox(height: 24),

                    // Orders section
                    _buildMenuSection(
                      title: 'Đơn hàng',
                      icon: Icons.receipt_long,
                      menuItems: [
                        MenuItem(
                          title: 'Đơn hàng của tôi',
                          icon: Icons.shopping_bag,
                          onTap: () {
                            Navigator.pushNamed(context, DonHangPage.routeName);
                          },
                        ),
                        MenuItem(
                          title: 'Giỏ hàng',
                          icon: Icons.shopping_cart,
                          onTap: () {
                            Navigator.pushNamed(context, GioHangPage.routeName);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Account section
                    _buildMenuSection(
                      title: 'Tài khoản',
                      icon: Icons.person,
                      menuItems: [
                        MenuItem(
                          title: 'Thông tin cá nhân',
                          icon: Icons.person_outline,
                          onTap: () async {
                            if (userData != null) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EditProfilePage(user: userData!),
                                ),
                              );
                              if (result == true) {
                                _loadUserData();
                              }
                            }
                          },
                        ),
                        MenuItem(
                          title: 'Địa chỉ đã lưu',
                          icon: Icons.location_on_outlined,
                          onTap: () {
                            // TODO: Navigate to saved addresses
                          },
                        ),
                        MenuItem(
                          title: 'Phương thức thanh toán',
                          icon: Icons.payment_outlined,
                          onTap: () {
                            // TODO: Navigate to payment methods
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Settings section
                    _buildMenuSection(
                      title: 'Cài đặt',
                      icon: Icons.settings,
                      menuItems: [
                        MenuItem(
                          title: 'Ngôn ngữ',
                          icon: Icons.language,
                          onTap: () {
                            // TODO: Language settings
                          },
                        ),
                        MenuItem(
                          title: 'Thông báo',
                          icon: Icons.notifications_outlined,
                          onTap: () {
                            // TODO: Notification settings
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Help & About section
                    _buildMenuSection(
                      title: 'Hỗ trợ & Thông tin',
                      icon: Icons.help_outline,
                      menuItems: [
                        MenuItem(
                          title: 'Trung tâm hỗ trợ',
                          icon: Icons.headset_mic_outlined,
                          onTap: () {
                            // TODO: Navigate to help center
                          },
                        ),
                        MenuItem(
                          title: 'Giới thiệu',
                          icon: Icons.info_outline,
                          onTap: () {
                            // TODO: Navigate to about page
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: const CustomNavBar(profile: true),
    );
  }

  Widget _buildProfileSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: AssetImage(
                Helper.getAssetName("icons8-user-50.png", "virtual"),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userData?.hoTen ?? 'Người dùng',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userData?.email ?? 'Email chưa cung cấp',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                if (userData != null) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: userData!),
                    ),
                  );
                  if (result == true) {
                    _loadUserData();
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColor.orange,
                side: const BorderSide(color: AppColor.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Chỉnh sửa hồ sơ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required IconData icon,
    required List<MenuItem> menuItems,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColor.orange),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...menuItems.map((item) => _buildMenuItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(item.icon, color: Colors.grey[700], size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final Function() onTap;

  MenuItem({required this.title, required this.icon, required this.onTap});
}

