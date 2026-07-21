import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:swiss/core/provider/loading_overlay_provider.dart';
import 'package:swiss/core/router/app_routes.dart';
import 'package:swiss/core/theme/app_spacing.dart';
import 'package:swiss/core/theme/app_text_styles.dart';
import 'package:swiss/core/validators/confirm_password_validator.dart';
import 'package:swiss/core/validators/password_validator.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';
import 'package:swiss/features/auth/widgets/app_error_snackbar.dart';
import 'package:swiss/features/auth/widgets/password_textfield.dart';
import 'package:swiss/shared/widgets/app_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    // Hide the keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    final loading = context.read<LoadingOverlayProvider>();

    loading.show(message: "reseting your password...");
    final bool success = await context.read<AuthProvider>().resetPassword(
      token: _otpController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
      confirmNewPassword: _confirmPasswordController.text.trim(),
    );
    loading.hide();

    if (!success || !mounted) return;
    AppSnackBar.show(
      context,
      message: "Password reset successful!",
      type: SnackBarType.success,
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.go(SwissRouter.loginAndRegistrationScreen);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorTheme = Theme.of(context).colorScheme;
    return Scaffold(
      // backgroundColor: Colors.grey[50],
      // appBar: AppBar(leading: AppBackButton()),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    size: 80,
                    color: colorTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Reset Password",
                    style: AppTextStyles.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    "Enter the OTP sent to your email and create a new password",
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // OTP Field____________________________________________
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, letterSpacing: 8),
                      maxLength: 6,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            required maxLength,
                          }) => null,
                      decoration: InputDecoration(
                        labelText: "Enter OTP",
                        hintText: "123456",

                        prefixIcon: HeroIcon(
                          HeroIcons.chatBubbleLeftEllipsis,
                          style: HeroIconStyle.solid,
                        ),
                        filled: true,
                        fillColor: colorTheme.onSecondary,
                        // fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md + AppSpacing.xs,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide: BorderSide(color: colorTheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide: BorderSide.none,
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter OTP";
                        }
                        if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                          return "Enter a valid 6-digit OTP";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  passwordTextField(
                    context: context,
                    obscurePass: _obscureNewPass,
                    ctrl: _newPasswordController,
                    label: "New Password",
                    onToggle: () {
                      setState(() => _obscureNewPass = !_obscureNewPass);
                    },
                    myValidator: (value) => Passwordvalidator.validate(value),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password
                  passwordTextField(
                    context: context,
                    obscurePass: _obscureConfirmPass,
                    ctrl: _confirmPasswordController,
                    label: "Confirm Password",
                    onToggle: () {
                      setState(
                        () => _obscureConfirmPass = !_obscureConfirmPass,
                      );
                    },
                    myValidator: (val) => ConfirmPasswordvalidator.validate(val, _newPasswordController.text.trim()),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Reset Button___________________
                  Consumer<LoadingOverlayProvider>(
                    builder: (context, provider, child) => AppButton(
                      label: provider.isLoading
                          ? "Reseting...."
                          : "Reset Password",
                      onPressed: provider.isLoading ? null : _resetPassword,
                      rad: AppRadius.lg,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
