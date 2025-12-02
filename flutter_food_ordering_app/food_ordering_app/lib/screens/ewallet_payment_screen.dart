import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/Payment.dart';
import 'package:food_ordering_app/services/payment_service.dart';
import 'package:food_ordering_app/screens/payment_result_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class EWalletPaymentScreen extends StatefulWidget {
  static const routeName = '/ewalletPayment';

  final PaymentMethodType walletType; // momo or zalopay
  final int orderId;
  final double amount;

  const EWalletPaymentScreen({
    super.key,
    required this.walletType,
    required this.orderId,
    required this.amount,
  });

  @override
  State<EWalletPaymentScreen> createState() => _EWalletPaymentScreenState();
}

class _EWalletPaymentScreenState extends State<EWalletPaymentScreen> {
  final PaymentService _paymentService = PaymentService.instance;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Tự động bắt đầu thanh toán sau 2 giây (giả lập user đã quét QR)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _processPayment();
      }
    });
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      PaymentResult result;

      if (widget.walletType == PaymentMethodType.momo) {
        result = await _paymentService.processMoMoPayment(
          orderId: widget.orderId,
          amount: widget.amount,
        );
      } else {
        result = await _paymentService.processZaloPayPayment(
          orderId: widget.orderId,
          amount: widget.amount,
        );
      }

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

  @override
  Widget build(BuildContext context) {
    final isMoMo = widget.walletType == PaymentMethodType.momo;
    final walletName = isMoMo ? 'MoMo' : 'ZaloPay';
    final walletColor =
        isMoMo ? const Color(0xFFAF206B) : const Color(0xFF0068FF);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Thanh toán $walletName'),
        backgroundColor: walletColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo
            _buildLogoCard(walletName, walletColor),

            const SizedBox(height: 24),

            // Amount card
            _buildAmountCard(),

            const SizedBox(height: 24),

            // QR Code (mock)
            _buildQRCodeCard(walletColor),

            const SizedBox(height: 24),

            // Status
            _buildStatusCard(walletName),

            const SizedBox(height: 32),

            // Info
            _buildInfoCard(walletName),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoCard(String walletName, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet, size: 50, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              walletName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Số tiền thanh toán',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
                decimalDigits: 0,
              ).format(widget.amount),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColor.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeCard(Color color) {
    // Mock QR data
    final qrData =
        'WALLET_${widget.walletType.toString()}_ORDER_${widget.orderId}_AMOUNT_${widget.amount}';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Mã QR thanh toán',
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
                border: Border.all(color: color, width: 3),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: color),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quét mã để thanh toán',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String walletName) {
    return Card(
      elevation: 2,
      color: _isProcessing ? Colors.blue.shade50 : Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (_isProcessing)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.orange),
                ),
              )
            else
              const Icon(Icons.qr_code_scanner, color: Colors.green, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isProcessing ? 'Đang xử lý...' : 'Chờ quét mã',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isProcessing
                        ? 'Vui lòng đợi, đang xác nhận giao dịch từ $walletName'
                        : 'Mở app $walletName và quét mã QR để thanh toán',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String walletName) {
    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Lưu ý',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Đảm bảo tài khoản $walletName của bạn có đủ số dư'),
            _buildInfoItem('Giao dịch sẽ được xử lý trong vòng 1-2 phút'),
            _buildInfoItem(
              'Bạn sẽ nhận được thông báo khi thanh toán thành công',
            ),
            _buildInfoItem('Đơn hàng #${widget.orderId}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
