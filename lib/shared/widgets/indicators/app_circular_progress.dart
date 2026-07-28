import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Circular progress indicator dengan label di tengah.
class AppCircularProgress extends StatelessWidget {
  const AppCircularProgress({
    super.key,
    required this.value,
    this.size = 80,
    this.strokeWidth = 6,
    this.color,
    this.backgroundColor,
    this.centerText,
    this.showPercentage = true,
    this.centerWidget,
  });

  /// Nilai 0.0 – 1.0.
  final double value;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final String? centerText;
  final bool showPercentage;
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? AppColors.primary;
    final bgColor =
        backgroundColor ?? progressColor.withValues(alpha: 0.15);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: bgColor,
              color: progressColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          if (centerWidget != null)
            centerWidget!
          else if (centerText != null)
            Text(
              centerText!,
              style: AppTextStyles.labelLarge.copyWith(
                color: progressColor,
              ),
            )
          else if (showPercentage)
            Text(
              '${(value * 100).toInt()}%',
              style: AppTextStyles.labelLarge.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
