import 'package:flutter/material.dart';
import 'package:food_ordering_app/const/colors.dart';
import 'package:food_ordering_app/models/Payment.dart';
import 'package:intl/intl.dart';

class PaymentResultScreen extends StatelessWidget {
  static const routeName = '/paymentResult';

  final PaymentResult result;
  final VoidCallback? onComplete;

  const PaymentResultScreen({super.key, required this.result, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleComplete(context);
        return false;
      },
      child: Scaffold(
        backgroundColor:
            result.isSuccess ? Colors.green.shade50 : Colors.red.shade50,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Animation
                      _buildAnimation(),

                      const SizedBox(height: 32),

                      // Status title
                      Text(
                        result.isSuccess
                            ? 'Thanh toán thành công!'
                            : 'Thanh toán thất bại',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color:
                              result.isSuccess
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Message
                      Text(
                        result.isSuccess
                            ? 'Đơn hàng của bạn đã được thanh toán thành công'
                            : result.errorMessage ??
                                'Đã có lỗi xảy ra trong quá trình thanh toán',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Payment details card
                      _buildDetailsCard(),

                      const SizedBox(height: 24),

                      // Transaction info
                      _buildTransactionInfo(),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              _buildBottomButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    if (result.isSuccess) {
      // Success animation
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle,
          size: 120,
          color: Colors.green.shade600,
        ),
      );
    } else {
      // Failure animation
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.error, size: 120, color: Colors.red.shade600),
      );
    }
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDetailRow(
              'Số tiền',
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
                decimalDigits: 0,
              ).format(result.amount),
              isBold: true,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Phương thức',
              _getPaymentMethodName(result.paymentMethod),
            ),
            const Divider(height: 24),
            _buildDetailRow('Mã giao dịch', result.transactionId),
            const Divider(height: 24),
            _buildDetailRow(
              'Thời gian',
              DateFormat('HH:mm - dd/MM/yyyy').format(result.timestamp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 20 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? AppColor.orange : AppColor.primary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionInfo() {
    if (!result.isSuccess || result.metadata == null) {
      return const SizedBox.shrink();
    }

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
                Icon(Icons.info_outline, size: 20, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Thông tin bổ sung',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...result.metadata!.entries.map((entry) {
              if (entry.key == 'orderId') return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatMetadataKey(entry.key),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (result.isSuccess) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleComplete(context),
                  icon: const Icon(Icons.check),
                  label: const Text('Xem đơn hàng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Về trang chủ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleComplete(BuildContext context) {
    if (onComplete != null) {
      onComplete!();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  String _getPaymentMethodName(PaymentMethodType method) {
    switch (method) {
      case PaymentMethodType.cod:
        return 'Tiền mặt (COD)';
      case PaymentMethodType.momo:
        return 'Ví MoMo';
      case PaymentMethodType.zalopay:
        return 'ZaloPay';
      case PaymentMethodType.card:
        return 'Thẻ tín dụng/Ghi nợ';
      case PaymentMethodType.banking:
        return 'Chuyển khoản ngân hàng';
    }
  }

  String _formatMetadataKey(String key) {
    switch (key) {
      case 'walletType':
        return 'Loại ví';
      case 'cardType':
        return 'Loại thẻ';
      case 'lastFourDigits':
        return '4 số cuối';
      case 'bankName':
        return 'Ngân hàng';
      case 'accountNumber':
        return 'Số tài khoản';
      default:
        return key;
    }
  }
}
