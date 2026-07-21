import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:swiss/features/auth/widgets/app_auth_textfield.dart';

AppAuthTextField passwordTextField({
    required BuildContext context,
    required bool obscurePass,
    required TextEditingController ctrl,
    required VoidCallback onToggle,
    required String? Function(String?)? myValidator,
    String label = '••••••••',
    bool forLogin = false,
    bool registerPass = false,
    bool forRegisterConfirmPass = false,
  }) {
    return AppAuthTextField(
      prefixIcon: HeroIcon(HeroIcons.lockClosed, style: HeroIconStyle.solid),
      label: label,
      controller: ctrl,
      obscureText: obscurePass,
      textInputAct: forLogin || forRegisterConfirmPass
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: forLogin || forRegisterConfirmPass
          ? (_) {
              FocusScope.of(context).unfocus();
            }
          : (_) {
              FocusScope.of(context).nextFocus();
            },
      // hint: '••••••••',
      validator: myValidator,
      // validator: myValidator,
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(obscurePass ? LucideIcons.eyeOff : LucideIcons.eye),
      ),
    );
  }