import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class NotificationUtil {
  static Future<void> showSuccessMessage(
    BuildContext context,
    String message, {
    VoidCallback? onComplete,
  }) async {
    await _showFlushBar(context, message, Colors.green);
    if (onComplete != null) onComplete();
  }

  static Future<void> showErrorMessage(
    BuildContext context,
    String message, {
    VoidCallback? onComplete,
  }) async {
    await _showFlushBar(context, message, Colors.redAccent);
    if (onComplete != null) onComplete();
  }

  static Future<void> _showFlushBar(
    BuildContext context,
    String message,
    Color color,
  ) {
    return Flushbar(
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 500),
      icon: const Icon(Icons.info_outline, color: Colors.white),
    ).show(context);
  }
}
