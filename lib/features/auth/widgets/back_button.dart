import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:swiss/core/theme/app_spacing.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () {
          context.pop(); // if using GoRouter
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondary,
            shape: BoxShape.circle,
          ),
          child: const HeroIcon(HeroIcons.chevronLeft),
        ),
      ),
    );
  }
}
