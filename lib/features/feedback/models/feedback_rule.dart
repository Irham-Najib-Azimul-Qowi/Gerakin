import '../../motion/models/motion_analysis.dart';
import '../../workout_engine/models/workout_session.dart';
import 'feedback_message.dart';
import 'feedback_priority.dart';

/// Aturan terisolasi berbasis fungsi (Rule-Based Approach) untuk menguji kondisi frame.
class FeedbackRule {
  const FeedbackRule({
    required this.id,
    required this.priority,
    required this.condition,
    required this.builder,
  });

  /// ID unik aturan.
  final String id;

  /// Prioritas aturan.
  final FeedbackPriority priority;

  /// Fungsi penguji kondisi biomekanik & workout session.
  final bool Function(MotionAnalysis motion, WorkoutSession session) condition;

  /// Fungsi pembangun [FeedbackMessage] jika kondisi terpenuhi.
  final FeedbackMessage Function(MotionAnalysis motion, WorkoutSession session) builder;

  /// Evaluasi aturan terhadap frame saat ini.
  FeedbackMessage? evaluate(MotionAnalysis motion, WorkoutSession session) {
    if (condition(motion, session)) {
      return builder(motion, session);
    }
    return null;
  }
}
