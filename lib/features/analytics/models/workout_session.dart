import 'package:objectbox/objectbox.dart';

@Entity()
class WorkoutSession {
  @Id()
  int id;

  final String workoutId;
  final String workoutName;

  @Property(type: PropertyType.date)
  final DateTime startTime;

  final int durationInSeconds;
  final double caloriesBurned;
  final int completedReps;
  final int targetReps;
  final double accuracy;
  final double averageRom;
  final bool isCompleted;
  final int recoveryScore;

  WorkoutSession({
    this.id = 0,
    required this.workoutId,
    required this.workoutName,
    required this.startTime,
    required this.durationInSeconds,
    required this.caloriesBurned,
    required this.completedReps,
    required this.targetReps,
    required this.accuracy,
    required this.averageRom,
    required this.isCompleted,
    required this.recoveryScore,
  });
}
