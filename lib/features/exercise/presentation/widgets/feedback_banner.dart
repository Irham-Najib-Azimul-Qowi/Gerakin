import 'package:flutter/material.dart';
import '../../domain/movement_feedback.dart';

/// Banner Overlay Umpan Balik Teks & Koreksi Gerakan Real-time.
class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({
    super.key,
    required this.feedback,
  });

  final MovementFeedback? feedback;

  @override
  Widget build(BuildContext context) {
    if (feedback == null) return const SizedBox.shrink();

    Color bgColor;
    Color textColor;
    IconData iconData;

    switch (feedback!.category) {
      case FeedbackCategory.positive:
        bgColor = const Color(0xFF00E676).withValues(alpha: 0.9);
        textColor = Colors.black;
        iconData = Icons.check_circle_rounded;
        break;
      case FeedbackCategory.instruction:
        bgColor = const Color(0xFF0F172A).withValues(alpha: 0.85);
        textColor = Colors.white;
        iconData = Icons.info_rounded;
        break;
      case FeedbackCategory.correction:
        bgColor = Colors.orange.shade800.withValues(alpha: 0.92);
        textColor = Colors.white;
        iconData = Icons.warning_rounded;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: textColor, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              feedback!.message,
              style: TextStyle(
                color: textColor,
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
