class Passwordvalidator {
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }

    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }

    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return "Include at least one letter";
    }

    if (!RegExp(r'\d').hasMatch(value)) {
      return "Include at least one number";
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\]~`]').hasMatch(value)) {
      return "Include at least one special character";
    }

    return null;
  }
}
