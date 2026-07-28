import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/indicators/app_circular_progress.dart';
import '../../../../../shared/widgets/indicators/app_progress_bar.dart';

/// Section indicators di Component Gallery.
class IndicatorsSection extends StatelessWidget {
  const IndicatorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Indicators', style: AppTextStyles.headlineSmall),
        Gap(AppSpacing.lg),

        // Linear Progress
        Text('Linear Progress', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        AppProgressBar(
          value: 0.75,
          label: 'Daily Goal',
          showPercentage: true,
        ),
        Gap(AppSpacing.md),
        AppProgressBar(
          value: 0.45,
          label: 'Calories',
          valueText: '450 / 1000 kcal',
          color: AppColors.tertiary,
        ),
        Gap(AppSpacing.md),
        AppProgressBar(
          value: 0.9,
          label: 'Steps',
          color: AppColors.success,
          height: 10,
        ),
        Gap(AppSpacing.xxl),

        // Circular Progress
        Text('Circular Progress', style: AppTextStyles.titleSmall),
        Gap(AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppCircularProgress(
              value: 0.75,
              size: 80,
            ),
            AppCircularProgress(
              value: 0.45,
              size: 80,
              color: AppColors.secondary,
            ),
            AppCircularProgress(
              value: 0.92,
              size: 80,
              color: AppColors.success,
              centerText: '🔥',
            ),
            AppCircularProgress(
              value: 0.3,
              size: 60,
              strokeWidth: 4,
              color: AppColors.tertiary,
            ),
          ],
        ),
      ],
    );
  }
}
