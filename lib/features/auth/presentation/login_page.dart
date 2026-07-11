import 'package:flutter/material.dart';
import 'package:flutter_design_system/core/common/widgets/app_button.dart';

import '../../../../core/common/widgets/app_card.dart';
import '../../../../core/common/widgets/app_text_field.dart';
import '../../../../core/config/theme/app_spacing.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────
                  Text('Welcome Back', style: text.displayMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in to continue',
                    style: text.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Form Card ──────────────────────────────
                  AppCard(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Email',
                          hint: 'you@example.com',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: colors.onSurface.withValues(alpha: 0.4),
                          ),
                          validator: (v) => (v?.contains('@') ?? false)
                              ? null
                              : 'Enter a valid email',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Password',
                          controller: _passCtrl,
                          obscureText: _obscure,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: colors.onSurface.withValues(alpha: 0.4),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: colors.onSurface.withValues(alpha: 0.4),
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) => (v?.length ?? 0) >= 6
                              ? null
                              : 'Minimum 6 characters',
                        ),
                      ],
                    ),
                  ),

                  // ── Forgot Password ────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot password?',
                        style: text.bodySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Submit ─────────────────────────────────
                  AppButton(
                    label: 'Sign In',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: add logic here
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Register redirect ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: text.bodyMedium),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Sign Up',
                          style: text.bodyMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
