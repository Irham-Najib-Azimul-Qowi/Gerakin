import '../models/coach_decision.dart';
import '../models/fatigue_status.dart';
import '../models/physical_profile.dart';
import '../models/safety_status.dart';

/// Engine pengambil keputusan adaptif berbasis aturan terisolasi (Rule-Based Decision Engine).
class CoachDecisionEngine {
  const CoachDecisionEngine();

  /// Mengevaluasi keputusan pelatih AI berdasarkan profil fisik, kelelahan, dan keselamatan.
  CoachDecision evaluateDecision({
    required PhysicalProfile profile,
    required FatigueStatus fatigue,
    required SafetyStatus safety,
  }) {
    final now = DateTime.now();

    // Aturan 1: Bahaya Keselamatan Darurat (Safety First)
    if (safety.shouldStopWorkout) {
      return CoachDecision(
        action: CoachAction.emergencyStop,
        title: 'Hentikan Latihan Sekarang!',
        reasoning: 'Skor keselamatan rendah (${safety.safetyScore.toInt()}%). Risiko cedera terdeteksi.',
        decidedAt: now,
      );
    }

    // Aturan 2: Kelelahan Tinggi
    if (fatigue.level == FatigueLevel.severe) {
      return CoachDecision(
        action: CoachAction.takeRest,
        title: 'Istirahat Ekstra Diperlukan',
        reasoning: 'Terdeteksi penurunan kestabilan gerak (${fatigue.degradationPercentage.toInt()}%).',
        adjustedRestDuration: 30,
        decidedAt: now,
      );
    }

    // Aturan 3: Kelelahan Sedang
    if (fatigue.level == FatigueLevel.moderate) {
      return CoachDecision(
        action: CoachAction.reduceVolume,
        title: 'Kurangi Target Repetisi',
        reasoning: 'Kelelahan sedang terdeteksi. Pengurangan target rep untuk mencegah cedera.',
        decidedAt: now,
      );
    }

    // Aturan 4: Kestabilan Sangat Tinggi & Tanpa Kelelahan -> Naikkan Kesulitan
    if (profile.stabilityScore >= 85.0 && fatigue.level == FatigueLevel.none) {
      return CoachDecision(
        action: CoachAction.increaseDifficulty,
        title: 'Tingkatkan Level Kesulitan!',
        reasoning: 'Kestabilan gerak sangat konsisten (${profile.stabilityScore.toInt()}%). SIAP naik level.',
        decidedAt: now,
      );
    }

    // Aturan 5: Penyesuaian Sudut Target Adaptif
    if (profile.shoulderRom < 130.0) {
      return CoachDecision(
        action: CoachAction.modifyTargetAngle,
        title: 'Penyesuaian Sudut Target Adaptif',
        reasoning: 'Rentang gerak disesuaikan dengan kapasitas ROM bahu (${profile.shoulderRom.toInt()}°).',
        adjustedTargetAngle: profile.shoulderRom - 10.0,
        decidedAt: now,
      );
    }

    // Aturan Standar: Pertahankan Level
    return CoachDecision(
      action: CoachAction.maintainLevel,
      title: 'Pertahankan Performa',
      reasoning: 'Kondisi fisik dan tempo gerakan berada dalam kisaran ideal.',
      decidedAt: now,
    );
  }
}
