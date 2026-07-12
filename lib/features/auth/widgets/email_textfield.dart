import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:swiss/features/auth/widgets/app_auth_textfield.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({super.key, this.forLogin = false,  required this.emailCtrl});
  final TextEditingController emailCtrl;
  final bool forLogin;

  @override
  Widget build(BuildContext context) {
    return AppAuthTextField(
      controller: emailCtrl,
      prefixIcon: HeroIcon(HeroIcons.envelope, style: HeroIconStyle.solid,),
      label: forLogin ? "email address" : "email@example.com",
      keyboardType: TextInputType.emailAddress,
      autofill: const [AutofillHints.email],
      textInputAct: TextInputAction.next,
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
