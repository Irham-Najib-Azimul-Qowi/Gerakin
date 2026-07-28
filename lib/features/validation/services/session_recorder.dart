import 'dart:convert';
import '../models/recorded_frame.dart';
import '../models/recorded_session.dart';

/// Service perekam sequence frame ke format JSON (Session Recorder).
class SessionRecorder {
  SessionRecorder();

  bool _isRecording = false;
  final List<RecordedFrame> _recordedFrames = [];
  DateTime? _startTime;
  String _currentExerciseId = 'arm_raise';

  bool get isRecording => _isRecording;

  void startRecording(String exerciseId) {
    _isRecording = true;
    _currentExerciseId = exerciseId;
    _startTime = DateTime.now();
    _recordedFrames.clear();
  }

  void recordFrame({
    required double shoulderAngle,
    required double elbowAngle,
    required double confidence,
    required String validationStatus,
  }) {
    if (!_isRecording || _startTime == null) return;

    final elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds;

    _recordedFrames.add(
      RecordedFrame(
        timestampMs: elapsedMs,
        shoulderAngle: shoulderAngle,
        elbowAngle: elbowAngle,
        confidence: confidence,
        validationStatus: validationStatus,
      ),
    );
  }

  RecordedSession? stopRecording() {
    if (!_isRecording || _startTime == null) return null;

    _isRecording = false;

    final session = RecordedSession(
      sessionId: 'session_${_startTime!.millisecondsSinceEpoch}',
      exerciseId: _currentExerciseId,
      recordedAt: _startTime!,
      frames: List.unmodifiable(_recordedFrames),
    );

    return session;
  }

  /// Mengekspor rekaman ke JSON String.
  String exportToJson(RecordedSession session) {
    return jsonEncode(session.toJson());
  }
}
