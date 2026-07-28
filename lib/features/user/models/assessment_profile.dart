import 'package:objectbox/objectbox.dart';

@Entity()
class AssessmentProfile {
  @Id()
  int id;

  final int userId;
  final int upperBodyMobilityScore; // 0-100
  final int coreStabilityScore; // 0-100
  final int enduranceLevel; // 0-100

  @Property(type: PropertyType.date)
  final DateTime completedAt;

  AssessmentProfile({
    this.id = 0,
    required this.userId,
    required this.upperBodyMobilityScore,
    required this.coreStabilityScore,
    required this.enduranceLevel,
    required this.completedAt,
  });

  AssessmentProfile copyWith({
    int? id,
    int? userId,
    int? upperBodyMobilityScore,
    int? coreStabilityScore,
    int? enduranceLevel,
    DateTime? completedAt,
  }) {
    return AssessmentProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      upperBodyMobilityScore: upperBodyMobilityScore ?? this.upperBodyMobilityScore,
      coreStabilityScore: coreStabilityScore ?? this.coreStabilityScore,
      enduranceLevel: enduranceLevel ?? this.enduranceLevel,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
