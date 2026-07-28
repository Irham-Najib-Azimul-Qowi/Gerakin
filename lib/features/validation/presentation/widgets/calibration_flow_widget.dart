import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/calibration_status.dart';

/// Widget panduan alur kalibrasi pra-latihan (Calibration Flow Widget).
class CalibrationFlowWidget extends StatelessWidget {
  const CalibrationFlowWidget({
    super.key,
    required this.calibrationStatus,
  });

  final CalibrationStatus calibrationStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAllLg,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerDark.withValues(alpha: 0.95),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: calibrationStatus.isCompleted
              ? AppColors.success
              : AppColors.primary,
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                calibrationStatus.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.tune_rounded,
                color: calibrationStatus.isCompleted
                    ? AppColors.success
                    : AppColors.primary,
                size: 28,
              ),
              Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalibrasi Pra-Latihan',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.onSurfaceDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tahap: ${calibrationStatus.step.name.toUpperCase()}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${calibrationStatus.progressPercentage.toInt()}%',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Gap(AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.borderRadiusSm,
            child: LinearProgressIndicator(
              value: calibrationStatus.progressPercentage / 100.0,
              color: calibrationStatus.isCompleted
                  ? AppColors.success
                  : AppColors.primary,
              backgroundColor: AppColors.surfaceVariantDark,
              minHeight: 8,
            ),
          ),
          Gap(AppSpacing.md),
          Text(
            calibrationStatus.statusMessage,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariantDark,
            ),
          ),
        ],
      ),
    );
  }
}
