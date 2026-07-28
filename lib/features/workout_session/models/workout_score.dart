/// Penilaian multi-dimensi profesional 0-100 untuk sesi latihan rehabilitasi.
class WorkoutScore {
  const WorkoutScore({
    required this.accuracyScore,
    required this.romScore,
    required this.smoothnessScore,
    required this.confidenceScore,
    required this.consistencyScore,
    required this.holdScore,
    required this.speedScore,
    required this.safetyScore,
    required this.totalScore,
  });

  /// Akurasi sudut dibanding target
  final double accuracyScore;

  /// Pencapaian Range of Motion (ROM)
  final double romScore;

  /// Kehalusan trajektori gerakan (mencegah tremor/gerakan mendadak)
  final double smoothnessScore;

  /// Confidence pose detector AI
  final double confidenceScore;

  /// Konsistensi ritme antar repetisi
  final double consistencyScore;

  /// Ketepatan waktu isometric hold
  final double holdScore;

  /// Kecepatan / tempo eksekusi yang tepat (tidak terlalu cepat)
  final double speedScore;

  /// Keamanan gerakan (tanpa kompensasi sendi bahu/panggul berlebih)
  final double safetyScore;

  /// Skor akhir 0-100 terhitung dari bobot profesional
  final double totalScore;

  /// Predikat kualitas rehabilitasi (Sangat Baik, Baik, Cukup, Perlu Penyesuaian)
  String get grade {
    if (totalScore >= 90) return 'Sangat Baik (A+)';
    if (totalScore >= 80) return 'Baik (A)';
    if (totalScore >= 70) return 'Cukup (B)';
    if (totalScore >= 60) return 'Perlu Latihan (C)';
    return 'Perlu Evaluasi (D)';
  }

  Map<String, dynamic> toJson() {
    return {
      'accuracyScore': accuracyScore,
      'romScore': romScore,
      'smoothnessScore': smoothnessScore,
      'confidenceScore': confidenceScore,
      'consistencyScore': consistencyScore,
      'holdScore': holdScore,
      'speedScore': speedScore,
      'safetyScore': safetyScore,
      'totalScore': totalScore,
    };
  }

  factory WorkoutScore.fromJson(Map<String, dynamic> json) {
    return WorkoutScore(
      accuracyScore: (json['accuracyScore'] as num).toDouble(),
      romScore: (json['romScore'] as num).toDouble(),
      smoothnessScore: (json['smoothnessScore'] as num).toDouble(),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      consistencyScore: (json['consistencyScore'] as num).toDouble(),
      holdScore: (json['holdScore'] as num).toDouble(),
      speedScore: (json['speedScore'] as num).toDouble(),
      safetyScore: (json['safetyScore'] as num).toDouble(),
      totalScore: (json['totalScore'] as num).toDouble(),
    );
  }
}
