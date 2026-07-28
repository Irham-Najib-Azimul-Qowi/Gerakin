import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../core/theme/app_colors.dart';
import '../../motion/models/motion_analysis.dart';
import '../../workout_engine/models/workout_session.dart';
import '../../workout_engine/models/workout_state.dart';
import '../models/feedback_message.dart';
import '../models/feedback_result.dart';

/// Service penentu tampilan visual real-time (Skeleton colors, joint highlights, hold/rest status).
class VisualFeedbackService {
  const VisualFeedbackService();

  /// Memproses [FeedbackResult] visual untuk frame saat ini.
  FeedbackResult computeVisualResult({
    required MotionAnalysis motion,
    required WorkoutSession session,
    required List<FeedbackMessage> activeMessages,
    FeedbackMessage? primaryMessage,
  }) {
    // 1. Tentukan warna Skeleton Overlay
    Color skeletonColor = AppColors.primary;

    if (primaryMessage != null && primaryMessage.action.skeletonColor != null) {
      skeletonColor = primaryMessage.action.skeletonColor!;
    } else if (session.currentState.isHold || session.currentState.isCompleted) {
      skeletonColor = AppColors.success;
    } else if (session.currentState.isMoving) {
      skeletonColor = AppColors.primary;
    } else if (session.currentState.isReady) {
      skeletonColor = AppColors.secondary;
    }

    // 2. Kumpulkan Sendi yang Perlu Di-highlight
    final highlighted = <PoseLandmarkType>{};
    for (final msg in activeMessages) {
      highlighted.addAll(msg.action.highlightJoints);
    }

    return FeedbackResult(
      primaryMessage: primaryMessage,
      allMessages: activeMessages,
      skeletonColor: skeletonColor,
      highlightedJoints: highlighted.toList(),
      holdRemainingSeconds: session.metrics.holdDurationSeconds,
      restRemainingSeconds: session.metrics.restDurationSeconds,
    );
  }
}
