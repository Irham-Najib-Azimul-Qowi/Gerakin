import '../models/movement_phase.dart';
import '../models/workout_rep.dart';
import 'movement_state_machine.dart';

/// Engine perhitung repetisi cerdas berbasis State Machine.
class RepCounter {
  RepCounter({
    required this.stateMachine,
    required this.targetAngle,
    required this.startAngle,
  });

  final MovementStateMachine stateMachine;
  final double targetAngle;
  final double startAngle;

  int _completedReps = 0;
  DateTime? _repStartTime;
  final List<WorkoutRep> _repHistory = [];
  final Map<MovementPhase, DateTime> _phaseTimestamps = {};
  final List<String> _currentRepFeedback = [];

  int get completedReps => _completedReps;
  List<WorkoutRep> get repHistory => List.unmodifiable(_repHistory);

  void reset() {
    _completedReps = 0;
    _repStartTime = null;
    _repHistory.clear();
    _phaseTimestamps.clear();
    _currentRepFeedback.clear();
    stateMachine.reset();
  }

  /// Memproses sudut per frame. Mengembalikan [WorkoutRep] jika ada repetisi sah yang baru saja selesai.
  WorkoutRep? processAngle(double currentAngle, DateTime now) {
    if (_repStartTime == null && stateMachine.currentPhase != MovementPhase.idle) {
      _repStartTime = now;
    }

    final prevPhase = stateMachine.currentPhase;
    final newPhase = stateMachine.processFrame(currentAngle, now);

    if (prevPhase != newPhase) {
      _phaseTimestamps[newPhase] = now;
    }

    // Jika fase telah sampai pada Completed, sahkan 1 repetisi penuh!
    if (newPhase == MovementPhase.completed) {
      _completedReps += 1;
      final startTime = _repStartTime ?? now.subtract(const Duration(seconds: 2));
      final durationMs = now.difference(startTime).inMilliseconds;

      final rom = (stateMachine.peakAngle - stateMachine.minAngle).abs();
      final targetROM = (targetAngle - startAngle).abs();
      final accuracy = targetROM > 0 ? (rom / targetROM * 100.0).clamp(0.0, 100.0) : 90.0;

      final rep = WorkoutRep(
        repNumber: _completedReps,
        peakAngle: stateMachine.peakAngle,
        maxROM: stateMachine.peakAngle,
        minROM: stateMachine.minAngle,
        accuracyScore: accuracy,
        durationMs: durationMs,
        holdsAchieved: stateMachine.holdProgress >= 0.9,
        isSuccessful: true,
        timestamp: now,
        phaseTimestamps: Map.from(_phaseTimestamps),
        feedbackMessages: List.from(_currentRepFeedback),
      );

      _repHistory.add(rep);

      // Reset state machine untuk repetisi berikutnya
      stateMachine.reset();
      _repStartTime = null;
      _phaseTimestamps.clear();
      _currentRepFeedback.clear();

      return rep;
    }

    return null;
  }

  void addFeedback(String msg) {
    if (!_currentRepFeedback.contains(msg)) {
      _currentRepFeedback.add(msg);
    }
  }
}
