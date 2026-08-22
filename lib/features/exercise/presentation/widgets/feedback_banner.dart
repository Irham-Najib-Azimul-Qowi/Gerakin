import 'package:flutter/material.dart';
import 'package:gerakin/core/theme/app_colors.dart';
import '../../domain/movement_feedback.dart';

/// Banner Overlay Umpan Balik Teks & Koreksi Gerakan Light Translucent.
class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({
    super.key,
    required this.feedback,
  });

  final MovementFeedback? feedback;

  @override
  Widget build(BuildContext context) {
    if (feedback == null) return const SizedBox.shrink();

    Color accentColor;
    IconData iconData;

    switch (feedback!.category) {
      case FeedbackCategory.positive:
        accentColor = const Color(0xFF008E76);
        iconData = Icons.check_circle_rounded;
        break;
      case FeedbackCategory.instruction:
        accentColor = AppColors.primaryDark;
        iconData = Icons.info_rounded;
        break;
      case FeedbackCategory.correction:
        accentColor = const Color(0xFFD97706);
        iconData = Icons.warning_rounded;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: accentColor, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              feedback!.message,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
