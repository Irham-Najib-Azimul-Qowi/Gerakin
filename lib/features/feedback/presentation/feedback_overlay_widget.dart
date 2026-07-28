import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/feedback_message.dart';
import '../models/feedback_result.dart';
import '../models/feedback_type.dart';

/// Widget UI Overlay yang menampilkan banner umpan balik real-time,
/// hold progress indicator, dan status countdown istirahat.
class FeedbackOverlayWidget extends StatelessWidget {
  const FeedbackOverlayWidget({
    super.key,
    required this.feedbackResult,
  });

  final FeedbackResult feedbackResult;

  @override
  Widget build(BuildContext context) {
    final primaryMsg = feedbackResult.primaryMessage;

    return Stack(
      children: [
        // 1. Top Banner Feedback Message
        if (primaryMsg != null)
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: _FeedbackBanner(message: primaryMsg),
          ),

        // 2. Hold Phase Progress Indicator
        if (feedbackResult.holdRemainingSeconds > 0)
          Positioned(
            top: 80,
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            child: _HoldProgressBadge(
              remainingSeconds: feedbackResult.holdRemainingSeconds,
            ),
          ),

        // 3. Rest Phase Countdown Overlay
        if (feedbackResult.restRemainingSeconds > 0)
          Positioned.fill(
            child: _RestCountdownOverlay(
              remainingSeconds: feedbackResult.restRemainingSeconds,
            ),
          ),
      ],
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.message});

  final FeedbackMessage message;

  @override
  Widget build(BuildContext context) {
    final typeColor = message.type.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.9),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: typeColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            message.type.icon,
            color: typeColor,
            size: 28,
          ),
          Gap(AppSpacing.md),
          Expanded(
            child: Text(
              message.text,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurfaceDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoldProgressBadge extends StatelessWidget {
  const _HoldProgressBadge({required this.remainingSeconds});

  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAllMd,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.9),
        borderRadius: AppRadius.borderRadiusFull,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer_rounded,
            color: AppColors.onSuccess,
            size: 20,
          ),
          Gap(AppSpacing.xs),
          Text(
            'TAHAN $remainingSeconds DETIK',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.onSuccess,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestCountdownOverlay extends StatelessWidget {
  const _RestCountdownOverlay({required this.remainingSeconds});

  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceDark.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ISTIRAHAT',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.onSurfaceDark,
                letterSpacing: 2.0,
              ),
            ),
            Gap(AppSpacing.md),
            Text(
              '$remainingSeconds',
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.primary,
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(AppSpacing.sm),
            Text(
              'Set berikutnya akan segera dimulai',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariantDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
