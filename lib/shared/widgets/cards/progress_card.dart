import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Card untuk menampilkan progress dengan indicator.
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
    this.subtitle,
    this.color,
    this.useCircular = false,
  });

  final String title;
  final String value;

  /// Nilai 0.0 – 1.0.
  final double progress;
  final String? subtitle;
  final Color? color;
  final bool useCircular;

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? AppColors.primary;

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              if (useCircular)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 4,
                        backgroundColor: progressColor
                            .withValues(alpha: 0.15),
                        color: progressColor,
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Gap(AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: progressColor,
            ),
          ),
          if (subtitle != null) ...[
            Gap(AppSpacing.xxs),
            Text(
              subtitle!,
              style: AppTextStyles.captionMedium.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ],
          if (!useCircular) ...[
            Gap(AppSpacing.md),
            ClipRRect(
              borderRadius: AppRadius.borderRadiusFull,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor:
                    progressColor.withValues(alpha: 0.15),
                color: progressColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
