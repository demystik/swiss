import 'package:flutter/material.dart';
import 'package:swiss/core/theme/app_spacing.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.buttonIcon,
    this.variant = AppButtonVariant.primary,
    this.rad = AppRadius.md,
  });

  final String label;
  final IconData? buttonIcon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final double rad;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rad),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    label,
                    style: text.titleMedium?.copyWith(color: colors.onPrimary),
                  ),
                  SizedBox(width: AppSpacing.sm),
                Icon(buttonIcon, color: Colors.white,),
              ],
            ),
      ),
    );
  }
}

enum AppButtonVariant { primary, outlined, ghost }
