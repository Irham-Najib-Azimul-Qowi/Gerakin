import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../core/theme/app_colors.dart';
import '../../motion/models/motion_analysis.dart';
import '../../motion/models/motion_validation.dart';
import '../../workout_engine/models/workout_session.dart';
import '../../workout_engine/models/workout_state.dart';
import '../models/feedback_action.dart';
import '../models/feedback_message.dart';
import '../models/feedback_priority.dart';
import '../models/feedback_rule.dart';
import '../models/feedback_type.dart';

/// Engine penguji aturan feedback berbasis data (Rule-Based Approach).
@Deprecated('Gunakan WorkoutSessionEngine di lib/features/workout_session/services/workout_session_engine.dart sebagai Single Source of Truth')
class FeedbackRuleEngine {
  FeedbackRuleEngine({List<FeedbackRule>? initialRules}) {
    _rules.addAll(initialRules ?? _buildDefaultRules());
  }

  final List<FeedbackRule> _rules = [];

  /// Daftar aturan terdaftar.
  List<FeedbackRule> get rules => List.unmodifiable(_rules);

  /// Menambahkan aturan baru secara dinamis.
  void registerRule(FeedbackRule rule) {
    _rules.add(rule);
  }

  /// Mengevaluasi seluruh aturan terhadap [MotionAnalysis] dan [WorkoutSession] saat ini.
  List<FeedbackMessage> evaluate({
    required MotionAnalysis motion,
    required WorkoutSession session,
  }) {
    final messages = <FeedbackMessage>[];
    for (final rule in _rules) {
      final msg = rule.evaluate(motion, session);
      if (msg != null) {
        messages.add(msg);
      }
    }
    return messages;
  }

  /// Aturan-aturan standar (Default Rules).
  List<FeedbackRule> _buildDefaultRules() {
    final now = DateTime.now();

    return [
      // 1. Out of Range Rule (Critical)
      FeedbackRule(
        id: 'out_of_range',
        priority: FeedbackPriority.critical,
        condition: (motion, session) =>
            motion.validationStatus == MotionValidationStatus.outOfRange &&
            !session.currentState.isCompleted,
        builder: (motion, session) => FeedbackMessage(
          id: 'out_of_range',
          type: FeedbackType.warning,
          priority: FeedbackPriority.critical,
          text: 'Posisi Tubuh Di Luar Kamera',
          voiceText: 'Posisikan seluruh tubuh di depan kamera',
          action: const FeedbackAction(
            skeletonColor: AppColors.error,
            vibrateHaptic: true,
          ),
          timestamp: now,
        ),
      ),

      // 2. Too Fast Rule (Critical)
      FeedbackRule(
        id: 'too_fast',
        priority: FeedbackPriority.critical,
        condition: (motion, session) =>
            motion.validationStatus == MotionValidationStatus.tooFast,
        builder: (motion, session) => FeedbackMessage(
          id: 'too_fast',
          type: FeedbackType.warning,
          priority: FeedbackPriority.critical,
          text: 'Gerakan Terlalu Cepat!',
          voiceText: 'Gerakan terlalu cepat, perlambat tempo',
          action: const FeedbackAction(
            skeletonColor: AppColors.warning,
          ),
          timestamp: now,
        ),
      ),

      // 3. Shoulder Asymmetry Rule (High)
      FeedbackRule(
        id: 'shoulder_asymmetry',
        priority: FeedbackPriority.high,
        condition: (motion, session) =>
            !motion.posture.isShoulderSymmetric &&
            session.currentState.isMoving,
        builder: (motion, session) => FeedbackMessage(
          id: 'shoulder_asymmetry',
          type: FeedbackType.warning,
          priority: FeedbackPriority.high,
          text: 'Posisi Bahu Miring!',
          voiceText: 'Luruskan posisi bahu kamu',
          action: const FeedbackAction(
            skeletonColor: AppColors.warning,
            highlightJoints: [
              PoseLandmarkType.leftShoulder,
              PoseLandmarkType.rightShoulder,
            ],
          ),
          timestamp: now,
        ),
      ),

      // 4. Hold Phase Rule (High)
      FeedbackRule(
        id: 'hold_phase',
        priority: FeedbackPriority.high,
        condition: (motion, session) => session.currentState.isHold,
        builder: (motion, session) => FeedbackMessage(
          id: 'hold_phase',
          type: FeedbackType.liveCoaching,
          priority: FeedbackPriority.high,
          text: 'Tahan Posisi Puncak!',
          voiceText: 'Tahan posisi',
          action: const FeedbackAction(
            skeletonColor: AppColors.success,
            showHoldProgress: true,
          ),
          timestamp: now,
        ),
      ),

      // 5. Success Completed Rule (High)
      FeedbackRule(
        id: 'workout_completed',
        priority: FeedbackPriority.high,
        condition: (motion, session) => session.currentState.isCompleted,
        builder: (motion, session) => FeedbackMessage(
          id: 'workout_completed',
          type: FeedbackType.success,
          priority: FeedbackPriority.high,
          text: 'Latihan Selesai! Luar Biasa!',
          voiceText: 'Selamat! Latihan telah selesai!',
          action: const FeedbackAction(
            skeletonColor: AppColors.success,
          ),
          timestamp: now,
        ),
      ),

      // 6. General Live Coaching Moving Rule (Medium)
      FeedbackRule(
        id: 'live_coaching_moving',
        priority: FeedbackPriority.medium,
        condition: (motion, session) => session.currentState.isMoving,
        builder: (motion, session) => FeedbackMessage(
          id: 'live_coaching_moving',
          type: FeedbackType.liveCoaching,
          priority: FeedbackPriority.medium,
          text: 'Bagus! Dorong terus sampai sudut target',
          voiceText: 'Bagus, lanjutkan gerakan',
          action: const FeedbackAction(
            skeletonColor: AppColors.primary,
          ),
          timestamp: now,
        ),
      ),
    ];
  }
}
