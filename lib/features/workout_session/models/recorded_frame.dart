import 'movement_phase.dart';
import 'workout_state.dart';

/// Telemetri landmark frame yang direkam selama latihan untuk fitur Replay.
class RecordedFrame {
  const RecordedFrame({
    required this.timestampMs,
    required this.currentAngle,
    required this.targetAngle,
    required this.phase,
    required this.state,
    required this.confidence,
    required this.repIndex,
    required this.setIndex,
    required this.landmarks,
  });

  /// Waktu berlalu sejak awal latihan (ms)
  final int timestampMs;

  /// Sudut sendi saat ini (derajat)
  final double currentAngle;

  /// Sudut target
  final double targetAngle;

  /// Fase gerakan
  final MovementPhase phase;

  /// Status workout
  final WorkoutState state;

  /// Tingkat kepercayaan AI pose
  final double confidence;

  final int repIndex;
  final int setIndex;

  /// Map titik landmark normalized: {'leftShoulder': [x, y, z, likelihood], ...}
  final Map<String, List<double>> landmarks;

  Map<String, dynamic> toJson() {
    return {
      'timestampMs': timestampMs,
      'currentAngle': currentAngle,
      'targetAngle': targetAngle,
      'phase': phase.name,
      'state': state.name,
      'confidence': confidence,
      'repIndex': repIndex,
      'setIndex': setIndex,
      'landmarks': landmarks,
    };
  }

  factory RecordedFrame.fromJson(Map<String, dynamic> json) {
    final rawLm = json['landmarks'] as Map<String, dynamic>? ?? {};
    final parsedLm = <String, List<double>>{};
    rawLm.forEach((k, v) {
      if (v is List) {
        parsedLm[k] = v.map((e) => (e as num).toDouble()).toList();
      }
    });

    return RecordedFrame(
      timestampMs: (json['timestampMs'] as num).toInt(),
      currentAngle: (json['currentAngle'] as num).toDouble(),
      targetAngle: (json['targetAngle'] as num).toDouble(),
      phase: MovementPhase.values.firstWhere(
        (e) => e.name == json['phase'],
        orElse: () => MovementPhase.idle,
      ),
      state: WorkoutState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => WorkoutState.workout,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      repIndex: (json['repIndex'] as num).toInt(),
      setIndex: (json['setIndex'] as num).toInt(),
      landmarks: parsedLm,
    );
  }
}
