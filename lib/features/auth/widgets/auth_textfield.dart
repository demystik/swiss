import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:swiss/shared/widgets/app_text_field.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({super.key, required this.label, this.icon, required this.firstNameCtrl} );

  final TextEditingController firstNameCtrl;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: firstNameCtrl,
      prefixIcon: Icon(icon ?? LucideIcons.userRound),
      label: label,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return "required";
        }
        return null;
      },
    );
  }
}