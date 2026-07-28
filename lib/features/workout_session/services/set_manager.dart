import '../models/workout_rep.dart';
import '../models/workout_set.dart';
import '../models/set_result.dart';

/// Service pengelola siklus Set & Rest pada sesi latihan rehabilitasi.
class SetManager {
  SetManager({
    required this.totalSetsTarget,
    required this.targetRepsPerSet,
    required this.restSecondsBetweenSets,
  });

  final int totalSetsTarget;
  final int targetRepsPerSet;
  final int restSecondsBetweenSets;

  int _currentSetIndex = 1;
  final List<WorkoutSet> _completedSets = [];
  final List<WorkoutRep> _currentSetReps = [];

  int get currentSetIndex => _currentSetIndex;
  int get totalSetsTargetVal => totalSetsTarget;
  List<WorkoutSet> get completedSets => List.unmodifiable(_completedSets);
  bool get isAllSetsCompleted => _currentSetIndex > totalSetsTarget;

  void reset() {
    _currentSetIndex = 1;
    _completedSets.clear();
    _currentSetReps.clear();
  }

  /// Menambahkan repetisi baru ke set aktif.
  SetResult? onRepCompleted(WorkoutRep rep) {
    _currentSetReps.add(rep);

    if (_currentSetReps.length >= targetRepsPerSet) {
      // Set selesai!
      final avgAcc = _currentSetReps.fold(0.0, (sum, r) => sum + r.accuracyScore) / _currentSetReps.length;
      final avgRom = _currentSetReps.fold(0.0, (sum, r) => sum + r.maxROM) / _currentSetReps.length;

      final finishedSet = WorkoutSet(
        setNumber: _currentSetIndex,
        targetReps: targetRepsPerSet,
        completedReps: _currentSetReps.length,
        averageAccuracy: avgAcc,
        averageROM: avgRom,
        reps: List.from(_currentSetReps),
        restDurationSeconds: restSecondsBetweenSets,
        isCompleted: true,
      );

      _completedSets.add(finishedSet);
      _currentSetReps.clear();

      final hasNext = _currentSetIndex < totalSetsTarget;
      if (hasNext) {
        _currentSetIndex += 1;
      } else {
        _currentSetIndex = totalSetsTarget + 1; // All done
      }

      return SetResult(
        isCompleted: true,
        set: finishedSet,
        restSecondsRemaining: restSecondsBetweenSets,
        hasNextSet: hasNext,
      );
    }

    return null;
  }
}
