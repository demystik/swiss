import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:swiss/features/auth/widgets/app_auth_textfield.dart';

class TextTextField extends StatelessWidget {
  const TextTextField({super.key, required this.label, this.icon, required this.firstNameCtrl} );

  final TextEditingController firstNameCtrl;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppAuthTextField(
      controller: firstNameCtrl,
      prefixIcon: HeroIcon(HeroIcons.user,style: HeroIconStyle.solid),
      textInputAct: TextInputAction.next,
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