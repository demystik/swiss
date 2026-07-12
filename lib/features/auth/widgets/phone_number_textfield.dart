import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:swiss/shared/widgets/app_text_field.dart';

class PhoneNumberTextField extends StatelessWidget {
  const PhoneNumberTextField({
    super.key,
    required TextEditingController phoneNumberCtrl,
  }) : _phoneNumberCtrl = phoneNumberCtrl;

  final TextEditingController _phoneNumberCtrl;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _phoneNumberCtrl,
      prefixIcon: Icon(LucideIcons.phone),
      label: "'+234 909 000 0000'",
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return "Phone number is required";
        }
    
        final phone = v.trim();
    
        final nigeriaPhoneRegex = RegExp(
          r'^(?:\+234|234|0)(7[0-9]|8[0-9]|9[0-9])\d{8}$',
        );
    
        if (!nigeriaPhoneRegex.hasMatch(phone)) {
          return "Enter a valid Nigerian phone number";
        }
    
        return null;
      },
    );
  }
}
