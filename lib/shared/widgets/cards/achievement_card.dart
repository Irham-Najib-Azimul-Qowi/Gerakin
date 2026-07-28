import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Card untuk menampilkan achievement / badge.
class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.emoji_events_rounded,
    this.isUnlocked = true,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconBgColor = isUnlocked
        ? AppColors.tertiary.withValues(alpha: 0.12)
        : AppColors.neutral200;
    final iconFgColor =
        isUnlocked ? AppColors.tertiary : AppColors.neutral400;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingAllLg,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: AppRadius.borderRadiusLg,
          boxShadow: isUnlocked ? AppShadows.sm : AppShadows.xs,
          border: isUnlocked
              ? Border.all(
                  color: AppColors.tertiary.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Row(
          children: [
            // Badge icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(icon, color: iconFgColor, size: 28),
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
                      color: isUnlocked
                          ? AppColors.onSurface
                          : AppColors.neutral500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Gap(AppSpacing.xxs),
                  Text(
                    description,
                    style: AppTextStyles.captionMedium.copyWith(
                      color: AppColors.neutral500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Gap(AppSpacing.sm),
            // Lock / check
            Icon(
              isUnlocked
                  ? Icons.check_circle_rounded
                  : Icons.lock_rounded,
              color: isUnlocked ? AppColors.success : AppColors.neutral400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
