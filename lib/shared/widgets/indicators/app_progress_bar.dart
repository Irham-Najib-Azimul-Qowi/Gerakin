import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Linear progress bar dengan label dan value text.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.label,
    this.valueText,
    this.height = 8,
    this.color,
    this.backgroundColor,
    this.showPercentage = false,
  });

  /// Nilai 0.0 – 1.0.
  final double value;
  final String? label;
  final String? valueText;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppColors.primary;
    final bgColor =
        backgroundColor ?? barColor.withValues(alpha: 0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || valueText != null || showPercentage)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: AppTextStyles.captionLarge.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                Text(
                  valueText ?? '${(value * 100).toInt()}%',
                  style: AppTextStyles.captionLarge.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: AppRadius.borderRadiusFull,
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: bgColor,
              color: barColor,
            ),
          ),
        ),
      ],
    );
  }
}
