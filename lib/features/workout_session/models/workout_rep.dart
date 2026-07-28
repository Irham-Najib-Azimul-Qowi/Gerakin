import 'movement_phase.dart';

/// Model data rincian performa satu repetisi latihan rehabilitasi.
class WorkoutRep {
  const WorkoutRep({
    required this.repNumber,
    required this.peakAngle,
    required this.maxROM,
    required this.minROM,
    required this.accuracyScore,
    required this.durationMs,
    required this.holdsAchieved,
    required this.isSuccessful,
    required this.timestamp,
    this.phaseTimestamps = const {},
    this.feedbackMessages = const [],
  });

  final int repNumber;
  final double peakAngle;
  final double maxROM;
  final double minROM;

  /// Skor akurasi 0 - 100%
  final double accuracyScore;

  /// Durasi total rep dalam milidetik
  final int durationMs;

  /// Apakah tahanan isometric target tercapai
  final bool holdsAchieved;

  /// Apakah repetisi sah memenuhi semua fase state machine
  final bool isSuccessful;

  final DateTime timestamp;

  /// Waktu masuk ke setiap fase (Timestamp)
  final Map<MovementPhase, DateTime> phaseTimestamps;

  /// Catatan feedback saat rep berlangsung
  final List<String> feedbackMessages;

  Map<String, dynamic> toJson() {
    return {
      'repNumber': repNumber,
      'peakAngle': peakAngle,
      'maxROM': maxROM,
      'minROM': minROM,
      'accuracyScore': accuracyScore,
      'durationMs': durationMs,
      'holdsAchieved': holdsAchieved,
      'isSuccessful': isSuccessful,
      'timestamp': timestamp.toIso8601String(),
      'phaseTimestamps': phaseTimestamps.map(
        (key, value) => MapEntry(key.name, value.toIso8601String()),
      ),
      'feedbackMessages': feedbackMessages,
    };
  }

  factory WorkoutRep.fromJson(Map<String, dynamic> json) {
    final rawPhase = json['phaseTimestamps'] as Map<String, dynamic>? ?? {};
    final parsedPhase = <MovementPhase, DateTime>{};
    rawPhase.forEach((key, value) {
      final phase = MovementPhase.values.firstWhere(
        (e) => e.name == key,
        orElse: () => MovementPhase.idle,
      );
      parsedPhase[phase] = DateTime.parse(value as String);
    });

    return WorkoutRep(
      repNumber: (json['repNumber'] as num).toInt(),
      peakAngle: (json['peakAngle'] as num).toDouble(),
      maxROM: (json['maxROM'] as num).toDouble(),
      minROM: (json['minROM'] as num).toDouble(),
      accuracyScore: (json['accuracyScore'] as num).toDouble(),
      durationMs: (json['durationMs'] as num).toInt(),
      holdsAchieved: json['holdsAchieved'] as bool? ?? false,
      isSuccessful: json['isSuccessful'] as bool? ?? true,
      timestamp: DateTime.parse(json['timestamp'] as String),
      phaseTimestamps: parsedPhase,
      feedbackMessages: List<String>.from(json['feedbackMessages'] as List? ?? []),
    );
  }
}
