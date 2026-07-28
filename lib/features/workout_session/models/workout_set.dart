import 'workout_rep.dart';

/// Model data rincian performa satu set latihan.
class WorkoutSet {
  const WorkoutSet({
    required this.setNumber,
    required this.targetReps,
    required this.completedReps,
    required this.averageAccuracy,
    required this.averageROM,
    required this.reps,
    required this.restDurationSeconds,
    this.isCompleted = false,
  });

  final int setNumber;
  final int targetReps;
  final int completedReps;
  final double averageAccuracy;
  final double averageROM;
  final List<WorkoutRep> reps;
  final int restDurationSeconds;
  final bool isCompleted;

  WorkoutSet copyWith({
    int? setNumber,
    int? targetReps,
    int? completedReps,
    double? averageAccuracy,
    double? averageROM,
    List<WorkoutRep>? reps,
    int? restDurationSeconds,
    bool? isCompleted,
  }) {
    return WorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      targetReps: targetReps ?? this.targetReps,
      completedReps: completedReps ?? this.completedReps,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      averageROM: averageROM ?? this.averageROM,
      reps: reps ?? this.reps,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'targetReps': targetReps,
      'completedReps': completedReps,
      'averageAccuracy': averageAccuracy,
      'averageROM': averageROM,
      'reps': reps.map((r) => r.toJson()).toList(),
      'restDurationSeconds': restDurationSeconds,
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    final rawReps = json['reps'] as List? ?? [];
    return WorkoutSet(
      setNumber: (json['setNumber'] as num).toInt(),
      targetReps: (json['targetReps'] as num).toInt(),
      completedReps: (json['completedReps'] as num).toInt(),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
      averageROM: (json['averageROM'] as num).toDouble(),
      reps: rawReps.map((e) => WorkoutRep.fromJson(e as Map<String, dynamic>)).toList(),
      restDurationSeconds: (json['restDurationSeconds'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
