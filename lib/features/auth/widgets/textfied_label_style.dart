import 'package:flutter/material.dart';
import 'package:swiss/core/theme/app_text_styles.dart';

class AuthTextfiedLabel extends StatelessWidget {
  final String label;
  const AuthTextfiedLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodyMedium
    );
  }
}
