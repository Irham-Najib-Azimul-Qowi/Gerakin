import '../models/recorded_frame.dart';
import '../models/movement_phase.dart';
import '../models/workout_state.dart';
import '../../camera/models/pose_landmark_model.dart';

/// Service perekam telemetri frame & landmark skeleton untuk fitur Replay.
class WorkoutRecorder {
  WorkoutRecorder();

  final List<RecordedFrame> _frames = [];
  DateTime? _recordingStartTime;

  List<RecordedFrame> get recordedFrames => List.unmodifiable(_frames);

  void startRecording() {
    _frames.clear();
    _recordingStartTime = DateTime.now();
  }

  void recordFrame({
    required double currentAngle,
    required double targetAngle,
    required MovementPhase phase,
    required WorkoutState state,
    required double confidence,
    required int repIndex,
    required int setIndex,
    required List<PoseLandmarkModel> landmarks,
  }) {
    if (_recordingStartTime == null) return;

    final timestampMs = DateTime.now().difference(_recordingStartTime!).inMilliseconds;

    final landmarkMap = <String, List<double>>{};
    for (final lm in landmarks) {
      landmarkMap[lm.type.name] = [
        lm.x,
        lm.y,
        lm.z,
        lm.likelihood,
      ];
    }

    _frames.add(
      RecordedFrame(
        timestampMs: timestampMs,
        currentAngle: currentAngle,
        targetAngle: targetAngle,
        phase: phase,
        state: state,
        confidence: confidence,
        repIndex: repIndex,
        setIndex: setIndex,
        landmarks: landmarkMap,
      ),
    );
  }

  void stopRecording() {
    _recordingStartTime = null;
  }
}
