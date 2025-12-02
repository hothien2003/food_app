import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';
import 'package:food_ordering_app/widgets/customTextInput.dart';
import 'package:food_ordering_app/api/api_thetindung.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = "/paymentScreen";

  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiTheTinDung _apiTheTinDung = ApiTheTinDung();
  List<TheTinDung> _cards = [];
  int? _maNguoiDung;
  bool _isLoading = true;

  // Controllers cho form thêm thẻ
  final TextEditingController _soTheController = TextEditingController();
  final TextEditingController _thangController = TextEditingController();
  final TextEditingController _namController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _tenController = TextEditingController();
  final TextEditingController _hoController = TextEditingController();
  bool _choPhepXoa = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _soTheController.dispose();
    _thangController.dispose();
    _namController.dispose();
    _cvvController.dispose();
    _tenController.dispose();
    _hoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final maNguoiDung = prefs.getInt('maNguoiDung');

    if (maNguoiDung != null) {
      setState(() {
        _maNguoiDung = maNguoiDung;
      });
      await _loadCards();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCards() async {
    if (_maNguoiDung == null) return;

    setState(() {
      _isLoading = true;
    });

    final cards = await _apiTheTinDung.getTheByUserId(_maNguoiDung!);
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
  }

  Future<void> _addCard() async {
    if (_maNguoiDung == null) {
      _showMessage('Vui lòng đăng nhập để thêm thẻ', isError: true);
      return;
    }

    // Validate
    if (_soTheController.text.isEmpty ||
        _thangController.text.isEmpty ||
        _namController.text.isEmpty ||
        _cvvController.text.isEmpty ||
        _tenController.text.isEmpty ||
        _hoController.text.isEmpty) {
      _showMessage('Vui lòng điền đầy đủ thông tin', isError: true);
      return;
    }

    final card = TheTinDung(
      maNguoiDung: _maNguoiDung!,
      soThe: _soTheController.text,
      tenChuThe: '${_hoController.text} ${_tenController.text}',
      thangHetHan: _thangController.text,
      namHetHan: _namController.text,
      maBaoMat: _cvvController.text,
      loaiThe: 'visa',
      choPhepXoa: _choPhepXoa,
    );

    final result = await _apiTheTinDung.addCard(card);

    if (result['success']) {
      _showMessage(result['message']);
      _clearForm();
      await _loadCards();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      _showMessage(result['message'], isError: true);
    }
  }

  Future<void> _deleteCard(int maThe, bool choPhepXoa) async {
    if (!choPhepXoa) {
      _showMessage('Thẻ này không được phép xóa', isError: true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận'),
            content: Text('Bạn có chắc muốn xóa thẻ này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final result = await _apiTheTinDung.deleteCard(maThe);
      _showMessage(result['message'], isError: !result['success']);
      if (result['success']) {
        await _loadCards();
      }
    }
  }

  void _clearForm() {
    _soTheController.clear();
    _thangController.clear();
    _namController.clear();
    _cvvController.clear();
    _tenController.clear();
    _hoController.clear();
    setState(() {
      _choPhepXoa = false;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.arrow_back_ios),
                                ),
                                Expanded(
                                  child: Text(
                                    "Thông tin thanh toán",
                                    style:
                                        Helper.getTheme(context).headlineMedium,
                                  ),
                                ),
                                Image.asset(
                                  Helper.getAssetName("cart.png", "virtual"),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Tùy chỉnh phương thức thanh toán",
                                  style: Helper.getTheme(context).displaySmall,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Divider(
                              color: AppColor.placeholder,
                              thickness: 1.5,
                              height: 30,
                            ),
                          ),
                          Container(
                            width: Helper.getScreenWidth(context),
                            constraints: BoxConstraints(minHeight: 190),
                            decoration: BoxDecoration(
                              color: AppColor.placeholderBg,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.placeholder.withOpacity(0.5),
                                  offset: Offset(0, 20),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Tiền mặt/thẻ khi nhận hàng",
                                        style: TextStyle(
                                          color: AppColor.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(Icons.check, color: AppColor.orange),
                                    ],
                                  ),
                                  Divider(
                                    color: AppColor.placeholder,
                                    thickness: 1,
                                    height: 20,
                                  ),
                                  // Hiển thị danh sách thẻ
                                  ..._cards.map(
                                    (card) => Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              child: Image.asset(
                                                Helper.getAssetName(
                                                  "visa.png",
                                                  "real",
                                                ),
                                              ),
                                            ),
                                            Text("****"),
                                            Text(
                                              card.soThe.substring(
                                                card.soThe.length - 4,
                                              ),
                                            ),
                                            OutlinedButton(
                                              style: ButtonStyle(
                                                side: WidgetStateProperty.all(
                                                  BorderSide(
                                                    color:
                                                        card.choPhepXoa
                                                            ? AppColor.orange
                                                            : AppColor
                                                                .placeholder,
                                                  ),
                                                ),
                                                shape: WidgetStateProperty.all(
                                                  StadiumBorder(),
                                                ),
                                                foregroundColor:
                                                    WidgetStateProperty.all(
                                                      card.choPhepXoa
                                                          ? AppColor.orange
                                                          : AppColor
                                                              .placeholder,
                                                    ),
                                              ),
                                              onPressed:
                                                  card.choPhepXoa
                                                      ? () => _deleteCard(
                                                        card.maThe!,
                                                        card.choPhepXoa,
                                                      )
                                                      : null,
                                              child: Text("Xóa thẻ"),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: AppColor.placeholder,
                                          thickness: 1,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Phương thức khác",
                                        style: TextStyle(
                                          color: AppColor.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 50),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                _showAddCardModal(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add),
                                  Text("Thêm thẻ tín dụng/ghi nợ khác"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: CustomNavBar()),
        ],
      ),
    );
  }

  void _showAddCardModal(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              height: Helper.getScreenHeight(context) * 0.7,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          _clearForm();
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.clear),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Text(
                          "Thêm thẻ tín dụng/ghi nợ",
                          style: Helper.getTheme(context).displaySmall,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(
                      color: AppColor.placeholder.withOpacity(0.5),
                      thickness: 1.5,
                      height: 40,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomTextInput(
                      hintText: "Số thẻ",
                      controller: _soTheController,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Hạn sử dụng"),
                        SizedBox(
                          height: 50,
                          width: 100,
                          child: CustomTextInput(
                            hintText: "MM",
                            controller: _thangController,
                            padding: const EdgeInsets.only(left: 35),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          width: 100,
                          child: CustomTextInput(
                            hintText: "YY",
                            controller: _namController,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomTextInput(
                      hintText: "Mã bảo mật",
                      controller: _cvvController,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomTextInput(
                      hintText: "Tên",
                      controller: _tenController,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomTextInput(
                      hintText: "Họ",
                      controller: _hoController,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Cho phép xóa thẻ này"),
                        Switch(
                          value: _choPhepXoa,
                          onChanged: (value) {
                            setModalState(() {
                              _choPhepXoa = value;
                            });
                          },
                          thumbColor: WidgetStateProperty.all(
                            AppColor.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _addCard,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 40),
                            Text("Thêm thẻ"),
                            SizedBox(width: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
