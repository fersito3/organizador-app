import 'package:flutter/material.dart';

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? (isError ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded),
              color: isError ? const Color(0xFFF87171) : const Color(0xFF34D399),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A), // Slate 900 elegante
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: const Duration(seconds: 2),
        elevation: 4,
      ),
    );
  }
}
