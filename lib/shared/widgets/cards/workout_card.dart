import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Card untuk menampilkan item workout.
class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    super.key,
    required this.title,
    required this.duration,
    required this.calories,
    this.level = 'Beginner',
    this.icon = Icons.fitness_center_rounded,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final String duration;
  final String calories;
  final String level;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  Color get _levelColor {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.info;
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
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary)
                    .withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            Gap(AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.neutral500,
                      ),
                      Gap(AppSpacing.xs),
                      Text(
                        duration,
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      Gap(AppSpacing.md),
                      Icon(
                        Icons.local_fire_department_outlined,
                        size: 14,
                        color: AppColors.neutral500,
                      ),
                      Gap(AppSpacing.xs),
                      Text(
                        calories,
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(AppSpacing.sm),
            // Level badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _levelColor.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Text(
                level,
                style: AppTextStyles.captionSmall.copyWith(
                  color: _levelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
