/// Enum tipe tindakan keputusan pelatih AI (Coach Action).
enum CoachAction {
  increaseDifficulty,
  reduceVolume,
  takeRest,
  maintainLevel,
  modifyTargetAngle,
  emergencyStop,
}

/// Model keputusan adaptif tingkat tinggi yang dihasilkan oleh AI Coach Decision Engine.
class CoachDecision {
  const CoachDecision({
    required this.action,
    required this.title,
    required this.reasoning,
    this.adjustedTargetAngle,
    this.adjustedRestDuration,
    required this.decidedAt,
  });

  /// Tindakan adaptif yang diputuskan.
  final CoachAction action;

  /// Judul ringkas keputusan.
  final String title;

  /// Penjelasan logis keputusan (reasoning).
  final String reasoning;

  /// Penyesuaian sudut target (jika ada).
  final double? adjustedTargetAngle;

  /// Penyesuaian durasi istirahat dalam detik (jika ada).
  final int? adjustedRestDuration;

  /// Timestamp waktu pengambilan keputusan.
  final DateTime decidedAt;

  factory CoachDecision.initial() {
    return CoachDecision(
      action: CoachAction.maintainLevel,
      title: 'Pertahankan Ritme',
      reasoning: 'Kondisi fisik dan bentuk tubuh dalam keadaan optimal.',
      decidedAt: DateTime.now(),
    );
  }
}
