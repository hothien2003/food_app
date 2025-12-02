import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/utils/helper.dart';
import 'package:food_ordering_app/widgets/customNavBar.dart';
import 'package:food_ordering_app/api/api_tinnhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InboxScreen extends StatefulWidget {
  static const routeName = "/inboxScreen";

  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ApiTinNhan _apiTinNhan = ApiTinNhan();
  List<TinNhan> _messages = [];
  bool _isLoading = true;
  int? _maNguoiDung;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    _maNguoiDung = prefs.getInt('maNguoiDung');

    List<TinNhan> messages;
    if (_maNguoiDung != null) {
      messages = await _apiTinNhan.getTinNhanByUserId(_maNguoiDung!);
    } else {
      messages = await _apiTinNhan.getPublicMessages();
    }

    setState(() {
      _messages = messages;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(int maTinNhan) async {
    await _apiTinNhan.markAsRead(maTinNhan);
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
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.arrow_back_ios_rounded),
                                ),
                                Expanded(
                                  child: Text(
                                    "Hộp thư",
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
                          SizedBox(height: 30),
                          if (_messages.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.mail_outline,
                                    size: 80,
                                    color: AppColor.placeholder,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Chưa có tin nhắn',
                                    style: TextStyle(
                                      color: AppColor.placeholder,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._messages.map((message) {
                              return GestureDetector(
                                onTap: () {
                                  if (!message.daDoc &&
                                      message.maTinNhan != null) {
                                    _markAsRead(message.maTinNhan!);
                                  }
                                },
                                child: MailCard(
                                  title: message.tieuDe,
                                  description: message.noiDung,
                                  time: message.getFormattedDate(),
                                  color:
                                      message.daDoc
                                          ? AppColor.placeholderBg
                                          : Colors.white,
                                  isUnread: !message.daDoc,
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomNavBar(menu: true),
          ),
        ],
      ),
    );
  }
}

class MailCard extends StatelessWidget {
  const MailCard({
    super.key,
    required String time,
    required String title,
    required String description,
    Color color = Colors.white,
    bool isUnread = false,
  }) : _time = time,
       _title = title,
       _description = description,
       _color = color,
       _isUnread = isUnread;

  final String _time;
  final String _title;
  final String _description;
  final Color _color;
  final bool _isUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: _color,
        border: Border(
          bottom: BorderSide(color: AppColor.placeholder, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: _isUnread ? AppColor.orange : AppColor.placeholder,
            radius: 5,
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: _isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                SizedBox(height: 5),
                Text(_description),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_time, style: TextStyle(fontSize: 10)),
              Image.asset(Helper.getAssetName("star.png", "virtual")),
            ],
          ),
        ],
      ),
    );
  }
}
