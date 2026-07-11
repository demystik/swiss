import 'package:flutter/material.dart';
import 'package:flutter_design_system/core/config/theme/app_spacing.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.onTap,
    this.onDeleted,
    this.selected = false,
    this.leadingIcon,
    this.variant = AppChipVariant.filled,
  });

  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool selected;
  final Widget? leadingIcon;
  final AppChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final bgColor = selected
        ? colors.primary
        : variant == AppChipVariant.outlined
        ? Colors.transparent
        : colors.surfaceContainerHighest.withValues(alpha: 0.5);

    final textColor = selected ? colors.onPrimary : colors.onSurface;

    final border = variant == AppChipVariant.outlined
        ? Border.all(
            color: selected
                ? colors.primary
                : colors.outline.withValues(alpha: 0.4),
          )
        : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: text.labelMedium?.copyWith(color: textColor)),
            if (onDeleted != null) ...[
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum AppChipVariant { filled, outlined }
