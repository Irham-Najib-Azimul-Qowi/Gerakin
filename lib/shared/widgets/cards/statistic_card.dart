import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Trend direction untuk [StatisticCard].
enum TrendDirection { up, down, neutral }

/// Card untuk menampilkan statistik angka dengan trend.
class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.trend,
    this.trendValue,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final TrendDirection? trend;
  final String? trendValue;
  final VoidCallback? onTap;

  Color get _trendColor {
    switch (trend) {
      case TrendDirection.up:
        return AppColors.success;
      case TrendDirection.down:
        return AppColors.error;
      case TrendDirection.neutral:
      case null:
        return AppColors.neutral500;
    }
  }

  IconData get _trendIcon {
    switch (trend) {
      case TrendDirection.up:
        return Icons.trending_up_rounded;
      case TrendDirection.down:
        return Icons.trending_down_rounded;
      case TrendDirection.neutral:
      case null:
        return Icons.trending_flat_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingAllLg,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.primary)
                          .withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: iconColor ?? AppColors.primary,
                    ),
                  ),
                  Gap(AppSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.captionLarge.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Gap(AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            if (trend != null && trendValue != null) ...[
              Gap(AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_trendIcon, size: 16, color: _trendColor),
                  Gap(AppSpacing.xxs),
                  Text(
                    trendValue!,
                    style: AppTextStyles.captionMedium.copyWith(
                      color: _trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
