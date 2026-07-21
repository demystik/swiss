class ConfirmPasswordvalidator {
  static String? validate(String? value, String? newPassword) {
    if (value == null || value.trim().isEmpty) {
      return "required";
    }
    if (value.trim() != newPassword) {
      return "Passwords do not match";
    }
    return null;
  }
}
