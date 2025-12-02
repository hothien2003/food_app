import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/services/payment_service.dart';
import 'package:food_ordering_app/screens/payment_result_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class QRBankingPaymentScreen extends StatefulWidget {
  static const routeName = '/qrBankingPayment';

  final int orderId;
  final double amount;

  const QRBankingPaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
  });

  @override
  State<QRBankingPaymentScreen> createState() => _QRBankingPaymentScreenState();
}

class _QRBankingPaymentScreenState extends State<QRBankingPaymentScreen> {
  final PaymentService _paymentService = PaymentService.instance;
  Timer? _countdownTimer;
  int _remainingSeconds = 300; // 5 phút
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _handleTimeout();
        }
      });
    });
  }

  void _handleTimeout() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mã QR đã hết hạn. Vui lòng thử lại.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _confirmPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _paymentService.processBankingPayment(
        orderId: widget.orderId,
        amount: widget.amount,
      );

      if (!mounted) return;

      // Đi đến màn hình kết quả
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentResultScreen(result: result),
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chuyển khoản QR'),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.primary,
        elevation: 0,
      ),
      body:
          _isProcessing
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColor.orange),
                    SizedBox(height: 16),
                    Text('Đang xác nhận thanh toán...'),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Countdown timer
                    _buildCountdownCard(),

                    const SizedBox(height: 24),

                    // QR Code card
                    _buildQRCodeCard(),

                    const SizedBox(height: 24),

                    // Banking info
                    _buildBankingInfo(),

                    const SizedBox(height: 24),

                    // Instructions
                    _buildInstructions(),

                    const SizedBox(height: 32),

                    // Confirm button
                    _buildConfirmButton(),
                  ],
                ),
              ),
    );
  }

  Widget _buildCountdownCard() {
    final isExpiringSoon = _remainingSeconds <= 60;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isExpiringSoon ? Colors.red.shade50 : Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer,
              color: isExpiringSoon ? Colors.red : Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thời gian còn lại',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isExpiringSoon ? Colors.red : Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeCard() {
    final qrData = _paymentService.generateVietQRData(
      orderId: widget.orderId,
      amount: widget.amount,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Quét mã QR để chuyển khoản',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Số tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(widget.amount)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankingInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin chuyển khoản',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Ngân hàng', 'MB Bank (Quân Đội)', true),
            const Divider(height: 20),
            _buildInfoRow('Số tài khoản', '0123456789', true),
            const Divider(height: 20),
            _buildInfoRow(
              'Số tiền',
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
                decimalDigits: 0,
              ).format(widget.amount),
              true,
            ),
            const Divider(height: 20),
            _buildInfoRow('Nội dung CK', 'FD${widget.orderId}', true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool canCopy) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
            if (canCopy) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // Copy to clipboard functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Icon(Icons.copy, size: 18, color: AppColor.orange),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Hướng dẫn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionStep('1', 'Mở app ngân hàng của bạn'),
            _buildInstructionStep(
              '2',
              'Quét mã QR hoặc nhập thông tin thủ công',
            ),
            _buildInstructionStep(
              '3',
              'Kiểm tra số tiền và nội dung chuyển khoản',
            ),
            _buildInstructionStep('4', 'Xác nhận chuyển khoản'),
            _buildInstructionStep('5', 'Nhấn "Đã chuyển khoản" bên dưới'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _confirmPayment,
        icon: const Icon(Icons.check_circle),
        label: const Text('Đã chuyển khoản'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
