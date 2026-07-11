import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:swiss/shared/widgets/app_text_field.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({super.key, required TextEditingController emailCtrl})
    : _emailCtrl = emailCtrl;

  final TextEditingController _emailCtrl;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _emailCtrl,
      prefixIcon: Icon(LucideIcons.mail),
      label: "email@example.com",
      keyboardType: TextInputType.emailAddress,
      autofill: const [AutofillHints.email],
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return "required";
        }
        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
          return "Enter a valid email";
        }
        return null;
      },
    );
  }
}
