import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:swiss/shared/widgets/app_text_field.dart';

class PasswordTextfield extends StatelessWidget {
  final TextEditingController passCtrl;
  final bool obscurePassword;
  const PasswordTextfield({super.key, required this.passCtrl, required this.obscurePassword});

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: "••••••••",
      prefixIcon: Icon(LucideIcons.lockKeyhole),
      controller: passCtrl,
      obscureText: obscurePassword,
      hint: "••••••••",
      suffixIcon: IconButton(onPressed: onPressed, icon: icon),
      );
  }
}


//  AppTextField(
//                       prefixIcon: Icon(LucideIcons.lockKeyhole),
//                       label: '••••••••',
//                       controller: _loginPasswordCtrl,
//                       obscureText: obscurePassword,
//                       hint: '••••••••',
//                       suffixIcon: Icon(obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff),
//                       ),
//                     TextField(
//                       obscureText: obscurePassword,
//                       decoration: InputDecoration(
                       
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             obscurePassword
//                                 ? Icons.visibility_outlined
//                                 : Icons.visibility_off_outlined,
//                             color: const Color(0xFF757575),
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               obscurePassword = !obscurePassword;
//                             });
//                           },
//                         ),
//                         filled: true,
//                         fillColor: const Color(0xFFFBFBFB),
//                         contentPadding: const EdgeInsets.symmetric(
//                           vertical: 16,
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFE5E5E5),
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(16),
//                           borderSide: const BorderSide(
//                             color: Color(0xFF1A1A1A),
//                             width: 1.5,
//                           ),
//                         ),
//                       ),
//                     ),