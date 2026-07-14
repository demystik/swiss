import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    Color background;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        background = Colors.green;
        icon = Icons.check_circle_outline_rounded;
        break;

      case SnackBarType.error:
        background = Colors.red.shade700;
        icon = Icons.error_outline_rounded;
        break;

      case SnackBarType.warning:
        background = Colors.orange.shade700;
        icon = Icons.warning_amber_rounded;
        break;

      case SnackBarType.info:
        background = Colors.blue.shade700;
        icon = Icons.info_outline_rounded;
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: duration,
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
