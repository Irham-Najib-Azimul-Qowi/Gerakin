import 'package:objectbox/objectbox.dart';

@Entity()
class RecoveryProgress {
  @Id()
  int id;

  @Property(type: PropertyType.date)
  final DateTime date;

  final int perceivedPainLevel; // 1-10
  final int fatigueLevel; // 1-10
  final int sleepQualityScore; // 1-100
  final double heartRateVariability;
  final int muscleSorenessScore; // 1-10
  final int overallRecoveryScore; // 1-100

  RecoveryProgress({
    this.id = 0,
    required this.date,
    required this.perceivedPainLevel,
    required this.fatigueLevel,
    required this.sleepQualityScore,
    required this.heartRateVariability,
    required this.muscleSorenessScore,
    required this.overallRecoveryScore,
  });
}
