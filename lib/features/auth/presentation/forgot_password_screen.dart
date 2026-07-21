import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:swiss/core/provider/loading_overlay_provider.dart';
import 'package:swiss/core/router/app_routes.dart';
import 'package:swiss/core/theme/app_spacing.dart';
import 'package:swiss/core/theme/app_text_styles.dart';
import 'package:swiss/features/auth/provider/auth_provider.dart';
import 'package:swiss/features/auth/widgets/app_error_snackbar.dart';
import 'package:swiss/features/auth/widgets/back_button.dart';
import 'package:swiss/features/auth/widgets/email_textfield.dart';
import 'package:swiss/shared/widgets/app_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final _forgotPasswordFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> sendForgotPasswordRequest() async {
    final loading = context.read<LoadingOverlayProvider>();
    loading.show(message: "Logging your forgot password...");

    final success = await context.read<AuthProvider>().forgotPassword(
      emailCtrl.text,
      '',
    );
    if (success) {
      loading.hide();
      emailCtrl.clear();
      if (!mounted) return;
      context.go(SwissRouter.resetPasswordScreen);
    } else {
      loading.hide();
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: "Something is wrong, try again later!",
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: AppBackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _forgotPasswordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: double.infinity, height: AppSpacing.xs),
                Text(
                  textAlign: TextAlign.center,
                  "Forgot Password",
                  style: AppTextStyles.displayLarge,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Text(
                    textAlign: TextAlign.center,
                    "Enter your email address to recieve a reset link and regain access to your account.",
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                EmailTextField(emailCtrl: emailCtrl, forLogin: true),
                SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: "Continue",
                  onPressed: () {
                    // Hide the keyboard
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (_forgotPasswordFormKey.currentState!.validate()) {
                      sendForgotPasswordRequest();
                    }
                  },
                  rad: AppRadius.xl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
