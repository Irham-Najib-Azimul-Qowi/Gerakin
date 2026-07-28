import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../motion/models/motion_analysis.dart';
import '../../workout_engine/models/workout_session.dart';

import '../models/feedback_result.dart';
import '../models/voice_settings.dart';
import '../services/feedback_priority_engine.dart';
import '../services/feedback_rule_engine.dart';
import '../services/visual_feedback_service.dart';
import '../services/voice_feedback_service.dart';

/// Riverpod Provider untuk [FeedbackEngine].
final feedbackEngineProvider =
    NotifierProvider<FeedbackEngine, FeedbackResult>(
  FeedbackEngine.new,
);

/// Facade / Controller utama Real-Time Feedback Engine.
///
/// TANGGUNG JAWAB:
/// - Menerima input dari Motion Engine ([MotionAnalysis]) dan Workout Engine ([WorkoutSession]).
/// - Mengeksekusi Rule Engine ([FeedbackRuleEngine]) berbasis data.
/// - Menyaring prioritas pesan ([FeedbackPriorityEngine]).
/// - Memicu umpan balik suara TTS dengan cooldown ([VoiceFeedbackService]).
/// - Mengatur warna skeleton dan sorotan visual ([VisualFeedbackService]).
class FeedbackEngine extends Notifier<FeedbackResult> {
  FeedbackEngine({
    FeedbackRuleEngine? ruleEngine,
    FeedbackPriorityEngine? priorityEngine,
    VoiceFeedbackService? voiceService,
    VisualFeedbackService? visualService,
  })  : _ruleEngine = ruleEngine ?? FeedbackRuleEngine(),
        _priorityEngine = priorityEngine ?? const FeedbackPriorityEngine(),
        _voiceService = voiceService ?? VoiceFeedbackService(),
        _visualService = visualService ?? const VisualFeedbackService();

  final FeedbackRuleEngine _ruleEngine;
  final FeedbackPriorityEngine _priorityEngine;
  final VoiceFeedbackService _voiceService;
  final VisualFeedbackService _visualService;

  @override
  FeedbackResult build() {
    return const FeedbackResult(
      skeletonColor: AppColors.primary,
    );
  }

  /// Memproses umpan balik untuk frame real-time saat ini.
  Future<FeedbackResult> processFrame({
    required MotionAnalysis motion,
    required WorkoutSession session,
  }) async {
    // 1. Evaluasi Aturan (Rule Engine)
    final activeMessages = _ruleEngine.evaluate(
      motion: motion,
      session: session,
    );

    // 2. Seleksi Prioritas Pesan Utama (Priority Engine)
    final primaryMessage = _priorityEngine.selectPrimaryMessage(activeMessages);

    // 3. Pemicuan Suara (Voice TTS dengan Cooldown)
    if (primaryMessage != null) {
      await _voiceService.speakMessage(primaryMessage);
    }

    // 4. Perhitungan Hasil Visual
    final result = _visualService.computeVisualResult(
      motion: motion,
      session: session,
      activeMessages: activeMessages,
      primaryMessage: primaryMessage,
    );

    state = result;
    return result;
  }

  /// Memperbarui pengaturan suara TTS.
  Future<void> updateVoiceSettings(VoiceSettings newSettings) async {
    await _voiceService.updateSettings(newSettings);
  }

  /// Reset cooldown dan riwayat suara.
  void resetVoiceCooldown() {
    _voiceService.resetCooldown();
  }
}
