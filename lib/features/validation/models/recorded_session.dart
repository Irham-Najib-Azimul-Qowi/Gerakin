import 'recorded_frame.dart';

/// Model data rekaman sesi latihan lengkap untuk Replay Debugging tanpa kamera.
class RecordedSession {
  const RecordedSession({
    required this.sessionId,
    required this.exerciseId,
    required this.recordedAt,
    required this.frames,
  });

  final String sessionId;
  final String exerciseId;
  final DateTime recordedAt;
  final List<RecordedFrame> frames;

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'recordedAt': recordedAt.toIso8601String(),
      'frames': frames.map((f) => f.toJson()).toList(),
    };
  }

  factory RecordedSession.fromJson(Map<String, dynamic> json) {
    return RecordedSession(
      sessionId: json['sessionId'] as String,
      exerciseId: json['exerciseId'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      frames: (json['frames'] as List)
          .map((f) => RecordedFrame.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}
