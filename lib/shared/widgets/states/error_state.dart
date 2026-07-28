import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../buttons/app_button.dart';

/// Widget untuk menampilkan state error dengan retry.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Terjadi Kesalahan',
    this.message,
    this.icon = Icons.error_outline_rounded,
    this.retryLabel = 'Coba Lagi',
    this.onRetry,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.error,
              ),
            ),
            Gap(AppSpacing.xl),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              Gap(AppSpacing.sm),
              Text(
                message!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              Gap(AppSpacing.xxl),
              AppButton(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                size: AppButtonSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
